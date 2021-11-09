variable "project_name"{
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "vpc_public_subnets_id" {
  type = list(string)
  default = []
}
