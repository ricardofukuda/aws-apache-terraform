variable "project_name"{
  type = string
  default = ""
}

variable "cidr_block"{
  type = string
  description = "VPC cidr"
  default = "12.0.0.0/16"
}

variable "private_subnets" {
  type = map
  description = "private_subnets"
  default = {
    "us-east-1a" = "12.0.11.0/24"
    "us-east-1b" = "12.0.12.0/24"
  }
}

variable "public_subnets" {
  type = map
  description = "public_subnets"
  default = {
    "us-east-1a" = "12.0.21.0/24"
    "us-east-1b" = "12.0.22.0/24"
  }
}