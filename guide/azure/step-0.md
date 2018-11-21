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

Replace the placeholders with your credentials, you can follow this guide if you don't know them:
[Creating credentials for Azure provider](https://www.terraform.io/docs/providers/azurerm/#creating-credentials).
The recommended method is to use a service principal but you can use the Azure Cli also.

Execute:

```bash
terraform init
terraform providers
terraform plan
```

**5\. Create our first resource**

Add the following code to the `example.tf` file:

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

Check in the Azure portal that the resource has been created. You should do it during the workshop to ensure that terraform really works ;)

Try also:

```bash
terraform plan -destroy # Check what will be deleted  if we run a destroy command
terraform destroy # Destroy every declared resource
terraform apply -auto-approve # If we execute apply again the resources will be regenerated
```

*Note: we use the -auto-approve option to avoid the prompt, and 'plan' is optional but recommended to be able to see what will happen*

Check also what happens if we remove the resource from the code and if we execute:

```bash
terraform plan
terraform apply -auto-approve
```

As you can see, managed resources will be deleted if they dissapear from code. This is the common way to delete resources.

**6\. Prepare a plan and execute it**

Did you notice this warning?

> *WARNING*
>
> Note: You didn't specify an "-out" parameter to save this plan, so Terraform
> can't guarantee that exactly these actions will be performed if
> "terraform apply" is subsequently run.

This is because when we are planning, we can save the shown plan to a file.
By applying this plan later, Terraform will ensure
that the state of your infrastructure is the same as when you planned to avoid
unwanted changes.

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

Continue the workshop: [Step 1](https://github.com/artberri/101-terraform/tree/master/guide/azure/step-1.md).
