output "ec2_public_ip" {
  value = aws_instance.migration_server.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.migration_bucket.bucket
}

output "vpc_id" {
  value = aws_vpc.migration_vpc.id
}