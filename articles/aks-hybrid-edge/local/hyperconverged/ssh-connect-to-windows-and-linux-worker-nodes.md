---
layout: Conceptual
title: Connect to Windows or Linux worker nodes with SSH | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/ssh-connect-to-windows-and-linux-worker-nodes
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
description: Learn how to use SSH to connect to Windows or Linux worker nodes in an AKS cluster.
ms.date: 2026-09-01T00:00:00.0000000Z
ms.topic: how-to
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: leslielin
ms.lastreviewed: 2025-07-02T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: cbae35d7-4de0-3108-c2ec-47ea23e3cbca
document_version_independent_id: 6b6912cf-f0b3-74a1-483a-c08e600f1872
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/ssh-connect-to-windows-and-linux-worker-nodes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/ssh-connect-to-windows-and-linux-worker-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/ssh-connect-to-windows-and-linux-worker-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8603cdfd-2496-ba7b-6a2f-23ad019e501b
---

# Connect to Windows or Linux worker nodes with SSH | Microsoft Learn

> 
> Applies to: AKS on Azure Local

During your AKS cluster's lifecycle, you might need to directly access cluster nodes for maintenance, log collection, or troubleshooting operations. For security purposes, you must use a Secure Shell Protocol (SSH) connection to access Windows or Linux worker nodes. You sign in using the node's IP address.

This article explains how to use SSH to connect to both Windows and Linux nodes.

## Prerequisites

### **Install the Kubernetes CLI**

You can use the Kubernetes CLI, [**kubectl**](https://kubernetes.io/docs/reference/kubectl/), to connect to your Kubernetes cluster. If you use Azure Cloud Shell, **kubectl** is already installed. If you run the commands locally, you can use the Azure CLI or Azure PowerShell to install **kubectl**.

# [Azure CLI](#tab/azure-cli)
- Install **kubectl** locally using the [`az aks install-cli`](/en-us/cli/azure/aks?view=azure-cli-latest&amp;preserve-view=true#az-aks-install-cli) command:

    ```azurecli
    az aks install-cli
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Install **kubectl** locally using the [`Install-AzAksCliTool`](/en-us/powershell/module/az.aks/install-azaksclitool?view=azps-14.2.0&amp;preserve-view=true) cmdlet:

    ```azurepowershell
    Install-AzAksCliTool
    ```

---

## Use SSH to connect to worker nodes

1. To access the Kubernetes cluster with the specified permissions, you must retrieve the certificate-based admin **kubeconfig** file using the [az aksarc get-credentials](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command. For more information, see [Retrieve certificate-based admin kubeconfig](retrieve-admin-kubeconfig):

    ```azurecli
    az aksarc get-credentials --resource-group $<resource_group_name> --name $<aks_cluster_name> --admin
    ```
2. Run **kubectl get** to obtain the node's IP address and capture its IP value in order to sign in to a Windows or Linux worker node using SSH:

    ```azurecli
    kubectl --kubeconfig /path/to/aks-cluster-kubeconfig get nodes -o wide
    ```
3. Run `ssh` to connect to a worker node:

    Note

    You must pass the correct location to your SSH private key. The following example uses the default location of **~/.ssh/id\_rsa**, but you might need to change this location if you requested a different path. To change the location, see [Configure SSH keys](configure-ssh-keys) to specify the `--ssh-key-value` parameter when you create an AKS cluster.

    For a Linux worker node, run the following command:

    ```azurecli
    ssh -i $env:USERPROFILE\.ssh\id_rsa clouduser@<IP address of the node>
    ```

    For a Windows worker node, run the following command:

    ```azurecli
    ssh -i $env:USERPROFILE\.ssh\id_rsa Administrator@<IP address of the node>
    ```

If you encounter SSH login issues, verify that your IP address is included in the **--ssh-auth-ip list**. To check this list, run `az aksarc show --name "$<aks_cluster_name>" --resource-group "$<resource_group_name>"` and look for `authorizedIpRanges` under `clusterVmAccessProfile`.