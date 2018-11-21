output "project1_load_balancer_ips" {
    value = "${module.project1_instances.ips}"
}

output "project1_load_balancer_dns" {
    value = "${module.project1_instances.dns}"
}

output "project2_load_balancer_ips" {
    value = "${module.project2_instances.ips}"
}

output "project2_load_balancer_dns" {
    value = "${module.project2_instances.dns}"
}
