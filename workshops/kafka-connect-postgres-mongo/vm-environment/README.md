# Confluent Workshop - Kafka Connect - From Postgres To MongoDB

## Overview

This repository allows you to configure and provision a cloud-based workshop using AWS. Each workshop participant connects to their own virtual machine and is intended to act as a psuedo on-premise datacenter. 
Each environment has a Postgres database, Confluent Platform and a MongoDB database. It also has browser UI for each component for the ease of connecting to them.


Each workshop participant will work through a series of Labs to perform Database Modernization, using Connectors for data flow between Apache Kafka® and Databases, and using KsqlDb for data processing.

For a single workshop participant, the logical architecture looks like this.

![](../common-docker/asciidoc/images/architecture.png)

## Prerequisites

* macOS or Linux
* Terraform 0.12.20 or later
* Python + [Yaml](https://pyyaml.org/wiki/PyYAML)
* AWS account with the appropriate privileges
* For setting AWS credentials, please check the following link: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where


## Provisioning a Workshop

Create an empty directory somewhere that will contain your workshop configuration file.

```
mkdir ~/myworkshop
```

Copy `workshop-example-aws.yaml` to `workshop.yaml` in the directory you just created.

```
cp workshop-aws-example.yaml ~/myworkshop/workshop.yaml
```

Edit `~/myworkshop/workshop.yaml` and make the required changes.

Change your current directory to the root of the repository

```
cd ~/vm-environment
```

To start provisioning the workshop, run `workshop-create.py` and pass in your workshop directory

```
python3 workshop-create.py --dir ~/myworkshop
```
Maybe you will need to execute the following commands before executing the previous script:
```
python3 -m pip install boto3
```

When the script finishes it will print the http direction and the user to access to the workshop documentation to be able to complete the labs.

When you are finished with the workshop you can destroy it using `workshop-destroy.py`

```
python3 workshop-destroy.py --dir ~/myworkshop
```

## License

This project is licensed under the Apache 2.0 - see the [LICENSE.md](LICENSE.md) file for details
