---
layout: Conceptual
title: Create an AKS on bare metal cluster on Ubuntu with Azure CLI | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-ubuntu-cli
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
description: Connect an Ubuntu host to Azure Arc and create an Azure Kubernetes Service on bare metal cluster by using an automated script or Azure CLI.
ms.topic: how-to
ms.date: 2026-10-16T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: b7650efb-dc00-857e-5037-15e5868a2088
document_version_independent_id: 31abe734-1f76-8159-942b-8cb6b3112feb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-ubuntu-cli.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-ubuntu-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-ubuntu-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 86ecef7a-2435-7915-c73a-81f4e254885e
---

# Create an AKS on bare metal cluster on Ubuntu with Azure CLI | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- Review the [Ubuntu host system requirements](aks-bare-metal-ubuntu-system-requirements) and ensure your host meets them.
- Get the ID of the Azure subscription where you want to deploy the cluster.
- Get your Microsoft Entra tenant ID.

## Deploy the cluster

You can deploy an AKS cluster on your bare metal Ubuntu machine in two ways. You can download a script that runs the deployment commands for you, or you can execute the commands yourself in a step-by-step process.

### Option 1: Connect and deploy with one command

The easiest way to deploy an AKS cluster is through a script maintained by the AKS team. The command downloads the script by using `curl` and pipes it to `bash` to connect your machine to Azure Arc and deploy the AKS cluster.

Replace the placeholder values with your subscription and tenant IDs. Run the command on your Ubuntu machine:

```bash
curl -sSL https://aka.ms/aksbm | bash -s -- \
  -s <subscription-id> \
  -t <tenant-id>
```

Note

To inspect the script before you run it, download the script from `https://aka.ms/aksbm` and review the file locally.

### Option 2: Connect and deploy step by step

If you prefer a step-by-step installation process, complete the following steps to install the AKS cluster.

1. Complete the steps to [prepare and connect your Ubuntu host](aks-bare-metal-ubuntu-system-requirements#prepare-and-connect-the-ubuntu-host).
2. Use Azure CLI version 2.90.0 or later.
3. Verify that the Arc-enabled server has a `Connected` status.
4. Sign in and select the subscription that contains the Arc-enabled server.

    ```azurecli
    az login
    az account set --subscription <subscription-id>
    ```
5. Install or update the public `aksarc` extension.

    ```azurecli
    az extension add --name aksarc --upgrade --allow-preview true
    ```
6. Deploy the cluster.

    ```azurecli
    az aksarc deploy \
      --resource-group <resource-group> \
      --arc-machine-names <host-name>
    ```

## Supported Kubernetes versions

If you don't specify `--kubernetes-version`, AKS deploys Kubernetes version `1.35.5`. To deploy another supported version, pass the corresponding version number to `--kubernetes-version`.

| Supported Kubernetes versions |
| --- |
| 1.34.3 |
| 1.34.4 |
| 1.34.8 |
| 1.35.5 |
| 1.36.1 |

The following example deploys Kubernetes `1.34.3`:

```azurecli
az aksarc deploy \
  --resource-group <resource-group> \
  --arc-machine-names <host-name> \
  --kubernetes-version 1.34.3
```

Deployment takes approximately 40 minutes. Keep the host connected to Azure and the required outbound endpoints throughout deployment.

## Verify the deployment

After deployment completes, you can verify the cluster status by running the following command:

```azurecli
az aksarc show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query properties.provisioningState \
  --output tsv
```

You can also view the cluster in the Azure portal under **Kubernetes Center** &gt; **Clusters**. The portal experience for Ubuntu is read-only during the preview.