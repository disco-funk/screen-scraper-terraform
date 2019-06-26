provider "aws" {
  //region = "eu-west-2"
  region = "${var.region}"
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

resource "aws_security_group" "tcp-port80" {
  name = "${var.prefix}-SS-tcp-port80"
  description = "Allow port 80 TCP inbound traffic"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = "${var.ingress_from_port}"
    to_port = "${var.ingress_to_port}"
    protocol = "${var.ingress_protocol}"
    cidr_blocks = "${var.ingress_cidr_blocks}"
  }

  tags = {
    Name = "${var.prefix}-SS-hsbc-sg"
  }
}

resource "aws_lb" "nlb" {
  name = "${var.prefix}-SS-nlb"
  internal = false
  load_balancer_type = "${var.lb_type}"
  subnets = module.vpc.public_subnets

  tags = {
    Name = "${var.prefix}-SS-hsbc-nlb"
  }
}

resource "aws_lb_listener" "lb_subnet_tcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port = "${var.lb_listener_port}"
  protocol = "${var.lb_listener_protocol}"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group" "target-group" {
  name = "${var.prefix}-SS-target-group"
  port = 80
  protocol = "TCP"
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.prefix}-SS-hsbc-target-group"
  }
}

resource "aws_lb_target_group_attachment" "target-group-attachment" {
  count = 3

  target_group_arn = aws_lb_target_group.target-group.arn
  target_id = aws_instance.screen-scrape-ec2[count.index].id
  port = 80
}

module "vpc" {
  source = "../"

  name = "${var.prefix}-SS-vpc"

  cidr = "${var.vpc_cidr}"

  azs = "${var.azs}"

  private_subnets = "${var.private_subnets}"
  public_subnets = "${var.public_subnets}"

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "${var.prefix}-SS-hsbc-public"
  }

  private_subnet_tags = {
    Name = "${var.prefix}-SS-hsbc-private"
  }

  tags = {
    Name = "${var.prefix}-SS-hsbc-vpc"
  }

  vpc_tags = {
    Name = "${var.prefix}-SS-hsbc-vpc-poc"
  }
}

resource "aws_instance" "screen-scrape-ec2" {
  count = 3

  ami = "${var.ami}"
  // C24519-screen-scraper-hsbc-nginx-ec2 AMI
  instance_type = "${var.ec2_instance_type}"
  subnet_id = module.vpc.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  security_groups = [
    "${aws_security_group.tcp-port80.id}"]

  tags = {
    Name = "${var.prefix}-SS-hsbc-${var.azs[count.index]}"
  }
}
