provider "aws" {
  access_key = "XXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXX"
  region     = "eu-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
  instance_type = "t2.micro"
}
