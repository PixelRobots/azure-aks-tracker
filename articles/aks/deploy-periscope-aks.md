---
layout: Conceptual
title: Deploy Periscope to an Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-periscope-aks
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
description: Learn how to deploy Periscope to and collect diagnostic information from an AKS cluster using the Azure CLI, Visual Studio Code, Kustomize, or Azure Copilot.
ms.topic: how-to
ms.date: 2026-08-11T00:00:00.0000000Z
ms.custom: aeo-round-2
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 18ab06ce-a0be-5f6b-3017-2fdc93f783ba
document_version_independent_id: fa108924-edd7-2fe1-fcfb-f51f99753891
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-periscope-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-periscope-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-periscope-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/911a44a7-2f6c-477c-810f-dc8b7d425cce
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/14f2b9d5-6f06-45a8-ac5f-313eaa351153
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 132d2f52-69a7-63ed-d244-8264555c5395
---

# Deploy Periscope to an Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn

[AKS Periscope](https://github.com/Azure/aks-periscope) is an open-source diagnostic tool that collects logs and diagnostic information from Azure Kubernetes Service (AKS) nodes and pods. To deploy Periscope and collect diagnostics, run [`az aks kollect`](/en-us/cli/azure/aks#az-aks-kollect) and specify your cluster and an Azure storage account. You can also deploy Periscope using the [AKS extension for Visual Studio Code](aks-extension-vs-code), [Kustomize](https://github.com/kubernetes-sigs/kustomize), or [Azure Copilot](/en-us/azure/copilot/work-aks-clusters#deploy-periscope-and-collect-logs).

Periscope collects the following information by default:

- Container logs from the `kube-system` namespace.
- Kubelet and container runtime system service logs.
- Outbound connectivity checks for the internet, API server, tunnel, Azure Container Registry, and Microsoft Container Registry.
- Node iptables data, provisioning logs, cloud-init logs, and DNS settings.
- Descriptions of pods, services, and deployments in the `kube-system` namespace.
- Kubelet command arguments and node and pod resource usage.

## Prerequisites

- You need an existing AKS cluster with Linux or Windows nodes. Periscope supports both operating systems, but the collected information differs. For more information, see [Windows and Linux functional differences](https://github.com/Azure/aks-periscope/blob/master/docs/windows-vs-linux.md).
- To deploy Periscope using the Azure CLI or Kustomize, install the [Azure CLI](/en-us/cli/azure/install-azure-cli) and sign in using [`az login`](/en-us/cli/azure/authenticate-azure-cli).
- To deploy Periscope using the Azure CLI, Visual Studio Code, or Kustomize, install [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) version 1.21 or later.
- Create or identify an [Azure storage account](/en-us/azure/storage/common/storage-account-overview) for the collected diagnostics.
- Verify that your cluster can pull images from Microsoft Container Registry (MCR).

Important

Periscope runs on your agent pool nodes and collects virtual machine (VM) and container-level data. Before you deploy Periscope, confirm that the cluster owner understands and consents to the collection and sharing of this information. For more information, see [Microsoft Support diagnostic information collection](https://azure.microsoft.com/support/legal/support-diagnostic-information-collection/).

## Deploy Periscope using the Azure CLI

The [`az aks kollect`](/en-us/cli/azure/aks#az-aks-kollect) command deploys Periscope, collects the diagnostic information, and uploads the results to [Azure Blob Storage](/en-us/azure/storage/blobs/storage-blobs-overview).

1. Install or update the `aks-preview` extension.

    ```azurecli
    az extension add --name aks-preview --upgrade
    ```
2. Set environment variables for your AKS cluster.

    ```azurecli
    RESOURCE_GROUP=<resource-group-name>
    AKS_CLUSTER=<aks-cluster-name>
    ```
3. Deploy Periscope and collect diagnostics using one of the following storage account options.

    - If the AKS diagnostic settings already specify a storage account, run the following command:

        ```azurecli
        az aks kollect \
            --resource-group $RESOURCE_GROUP \
            --name $AKS_CLUSTER
        ```
    - To use a storage account that you own, specify its resource ID:

        ```azurecli
        STORAGE_ACCOUNT_ID=<storage-account-resource-id>
        
        az aks kollect \
            --resource-group $RESOURCE_GROUP \
            --name $AKS_CLUSTER \
            --storage-account $STORAGE_ACCOUNT_ID
        ```
    - To use a storage account name and a shared access signature (SAS) token, specify a SAS token that has write permission:

        ```azurecli
        STORAGE_ACCOUNT=<storage-account-name>
        SAS_TOKEN=<sas-token>
        
        az aks kollect \
            --resource-group $RESOURCE_GROUP \
            --name $AKS_CLUSTER \
            --storage-account $STORAGE_ACCOUNT \
            --sas-token "$SAS_TOKEN"
        ```

Caution

A SAS token grants access to your storage account. Protect it like a password, don't commit it to source control, and revoke or rotate it when you no longer need it.

When collection finishes, Periscope stores the results in a blob container named after the cluster API server fully qualified domain name (FQDN). The container also includes a ZIP file that you can download for analysis or share with Microsoft Support.

### Customize the collected diagnostics

By default, Periscope collects logs and Kubernetes objects from the `kube-system` namespace. Use the optional `az aks kollect` parameters to target other resources.

- Collect all container logs in a namespace or a specific container:

    ```azurecli
    az aks kollect \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_CLUSTER \
        --container-logs "<namespace> <namespace>/<container-name>"
    ```
- Describe all objects of a resource type in a namespace or a specific object:

    ```azurecli
    az aks kollect \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_CLUSTER \
        --kube-objects "<namespace>/<resource-type> <namespace>/<resource-type>/<resource-name>"
    ```
- Collect specific Linux node log files:

    ```azurecli
    az aks kollect \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_CLUSTER \
        --node-logs "/var/log/azure-vnet.log /var/log/azure-vnet-ipam.log"
    ```
- Collect specific Windows node log files:

    ```azurecli
    az aks kollect \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_CLUSTER \
        --node-logs-windows 'C:\AzureData\CustomDataSetupScript.log'
    ```

You can combine these parameters with any storage account option from Deploy Periscope using the Azure CLI. For the complete command reference, see [`az aks kollect`](/en-us/cli/azure/aks#az-aks-kollect).

## Deploy Periscope using Visual Studio Code

The AKS extension for Visual Studio Code provides a graphical workflow for deploying Periscope and downloading the results.

1. [Install the Azure Kubernetes Service extension for Visual Studio Code](aks-extension-vs-code#installation).
2. Sign in to Azure in Visual Studio Code.
3. Confirm that the AKS cluster diagnostic settings specify a storage account. If you need to configure one, complete the following steps:
    1. In the AKS extension, right-click your cluster and select **Show In Azure Portal**.
    2. In the Azure portal, select **Monitoring** &gt; **Diagnostic settings** &gt; **Add diagnostic setting**.
    3. Enter a name for the diagnostic setting, select **Archive to a storage account**, and select a storage account.
    4. Select the logs that you want to enable, and then select **Save**.
4. In the AKS extension, right-click your cluster and select **Run AKS Periscope**.
5. If the cluster has more than one storage account in its diagnostic settings, select the account where you want to store the results.
6. When collection finishes, select **Generate Link** to create a downloadable link or a shareable link that expires after seven days. If the results don't include every node, wait for the remaining uploads and then select **Generate Link** again.

For more information, see [AKS tools and diagnostics in Visual Studio Code](https://code.visualstudio.com/docs/azure/aksextensions#_aks-periscope).

## Deploy Periscope using Kustomize

Use Kustomize when you need to inspect or override the Kubernetes resources, choose a specific Periscope release, or customize the collectors. This method requires you to manage the storage credentials and manifests directly.

1. Create a directory for the Periscope configuration, and then create a `kustomization.yaml` file in that directory.
2. Create an account SAS with the following settings. Use the shortest practical expiration time.

    - **Service**: Blob (`ss=b`).
    - **Resource types**: Service, container, and object (`srt=sco`).
    - **Permissions**: Read, list, add, create, and write (`sp=rlacw`).
    - **Allowed protocol**: HTTPS only.
3. Add the Periscope base release, image tags, storage destination, SAS key, and run ID to the file. Replace every placeholder with your values. The SAS key must include the leading question mark (`?`).

    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    resources:
      - https://github.com/Azure/aks-periscope//deployment/base?ref=<release-tag>
    
    images:
      - name: periscope-linux
        newName: mcr.microsoft.com/aks/periscope
        newTag: <image-tag>
      - name: periscope-windows
        newName: mcr.microsoft.com/aks/periscope
        newTag: <image-tag>
    
    secretGenerator:
      - name: azureblob-secret
        behavior: replace
        literals:
          - AZURE_BLOB_ACCOUNT_NAME=<storage-account-name>
          - AZURE_BLOB_CONTAINER_NAME=<container-name>
          - AZURE_BLOB_SAS_KEY=?<sas-token>
    
    configMapGenerator:
      - name: diagnostic-config
        behavior: merge
        literals:
          - DIAGNOSTIC_RUN_ID=<YYYY-MM-DDThh-mm-ssZ>
    ```

Caution

The `kustomization.yaml` file contains the SAS token in plaintext. Don't commit the file to source control. Protect the SAS like an account key, and revoke or rotate it when you no longer need it.
4. Connect `kubectl` to your AKS cluster.

    ```azurecli
    az aks get-credentials \
        --resource-group <resource-group-name> \
        --name <aks-cluster-name>
    ```
5. Deploy Periscope.

    ```bash
    kubectl apply -k <path-to-kustomize-directory>
    ```
6. Verify that the Periscope pods are running.

    ```bash
    kubectl get pods --namespace aks-periscope
    ```

For all available configuration values, optional Windows components, and instructions to run another collection, see the [AKS Periscope Kustomize deployment guide](https://github.com/Azure/aks-periscope#kustomize-deployment).

## Deploy Periscope using Azure Copilot

Use [Azure Copilot to deploy Periscope to an AKS cluster](/en-us/azure/copilot/work-aks-clusters#deploy-periscope-and-collect-logs). If Azure Copilot can't determine the cluster from the current context, it prompts you to select one. After you select the cluster, Azure Copilot might ask you to confirm the deployment details before it deploys Periscope.

Sample prompts include:

- "Help me deploy Periscope to my AKS cluster"
- "Deploy Periscope to my cluster"
- "Add Periscope to my cluster"
- "Add periscope logging to my cluster"
- "Help me collect diagnostics logs from my AKS cluster"