terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.64"
    }
  }
  
  backend "s3" {
    bucket = "fukuda-aws-apache-terraform"
    region = "us-east-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

module "vpc"{
  source = "./modules/vpc"
}

module "ec2" {
  source = "./modules/ec2"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  sg_alb_id = module.elb.sg_alb_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  alb_target_group_arn = module.elb.alb_target_group_arn
  vpc_private_subnets_id = module.vpc.vpc_private_subnets_id
}

module "elb"{
  source = "./modules/elb"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  vpc_public_subnets_id = module.vpc.vpc_public_subnets_id 
}

module "s3"{
  source = "./modules/s3"
  project_name = var.project_name
  cf_origin_access_identity_iam_arn = module.cloudfront.cf_origin_access_identity_iam_arn
}

module "cloudfront"{
  source = "./modules/cloudfront"
  project_name = var.project_name
  s3_bucket_dns = module.s3.s3_bucket_dns
  alb_public_dns = module.elb.dns_name
}

module "route53"{
  source = "./modules/route53"
  dns_record_domain_name = var.dns_record_domain_name
  cf_distribution_domain_name = module.cloudfront.domain_name
  cf_distribution_hosted_zone_id = module.cloudfront.hosted_zone_id
}
