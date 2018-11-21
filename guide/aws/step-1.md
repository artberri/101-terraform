# Step 1 - Input/Outputs

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout aws-step-1
```

## Steps

**1\. My credentials are hardcoded!!**

Create a `variables.tf` file with the following:

```tf
variable "access_key" {
    description = "The AWS Access key."
}

variable "secret_key" {
    description = "The AWS Secret key."
}

variable "region" {
    description = "The AWS region to create things in."
    default = "eu-west-2"
}
```

And replace example.tf with this (save your credentials first for later use):

```tf
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

resource "aws_instance" "example" {
    ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type = "t2.micro"
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
access_key = "PUT YOUR AWS ACCESS KEY HERE"
secret_key = "PUT YOUR AWS SECRET KEY HERE"
```

Now try:

```bash
terraform plan
```

You can also use other methods to authenticate: [AWS Provider authentication](https://www.terraform.io/docs/providers/aws/index.html)

**3\. Let's create an S3 bucket**

For more info see [the s3 bucket documentation](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html).

Add the following code to our `example.tf`:

```tf
resource "aws_s3_bucket" "acme" {
    bucket = "acme-terraform-101-images"
    acl    = "public-read"
}
```

To make the workshop easier we will run `terraform apply -auto-approve` a lot of times
but the proper way is to make a plan and apply it later.

So, run:

```tf
terraform apply -auto-approve
```

**4\. Now, we will output the machine IP**

To output to the console some data we can create output elements. Remember that terraform will read all .tf files in the folder where
you are running terraform, so, to keep our code organized we will create a new file called `output.tf` where we will place
the values that we want to output:

```tf
# output.tf file

output "acme_ip" {
    value = "${aws_instance.example.public_ip}"
}
```

Run apply again to see the output. (Of course, it won't create the resources again if you already created them in the last step):

```tf
terraform apply -auto-approve
```

**5\. Mini refactor**

Our `example.tf` file doesn't have a meaningful name, let's make a little refactor and put the provider statement in a new `providers.tf`
file, s3 bucket in a new `s3.tf` file and the instance related conf to a `instances.tf` file, then remove the `example.tf` file.

Run apply again to see the that nothing changes.

```tf
terraform apply -auto-approve
```

---

Continue the workshop: [Step 2](https://github.com/artberri/101-terraform/tree/master/guide/aws/step-2.md).
