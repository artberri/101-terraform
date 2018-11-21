resource "aws_instance" "frontend" {
    count                       = "${var.instance_count}"
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "${var.instance_size}"
    associate_public_ip_address = true
    key_name                    = "${var.key_name}"

    tags {
        Name = "${var.prefix}-acme-${count.index}"
    }
}

resource "aws_elb_attachment" "frontend" {
    count    = "${var.instance_count}"
    elb      = "${aws_elb.acme.id}"
    instance = "${element(aws_instance.frontend.*.id, count.index)}"
}
