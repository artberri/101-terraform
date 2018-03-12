# Step 2 - The State

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout azure-step-2
```

## Steps

**1\. What is the `terraform.tfstate` file?**

See: [https://www.terraform.io/docs/state/](https://www.terraform.io/docs/state/)

**2\. Make a little test**

Rename the `terraform.tfstate` file and run `terraform plan` to see what happens.

**3\. State keeping strategies**

- Single developer: Commiting it to your repo could be a possibility.
- Multiple developers: Commiting is not and option (conflicts will be fifficult to resolve). Use backends: [https://www.terraform.io/docs/backends/index.html](https://www.terraform.io/docs/backends/index.html)

In our case we will use the Azure backend (an storage account):
[https://www.terraform.io/docs/backends/types/azurerm.html](https://www.terraform.io/docs/backends/types/azurerm.html)

I'd recommend to create this storage manually (the only thing that should be created manually IMHO). This way,
we will avoid deleting it accidentally and without the ability to recover it.

Now, create a file called `backend.tf` with the following content:

```tf
terraform {
    backend "azurerm" {
        storage_account_name = "101terraformstates" # Use your own unique name here
        container_name       = "plaintfstate"
        key                  = "prod.terraform.tfstate"
        resource_group_name  = "101-terraform-states"
    }
}
```

And try running `terraform plan`. What happened?

As you can see, you need to reinitialize your workspace. This usually happens when you change your providers
or your backend. To solve the issue you need to run `terraform init`, which is an idempotent command that
can be safely called as many times as you need.

In this case we will run the command passing a conf file to provide the credentials (because variable interpolation
is not available during backend initialization):

```bash
terraform init -backend-config=terraform.tfvars
```

Answer `yes` if you are prompted to copy your local state to your remote backend.

After this, you will be able to remove your local `.tfstate` files.

```bash
rm terraform.tfstate
rm terraform.tfstate.backup
```

---

Continue the workshop in [the `azure-step-3` branch](https://github.com/artberri/101-terraform/blob/azure-step-3/instructions/step-3.md).
