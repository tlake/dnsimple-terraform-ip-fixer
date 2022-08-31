#!/usr/bin/env bash

if [[ -z ${TFC_TOKEN} ]] ; then
    echo "TFC_TOKEN env var must be set!"
    exit 1
fi

if [[ -z ${TFC_WORKSPACE_ID} ]] ; then
    echo "TFC_WORKSPACE_ID env var must be set!"
    exit 1
fi

IP_URL="https://ipv4.icanhazip.com"
TFC_URL="https://app.terraform.io/api/v2"
TFC_WORKSPACE_URL="${TFC_URL}/workspaces/${TFC_WORKSPACE_ID}"

TFC_VARIABLES=$(curl -s -H "Authorization: Bearer ${TFC_TOKEN}" -X GET "${TFC_WORKSPACE_URL}/vars" | jq -r '.data[] | {"id" : .id, "key" : .attributes["key"], "value" : .attributes["value"]}')

HOME_IP_VARIABLE=$(echo ${TFC_VARIABLES} | jq -r 'select(.key=="home_ip_address")')

CURRENT_IP=$(curl -s "${IP_URL}")
TERRAFORM_IP=$(echo ${HOME_IP_VARIABLE} | jq -r '.value')

echo "CURRENT_IP: ${CURRENT_IP}"
echo "TERRAFORM_IP: ${TERRAFORM_IP}"

if [[ ${CURRENT_IP} == ${TERRAFORM_IP} ]] ; then
    echo "IPs match! Nothing to do."
else
    echo "IPs don't match!"
    echo "Updating variable in Terraform..."

    IP_VAR_ID=$(echo ${HOME_IP_VARIABLE} | jq -r '.id')

    echo "TFC response status code: $(curl \
        -o /dev/null -w "%{http_code}" -s -X PATCH \
        -H "Authorization: Bearer ${TFC_TOKEN}" \
        -H "content-type: application/vnd.api+json" \
        "${TFC_WORKSPACE_URL}/vars/${IP_VAR_ID}" \
        --data "{\"data\": {\"type\": \"vars\", \"id\": \"${IP_VAR_ID}\",\"attributes\": {\"value\": \"${CURRENT_IP}\"}}}")"

    echo "Applying update..."

    echo "TFC response status code: $(curl \
        -o /dev/null -w "%{http_code}" -s -X POST \
        -H "Authorization: Bearer ${TFC_TOKEN}" \
        -H "Content-Type: application/vnd.api+json" \
        --data "{\"data\": {\"attributes\": {\"auto-apply\": \"true\", \"message\": \"Automated home_ip_address update `date`\"}, \"type\": \"runs\", \"relationships\": {\"workspace\": {\"data\": {\"type\": \"workspaces\", \"id\": \"${TFC_WORKSPACE_ID}\"}}}}}" \
        "${TFC_URL}/runs")"

    echo "Finished!"
fi

