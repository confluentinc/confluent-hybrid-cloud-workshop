# Confluent Hybrid-Cloud Workshop

## Overview

This repository allows you to configure and provision a cloud-based workshop using your preferred cloud provider GCP, AWS or Azure. Each workshop participant connects to their own virtual machine and is intended to act as a psuedo on-premise datacenter. A single Confluent Cloud cluster is shared by all workshop participants.

For a single workshop participant, the logical architecture looks like this.

![workshop](core/asciidoc/images/hybrid-cloud-ws/default/architecture.png) 

From a physical architecture point of view, each component, except for Confluent Cloud, is hosted on the participant's virtual machine. 

Each workshop participant will work through a series of Labs to create the following ksqlDB Supply & Demand Application.

![workshop](core/asciidoc/images/hybrid-cloud-ws/default/ksqlDB_topology.png)

## Prerequisites

* macOS or Linux
* Terraform 0.12.20 or later
* Python + [Yaml](https://pyyaml.org/wiki/PyYAML)
* A GCP/AWS/Azure account with the appropriate privileges
* For setting AWS credentials, please check the following link: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where
* A Confluent Cloud Account
* [MongoDB Realm CLI](https://docs.mongodb.com/realm/deploy/realm-cli-reference/#installation) (required if you use the MongoDB Atlas extension)

## Things to know before starting

This repository is going to create the required  Confluent Cloud features (Environment, Cluster, API keys...).
The cluster type by default is Basic. If it is necessary to use Standard or Dedicated cluster, please check this link to make the required changes:
https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster .

## Provisioning a Workshop

Create an empty directory somewhere that will contain your workshop configuration file.

```
mkdir ~/myworkshop
```

Copy `workshop-example-<cloud provider>.yaml` to `workshop.yaml` in the directory you just created.

```
cp workshop-<cloud provider>-example.yaml ~/myworkshop/workshop.yaml
```

Edit `~/myworkshop/workshop.yaml` and make the required changes.

Change your current directory to the root of the repository

```
cd ~/confluent-hybrid-cloud-workshop
```

To start provisioning the workshop, run `workshop-create.py` and pass in your workshop directory

```
python3 workshop-create.py --dir ~/myworkshop
```
Maybe you will need to execute the following commands before executing the previous script:
```
python3 -m pip install boto3
python3 -m pip install google
python3 -m pip install google-api-python-client
python3 -m pip install azure-cli
```

When you are finished with the workshop you can destroy it using `workshop-destroy.py`

```
python3 workshop-destroy.py --dir ~/myworkshop
```

## Troubleshooting
If you ever need root access on the docker containers use:

```
docker exec --interactive --tty --user root --workdir / kafka-connect-ccloud bash
```
See [this blog post](https://rmoff.net/2021/01/13/running-as-root-on-docker-images-that-dont-use-root/) for more info


## License

This project is licensed under the Apache 2.0 - see the [LICENSE.md](LICENSE.md) file for details
