# Generate a random_id for the account name. Storage account names must be
# unique across the entire scope of Azure. Here we are generating a random hex
# value of length 8 (4*2) that is prefixed with the static string "101terraform". For
# example: "101terraform3d1b9d47".
resource "random_id" "storage_account" {
    prefix      = "101terraform"
    byte_length = "4"
}

resource "azurerm_storage_account" "frontend" {
    name                     = "${lower(random_id.storage_account.hex)}"
    resource_group_name      = "${azurerm_resource_group.terraform_sample.name}"
    location                 = "${azurerm_resource_group.terraform_sample.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
