#!/bin/bash
set -e

cd ~/cloud-platform-migration-lab/terraform

echo "Initializing Terraform..."
terraform init

echo "Formatting Terraform..."
terraform fmt

echo "Validating Terraform..."
terraform validate

echo "Building AWS infrastructure..."
terraform apply -auto-approve

echo "AWS infrastructure created."
terraform output
