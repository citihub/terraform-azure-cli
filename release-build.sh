#!/usr/bin/env bash

set -eo pipefail

AZURE_CLI_VERSION="2.25.0"
TERRAFORM_VERSION="1.0.1"
DATABRICKS_CLI_VERSION="0.14.3"

./dev-build.sh ${AZURE_CLI_VERSION} ${TERRAFORM_VERSION} ${DATABRICKS_CLI_VERSION}
