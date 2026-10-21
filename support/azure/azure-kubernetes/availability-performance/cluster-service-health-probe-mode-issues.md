---
layout: Conceptual
title: Troubleshoot AKS service load balancer health probe mode - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/cluster-service-health-probe-mode-issues
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
description: Troubleshoot AKS service load balancer health probe mode issues, resolve common failures quickly, and use the steps to restore healthy traffic routing.
ms.date: 2024-06-03T00:00:00.0000000Z
ms.reviewer: niqi, cssakscic, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance, devx-track-azurecli, innovation-engine
locale: en-us
document_id: 50e810b3-37b6-c7d6-21d7-850d45ffe4d3
document_version_independent_id: 50e810b3-37b6-c7d6-21d7-850d45ffe4d3
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/cluster-service-health-probe-mode-issues.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/cluster-service-health-probe-mode-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/cluster-service-health-probe-mode-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bf572637-ef3e-2c36-2c5b-2bcfba84fb26
---

# Troubleshoot AKS service load balancer health probe mode - Azure | Microsoft Learn

## Summary

The health probe mode feature enables you to configure how Azure Load Balancer checks the health of the nodes in your Azure Kubernetes Service (AKS) cluster. You can choose between two modes: Shared and ServiceNodePort. The Shared mode uses a single health probe for all external traffic policy cluster services that use the same load balancer. In contrast, the ServiceNodePort mode uses a separate health probe for each service. The Shared mode can reduce the number of health probes and improve the performance of the load balancer, but it requires some extra components to work properly. To enable this feature, see How to enable the health probe mode feature by using Azure CLI.

This article describes some common problems with using the health probe mode feature in an AKS cluster and helps you troubleshoot and resolve these problems.

## Symptoms

When you create or update an AKS cluster by using the Azure CLI and enable the health probe mode feature by using the `--cluster-service-load-balancer-health-probe-mode Shared` flag, the following problems can occur:

- The load balancer doesn't distribute traffic to the nodes as expected.
- The load balancer reports unhealthy nodes even if they're healthy.
- The health-probe-proxy sidecar container crashes or doesn't start.
- The cloud-node-manager pod crashes or doesn't start.

The following operations also happen:

1. RP frontend checks if the request is valid and updates the corresponding property in the LoadBalancerProfile.
2. RP async calls the cloud provider config secret reconciler to update the cloud provider config secret based on the LoadBalancerProfile.
3. Overlaymgr reconciles the cloud-node-manager chart to enable the health-probe-proxy sidecar.

## Initial troubleshooting

To troubleshoot these problems, follow these steps:

1. First, connect to your AKS cluster by using the Azure CLI:

    ```azurecli
    export RESOURCE_GROUP="aks-rg"
    export AKS_CLUSTER_NAME="aks-cluster"
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing
    ```
2. Next, check the RP frontend log to see if the health probe mode in the LoadBalancerProfile is properly configured. Use the `az aks show` command to view the LoadBalancerProfile property of your cluster.

    ```azurecli
    export RESOURCE_GROUP="aks-rg"
    export AKS_CLUSTER_NAME="aks-cluster"
    az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "networkProfile.loadBalancerProfile"
    ```

    Results:

    ```output
    {
      "clusterServiceLoadBalancerHealthProbeMode": "Shared",
      "managedOutboundIPs": null,
      "outboundIPs": null,
      "outboundIPPrefixes": null,
      "allocatedOutboundPorts": null,
      "effectiveOutboundIPs": [
        {
          "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MC_aks-rg_aks-cluster_eastus2/providers/Microsoft.Network/publicIPAddresses/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        }
      ],
      "idleTimeoutInMinutes": 30,
      "loadBalancerSku": "standard",
      "managedOutboundIPv6": null
    }
    ```
3. Check the cloud provider configuration. In modern AKS clusters, the cloud provider configuration is managed internally and the `ccp` namespace doesn't exist. Instead, check for cloud provider related resources and verify the cloud-node-manager pods are running properly:

    ```bash
    # Check for cloud provider related ConfigMaps in kube-system
    kubectl get configmap -n kube-system | grep -i azure
    
    # Check if cloud-node-manager pods are running (indicates cloud provider integration is working)
    kubectl get pods -n kube-system | grep cloud-node-manager
    
    # Check the azure-ip-masq-agent-config if it exists
    kubectl get configmap azure-ip-masq-agent-config-reconciled -n kube-system -o yaml 2>/dev/null || echo "ConfigMap not found"
    ```

    Results:

    ```output
    configmap/azure-ip-masq-agent-config-reconciled   1      11h
    
    cloud-node-manager-rfb2w                        2/2     Running   0          16m
    ```
