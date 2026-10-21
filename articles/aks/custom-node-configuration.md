---
layout: Conceptual
title: Customize the Node Configuration for Azure Kubernetes Service (AKS) Node Pools - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/custom-node-configuration
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
description: Learn how to customize the configuration on Azure Kubernetes Service (AKS) cluster nodes and node pools.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.date: 2026-10-07T00:00:00.0000000Z
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: b0742c30-d2b9-d79e-8c2d-5e80165a6192
document_version_independent_id: 93830ca8-012d-fc0a-fa85-9f12fc114b40
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/custom-node-configuration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/custom-node-configuration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/custom-node-configuration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 69aaff3a-6c1d-d85a-3f1a-552e88e8374b
---

# Customize the Node Configuration for Azure Kubernetes Service (AKS) Node Pools - Azure Kubernetes Service | Microsoft Learn

By customizing your node configuration, you can adjust operating system (OS) settings or kubelet parameters to match the needs of your workloads. When you create an AKS cluster or add a node pool to your cluster, you can customize a subset of commonly used OS and kubelet settings. To configure settings beyond this subset, [use a daemon set to customize your needed configurations without losing AKS support for your nodes](support-policies#shared-responsibility).

## Prerequisites

As the service adds support for new settings and kubelet parameters, it might require preview feature flag registration. If a preview flag is required, the [custom node configuration parameters reference](custom-node-configuration-reference) calls it out.

The `kubeReserved`, `hardEvictionThreshold`, `softEvictionThreshold`, `softEvictionGracePeriod`, and `evictionMaxPodGracePeriodInSeconds` kubelet settings are in preview and require the `CustomNodeConfigPreview` feature flag. These settings let you customize resource reservations and eviction thresholds, which are also configured by AKS Node Hardening. For registration steps, default values, and examples, see [Node Hardening (preview) in AKS](node-hardening).

## Create custom node configuration files for AKS node pools

To change the OS and kubelet configuration, create a new configuration file with the parameters and settings you want. If you don't specify a value for a parameter, the default value is used.

Note

The following examples show common configuration settings. Modify the settings to meet your workload requirements. For the full list of supported custom configuration parameters, see [Custom node configuration parameters for AKS](custom-node-configuration-reference).

### Kubelet configuration

# [Linux node pools](#tab/linux-node-pools)
Create a `linuxkubeletconfig.json` file with the following contents:

```json
{
 "cpuManagerPolicy": "static",
 "cpuCfsQuota": true,
 "cpuCfsQuotaPeriod": "200ms",
 "imageGcHighThreshold": 90,
 "imageGcLowThreshold": 70,
 "topologyManagerPolicy": "best-effort",
 "allowedUnsafeSysctls": [
  "kernel.msg*",
  "net.*"
],
 "failSwapOn": false
}
```

To customize kube-reserved resources and eviction thresholds on Linux node pools, see [Customize Node Hardening settings](node-hardening#customize-node-hardening-settings).

# [Windows node pools](#tab/windows-node-pools)
Note

Windows kubelet custom configuration only supports the parameters `imageGcHighThreshold`, `imageGcLowThreshold`, `containerLogMaxSizeMB`, and `containerLogMaxFiles`.

Create a `windowskubeletconfig.json` file with the following contents:

```json
{
 "imageGcHighThreshold": 90,
 "imageGcLowThreshold": 70,
 "containerLogMaxSizeMB": 20,
 "containerLogMaxFiles": 6
}
```

---

### OS configuration

# [Linux node pools](#tab/linux-node-pools)
Create a `linuxosconfig.json` file with the following contents:

```json
{
 "transparentHugePageEnabled": "madvise",
 "transparentHugePageDefrag": "defer+madvise",
 "swapFileSizeMB": 1500,
 "sysctls": {
  "netCoreSomaxconn": 163849,
  "netIpv4TcpTwReuse": true,
  "netIpv4IpLocalPortRange": "32000 60000"
 }
}
```

# [Windows node pools](#tab/windows-node-pools)
Currently unsupported.

---

## Create an AKS cluster using custom configuration files

Note

Keep the following information in mind when using custom configuration files when creating a new AKS cluster:

- If you specify a configuration when creating a cluster, the configuration applies only to the nodes in the initial node pool. The cluster retains default values for any settings not configured in the JSON file.
- `CustomLinuxOsConfig` isn't supported for the Windows OS type.
- The preview `kubeReserved` and eviction threshold kubelet settings are supported only for Linux node pools and require the `CustomNodeConfigPreview` feature flag. For registration steps, see [Node Hardening (preview) in AKS](node-hardening).

Create a new cluster using custom configuration files by running the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and specifying your configuration files for the `--kubelet-config` and `--linux-os-config` parameters. The following example command creates a new cluster with the custom `./linuxkubeletconfig.json` and `./linuxosconfig.json` files:

```azurecli
az aks create --name <cluster-name> --resource-group <resource-group-name> --kubelet-config ./linuxkubeletconfig.json --linux-os-config ./linuxosconfig.json
```

## Add a node pool by using custom configuration files

Note

Keep the following information in mind when using custom configuration files to add a new node pool to an existing AKS cluster:

- When you add a Linux node pool to an existing cluster, you can specify the kubelet configuration, OS configuration, or both. When you add a Windows node pool to an existing cluster, you can only specify the kubelet configuration. If you specify a configuration when adding a node pool, the configuration applies only to the nodes in the new node pool. The node pool retains default values for any settings not configured in the JSON file.
- `CustomKubeletConfig` is supported for Linux and Windows node pools.
- The preview `kubeReserved` and eviction threshold kubelet settings are supported only for Linux node pools and require the `CustomNodeConfigPreview` feature flag. For registration steps, see [Node Hardening (preview) in AKS](node-hardening).

# [Linux node pools](#tab/linux-node-pools)
Create a new Linux node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks#az-aks-create) command and specifying your configuration files for the `--kubelet-config` and `--linux-os-config` parameters. The following example command creates a new Linux node pool with the custom `./linuxkubeletconfig.json` file:

```azurecli
az aks nodepool add --name <node-pool-name> --cluster-name <cluster-name> --resource-group <resource-group-name> --kubelet-config ./linuxkubeletconfig.json
```

# [Windows node pools](#tab/windows-node-pools)
Create a new Windows node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks#az-aks-create) command and specifying your configuration file for the `--kubelet-config` parameter. The following example command creates a new Windows node pool with the custom `./windowskubeletconfig.json` file:

```azurecli
az aks nodepool add --name <node-pool-name> --cluster-name <cluster-name> --resource-group <resource-group-name> --os-type Windows --kubelet-config ./windowskubeletconfig.json
```

---

## Confirm settings were applied

After you apply custom node configuration, you can confirm the settings were applied to the nodes by [connecting to the host](node-access) and verifying `sysctl` or configuration changes were made on the filesystem.

## Review supported custom configuration parameters

For the full list of supported kubelet and Linux OS configuration parameters, allowed values, defaults, and descriptions, see [Custom node configuration parameters for AKS](custom-node-configuration-reference).

## Considerations for custom node configurations

Keep the following considerations in mind when customizing your node configuration:

- Node image upgrades reapply custom node configurations.
- Scale-out operations preserve custom node configurations.
- AKS doesn't perform pre-flight validation for every custom node configuration parameter or value. Ensure that the custom node configuration parameters and values you specify are supported and valid to avoid potential issues with your cluster nodes.
- The preview `kubeReserved` and eviction threshold kubelet settings are available only on Linux node pools. If you configure them, use the supported ranges, units, and pairing rules in the [custom node configuration parameters reference](custom-node-configuration-reference).
- Default values for custom node configuration parameters often change with new operating system versions. When applying custom node configurations, review the default values for the parameters you're configuring to ensure that your custom settings are appropriate for the OS version of your cluster nodes.
- Limit the number of people who have permissions to modify the custom node configuration to prevent unintended consequences on cluster stability and performance. Consider using [Microsoft Entra ID authorization for the Kubernetes API](entra-id-authorization) to restrict access to cluster configuration settings.
- Separate node pools with custom configurations from those without custom configurations to prevent unintended consequences on workloads that might be sensitive to certain configuration changes. For example, if you have a critical workload that requires specific kubelet settings, consider isolating that workload to a dedicated node pool with the necessary custom kubelet configuration.