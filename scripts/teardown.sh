#!/bin/bash
set -e

cd ~/cloud-platform-migration-lab/terraform

echo "Destroying AWS infrastructure..."
terraform destroy -auto-approve

echo "Teardown complete."
