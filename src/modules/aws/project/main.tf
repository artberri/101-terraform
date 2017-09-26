resource "aws_s3_bucket" "main" {
    bucket = "acme-${var.subdomain}-101-images"
    acl    = "public-read"
}

# Create a new load balancer
resource "aws_elb" "main" {
  name               = "${var.subdomain}-elb"
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
    command = "echo ${self.dns_name} >> ~/adme_address.txt"
  }
}

resource "aws_security_group" "main" {
  name        = "acme_sg_${var.subdomain}"
  description = "Allow load balancer traffic and outbound"

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = ["${aws_elb.main.source_security_group_id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

module "instances" {
  source           = "../instance"
  servers          = "${var.servers}"
  elb_id           = "${aws_elb.main.id}"
  ami              = "${var.instance_ami}"
  type             = "${var.instance_type}"
  bootstrap_script = "${file("${path.module}/../../../../scripts/${var.bootstrap_script}")}"
  security_group   = "${aws_security_group.main.name}"
}
