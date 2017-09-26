# State

Go to:

```
git checkout step-2
```

## Steps

1\. What is the terraform.tfstate file?
https://www.terraform.io/docs/state/

2\. Delete the file

Delete the file and then:

```
terraform plan -var-file="production.tfvars"
```

3\. Import the resource

Look at your resource ID in the AWS console

```
terraform import -var-file="production.tfvars" aws_instance.example i-abcd1234
terraform plan -var-file="production.tfvars"
```

4\. Commit the state file?

Remote state file and better only CI

5\. Remote state file

https://www.terraform.io/docs/state/remote.html

We will use S3

Create a state.tf file with:

```
terraform {
    backend "s3" {
        bucket = "terraform-example"
        key    = "production.tfstate"
        region = "eu-west-2"
    }
}
```

```
terraform plan -var-file="production.tfvars"
```

Replace the file with:

```
resource "aws_s3_bucket" "state" {
    bucket = "terraform-example"
    acl    = "private"

    tags {
        Name        = "Terraform State Store"
        Environment = "Production"
    }
}
```

Tags? Add them also to the ec2 VM:

```
resource "aws_instance" "example" {
    ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type = "t2.micro"

    tags {
        Name        = "Example Machine"
        Environment = "Production"
    }
}
```

```
terraform plan -var-file="production.tfvars" -out=my.plan
terraform apply "my.plan"
```

Add again to the file:

```
terraform {
    backend "s3" {
        bucket = "terraform-example"
        key    = "production.tfstate"
        region = "eu-west-2"
    }
}
```

```
terraform plan -var-file="production.tfvars"
terraform init
```

We need to use another kind of authentication:

Create: ~/.aws/credentials

with:
```
[default]
aws_access_key_id = XXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXX
```
aws configure --profile default ???

Init (with copy state) and remove old credentials tfvars files

```
terraform init
rm terraform.tfstate
rm terraform.tfstate.backup
```
