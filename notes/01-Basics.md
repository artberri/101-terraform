# Basics

Go to:

```
git checkout step-0
```

## Steps

1\. Ensure everyone has terraform installed and running

```
terraform -v
terraform -h
```

2\. Try terraform init and fail

```
mkdir src
cd src/
terraform init
```

3\. Create our first empty example

```
touch example.tf
terraform init
```

4\. Run terraform plan (No changes)

```
terraform plan
```

5\. first example

(ensure everyone have their amazon credentials)

```
provider "aws" {
  access_key = "XXXXXXXXXXXXXXXXXxxxxxxxx"
  secret_key = "XXXXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxx"
  region     = "eu-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
  instance_type = "t2.micro"
}
```

```
terraform plan
terraform providers
terraform init
terraform plan
```

*ATENTION*

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.


6\. Prepare a plan

```
terraform plan -out=my.plan
```

7\. Prepare a plan

```
terraform apply "my.plan"
```

8\. Deleting resources

8.1 If you want to remove it permanently

Remove:

```
resource "aws_instance" "example" {
  ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
  instance_type = "t2.micro"
}
```

and:

```
terraform plan
```

8.2 If you just want to remove everything to rebuild

```
terraform plan -destroy -out=my.plan
terraform apply "my.plan"
# If you run plan again you will see that it plans to create it again
terraform plan
```
