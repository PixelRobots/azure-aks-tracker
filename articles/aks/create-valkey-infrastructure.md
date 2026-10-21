---
layout: Conceptual
title: Create the Infrastructure for Running a Valkey Cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/create-valkey-infrastructure
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: In this article, you create the infrastructure for running a Valkey cluster on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2025-09-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
zone_pivot_groups: azure-cli-or-terraform
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: 305a0473-2fc0-5ea6-8d46-a86b23e50ab1
document_version_independent_id: 37f08981-6fcf-91d0-94c4-8e7f06c2f529
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/create-valkey-infrastructure.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/create-valkey-infrastructure
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/create-valkey-infrastructure.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
platformId: 2542ff46-f0d9-3974-cca3-3a61cdc2bf8c
---

# Create the Infrastructure for Running a Valkey Cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This guide walks through the complete setup process for running a Valkey cluster on AKS. This process includes configuring environment variables, provisioning core Azure resources (such as a resource group, Azure Key Vault, and Azure Container Registry (ACR)), creating an AKS cluster with integrated workload identity and managing secrets. It also covers the creation of a dedicated node pool for Valkey workloads and how to import Valkey images into your private registry. If you prefer infrastructure-as-code, the guide includes an alternative deployment path using Terraform with Azure Verified Modules, ensuring best practices and production readiness.

::: zone pivot="terraform"

