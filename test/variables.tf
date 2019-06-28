variable "region" {
  default = "eu-west-2"
}

variable "prefix" {
  description = "Prefix for all resources."
  type = "string"
  default = "C24519-test"
}

variable "key_name" {
  description = "The name of a secure public key."
  type = string
  default = "C24519-test"
}
