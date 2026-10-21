---
layout: Conceptual
title: Create Azure AKS Infrastructure - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/create-aks-infrastructure
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
description: Learn how to build the foundational Azure infrastructure for a generic AKS cluster that can host any containerized workload.
ms.topic: how-to
ms.author: carols
author: fossygirl
ms.reviewer: rogardle
ms.date: 2025-11-20T00:00:00.0000000Z
locale: en-us
document_id: 0c47eca7-8123-c544-df94-d11e7dfc91e3
document_version_independent_id: 72e379c6-0abd-b147-2981-af3a1a7f4e51
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/create-aks-infrastructure.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/create-aks-infrastructure
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/create-aks-infrastructure.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 23ae8a96-5245-5a81-3c62-af860aebd0aa
---

# Create Azure AKS Infrastructure - Azure Kubernetes Service | Microsoft Learn

In this article, you provision the core Azure resources required for a production-ready AKS deployment. This article validates Azure access, creates a resource group, establishes an Azure Container Registry (ACR), deploys a baseline AKS cluster, optionally adds an additional node pool for user workloads, and grants the cluster permission to pull from ACR. All commands rely on parameterized environment variables so the workflow remains repeatable across regions and subscriptions.

## Prerequisites

You need the following tooling and account access before running the guide. Ensure you're authenticated to Azure using `az login` and have sufficient permissions to create resource groups, container registries, and AKS clusters.

- Azure subscription with quota for the selected region
- Azure CLI (`az`) with Owner or Contributor rights
- kubectl configured locally for cluster access
- jq (optional) for parsing JSON output during verification

Run the following commands to confirm you have all the necessary CLI tooling and Azure access:

```bash
command -v az >/dev/null || echo "Azure CLI missing"
command -v kubectl >/dev/null || echo "kubectl missing"
command -v jq >/dev/null || echo "jq missing (optional)"
```

## Set up the environment

Here, you define all the environment variables used throughout the provisioning steps. The `HASH` timestamp keeps resource names unique during repeated executions. Cluster and registry defaults target a minimal proof-of-concept footprint, but you can adjust them as needed.

The following commands establish Azure scope, AKS sizing, and ACR naming conventions for the provisioning sequence regardless of downstream workloads.

```bash
export HASH="${HASH:-$(date -u +"%y%m%d%H%M")}"  # YYMMDDHHMM stamp

# Azure scope and regional placement
export LOCATION="${LOCATION:-eastus2}"
export SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv)}"
export RESOURCE_GROUP="${RESOURCE_GROUP:-rg_aks_${HASH}}"

# AKS cluster naming and version control
# Hyphen required because AKS cluster names cannot include underscores
export AKS_CLUSTER_NAME="${AKS_CLUSTER_NAME:-aks-openwebsearch-${HASH}}"
export AKS_VERSION="${AKS_VERSION:-}"  # Optional Kubernetes version override

# Node pool sizing
export AKS_SYSTEM_NODE_COUNT="${AKS_SYSTEM_NODE_COUNT:-1}"
export AKS_USER_NODE_COUNT="${AKS_USER_NODE_COUNT:-1}"
export AKS_NODE_VM_SIZE="${AKS_NODE_VM_SIZE:-Standard_D4s_v5}"
export AKS_SYSTEM_NODEPOOL_NAME="${AKS_SYSTEM_NODEPOOL_NAME:-system}"
export AKS_USER_NODEPOOL_NAME="${AKS_USER_NODEPOOL_NAME:-user}"

# ACR configuration
export ACR_NAME="${ACR_NAME:-acrwebsearch${HASH}}"
export ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:-${ACR_NAME}.azurecr.io}"
```

### Verify environment variable values

Review the effective configuration before creating resources. Re-run the block after any adjustments to ensure the active values are correct for the target subscription and region.

Use the following commands to pint the active parameters to validate naming, sizing, and regional choices.

```bash
: "${HASH:=$(date -u +"%y%m%d%H%M")}"  # Ensure HASH exists

VARS=(
  HASH
  LOCATION
  SUBSCRIPTION_ID
  RESOURCE_GROUP
  AKS_CLUSTER_NAME
  AKS_VERSION
  AKS_SYSTEM_NODE_COUNT
  AKS_USER_NODE_COUNT
  AKS_NODE_VM_SIZE
  AKS_SYSTEM_NODEPOOL_NAME
  AKS_USER_NODEPOOL_NAME
  ACR_NAME
  ACR_LOGIN_SERVER
)
for v in "${VARS[@]}"; do
  printf "%s=%s\n" "$v" "${!v}"
done
```

## Steps

Execute each step sequentially. Every subsection includes purpose, commands, and a summary to confirm expected outcomes.

