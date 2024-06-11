# Confluent Workshops repository

## Overview

This repository is composed of several Confluent workshops which allow you to configure and provision them.
Some are cloud-based workshops using your preferred cloud provider GCP, AWS or Azure where each workshop participant connects to their own virtual machine and is intended to act as a psuedo on-premise datacenter and if they require  Confluent Cloud cluster , one single cluster will be used and shared by all workshop participants. 
Others are docker based which you can execute locally without involving any cloud provider.

Every folder is a different workshop, please read the README file of the workshop that you want to provision where you will find more information there.

## Prerequisites

* macOS or Linux
* Terraform 0.12.20 or later
* Python + [Yaml](https://pyyaml.org/wiki/PyYAML)
* A GCP/AWS/Azure account with the appropriate privileges
* For setting AWS credentials, please check the following link: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where
* A Confluent Cloud Account
* [MongoDB Realm CLI](https://docs.mongodb.com/realm/deploy/realm-cli-reference/#installation) (required if you use the MongoDB Atlas extension)
* Docker installed

Please check README file of the workshop that you want to provision where you will find more detailed information.

## License

This project is licensed under the Apache 2.0 - see the [LICENSE.md](LICENSE.md) file for details
