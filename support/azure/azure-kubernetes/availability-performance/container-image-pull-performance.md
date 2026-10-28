---
layout: Conceptual
title: Improve container image pull performance in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/container-image-pull-performance
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
description: Learn how to improve container image pull performance in AKS, compare parallel and serialized pulls, and reduce node startup latency. Get started now.
ms.date: 2026-10-23T00:00:00.0000000Z
ms.reviewer: slibbing, schaffererin, v-weizhu, jiayil, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
ai-usage: ai-assisted
locale: en-us
document_id: dfba110f-6300-dd28-4763-bf114918fcad
document_version_independent_id: dfba110f-6300-dd28-4763-bf114918fcad
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/container-image-pull-performance.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurepowershell
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/container-image-pull-performance
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/container-image-pull-performance.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f4ac0a4d-6828-0b9b-e931-66636e78385a
---

# Improve container image pull performance in AKS - Azure | Microsoft Learn

## Summary

This article explains the factors that affect container image pull performance in Azure Kubernetes Service (AKS) and describes how to reduce pod startup latency.

The image size and layer count, node CPU and disk performance, network connectivity, registry location and service tier, and the number of concurrent pulls can affect container image pull performance. For large supported images, [Artifact Streaming](/en-us/azure/aks/artifact-streaming) can reduce pod startup time. To isolate the source of slow pulls, review the pod's `Pulling`, `Pulled`, and `Started` events, and follow the guidance in [Troubleshoot ACR performance](/en-us/azure/container-registry/container-registry-troubleshoot-performance).

This article provides methods to improve container image pull performance in Azure Kubernetes Service (AKS).

## Compare serialized and parallel image pulls

Two types of container image pulls exist: serialized and parallel image pulls.

In AKS versions earlier than 1.31, AKS enables serialized image pulls by default. Starting in AKS version 1.31, AKS pulls container images in parallel by default. Typically, serialized image pulls are less performant than parallel image pulls, particularly when the service tries to pull large or numerous container images.

However, you might still experience decreased performance when using parallel image pulls compared to using serial image pulls. Trying to pull large or numerous images in a parallel manner might throttle the disk. This throttling is especially true when you use unoptimized disk and VM resources. In this situation, you might notice that the time to pull the first images is faster in a serial setup, but the time to pull all images is faster in a parallel setup. Depending on your workload needs, consider using the following steps to scale your disk and VM resources or toggle the image pull type.

## Improve image pull performance in AKS versions earlier than 1.31

Upgrade to a currently supported AKS version. Parallel image pulls are enabled by default starting with AKS 1.31 and generally improve image pull performance.

## Improve image pull performance in AKS 1.31 and later versions

If you notice that parallel image pulls increase the latency of operations compared to serialized image pulls, try one or more methods in the following list to improve performance:

