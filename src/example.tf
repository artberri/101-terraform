provider "azurerm" {
    subscription_id = "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX"
    client_id = "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX"
    client_secret = "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX"
    tenant_id = "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX"
}

resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-sample"
    location = "UK West"
}
