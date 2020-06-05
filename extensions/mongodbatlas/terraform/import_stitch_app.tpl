#!/bin/bash

function import_stitch_app(){
    
    stitch-cli login --api-key=${MONGODBATLAS_PUBLIC_KEY} --private-api-key=${MONGODBATLAS_PRIVATE_KEY} --yes
    stitch-cli import  \
        --path mongodb/stitch_checkout  \
        --strategy=replace-by-name \
        --project-id ${MONGODBATLAS_PROJECT_ID} \
        --include-hosting \
        --yes
}

sudo apt install npm -y
sudo npm install -g mongodb-stitch-cli -y

import_stitch_app