- Use [ephemeral OS disks](/en-us/azure/aks/cluster-configuration#ephemeral-os) for high-performance local storage and to reduce disk throughput bottlenecks.
- Increase the [managed OS disk size](/en-us/azure/aks/cluster-configuration#default-os-disk-sizing) to get a higher disk performance tier and prevent throttling.
- Use a [newer VM size](/en-us/azure/aks/aks-virtual-machine-sizes) to improve CPU, storage, and network performance.
- Use a [larger VM size](/en-us/azure/aks/aks-virtual-machine-sizes) to increase available CPU cores and avoid VM throttling.
- Enable [Artifact Streaming](/en-us/azure/aks/artifact-streaming) to stream image layers on demand and reduce startup time for large images.
- Use [Prepared Image Specification (PIS)](/en-us/azure/aks/prepared-image-specification-overview) to pre-cache stable container images for faster node scale-out.
- Toggle image pull type

### Toggle image pull type

Caution

This setting applies to **all existing and future AKS clusters in the subscription.** When possible, test the setting in a test subscription first. Consider opting in to this solution only as a last resort.

Use the following AFEC flag instructions to toggle parallel images on or off.

Behavior expectation if the feature is registered:

- By default, upgrading any node pool or cluster to Kubernetes 1.31 from a version that's earlier than 1.31 causes serial image pulling. Upgrading in Kubernetes 1.31 or a later version causes parallel pulling.
- Node pools or clusters that are already running Kubernetes 1.31 but were created before the subscription registration initially use parallel image pulling. However, any subsequent node image upgrade or Kubernetes version upgrade causes the node pool or cluster to use serial image pulling.
- For any new clusters or node pools that are created or upgraded to Kubernetes versions earlier than 1.31, registering for this feature has no effect. This limitation exists because parallel image pulling applies only to versions 1.31 and later.
- Performing an empty `PUT` on existing Kubernetes 1.31 node pools or clusters (that were created before subscription registration) doesn't immediately switch parallel image pulling to serial pulling. To trigger the change, the node must undergo a reimage. A reimage occurs only during a Kubernetes or node image upgrade. However, the `PUT` operation updates the flag in the database, and the change takes effect during the next upgrade.

# [Azure CLI](#tab/azure-cli)
#### Enable serialized image pulls

1. Check the feature registration state.

    ```azurecli
    az feature list \
      --namespace Microsoft.ContainerService \
      --subscription <subscription-id> \
      --query "[?contains(name, 'DisableParallelImagePulls')].{Name:name, State:properties.state}" \
      --output table
    ```

    The output resembles the following example.

    ```output
    Name                                                   State
    -----------------------------------------------------  -------------
    Microsoft.ContainerService/DisableParallelImagePulls   NotRegistered
    ```
2. Register the feature.

    ```azurecli
    az feature register \
      --namespace Microsoft.ContainerService \
      --name DisableParallelImagePulls \
      --subscription <subscription-id>
    ```
3. Wait until the feature reports `Registered`, and then register the `Microsoft.ContainerService` resource provider.

    ```azurecli
    az provider register \
      --namespace Microsoft.ContainerService \
      --subscription <subscription-id> \
      --wait
    
    az provider show \
      --namespace Microsoft.ContainerService \
      --subscription <subscription-id> \
      --query registrationState \
      --output tsv
    ```
4. Apply the setting by using one of the following options:

    - Update and reimage an existing node pool.

        ```azurecli
        az aks nodepool update \
          --resource-group <resource-group> \
          --cluster-name <cluster-name> \
          --name <node-pool-name> \
          --max-surge 10% \
          --subscription <subscription-id>
        
        az aks nodepool upgrade \
          --resource-group <resource-group> \
          --cluster-name <cluster-name> \
          --name <node-pool-name> \
          --node-image-only \
          --subscription <subscription-id>
        ```
    - Create a new node pool, which uses the setting when AKS provisions its nodes.

        ```azurecli
        az aks nodepool add \
          --resource-group <resource-group> \
          --cluster-name <cluster-name> \
          --name <new-node-pool-name> \
          --node-count <node-count> \
          --subscription <subscription-id>
        ```

#### Roll back to parallel image pulls

1. Unregister the feature.

    ```azurecli
    az feature unregister \
      --namespace Microsoft.ContainerService \
      --name DisableParallelImagePulls \
      --subscription <subscription-id>
    ```
2. Wait until the feature reports `Unregistered`, and then register the `Microsoft.ContainerService` resource provider.

    ```azurecli
    az feature list \
      --namespace Microsoft.ContainerService \
      --subscription <subscription-id> \
      --query "[?contains(name, 'DisableParallelImagePulls')].{Name:name, State:properties.state}" \
      --output table
    
    az provider register \
      --namespace Microsoft.ContainerService \
      --subscription <subscription-id> \
      --wait
    
    az provider show \
      --namespace Microsoft.ContainerService \
      --subscription <subscription-id> \
      --query registrationState \
      --output tsv
    ```
3. Apply the rollback by using one of the following options:

    - Update and reimage an existing node pool.

        ```azurecli
        az aks nodepool update \
          --resource-group <resource-group> \
          --cluster-name <cluster-name> \
          --name <node-pool-name> \
          --max-surge 10% \
          --subscription <subscription-id>
        
        az aks nodepool upgrade \
          --resource-group <resource-group> \
          --cluster-name <cluster-name> \
          --name <node-pool-name> \
          --node-image-only \
          --subscription <subscription-id>
        ```
    - Create a new node pool, which uses the rollback setting when AKS provisions its nodes.

        ```azurecli
        az aks nodepool add \
          --resource-group <resource-group> \
          --cluster-name <cluster-name> \
          --name <new-node-pool-name> \
          --node-count <node-count> \
          --subscription <subscription-id>
        ```

After the reimage finishes, kubelet uses `serializeImagePulls: false` and pulls images in parallel.

# [Azure PowerShell](#tab/azure-powershell)
#### Enable serialized image pulls

1. Set the subscription context and check the feature registration state.

    ```azurepowershell
    $subscriptionId = "<subscription-id>"
    $resourceGroupName = "<resource-group>"
    $clusterName = "<cluster-name>"
    $nodePoolName = "<node-pool-name>"
    
    Set-AzContext -SubscriptionId $subscriptionId
    
    Get-AzProviderFeature `
      -ProviderNamespace Microsoft.ContainerService `
      -FeatureName DisableParallelImagePulls
    ```

    The output resembles the following example.

    ```output
    FeatureName                ProviderName                 RegistrationState
    -----------                ------------                 -----------------
    DisableParallelImagePulls  Microsoft.ContainerService   NotRegistered
    ```
2. Register the feature.

    ```azurepowershell
    Register-AzProviderFeature `
      -ProviderNamespace Microsoft.ContainerService `
      -FeatureName DisableParallelImagePulls
    ```
3. Check the feature state until it reports `Registered`, and then register the `Microsoft.ContainerService` resource provider.

    ```azurepowershell
    Get-AzProviderFeature `
      -ProviderNamespace Microsoft.ContainerService `
      -FeatureName DisableParallelImagePulls |
      Select-Object FeatureName, ProviderName, RegistrationState
    
    Register-AzResourceProvider `
      -ProviderNamespace Microsoft.ContainerService
    
    Get-AzResourceProvider `
      -ProviderNamespace Microsoft.ContainerService |
      Select-Object ProviderNamespace, RegistrationState -Unique
    ```
4. Apply the setting by using one of the following options:

    - Update and reimage an existing node pool.

        ```azurepowershell
        Update-AzAksNodePool `
          -ResourceGroupName $resourceGroupName `
          -ClusterName $clusterName `
          -Name $nodePoolName `
          -MaxSurge "10%" `
          -SubscriptionId $subscriptionId
        
        Update-AzAksNodePool `
          -ResourceGroupName $resourceGroupName `
          -ClusterName $clusterName `
          -Name $nodePoolName `
          -NodeImageOnly `
          -SubscriptionId $subscriptionId
        ```
    - Create a new node pool, which uses the setting when AKS provisions its nodes.

        ```azurepowershell
        New-AzAksNodePool `
          -ResourceGroupName $resourceGroupName `
          -ClusterName $clusterName `
          -Name "<new-node-pool-name>" `
          -Count 3 `
          -SubscriptionId $subscriptionId
        ```

#### Roll back to parallel image pulls

1. Unregister the feature.

    ```azurepowershell
    Unregister-AzProviderFeature `
      -ProviderNamespace Microsoft.ContainerService `
      -FeatureName DisableParallelImagePulls `
      -Confirm:$false
    ```
2. Check the feature state until it reports `Unregistered`, and then register the `Microsoft.ContainerService` resource provider.

    ```azurepowershell
    Get-AzProviderFeature `
      -ProviderNamespace Microsoft.ContainerService `
      -FeatureName DisableParallelImagePulls |
      Select-Object FeatureName, ProviderName, RegistrationState
    
    Register-AzResourceProvider `
      -ProviderNamespace Microsoft.ContainerService
    
    Get-AzResourceProvider `
      -ProviderNamespace Microsoft.ContainerService |
      Select-Object ProviderNamespace, RegistrationState -Unique
    ```
3. Apply the rollback by using one of the following options:

    - Update and reimage an existing node pool.

        ```azurepowershell
        Update-AzAksNodePool `
          -ResourceGroupName $resourceGroupName `
          -ClusterName $clusterName `
          -Name $nodePoolName `
          -MaxSurge "10%" `
          -SubscriptionId $subscriptionId
        
        Update-AzAksNodePool `
          -ResourceGroupName $resourceGroupName `
          -ClusterName $clusterName `
          -Name $nodePoolName `
          -NodeImageOnly `
          -SubscriptionId $subscriptionId
        ```
    - Create a new node pool, which uses the rollback setting when AKS provisions its nodes.

        ```azurepowershell
        New-AzAksNodePool `
          -ResourceGroupName $resourceGroupName `
          -ClusterName $clusterName `
          -Name "<new-node-pool-name>" `
          -Count 3 `
          -SubscriptionId $subscriptionId
        ```

After the reimage finishes, kubelet uses `serializeImagePulls: false` and pulls images in parallel.

---