terraform {
  backend "s3" {
    bucket       = "terraform-state-vmware-migration-0fce790f"
    key          = "cloud-platform-migration-lab/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}