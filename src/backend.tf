terraform {
    backend "s3" {
        bucket = "terraform-example-101"
        key    = "production.tfstate"
        region = "eu-west-2"
    }
}
