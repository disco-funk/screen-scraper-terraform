provider "aws" {
  region = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "c24159-backend-test-state"
    key = "terraform/key"
    region = "eu-west-2"
    dynamodb_table = "c24159-backend-test-state-dynamo"
  }
}

resource "aws_security_group" "direct-channel-security-group" {
  name = "direct-channel-security-group"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "direct-channel-mock" {
  ami = "ami-0395e39e84620dd79"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.direct-channel-security-group.id]
  key_name = var.key_name

  tags = {
    Name = "${var.prefix}-SS-DC"
  }
}

resource "null_resource" "direct-channel-nr" {
  connection {
    user = "ubuntu"
    host = aws_instance.direct-channel-mock.public_ip
    private_key = file("~/.ssh/${var.key_name}.pem")
  }

  provisioner "file" {
    source      = "apt"
    destination = "apt"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x apt",
      "sudo ./apt install -y default-jre"
    ]
  }

  provisioner "file" {
    source      = "wiremock-standalone-2.23.2.jar"
    destination = "wiremock-standalone-2.23.2.jar"
  }

  provisioner "remote-exec" {
    inline = [
      "nohup java -jar wiremock-standalone-2.23.2.jar &",
      "sleep 1"
    ]
  }
}
