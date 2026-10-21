---
layout: Conceptual
title: Retrieve certificate-based admin kubeconfig in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/retrieve-admin-kubeconfig
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
description: Retrieve certificate-based admin kubeconfig in AKS Hybrid and Edge.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-06-03T00:00:00.0000000Z
ms.reviewer: leslielin
ms.custom: hyperconverged
locale: en-us
document_id: a95d1b51-9754-8b86-7735-02836d67ff4b
document_version_independent_id: 6e28ba25-555f-c3a1-2c26-9150f4713436
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/retrieve-admin-kubeconfig.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/retrieve-admin-kubeconfig
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/retrieve-admin-kubeconfig.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 6ce7fd6e-2f34-fdef-52a9-c814d7ce1bd4
---

# Retrieve certificate-based admin kubeconfig in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

## Get certificate-based admin kubeconfig

An AKS Hybrid and Edge cluster administrator can retrieve the certificate-based admin kubeconfig using the following command.

### Before you begin

Ensure you meet the following prerequisites:

- An AKS Hybrid and Edge cluster.
- You need the Azure CLI installed and configured. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Install the latest version of the `aksarc` and `connectedk8s` Azure CLI extension:

    ```azurecli
    az extension add --name aksarc
    az extension add --name connectedk8s
    ```

    If you already installed the extensions, update the extension to the latest version:

    ```azurecli
    az extension update --name aksarc
    az extension update --name connectedk8s
    ```
- **Kubectl**. The Kubernetes command-line tool, kubectl, enables you to run commands targeting your Kubernetes clusters. To check whether you installed kubectl, open a command prompt and type `kubectl version --client`. Make sure your kubectl client version is at least `v1.24.0`. For installation instructions, see [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl).
- To run the Azure CLI command, you must have the `Azure Kubernetes Service Arc Cluster Admin` role, or **Microsoft.HybridContainerService/provisionedClusterInstances/listAdminKubeconfig/action** action on the Kubernetes cluster.
- In order to retrieve and use the certificate-based admin Kubeconfig, you need direct line of sight to your AKS cluster. Run the following commands on the physical machine, or a jumpbox that has access to the physical machines on which your AKS cluster is running.

### Retrieve the certificate-based admin kubeconfig using Az CLI

You can retrieve the kubeconfig of your AKS cluster using the [`az aksarc get-credentials`](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command.

Caution

The admin kubeconfig contains secrets, so you should follow best security practices for the admin kubeconfig; such as securely handle it, rotate secrets periodically, and so on.

```azurecli
az aksarc get-credentials --resource-group myResourceGroup --name myAKSCluster --admin
```

Now, you can use `kubectl` to manage your Kubernetes cluster. For example, you can list the nodes in your cluster using `kubectl get nodes`:

```azurecli
kubectl get nodes
```

Expected output:

```output
NAME             STATUS ROLES                AGE VERSION
moc-l0ttdmaioew  Ready  control-plane,master 34m v1.24.11
moc-ls38tngowsl  Ready  <none>               32m v1.24.11
```