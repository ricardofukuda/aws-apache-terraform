variable "region" {
  default = "us-east-1"
  type = string
  description = "aws region for deploy"
}

variable "project_name" {
  default = "my-website"
  type = string
}

variable "dns_record_domain_name" {
  default = "mywebsite2.info"
  type = string
}
