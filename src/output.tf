output "frontend_id" {
    value = "${azurerm_subnet.my_subnet_frontend.id}"
}

output "backend_id" {
    value = "${azurerm_subnet.my_subnet_backend.id}"
}

output "dmz_id" {
    value = "${azurerm_subnet.my_subnet_dmz.id}"
}
