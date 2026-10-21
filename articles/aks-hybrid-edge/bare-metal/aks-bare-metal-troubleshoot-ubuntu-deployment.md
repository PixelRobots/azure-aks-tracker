---
layout: Conceptual
title: Troubleshoot AKS on Bare Metal on Ubuntu | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-ubuntu-deployment
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
description: Resolve Azure Arc, extension, permission, network, and deployment issues for AKS on bare metal on Ubuntu.
ms.topic: troubleshooting-general
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: 062ba77e-d67c-3c4a-5c35-be8419610720
document_version_independent_id: 18f3e70a-07e1-1d97-2320-7bb9bda38986
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-ubuntu-deployment.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-ubuntu-deployment
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-ubuntu-deployment.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 2c9ae5b6-4305-f26e-2e4c-6ab70443069b
---

# Troubleshoot AKS on Bare Metal on Ubuntu | Microsoft Learn

Use this guidance for Azure Kubernetes Service (AKS) on bare metal on Ubuntu.

## The Arc-enabled server is disconnected

Check the Azure Connected Machine agent:

```bash
sudo azcmagent check
sudo systemctl status himdsd
```

Verify the Azure resource status:

```azurecli
az connectedmachine show \
  --resource-group <resource-group> \
  --name <host-name> \
  --query status \
  --output tsv
```

If the status is `Disconnected`, check DNS, proxy, firewall, and outbound endpoint access. For detailed Azure Arc guidance, see [Troubleshoot Azure Arc-enabled servers agent connection issues](/en-us/azure/azure-arc/servers/troubleshoot-agent-onboard).

## The aksarc command isn't available

Update Azure CLI, then install or update the public extension:

```azurecli
az upgrade
az extension add --name aksarc --upgrade --allow-preview true
```

The `deploy` and `undeploy` commands require the public-preview release of the extension.

## Deployment fails with an authorization error

Confirm that your role assignment is active and permanent. You need Owner, or Contributor plus User Access Administrator, on the resource group. Also verify that all six required resource providers and both public-preview features are registered.

## Deployment can't resolve the Microsoft.AzureStackHCI service principal

The deployment can fail with the following error:

```output
Could not resolve the Microsoft.AzureStackHCI resource provider service
principal through Microsoft Graph. Supply its tenant-specific object ID with
--hci-rp-object-id or the HCI_RP_OBJECT_ID environment variable. Original
error: AADSTS53003: Access has been blocked by Conditional Access policies.
The access policy does not allow token issuance.
```

To resolve the issue, get the tenant-specific object ID of the `Microsoft.AzureStackHCI` resource provider service principal:

```azurecli
HCIRP_OBJECT_ID=$(az ad sp show \
  --id 1412d89f-b8a8-4111-b4fd-e82905cbd85d \
  --query id \
  --output tsv)
```

If your session can't run the Microsoft Graph query because of Conditional Access, ask your Microsoft Entra administrator to run the command and provide the object ID. Pass the object ID to the deployment command:

```azurecli
az aksarc deploy \
  --resource-group <resource-group> \
  --arc-machine-names <host-name> \
  --hci-rp-object-id "$HCIRP_OBJECT_ID"
```

## Deployment times out

Confirm that the host meets the minimum CPU, memory, and disk requirements and can reach `mcr.microsoft.com`, `*.data.mcr.microsoft.com`, and Azure management endpoints over HTTPS. Keep the Azure Arc connection active throughout deployment.

## Retry a failed deployment

Remove the incomplete cluster before you retry:

```azurecli
az aksarc undeploy \
  --resource-group <resource-group> \
  --arc-machine-names <host-name> \
  --yes
```

Then run the deployment command again.