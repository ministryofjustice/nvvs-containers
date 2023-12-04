FROM ubuntu:23.10

ARG PLATFORM=linux_amd64
ARG TFENV_VERSION=3.0.0
ARG TF_VERSIONS="0.12.31 0.13.7 0.15.5 1.1.0 1.1.3 1.1.6 1.1.7 1.1.8 1.1.9 1.2.9 1.5.4"
ARG TFLINT_VERSION=0.48.0
ARG TFLINT_AWS_RULESET_VERSION=0.22.1
ARG KUBECTL_VERSION=v1.22.0

LABEL org.opencontainers.image.description="Hashicorp Terraform and tflint" \
      org.opencontainers.image.authors="Ministry of Justice - NVVS DevOps" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/nvvs/terraform" \
      org.opencontainers.image.source="git@github.com:ministryofjustice/nvvs-containers.git" \
      org.opencontainers.image.licenses="MIT"

COPY .tflint.hcl.source /root/

# make tfenv callable during build
ENV PATH "/opt/.tfenv/bin:$PATH"
SHELL ["/bin/bash", "-c"]
RUN apt-get update \
  && apt-get install -y curl wget make gettext unzip git jq dateutils apache2-utils mysql-client \
  && git clone --single-branch https://github.com/tfutils/tfenv.git /opt/.tfenv \
  && wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_${PLATFORM}.zip \
  && wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt \
  && set -o pipefail && grep ${PLATFORM} checksums.txt | sha256sum -c - \
  && unzip tflint_${PLATFORM}.zip -d /usr/local/bin \
  && rm tflint_${PLATFORM}.zip checksums.txt \
  && envsubst < /root/.tflint.hcl.source > /root/.tflint.hcl \
  && tflint --init \
  && curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
  && chmod +x get_helm.sh \
  && ./get_helm.sh \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin \
  && rm awscliv2.zip \
  && for version in $TF_VERSIONS; do \
      tfenv install "$version"; \
      done;