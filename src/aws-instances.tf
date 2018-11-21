module "project1_instances" {
    source            = "./modules/aws/ubuntu-vms-with-lb"
    prefix            = "project1"
    instance_count    = 2
    instance_size     = "t2.micro"
    key_name          = "${aws_key_pair.acme.key_name}"
    user_data_file    = "myapp.sh"
}

module "project2_instances" {
    source            = "./modules/aws/ubuntu-vms-with-lb"
    prefix            = "project2"
    instance_count    = 1
    instance_size     = "t2.micro"
    key_name          = "${aws_key_pair.acme.key_name}"
    user_data_file    = "myapp.sh"
}
