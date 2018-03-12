resource "azurerm_public_ip" "frontend" {
    name                         = "101-terraform-public-ip"
    location                     = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name          = "${azurerm_resource_group.terraform_sample.name}"
    public_ip_address_allocation = "static"
}

resource "azurerm_lb" "frontend" {
    name                = "101terraform-f-lb"
    location            = "${azurerm_resource_group.terraform_sample.location}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"

    frontend_ip_configuration {
        name                          = "default"
        public_ip_address_id          = "${azurerm_public_ip.frontend.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_lb_probe" "port80" {
    name                = "101terraform-f-lb-probe-80-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
}

resource "azurerm_lb_rule" "port80" {
    name                    = "101terraform-f-lb-rule-80-80"
    resource_group_name     = "${azurerm_resource_group.terraform_sample.name}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port80.id}"

    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_probe" "port443" {
    name                = "101terraform-f-lb-probe-443-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
    protocol            = "Http"
    request_path        = "/"
    port                = 443
}

resource "azurerm_lb_rule" "port443" {
    name                    = "101terraform-f-lb-rule-443-443"
    resource_group_name     = "${azurerm_resource_group.terraform_sample.name}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port443.id}"

    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_backend_address_pool" "frontend" {
    name                = "101terraform-f-lb-pool"
    resource_group_name = "${azurerm_resource_group.terraform_sample.name}"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
}
