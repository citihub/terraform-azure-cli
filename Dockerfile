# Setup build arguments with default versions
ARG AZURE_CLI_VERSION=2.25.0
ARG DATABRICKS_CLI_VERSION=0.14.3
ARG TERRAFORM_VERSION=1.0.1
ARG PYTHON_MAJOR_VERSION=3.7
ARG DEBIAN_VERSION=buster-20201012-slim

# Download Terraform binary
FROM debian:${DEBIAN_VERSION} as terraform-cli
ARG TERRAFORM_VERSION
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates=20200601~deb10u2
RUN apt-get install -y --no-install-recommends curl=7.64.0-4+deb10u2
RUN apt-get install -y --no-install-recommends unzip=6.0-23+deb10u2
RUN apt-get install -y --no-install-recommends gnupg=2.2.12-1+deb10u1
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
COPY hashicorp.asc hashicorp.asc
COPY gitlab-terraform.sh gitlab-terraform
RUN chmod +x gitlab-terraform
RUN gpg --import hashicorp.asc
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN grep terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c -
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Download Terraform providers
FROM debian:${DEBIAN_VERSION} as providers-cli
COPY --from=terraform-cli /terraform /usr/local/bin/terraform
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates=20200601~deb10u2
COPY providers.tf providers.tf
RUN terraform providers mirror /tfproviders

# Install az CLI using PIP
FROM debian:${DEBIAN_VERSION} as azure-cli
ARG AZURE_CLI_VERSION
ARG PYTHON_MAJOR_VERSION
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3=${PYTHON_MAJOR_VERSION}.3-1
RUN apt-get install -y --no-install-recommends python3-pip=18.1-5
RUN apt-get install -y --no-install-recommends gcc=4:8.3.0-1
RUN apt-get install -y --no-install-recommends python3-dev=${PYTHON_MAJOR_VERSION}.3-1
RUN pip3 install --upgrade pip==21.1.3
RUN pip3 install setuptools==50.3.2
RUN pip3 install wheel==0.35.1
RUN pip3 install azure-cli==${AZURE_CLI_VERSION}

# Install databrics CLI using PIP
FROM debian:${DEBIAN_VERSION} as databricks-cli
ARG DATABRICKS_CLI_VERSION
ARG PYTHON_MAJOR_VERSION
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3=${PYTHON_MAJOR_VERSION}.3-1
RUN apt-get install -y --no-install-recommends python3-pip=18.1-5
RUN apt-get install -y --no-install-recommends gcc=4:8.3.0-1
RUN apt-get install -y --no-install-recommends python3-dev=${PYTHON_MAJOR_VERSION}.3-1
RUN pip3 install setuptools==50.3.2
RUN pip3 install wheel==0.35.1
RUN pip3 install databricks-cli==${DATABRICKS_CLI_VERSION}

# Build final image
FROM debian:${DEBIAN_VERSION}
LABEL maintainer="support@citihub.com"
ARG PYTHON_MAJOR_VERSION
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u2 \
    sudo=1.8.27-1+deb10u3 \
    git=1:2.20.1-2+deb10u3 \
    wget=1.20.1-1.1 \
    jq=1.5+dfsg-2+b1 \
    python3=${PYTHON_MAJOR_VERSION}.3-1 \
    python3-distutils=${PYTHON_MAJOR_VERSION}.3-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_MAJOR_VERSION} 1 \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY --from=terraform-cli /terraform /usr/local/bin/terraform
COPY --from=terraform-cli /gitlab-terraform /usr/local/bin/gitlab-terraform
COPY --from=providers-cli /tfproviders /tfproviders
COPY --from=azure-cli /usr/local/bin/az* /usr/local/bin/
COPY --from=azure-cli /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages
COPY --from=azure-cli /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages
COPY --from=databricks-cli /usr/local/bin/databricks* /usr/local/bin/
COPY --from=databricks-cli /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages
COPY --from=databricks-cli /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages

WORKDIR /workspace
COPY .terraformrc .terraformrc
RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store azure credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && adduser nonroot sudo \
  && chown nonroot:nonroot /workspace \
  && chmod 777 /workspace \
  && mkdir /.azure \
  && chmod 777 /.azure
USER nonroot

CMD ["bash"]
