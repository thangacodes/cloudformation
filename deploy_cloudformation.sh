#!/bin/bash

# http://blog.kablamo.org/2015/11/08/bash-tricks-eux/
set -euxo pipefail
cd "$(dirname "$0")/.."

# shellcheck disable=SC1091
. "scripts/stack_name_vars.sh"

# export HTTP_PROXY="${ProxyUrl}"
# export HTTPS_PROXY="${ProxyUrl}"
# export http_proxy="${ProxyUrl}"
# export https_proxy="${ProxyUrl}"

NONPRIV_ROLE_NAME="infra-cfnrole-${PROJECT_ID}-nonprivileged"

# PRIV_ROLE_NAME='infra-cfnrole-sophia-privileged'
PARAMS_FILE="cloudformation/params/${ENVIRONMENT}/${AWS_DEFAULT_REGION}.yml"

set +x
VAULT_TOKEN=$(vault login -token-only -method=aws header_value=active.vault.service.consul.a-sharedinfra.net "role=jenkins-${PROJECT_ID}-${ENVIRONMENT}")
export VAULT_TOKEN
SECRETS=$(vault kv get -format=json "kv2/prj/${ENVIRONMENT}/${PROJECT_ID}/default")
CFN_DB_USERNAME=$(echo "$SECRETS" | jq -r .data.data.attendize_db_user)
CFN_DB_PASSWORD=$(echo "$SECRETS" | jq -r .data.data.attendize_db_password)
CFN_APP_KEY=$(echo "$SECRETS" | jq -r .data.data.attendize_app_key)
CFN_GOOGLE_API_KEY=$(echo "$SECRETS" | jq -r .data.data.attendize_google_api_key)
CFN_MAIL_USERNAME=$(echo "$SECRETS" | jq -r .data.data.attendize_mail_username)
CFN_MAIL_PASSWORD=$(echo "$SECRETS" | jq -r .data.data.attendize_mail_password)
CFN_SES_KEY=$(echo "$SECRETS" | jq -r .data.data.attendize_ses_key)
CFN_SES_SECRET=$(echo "$SECRETS" | jq -r .data.data.attendize_ses_secret)

export CFN_DB_USERNAME
export CFN_DB_PASSWORD
export CFN_APP_KEY
export CFN_GOOGLE_API_KEY
export CFN_MAIL_USERNAME
export CFN_MAIL_PASSWORD
export CFN_SES_KEY
export CFN_SES_SECRET
set -x

cfn_manage deploy-stack \
  --stack-name "$CFN_SG_STACK" \
  --template-file 'cloudformation/templates/sg.yml' \
  --parameters-file "$PARAMS_FILE" \
  --role-name "$NONPRIV_ROLE_NAME"

cfn_manage deploy-stack \
  --stack-name "$CFN_DB_STACK" \
  --template-file 'cloudformation/templates/db.yml' \
  --parameters-file "$PARAMS_FILE" \
  --role-name "$NONPRIV_ROLE_NAME"

cfn_manage deploy-stack \
  --stack-name "$CFN_REDIS_STACK" \
  --template-file 'cloudformation/templates/redis.yml' \
  --parameters-file "$PARAMS_FILE" \
  --role-name "$NONPRIV_ROLE_NAME"

cfn_manage deploy-stack \
  --stack-name "$CFN_ECS_STACK" \
  --template-file 'cloudformation/templates/ecs-cluster.yml' \
  --parameters-file "$PARAMS_FILE" \
  --role-name "$NONPRIV_ROLE_NAME"


















