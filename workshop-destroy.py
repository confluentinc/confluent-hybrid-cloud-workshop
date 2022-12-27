#!/usr/bin/env python

import argparse
import yaml
import os
import shutil
import boto3
import botocore

argparse = argparse.ArgumentParser()
argparse.add_argument('--dir', help="Workshop directory", required=True)
args = argparse.parse_args()
workshop_home = args.dir

# Open and parse configuration file
with open(os.path.join(workshop_home, "workshop.yaml"), 'r') as yaml_file:
    try:
        config = yaml.safe_load(yaml_file)
    except yaml.YAMLError as exc:
        print(exc)


def check_login():
    boto3.setup_default_session(profile_name=(config['workshop']['core']['profile']))
    sts = boto3.client('sts')
    try:
        sts.get_caller_identity()
        return True
    except botocore.exceptions.UnauthorizedSSOTokenError:
        return False
    except botocore.exceptions.ClientError:
        return False


if (config['workshop']['core']['cloud_provider']) == 'aws':
    if check_login():
        print("Credentials are valid.")
    else:
        print("AWS Credentials are NOT valid. Please refresh your credentials before executing the script.")
        exit()

terraform_staging = os.path.join(args.dir, ".terraform_staging")
docker_staging = os.path.join(args.dir, ".docker_staging")

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
