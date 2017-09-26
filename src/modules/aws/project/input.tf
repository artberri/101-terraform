variable "subdomain" {}
variable "bootstrap_script" {}
variable "servers" {
    default = 1
}

variable "instance_type" {
    default = "t2.micro"
}

variable "instance_ami" {
    default = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
}
