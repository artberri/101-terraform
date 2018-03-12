variable "arm_subscription_id" {
    description = "The Azure subscription ID."
}

variable "arm_client_id" {
    description = "The Azure Service Principal app ID."
}

variable "arm_client_secret" {
    description = "The Azure Service Principal password."
}

variable "arm_tenant_id" {
    description = "The Azure Tenant ID."
}

variable "arm_region" {
    description = "The Azure region to create things in."
    default = "West Europe"
}

variable "arm_vm_admin_password" {
    description = "Passwords for the root user in VMs."
    default = "SUper.123-" # This should be hidden and passed as variable, doing this just for training purpose
}

variable "arm_frontend_instances" {
    description = "Number of front instances"
    default = 2
}
