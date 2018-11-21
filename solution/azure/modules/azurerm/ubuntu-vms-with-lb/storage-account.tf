resource "random_id" "storage_account" {
    prefix      = "${var.prefix}"
    byte_length = "4"
}

resource "azurerm_storage_account" "frontend" {
    name                     = "${lower(random_id.storage_account.hex)}"
    resource_group_name      = "${var.resource_group}"
    location                 = "${var.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
