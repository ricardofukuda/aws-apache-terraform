output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_private_subnets_id" {
  value = values(aws_subnet.vpc_subnet_private)[*].id
}

output "vpc_public_subnets_id" {
  value = values(aws_subnet.vpc_subnet_public)[*].id
}