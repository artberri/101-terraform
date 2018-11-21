# Step 4 - Modules

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout azure-step-4
```

## Steps

As the code size grows, we will need to reorganize our code and reuse resources to keep it readable
and maintainable. This is when modules comes up. Link: [Oficial documentation](https://www.terraform.io/docs/modules/usage.html).

We will do a litle example now, but in real live do not reinvent the wheel, we have a lot of official and unofficial modules in the
Terraform Module Registry that could match your needs. Link: [Terraform Module Registry](https://www.terraform.io/docs/modules/usage.html).

**1\. Create a directory for our new module**

```bash
mkdir -p modules/azurerm/ubuntu-vms-with-lb
```

*Remember: Terraform will include all `.tf` files that are in the folder where is being executed,
but it won't do it recursively.*

**2\. Create the module**

First thing to do is to move the `virtual-machines.tf`, `storage-account.tf` and the `load-balancer.tf` files to the recently created folder.

Then create a `variables.tf` and a `output.tf` empty files inside the `ubuntu-vms-with-lb` folder.

Add the following variables to the new created `variables.tf` file:

```tf
variable "prefix" {}

variable "resource_group" {}

variable "location" {}

variable "subnet_id" {}

variable "instance_count" {}

variable "instance_size" {}

variable "instance_user" {}

variable "instance_password" {}
```

We will use this variables inside the `virtual-machines.tf`, `storage-account.tf` and the `load-balancer.tf` file in order to make it reusable.
Copy the file contents of bellow if you want to go faster:

`load-balancer.tf`

```tf
resource "azurerm_public_ip" "frontend" {
    name                         = "${var.prefix}-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.resource_group}"
    public_ip_address_allocation = "static"
}

resource "azurerm_lb" "frontend" {
    name                = "${var.prefix}-f-lb"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group}"

    frontend_ip_configuration {
        name                          = "default"
        public_ip_address_id          = "${azurerm_public_ip.frontend.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_lb_probe" "port80" {
    name                = "${var.prefix}-f-lb-probe-80-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${var.resource_group}"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
}

resource "azurerm_lb_rule" "port80" {
    name                    = "${var.prefix}-f-lb-rule-80-80"
    resource_group_name     = "${var.resource_group}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port80.id}"

    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_probe" "port443" {
    name                = "${var.prefix}-f-lb-probe-443-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${var.resource_group}"
    protocol            = "Http"
    request_path        = "/"
    port                = 443
}

resource "azurerm_lb_rule" "port443" {
    name                    = "${var.prefix}-f-lb-rule-443-443"
    resource_group_name     = "${var.resource_group}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port443.id}"

    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_backend_address_pool" "frontend" {
    name                = "${var.prefix}-f-lb-pool"
    resource_group_name = "${var.resource_group}"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
}
```

`storage-account.tf`

```tf
resource "random_id" "storage_account" {
    prefix      = "${var.prefix}"
    byte_length = "4"
}

resource "azurerm_storage_account" "frontend" {
    name                     = "${lower(random_id.storage_account.hex)}"
    resource_group_name      = "${var.resource_group}"
    location                 = "${var.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
```

`virtual-machines.tf`

```tf
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
```

Finally we will create an output to our module to expose the IP:

`output.tf`:

```tf
output "load_balancer_ip" {
    value = "${azurerm_public_ip.frontend.ip_address}"
}

```

**3\. Plan and execute**

Now we will use this litle module inside our project, for that we will create a `azure-instances.tf` file with the following
content in the `src` folder that is calling our own module:

```tf
module "project1_instances" {
    source            = "./modules/azurerm/ubuntu-vms-with-lb"
    prefix            = "acme"
    resource_group    = "${azurerm_resource_group.terraform_sample.name}"
    location          = "${azurerm_resource_group.terraform_sample.location}"
    subnet_id         = "${azurerm_subnet.my_subnet_frontend.id}"
    instance_count    = 2
    instance_size     = "Standard_A0"
    instance_user     = "${var.arm_frontend_instances}"
    instance_password = "${var.arm_vm_admin_password}"
}

module "project2_instances" {
    source            = "./modules/azurerm/ubuntu-vms-with-lb"
    prefix            = "acme2"
    resource_group    = "${azurerm_resource_group.terraform_sample.name}"
    location          = "${azurerm_resource_group.terraform_sample.location}"
    subnet_id         = "${azurerm_subnet.my_subnet_frontend.id}"
    instance_count    = 1
    instance_size     = "Standard_A2"
    instance_user     = "${var.arm_frontend_instances}"
    instance_password = "${var.arm_vm_admin_password}"
}
```

We should also change the content of the `output.tf` file in our src folder:

```tf
output "project1_load_balancer_ip" {
    value = "${module.project1_instances.load_balancer_ip}"
}

output "project2_load_balancer_ip" {
    value = "${module.project2_instances.load_balancer_ip}"
}

```

**4\. Plan and execute**

Try running `terraform plan`.

You will see that terraform is complaining because it has not the `module project1_instances` module and is
suggesting you to runu init again, so, you will need to run `init` again:

```bash
terraform init -backend-config=terraform.tfvars
```

Now create a plan and execute it:

```bash
terraform plan -out=my.plan
terraform apply -auto-approve "my.plan"
```

---

Continue the workshop: [Step 5](https://github.com/artberri/101-terraform/tree/master/guide/azure/step-5.md).
