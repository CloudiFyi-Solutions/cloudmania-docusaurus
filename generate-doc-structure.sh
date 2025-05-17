#!/bin/bash

set -e

BASE_DIR="docs"

# Array of "path::title"
paths=(
  "terraform/azurerm/function_app:Function App"
  "terraform/azurerm/resource_group:Resource Group"
  "terraform/azurerm/storage_account:Storage Account"
  "terraform/azurerm/key_vault:Key Vault"
  "terraform/azurerm/key_vault_secret:Key Vault Secret"
  "terraform/azurerm/key_vault_access_policy:Key Vault Access Policy"
  "terraform/azurerm/key_vault_certificate:Key Vault Certificate"
  "terraform/azurerm/key_vault_key:Key Vault Key"
  "terraform/azurerm/app_service:App Service"
  "terraform/azurerm/app_service_plan:App Service Plan"
  "terraform/azurerm/sql_server:SQL Server"
  "terraform/azurerm/sql_database:SQL Database"
  "terraform/github/teams:Teams"
  "terraform/github/repository:Repository"
  "terraform/github/organization:Organization"
  "terraform/github/branch_protection:Branch Protection"
  "terraform/github/branch_protection_rule:Branch Protection Rule"
  
)
for entry in "${paths[@]}"; do
  IFS="::" read -r path title <<< "$entry"
  full_path="$BASE_DIR/$path"
  file_path="$full_path/index.md"

  if [[ -f "$file_path" ]]; then
    echo "⏩ Skipped (already exists): $file_path"
    continue
  fi

  mkdir -p "$full_path"

  cat <<EOF > "$file_path"
---
sidebar_position: 1
---

# $title
EOF

  echo "✅ Created: $file_path"
done