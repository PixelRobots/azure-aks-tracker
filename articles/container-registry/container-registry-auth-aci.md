---
layout: Conceptual
title: Access Registry Images from ACI - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auth-aci
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to provide access to images in your container registry from Azure Container Instances by using a Microsoft Entra service principal.
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 622be52c-4745-7122-700e-38a64223a698
document_version_independent_id: 380df4f6-f71c-1fdd-0747-cbbcb5d45de7
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-auth-aci.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/container-registry-auth-aci
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-auth-aci.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/dcc344b3-3794-4849-9766-7ea55b09218c
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/54120bfe-7774-429b-9674-ff285a2c9445
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: 5ae3b3c5-8d7e-d66c-7535-f44cf8d9d985
---

# Access Registry Images from ACI - Azure Container Registry | Microsoft Learn

You can use a Microsoft Entra service principal to provide access to your container registries in Azure Container Registry.

In this article, you learn to create and configure a Microsoft Entra service principal with *pull* permissions to your registry. Then, you start a container in Azure Container Instances (ACI) that pulls its image from your registry, using the service principal for authentication.

## When to use a service principal

You should use a service principal for authentication from ACI in **headless scenarios**, such as in applications or services that create container instances in an automated or otherwise unattended manner.

For example, if you have an automated script that runs nightly and creates a [task-based container instance](/en-us/azure/container-instances/container-instances-restart-policy) to process some data, it can use a service principal with pull-only permissions to authenticate to the registry. You can then rotate the service principal's credentials or revoke its access completely without affecting other services and applications.

Service principals should also be used when the registry [admin user](container-registry-authentication#admin-account) is disabled.

## Create a service principal

To create a service principal with access to your container registry, run the following script in the [Azure Cloud Shell](/en-us/azure/cloud-shell/overview) or a local installation of the [Azure CLI](/en-us/cli/azure/install-azure-cli). The script is formatted for the Bash shell.

Before running the script, update the `ACR_NAME` variable with the name of your container registry. The `SERVICE_PRINCIPAL_NAME` value must be unique within your Microsoft Entra tenant. If you receive an "`'http://acr-service-principal' already exists.`" error, specify a different name for the service principal.

You can optionally modify the `--role` value in the [az ad sp create-for-rbac](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command to grant different permissions. For a complete list of roles, see [Azure Container Registry Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview).

After you run the script, take note of the service principal's **ID** and **password**. Once you have its credentials, you can configure your applications and services to authenticate to your container registry as the service principal.

```azurecli
#!/bin/bash
# This script requires Azure CLI version 2.25.0 or later. Check version with `az --version`.

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_NAME=$servicePrincipal

# Obtain the full registry ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
# echo $registryId

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"
```

### Use an existing service principal

To grant registry access to an existing service principal, you must assign a new role to the service principal. As with creating a new service principal, you must perform role assignments to grant permissions to the service principal. See [Azure Container Registry Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview).

The following script uses the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to grant pull permissions to a service principal you specify in the `SERVICE_PRINCIPAL_ID` variable. Adjust the `--role` value if you'd like to grant a different level of access.

```azurecli
#!/bin/bash
# Modify for your environment. The ACR_NAME is the name of your Azure Container
# Registry, and the SERVICE_PRINCIPAL_ID is the service principal's 'appId' or
# one of its 'servicePrincipalNames' values.
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_ID=$servicePrincipal

# Populate value required for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

# Assign the desired role to the service principal. Modify the '--role' argument
# value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role acrpull
```

## Authenticate using the service principal

To launch a container in Azure Container Instances using a service principal, specify its ID for `--registry-username`, and its password for `--registry-password`.

```azurecli
az container create \
    --resource-group myResourceGroup \
    --name mycontainer \
    --image mycontainerregistry.azurecr.io/myimage:v1 \
    --registry-login-server mycontainerregistry.azurecr.io \
    --registry-username <service-principal-ID> \
    --registry-password <service-principal-password>
```

Note

We recommend running the commands in the most recent version of the Azure Cloud Shell. Set `export MSYS_NO_PATHCONV=1` for running on-perm bash environment.

## Sample scripts

You can find the preceding sample scripts for Azure CLI on GitHub, as well versions for Azure PowerShell:

- [Azure CLI](https://github.com/Azure/azure-docs-cli-python-samples/tree/master/container-registry/create-registry/create-registry-service-principal-assign-role.sh)
- [Azure PowerShell](https://github.com/Azure/azure-docs-powershell-samples/tree/master/container-registry)