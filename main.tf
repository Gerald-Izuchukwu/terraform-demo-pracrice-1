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

# create subnet
resource "aws_subnet" "public" {
  #   count                   = 1
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.avail_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_prefix}_public_subnet-1"
  }
}
# create igw for for vpc
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_prefix}_igw"
  }

}

# create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${var.env_prefix}_public_route_table"
  }
}

# associate route table to subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}



# resource "aws_instance" "this" {
#     ami_id = "ami-0b72821e2f351e396"
#     tags = {
#         Name = "webserver-1"
#     }
# }

# -------- below this is config for private subnet and 
# NAT-GW but NAT-GW isnt free

# resource "aws_subnet" "private" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = var.avail_zone

#   tags = {
#     Name = "${var.env_prefix}_private_subnet-1"
#   }
# }

# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.this.id
#   subnet_id     = aws_subnet.public.id
#   tags = {
#     Name = "${var.env_prefix}_nat_gw"
#   }
#   depends_on = [aws_internet_gateway.this]
# }

# resource "aws_eip" "this" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.env_prefix}_nat_eip"
#   }
# }

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.this.id
#   }
#   route {
#     cidr_block = "10.0.0.0/16"
#     gateway_id = "local"
#   }

#   tags = {
#     Name = "${var.env_prefix}_private_route_table"
#   }
# }

# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private_route_table.id
# }