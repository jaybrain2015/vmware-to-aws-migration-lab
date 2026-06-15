# VMware to AWS Migration Lab

This project simulates migrating a VMware-hosted workload to AWS using Terraform.

## Source Environment

- VMware Workstation
- Ubuntu VM
- Nginx web server
- MySQL database

## AWS Target Environment

Provisioned with Terraform:

- VPC
- Public subnet
- Internet Gateway
- Route table
- Security group
- IAM role
- S3 bucket
- EC2 instance
- CloudWatch alarm

## Migration Flow

1. Application runs on VMware VM.
2. VMware snapshot is taken as rollback point.
3. Website files are packaged using `tar`.
4. MySQL database is exported using `mysqldump`.
5. Artifacts are uploaded to S3.
6. AWS infrastructure is provisioned with Terraform.
7. Application and database are restored on EC2.
8. Migration is validated through browser and database query.

## Key Lessons

- VMware snapshots provide rollback before risky changes.
- S3 can be used as a migration artifact store.
- IAM roles are safer than storing AWS keys on servers.
- Terraform enables repeatable infrastructure provisioning.
- EC2 public IPs change when instances are recreated unless DNS or Elastic IP is used.
