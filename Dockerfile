ARG BUILDX_VERSION=19.03.5_0.3.1
ARG FAAS_CLI_VERSION=0.11.8

FROM jonoh/docker-buildx-qemu:${BUILDX_VERSION}

# Download FaaS CLI
RUN curl -sLSf -o faas-cli.sig https://github.com/openfaas/faas-cli/releases/download/${FAAS_CLI_VERSION}/faas-cli && \
    curl -sLSf -o faas-cli.sig https://github.com/openfaas/faas-cli/releases/download/${FAAS_CLI_VERSION}/faas-cli.sha256 && \
    shasum -a 256 faas-cli -c faas-cli.sig && \
    mv faas-cli /usr/local/bin

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]