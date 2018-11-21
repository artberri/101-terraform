output "acme_dns" {
    value = "${aws_elb.acme.dns_name}"
}

output "acme_ips" {
    value = "${aws_instance.frontend.*.public_ip}"
}
