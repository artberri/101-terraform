# Provisioners

Go to:

```
git checkout step-5
```

## Steps

1\. Multiple provider types

https://www.terraform.io/intro/getting-started/provision.html

Image-based infrastructure (ie Packer).

2\. Provisioning our images

https://stackoverflow.com/questions/44378064/terraform-should-i-use-user-data-or-provisioner-to-bootstrap-a-resource

Create scripts/sample.sh file with:

```
#!/bin/bash
export HOME=/root
apt-get update
apt-get upgrade -y
apt-get install -y wget curl build-essential libssl-dev git unattended-upgrades
cd /root
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 6.11.3
npm install pm2 -g
git clone https://github.com/heroku/node-js-sample.git
cd node-js-sample
npm install
pm2 start index.js
```

Add the following inputs to the instance module:

```
variable "bootstrap_script" {}

variable "security_group" {}
```

Add the following parameters to the instance module main file:

```
    user_data                   = "${file("../scripts/${var.bootstrap_script}")}"
    security_groups             = ["${var.security_group}"]
```

Change the main terraform file to include real load balancer with security groups and change port

```
# Create a new load balancer
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

  provisioner "local-exec" {
    command = "echo ${self.dns_name} > ~/adme_address.txt"
  }
}

resource "aws_security_group" "acme_instances" {
  name        = "acme_instances"
  description = "Allow load balancer traffic and outbound"

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

module "acme_instances" {
  source           = "./modules/aws/instance"
  servers          = 1
  elb_id           = "${aws_elb.acme.id}"
  ami              = "${var.acme_instance_ami}"
  type             = "${var.acme_instance_type}"
  bootstrap_script = "sample.sh"
  security_group   = "${aws_security_group.acme_instances.name}"
}
```

Run

```
terraform get
terraform plan
terraform apply
```
