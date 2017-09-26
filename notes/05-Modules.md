# Modules

Go to:

```
git checkout step-4
```

## Steps

1\. Variables are variables

Add this to variables and use them in main.tf:

```
variable "acme_instance_type" {
    default = "t2.micro"
}

variable "acme_instance_ami" {
    default = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
}

variable "acme_db_type" {
    default = "db.t2.micro"
}
```

2. \ Instance module

https://www.terraform.io/docs/modules/usage.html
https://registry.terraform.io/
https://www.terraform.io/intro/examples/count.html

Replace instances in main.tf with:

```
module "acme_instances" {
  source  = "./modules/aws/instance"
  servers = 2
  elb_id  = "${aws_elb.acme.id}"
  ami     = "${var.acme_instance_ami}"
  type    = "${var.acme_instance_type}"
}
```

Create modules/aws/instance folder with:

input.tf

```
variable "elb_id" {}

variable "type" {}

variable "ami" {}

variable "servers" {}

```

main.tf

```
resource "aws_instance" "main" {
    ami                         = "${var.ami}"
    instance_type               = "${var.type}"
    associate_public_ip_address = true
    key_name                    = "acme"
    # This will create 4 instances
    count = "${var.servers}"
}

resource "aws_elb_attachment" "main" {
    elb      = "${var.elb_id}"
    instance = "${aws_instance.main.*.id[count.index]}"
    # This will create 4 instances
    count = "${var.servers}"
}

```

module output.tf

```
output "ips" {
    value = ["${aws_instance.main.*.public_ip}"]
}
```

in the main output.tf

```
output "acme_ips" {
    value = "${module.acme_instances.ips}"
}
```

```
terraform get
terraform plan
terraform apply
```
