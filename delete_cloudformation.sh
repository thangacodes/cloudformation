#!/bin/bash

# http://blog.kablamo.org/2015/11/08/bash-tricks-eux/
set -euxo pipefail
cd "$(dirname "$0")/.."

# shellcheck disable=SC1091
. "scripts/stack_name_vars.sh"
# Guard the stack from deletion unless branch is NOT master
if [[ -n "${STACK_SUFFIX-}" ]]; then
  cfn_manage delete-stack --stack-name "$CFN_GUILD_S3_STACK"
fi

