---
layout: Conceptual
title: Connect to an AKS on bare metal Cluster (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-connect-to-cluster
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
description: Learn how to connect to your Azure Kubernetes Service on bare metal cluster using the Azure Arc proxy and kubectl.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 8aabf2eb-2765-e020-4d7a-a8b4937fe784
document_version_independent_id: 5e5c3e92-4696-e759-3bee-93703f8fd595
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-connect-to-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-connect-to-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-connect-to-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: cc0b8156-ae2f-e0ac-1466-1348b0a973c6
---

# Connect to an AKS on bare metal Cluster (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to connect to your AKS on bare metal cluster to run `kubectl` commands. After you deploy your cluster, use the Azure Arc proxy to route `kubectl` commands from your local machine to the Kubernetes cluster running on your device.

## Prerequisites

- An AKS on bare metal cluster in a **Succeeded** state.
- Azure CLI installed on your local machine and signed in.
- The `connectedk8s` extension installed.

    ```azurecli
    az extension add --name connectedk8s
    ```
- `kubectl` installed. Open a terminal and run the following command, then close and reopen your terminal:

    ```azurecli
    sudo az aks install-cli
    ```
- Your user account must be a member of the Microsoft Entra ID admin group you specified during cluster deployment. This membership is required to view and manage workloads on the cluster.

## Connect by using Azure Arc proxy

The Azure Arc proxy lets you connect to your cluster from anywhere without direct network access to the bare metal host.

### Step 1: Sign in to Azure

Open a terminal window and sign in to Azure, and then select the subscription that contains your deployed cluster:

```azurecli
az login
az account set --subscription <subscription-id>
```

### Step 2: Start the proxy

Run the following command and keep this terminal window open:

```azurecli
az connectedk8s proxy --name <cluster-name> --resource-group <resource-group>
```

You see output similar to:

```output
Proxy is listening on port 47011
Merged "<cluster-name>" as current context in C:\Users\<you>\.kube\config
Start sending kubectl requests on '<cluster-name>' context using kubeconfig at C:\Users\<you>\.kube\config
Press Ctrl+C to close proxy.
```

Important

Keep this terminal window open. The proxy must stay running while you use kubectl.

### Step 3: Run kubectl in a new terminal

Open a **second terminal window** and run:

```bash
kubectl get nodes
```

Expected output:

```output
NAME               STATUS   ROLES           AGE   VERSION
<cluster-name>     Ready    control-plane   1d    v1.34.3
```

## Download credentials for an Ubuntu cluster

For Ubuntu, you can download a standalone kubeconfig file instead of running the Azure Arc proxy:

```azurecli
az aksarc get-credentials \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --file ./aks-ubuntu.kubeconfig
```

Use the downloaded file:

```bash
kubectl --kubeconfig ./aks-ubuntu.kubeconfig get nodes
```

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `context deadline exceeded` | The proxy isn't running. Restart `az connectedk8s proxy` in the first terminal. |
| `kubectl: command not found` | Run `az aks install-cli`, then close and reopen your terminal. |
| MSI token audience error | Don't use Azure Cloud Shell. Run `az connectedk8s proxy` from your local machine. |
| `unrecognized arguments` | Use double dashes: `--name` and `--resource-group` (not single dash). |