### Check the Azure subscription context

Verify the active Azure subscription and ensure the resource providers required for AKS and ACR operations are registered.

```bash
az account show --query id -o tsv
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerRegistry
```

### Create a resource group

Provision a dedicated resource group to isolate the AKS cluster, registry, and supporting infrastructure for your workloads.

```bash
az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --output table
```

### Provision the Azure Container Registry

Create an Azure Container Registry for storing container images and authenticate the local Docker daemon to push images.

```bash
az acr create \
  --name "${ACR_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --sku Basic \
  --output table
az acr login --name "${ACR_NAME}"
```

### Create the AKS cluster

Deploy the AKS cluster to host your workloads. Guard against reusing an existing cluster name by checking before creation.

```bash
if az aks show \
  --name "${AKS_CLUSTER_NAME}" \
  --resource-group "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  echo "AKS cluster ${AKS_CLUSTER_NAME} already exists in ${RESOURCE_GROUP}";
  echo "Skip creation or provide a new AKS_CLUSTER_NAME.";
else
  az aks create \
    --name "${AKS_CLUSTER_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --generate-ssh-keys \
    --node-count "${AKS_SYSTEM_NODE_COUNT}" \
    --nodepool-name "${AKS_SYSTEM_NODEPOOL_NAME}" \
    --node-vm-size "${AKS_NODE_VM_SIZE}" \
    ${AKS_VERSION:+--kubernetes-version "${AKS_VERSION}"} \
    --output table
fi
```

### Add optional user node pool

Provision an additional node pool when requested. The add command runs asynchronously to avoid CLI timeouts; the wait command tracks Azure's progress. The script first checks whether the pool already exists to prevent duplicate name errors.

```bash
if [ "${AKS_USER_NODE_COUNT}" -gt 0 ]; then
  if az aks nodepool show \
    --cluster-name "${AKS_CLUSTER_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${AKS_USER_NODEPOOL_NAME}" >/dev/null 2>&1; then
    echo "Node pool ${AKS_USER_NODEPOOL_NAME} already exists; skipping add.";
  else
    az aks nodepool add \
      --cluster-name "${AKS_CLUSTER_NAME}" \
      --resource-group "${RESOURCE_GROUP}" \
      --name "${AKS_USER_NODEPOOL_NAME}" \
      --node-count "${AKS_USER_NODE_COUNT}" \
      --node-vm-size "${AKS_NODE_VM_SIZE}" \
      --no-wait
    az aks nodepool wait \
      --cluster-name "${AKS_CLUSTER_NAME}" \
      --resource-group "${RESOURCE_GROUP}" \
      --name "${AKS_USER_NODEPOOL_NAME}" \
      --created
  fi
fi
```

### Retrieve cluster credentials

Merge the AKS kubeconfig into the local context and verify all nodes are reachable.

```bash
az aks get-credentials \
  --name "${AKS_CLUSTER_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --overwrite-existing
kubectl get nodes -o wide
```

### Attach ACR to AKS cluster

Grant the AKS cluster permission to pull images from the provisioned ACR so future deployments can access your container images.

```bash
az aks update \
  --name "${AKS_CLUSTER_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --attach-acr "${ACR_NAME}" \
  --output table
```

## Verification

Confirm the AKS cluster exists and responds to basic `kubectl` queries before continuing to downstream deployment steps. Start by ensuring the AKS cluster exists.

```bash
if ! az aks show \
  --name "${AKS_CLUSTER_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "{name:name,provisioningState:provisioningState,location:location}" \
  --output table; then
  echo "AKS cluster '${AKS_CLUSTER_NAME}' not found in resource group '${RESOURCE_GROUP}'."
else
  echo "AKS cluster '${AKS_CLUSTER_NAME}' exists in resource group '${RESOURCE_GROUP}'."
fi
```

If the AKS cluster has been created, you'll see something like:

```text
AKS cluster ${AKS_CLUSTER_NAME} exists in resource group ${RESOURCE_GROUP}.
```

Next, check that `kubectl` is correctly configured:

```bash
kubectl cluster-info
```

This command will output status of the current cluster, something like:

```text
Kubernetes control plane is running at ...
CoreDNS is running at https://...
Metrics-server is running at https://...
```

Finally, ensure that there are both system and user nodes available:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.labels.agentpool}{"\n"}{end}' |
  sort |
  uniq -c
```

This will output a count of nodes, something like:

```text
      1 system
      1 user
```

Summary: Validated that the AKS cluster is present, healthy, and reachable via kubectl in the current context.

## Summary

The resource group, container registry, AKS cluster, optional node pool, and registry attachment are validated, leaving the cluster ready for any containerized workloads.