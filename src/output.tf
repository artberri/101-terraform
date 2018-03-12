output "project1_load_balancer_ip" {
    value = "${module.project1_instances.load_balancer_ip}"
}

output "project2_load_balancer_ip" {
    value = "${module.project2_instances.load_balancer_ip}"
}
