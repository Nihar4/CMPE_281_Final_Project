#!/bin/bash
# AWS Credentials Setup Script
# Run this to configure AWS credentials

export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=us-west-1

echo "✅ AWS credentials configured for region: us-west-1"
echo "Account ID: 799416476754"
echo ""
echo "To use these credentials, run:"
echo "  source .aws_credentials_setup.sh"
