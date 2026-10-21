---
layout: Conceptual
title: Create infrastructure for deploying Apache Airflow on AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/airflow-create-infrastructure
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Step-by-step guide to set up Apache Airflow on Azure Kubernetes Service (AKS) using Helm and configure identity and storage for production-ready deployments.
ms.topic: how-to
ms.date: 2025-07-14T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: 169bc1cb-615e-e897-341e-57c78cd8c017
document_version_independent_id: 44be501c-e35c-28ab-af08-fdab9ee89f00
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/airflow-create-infrastructure.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/airflow-create-infrastructure
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/airflow-create-infrastructure.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 256db8f2-8da5-1f4e-42ae-bb7725828d28
---

# Create infrastructure for deploying Apache Airflow on AKS - Azure Kubernetes Service | Microsoft Learn

In this article, you create the infrastructure resources needed to run Apache Airflow on Azure Kubernetes Service (AKS).

## Prerequisites

- If you haven't already, review the [Overview for deploying an Apache Airflow cluster on Azure Kubernetes Service (AKS)](airflow-overview).
- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.61.0. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Helm version 3 or later. To install, see [Installing Helm](https://helm.sh/docs/intro/install/).
- `kubectl`, which is installed in Azure Cloud Shell by default.
- GitHub Repo to store Airflow Dags.
- Docker installed on your local machine. To install, see [Get Docker](https://docs.docker.com/get-docker/).

## Set environment variables

- Set the required environment variables for use throughout this guide:

    ```bash
    random=$(echo $RANDOM | tr '[0-9]' '[a-z]')
    export MY_LOCATION=canadacentral
    export MY_RESOURCE_GROUP_NAME=apache-airflow-rg
    export MY_IDENTITY_NAME=airflow-identity-123
    export MY_ACR_REGISTRY=mydnsrandomname$(echo $random)
    export MY_KEYVAULT_NAME=airflow-vault-$(echo $random)-kv
    export MY_CLUSTER_NAME=apache-airflow-aks
    export SERVICE_ACCOUNT_NAME=airflow
    export SERVICE_ACCOUNT_NAMESPACE=airflow
    export AKS_AIRFLOW_NAMESPACE=airflow
    export AKS_AIRFLOW_CLUSTER_NAME=cluster-aks-airflow
    export AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME=airflowsasa$(echo $random)
    export AKS_AIRFLOW_LOGS_STORAGE_CONTAINER_NAME=airflow-logs
    export AKS_AIRFLOW_LOGS_STORAGE_SECRET_NAME=storage-account-credentials
    ```

## Create a resource group

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $MY_RESOURCE_GROUP_NAME --location $MY_LOCATION --output table
    ```

    Example output:

    ```output
    Location       Name
    -------------  -----------------
    $MY_LOCATION   $MY_RESOURCE_GROUP_NAME
    ```

## Create an identity to access secrets in Azure Key Vault

In this step, we create a user-assigned managed identity that the External Secrets Operator uses to access the Airflow passwords stored in Azure Key Vault.

- Create a user-assigned managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    az identity create --name $MY_IDENTITY_NAME --resource-group $MY_RESOURCE_GROUP_NAME --output table
    export MY_IDENTITY_NAME_ID=$(az identity show --name $MY_IDENTITY_NAME --resource-group $MY_RESOURCE_GROUP_NAME --query id --output tsv)
    export MY_IDENTITY_NAME_PRINCIPAL_ID=$(az identity show --name $MY_IDENTITY_NAME --resource-group $MY_RESOURCE_GROUP_NAME --query principalId --output tsv)
    export MY_IDENTITY_NAME_CLIENT_ID=$(az identity show --name $MY_IDENTITY_NAME --resource-group $MY_RESOURCE_GROUP_NAME --query clientId --output tsv)
    ```

    Example output:

    ```output
    ClientId                              Location       Name                  PrincipalId                           ResourceGroup            TenantId
    ------------------------------------  -------------  --------------------  ------------------------------------  -----------------------  ------------------------------------  
    00001111-aaaa-2222-bbbb-3333cccc4444  $MY_LOCATION   $MY_IDENTITY_NAME     aaaaaaaa-bbbb-cccc-1111-222222222222  $MY_RESOURCE_GROUP_NAME  aaaabbbb-0000-cccc-1111-dddd2222eeee 
    ```

## Create an Azure Key Vault instance

- Create an Azure Key Vault instance using the [`az keyvault create`](/en-us/cli/azure/keyvault#az-keyvault-create) command.

    ```azurecli
    az keyvault create --name $MY_KEYVAULT_NAME --resource-group $MY_RESOURCE_GROUP_NAME --location $MY_LOCATION --enable-rbac-authorization false --output table
    export KEYVAULTID=$(az keyvault show --name $MY_KEYVAULT_NAME --query "id" --output tsv)
    export KEYVAULTURL=$(az keyvault show --name $MY_KEYVAULT_NAME --query "properties.vaultUri" --output tsv)
    ```

    Example output:

    ```output
    Location       Name                  ResourceGroup
    -------------  --------------------  ----------------------
    $MY_LOCATION   $MY_KEYVAULT_NAME     $MY_RESOURCE_GROUP_NAME
    ```

## Create an Azure container registry

- Create an Azure container registry to store and manage your container images using the [`az acr create`](/en-us/cli/azure/acr#az-acr-create) command.

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
    NAME                  RESOURCE GROUP           LOCATION       SKU      LOGIN SERVER                     CREATION DATE         ADMIN ENABLED
    --------------------  ----------------------   -------------  -------  -------------------------------  --------------------  ---------------
    mydnsrandomnamebfbje  $MY_RESOURCE_GROUP_NAME  $MY_LOCATION   Premium  mydnsrandomnamebfbje.azurecr.io  2024-11-07T00:32:48Z  True
    ```

## Create an Azure storage account

- Create an Azure Storage Account to store the Airflow logs using the [`az acr create`](/en-us/cli/azure/storage/account#az-storage-account-create) command.

    ```azurecli
    az storage account create --name $AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME --resource-group $MY_RESOURCE_GROUP_NAME --location $MY_LOCATION --sku Standard_ZRS --output table
    export AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_KEY=$(az storage account keys list --account-name $AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
    az storage container create --name $AKS_AIRFLOW_LOGS_STORAGE_CONTAINER_NAME --account-name $AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME --output table --account-key $AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_KEY
    az keyvault secret set --vault-name $MY_KEYVAULT_NAME --name AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-NAME --value $AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME
    az keyvault secret set --vault-name $MY_KEYVAULT_NAME --name AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-KEY --value $AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_KEY
    ```

    Example output:

    ```output
    AccessTier    AllowBlobPublicAccess    AllowCrossTenantReplication    CreationTime                      EnableHttpsTrafficOnly    Kind       Location       MinimumTlsVersion    Name              PrimaryLocation    ProvisioningState    ResourceGroup      StatusOfPrimary
    ------------  -----------------------  -----------------------------  --------------------------------  ------------------------  ---------  -------------  -------------------  ----------------  -----------------  -------------------  -----------------  -----------------
    Hot           False                    False                          2024-11-07T00:22:13.323104+00:00  True                      StorageV2  $MY_LOCATION   TLS1_0               airflowsasabfbje  $MY_LOCATION       Succeeded            $MY_RESOURCE_GROUP_NAME  available
    Created
    ---------
    True
    ```

## Create an AKS cluster

In this step, we create an AKS cluster with workload identity and OIDC issuer enabled. This configuration creates a high-availability AKS cluster optimized for running production workloads like Apache Airflow. It provisions a *three* node cluster using `Standard_DS4_v2` VMs across three availability zones for resilience. The cluster is integrated with ACR for secure image pulls and includes OIDC issuer and workload identity support for secure, identity-based access to Azure resources. It also enables the Azure CNI network plugin, Blob CSI driver, and automatic node OS and Kubernetes version upgrades for enhanced performance and security.

1. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    az aks create \
    --location $MY_LOCATION \
    --name $MY_CLUSTER_NAME \
    --tier standard \
    --resource-group $MY_RESOURCE_GROUP_NAME \
    --network-plugin azure  \
    --node-vm-size Standard_DS4_v2 \
    --node-count 3 \
    --auto-upgrade-channel stable \
    --node-os-upgrade-channel NodeImage \
    --attach-acr ${MY_ACR_REGISTRY} \
    --enable-oidc-issuer \
    --enable-blob-driver \
    --enable-workload-identity \
    --zones 1 2 3 \
    --generate-ssh-keys \
    --output table
    ```

    Example output:

    ```output
    AzurePortalFqdn                                                                 CurrentKubernetesVersion    DisableLocalAccounts    DnsPrefix                           EnableRbac    Fqdn                                                                     KubernetesVersion    Location       MaxAgentPools    Name                NodeResourceGroup                                      ProvisioningState    ResourceGroup            ResourceUid                           SupportPlan
    ------------------------------------------------------------------------------  --------------------------  ----------------------  ----------------------------------  ------------  -----------------------------------------------------------------------  -------------------  -------------  ---------------  ------------------  -----------------------------------------------------  -------------------  -----------------------  ------------------------------------  ------------------
    apache-air-apache-airflow-r-363a0a-rhf6saad.portal.hcp.$MY_LOCATION.azmk8s.io   1.29.9                      False                   apache-air-apache-airflow-r-363a0a  True          apache-air-apache-airflow-r-363a0a-rhf6saad.hcp.$MY_LOCATION.azmk8s.io   1.29                 $MY_LOCATION   100              $MY_CLUSTER_NAME    MC_apache-airflow-rg_apache-airflow-aks_$MY_LOCATION   Succeeded            $MY_RESOURCE_GROUP_NAME  b1b1b1b1-cccc-dddd-eeee-f2f2f2f2f2f2  KubernetesOfficial
    ```
2. Get the OIDC issuer URL to use for the workload identity configuration using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    export OIDC_URL=$(az aks show --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --query oidcIssuerProfile.issuerUrl --output tsv)
    ```
3. Assign the `AcrPull` role to the kubelet identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    export KUBELET_IDENTITY=$(az aks show -g $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --output tsv --query identityProfile.kubeletidentity.objectId)
    az role assignment create \
    --assignee ${KUBELET_IDENTITY} \
    --role "AcrPull" \
    --scope ${MY_ACR_REGISTRY_ID} \
    --output table
    ```

    Example output:

    ```output
    CreatedBy                             CreatedOn                         Name                                  PrincipalId                           PrincipalName                         PrincipalType     ResourceGroup            RoleDefinitionId                                                                                                                            RoleDefinitionName    Scope                                                                                                                                                             UpdatedBy                             UpdatedOn
    ------------------------------------  --------------------------------  ------------------------------------  ------------------------------------  ------------------------------------  ----------------  -----------------------  ------------------------------------------------------------------------------------------------------------------------------------------  --------------------  ----------------------------------------------------------------------------------------------------------------------------------------------------------        ------------------------------------  --------------------------------
    ccccdddd-2222-eeee-3333-ffff4444aaaa  2024-11-07T00:43:26.905445+00:00  b1b1b1b1-cccc-dddd-eeee-f2f2f2f2f2f2  bbbbbbbb-cccc-dddd-2222-333333333333  cccccccc-dddd-eeee-3333-444444444444  ServicePrincipal  $MY_RESOURCE_GROUP_NAME  /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d  AcrPull               /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/$MY_RESOURCE_GROUP_NAME/providers/Microsoft.ContainerRegistry/registries/mydnsrandomnamebfbje  ccccdddd-2222-eeee-3333-ffff4444aaaa  2024-11-07T00:43:26.905445+00:00
    ```

## Connect to the AKS cluster

- Configure `kubectl` to connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --overwrite-existing --output table
    ```

## Upload Apache Airflow images to your container registry

In this section, we download the Apache Airflow images from Docker Hub and upload them to Azure Container Registry. This step ensures that the images are available in your private registry and can be used in your AKS cluster. We don't recommend consuming the public image in a production environment.

- Import the Airflow images from Docker Hub and upload them to your container registry using the [`az acr import`](/en-us/cli/azure/acr#az-acr-import) command.

    ```azurecli
    az acr import --name $MY_ACR_REGISTRY --source docker.io/apache/airflow:airflow-pgbouncer-2025.03.05-1.23.1 --image airflow:airflow-pgbouncer-2025.03.05-1.23.1
    az acr import --name $MY_ACR_REGISTRY --source docker.io/apache/airflow:airflow-pgbouncer-exporter-2025.03.05-0.18.0 --image airflow:airflow-pgbouncer-exporter-2025.03.05-0.18.0
    az acr import --name $MY_ACR_REGISTRY --source docker.io/bitnamilegacy/postgresql:16.1.0-debian-11-r15 --image postgresql:16.1.0-debian-11-r15
    az acr import --name $MY_ACR_REGISTRY --source quay.io/prometheus/statsd-exporter:v0.28.0 --image statsd-exporter:v0.28.0 
    az acr import --name $MY_ACR_REGISTRY --source docker.io/apache/airflow:3.0.2 --image airflow:3.0.2 
    az acr import --name $MY_ACR_REGISTRY --source registry.k8s.io/git-sync/git-sync:v4.3.0 --image git-sync:v4.3.0
    ```