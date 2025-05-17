#!/bin/bash

set -e

BASE_DIR="Docusaurus-Cloudmania/cloudmania/docs"

# Array of "path::title"
paths=(
  "terraform/azurerm/function_app::Function App"
  "terraform/azurerm/resource_group::Resource Group"
  "github/teams::Teams"
)

for entry in "${paths[@]}"; do
  IFS="::" read -r path title <<< "$entry"
  full_path="$BASE_DIR/$path"

  mkdir -p "$full_path"

  cat <<EOF > "$full_path/index.md"
---
sidebar_position: 1
---

# $title
EOF

  echo "✅ Created: $full_path/index.md"
done
