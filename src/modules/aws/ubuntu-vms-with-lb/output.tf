output "dns" {
    value = "${aws_elb.acme.dns_name}"
}

output "ips" {
    value = "${aws_instance.frontend.*.public_ip}"
}
