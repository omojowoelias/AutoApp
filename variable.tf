variable "aws_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
  default     = "us-east-1"                                                     
  
}

variable "ax" {
  default = "us-east-1a"
}


# variable "ay" {
#   default = "us-east-1b"
# }


variable "az" {
  default = "us-east-1c"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "automobann"
  
}

variable "environment" {
  description = "The environment to deploy the resources in"
  type        = string
  default     = "dev"
}

# variable "aws_vpc" {
#     description = "The VPC ID"
#     type        = string 
# }