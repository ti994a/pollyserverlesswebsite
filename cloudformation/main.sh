#!/bin/bash
aws cloudformation deploy --template-file mainstack.yml --stack-name polly-serverless-website --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name polly-serverless-website
aws cloudformation --region us-east-1 describe-stacks --stack-name polly-serverless-website
# Get ARN of PollyLambda
PollyLambdaARN=$(aws cloudformation --region us-east-1 describe-stacks --stack-name polly-serverless-website --query 'Stacks[0].Outputs[0].OutputValue')
# Use ARN of PollyLambda to create lambda notification off of pollyserverlesswebsite-code bucket object adds
# First create json bucket notification configuration file
cat > lambda_notification.json << EOF
{
    "LambdaFunctionConfigurations": [
      {
        "LambdaFunctionArn": $PollyLambdaARN,
        "Events": ["s3:ObjectCreated:*"]
      }
    ]
 }
EOF
# Then apply bucket notification configuration
aws s3api put-bucket-notification-configuration --bucket pollyserverlesswebsite-code --notification-configuration file://lambda_notification.json
