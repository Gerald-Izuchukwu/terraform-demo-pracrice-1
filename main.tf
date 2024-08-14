provider "aws" {
  region = "us-east-1"
}

variable "env_prefix" {}
variable "avail_zone" {}
variable "my_ip_address" {}
variable "public_key_path" {
  description = "Path to the ssh public key file"
  type        = string
}
variable "private_key_path" {}

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

resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.main.id


  # Allow inbound all traffic from any IP
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Allow inbound traffic from 10.0.0.0/24 on all ports
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.0.0/24"
    from_port  = 0
    to_port    = 65535
  }

  # Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.env_prefix}_nacl"
  }
}


resource "aws_network_acl_association" "this" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.main.id
  ingress { //for ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  ingress { // for internet traffic to enter the webserver
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { // for traffic to leave the intsnace regardless of protocol and ports
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}_sg"
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.env_prefix}_key_pair"
  public_key = file(var.public_key_path)
}


resource "aws_instance" "this" {
  count                       = 1
  ami                         = "ami-0b72821e2f351e396"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.this.key_name
  availability_zone           = var.avail_zone
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.this.id]
  user_data                   = file("entry_script.sh")
  tags = {
    Name = "webserver_1"
  }

  provisioner "file" {
    source      = "docker_pull_script.sh"
    destination = "/home/ec2-user/docker_pull_script.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "while ! systemctl is-active docker; do sleep 5; done", # Wait until Docker is active
      "chmod +x /home/ec2-user/docker_pull_script.sh",
      "/home/ec2-user/docker_pull_script.sh"
    ]
  }


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}





# -------- below this is config for private subnet and NAT-GW but NAT-GW isnt free

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