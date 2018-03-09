variable "azurerm_subscription_id" {
    description = "The Azure subscription ID."
}

variable "azurerm_client_id" {
    description = "The Azure Service Principal app ID."
}

variable "azurerm_client_secret" {
    description = "The Azure Service Principal password."
}

variable "azurerm_tenant_id" {
    description = "The Azure Tenant ID."
}

variable "azurerm_region" {
    description = "The Azure region to create things in."
    default = "UK West"
}
