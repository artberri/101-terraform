resource "aws_instance" "main" {
    ami                         = "${var.ami}"
    instance_type               = "${var.type}"
    associate_public_ip_address = true
    key_name                    = "acme"
    count                       = "${var.servers}"
    user_data                   = "${file("../scripts/${var.bootstrap_script}")}"
    security_groups             = ["${var.security_group}"]
}

resource "aws_elb_attachment" "main" {
    elb      = "${var.elb_id}"
    instance = "${aws_instance.main.*.id[count.index]}"
    # This will create 4 instances
    count = "${var.servers}"
}
