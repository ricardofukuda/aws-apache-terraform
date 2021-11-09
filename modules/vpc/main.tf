
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
	enable_dns_hostnames = true
	enable_dns_support = true
  tags = {
    Name = "vpc-${var.project_name}-${terraform.workspace}"
		Environment = terraform.workspace
  }
}

# Create private and public subnets
resource "aws_subnet" "vpc_subnet_private"{
  vpc_id = aws_vpc.vpc.id
	for_each = var.private_subnets
  cidr_block = each.value
	availability_zone = each.key
  map_public_ip_on_launch = false
  tags = {
    Name = "vpc-${var.project_name}-${each.key}-private-${terraform.workspace}"
		Environment = terraform.workspace
  }
}

resource "aws_subnet" "vpc_subnet_public"{
  vpc_id = aws_vpc.vpc.id
	for_each = var.public_subnets
  cidr_block = each.value
	availability_zone = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "vpc-${var.project_name}-${each.key}-public-${terraform.workspace}"
		Environment = terraform.workspace
  }
}

## Capture VPC default route table
resource "aws_default_route_table" "vpc_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route = []

  tags = {
    Name = "rt-${var.project_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Create private and public route tables for subnets
resource "aws_route_table" "subnet_route_table_private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rt-${var.project_name}-private-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_route_table" "subnet_route_table_public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rt-${var.project_name}-public-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

## Assign a distinct route table for each subnet private vs public 
resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.vpc_subnet_private[each.key].id
  route_table_id = aws_route_table.subnet_route_table_private.id
  for_each = var.private_subnets
}

resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.vpc_subnet_public[each.key].id
  route_table_id = aws_route_table.subnet_route_table_public.id
  for_each = var.public_subnets
}

# NatGateway for private subnets
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip_natgw.id
  connectivity_type = "public" # to access internet
  subnet_id = aws_subnet.vpc_subnet_public[element(keys(var.private_subnets), 0)].id

  tags = {
    Name = "natgw-${var.project_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
resource "aws_eip" "eip_natgw" {
  vpc = true
  tags = {
    Name = "eip-natgw-${var.project_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

## NatGateway route for private subnets
resource "aws_route" "natgw_route" {
  route_table_id         = aws_route_table.subnet_route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
  #gateway_id             = aws_internet_gateway.igw.id
}

# InternetGateway route for public subnets
resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.subnet_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.project_name}-${terraform.workspace}"
		Environment = terraform.workspace
  }
}

