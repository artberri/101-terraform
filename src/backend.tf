terraform {
    backend "azurerm" {
        storage_account_name = "101terraformstates"
        container_name       = "plaintfstate"
        key                  = "prod.terraform.tfstate"
        resource_group_name  = "101-terraform-states"
    }
}
