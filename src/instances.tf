// module "project1_instances" {
//     source            = "./modules/azurerm/ubuntu-vms-with-lb"
//     prefix            = "acme"
//     resource_group    = "${azurerm_resource_group.terraform_sample.name}"
//     location          = "${azurerm_resource_group.terraform_sample.location}"
//     subnet_id         = "${azurerm_subnet.my_subnet_frontend.id}"
//     instance_count    = 0
//     instance_size     = "Standard_A0"
//     instance_user     = "${var.arm_frontend_instances}"
//     instance_password = "${var.arm_vm_admin_password}"
//     custom_data_file  = "myapp.sh"
// }

// module "project2_instances" {
//     source            = "./modules/azurerm/ubuntu-vms-with-lb"
//     prefix            = "acme2"
//     resource_group    = "${azurerm_resource_group.terraform_sample.name}"
//     location          = "${azurerm_resource_group.terraform_sample.location}"
//     subnet_id         = "${azurerm_subnet.my_subnet_frontend.id}"
//     instance_count    = 0
//     instance_size     = "Standard_A2"
//     instance_user     = "${var.arm_frontend_instances}"
//     instance_password = "${var.arm_vm_admin_password}"
//     custom_data_file  = "myapp.sh"
// }
