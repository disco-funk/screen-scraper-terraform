variable "region" {
  default = "eu-west-2"
}

variable "prefix" {
  description = "Prefix for all resources."
  default = "C24519"
}

variable "ingress_from_port" {
  default = 80
}

variable "ingress_to_port" {
  default = 80
}

variable "ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "ingress_protocol" {
  default = "tcp"
}

variable "lb_type" {
  description = "Load balancer type."
  default = "network"
}

variable "lb_listener_port" {
  description = "Port for load balancer listener."
  default = 80
}

variable "lb_listener_protocol" {
  description = "Protocol for load balancer listener."
  default = "TCP"
}

variable "vpc_cidr" {
  default = "10.32.0.0/16"
}

variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones."
  type = "list"
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"]
}

variable "private_subnets" {
  description = "Private subnets for vpc."
  type = "list"
  default = [
    "10.32.24.0/22",
    "10.32.28.0/22",
    "10.32.32.0/22",
    "10.32.0.0/22",
    "10.32.4.0/22",
    "10.32.8.0/22"]
}

variable "public_subnets" {
  description = "Public subnets for vpc."
  type = "list"
  default = [
    "10.32.12.0/22",
    "10.32.16.0/22",
    "10.32.20.0/22"]
}

variable "ami" {
  description = "AMI for EC2 instance."
  default = "ami-0395e39e84620dd79"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2"
  default = "t2.micro"
}