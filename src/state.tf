terraform {
    backend "s3" {
        bucket = "terraform-example"
        key    = "production.tfstate"
        region = "eu-west-2"
    }
}

resource "aws_s3_bucket" "state" {
    bucket = "terraform-example"
    acl    = "private"

    tags {
        Name        = "Terraform State Store"
        Environment = "Production"
    }
}
