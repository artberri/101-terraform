output "acme_dns" {
    value = "${module.main_project.dns}"
}

output "acme_ips" {
    value = "${module.main_project.ips}"
}
