provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "stage_instance" {
  instance_type          = var.instance_type
  ami                    = var.ami_id
  key_name               = "myec2keypair"
  vpc_security_group_ids = ["sg-02d85b5dd5f74c7a7"]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("myec2keypair.pem")
      host        = aws_instance.stage_instance.public_ip
    }
    source      = "abc.sh"
    destination = "/tmp/abc.sh"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("myec2keypair.pem")
    host        = aws_instance.stage_instance.public_ip
  }
  provisioner "remote-exec" {

    
    inline = [
      "chmod +x /tmp/abc.sh",
      "/tmp/abc.sh",
    ]
  }

  tags = {
    Name = "stage-instance"
  }
}
