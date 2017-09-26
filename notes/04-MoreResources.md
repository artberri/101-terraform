# Add More Resources

Go to:

```
git checkout step-3
```

## Steps

1\. Create key pair to access the machine

```
ssh-keygen -t rsa -b 4096 -C "terraform@acme"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_terraform_sample
cp /home/alberto/.ssh/id_terraform_sample.pub ../admin_ssh_key.pub
```

1\. We will change main.tf:

```
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

resource "aws_instance" "acme1" {
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    key_name                    = "acme"
}

resource "aws_elb_attachment" "acme1" {
  elb      = "${aws_elb.acme.id}"
  instance = "${aws_instance.acme1.id}"
}

resource "aws_instance" "acme2" {
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    key_name                    = "acme"
}

resource "aws_elb_attachment" "acme2" {
  elb      = "${aws_elb.acme.id}"
  instance = "${aws_instance.acme2.id}"
}

resource "aws_db_instance" "acme" {
  allocated_storage    = 5
  storage_type         = "standard"
  engine               = "mysql"
  engine_version       = "5.7.17"
  instance_class       = "db.t2.micro"
  name                 = "acme"
  username             = "acme"
  password             = "12345678"
  skip_final_snapshot  = true
}
```

And output.tf:

```
output "acme_dns" {
    value = "${aws_elb.acme.dns_name}"
}

output "acme1_ip" {
    value = "${aws_instance.acme1.public_ip}"
}

output "acme2_ip" {
    value = "${aws_instance.acme2.public_ip}"
}

output "acme_db_address" {
    value = "${aws_db_instance.acme.address}"
}
```

```
terraform plan
terraform apply
```

Explain:
https://www.terraform.io/docs/configuration/interpolation.html
