variable "project_name"{
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "vpc_cidr_block" {
  type = string
  default = ""
}

variable "sg_alb_id" {
  type = string
  default = ""
}

variable "ec2_keyname" {
  default = "ricardo"
  type = string
  description = "ec2 keyname for SSH"
}

variable "vpc_private_subnets_id" {
  type = list(string)
  default = []
}

variable "alb_target_group_arn" {
  type = string
  default = ""
}