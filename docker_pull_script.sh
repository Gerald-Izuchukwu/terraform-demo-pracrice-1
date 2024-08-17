#!/bin/bash

export AWS_REGION='us-east-1'
export REPOSITORY_NAME='cross_a'
export REPOSITORY_NAME2='cross_b'
export IMAGE_TAG='latest'
export REPOSITORY_ID='u0i6l9j2'

# Check if required environment variables are set
if [ -z "$AWS_REGION" ] || [ -z "$REPOSITORY_NAME" ] || [ -z "$REPOSITORY_NAME2" ] || [ -z "$IMAGE_TAG" ] || [ -z "$REPOSITORY_ID" ]; then
  echo "Error: Required environment variables (AWS_REGION, AWS_ACCOUNT_ID, REPOSITORY_NAME, IMAGE_TAG) are not set."
  exit 1
fi

# Pull the image from ECR
sudo docker pull public.ecr.aws/$REPOSITORY_ID/$REPOSITORY_NAME:$IMAGE_TAG
sudo docker pull public.ecr.aws/$REPOSITORY_ID/$REPOSITORY_NAME2:$IMAGE_TAG

# Optionally, tag the image with a local name
# docker tag public.ecr.aws/$REPOSITORY_ID/$REPOSITORY_NAME:$IMAGE_TAG $REPOSITORY_NAME:4

# Verify the pulled image
sudo docker images | grep $REPOSITORY_NAME

echo "Image pulled successfully!"

sudo docker tag public.ecr.aws/$REPOSITORY_ID/$REPOSITORY_NAME:$IMAGE_TAG $REPOSITORY_NAME:1
sudo docker tag public.ecr.aws/$REPOSITORY_ID/$REPOSITORY_NAME2:$IMAGE_TAG $REPOSITORY_NAME2:1

sudo docker network create mynetwork

sudo docker run -d -p 9661:9661 --network mynetwork --name crossa $REPOSITORY_NAME:1 #chnage the -ne to --net
sudo docker run -d -p 9660:9660 --network mynetwork --name crossb $REPOSITORY_NAME2:1

# sudo docker compose up -d

echo "Running image"
