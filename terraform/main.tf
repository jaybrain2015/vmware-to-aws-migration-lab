provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_vpc" "migration_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "migration-demo-vpc"
    Project = "vmware-to-aws-migration"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.migration_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "migration-demo-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.migration_vpc.id

  tags = {
    Name = "migration-demo-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.migration_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "migration-demo-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "migration-demo-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.migration_vpc.id

  ingress {
    description = "SSH from my IP or open for lab"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "migration-demo-web-sg"
  }
}

resource "aws_s3_bucket" "migration_bucket" {
  bucket        = "vmware-migration-artifacts-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "migration-artifact-bucket"
    Project = "vmware-to-aws-migration"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "migration-demo-ec2-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name = "migration-demo-s3-read-policy-${random_id.suffix.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.migration_bucket.arn,
          "${aws_s3_bucket.migration_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "migration-demo-ec2-profile-${random_id.suffix.hex}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "migration_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = "migration-lab-key"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name    = "aws-migrated-app-server"
    Project = "vmware-to-aws-migration"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "migration-demo-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when EC2 CPU exceeds 70 percent"

  dimensions = {
    InstanceId = aws_instance.migration_server.id
  }
}