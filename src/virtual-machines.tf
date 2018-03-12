resource "azurerm_availability_set" "frontend" {
    name                = "101terraform-f-availability-set"
    location            = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
}

resource "azurerm_storage_container" "frontend" {
    count                 = "${var.arm_frontend_instances}"
    name                  = "101terraform-f-storage-container-${count.index}"
    resource_group_name   = "${azurerm_resource_group.terraform_sample.name}"
    storage_account_name  = "${azurerm_storage_account.frontend.name}"
    container_access_type = "private"
}

resource "azurerm_network_interface" "frontend" {
    count               = "${var.arm_frontend_instances}"
    name                = "101terraform-f-interface-${count.index}"
    location            = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"

    ip_configuration {
        name                                    = "101terraform-f-ip-${count.index}"
        subnet_id                               = "${azurerm_subnet.my_subnet_frontend.id}"
        private_ip_address_allocation           = "dynamic"
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.frontend.id}"]
    }
}

resource "azurerm_virtual_machine" "frontend" {
    count                 = "${var.arm_frontend_instances}"
    name                  = "101terraform-f-instance-${count.index}"
    location              = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name   = "${azurerm_resource_group.terraform_sample.name}"
    network_interface_ids = ["${element(azurerm_network_interface.frontend.*.id, count.index)}"]
    vm_size               = "Standard_A0"
    availability_set_id   = "${azurerm_availability_set.frontend.id}"

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name          = "101terraform-f-disk-${count.index}"
        vhd_uri       = "${azurerm_storage_account.frontend.primary_blob_endpoint}${element(azurerm_storage_container.frontend.*.name, count.index)}/mydisk.vhd"
        caching       = "ReadWrite"
        create_option = "FromImage"
    }

    # Optional data disks
    storage_data_disk {
        name          = "datadisk0"
        vhd_uri       = "${azurerm_storage_account.frontend.primary_blob_endpoint}${element(azurerm_storage_container.frontend.*.name, count.index)}/datadisk0.vhd"
        disk_size_gb  = "1023"
        create_option = "Empty"
        lun           = 0
    }

    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    os_profile {
        computer_name  = "101terraform-f-instance-${count.index}"
        admin_username = "demo"
        admin_password = "${var.arm_vm_admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}
