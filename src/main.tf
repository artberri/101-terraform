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
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
}

module "acme_instances" {
  source  = "./modules/aws/instance"
  servers = 2
  elb_id  = "${aws_elb.acme.id}"
  ami     = "${var.acme_instance_ami}"
  type    = "${var.acme_instance_type}"
}

resource "aws_db_instance" "acme" {
  allocated_storage    = 5
  storage_type         = "standard"
  engine               = "mysql"
  engine_version       = "5.7.17"
  instance_class       = "${var.acme_db_type}"
  name                 = "acme"
  username             = "acme"
  password             = "12345678"
}
