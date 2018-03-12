# Step 1 - Input/Outputs

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout azure-step-1
```

## Steps

**1\. My credentials are shown!!**

Create a `variables.tf` file with the following:

```tf
variable "azurerm_subscription_id" {
    description = "The Azure subscription ID."
}

variable "azurerm_client_id" {
    description = "The Azure Service Principal app ID."
}

variable "azurerm_client_secret" {
    description = "The Azure Service Principal password."
}

variable "azurerm_tenant_id" {
    description = "The Azure Tenant ID."
}

variable "azurerm_region" {
    description = "The Azure region to create things in."
    default = "UK West"
}
```

And replace example.tf with this:

```tf
provider "azurerm" {
    subscription_id = "${var.azurerm_subscription_id}"
    client_id = "${var.azurerm_client_id}"
    client_secret = "${var.azurerm_client_secret}"
    tenant_id = "${var.azurerm_tenant_id}"
}

resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-sample"
    location = "${var.azurerm_region}"
}
```

Now try:

```bash
terraform plan
```

**2\. Ok but... Will I be prompted to enter credentials every time?**

There are multiple options (enviroment variables, from command line, file...): [See documentation](https://www.terraform.io/intro/getting-started/variables.html#assigning-variables)

We will use the default variable file called `terraform.tfvars`, so create a file with that name and the following content:

```txt
azurerm_subscription_id="PUT YOUR AZURE SUBSCRIPTION ID HERE"
azurerm_client_id="PUT YOUR AZURE CLIENT ID HERE"
azurerm_client_secret="PUT YOUR AZURE CLIENT SECRET HERE"
azurerm_tenant_id="PUT YOUR AZURE TENANT ID HERE"
```

Now try:

```bash
terraform plan
```

InsYou can also use the Azure CLI or the Managed Service Identity to authenticate:

- [Authenticating using the Azure CLI](https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html)
- [Authenticating using a Service Principal](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html)
- [Authenticating using Managed Service Identity](https://www.terraform.io/docs/providers/azurerm/authenticating_via_msi.html)

**3\. Let's create a Virtual Network**

For more info see [the virtual network documentation](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html) and [the subnet documentation](https://www.terraform.io/docs/providers/azurerm/r/subnet.html).

Add the following code to our `example.tf`:

```tf
resource "azurerm_virtual_network" "my_vn" {
    name                = "terraform-sample-vn"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
}

resource "azurerm_subnet" "my_subnet_frontend" {
    name                 = "frontend"
    resource_group_name  = "${azurerm_resource_group.terraform_sample.name}"
    virtual_network_name = "${azurerm_virtual_network.my_vn.name}"
    address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "my_subnet_backend" {
    name                 = "backend"
    resource_group_name  = "${azurerm_resource_group.terraform_sample.name}"
    virtual_network_name = "${azurerm_virtual_network.my_vn.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "my_subnet_dmz" {
    name                 = "dmz"
    resource_group_name  = "${azurerm_resource_group.terraform_sample.name}"
    virtual_network_name = "${azurerm_virtual_network.my_vn.name}"
    address_prefix       = "10.0.3.0/24"
}
```

To make the workshop easier we will run `terraform apply -auto-approve` a lot of times
but the proper way is to make a plan and apply it later.

So, run:

```tf
terraform apply -auto-approve
```

**4\. Now, just as a sample, we will output the subnet IDs**

To output to the console some data we can create output elements. Remember that terraform will read all .tf files in the folder where
you are running terraform, so, to keep our code organized we will create a new file called `output.tf` where we will place
the values that we want to output:

```tf
# output.tf file

output "frontend_id" {
    value = "${azurerm_subnet.my_subnet_frontend.id}"
}

output "backend_id" {
    value = "${azurerm_subnet.my_subnet_backend.id}"
}

output "dmz_id" {
    value = "${azurerm_subnet.my_subnet_dmz.id}"
}
```

Run apply again to see the output. (Of course, it won't create the resources again if you already created them in the last step):

```tf
terraform apply -auto-approve
```

**5\. Mini refactor**

Our `example.tf` file doesn't have a meaningful name, let's make a little refactor and put the provider statement in a new `providers.tf`
file and the VN related conf to a `virtual-network.tf` file, then remove the `example.tf` file.

Run apply again to see the that nothing changes.

```tf
terraform apply -auto-approve
```

---

Continue the workshop in [the `azure-step-2` branch](https://github.com/artberri/101-terraform/blob/azure-step-2/instructions/step-2.md).
