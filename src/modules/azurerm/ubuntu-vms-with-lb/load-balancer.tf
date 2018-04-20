resource "azurerm_public_ip" "frontend" {
    name                         = "${var.prefix}-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.resource_group}"
    public_ip_address_allocation = "static"
}

resource "azurerm_lb" "frontend" {
    name                = "${var.prefix}-f-lb"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group}"

    frontend_ip_configuration {
        name                          = "default"
        public_ip_address_id          = "${azurerm_public_ip.frontend.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_lb_probe" "port80" {
    name                = "${var.prefix}-f-lb-probe-80-up"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
    resource_group_name = "${var.resource_group}"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
}

resource "azurerm_lb_rule" "port80" {
    name                    = "${var.prefix}-f-lb-rule-80-80"
    resource_group_name     = "${var.resource_group}"
    loadbalancer_id         = "${azurerm_lb.frontend.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.frontend.id}"
    probe_id                = "${azurerm_lb_probe.port80.id}"

    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 5000
    frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_backend_address_pool" "frontend" {
    name                = "${var.prefix}-f-lb-pool"
    resource_group_name = "${var.resource_group}"
    loadbalancer_id     = "${azurerm_lb.frontend.id}"
}
