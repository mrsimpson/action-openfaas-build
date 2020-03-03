#!/bin/bash

# $1 stack-file
# $2 docker-username
# $3 docker-password
# $4 platforms

# Trigger the shrinkwrap
BUILDING_MESSAGES_STRING=$(faas-cli build -f $1 --shrinkwrap --tag sha | grep 'Building:')
SHRINKWRAP_MESSAGES_STRING=$(faas-cli build -f $1 --shrinkwrap --tag sha | grep 'shrink-wrapped')

mapfile -t SHRINKWRAP_MESSAGES <<< "$SHRINKWRAP_MESSAGES_STRING"
mapfile -t BUILDING_MESSAGES <<< "$BUILDING_MESSAGES_STRING"

INDEX=0
for BUILDING_MESSAGE in "${BUILDING_MESSAGES[@]}"; do
    # Determine the components of the image by parsing the building message
    IMAGE_FULL=$(echo $BUILDING_MESSAGE | cut -d' ' -f2)

    SLASH_COUNT=$(tr -dc '/' <<<"$IMAGE_FULL" | awk '{ print length; }')

    TAG=$(echo $IMAGE_FULL | rev | cut -f1 -d":" | rev) # part after last colon
    WITHOUT_TAG=$(echo $IMAGE_FULL | sed "s/:$TAG//")
    IMAGE=$(echo $WITHOUT_TAG | rev | cut -f1 -d"/" | rev) # part after last slash
    WITHOUT_IMAGE=$(echo $WITHOUT_TAG | sed "s/\/$IMAGE//")
    ORG=$(echo $WITHOUT_IMAGE| rev | cut -f1 -d"/" | rev) # part after last slash

    if [ $SLASH_COUNT -gt 1 ]; then
        REGISTRY=$(echo $WITHOUT_IMAGE | sed "s/\/$ORG//")
    else
        REGISTRY=''
    fi
    
    # Get mapping to functions and directories
    SHRINKWRAP_MESSAGE=${SHRINKWRAP_MESSAGES[INDEX]}
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

    # Build and push
    cd "${FOLDER}"
    DOCKER_BUILDKIT=1 docker build --platform $4 -t $IMAGE_FULL .
    docker push $IMAGE_FULL
    cd -

    ((INDEX++))
done

# TAG is the same across all function builds
echo ::set-output name=tag::$TAG