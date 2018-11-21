# Step 0 - Basics

Go to:

```bash
git clone https://github.com/artberri/101-terraform.git
git checkout aws-step-0
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

**4\. Set up AWS provider**

```tf
provider "aws" {
    access_key = "XXXXXXXXXXXXXXXXXxxxxxxxx"
    secret_key = "XXXXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxx"
    region     = "eu-west-2"
}
```

Replace the placeholders with your credentials, you can follow this guide if you don't know them:
[Creating credentials for AWS provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) or [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
More info about the authentication with AWS Terraform provider: [AWS Provider](https://www.terraform.io/docs/providers/aws/index.html)

Execute:

```bash
terraform init
terraform providers
terraform plan
```

**5\. Create our first resource**

Add the following code to the `example.tf` file:

```tf
resource "aws_instance" "example" {
    ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type = "t2.micro"
}
```

Execute:

```bash
terraform apply
```

Check in the AWS console that the resource has been created. You should do it during the workshop to ensure that terraform really works ;)

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
resource "aws_instance" "example" {
    ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type = "t2.micro"
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

Continue the workshop: [Step 1](https://github.com/artberri/101-terraform/tree/master/guide/aws/step-1.md).
