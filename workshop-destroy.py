#!/usr/bin/env python

import argparse
import yaml
import os
import shutil

argparse = argparse.ArgumentParser()
argparse.add_argument('--dir', help="Workshop directory", required=True)
args = argparse.parse_args()
workshop_home = args.dir

# Open and parse configuration file
with open( os.path.join(workshop_home, "workshop.yaml"), 'r') as yaml_file:
    try:
        config = yaml.safe_load(yaml_file)
    except yaml.YAMLError as exc:
        print(exc)

terraform_staging=os.path.join(args.dir, ".terraform_staging" )
docker_staging=os.path.join(args.dir, ".docker_staging")

# Terraform Destroy
owd = os.getcwd()
if os.path.exists(terraform_staging):
    os.chdir(terraform_staging)
    os.system("terraform destroy -auto-approve")
    os.chdir(owd)
    shutil.rmtree(terraform_staging)

# Delete Docker staging area
if os.path.exists(docker_staging):
     shutil.rmtree(docker_staging)



