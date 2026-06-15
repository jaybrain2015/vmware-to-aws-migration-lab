variable "aws_region" {
  description = "AWS region for the migration lab"
  type        = string
  default     = "eu-north-1"
}

variable "availability_zone" {
  description = "Availability zone for public subnet"
  type        = string
  default     = "eu-north-1a"
}

variable "instance_type" {
  description = "Small EC2 instance for lab"
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into EC2"
  type        = string
  default     = "0.0.0.0/0"
}
