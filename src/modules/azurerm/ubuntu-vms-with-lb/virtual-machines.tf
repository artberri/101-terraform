resource "azurerm_availability_set" "frontend" {
    name                = "${var.prefix}-f-availability-set"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group}"
}

resource "azurerm_storage_container" "frontend" {
    count                 = "${var.instance_count}"
    name                  = "${var.prefix}-f-storage-container-${count.index}"
    resource_group_name   = "${var.resource_group}"
    storage_account_name  = "${azurerm_storage_account.frontend.name}"
    container_access_type = "private"
}

resource "azurerm_network_interface" "frontend" {
    count               = "${var.instance_count}"
    name                = "${var.prefix}-f-interface-${count.index}"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group}"

    ip_configuration {
        name                                    = "${var.prefix}-f-ip-${count.index}"
        subnet_id                               = "${var.subnet_id}"
        private_ip_address_allocation           = "dynamic"
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.frontend.id}"]
    }
}

resource "azurerm_virtual_machine" "frontend" {
    count                 = "${var.instance_count}"
    name                  = "${var.prefix}-f-instance-${count.index}"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group}"
    network_interface_ids = ["${element(azurerm_network_interface.frontend.*.id, count.index)}"]
    vm_size               = "${var.instance_size}"
    availability_set_id   = "${azurerm_availability_set.frontend.id}"

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name          = "${var.prefix}-f-disk-${count.index}"
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
        computer_name  = "${var.prefix}-f-instance-${count.index}"
        admin_username = "${var.instance_user}"
        admin_password = "${var.instance_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}
