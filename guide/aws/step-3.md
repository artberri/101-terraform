# Step 3 - More Resources

If you were not able to follow the workshop until here, you can continue from this step by executing:

```bash
git checkout aws-step-3
```

## Steps

We will add more resources. Check the official documentation to see all available resources:
[https://www.terraform.io/docs/providers/aws/](https://www.terraform.io/docs/providers/aws/)

As an example we will spin up 2 machines under a load balancer.

**1\. First, we will create some variables that we will use later**

Add the following to the `variables.tf` file:

```tf
variable "ssh_pubkey_path" {
    description = "Path to the ssh pub key"
    default = "files/admin_ssh_key.pub"
}

variable "instance_count" {
    description = "Number of instances"
    default = 2
}
```

Create a pair key first if you don't have any:

```bash
ssh-keygen -t rsa -b 4096 -C "terraform@acme"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_terraform_sample
mkdir files
cp /home/yourname/.ssh/id_terraform_sample.pub files/admin_ssh_key.pub
```

**2\. Next, we will create the key pair**

Create a `key-pair.tf` file with the following content:

```tf
resource "aws_key_pair" "acme" {
    key_name   = "acme"
    public_key = "${file(var.ssh_pubkey_path)}"
}
```

Plan and execute, you already know how to do this ;)

**3\. Load Balancer**

Create a `load-balancer.tf` file with the following content:

```tf
resource "aws_elb" "acme" {
    name               = "acme-elb"
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

**4\. We'll create a security group**

Create a `security-group.tf` file with the following content:

```tf
resource "aws_security_group" "acme_instances" {
    name        = "acme_instances"
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

**4\. Finally we will define the instances**

Replace the `instances.tf` file with the following content:

```tf
resource "aws_instance" "frontend" {
    count                       = "${var.instance_count}"
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    key_name                    = "acme"

    tags {
        Name = "acme-${count.index}"
    }
}

resource "aws_elb_attachment" "frontend" {
    count    = "${var.instance_count}"
    elb      = "${aws_elb.acme.id}"
    instance = "${element(aws_instance.frontend.*.id, count.index)}"
}
```

**5\. We should output the Load balancer IP in order to be able to point our A/CNAME record to it**

Delete the other outputs from the `outputs.tf` file and add the following:

```tf
output "acme_dns" {
    value = "${aws_elb.acme.dns_name}"
}

output "acme_ips" {
    value = "${aws_instance.frontend.*.public_ip}"
}
```

**6\. Plan and execute**

Now create a plan and execute it:

```bash
terraform plan -out=my.plan
terraform apply -auto-approve "my.plan"
```

---

Continue the workshop: [Step 4](https://github.com/artberri/101-terraform/tree/master/guide/aws/step-4.md).
