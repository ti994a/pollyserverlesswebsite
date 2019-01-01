#!/bin/bash
. ./config.conf
# Empty all buckets
aws s3 rm s3://$SITEBUCKET --recursive
aws s3 rm s3://$AUDIOBUCKET --recursive
aws s3 rm s3://$CODEBUCKET --recursive
# Tear down stack
aws cloudformation delete-stack --stack-name $STACKNAME




