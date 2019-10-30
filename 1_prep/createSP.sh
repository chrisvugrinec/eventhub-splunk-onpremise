#!/bin/bash

APP_NAME="http://eh-splunk-demo"

subscription=$(az account show | jq -r .id)
sp=$(az ad sp create-for-rbac -n $APP_NAME --role="Contributor" --scopes="/subscriptions/$subscription")

appId=$(echo $sp | jq -r .appId)
password=$(echo $sp | jq -r .password)
tenant=$(echo $sp | jq -r .tenant)

objectId=$(az ad sp show --id $appId --query objectId -o tsv)

echo "now copy paste this before creating infra"
echo "export TF_VAR_CLIENT_ID="$appId
echo "export TF_VAR_CLIENT_SECRET="$password
echo "export TF_VAR_TENANT_ID="$tenant
echo "export TF_VAR_OBJECT_USER_ID="$objectId
echo "export TF_VAR_SUBSCRIPTION_ID="$subscription

