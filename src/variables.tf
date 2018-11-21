variable "access_key" {
    description = "The AWS Access key."
}

variable "secret_key" {
    description = "The AWS Secret key."
}

variable "region" {
    description = "The AWS region to create things in."
    default = "eu-west-2"
}

variable "ssh_pubkey_path" {
    description = "Path to the ssh pub key"
    default = "files/admin_ssh_key.pub"
}

variable "instance_count" {
    description = "Number of instances"
    default = 2
}
