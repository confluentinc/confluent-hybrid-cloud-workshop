#!/bin/bash

function import_stitch_app(){
    stitch-cli login --api-key=${MONGODBATLAS_PUBLIC_KEY} --private-api-key=${MONGODBATLAS_PRIVATE_KEY} --yes
    stitch-cli import --path $STITCH_APP_DIR --strategy=replace-by-name --project-id ${MONGODBATLAS_PROJECT_ID} --include-hosting --yes
}

#app_name = checkout
function get_stitch_app_id() {

    MONGODBATLAS_APP_ID=$(curl --request GET \
    --header 'Authorization: Bearer '${MONGODBATLAS_BEARER_AUTH} \
    https://stitch.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps | jq -c '.[] | select( .name == "'$MONGODBATLAS_APP_NAME'" ) ' | jq '._id' -r)

    echo "DELETING Stitch App: App id $MONGODBATLAS_APP_ID"

    curl --request DELETE \
    --header 'Authorization: Bearer '${MONGODBATLAS_BEARER_AUTH} \
    https://stitch.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps/${MONGODBATLAS_APP_ID}
}

function delete_stitch_app() {
    login_stitch_api
    get_stitch_app_id
  
    echo "DELETING Stitch App: App id $MONGODBATLAS_APP_ID"

    curl --request DELETE \
    --header 'Authorization: Bearer '${MONGODBATLAS_BEARER_AUTH} \
    https://stitch.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps/${MONGODBATLAS_APP_ID}
}

function login_stitch_api() {

    MONGODBATLAS_BEARER_AUTH=$(curl --request POST \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --data '{"username": "'"${MONGODBATLAS_PUBLIC_KEY}"'", "apiKey": "'"${MONGODBATLAS_PRIVATE_KEY}"'"}' \
        https://stitch.mongodb.com/api/admin/v3.0/auth/providers/mongodb-cloud/login | jq '.access_token' -r)

}

function install_stitch_cli() {
    sudo apt install npm -y
    sudo npm install -g mongodb-stitch-cli -y
}