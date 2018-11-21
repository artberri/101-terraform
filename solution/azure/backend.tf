terraform {
    backend "azurerm" {
        storage_account_name = "101terraformstates" # Use your own unique name here
        container_name       = "plaintfstate" # Use your own container name here
        key                  = "prod.terraform.tfstate" # Add a name to the state file
        resource_group_name  = "101-terraform-states" # Use your own container name here
    }
}
