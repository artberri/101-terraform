# Generate a random_id for the account name. Storage account names must be
# unique across the entire scope of Azure. Here we are generating a random hex
# value of length 8 (4*2) that is prefixed with the static string "demo". For
# example: "demo3d1b9d47".
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
