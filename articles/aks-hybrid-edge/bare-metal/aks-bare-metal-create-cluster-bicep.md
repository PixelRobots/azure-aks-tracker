---
layout: Conceptual
title: Create an AKS on bare metal cluster using Bicep (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-bicep
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to deploy an Azure Kubernetes Service (AKS) cluster on bare metal using a Bicep template.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 34524186-9e28-89fc-ff4d-d57c19bfff4a
document_version_independent_id: 1705974f-8650-dcc3-fb75-e93015ee22ee
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-bicep.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-bicep
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-bicep.md
platformId: 1478cf80-e7db-428e-9da2-8c3d819f2b4c
---

# Create an AKS on bare metal cluster using Bicep (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to create an Azure Kubernetes Service (AKS) cluster on bare metal using a Bicep template.

## Prerequisites

Complete all [system requirements and prerequisites](aks-bare-metal-system-requirements) before you begin.

## Step 1: Download the Bicep parameters file

1. Download a local copy of the [Bicep parameters file](https://github.com/Azure/aksArc/blob/main/deploymentTemplates/aks-baremetal-bicep/create.example.bicepparam).
2. Configure the following parameters:

| Parameter | Value | Notes |
| --- | --- | --- |
| `location` | `eastus` | Only supported region for public preview. |
| `clusterName` | Your cluster name | Name must be 1-27 characters long, start and end with a letter or number, and can only contain letters, numbers, hyphens, or underscores. |
| `kubernetesVersion` | `1.34.2-20260204` or `1.34.3-20260204` | Format: `Major.Minor.Patch-YYYYMMDD`. |
| `controlPlaneIp` | IP address | If omitted, defaults to the host machine's IP address. Only specify a custom IP if you need the control plane to be reachable on a different address than the host. If provided, it must be in the same subnet as the host IP. |
| `adminGroupObjectIds` | Microsoft Entra ID group object ID | Used for cluster admin RBAC. |
| `sshPublicKey` | SSH public key | An SSH key pair was created during Edge Machine creations. Use that public key here. |
| `logAnalyticsWorkspaceId` | `/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.OperationalInsights/workspaces/<WORKSPACE_NAME>` | New workspace used for log analytics. |
| `edgeMachineName` | Edge machine name | Must match the provisioned machine in your resource group. |

Warning

If you specify a custom controlPlaneIp and your machine uses DHCP, you must reserve the control plane IP address so it remains permanently assigned to this machine. If the control plane IP changes, the Kubernetes cluster becomes unreachable and must be redeployed.

## Step 2: Download the Bicep template

Save the [Bicep template](https://github.com/Azure/aksArc/blob/main/deploymentTemplates/aks-baremetal-bicep/cluster-create.bicep) to the same directory as your parameters file.

## Step 3: Deploy

Run the following command from the directory containing both files:

```azurecli
az deployment group create \
  --resource-group <RESOURCE_GROUP> \
  --template-file cluster-create.bicep \
  --parameters create.example.bicepparam
```

Note

Deployment typically takes 20 minutes. You can monitor progress in the Azure portal under your resource group &gt; **Deployments**.

## Verify deployment

After the deployment completes, connect to your cluster:

```azurecli
az aksarc get-credentials --name <clusterName> --resource-group <RESOURCE_GROUP>
```

Then in a new terminal:

```bash
kubectl get nodes
```

For detailed connection instructions, see [Connect to your cluster](aks-bare-metal-connect-to-cluster).