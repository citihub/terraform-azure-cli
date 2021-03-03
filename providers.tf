###############################################################################
# 
# providers.tf
#   Terraform provider definitions
#
# REVISION HISTORY:
#   21 FEB 2021 des Created
# 
# (c) 2021 Citihub Ltd
###############################################################################
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 2.48.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "~> 1.4.0"
        }
        databricks = {
            source  = "databrickslabs/databricks"
            version = "~> 0.3.1"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.1.0"
        }
        null = {
            source = "hashicorp/null"
            version = "~> 3.1.0"
        }
        vault = {
            source = "hashicorp/vault"
            version = "~> 2.15.0"
        }
    }
}