#!/bin/bash

function import_realm_app(){
    #install_realm_cli
    #Installation should be done on the host laptop that execute the workshop creation. This code is executed locally
    realm-cli login --api-key=${MONGODBATLAS_PUBLIC_KEY} --private-api-key=${MONGODBATLAS_PRIVATE_KEY} --yes
    realm-cli import --path $REALM_APP_DIR --strategy=replace-by-name --project-id ${MONGODBATLAS_PROJECT_ID} --include-hosting --yes
}

#app_name = checkout
function get_realm_app_id() {

    echo "Getting Realm App ID via REST api"
    echo "curl --request GET \
    --header 'Authorization: Bearer '${MONGODBATLAS_BEARER_AUTH} \
    https://realm.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps | jq -c --arg app_name $MONGODBATLAS_APP_NAME '.[] | select( .name==$app_name ) ' | jq '._id' -r"

    MONGODBATLAS_APP_ID=$(curl --request GET \
    --header 'Authorization: Bearer '${MONGODBATLAS_BEARER_AUTH} \
    https://realm.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps | jq -c --arg app_name "$MONGODBATLAS_APP_NAME" '.[] | select( .name==$app_name ) ' | jq '._id' -r)

}

function delete_realm_app() {
    login_realm_api
    get_realm_app_id
  
    echo "DELETING Realm App: App id $MONGODBATLAS_APP_ID"

    echo "curl --request DELETE \
    --header 'Authorization: Bearer '$MONGODBATLAS_BEARER_AUTH \
    https://realm.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps/${MONGODBATLAS_APP_ID}"
    curl --request DELETE \
    --header 'Authorization: Bearer '$MONGODBATLAS_BEARER_AUTH \
    https://realm.mongodb.com/api/admin/v3.0/groups/${MONGODBATLAS_PROJECT_ID}/apps/${MONGODBATLAS_APP_ID}
}

function login_realm_api() {

    echo "Logging in Realm API via Rest"
    echo "${MONGODBATLAS_PUBLIC_KEY}     ${MONGODBATLAS_PRIVATE_KEY} "

    MONGODBATLAS_BEARER_AUTH=$(curl --request POST \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --data '{"username": "'"${MONGODBATLAS_PUBLIC_KEY}"'", "apiKey": "'"${MONGODBATLAS_PRIVATE_KEY}"'"}' \
        https://realm.mongodb.com/api/admin/v3.0/auth/providers/mongodb-cloud/login | jq '.access_token' -r)

}

function install_realm_cli() {
    sudo apt install npm -y
    sudo npm install -g mongodb-realm-cli -y
}

