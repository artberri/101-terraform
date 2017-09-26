# AcmeCo admin key
resource "aws_key_pair" "acme" {
    key_name   = "acme"
    public_key = "${file("../admin_ssh_key.pub")}"
}

resource "aws_s3_bucket" "acme" {
    bucket = "acme-terraform-101-images"
    acl    = "public-read"
}

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
