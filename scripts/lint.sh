#!/usr/bin/env bash

set -eo pipefail 

if [ -f /.dockerenv ]; then
  hadolint Dockerfile
else
  docker run -v $(pwd):/host:ro hadolint/hadolint:v1.17.2-debian hadolint /host/Dockerfile
fi
