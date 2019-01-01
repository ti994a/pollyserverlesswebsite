#!/bin/bash
. ./config.conf
aws cloudformation deploy --template-file mainstack.yml --stack-name $STACKNAME --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name $STACKNAME
aws cloudformation --region us-east-1 describe-stacks --stack-name $STACKNAME
# Get ARN of PollyLambda
PollyLambdaARN=$(aws cloudformation --region us-east-1 describe-stacks --stack-name $STACKNAME --query 'Stacks[0].Outputs[0].OutputValue')
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
