output "load_balancer_ip" {
    value = "${azurerm_public_ip.frontend.ip_address}"
}
