#!/bin/bash
MONGODBATLAS_PUBLIC_KEY=${mongodbatlas_public_key}
MONGODBATLAS_PRIVATE_KEY=${var.mongodbatlas_private_key}
MONGODBATLAS_PROJECT_ID=${var.mongodbatlas_project_id}
MONGODBATLAS_APP_NAME=checkout
source /tmp/mongodb_stitch_utils.sh
replace_stitch_url_in_docs