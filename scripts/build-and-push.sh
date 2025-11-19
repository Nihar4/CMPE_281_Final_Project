#!/bin/bash
# Usage: ./scripts/build-and-push.sh
# Builds backend Docker image, logs in to ECR, tags, and pushes image.

set -e

ECR_URL="799416476754.dkr.ecr.us-west-1.amazonaws.com/coursebundler-final-backend"
AWS_REGION="us-west-1"

cd "$(dirname "$0")/../backend"

echo "Building Docker image..."
docker buildx build --platform linux/amd64 -t coursebundler-final-backend:latest .

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"

echo "Tagging image..."
docker tag coursebundler-final-backend:latest "$ECR_URL:latest"

echo "Pushing image to ECR..."
docker push "$ECR_URL:latest"
