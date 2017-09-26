# Exercise refactor

Go to:

```
git checkout step-7
```

## Steps

1\. Reorganize all this mess in order to be able to create the resources like this

main.tf:

```
# AcmeCo admin key
resource "aws_key_pair" "acme" {
    key_name   = "acme"
    public_key = "${file("../admin_ssh_key.pub")}"
}

module "main_project" {
    source           = "./modules/aws/project"
    subdomain        = "acme"
    servers          = 2
    instance_ami     = "${var.acme_instance_ami}"
    instance_type    = "${var.acme_instance_type}"
    bootstrap_script = "sample.sh"
}

module "secondary_project" {
    source           = "./modules/aws/project"
    subdomain        = "secondary"
    servers          = 1
    instance_ami     = "${var.acme_instance_ami}"
    instance_type    = "${var.acme_instance_type}"
    bootstrap_script = "sample.sh"
}
```

Solution:

```
git checkout step-8
```

Bad side of refactor: you need to move resources

```
git checkout step-8
```


Solution:

```
git checkout master
```