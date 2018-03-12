# Step 0 - Basics

Go to:

```bash
git clone https://github.com/artberri/101-terraform.git
git checkout azure-step-0
```

## Steps

**1\. Ensure you has terraform properly installed**

```bash
terraform -v
terraform -h
```

**2\. Create directory for our code**

```bash
mkdir src
cd src/
```

**3\. Create our first empty example and run terraform plan (It should say there are no changes)**

```bash
touch example.tf
terraform init
terraform plan
```

**4\. Set up AzureRM provider (Do not use Azure Service Management Provider anymore, it's the legacy API)**

```tf
provider "azurerm" {
    subscription_id = "subscription_id-example"
    client_id = "client_id-example"
    client_secret = "client_secret-example"
    tenant_id = "tenant_id-example"
}
```

Execute:

```bash
terraform init
terraform providers
terraform plan
```

**5\. Create our first resource**

Add the following to the `example.tf` file:

```tf
resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-sample"
    location = "West Europe"
}
```

Execute:

```bash
terraform apply
```

Try also:

```bash
terraform plan -destroy
terraform destroy
terraform apply -auto-approve
```

Check also what happens if we remove the resource from the code and if we execute:

```bash
terraform plan
terraform apply -auto-approve
```

*WARNING*

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

**6\. Prepare a plan and execute it**

Add the resource group again to the `example.tf` file:

```tf
resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-sample"
    location = "West Europe"
}
```

Now we will prepare a plan (it won't be executed):

```bash
terraform plan -out=my.plan
```

And execute the plan:

```bash
terraform apply "my.plan"
```

This way, we will ensure that it will be executed only what we already planned and we will avoid conflicts with multiple concurrent executions.

---

Continue the workshop in [the `azure-step-1` branch](https://github.com/artberri/101-terraform/blob/azure-step-1/instructions/step-1.md).
