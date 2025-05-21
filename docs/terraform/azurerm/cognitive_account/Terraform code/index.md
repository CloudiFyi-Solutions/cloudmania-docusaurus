---
sidebar_position: 1
---

# Terraform code

### Index

- [Example Usage](#example-usage)
- [Variables](#variables)
- [Resource](#resource)
- [Outputs](#outputs)

### Terraform

```terraform
terraform {
  required_providers {
    azurerm = ">= 4.0.0"
  }
}
```

### Example Usage

```terraform
module "azure-cognative-account" {
    source = "../"

    # name - (required) is a type of string
    name = string
    # resource_group_name - (required) is a type of string
    resource_group_name = string
    # sku_name - (required) is a type of string
    sku_name = string
    # location - (optional) is a type of string
    location = string
    # environment - (optional) is a type of string
    environment = string
    # sku_name - (required) is a type of string
    kind = string
    # dynamic_throttling_enabled - (optional) is a type of bool
    dynamic_throttling_enabled = bool
    # dynamic_throttling_enabled - (optional) is a type of list of strings
    fqdns = list(string)
    # local_auth_enabled - (optional) is a type of bool
    local_auth_enabled = bool
    # metrics_advisor_aad_client_id - (optional) is a type of string
    metrics_advisor_aad_client_id = string
    # metrics_advisor_aad_tenant_id - (optional) is a type of string
    metrics_advisor_aad_tenant_id = string
    # metrics_advisor_super_user_name - (optional) is a type of string
    metrics_advisor_super_user_name = string
    # metrics_advisor_website_name - (optional) is a type of string
    metrics_advisor_website_name = string

    # custom_subdomain_name - (optional) is a type of string
    custom_subdomain_name = string
    # network_acls - (optional) is a type of list of objects
    network_acls = list(object)
    # customer_managed_key - (optional) is a type of list of objects
    customer_managed_key = list(object)
    # identity - (optional) is a type of list of objects
    identity = list(object)
    # storage - (optional) is a type of list of objects
    storage = list(object)
    # outbound_network_access_restricted - (optional) is a type of bool
    outbound_network_access_restricted = bool
    # public_network_access_enabled - (optional) is a type of bool
    public_network_access_enabled = bool
    # qna_runtime_endpoint - (optional) is a type of string
    qna_runtime_endpoint = string
    # custom_question_answering_search_service_id - (optional) is a type of string
    custom_question_answering_search_service_id = string
    # custom_question_answering_search_service_key - (optional) is a type of string
    custom_question_answering_search_service_key = string

    # tags - (optional) is a type of map of strings
    tags = map(string)
}

```

[top](#index)

### Variables

```terraform
variable "name" {
  description = "(required)"
  type = string
}

variable "location" {
  description = "(optional)"
  type = string
  default = "westus"
}

variable "environment" {
  description = "(optional)"
  type = string
  default = "dev"
}

variable "resource_group_name" {
  description = "(required)"
  type = string
}

variable "kind" {
  description = "(required)"
  type = string
}

variable "sku_name" {
  description = "(required)"
  type = string
}

variable "local_auth_enabled" {
  description = "(optional)"
  type = bool
  default = true
}

variable "custom_subdomain_name" {
  description = "(optional)"
  type = string
  default = null
}

variable "dynamic_throttling_enabled" {
  description = "(optional)"
  type    = bool
  default = false
}

variable "fqdns" {
  description = "(optional)"
  type    = list(string)
  default = null
}

variable "metrics_advisor_aad_client_id" {
  description = "(optional)"
  type    = string
  default = null
}

variable "metrics_advisor_aad_tenant_id" {
  description = "(optional)"
  type    = string
  default = null
}

variable "metrics_advisor_super_user_name" {
  description = "(optional)"
  type    = string
  default = null
}

variable "metrics_advisor_website_name" {
  description = "(optional)"
  type    = string
  default = null
}

variable "network_acls" {
  description = "(optional)"
  type = list(object({
    bypass = optional(string)
    default_action = string
    ip_rules = optional(list(string))
    virtual_network_rules = optional(list(object({
      subnet_id = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })))
  }))

  default = null
}

variable "customer_managed_key" {
  description = "(optional)"
  type = list(object({
    key_vault_key_id = optional(string)
    identity_client_id = optional(string)
  }))

  default = null
}

variable "identity" {
  description = "(optional)"
  type = list(object({
    type = string
    identity_ids = optional(list(string))
  }))

  default = null
}

variable "storage" {
  description = "(optional)"
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default = null
}

variable "outbound_network_access_restricted" {
  description = "(optional)"
  type = bool
  default = false
}

variable "public_network_access_enabled" {
  description = "(optional)"
  type = bool
  default = true
}

variable "qna_runtime_endpoint" {
  description = "(optional)"
  type    = string
  default = null
}

variable "custom_question_answering_search_service_id" {
  description = "(optional)"
  type    = string
  default = null
}

variable "custom_question_answering_search_service_key" {
  description = "(optional)"
  type    = string
  default = null
}

variable "tags" {
  description = "(optional)"
  type = map(string)
  default = {}
}
```

[top](#index)

### Resource

```terraform
resource "azurerm_cognitive_account" "main" {
  name                = "${var.name}-${var.location}-${var.environment}-ca"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.kind

  sku_name = var.sku_name

  custom_subdomain_name      = var.network_acls != null ? var.custom_subdomain_name : null
  dynamic_throttling_enabled = var.dynamic_throttling_enabled

  fqdns              = var.fqdns
  local_auth_enabled = var.local_auth_enabled

  metrics_advisor_aad_client_id   = var.kind == "MetricsAdvisor" ? var.metrics_advisor_aad_client_id : null
  metrics_advisor_aad_tenant_id   = var.kind == "MetricsAdvisor" ? var.metrics_advisor_aad_tenant_id : null
  metrics_advisor_super_user_name = var.kind == "MetricsAdvisor" ? var.metrics_advisor_super_user_name : null
  metrics_advisor_website_name    = var.kind == "MatricsAdvisor" ? var.metrics_advisor_website_name : null

  outbound_network_access_restricted = var.outbound_network_access_restricted
  public_network_access_enabled      = var.public_network_access_enabled

  qna_runtime_endpoint = var.qna_runtime_endpoint

  custom_question_answering_search_service_id  = var.kind == "TextAnalytics" ? var.custom_question_answering_search_service_id : null
  custom_question_answering_search_service_key = var.kind == "TextAnalytics" ? var.custom_question_answering_search_service_key : null

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : var.customer_managed_key
    content {
      key_vault_key_id   = lookup(customer_managed_key.value, "key_vault_key_id")
      identity_client_id = lookup(customer_managed_key.value, "identity_client_id", null)
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : var.identity
    content {
      type         = lookup(identity.value, "type")
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : var.network_acls
    content {
      bypass         = var.kind == "OpenAI" ? lookup(network_acls.value, "bypass", null) : null
      default_action = lookup(network_acls.value, "default_action")
      ip_rules       = lookup(network_acls.value, "ip_rules", null)
      dynamic "virtual_network_rules" {
        for_each = lookup(network_acls.value, "virtual_network_rules", [])
        content {
          ignore_missing_vnet_service_endpoint = lookup(virtual_network_rules.value, "ignore_missing_vnet_service_endpoint", false)
          subnet_id                            = lookup(virtual_network_rules.value, "subnet_id")
        }
      }
    }
  }

  dynamic "storage" {
    for_each = var.storage == null ? [] : (var.kind == "OpenAI" ? [] : var.storage)
    content {
      storage_account_id = lookup(storage.value, "storage_account_id")
      identity_client_id = lookup(storage.value, "identity_client_id", null)
    }
  }


  tags = var.tags
}
```

[top](#index)

### Outputs

```terraform
output "id" {
  description = "returns a string"
  value = azurerm_cognitive_account.main.id
}

output "endpoint" {
  description = "returns a string"
  value = azurerm_cognitive_account.main.endpoint
}

output "identity" {
  description = "returns an object"
  value = azurerm_cognitive_account.main.identity
}
```

[top](#index)