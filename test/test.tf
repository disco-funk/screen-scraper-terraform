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

resource "aws_instance" "direct-channel-mock" {
  ami = "ami-0395e39e84620dd79"
  instance_type = "t2.micro"

  tags = {
    Name = "${var.prefix}-SS-DC"
  }
}
