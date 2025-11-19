#!/bin/bash
# Usage: ./scripts/deploy-frontend.sh
# Builds React frontend, syncs to S3, and invalidates CloudFront cache.

set -e

CLOUDFRONT_DIST_ID="E2QFNIEVREFPBC"
S3_BUCKET="coursebundler-final-frontend-6eb9f2aa"

cd "$(dirname "$0")/../frontend"

echo "Building React app..."
npm run build

echo "Syncing build to S3..."
aws s3 sync build/ "s3://$S3_BUCKET" --delete

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DIST_ID" --paths "/*"
