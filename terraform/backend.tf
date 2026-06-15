terraform {
  backend "s3" {
    bucket         = "terraform-state-vmware-migration-0fce790f"
    key            = "cloud-platform-migration-lab/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
