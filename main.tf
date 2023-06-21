# Calling the required AWS cloud provider and what region to deploy in from the variables.tf file
terraform {
  required_providers {
    aws = "~> 3.74"
  }

  provider "aws" {
    region = var.region
  }
  
# Creates a VPC with a /16 address block
resource "aws_vpc" "ansible_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
  }

 # Create a subnet in the VPC with a /24 address block
resource "aws_subnet" "ansible_subnet" {
    vpc_id = aws_vpc.ansible_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
  }

# Creates a security group for the Ansible nodes
resource "aws_security_group" "ansible_sg" {
    vpc_id = aws_vpc.ansible_vpc.id
    name = "ansible_sg"
    description = "Security group for Ansible nodes"

  # Should allow SSH traffic on port 22 for all IPs <--can be chnaged to a certain block of IPs
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }  

# The ami images used for the Ansible control and worker nodes. 1 worker and 2 control nodes. 
locals {
    control_node_ami = var.ami
    worker_node_ami = var.ami
    control_node_count = 1
    worker_node_count = 2
  }

# This will create the control and worker nodes in the VPC and subnet, and assign the security group
resource "aws_instance" "control_node" {
    ami = local.control_node_ami
    instance_type = "t2.micro"
    key_name = var.key_name
    vpc_id = aws_vpc.ansible_vpc.id
    subnet_id = aws_subnet.ansible_subnet.id
    security_groups = [aws_security_group.ansible_sg.id]
    tags = {
     Name = "Ansible Control Node"
    }
  }
resource "aws_instance" "worker_node" {
    ami = local.worker_node_ami
    instance_type = "t2.micro"
    count = local.worker_node_count
    key_name = var.key_name
    vpc_id = aws_vpc.ansible_vpc.id
    subnet_id = aws_subnet.ansible_subnet.id
    security_groups = [aws_security_group.ansible_sg.id]
    tags = {
     Name = "Ansible Worker Node"
    }
  }
}

