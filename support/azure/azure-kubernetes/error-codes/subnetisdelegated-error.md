---
layout: Conceptual
title: Troubleshoot the SubnetIsDelegated error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/subnetisdelegated-error
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Troubleshoot the SubnetIsDelegated error in AKS when creating a node pool. Learn the causes and step-by-step resolution to fix subnet delegation issues.
ms.date: 2026-09-16T00:00:00.0000000Z
ms.reviewer: shipu.yao, pinghe, zhixinsun
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 9bfc4997-9096-f8d9-af70-0e3ddb3805d8
document_version_independent_id: 9bfc4997-9096-f8d9-af70-0e3ddb3805d8
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/subnetisdelegated-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/subnetisdelegated-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/subnetisdelegated-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 981236c6-2a53-9554-cc91-be57961e3548
---

# Troubleshoot the SubnetIsDelegated error code - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the `SubnetIsDelegated` error that occurs in Azure Kubernetes Service (AKS) when you try to create a node pool. Follow the steps in this article to fix subnet delegation issues and successfully create your node pool.

## Prerequisites

Ensure the following prerequisites are met:

- Azure CLI (version 2.0.59 or a later version)
- Access to the AKS cluster and permission to read the subnet identified in the error. To remove a delegation, you also need permission to update that subnet.

## Symptoms

When you try to create a node pool in an AKS cluster, you receive the following error message:

> 
> **Code:** **SubnetIsDelegated**
> 
> **Message:**`AgentPoolProfile` subnet with id &lt;subnet-id&gt; cannot be used as it's a delegated subnet. Please check https://aka.ms/adv-network-prerequest for more details.

The exact message can vary. It might omit the delegation ID and service name.

## Cause

The subnet you specified for the node pool is delegated to an Azure service. AKS rejects the delegated subnet as the node subnet. This condition also applies when the delegated service is `Microsoft.ContainerService/managedClusters`. Changing the delegation from another service to this service doesn't resolve the node subnet error.

The subnet identified by `AgentPoolProfile` is the node subnet you specified by using `--vnet-subnet-id`. Don't confuse it with an API server subnet or a separate pod subnet, which have their own networking requirements. For example, [API Server VNet Integration](/en-us/azure/aks/api-server-vnet-integration) requires a dedicated API server subnet delegated to `Microsoft.ContainerService/managedClusters`. That requirement doesn't apply to the node subnet.

## Resolution

To resolve this issue, follow these steps:

1. Identify the node subnet from the error message, and inspect its delegations. Replace `<subnet-id-from-the-error>` with the full subnet resource ID.

Use a command line interface (CLI) tool or Azure PowerShell to run the following commands.

# [Bash](#tab/bash)
```bash
    SUBNET_ID="<subnet-id-from-the-error>"

    az network vnet subnet show \
      --ids "$SUBNET_ID" \
      --query delegations \
      --output json
```

# [PowerShell](#tab/powershell)
```powershell
    $SUBNET_ID = "<subnet-id-from-the-error>"

    az network vnet subnet show `
      --ids "$SUBNET_ID" `
      --query delegations `
      --output json
```

---

An empty array (`[]`) means that the subnet has no delegations. A nonempty array lists the delegated services.

1. Select a dedicated, nondelegated subnet for the node pool. If the original subnet is still required by its delegated service, leave its delegation unchanged and use a different subnet that meets the AKS networking requirements. Set `SUBNET_ID` to the selected subnet's resource ID.

If you intend to reuse the original subnet, first confirm that it is no longer required by the delegated service and that removing the delegation is safe. Only after confirmation should you then remove the delegation.

Use a CLI tool or Azure PowerShell to run the following commands.

# [Bash](#tab/bash)
```bash
    az network vnet subnet update \
      --ids "$SUBNET_ID" \
      --remove delegations 0
```

# [PowerShell](#tab/powershell)
```powershell
    az network vnet subnet update `
      --ids "$SUBNET_ID" `
      --remove delegations 0
```

---

This command removes only the delegation at index `0`. If more than one delegation is present, review the remaining entries and repeat the removal only when each entry can safely be removed. Don't remove a delegation from an API server subnet, a pod subnet, or a subnet used by another service merely to make it available to the node pool.

1. Verify that the selected node subnet has no delegations.

Use a command line interface (CLI) tool or Azure PowerShell to run the following commands.

# [Bash](#tab/bash)
```bash
    az network vnet subnet show \
      --ids "$SUBNET_ID" \
      --query delegations \
      --output json
```

# [PowerShell](#tab/powershell)
```powershell
    az network vnet subnet show `
      --ids "$SUBNET_ID" `
      --query delegations `
      --output json
```

---

The output must be `[]`. Don't add `Microsoft.ContainerService/managedClusters` delegation to the node subnet.

1. Retry the `az aks nodepool add` command, making sure that `--vnet-subnet-id` points to the selected nondelegated subnet. If you selected a different subnet, also confirm that it meets the cluster's networking requirements and that the cluster identity has the required permissions.

If the request returns **OperationNotAllowed** because another cluster operation is in progress, wait for that operation to finish before retrying. This concurrency error doesn't establish whether the subnet delegation is valid.

## References

- [az aks nodepool add examples](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add-examples)
- [AKS CNI networking prerequisites](/en-us/azure/aks/concepts-network-cni-overview#aks-cni-networking-prerequisites)
- [API Server VNet Integration](/en-us/azure/aks/api-server-vnet-integration)
- [Subnet delegation overview](/en-us/azure/virtual-network/subnet-delegation-overview)