To deploy the infrastructure using Terraform, we use the [Azure Verified Module](https://azure.github.io/Azure-Verified-Modules/)[for AKS](https://github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster.git).

Note

If you're planning to run this deployment in production, we recommend looking at [AKS production pattern module for Azure Verified Modules](https://github.com/Azure/terraform-azurerm-avm-ptn-aks-production). This module comes coupled with best practice recommendations.

::: zone-end

## Prerequisites

- If you haven't already, review the [Overview for deploying a Valkey cluster on Azure Kubernetes Service (AKS)](valkey-overview).
- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.61.0. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Helm version 3 or later. To install, see [Installing Helm](https://helm.sh/docs/intro/install/).
- `kubectl`, which the Azure Cloud Shell installs by default.
- Docker installed on your local machine. To install, see [Get Docker](https://docs.docker.com/get-docker/).

::: zone pivot="azure-cli"

## Set environment variables

- Set the required environment variables for use throughout this guide:

    ```bash
    random=$(echo $RANDOM | tr '[0-9]' '[a-z]')
    export MY_RESOURCE_GROUP_NAME=myResourceGroup-rg-$(echo $random)
    export MY_LOCATION=centralus
    export MY_ACR_REGISTRY=mydns$(echo $random)
    export MY_KEYVAULT_NAME=vault-$(echo $random)-kv
    export MY_CLUSTER_NAME=cluster-aks
    ```

## Create a resource group

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $MY_RESOURCE_GROUP_NAME --location $MY_LOCATION --output table
    ```

    Example output:

    ```output
    Location    Name
    ----------  ------------------
    eastus      myResourceGroup-rg
    ```

## Create an Azure Key Vault instance

- Create an Azure Key Vault instance using the [`az keyvault create`](/en-us/cli/azure/keyvault#az-keyvault-create)command. Azure Key Vault securely stores and accessing secrets such as API keys, passwords, certificates, or cryptographic keys.

    ```azurecli
    az keyvault create --name $MY_KEYVAULT_NAME --resource-group $MY_RESOURCE_GROUP_NAME --location $MY_LOCATION --enable-rbac-authorization false --output table
    ```

    Example output:

    ```output
    Location    Name            ResourceGroup
    ----------  --------------  ------------------
    eastus      vault-bbbhe-kv  myResourceGroup-rg
    ```

## Create an Azure Container Registry

- Create an Azure Container Registry to store and manage your container images using the [`az acr create`](/en-us/cli/azure/acr#az-acr-create) command.

    ```azurecli
    az acr create \
      --name ${MY_ACR_REGISTRY} \
      --resource-group $MY_RESOURCE_GROUP_NAME \
      --sku Premium \
      --location $MY_LOCATION \
      --admin-enabled true \
      --output table
    export MY_ACR_REGISTRY_ID=$(az acr show --name $MY_ACR_REGISTRY --resource-group $MY_RESOURCE_GROUP_NAME --query id --output tsv)
    ```

    Example output:

    ```output
    NAME                  RESOURCE GROUP      LOCATION    SKU      LOGIN SERVER                     CREATION DATE         ADMIN ENABLED
    --------------------  ------------------  ----------  -------  -------------------------------  --------------------  ---------------
    mydnsrandomnamebbbhe  myResourceGroup-rg  eastus      Premium  mydnsrandomnamebbbhe.azurecr.io  2024-06-11T09:36:43Z  True
    ```

## Create an AKS cluster

In this step, we create an AKS cluster. We enable the [Azure Key Vault Secrets provider add-on](csi-secrets-store-driver) (`azure-keyvault-secrets-provider`), which allows the AKS cluster to access secrets stored in Azure Key Vault. We also enable [workload identity](workload-identity-overview), which allows the AKS cluster to access other Azure resources securely.

- Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    az aks create \
     --location $MY_LOCATION \
     --name $MY_CLUSTER_NAME \
     --tier standard \
     --resource-group $MY_RESOURCE_GROUP_NAME \
     --network-plugin azure  \
     --node-vm-size Standard_D4_v3 \
     --node-count 3 \
     --auto-upgrade-channel stable \
     --node-os-upgrade-channel  NodeImage \
     --attach-acr ${MY_ACR_REGISTRY} \
     --enable-oidc-issuer \
     --enable-workload-identity \
     --enable-addons azure-keyvault-secrets-provider \
     --zones 1 2 3 \
     --generate-ssh-keys \
     --output table
    ```

    Example output:

    ```output
    Kind    KubernetesVersion    Location    MaxAgentPools    Name         NodeResourceGroup                         ProvisioningState    ResourceGroup       ResourceUid               SupportPlan
    -----------------------------------------------------------------------  --------------------------  ----------------------  ----------------------------------  ------------------------------------  -------------------------  ------------  ----------------------------------------------------------------  ------  -------------------  ----------  ---------------  -----------  ----------------------------------------  -------------------  ------------------  ------------------------  ------------------
    cluster-ak-myresourcegroup--9b70ac-hhrizake.portal.hcp.eastus.azmk8s.io  1.28.9                      False                   cluster-ak-myResourceGroup--9b70ac  a0a0a0a0-bbbb-cccc-dddd-e1e1e1e1e1e1  False                      True          cluster-ak-myresourcegroup--9b70ac-hhrizake.hcp.eastus.azmk8s.io Base     1.28                 eastus      100              cluster-aks  MC_myResourceGroup-rg_cluster-aks_eastus  Succeeded            myResourceGroup-rg  b1b1b1b1-cccc-dddd-eeee-f2f2f2f2f2f2  KubernetesOfficial
    ```

## Get the identity ID and object ID for the Azure Key Vault Secrets provider

- Get the identity ID and the object ID created by the Azure Key Vault Secrets provider add-on using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    export userAssignedIdentityID=$(az aks show --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId --output tsv)
    export userAssignedObjectID=$(az aks show --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId --output tsv)
    ```

## Assign the `AcrPull` role to the kubelet identity

- Assign the `AcrPull` role to the kubelet identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    export KUBELET_IDENTITY=$(az aks show --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --output tsv --query identityProfile.kubeletidentity.objectId)
    az role assignment create \
      --assignee ${KUBELET_IDENTITY} \
      --role "AcrPull" \
      --scope ${MY_ACR_REGISTRY_ID} \
      --output table
    ```

    Example output:

    ```output
    CreatedBy                             CreatedOn                         Name                                  PrincipalId                           PrincipalName                         PrincipalType     ResourceGroup       RoleDefinitionId                                                                                                                            RoleDefinitionName    Scope                                                                                                                                                        UpdatedBy                             UpdatedOn
    ------------------------------------  --------------------------------  ------------------------------------  ------------------------------------  ------------------------------------  ----------------  ------------------  ------------------------------------------------------------------------------------------------------------------------------------------  --------------------  -----------------------------------------------------------------------------------------------------------------------------------------------------------  ------------------------------------  --------------------------------
    bbbb1b1b-cc2c-dd3d-ee4e-ffffff5f5f5f  2024-06-11T09:41:36.631310+00:00  00aa00aa-bb11-cc22-dd33-44ee44ee44ee  aaaaaaaa-bbbb-cccc-1111-222222222222  bbbbbbbb-cccc-dddd-2222-333333333333  ServicePrincipal  myResourceGroup-rg  /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/providers/Microsoft.Authorization/roleDefinitions/aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb  AcrPull               /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myResourceGroup-rg/providers/Microsoft.ContainerRegistry/registries/mydnsrandomnamebbbhe  bbbb1b1b-cc2c-dd3d-ee4e-ffffff5f5f5f  2024-06-11T09:41:36.631310+00:00
    ```

## Create a node pool for the Valkey workload

In this section, we create a node pool dedicated to running the Valkey workload. This node pool has autoscaling disabled and is created with six nodes across two availability zones, because we want to have one secondary per primary in a different zone. The replicas are scheduled in the third zone.

- Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

    ```azurecli
    while [ "$(az aks show --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --output tsv --query provisioningState)" != "Succeeded" ]; do echo "waiting for cluster to be ready"; sleep 10; done
    
    az aks nodepool add \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --cluster-name  $MY_CLUSTER_NAME \
        --name valkey \
        --node-vm-size Standard_D4_v3 \
        --node-count 6 \
        --zones 1 2 3 \
        --output table
    ```

    Example output:

    ```output
    Count    CurrentOrchestratorVersion    ETag                                  EnableAutoScaling    EnableCustomCaTrust    EnableEncryptionAtHost    EnableFips    EnableNodePublicIp    EnableUltraSsd    KubeletDiskType    MaxPods    Mode    Name    NodeImageVersion                          OrchestratorVersion    OsDiskSizeGb    OsDiskType    OsSku    OsType    ProvisioningState    ResourceGroup       ScaleDownMode    TypePropertiesType       VmSize           WorkloadRuntime
    -------  ----------------------------  ------------------------------------  -------------------  ---------------------  ------------------------  ------------  --------------------  ----------------  -----------------  ---------  ------  ------  ----------------------------------------  ---------------------  --------------  ------------  -------  --------  -------------------  ------------------  ---------------  -----------------------  ---------------  -----------------
    6        1.28.9                        aaaa0000-bb11-2222-33cc-444444dddddd  False                False                  False                     False         False                 False             OS                 30         User    valkey  AKSUbuntu-2204gen2containerd-202405.27.0  1.28                   128             Managed       Ubuntu   Linux     Succeeded            myResourceGroup-rg  Delete           VirtualMachineScaleSets  Standard_D4s_v3  OCIContainer
    ```

## Upload Valkey images to your Azure Container Registry

In this section, we download the Valkey image from Docker Hub and upload it to Azure Container Registry. This step ensures that the image is available in your private registry and can be used in your AKS cluster. We don't recommend consuming the public image in a production environment.

- Import the Valkey image from Dockerhub and upload it to your Azure Container Registry using the [`az acr import`](/en-us/cli/azure/acr#az-acr-import) command.

    ```azurecli
    az acr import \
        --name $MY_ACR_REGISTRY \
        --source docker.io/valkey/valkey:latest  \
        --image valkey:latest \
        --output table
    ```

::: zone-end

::: zone pivot="terraform"

## Clone the Terraform module

- Clone the git repository with the Terraform module.

    ```bash
    git clone https://github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster.git
    cd terraform-azurerm-avm-res-containerservice-managedcluster/tree/stateful-workloads/examples/stateful-workloads-valkey
    ```

## Create a Terraform variables file

- Set Valkey variables by creating a `valkey.tfvars` file with the following contents. You can also provide your specific [variables](https://developer.hashicorp.com/terraform/language/values/variables) at this step:

    ```terraform
        acr_task_content = <<-EOF
        version: v1.1.0
        steps:
          - cmd: bash echo Waiting 10 seconds the propagation of the Container Registry Data Importer and Data Reader role
          - cmd: bash sleep 10
          - cmd: az login --identity
          - cmd: az acr import --name $RegistryName --source docker.io/valkey/valkey:latest --image valkey:latest
        EOF
    
        valkey_enabled = true
        node_pools = {
          valkey = {
            name       = "valkey"
            vm_size    = "Standard_DS4_v2"
            node_count = 3
            zones      = [1, 2, 3]
            os_type    = "Linux"
          }
        }
    ```

## Deploy the infrastructure

1. To deploy the infrastructure, run the Terraform commands. In this step, we set the required variables for deploying Valkey.

    ```bash
    terraform init
    export MY_RESOURCE_GROUP_NAME=myResourceGroup-rg
    export MY_LOCATION=centralus
    SECRET=$(openssl rand -base64 32)
    export TF_VAR_valkey_password=${SECRET}
    export TF_VAR_location=${MY_LOCATION}
    export TF_VAR_resource_group_name=${MY_RESOURCE_GROUP_NAME}
    terraform apply -var-file="valkey.tfvars"
    ```

    Note

    In some cases, the container registry tasks that import Valkey images to the container registry might fail. For more information, see [container-registry-task](/en-us/azure/container-registry/container-registry-faq#run-error-message-troubleshooting). In most cases, retrying resolves the problem.
2. Run the following command to export the Terraform output values as environment variables in the terminal to use them in the next steps:

    ```bash
    export MY_ACR_REGISTRY=$(terraform output -raw acr_registry_name)
    export MY_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
    ```

::: zone-end