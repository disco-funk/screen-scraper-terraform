# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

# Instance tags
output "instance_tags" {
  description = "A list of the screen-scrape-ec2 instances"
  value       = aws_instance.screen-scrape-ec2.*.tags.Name
}

# Instance ids
output "instance_ids" {
  value = aws_instance.screen-scrape-ec2.*.id
}


# Outputs for terratest
output "region" {
  value = var.region
}

output "expected_vpc_cidr" {
  value = var.vpc_cidr
}
