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
