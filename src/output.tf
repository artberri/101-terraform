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
