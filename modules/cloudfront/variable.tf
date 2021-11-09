variable "project_name"{
  type = string
  default = ""
}

variable "s3_bucket_dns"{
  type = string
  default = ""
}

variable "alb_public_dns"{
  type = string
  default = ""
}

variable "cf_price_class"{
  type = string
  default = "PriceClass_100"
}