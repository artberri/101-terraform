# Step 2 - The State

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout aws-step-2
```

## Steps

**1\. What is the `terraform.tfstate` file?**

See: [https://www.terraform.io/docs/state/](https://www.terraform.io/docs/state/)

**2\. We will do a little experiment**

Rename the `terraform.tfstate` file with any other name and run `terraform plan` to see what happens.

As you can see terraform thinks that nothing has been created yet and shows a plan
where everything will be created again. Don't run it. This is just to understand how
important is to keep this file saved.

Rename back your state file to `terraform.tfstate`.

**3\. State keeping strategies**

- Single developer: Commiting it to your repo could be a possibility.
- Multiple developers: Commiting is not and option (conflicts will be fifficult to resolve). Use backends: [https://www.terraform.io/docs/backends/index.html](https://www.terraform.io/docs/backends/index.html)

In our case we will use the AWS S3 backend:
[https://www.terraform.io/docs/backends/types/s3.html](https://www.terraform.io/docs/backends/types/s3.html)

*Note: If you are not used to the AWS Console you can skip to [Step 3](https://github.com/artberri/101-terraform/tree/master/guide/aws/step-3.md) in order to save some time and try it later if you have enough time at the end of the workshop*

I'd recommend to create this storage manually (the only thing that should be created manually IMHO). This way,
we will avoid deleting it accidentally and without the ability to recover it.

Now, if you have created the storage account and the containe, create a file called `backend.tf` with the following content:

```tf
terraform {
    backend "s3" {
        bucket = "terraform-example-101"
        key    = "production.tfstate"
        region = "eu-west-2"
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

Continue the workshop: [Step 3](https://github.com/artberri/101-terraform/tree/master/guide/aws/step-3.md).
