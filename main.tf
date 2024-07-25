provider "aws" {
  region = "us-east-1"
}

variable "env_prefix" {}
variable "avail_zone" {}

# create VPC
resource "aws_vpc" "main" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env_prefix}_vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 1
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.avail_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_prefix}_public_subnet-1"
  }
}



# resource "aws_instance" "this" {
#     ami_id = "ami-0b72821e2f351e396"
#     tags = {
#         Name = "webserver-1"
#     }
# }