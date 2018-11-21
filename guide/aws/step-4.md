# Step 4 - Modules

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout aws-step-4
```

## Steps

As the code size grows, we will need to reorganize our code and reuse resources to keep it readable
and maintainable. This is when modules comes up. Link: [Oficial documentation](https://www.terraform.io/docs/modules/usage.html).

We will do a litle example now, but in real live do not reinvent the wheel, we have a lot of official and unofficial modules in the
Terraform Module Registry that could match your needs. Link: [Terraform Module Registry](https://www.terraform.io/docs/modules/usage.html).

**1\. Create a directory for our new module**

```bash
mkdir -p modules/aws/ubuntu-vms-with-lb
```

*Remember: Terraform will include all `.tf` files that are in the folder where is being executed,
but it won't do it recursively.*

**2\. Create the module**

First thing to do is to move the `instances.tf`, `security-group.tf` and the `load-balancer.tf` files to the recently created folder.

Then create a `variables.tf` and a `output.tf` empty files inside the `ubuntu-vms-with-lb` folder.

Add the following variables to the new created `variables.tf` file:

```tf
variable "prefix" {}

variable "instance_count" {}

variable "instance_size" {}

variable "key_name" {}
```

We will use this variables inside the `instances.tf`, `security-group.tf` and the `load-balancer.tf` file in order to make it reusable.
Copy the file contents of bellow if you want to go faster:

`load-balancer.tf`

```tf
resource "aws_elb" "acme" {
    name               = "${var.prefix}-acme-elb"
    availability_zones = ["eu-west-2a", "eu-west-2b"]

    listener {
        instance_port     = 5000
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:5000/"
        interval            = 30
    }
}
```

`security-group.tf`

```tf
resource "aws_security_group" "acme_instances" {
    name        = "${var.prefix}-acme_instances"
    description = "Allow load balancer traffic and outbound"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 5000
        to_port         = 5000
        protocol        = "tcp"
        security_groups = ["${aws_elb.acme.source_security_group_id}"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
```

`instances.tf`

```tf
resource "aws_instance" "frontend" {
    count                       = "${var.instance_count}"
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "${var.instance_size}"
    associate_public_ip_address = true
    key_name                    = "${var.key_name}"
    security_groups             = ["${aws_security_group.acme_instances.name}"]

    tags {
        Name = "${var.prefix}-acme-${count.index}"
    }
}

resource "aws_elb_attachment" "frontend" {
    count    = "${var.instance_count}"
    elb      = "${aws_elb.acme.id}"
    instance = "${element(aws_instance.frontend.*.id, count.index)}"
}
```

Finally we will create an output to our module to expose the IPs and DNSs:

`output.tf`:

```tf
output "dns" {
    value = "${aws_elb.acme.dns_name}"
}

output "ips" {
    value = "${aws_instance.frontend.*.public_ip}"
}
```

**3\. Plan and execute**

Now we will use this litle module inside our project, for that we will create a `aws-instances.tf` file with the following
content in the `src` folder that is calling our own module:

```tf
module "project1_instances" {
    source            = "./modules/aws/ubuntu-vms-with-lb"
    prefix            = "project1"
    instance_count    = 2
    instance_size     = "t2.micro"
    key_name          = "${aws_key_pair.acme.key_name}"
}

module "project2_instances" {
    source            = "./modules/aws/ubuntu-vms-with-lb"
    prefix            = "project2"
    instance_count    = 1
    instance_size     = "t2.micro"
    key_name          = "${aws_key_pair.acme.key_name}"
}
```

We should also change the content of the `output.tf` file in our src folder:

```tf
output "project1_load_balancer_ips" {
    value = "${module.project1_instances.ips}"
}

output "project1_load_balancer_dns" {
    value = "${module.project1_instances.dns}"
}

output "project2_load_balancer_ips" {
    value = "${module.project2_instances.ips}"
}

output "project2_load_balancer_dns" {
    value = "${module.project2_instances.dns}"
}
```

**4\. Plan and execute**

Try running `terraform plan`.

You will see that terraform is complaining because it has not the `module project1_instances` module and is
suggesting you to runu init again, so, you will need to run `init` again:

```bash
terraform init -backend-config=terraform.tfvars
```

Now create a plan and execute it:

```bash
terraform plan -out=my.plan
terraform apply -auto-approve "my.plan"
```

---

Continue the workshop: [Step 5](https://github.com/artberri/101-terraform/tree/master/guide/aws/step-5.md).
