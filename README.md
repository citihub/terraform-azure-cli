[![lint-build-test](https://github.com/citihub/terraform-azure-cli/workflows/lint-build-test/badge.svg)](https://github.com/citihub/terraform-azure-cli/actions?query=workflow%3Alint-build-test)
[![push-latest](https://github.com/citihub/terraform-azure-cli/workflows/push-latest/badge.svg)](https://github.com/citihub/terraform-azure-cli/actions?query=workflow%3Apush-latest)
[![release](https://github.com/citihub/terraform-azure-cli/workflows/release/badge.svg)](https://github.com/citihub/terraform-azure-cli/actions?query=workflow%3Arelease)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/citihub/terraform-azure-cli.svg)](https://hub.docker.com/r/citihub/terraform-azure-cli/)

<p align="center">
  <a href="https://azure.microsoft.com"><img width="200" src="https://github.com/citihub/terraform-azure-cli/raw/master/resources/azure-logo.png"></a>
  <a href="https://www.terraform.io/"><img width="200" src="https://github.com/citihub/terraform-azure-cli/raw/master/resources/terraform-logo.png"></a>
  <a href="https://www.databricks.com/"><img width="200" src="https://github.com/citihub/terraform-azure-cli/raw/master/resources/databricks-logo.png"></a>
</p>

# Terraform, Azure CLI and Databricks CLI Docker image
This repo is a fork from [Zenika/terraform-azure-cli](https://github.com/zenika/terraform-azure-cli) with Databricks CLI, jq and wget added to the image.

## 📦 Supported tags and respective Dockerfile links
Available image tags can be found on the Docker Hub registry: [citihub/terraform-azure-cli](https://hub.docker.com/r/citihub/terraform-azure-cli/tags)

The following image tag strategy is applied:
* `citihub/terraform-azure-cli:latest` - build from master
  * Included CLI versions can be found in the [Dockerfile](https://github.com/citihub/terraform-azure-cli/blob/master/Dockerfile)
* `citihub/terraform-azure-cli:release-S.T_terraform-UU.VV.WW_azcli-XX.YY.ZZ_databricks-AA.BB.CC` - build from releases
  * `release-S.T` is the release tag
  * `terraform-UU.VV.WWW` is the included Terraform CLI version
  * `azcli-XX.YY.ZZ` is the included Azure CLI version
  * `databricks-AA.BB.ZZ` is the included Databricks CLI version

Please report to the [releases page](https://github.com/citihub/terraform-azure-cli/releases) for the changelogs. Any other tags are not supported.

## Gitlab Terraform

The docker image contains the `gitlab-terraform` shell script. This script is a thin wrapper around the terraform binary. Its main purpose is to serve the Infrastructure as code with Terraform and GitLab
, by extracting some of the standard configuration a user would need to set up to use the Terraform backend on GitLab as well as the Terraform merge request widget.

### How to use it
The wrapper expects three environment variables to be set:

TF_ADDRESS

Should be the backend url. For the GitLab backend it will be something like,
"{GITLAB_API_URL}/projects/{PROJECT_ID}/terraform/state/{STATE_NAME}"

- {GITLAB_API_URL} is the URL of your GitLab API.

- {PROJECT_ID} is the id of the project you're using as your infrastructure as code.

- {STATE_NAME} can be arbitrarily defined to the Terraform state name one wants to create.

TF_USERNAME

Is your user login name, which must have maintainer access. If this is unset, it will default to the value of GITLAB_USER_LOGIN which is the username that triggered the build.

TF_PASSWORD

An access token created for the above maintainer with the api scope. If this is unset, it will default to the value of CI_JOB_TOKEN and override the TF_USERNAME to match.


### Optional environment variables

TF_CACERTS

A directory with CA certificates to added to the docker image. The contents of the TF_CACERTS directory are copied to the `/usr/local/shared/ca-certificates` directory in the running container and `/usr/sbin/update-ca-certificates` is run to update the container CA certificates.

TF_HTTP_SKIP_CERT_VERIFY

Whether to skip TLS verification. Possible values are true or false. Defaults to false.

### HTTP backend
Terraform HTTP backend environment variables are also implemented - see [Terraform http backend](https://www.terraform.io/docs/language/settings/backends/http.html)

## 💡Motivation
The goal is to create a **minimalist** and **lightweight** image with these tools in order to reduce network and storage impact.

This image gives you the flexibility to be used for development or as a base image as you see fits.

## 🔧 What's inside ?
* [Azure CLI](https://docs.microsoft.com/cli/azure/?view=azure-cli-latest):
  * Included version indicated in the image tag: `azcli-XX.YY.ZZ`
  * Available versions on the [project release page](https://github.com/Azure/azure-cli/releases)
* [Terraform CLI](https://www.terraform.io/docs/commands/index.html):
  * Included version indicated in the image tag: `terraform-XX.YY.ZZ`
  * Available versions on the [project release page](https://github.com/hashicorp/terraform/releases)
* [Terraform Providers](https://www.terraform.io/docs/providers/index.html):
  * Terraform providers are nirrored under: `/tfproviders`
  * databricks v0.3.1 [terraform-provider-databricks](https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs)
  * azurerm v2.48.0 [terrform-provider-azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
  * random v3.1.0 [terraform-provider-random](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
  * null v3.1.0 [terraform-provider-null](https://registry.terraform.io/providers/hashicorp/null/latest/docs)
  * vault v2.15.0 [terraform-provider-vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
* [Databricks CLI](https://docs.databricks.com/dev-tools/cli/index.html)
  * Included version indicated in the image tag: `databricks-XX.YY.ZZ`
  * Available versions on the [project release page](https://github.com/databricks/databricks-cli)
* [Git](https://git-scm.com/)
  * Available versions on the [Debian Packages repository](https://packages.debian.org/search?suite=buster&arch=any&searchon=names&keywords=git)
* [Python 3](https://www.python.org/)
  * Available versions on the [Debian packages repository](https://packages.debian.org/search?suite=buster&arch=any&searchon=names&keywords=python3)
* This image use a non root user with a GID and UID of 1001

This image uses a non-root user with a UID and GID of 1001 to conform with docker security best practices.

## 🚀 Usage

### Launch the CLI
Simply launch the container and use the CLI as you would on any other platform, for instance using the latest image:

```bash
docker container run -it --rm --mount type=bind,source="$(pwd)",target=/workspace citihub/terraform-azure-cli:latest
```

> The `--rm` flag will completely destroy the container and its data on exit.

### Build the image
You can build the image locally directly from the Dockerfile, using the build script.

It will :
* Lint the Dockerfile with [Hadolint](https://github.com/hadolint/hadolint);
* Build and tag the image `citihub/terraform-azure-cli:dev`;
* Execute [container structure tests](https://github.com/GoogleContainerTools/container-structure-test) on the image.

```bash
# launch build script
./dev-build.sh
```

Optionally, it is possible to choose the tools desired versions using [Docker builds arguments](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg) :

```bash
# Set tools desired versions
AZURE_CLI_VERSION=2.19.1
TERRAFORM_VERSION=0.14.6
DATABRICKS_CLI_VERSION=0.14.6

# launch the build script with parameters
./dev-build.sh $AZURE_CLI_VERSION $TERRAFORM_VERSION $DATABRICKS_CLI_VERSION
```

## 🙏 Roadmap & Contributions
Please refer to the [github project](https://github.com/citihub/terraform-azure-cli/projects/1) to track new features.

Do not hesitate to contribute by [filling an issue](https://github.com/citihub/terraform-azure-cli/issues) or [opening a PR](https://github.com/citihub/terraform-azure-cli/pulls) !

## 📖 License
This project is under the [Apache License 2.0](https://raw.githubusercontent.com/citihub/terraform-azure-cli/master/LICENSE)

[![with love by citihub](https://img.shields.io/badge/With%20%E2%9D%A4%EF%B8%8F%20by-citihub-b51432.svg)](https://oss.citihub.com)
