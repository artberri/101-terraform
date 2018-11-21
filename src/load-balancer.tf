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