4. Check the chart or overlay daemonset cloud-node-manager to see if the health-probe-proxy sidecar container is enabled. Use the `kubectl get ds` command to view the daemonset.

    ```shell
    kubectl get ds -n kube-system cloud-node-manager -o yaml
    ```

    Results:

    ```output
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: cloud-node-manager
      namespace: kube-system
      ...
    spec:
      template:
        spec:
          containers:
          - name: cloud-node-manager
            image: mcr.microsoft.com/oss/kubernetes/azure-cloud-node-manager:xxxxxxxx
          - name: health-probe-proxy
            image: mcr.microsoft.com/oss/kubernetes/azure-health-probe-proxy:xxxxxxxx
          ...
    ```

## Cause 1: The health probe mode isn't Shared or ServiceNodePort

The health probe mode feature works only with these two modes. If you use any other mode, the feature doesn't work.

### Solution 1: Use the correct health probe mode

Use the Shared or ServiceNodePort mode when creating or updating your cluster. Use the `--cluster-service-load-balancer-health-probe-mode` flag to specify the mode.

## Cause 2: The toggle for the health probe mode feature is off

The AKS team controls the toggle for the health probe mode feature. If the toggle is off, the feature doesn't work.

### Solution 2: Turn on the toggle

Contact the AKS team to check if the toggle for the health probe mode feature is on or off. If it's off, ask them to turn it on for your subscription.

## Cause 3: The load balancer SKU is Basic

The health probe mode feature works only with the Standard Load Balancer SKU. If you use the Basic Load Balancer SKU, the feature doesn't work.

### Solution 3: Use the Standard Load Balancer SKU

Use the Standard Load Balancer SKU when creating or updating your cluster. Use the `--load-balancer-sku` flag to specify the SKU.

## Cause 4: The feature isn't registered

You need to register the health probe mode feature on your subscription. If the feature isn't registered, it doesn't work.

### Solution 4: Register the feature

Before you create or update your cluster, register the feature for your subscription. Use the `az feature register` command to register the feature.

```azurecli
export FEATURE_NAME="EnableSLBSharedHealthProbePreview"
export PROVIDER_NAMESPACE="Microsoft.ContainerService"
az feature register --name $FEATURE_NAME --namespace $PROVIDER_NAMESPACE
```

Results:

```output
{
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/providers/Microsoft.Features/providers/Microsoft.ContainerService/features/EnableAKSClusterServiceLoadBalancerHealthProbeMode",
  "name": "Microsoft.ContainerService/EnableAKSClusterServiceLoadBalancerHealthProbeMode",
  "properties": {
    "state": "Registering"
  },
  "type": "Microsoft.Features/providers/features"
}
```

## Cause 5: The Kubernetes version is earlier than v1.28.0

The health probe mode feature requires a minimum Kubernetes version of v1.28.0. If you use an older version, the feature doesn't work.

### Solution 5: Upgrade the Kubernetes version

Use Kubernetes v1.28.0 or a later version when creating or updating your cluster. Use the `--kubernetes-version` flag to specify the version.

## Known issues

For Windows, the kube-proxy component doesn't start until you create the first non-HPC pod in a node. This issue affects the health probe mode feature and causes the load balancer to report unhealthy nodes. It will be fixed in a future update.

## How to enable the health probe mode feature by using Azure CLI

To enable the health probe mode feature, run one of the following commands:

Enable `ServiceNodePort` health probe mode (default) for a cluster:

```shell
export RESOURCE_GROUP="aks-rg"
export AKS_CLUSTER_NAME="aks-cluster"
az aks update --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --cluster-service-load-balancer-health-probe-mode ServiceNodePort 
```

Results:

```output
{
  "name": "aks-cluster",
  "location": "eastus2",
  "resourceGroup": "aks-rg",
  "kubernetesVersion": "1.28.x",
  "provisioningState": "Succeeded",
  "loadBalancerProfile": {
    "clusterServiceLoadBalancerHealthProbeMode": "ServiceNodePort",
    ...
  },
  ...
}
```

Enable `Shared` health probe mode for a cluster:

```shell
export RESOURCE_GROUP="MyAksResourceGroup"
export AKS_CLUSTER_NAME="MyAksCluster"
az aks update --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --cluster-service-load-balancer-health-probe-mode Shared
```

Results:

```output
{
  "name": "MyAksCluster",
  "location": "eastus2",
  "resourceGroup": "MyAksResourceGroup",
  "kubernetesVersion": "1.28.x",
  "provisioningState": "Succeeded",
  "loadBalancerProfile": {
    "clusterServiceLoadBalancerHealthProbeMode": "Shared",
    ...
  },
  ...
}
```