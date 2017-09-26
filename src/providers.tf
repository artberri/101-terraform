provider "aws" {
    region  = "${var.aws_region}"
}

provider "godaddy" {
    key = "${var.godaddy_key}"
    secret = "${var.godaddy_secret}"
}
