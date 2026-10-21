---
layout: Conceptual
title: Create an AKS on bare metal cluster using ARM template (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-arm-template
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
description: Learn how to deploy an Azure Kubernetes Service (AKS) cluster on bare metal using an ARM template.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 84c07255-281b-631b-59cc-1ab12689d875
document_version_independent_id: 2e56466b-f0c8-9114-ccdb-fddc366a9691
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-arm-template.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-arm-template
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-arm-template.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6a682752-5ec1-c407-8edf-535f4b4356a4
---

# Create an AKS on bare metal cluster using ARM template (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to create an Azure Kubernetes Service (AKS) cluster on bare metal using an Azure Resource Manager template (ARM template).

## Prerequisites

Complete all [system requirements and prerequisites](aks-bare-metal-system-requirements) before you begin.

## Step 1: Download the ARM template parameters file

1. Download a local copy of the [ARM template parameters file](https://github.com/Azure/aksArc/blob/main/deploymentTemplates/aks-baremetal-arm/aks-baremetal-arm.parameteres.json).
2. Configure the following required parameters:

    | Parameter | Value | Notes |
    | --- | --- | --- |
    | `edgeMachineName` | Edge machine name | Must match the provisioned machine in your resource group. |
    | `adminGroupObjectIds` | Microsoft Entra ID group object ID | Used for cluster admin RBAC. Must be a valid GUID. |
    | `sshPublicKey` | SSH public key | An SSH key pair was created during Edge Machine creation. Use that public key. |
3. Optionally configure additional parameters:

    | Parameter | Default | Notes |
    | --- | --- | --- |
    | `clusterName` | `my-aks-on-baremetal-cluster` | Name must be 1-27 characters long, start and end with a letter or number, and can only contain letters, numbers, hyphens, or underscores. |
    | `kubernetesVersion` | `1.34.3-20260204` | Format: `Major.Minor.Patch-YYYYMMDD`. |
    | `controlPlaneIp` | (auto-assigned as host IP) | If specified, must be in the same subnet as the host IP **but cannot be the same as the host IP**. If no IP is provided, it defaults to the host IP. |
    | `enableAzurePolicy` | `true` | Set to `false` to skip Azure Policy extension installation. |
    | `enableContainerMonitoring` | `true` | Set to `false` to skip Container Monitoring extension installation. |
    | `logAnalyticsWorkspaceId` | (empty) | Required if `enableContainerMonitoring` is `true`. Format: `/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.OperationalInsights/workspaces/<WORKSPACE_NAME>` |

Warning

If your machine uses DHCP and you specify a control plane IP, you must reserve that IP address so it remains permanently assigned to this machine. If the control plane IP changes, the Kubernetes cluster becomes unreachable and must be redeployed.

## Step 2: Download the ARM template

Save the [ARM template](https://github.com/Azure/aksArc/blob/main/deploymentTemplates/aks-baremetal-arm/aks-baremetal-arm.json) to the same directory as your parameters file.

## Step 3: Deploy

Run the following command from the directory containing both files:

```azurecli
az deployment group create \
  --resource-group <RESOURCE_GROUP> \
  --template-file aks-baremetal-arm.json \
  --parameters aks-baremetal-arm.parameteres.json
```

Note

Deployment typically takes 20 minutes. You can monitor progress in the Azure portal under your resource group &gt; **Deployments**.

## Verify deployment

After the deployment finishes, connect to your cluster:

```azurecli
az aksarc get-credentials --name <clusterName> --resource-group <RESOURCE_GROUP>
```

Then, in a new terminal:

```bash
kubectl get nodes
```

For detailed connection instructions, see [Connect to your cluster](aks-bare-metal-connect-to-cluster).