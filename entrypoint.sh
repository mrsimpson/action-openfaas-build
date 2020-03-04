#!/bin/bash

set -e
set -o pipefail

# $1 stack-file
# $2 docker-username
# $3 docker-password
# $4 platforms
# $5 deploy
# $6 gateway
# $7 openfaas-username
# $8 openfaas-password

# Trigger the shrinkwrap
BUILDING_MESSAGES_STRING=$(faas-cli build -f $1 --shrinkwrap --tag sha | grep 'Building:')
SHRINKWRAP_MESSAGES_STRING=$(faas-cli build -f $1 --shrinkwrap --tag sha | grep 'shrink-wrapped')

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
    echo FUNCTION=$FUNCTION
    echo FOLDER=$FOLDER

# Authenticate
    echo $3 | docker login -u $2 --password-stdin $REGISTRY

# Build and push docker image
    cd "${FOLDER}"
    export DOCKER_CLI_EXPERIMENTAL=enabled
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker buildx create --use
    docker buildx install
    docker build --platform $4 -t $IMAGE_FULL --push .
    cd -
done

# TAG is the same across all function builds
echo ::set-output name=tag::$TAG

# Deploy function stack if requested
if [ -z $5 ]; then
echo "Deploying function stack"
    echo $8 | faas-cli login -u $7 --password-stdin -g $6
    faas-cli deploy -f $1 -g $6
fi
