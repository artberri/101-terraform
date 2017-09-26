# AcmeCo admin key
resource "aws_key_pair" "acme" {
    key_name   = "acme"
    public_key = "${file("../admin_ssh_key.pub")}"
}

module "main_project" {
    source           = "./modules/aws/project"
    subdomain        = "acme"
    servers          = 1
    instance_ami     = "${var.acme_instance_ami}"
    instance_type    = "${var.acme_instance_type}"
    bootstrap_script = "sample.sh"
}
