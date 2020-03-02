#!/bin/bash

# $1 stack-file
# $2 docker-username
# $3 docker-password
# $4 platforms

# Trigger the shrinkwrap
BUILDING_MESSAGE=$(faas-cli build -f $1 --shrinkwrap --tag sha | grep -i building | sed -n 2p)

# Determine the components of the image from the building message
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

# For debugging purposes
echo 1=$1
echo 2=$2
echo 3=$3
echo 4=$4


echo REGISTRY=$REGISTRY
echo ORG=$ORG
echo IMAGE=$IMAGE
echo TAG=$TAG

# Authenticate
echo $3 | docker login -u $2 --password-stdin $REGISTRY

# Build and push
docker buildx install

cd "build/$(ls build | sed -n p)"
docker build --platform $4 -t $IMAGE_FULL --push .

# Propagate determined variables to the outer workflow
echo ::set-output name=registry::$REGISTRY
echo ::set-output name=org::$ORG
echo ::set-output name=image::$IMAGE
echo ::set-output name=tag::$TAG
