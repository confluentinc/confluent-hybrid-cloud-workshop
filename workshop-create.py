#!/usr/bin/env python

import argparse
import os
import yaml
import json
import shutil
import fileinput
import re 
import glob

argparse = argparse.ArgumentParser()
argparse.add_argument('--dir', help="Workshop directory", required=True)
args = argparse.parse_args()

docker_staging=os.path.join(args.dir, ".docker_staging")
terraform_staging=os.path.join(args.dir, ".terraform_staging")

# Open and parse configuration file
with open( os.path.join(args.dir, "workshop.yaml"), 'r') as yaml_file:
    try:
        config = yaml.safe_load(yaml_file)
    except yaml.YAMLError as exc:
        print(exc)

def copytree(src, dst):
  if not os.path.exists(dst):
    os.makedirs(dst)
    shutil.copystat(src, dst)
  lst = os.listdir(src)
  for item in lst:
    s = os.path.join(src, item)
    d = os.path.join(dst, item)
    if os.path.isdir(s):
      copytree(s, d)
    else:
      shutil.copy2(s, d)

#----------------------------------------
# Create the Terraform staging directory 
#----------------------------------------

# Copy core terraform files to terraform staging
copytree(os.path.join("./core/terraform", config['workshop']['core']['cloud_provider']), terraform_staging)
copytree("./core/terraform/common", os.path.join(terraform_staging, "common"))

# Copy extension terraform files to terraform staging
if 'extensions' in config['workshop'] and config['workshop']['extensions'] != None:
    for extension in config['workshop']['extensions']:
        if os.path.exists(os.path.join("./extensions", extension, "terraform")):
            copytree(os.path.join("./extensions", extension, "terraform"), terraform_staging)

# Create Terraform tfvars file 
with open(os.path.join(terraform_staging, "terraform.tfvars"), 'w') as tfvars_file:
    
    # Process high level
    for var in config['workshop']:
        if var not in ['core', 'extensions']:
            tfvars_file.write(str(var) + '="' + str(config['workshop'][var]) + "\"\n")
    for var in config['workshop']['core']:
        if var != 'cloud_provider':
            tfvars_file.write(str(var) + '="' + str(config['workshop']['core'][var]) + "\"\n")
    if 'extensions' in config['workshop'] and config['workshop']['extensions'] != None:
        for extension in config['workshop']['extensions']:
            if os.path.exists(os.path.join("./extensions", extension, "terraform")):
                if config['workshop']['extensions'][extension] != None:
                    for var in config['workshop']['extensions'][extension]:
                        tfvars_file.write(str(var) + '="' + str(config['workshop']['extensions'][extension][var]) + "\"\n")

#----------------------------------------------------------------------------
# Create the Docker staging directory, this directory is uploaded to each VM 
#----------------------------------------------------------------------------

# remove stage directory
if os.path.exists(docker_staging):
    shutil.rmtree(docker_staging)
    
# Create staging directory and copy the required docker files into it
os.mkdir(docker_staging)
os.mkdir(os.path.join(docker_staging, "extensions"))
copytree("./core/docker/", docker_staging)

# Copy asciidoc directory to .docker_staging
copytree(os.path.join("./core/asciidoc"), os.path.join(docker_staging, "asciidoc"))

# Deal with extensions
if 'extensions' in config['workshop'] and config['workshop']['extensions'] != None:

    # Add each extensions asciidoc file as an include in the main workshop.adoc file
    includes = []
    include_str="" 
    for extension in config['workshop']['extensions']:
        if os.path.isdir(os.path.join("./extensions", extension, "asciidoc")):
            includes.append(glob.glob(os.path.join("./extensions", extension, "asciidoc/*.adoc"))[0])
    
    # Build extension include string
    for include in includes:
        include_str += 'include::.' + include + '[]\n'
    
    # Add extension includes to core workshop.adoc 
    for line in fileinput.input(os.path.join(docker_staging, "asciidoc/workshop.adoc"), inplace=True):
        line=re.sub("^#EXTENSIONS_PLACEHOLDER#",include_str,line)   
        print(line.rstrip())
    
    # Copy extension asciidoc files to docker staging
    for extension in config['workshop']['extensions']:
        if os.path.isdir(os.path.join("./extensions", extension, "asciidoc")):
            copytree(os.path.join("./extensions", extension, "asciidoc"), os.path.join(docker_staging, "extensions", extension, "asciidoc"))

    # Copy extension docker files to docker staging and create docker .env file
    for extension in config['workshop']['extensions']:
        if os.path.isdir(os.path.join("./extensions", extension, "docker")):
            copytree(os.path.join("./extensions", extension, "docker"), os.path.join(docker_staging, "extensions", extension, "docker"))
            # Create .env file for docker
            if config['workshop']['extensions'][extension] != None:
                for var in config['workshop']['extensions'][extension]:
                    with open(os.path.join(docker_staging, "extensions", extension, "docker/.env"), 'a') as env_file:
                        env_file.write(var + '=' + config['workshop']['extensions'][extension][var] + "\n")
                    
       
#-----------------
# Create Workshop
#-----------------

os.chdir(terraform_staging)

# Terraform init
os.system("terraform init")

# Terraform plan
os.system("terraform plan")

# Terraform apply
os.system("terraform apply -auto-approve")

# Show workshop details
os.system("terraform output -json external_ip_addresses > workshop_details.out")
if os.path.exists("workshop_details.out"):
    with open('workshop_details.out') as wd:
        ip_addresses = json.load(wd)
        print("*" * 65)
        print("\n WORKSHOP DETAILS\n Copy & paste into Google Sheets and share with the participants\n")
        print("*" * 65)
        print('=SPLIT("ENVIRONMENT ID,GETTING STARTED URL,PARTICIPANT NAME/EMAIL",",")')
        for id, ip_address in enumerate(ip_addresses, start=0):
            print('=SPLIT("{}-{},http://{}", ",")'.format(config['workshop']['name'], id, ip_address))

    os.remove("workshop_details.out")
