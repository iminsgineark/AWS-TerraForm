provider "aws" {
  region = "us-east-1"
}


locals {
  instance_type = "t2.micro"
}

variable "ami_id" {
  description = "The AMI to use Amazon Linux"
  default     = "ami-02396cdd13e9a1257"
}


resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = local.instance_type
  key_name                    = "myec2keypair"
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  user_data                   = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}


resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
