#!/bin/bash

MONGODBATLAS_APP_URL="https://${mongodbatlas_stitch_app_id}.mongodbstitch.com/"
sed -i "s,MONGODB_STITCH_APP_URL,$MONGODBATLAS_APP_URL,g" ${asciidoc_index_path}
