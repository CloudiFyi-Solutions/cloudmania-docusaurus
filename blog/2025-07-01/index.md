---
slug: gcp-to-azure-devops-wif
title: Azure to GCP connection
authors: [skhan]
tags: [azure, devops, automation, gcp, federated-identity, google-cloud]
---

# GCP to Azure DevOps Workload Identity Federation Setup

This guide walks through how to configure **Workload Identity Federation (WIF)** from **Azure DevOps to Google Cloud (GCP)**.

---

## High-Level Steps:

1. Create Azure DevOps Service Connection with Federated Identity
2. Create a Workload Identity Pool and Provider on GCP
3. Create a Google Cloud Service Account
4. Grant Roles to the Workload Identity Pool Principal
5. Configure Azure Pipeline to Use WIF

---

## Step 1: Create Azure DevOps Service Connection with Federated Identity

- Go to your **Azure DevOps Project** ➝ `Project Settings` ➝ `Service Connections`
- Click **New Service Connection** ➝ Choose **Azure Resource Manager**
- Select **Workload Identity Federation**

Fill in the required details:
- **Tenant ID**
- **Client ID** of your Azure App Registration (or Managed Identity)
- Select the appropriate **Subscription**

Save the connection.  
This creates the federated credential on the Azure side and exposes the **OIDC issuer URL** (e.g., `https://vstoken.actions.githubusercontent.com/<...>`)

**Subject Format:**
```
sc://<org>/<project>
```
or
```
repo:<org>/<repo>:ref:refs/heads/<branch>
```

---

## Step 2: Create Workload Identity Pool and Provider on GCP

> You can do this via `gcloud` CLI, the GUI, or using Terraform.

### Using `gcloud` CLI

```bash
gcloud iam workload-identity-pools create azuredevopspool \
  --location="global" \
  --display-name="Azure-DevOps-Pool"

gcloud iam workload-identity-pools providers create-oidc azureprovider \
  --location="global" \
  --workload-identity-pool="azuredevopspool" \
  --display-name="Azure-DevOps-Provider" \
  --issuer-uri="<issuer URL from Azure DevOps>" \
  --attribute-mapping="insert attribute mapping here"
```

### Using Terraform

```hcl
resource "google_iam_workload_identity_pool" "pool" {
  project = var.project_id
  workload_identity_pool_id = "azure-devops-wif-pool"
  display_name              = "azure-devops-wif-pool"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "azure_devops_organization" {
  project = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "ado-${lower(var.azure_devops_organization_name)}"
  display_name                       = "ado/${var.azure_devops_organization_name}"
  disabled                           = false

  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.org"  = "assertion.sub.extract('sc://{organization}/')"
    "attribute.proj" = "assertion.sub.extract('sc://{organization}/') + '/' + (assertion.sub.extract('sc://{conn}')).split('/', 3)[1]"
    "attribute.conn" = "assertion.sub.extract('sc://{conn}')"
  }

  oidc {
    issuer_uri = "https://vstoken.dev.azure.com/${var.azure_devops_organization_id}"
    allowed_audiences = [
      "api://AzureADTokenExchange"
    ]
  }
}
```

---

## Step 3: Create Google Cloud Service Account

### Using `gcloud` CLI

```bash
gcloud iam service-accounts create azuredevsc
```

### Using Terraform

```hcl
resource "google_service_account" "azure_devops_project" {
  project      = var.project_id
  account_id   = "ado-${lower(var.azure_devops_project_name)}"
  display_name = "ado/${var.azure_devops_organization_name}/${var.azure_devops_project_name}"
}
```

---

## Step 4: Grant IAM Roles to the Service Account

### Using `gcloud` CLI

```bash
gcloud iam service-accounts add-iam-policy-binding azuredevsc@<project-id>.iam.gserviceaccount.com \
  --project=<project-id> \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/<project-number>/locations/global/workloadIdentityPools/azuredevopspool/attribute.proj/<your-devops-org>/<your-devops-project>"
```

### Using Terraform

```hcl
resource "google_service_account_iam_member" "azure_devops_project_workload_identity_user_azure_devops_organization" {
  service_account_id = google_service_account.azure_devops_project.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.proj/${var.azure_devops_organization_name}/${var.azure_devops_project_name}"
}

resource "google_project_iam_member" "azure_devops_project_project_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.azure_devops_project.email}"
}
```

---

## Step 5: Configure Azure DevOps Pipeline

Now that all permissions and credentials are in place, configure your Azure Pipeline to use the federated identity to authenticate with GCP.

Here's an example of how to test that the connection is working:

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
- name: Azure.WorkloadIdentity.Connection
  value: your-service-connection
- name: GoogleCloud.WorkloadIdentity.ProjectNumber
  value: gcp-project-number
- name: GoogleCloud.WorkloadIdentity.Pool
  value: your-workload-identity-pool
- name: GoogleCloud.WorkloadIdentity.Provider
  value: your-workload-identity-provider
- name: GoogleCloud.WorkloadIdentity.ServiceAccount
  value: your-service-account@gcp-project-name.iam.gserviceaccount.com
- name: GOOGLE_APPLICATION_CREDENTIALS
  value: $(Pipeline.Workspace)/.workload_identity.wlconfig


steps:
  - task: AzureCLI@2
    inputs:
      connectedServiceNameARM: $(Azure.WorkloadIdentity.Connection)
      addSpnToEnvironment: true
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        echo $idToken > $(Pipeline.Workspace)/.workload_identity.jwt
        cat << EOF > $GOOGLE_APPLICATION_CREDENTIALS
        {
          "type": "external_account",
          "audience": "//iam.googleapis.com/projects/$(GoogleCloud.WorkloadIdentity.ProjectNumber)/locations/global/workloadIdentityPools/$(GoogleCloud.WorkloadIdentity.Pool)/providers/$(GoogleCloud.WorkloadIdentity.Provider)",
          "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
          "token_url": "https://sts.googleapis.com/v1/token",
          "credential_source": {
            "file": "$(Pipeline.Workspace)/.workload_identity.jwt"
          },
          "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$(GoogleCloud.WorkloadIdentity.ServiceAccount):generateAccessToken"
        }
        EOF

  - script: |
      echo "Activating Google Cloud auth using external credentials..."
      gcloud auth login --cred-file="$(GOOGLE_APPLICATION_CREDENTIALS)"

      gcloud config set project $(GoogleCloud.WorkloadIdentity.ProjectNumber)
      
      echo "Verifying authentication by listing current authenticated account:"
      gcloud auth list

      echo "Validating GCP authentication by fetching IAM policy for the project:"
      gcloud projects get-iam-policy $(GoogleCloud.WorkloadIdentity.ProjectNumber) 
    displayName: 'Validate GCP Authentication'

```

---