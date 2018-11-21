# Step 3 - More Resources

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout azure-step-3
```

## Steps

We will add more resources. Check the official documentation to see all available resources:
[https://www.terraform.io/docs/providers/azurerm/](https://www.terraform.io/docs/providers/azurerm/)

As an example we will spin up 2 machines in the frontend subnet under a load balancer.

**1\. First, we will create some variables that we will use later**

Add the following to the `variables.tf` file:

```tf
variable "arm_vm_admin_password" {
    description = "Passwords for the root user in VMs."
    default = "SUper.123-" # This should be hidden and passed as variable, doing this just for training purpose
}

variable "arm_frontend_instances" {
    description = "Number of front instances"
    default = 2
}
```

**2\. Next, we will create the load balancer**

Create a `load-balancer.tf` file with the following content (load balancer and it rules, see how we pass parameters from one reource to the others):

```tf
resource "azurerm_public_ip" "frontend" {
    name                         = "101-terraform-public-ip"
    location                     = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name          = "${azurerm_resource_group.terraform_sample.name}"
    public_ip_address_allocation = "static"
}

resource "azurerm_lb" "frontend" {
    name                = "101terraform-f-lb"
    location            = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"

    frontend_ip_configuration {
        name                          = "default"
        public_ip_address_id          = "${azurerm_public_ip.frontend.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_lb_probe" "port80" {
    name                = "101terraform-f-lb-probe-80-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
}

resource "azurerm_lb_rule" "port80" {
    name                    = "101terraform-f-lb-rule-80-80"
    resource_group_name     = "${azurerm_resource_group.terraform_sample.name}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port80.id}"

    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_probe" "port443" {
    name                = "101terraform-f-lb-probe-443-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
    protocol            = "Http"
    request_path        = "/"
    port                = 443
}

resource "azurerm_lb_rule" "port443" {
    name                    = "101terraform-f-lb-rule-443-443"
    resource_group_name     = "${azurerm_resource_group.terraform_sample.name}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port443.id}"

    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_backend_address_pool" "frontend" {
    name                = "101terraform-f-lb-pool"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
}
```

Plan and execute, you already know how to do this ;)

**3\. We'll create an storage account for the VM disks**

Create a `storage-account.tf` file with the following content:

```tf
resource "random_id" "storage_account" {
    prefix      = "101terraform"
    byte_length = "4"
}

resource "azurerm_storage_account" "frontend" {
    name                     = "${lower(random_id.storage_account.hex)}"
    resource_group_name      = "${azurerm_resource_group.terraform_sample.name}"
    location                 = "${azurerm_resource_group.terraform_sample.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
```

**4\. Finally we will create the availabilty set and the VMs**

Create a `virtual-machines.tf` file with the following content:

```tf
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
    vm_size               = "Standard_DS1_v2"
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
```

**5\. We should output the Load balancer IP in order to be able to point our A/CNAME record to it**

Delete the other outputs from the `outputs.tf` file and add the following:

```tf
output "load_balancer_ip" {
    value = "${azurerm_public_ip.frontend.ip_address}"
}
```

**6\. Plan and execute**

Try running `terraform plan`.

You will see that terraform is complaining because it has not the `random` provider which is needed
to create the random number. So, you will need to run `init` again:

```bash
terraform init -backend-config=terraform.tfvars
```

Now create a plan and execute it:

```bash
terraform plan -out=my.plan
terraform apply -auto-approve "my.plan"
```

---

Continue the workshop: [Step 4](https://github.com/artberri/101-terraform/tree/master/guide/azure/step-4.md).
