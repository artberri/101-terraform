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
