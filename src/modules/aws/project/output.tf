output "dns" {
    value = "${aws_elb.main.dns_name}"
}

output "ips" {
    value = "${module.instances.ips}"
}
