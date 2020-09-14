#!/bin/bash

set -e
set -o pipefail

STACK_FILE="$1"
DOCKER_USERNAME="$2"
DOCKER_PASSWORD="$3"
PLATFORMS="$4"
TAG_ALIAS="$5"
DEPLOY="$6"
GATEWAY="$7"
OPENFAAS_USERNAME="$8"
OPENFAAS_PASSWORD="$9"

# Trigger the shrinkwrap
BUILDING_MESSAGES_STRING=$(faas-cli build -f $STACK_FILE --shrinkwrap --tag sha | grep 'Building:')
SHRINKWRAP_MESSAGES_STRING=$(faas-cli build -f $STACK_FILE --shrinkwrap --tag sha | grep 'shrink-wrapped')

mapfile -t SHRINKWRAP_MESSAGES <<< "$SHRINKWRAP_MESSAGES_STRING"
mapfile -t BUILDING_MESSAGES <<< "$BUILDING_MESSAGES_STRING"

for i in "${!BUILDING_MESSAGES[@]}"; do
    SHRINKWRAP_MESSAGE=${SHRINKWRAP_MESSAGES[i]}
    BUILDING_MESSAGE=${BUILDING_MESSAGES[i]}

# Parse messages
    IMAGE_FULL=$(echo $BUILDING_MESSAGE | cut -d' ' -f2)
    TAG=$(echo $IMAGE_FULL | rev | cut -f1 -d":" | rev) # part after last colon
    WITHOUT_TAG=$(echo $IMAGE_FULL | sed "s/:$TAG//")
    IMAGE=$(echo $WITHOUT_TAG | rev | cut -f1 -d"/" | rev) # part after last slash
    WITHOUT_IMAGE=$(echo $WITHOUT_TAG | sed "s/\/$IMAGE//")
    ORG=$(echo $WITHOUT_IMAGE| rev | cut -f1 -d"/" | rev) # part after last slash

    SLASH_COUNT=$(tr -dc '/' <<<"$IMAGE_FULL" | awk '{ print length; }')
    if [ $SLASH_COUNT -gt 1 ]; then
        REGISTRY=$(echo $WITHOUT_IMAGE | sed "s/\/$ORG//")
    else
        REGISTRY=''
    fi
    
# Get mapping to functions and directories
    FUNCTION=$(echo $SHRINKWRAP_MESSAGE | cut -d' ' -f1)
    FOLDER=$(echo $SHRINKWRAP_MESSAGE | cut -d' ' -f4)
    
    # For debugging purposes
    echo IMAGE_FULL=$IMAGE_FULL
    echo REGISTRY=$REGISTRY
    echo ORG=$ORG
    echo IMAGE=$IMAGE
    echo TAG=$TAG
    echo TAG_ALIAS=$TAG_ALIAS
    echo FUNCTION=$FUNCTION
    echo FOLDER=$FOLDER

# Authenticate
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin $REGISTRY

# Build and push docker image
    cd "${FOLDER}"
    export DOCKER_CLI_EXPERIMENTAL=enabled
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker buildx create --use
    docker buildx install
    if [ ! -z $TAG_ALIAS ]; then
        ALIAS="${WITHOUT_TAG}:${TAG_ALIAS}"
        docker build --platform $PLATFORMS -t $IMAGE_FULL -t $ALIAS --push .
    else
        docker build --platform $PLATFORMS -t $IMAGE_FULL --push .
    fi
    cd -
done

# TAG is the same across all function builds
echo ::set-output name=tag::$TAG

# Deploy function stack if requested
if [ $DEPLOY = 'true' ]; then
    echo "Deploying function stack"
    if [ -z $GATEWAY ]; then
        echo $OPENFAAS_PASSWORD | faas-cli login -u $OPENFAAS_USERNAME --password-stdin
        faas-cli deploy -f STACK_FILE --image $IMAGE_FULL --tag sha
    else
        echo $OPENFAAS_PASSWORD | faas-cli login -u $OPENFAAS_USERNAME --password-stdin -g $GATEWAY
        faas-cli deploy -f STACK_FILE --image $IMAGE_FULL --tag sha -g $GATEWAY
    fi
fi
