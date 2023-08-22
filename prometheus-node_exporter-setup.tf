provider "aws" {
  region = "us-east-1"
}


locals {
  instance_type = "t2.micro"
}
resource "aws_instance" "node-exporter" {
  ami                         = var.ami_id
  instance_type               = local.instance_type
  key_name                    = "myec2keypair"
  vpc_security_group_ids      = [aws_security_group.node_exp_sg.id]
  associate_public_ip_address = true
  user_data                   = file("node-exporter.sh")
  tags = {
    Name = "node-exporter-tf"
  }
}

resource "aws_instance" "prometheus" {
  ami                         = var.ami_id
  instance_type               = local.instance_type
  key_name                    = "myec2keypair"
  vpc_security_group_ids      = [aws_security_group.prom_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get update
              sudo apt-get -y upgrade
              cd /opt
              sudo wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
              sudo tar xf prometheus-2.43.0.linux-amd64.tar.gz
              sudo sed -i 's/- targets: \["localhost:9090"\]/- targets: \["localhost:9090", ${aws_instance.node-exporter.public_ip}:9100\]/' /opt/prometheus-2.43.0.linux-amd64/prometheus.yml
              sudo ./prometheus
              EOF

  tags = {
    Name = "prometheus-tf"
  }
}


resource "aws_security_group" "node_exp_sg" {
  name_prefix = "node_exp_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
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

resource "aws_security_group" "prom_sg" {
  name_prefix = "prom_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
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
