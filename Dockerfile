FROM jonoh/docker-buildx-qemu:19.03.5_0.3.1

# Install buildx as default
RUN curl -sSL https://cli.openfaas.com | sh

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]