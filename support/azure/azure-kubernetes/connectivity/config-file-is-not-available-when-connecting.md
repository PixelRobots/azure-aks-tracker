---
layout: Conceptual
title: AKS config file missing when connecting to cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/config-file-is-not-available-when-connecting
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
description: Fix AKS connection errors caused by a missing or invalid config file and restore cluster access quickly. Follow the steps to reconnect now.
ms.date: 2026-10-30T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, v-leedennis, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
ai-usage: ai-assisted
locale: en-us
document_id: 7910039f-6211-5455-a543-2b109b73eaae
document_version_independent_id: 7910039f-6211-5455-a543-2b109b73eaae
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/config-file-is-not-available-when-connecting.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/config-file-is-not-available-when-connecting
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/config-file-is-not-available-when-connecting.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: b3aa2a93-503e-045c-ebd4-0f3b631eec17
---

# AKS config file missing when connecting to cluster - Azure | Microsoft Learn

## Summary

This article describes how to fix issues that occur when you can't connect to an Azure Kubernetes Service (AKS) cluster because of a missing or invalid *config* file.

## Prerequisites

Ensure that you meet the following prerequisites:

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Kubernetes cluster command-line tool ([kubectl](https://kubernetes.io/docs/tasks/tools/)). You can alternatively install kubectl by running the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command in Azure CLI.

## Symptoms

During a cluster connection attempt, an error message similar to the following text appears.

```output
Unable to connect to the server: dial tcp [::1]:8080: connectex: No connection could be made because the target machine actively refused it. 

error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

## Causes

The [kubectl tool](https://kubernetes.io/docs/reference/kubectl/overview/) and other Kubernetes connection tools use a local configuration file named *config*. The *config* file contains authentication credentials and details to connect to the cluster. By default:

- The [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command in Azure CLI, which is used to get access credentials for a managed Kubernetes cluster, modifies the *~/.kube/config* file.
- The kubectl command uses the [kubeconfig (kubectl configuration) file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) in the *$HOME/.kube* directory.

So what happens during an attempted Kubernetes session depends on the user who's running the kubectl command. If you sign in as user A and run both commands, here's what happens:

- The `az aks get-credentials` command tries to add the new kubeconfig parameters in the *C:\Users\A\.kube\config* file.
- The kubectl command tries to search the *C:\Users\A\.kube\config* file.

But for kubectl, if the pointer to the kubeconfig file changes, the file that's used for accessing the cluster is in a different location.

Note

A kubeconfig file is a reference to a file that contains configuration parameters for accessing Kubernetes clusters. It doesn't necessarily refer to a file that's named *kubeconfig*.

The error occurs if one of the following scenarios occurs.

## Cause 1: The config file doesn't exist

The config file doesn't exist on your machine.

### Solution: Save the credentials to the config file

Load the config file by running the `az aks get-credentials` command in Azure CLI, which saves the credentials. If you don't want to use the default location, specify the `--file <config-file-location>` parameter with the location of the config file (for example, *~/Dir1/Dir2/config* or *C:\Dir1\Dir2\config*).

```azurecli
az aks get-credentials --resource-group <cluster-resource-group> \
    --name <cluster-name> \
    [--file <config-file-location>]
```

## Cause 2: The config file is in the wrong directory

The config file is on your machine, but it's in a different directory from where the `az aks get-credentials` command and the kubectl tool expect it to be.

### Solution: Move the config file, save the credentials again, or change the KUBECONFIG environment variable

Take one or more of the following actions:

- Move the config file to the directory you want.
- Run the `az aks get-credentials` command. Specify the location you want if it isn't the default location.

    ```azurecli
    az aks get-credentials --resource-group <cluster-resource-group> \
        --name <cluster-name> \
        [--file <config-file-location>]
    ```
- Use one of the following options to change where kubectl looks for configuration parameters:

    - Modify the `KUBECONFIG` environment variable to point to the config file's current location. For more information, see [Set the KUBECONFIG environment variable](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#set-the-kubeconfig-environment-variable).
    - Run the [kubectl config](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config) command with the `--kubeconfig=<config-file-location>` parameter.

## Cause 3: The config file is expired or corrupted

The config file is on your machine. It's also in the expected directory for the `az aks get-credentials` command and the kubectl tool. But the file is expired or corrupted.

### Solution: Reestablish the credentials

Reestablish the credentials because the existing credentials might be expired or corrupted. In that case, run the `az aks get-credentials` command with the `--overwrite-existing` parameter.

```azurecli
az aks get-credentials --resource-group <cluster-resource-group> \
    --name <cluster-name> \
    --overwrite-existing \
    [--file <config-file-location>]
```