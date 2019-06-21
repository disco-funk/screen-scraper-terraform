provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "screen-scrape-hsbc-terraform-state"
    key = "terraform/key"
    region = "eu-west-2"
    dynamodb_table = "screen-scrape-hsbc-terraform-state-dynamo"
  }
}

data "aws_security_group" "default" {
  name = "default"
  vpc_id = module.vpc.vpc_id
}

variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"]
}

resource "aws_lb" "nlb" {
  name = "screen-scraper-nlb"
  internal = false
  load_balancer_type = "network"
  subnets = "${module.vpc.public_subnets}"

  tags = {
    Name = "C24519-screen-scraper-hsbc-nlb"
  }
}

resource "aws_lb_listener" "lb_subnet_tcp" {
  load_balancer_arn = "${aws_lb.nlb.arn}"
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.target-group.arn}"
  }
}

resource "aws_lb_target_group" "target-group" {
  name = "screen-scraper-target-group"
  port = 80
  protocol = "TCP"
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "C24519-screen-scraper-hsbc-target-group"
  }
}

resource "aws_lb_target_group_attachment" "target-group-attachment" {
  count = 3

  target_group_arn = "${aws_lb_target_group.target-group.arn}"
  target_id = "${aws_instance.screen-scrape-ec2[count.index].id}"
  port = 80
}

module "vpc" {
  source = "../"

  name = "screen-scraper-vpc"

  cidr = "10.32.0.0/16"

  azs = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"]
  private_subnets = [
    "10.32.0.0/22",
    "10.32.4.0/22",
    "10.32.8.0/22",
    "10.32.24.0/22",
    "10.32.28.0/22",
    "10.32.32.0/22"]
  public_subnets = [
    "10.32.12.0/22",
    "10.32.16.0/22",
    "10.32.20.0/22"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "C24519-screen-scraper-hsbc-public"
  }

  private_subnet_tags = {
    Name = "C24519-screen-scraper-hsbc-private"
  }

  tags = {
    Name = "C24519-screen-scraper-hsbc-vpc"
  }

  vpc_tags = {
    Name = "C24519-screen-scraper-hsbc-vpc-poc"
  }
}

resource "aws_instance" "screen-scrape-ec2" {
  count = 3

  ami = "ami-07dc734dc14746eab"
  instance_type = "t2.micro"
  subnet_id = "${module.vpc.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = {
    Name = "C24519-screen-scraper-hsbc-${element(var.azs, count.index)}"
  }
}