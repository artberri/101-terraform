# Provisioners

Go to:

```
git checkout step-6
```

## Steps

1\. Let's create vars file to pass dp user/pass

(let people do it)

```
resource "aws_db_instance" "acme" {
  allocated_storage    = 5
  storage_type         = "standard"
  engine               = "mysql"
  engine_version       = "5.7.17"
  instance_class       = "${var.acme_db_type}"
  name                 = "${var.acme_db_name}"
  username             = "${var.acme_db_user}"
  password             = "${var.acme_db_pass}"
}
```

input.tf:

```
variable "acme_db_name" {}
variable "acme_db_user" {}
variable "acme_db_pass" {}
```

terraform.tfvars:

```
acme_db_name = "name"
acme_db_user = "acme"
acme_db_pass = "12345678"
```

2\. Provisioning our images

Change main.tf:

```
resource "aws_db_instance" "acme" {
  allocated_storage    = 5
  storage_type         = "standard"
  engine               = "mysql"
  engine_version       = "5.7.17"
  instance_class       = "${var.acme_db_type}"
  name                 = "${var.acme_db_name}"
  username             = "${var.acme_db_user}"
  password             = "${var.acme_db_pass}"
  skip_final_snapshot  = true
}

data "template_file" "mycnf" {
  template = "${file("../templates/sample.sh.tpl")}"

  vars {
    host     = "${aws_db_instance.acme.address}"
    database = "${var.acme_db_name}"
    user     = "${var.acme_db_user}"
    password = "${var.acme_db_pass}"
  }
}

module "acme_instances" {
  source           = "./modules/aws/instance"
  servers          = 1
  elb_id           = "${aws_elb.acme.id}"
  ami              = "${var.acme_instance_ami}"
  type             = "${var.acme_instance_type}"
  bootstrap_script = "${data.template_file.mycnf.rendered}"
  security_group   = "${aws_security_group.acme_instances.name}"
}
```

And in the main.tf of the module:

```
    user_data = "${var.bootstrap_script}"
```

Download new provider and run

```
terraform init
terraform get
terraform plan
terraform apply
```
