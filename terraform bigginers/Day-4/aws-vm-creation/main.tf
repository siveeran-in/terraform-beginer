resource "aws_key_pair" "web" {
  key_name   = "sagar-kp"
  public_key = file("/root/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami           = "ami-08e5424edfe926b43"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web.key_name

  tags = {
    Name = "sagar-web"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop ufw",
      "sudo systemctl disable ufw",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("/root/.ssh/id_rsa")
      host = self.public_ip
    }
  }

  provisioner "file" {
    source = "web.sh"
    destination = "/tmp/web.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("/root/.ssh/id_rsa")
      host = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 755 /tmp/web.sh",
      "sudo /tmp/web.sh",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("/root/.ssh/id_rsa")
      host = self.public_ip
    }
  }
}