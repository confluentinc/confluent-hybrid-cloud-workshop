#!/usr/bin/env python

import argparse
import os
import yaml
import json
import shutil
import fileinput
import re
import glob
import boto3
import botocore
import google
from google.oauth2 import service_account
from azure.cli.core import get_default_cli

argparse = argparse.ArgumentParser()
argparse.add_argument('--dir', help="Workshop directory", required=True)
args = argparse.parse_args()
sts = boto3.client('sts')

docker_staging = os.path.join(args.dir, ".docker_staging")
terraform_staging = os.path.join(args.dir, ".terraform_staging")

# Open and parse configuration file
with open(os.path.join(args.dir, "workshop.yaml"), 'r') as yaml_file:
    try:
        config = yaml.safe_load(yaml_file)
    except yaml.YAMLError as exc:
        print(exc)


def check_aws_login():
    boto3.setup_default_session(profile_name=(config['workshop']['core']['profile']))
    sts = boto3.client('sts')
    try:
        sts.get_caller_identity()
        return True
    except botocore.exceptions.UnauthorizedSSOTokenError:
        return False
    except botocore.exceptions.ClientError:
        return False


if config['workshop']['core']['cloud_provider'] is not None:

    if (config['workshop']['core']['cloud_provider']) == 'aws':
        if check_aws_login():
            print("Credentials are valid.")
        else:
            print("AWS Credentials are NOT valid. Please refresh your credentials before executing the script.")
            exit()
else:
    print("You must specify cloud provider in the yaml file.")


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


if int(config['workshop']['participant_count']) > 35:
    print()
    print("*" * 70)
    print("WARNING: Make sure your Confluent Cloud cluster has enough free partitions")
    print("to support this many participants. Each participant uses ~50 partitions.")
    print("*" * 70)
    print()
    while True:
        val = input('Do You Want To Continue (y/n)? ')
        if val == 'y':
            break
        elif val == 'n':
            exit()

# ----------------------------------------
# Create the Terraform staging directory 
# ----------------------------------------

# Copy core terraform files to terraform staging
copytree(os.path.join("./core/terraform", config['workshop']['core']['cloud_provider']), terraform_staging)
copytree("./core/terraform/common", os.path.join(terraform_staging, "common"))

# Create Terraform tfvars file 
with open(os.path.join(terraform_staging, "terraform.tfvars"), 'w') as tfvars_file:
    # Process high level
    for var in config['workshop']:
        if var not in ['core']:
            tfvars_file.write(str(var) + '="' + str(config['workshop'][var]) + "\"\n")
    for var in config['workshop']['core']:
        if var == 'availability_zones':
            tfvars_file.write(str(var) + '=' + str(json.dumps(config['workshop']['core'][var])) + "\n")
        else:
            tfvars_file.write(str(var) + '="' + str(config['workshop']['core'][var]) + "\"\n")

# ----------------------------------------------------------------------------
# Create the Docker staging directory, this directory is uploaded to each VM 
# ----------------------------------------------------------------------------

# remove stage directory
if os.path.exists(docker_staging):
    shutil.rmtree(docker_staging)

# Create staging directory and copy the required docker files into it
os.mkdir(docker_staging)
copytree("./core/docker/", docker_staging)
copytree("../common-docker/", docker_staging)


# -----------------
# Create Workshop
# -----------------

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
        print('=SPLIT("SSH USERNAME,GETTING STARTED URL,PARTICIPANT NAME/EMAIL",",")')
        for id, ip_address in enumerate(ip_addresses, start=1):
            print('=SPLIT("dc{:02d},http://{}", ",")'.format(id, ip_address))
            # print('=SPLIT("{}-{},http://{}", ",")'.format(config['workshop']['name'], id, ip_address))

    os.remove("workshop_details.out")
