#!/usr/bin/env bash

set -eo pipefail

IMAGE_NAME="citihub/terraform-azure-cli:dev"

LATEST_NAME="citihub/terraform-azure-cli:latest"


# Lint Dockerfile
echo "Linting Dockerfile..."
docker run --rm -i hadolint/hadolint:v1.17.6-alpine < Dockerfile
echo "Lint Successful!"

# Build dev image
if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
  echo "Building release image with ${TAG}..."
  TAG="release-1.1_azcli-${1}_terraform-${2}_databricks-${3}"
  IMAGE_NAME="citihub/terraform-azure-cli:${TAG}"
  echo "Building release image ${IMAGE_NAME}..."
  docker image build --build-arg AZURE_CLI_VERSION="$1" --build-arg TERRAFORM_VERSION="$2" --build-arg DATABRICKS_CLI_VERSION="$3" -t $IMAGE_NAME .
  docker push ${IMAGE_NAME}
  docker tag ${IMAGE_NAME} ${LATEST_NAME}
  docker push ${LATEST_NAME}
else
  echo "Building dev images with default parameters..."
  docker image build -f Dockerfile -t $IMAGE_NAME .
fi

# Test dev image
echo "Executing container structure test..."
docker container run --rm -it -v "${PWD}"/tests/container-structure-tests.yml:/tests.yml:ro -v /var/run/docker.sock:/var/run/docker.sock:ro gcr.io/gcp-runtimes/container-structure-test:v1.8.0 test --image $IMAGE_NAME --config /tests.yml
