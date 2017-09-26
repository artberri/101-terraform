variable "aws_region" {
    description = "The AWS region to create things in."
    default = "eu-west-2"
}

variable "acme_instance_type" {
    default = "t2.micro"
}

variable "acme_instance_ami" {
    default = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
}

variable "acme_db_type" {
    default = "db.t2.micro"
}

variable "acme_db_name" {}
variable "acme_db_user" {}
variable "acme_db_pass" {}

variable "godaddy_key" {}
variable "godaddy_secret" {}
