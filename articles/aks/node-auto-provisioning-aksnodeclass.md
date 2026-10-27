---
layout: Conceptual
title: Configure AKSNodeClass Resources for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-provisioning-aksnodeclass
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
description: Learn how to configure Azure-specific settings for AKS node auto-provisioning using AKSNodeClass resources.
ms.topic: how-to
ms.custom: devx-track-azurecli, aks-scaling
ms.date: 2026-09-18T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 19fb826e-d7ad-d6cc-c113-ebfbb67986d9
document_version_independent_id: d317240d-908e-8f7e-379b-96bcbdf2d660
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-provisioning-aksnodeclass.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-provisioning-aksnodeclass
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-provisioning-aksnodeclass.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/2d774b87-7dcb-40bf-a0b9-5a7a9efff0d1
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/89dc5f37-0e4e-4b05-ad87-5fcd2b941a8a
platformId: 1aaa216b-9f0e-644b-b6cc-b67cdb3db6a3
---

# Configure AKSNodeClass Resources for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to configure `AKSNodeClass` resources to define Azure-specific settings for node auto-provisioning (NAP) in Azure Kubernetes Service (AKS) using Karpenter. `AKSNodeClass` allows you to customize various aspects of the nodes that Karpenter provisions, such as the virtual machine (VM) image, operating system (OS) disk size, maximum pods per node, and kubelet configurations.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Overview of AKSNodeClass resources

`AKSNodeClass` resources enable you to configure Azure-specific settings for NAP. Each [`NodePool` resource](node-auto-provisioning-node-pools) must reference an `AKSNodeClass` using `spec.template.spec.nodeClassRef`. You can have multiple `NodePools` that point to the same `AKSNodeClass`, allowing you to share common Azure configurations across different node pools.

Important

Changing a setting on an existing `AKSNodeClass` doesn't reconfigure running nodes in place. NAP marks the nodes provisioned from the previous configuration as *drifted* and replaces them, subject to the disruption controls on the referencing `NodePool` resources. The `tags` field is the only exception, because tag changes apply to existing Azure resources without replacing the node. To learn more, see [Drift](node-auto-provisioning-disruption#drift) and [Disruption budgets](node-auto-provisioning-disruption#disruption-budgets). Before you modify an `AKSNodeClass` that production workloads use, review this guidance.

## Image family configuration

The `imageFamily` field sets the default VM image and bootstrapping logic for nodes provisioned through the `AKSNodeClass`. If you don't specify an image family, the default OS version according to your Kubernetes version is used. GPUs are supported with both image families on compatible VM sizes. For more information about the default OS version per Kubernetes version, see the [AKS OS Version documentation](upgrade-os-version).

### Supported image families

- **`Ubuntu`**: Ubuntu is the default Linux distribution for AKS nodes.
    - OS version defaults change based on your Kubernetes version. Ubuntu 22.04 is default for Kubernetes versions 1.25 to 1.33. Ubuntu 24.04 is default for Kubernetes versions 1.34 and later.
- **`AzureLinux`**: Azure Linux is Microsoft's alternative Linux distribution for AKS workloads. For more information, see the [Azure Linux documentation](/en-us/azure/aks/use-azure-linux).
- **`AzureContainerLinux`**: Azure Container Linux is supported with AKS 1.34 and later. Use a generation 2 VM and explicitly enable both Trusted Launch settings, even when you don't otherwise require them:
    - Set `security.trustedLaunch.vtpm` to `true`.
    - Set `security.trustedLaunch.secureBoot` to `true`.
    - If you set `osDiskSizeGB`, use a value of at least 60.
    - Don't combine this image family with settings that its image doesn't support. See [Azure Container Linux on AKS](azure-container-linux-overview) for details.
- **`Windows2022`**: Windows Server 2022 is in preview. It requires AMD64 architecture and isn't supported with the Cilium data plane. Windows2022 doesn't support FIPS or Trusted Launch. Don't configure `linuxOSConfig`, enable artifact streaming, or set LocalDNS to a mode other than `Disabled`.
- **`Windows2025`**: Windows Server 2025 is in preview. It requires AMD64 architecture and isn't supported with the Cilium data plane. FIPS is required and is enabled effectively even when `fipsMode` is omitted. Don't configure `linuxOSConfig`, enable artifact streaming, or set LocalDNS to a mode other than `Disabled`.

#### Example image family configuration

The following example configures the `AKSNodeClass` to use the `AzureLinux` image family:

```yaml
spec:
  imageFamily: AzureLinux
```

#### Azure Container Linux configuration

The following example uses Azure Container Linux with the required Trusted Launch settings. It omits `osDiskSizeGB` so that the platform selects a supported disk size.

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: azure-container-linux
spec:
  imageFamily: AzureContainerLinux
  security:
    trustedLaunch:
      vtpm: true
      secureBoot: true
```

#### Windows OS support (preview)

Note

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support Policies](support-policies)
- [Azure support FAQ](faq)

NAP supports `Windows2022` and `Windows2025` images.

- **`Windows2022`**: Windows Server 2022 is in preview. It requires AMD64 architecture and isn't supported with the Cilium data plane. Windows2022 doesn't support FIPS or Trusted Launch. Don't configure `linuxOSConfig`, enable artifact streaming, or set LocalDNS to a mode other than `Disabled`.
- **`Windows2025`**: Windows Server 2025 is in preview. It requires AMD64 architecture and isn't supported with the Cilium data plane. FIPS is required and is enabled effectively even when `fipsMode` is omitted. Don't configure `linuxOSConfig`, enable artifact streaming, or set LocalDNS to a mode other than `Disabled`.

**Windows2022 configuration**

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: windows-2025
spec:
  imageFamily: Windows2025
```

**Windows2025 Configuration**

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: windows-2025
spec:
  imageFamily: Windows2025
  security:
    trustedLaunch:
      vtpm: true
      secureBoot: true
```

Important

Windows image families are preview functionality. Use a Windows `NodePool` that selects `kubernetes.io/os: windows` and `kubernetes.io/arch: amd64`, and ensure that the workloads also select Windows nodes. For details, see [Configure node pools for node auto-provisioning on AKS](node-auto-provisioning-node-pools).

#### FIPS compliant node image configuration

You can also enable Federal Information Processing Standards (FIPS) compliant node images. For more information about FIPS in AKS, see [FIPS documentation](enable-fips-nodes).

The `fipsMode` field is set by default to Disabled, and can be set to the following options:

- FIPS - select FIPS-compliant node images
- Disabled - do not use FIPS-compliant node images

The following example configures the 'AKSNodeClass' to select FIPS-compliant node images by setting `fipsMode` to `FIPS`:

```yaml
spec:
  fipsMode: FIPS
```

## Instance-level public IP configuration

You can assign a public IPv4 address to each NAP-provisioned node by setting `nodePublicIP.enabled` to `true`. You can optionally specify `ipTags` or `prefixIDs`. Use one or the other, not both.

### Use instance-level public IP with prefixes

Optionally, specify one IPv4 public IP prefix using `prefixIDs`. The prefix must be in the same region as the cluster. For a zonal prefix, constrain the corresponding `NodePool` to the same availability zone. You can't specify `ipTags` and `prefixIDs` together - use only one.

The cluster identity needs permission to use the public IP prefix, if specified, and to create and manage the node public IP resources. For complete setup, network security, and verification guidance, see [Use node public IPs](use-node-public-ips).

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: public-ip-nodes
spec:
  nodePublicIP:
    enabled: true
    # Optional. Specify at most one IPv4 public IP prefix resource ID.
    prefixIDs:
      - /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/publicIPPrefixes/<prefix-name>
```

### Use instance-level public IP with IP tags an internet routing preference

The following example shows how to use instance-level public IP with an IP tag:

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: public-ip-nodes
spec:
  nodePublicIP:
    enabled: true
    ipTags:
      - ipTagType: RoutingPreference
        tag: Internet
    # Optional. Specify at most one IPv4 public IP prefix resource ID.
    prefixIDs:
      - /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/publicIPPrefixes/<prefix-name>
```

## Artifact streaming

[Artifact Streaming](artifact-streaming-overview) allows you to stream container images from Azure Container Registry (ACR) to Azure Kubernetes Service (AKS). AKS only pulls the necessary layers for initial pod startup, reducing the time it takes to deploy your workloads.

### Prerequisites

- Artifact Streaming requires that you have a Premium tier ACR integrated with your AKS cluster.
- Artifact Streaming must be enabled in ACR.

See [Artifact Streaming](artifact-streaming) documentation for instructions on enabling Artifact Streaming in ACR.

### Enable artifact streaming in NAP clusters

Clusters with [Node Auto Provisioning (NAP)](node-auto-provisioning) enabled can enable artifact streaming by using the `spec.artifactStreaming.enabled` field of the [AKSNodeClass CRD](node-auto-provisioning-aksnodeclass). Set this field to `true` to enable artifact streaming for any new or existing NAP-managed nodes associated with this AKSNodeClass CRD.

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: my-node-class
spec:
  # Enables artifact streaming; To use this feature container images must also enable artifact streaming on ACR
  # Valid values: true, false; defaults to false if not specified
  artifactStreaming:
    enabled: 
      true
```

Note

To use artifact streaming on AKS NAP managed nodes, you must also enable artifact streaming in Azure Container Registry (ACR). If you don't set this option in ACR, the field defaults to false.

## Virtual network (VNet) subnet configuration

The `vnetSubnetID` field specifies which Azure VNet subnet should be used for provisioning node network interfaces. This field is optional. If you don't specify a subnet, NAP uses the default subnet configured during Karpenter installation. For more information, see [Subnet configurations for NAP](node-auto-provisioning-networking#subnet-configurations-for-nap).

### Example subnet configuration

The subnet ID must be in the full Azure Resource Manager (ARM) format, as shown in the following example:

```yaml
spec:
  vnetSubnetID: "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}"
```

## OS disk size configuration

The `osDiskSizeGB` field specifies the size of the OS disk in gigabytes. The default value is 128 GB, and the minimum value is 30 GB.

Consider larger OS disk sizes for workloads that:

- Store significant data locally.
- Require extra space for container images.
- Have high disk I/O requirements.

### Example OS disk size configuration

```yaml
spec:
  osDiskSizeGB: 256  # 256 GB OS disk
```

## Ephemeral OS disk configuration

NAP automatically uses [Ephemeral OS disks](/en-us/azure/virtual-machines/ephemeral-os-disks) when available and suitable for the requested disk size. Ephemeral OS disks provide better performance and lower cost compared to managed disks.

### Ephemeral disk selection criteria

The system automatically chooses Ephemeral disks in the following scenarios:

- The VM instance type supports Ephemeral OS disks.
- The Ephemeral disk capacity is greater than or equal to the requested `osDiskSizeGB`.
- The VM has sufficient ephemeral storage capacity.

If these conditions aren't met, the system falls back to using managed disks.

### Ephemeral disk types and prioritization

Azure VMs can have different types of ephemeral storage. The system uses the following priority order:

- **NVMe disks** (highest performance)
- **Cache disks** (balanced performance)
- **Resource disks** (basic performance)

### Example ephemeral disk configuration

You can use node pool requirements to ensure nodes have sufficient ephemeral disk capacity, as shown in the following example:

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ephemeral-disk-pool
spec:
  template:
    spec:
      requirements:
        - key: karpenter.azure.com/sku-storage-ephemeralos-maxsize
          operator: Gt
          values: ["128"]  # Require ephemeral disk larger than 128 GB
      nodeClassRef:
        group: karpenter.azure.com
        kind: AKSNodeClass
        name: my-node-class
---
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: my-node-class
spec:
  osDiskSizeGB: 128  # This will use ephemeral disk if available and large enough
```

This configuration ensures that only VM instance types with ephemeral disks larger than 128 GB are selected, guaranteeing ephemeral disk usage for the specified OS disk size.

## Maximum pods configuration

The `maxPods` field specifies the maximum number of pods that can be scheduled on a node. This setting affects both cluster density and network configuration.

The minimum value for `maxPods` is 10, and the maximum value is 250.

### Default behavior for `maxPods`

The default behavior for `maxPods` depends on the network plugin configuration. The following table summarizes the defaults:

| Network plugin configuration | Default`maxPods`per node |
| --- | --- |
| Azure CNI with standard networking (v1 or NodeSubnet) | 30 |
| Azure CNI with overlay networking | 250 |
| None (no network plugin) | 250 |
| Other configurations | 110 (standard Kubernetes default) |

### Example maximum pods configuration

```yaml
spec:
  maxPods: 50  # Allow up to 50 pods per node
```

## LocalDNS configuration

LocalDNS deploys a node level DNS proxy that resolves DNS queries closer to workloads, reducing query latency and improving resiliency during transient DNS disruptions. For more information, see the [LocalDNS documentation](localdns-custom). By default, LocalDNS is set to Disabled and can be configured to the following options:

- `Disabled` (default) - Disables the LocalDNS feature. DNS queries aren't resolved locally on the node.
- `Preferred` - AKS manages LocalDNS enablement based on the Kubernetes version of the node pool. The configuration is always validated and included, but LocalDNS isn't enabled unless the correct Kubernetes version is used.
- `Required` - LocalDNS is enforced on the node pool if all prerequisites are satisfied. If the requirements aren't met, the deployment fails.

### Example LocalDNS configuration

You can customize LocalDNS configurations such as `vnetDNSOverrides` and `kubeDNSOverrides`. For more details on the supported plugins, see [Customize LocalDNS](localdns-custom).

```yaml
spec:
  LocalDNS:
    mode: Required
    vnetDNSOverrides:
      - zone: "."
        cacheDuration: "3600s"
        forwardDestination: VnetDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: PreferUDP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
      - zone: "cluster.local"
        cacheDuration: "3600s"
        forwardDestination: ClusterCoreDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: ForceTCP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
    kubeDNSOverrides:
      - zone: "."
        cacheDuration: "3600s"
        forwardDestination: ClusterCoreDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: PreferUDP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
      - zone: "cluster.local"
        cacheDuration: "3600s"
        forwardDestination: ClusterCoreDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: ForceTCP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
```

### Update the LocalDNS configuration on an existing AKSNodeClass

The `localDNS` setting participates in drift detection like other `AKSNodeClass` settings. When you change `spec.localDNS` on an `AKSNodeClass` that existing nodes already reference, NAP applies the change through the standard [Drift](node-auto-provisioning-disruption#drift) mechanism. NAP doesn't reimage existing nodes.

The following behavior applies when you change the LocalDNS mode or overrides, such as changing `mode` from `Disabled` to `Required`:

- **New nodes**: Every node that NAP provisions after you update the `AKSNodeClass` uses the new LocalDNS configuration.
- **Existing nodes**: NAP marks the existing `NodeClaim` objects as *drifted* because their recorded configuration no longer matches the `AKSNodeClass`. NAP launches a replacement node that uses the new LocalDNS configuration, then cordons, drains, and removes the drifted node.
- **No reimage**: Enabling LocalDNS on an AKS managed node pool reimages every node in the pool. NAP replaces the node instead. Either way, pods on the affected nodes are evicted and rescheduled, so plan for the same workload impact.

Important

Setting `mode` to `Preferred` or `Disabled` also changes the resolved `AKSNodeClass` configuration and drifts existing nodes. Any change within the `localDNS` section, including the `vnetDNSOverrides` and `kubeDNSOverrides` values, causes node replacement.

#### When replacement starts

Drift evaluation and replacement begin as soon as you apply the updated `AKSNodeClass`. Replacement follows the standard NAP disruption lifecycle, so the rate and timing depend on the disruption controls that you configure on the `NodePool` resources referencing the `AKSNodeClass`.

#### How NAP orchestrates replacement

Drift caused by a LocalDNS change honors the standard NAP disruption controls described in the following table:

| Control | Effect on LocalDNS-induced replacement |
| --- | --- |
| [Disruption budgets](node-auto-provisioning-disruption#disruption-budgets) (`spec.disruption.budgets`) | Rate limits how many nodes NAP replaces at once. If you don't define budgets, NAP defaults to one budget of `nodes: 10%`, so it disrupts a maximum of 10 percent of the node pool's nodes concurrently. |
| [Budget `schedule` and `duration`](node-auto-provisioning-disruption#schedule-and-duration-fields) | Confines replacement to a maintenance window. Set `nodes: "0"` outside the window to block replacement. |
| Pod disruption budgets (PDBs) | Apply during node drain. NAP waits instead of evicting pods that violate a PDB. |
| `karpenter.sh/do-not-disrupt` annotation | Excludes annotated pods and nodes from voluntary disruption, including drift. |
| [`terminationGracePeriod`](node-auto-provisioning-disruption#termination-grace-period) | Caps drain time. This setting bypasses PDBs and the `karpenter.sh/do-not-disrupt` annotation when the period elapses. |

Replacement is neither fully serial nor fully parallel. NAP provisions replacement capacity before it removes a drifted node, but it can replace multiple nodes that reference the same `AKSNodeClass` concurrently, up to the limit that your disruption budgets set.

Warning

If you don't define disruption budgets on your node pools and don't define pod disruption budgets for your workloads, changing `localDNS` on a busy `AKSNodeClass` can disrupt up to 10 percent of your nodes at a time with no application-level protection, which can cause workload downtime. Define PDBs for critical workloads and set a conservative disruption budget before you change `localDNS` on a production cluster.

#### Reduce availability risk when you enable LocalDNS

1. Confirm that your custom DNS servers answer queries over both UDP and TCP port 53 from the node subnet. For more information, see [Validate custom DNS before enabling LocalDNS](localdns-custom#validate-custom-dns-before-enabling-localdns).
2. Define pod disruption budgets for every critical workload.
3. Set a conservative disruption budget on the affected `NodePool` resources before you change the `AKSNodeClass`, as shown in the following example:

    ```yaml
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      disruption:
        budgets:
        - nodes: "1"   # Replace one node at a time
    ```
4. Apply the `localDNS` change to a nonproduction `AKSNodeClass` first. Alternatively, create an `AKSNodeClass` that has LocalDNS enabled and migrate workloads to a `NodePool` that references it.
5. Monitor replacement progress by listing the node claims. Replacement is complete when no node claim reports the `Drifted` status condition.

    ```bash
    # List node claims and watch replacements appear as drifted nodes are removed
    kubectl get nodeclaims
    
    # Inspect the status conditions on a specific node claim
    kubectl describe nodeclaim <nodeclaim-name>
    ```
6. Confirm that LocalDNS is active on the replacement nodes. For more information, see [Verify LocalDNS operation](localdns-custom#verify-localdns-operation).

## Kubelet configuration

The `kubelet` section allows you to configure various kubelet parameters that affect node behavior. These parameters are typical kubelet arguments, so the Azure provider simply passes them through to the kubelet on the node.

Important

**Configure kubelet settings carefully**, and test any changes in nonproduction environments first.

### CPU management

The following settings control CPU management behavior for the kubelet:

```yaml
spec:
  kubelet:
    cpuManagerPolicy: "static"  # or "none"
    cpuCFSQuota: true
    cpuCFSQuotaPeriod: "100ms"
```

- `cpuManagerPolicy`: Controls how the kubelet allocates CPU resources. Set to `"static"` for CPU pinning in latency-sensitive workloads.
- `cpuCFSQuota`: Enables CPU Completely Fair Scheduler (CFS) quota enforcement for containers that specify CPU limits.
- `cpuCFSQuotaPeriod`: Sets the CPU CFS quota period.

### Image garbage collection

The following settings control image garbage collection behavior for the kubelet:

```yaml
spec:
  kubelet:
    imageGCHighThresholdPercent: 85
    imageGCLowThresholdPercent: 80
```

These settings control when the kubelet performs garbage collection of container images:

- `imageGCHighThresholdPercent`: Disk usage percentage that triggers image garbage collection.
- `imageGCLowThresholdPercent`: Target disk usage percentage after garbage collection.

### Topology management

The following setting controls the topology manager policy for the kubelet:

```yaml
spec:
  kubelet:
    topologyManagerPolicy: "best-effort"  # none, restricted, best-effort, single-numa-node
```

The topology manager helps coordinate resource allocation for latency-sensitive workloads across CPU and device (like GPU) resources.

### System configuration

The following settings allow you to configure extra system parameters for the kubelet:

```yaml
spec:
  kubelet:
    allowedUnsafeSysctls:
      - "kernel.msg*"
      - "net.ipv4.route.min_pmtu"
    containerLogMaxSize: "50Mi"
    containerLogMaxFiles: 5
    podPidsLimit: 4096
```

- `allowedUnsafeSysctls`: List of permitted unsafe sysctls that pods can use.
- `containerLogMaxSize`: Maximum size of container log files before rotation.
- `containerLogMaxFiles`: Maximum number of container log files to retain.
- `podPidsLimit`: Maximum number of processes allowed in any pod.

## Linux custom OS configuration settings

The `LinuxOSConfig` section allows you to configure various kubelet parameters that affect node behavior. These parameters are typical custom OS arguments, so the NAP simply passes them through to the kubelet on the node.

For more information about custom Linux OS configuration settings, default values, and considerations, see the [custom node configuration parameters reference](custom-node-configuration-reference#linux-custom-os-configuration-parameters).

Important

**Configure Linux OS settings carefully**, and test any changes in nonproduction environments first.

### Linux file handle limits settings

Use the following settings to set the file system settings.

```yaml
spec:
  linuxOSConfig: 
    # Sysctl Settings  
    sysctls:  
      # File System Settings  
      fsFileMax: 2000000               # Range: 8192-12000500  Default: Max of available range
      fsInotifyMaxUserWatches: 1000000 # Range: 781250-2097152 Default: 1048576
      fsAioMaxNr: 1000000              # Range: 65536-6553500  Default: 65536
      fsNrOpen: 1000000                # Range: 8192-20000500  Default: 1048576
```

### Linux socket and network tuning settings

Use the following settings to set the TCP and network setting.

```yaml
spec:
  linuxOSConfig:
      # Network Settings  
      netCoreSomaxconn: 65535          # Range: 4096-3240000  Default: 16384
      netCoreNetdevMaxBacklog: 5000    # Range: 1000-3240000  Default: 1000
      netCoreRmemMax: 134217728        # Range: 212992-134217728  Default: 1048576
      netCoreOptmemMax: 102400         # Range: 20480-4194304     Default: 131072 
      netCoreWmemMax: 134217728        # Range: 212992-134217728  Default: 212992
      netCoreRmemDefault: 212992       # Range: 212992-134217728  
      netCoreWmemDefault: 212992       # Range: 212992-134217728  
      netIPv4IPLocalPortRange: "1024 65535" # Format: "first last", first: 1024-60999, last: 32768-65535  

      # Neighbor Table GC Thresholds  
      netIPv4NeighDefaultGcThresh1: 1024   # Range: 128-80000  Default: 4096
      netIPv4NeighDefaultGcThresh2: 2048   # Range: 512-80000  Default: 8192
      netIPv4NeighDefaultGcThresh3: 4096   # Range: 1024-80000  Default: 16384
      # Note: thresh1 <= thresh2 <= thresh3  

      # Connection Tracking  
      netNetfilterNfConntrackBuckets: 131072  # Range: 65536-524288   Default: dynamically calculated 
      netNetfilterNfConntrackMax: 262144       # Range: 131072-2097152 Default: dynamically calculated 
```

### Linux worker limit settings

Use the following settings to set the kernel setting.

```yaml
spec:
  linuxOSConfig:
      # Kernel Settings  
      kernelThreadsMax: 100000         # Range: 20-513785  Default: Dynamically calculated
```

### Linux virtual memory settings

Use the following options to tune the operation of the Linux virtual memory subsystem of the Linux kernel and the writeout of dirty data to disk.

```yaml
spec:
  linuxOSConfig:
      # Memory Management  
      vmMaxMapCount: 262144          # Range: 65530-262144 Default: Max of available range
      vmVfsCachePressure: 100        # Range: 0-100  Default: 100
      vmSwappiness: 60               # Range: 0-100  Default: 60

      # Swap File Configuration  
      swapFileSize: "2Gi"             # Default: (not set) | Pattern: quantity with units Note: Requires kubelet.failSwapOn: false  

      # Transparent Huge Pages  
      transparentHugePageEnabled: "madvise"    # Values: [always, madvise, never]  Default: always
      transparentHugePageDefrag: "defer+madvise" # Values: [always, defer, defer+madvise, madvise, never]  Default: madvise
```

## GPU settings

Use the following field to enable custom GPU driver installation, such as with the NVIDIA GPU Operator.

```yaml
spec:
  gpu:
    mode: 
      # acceptable values: [driver, none] default(or if not specified): driver
      # none skips gpu driver installation, driver has NAP manage the GPU driver installation  
      none
```

### Managed GPU

The `gpu.mode` field controls GPU driver installation. It accepts `Driver` or `None` and defaults to `Driver`. Set `None` to skip driver installation, for example, when using the NVIDIA GPU Operator.

To opt in to the managed NVIDIA GPU experience, use `mode: Driver` and set `nvidia.managementMode: Managed`. Managed GPU is supported for Linux NVIDIA GPU nodes using the AKS Machine API provision mode. The default NVIDIA management mode is `Unmanaged`.

```yaml
spec:
  gpu:
    mode: Driver
    nvidia:
      managementMode: Managed
```

For a complete NAP-managed GPU example and verification steps, see [AKS-managed GPU nodes](aks-managed-gpu-nodes).

## Security settings

### Encryption at host

The following field specifies whether host-level encryption is enabled for provisioned nodes. When you set this field to `true`, NAP includes only instance options that support encryption at host.

```yaml
spec:
  security:
    encryptionatHost: 
      # acceptable values: [true, false] default(or if not specified): false  
      false
```

For more information about host-based encryption, see [Encryption at Host documentation](enable-host-encryption).

### Custom-managed keys and disk encryption sets

NAP supports clusters that use customer-managed keys and disk encryption sets. Enable these options at the cluster level. They don't have `AKSNodeClass` fields that you need to set. Ensure that your cluster identity has the proper [role-based access control (RBAC)](aks-desktop-permissions):

- The cluster identity has `Reader` access to the Disk Encryption Set.
- The Disk Encryption set resource has `Key Vault Crypto Service Encryption User` access to the Azure Key Vault.

For information on customer-managed keys and disk encryption sets enabled during cluster creation, see [Customer-Managed Keys documentation](azure-disk-customer-managed-keys).

### Enable trusted launch in NAP clusters

Clusters with [Node Auto Provisioning (NAP)](node-auto-provisioning) enabled can enable trusted launch by using the `spec.security.trustedLaunch` field of the [AKSNodeClass CRD](node-auto-provisioning-aksnodeclass). Set the `secureBoot` and `vTPM` fields to `true` to enable trusted launch for any new or existing NAP-managed nodes associated with this AKSNodeClass CRD.

```yaml
spec:
  security:
  # Enables trusted lunch
  # Valid values: true, false; defaults to false if not specified
     trustedLaunch:
       secureBoot: true
       vTPM: true   
```

## Azure resource tags configuration

You can specify Azure resource tags that apply to all VM instances created using a particular `AKSNodeClass` resource. Tags are useful for cost tracking, resource organization, and compliance requirements.

### Tag limitations

- Azure resource tags have a limit of 50 tags per resource.
- Tag names are case-insensitive but tag values are case-sensitive.
- Azure reserves some tag names that can't be used. For more information, see [Tag guidance and limits](/en-us/azure/azure-resource-manager/management/tag-resources#tag-restrictions).

### Example tags configuration

```yaml
spec:
  tags:
    Environment: "production"
    Team: "platform"
    Application: "web-service"
    CostCenter: "engineering"
```

## Comprehensive `AKSNodeClass` configuration example

The following example demonstrates a comprehensive `AKSNodeClass` configuration that includes all the settings discussed in this article:

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.azure.com
        kind: AKSNodeClass
        name: comprehensive-example
---
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: comprehensive-example
spec:
  # Image family configuration
  # Default: Ubuntu
  # Valid values: Ubuntu, AzureLinux, AzureContainerLinux
  imageFamily: Ubuntu

  # FIPS compliant mode - allows support for FIPS-compliant node images
  # Default: Disabled
  # Valid values: FIPS, Disabled
  fipsMode: Disabled

  # Artifact Streaming- allows use of artifact streaming feature; To use this feature container images must also enable artifact streaming on ACR
  # Valid values: true, false; defaults to false if not specified
  artifactStreaming:
    enabled: true

  # LocalDNS mode - allows use of LocalDNS feature
  # Default: Disabled
  # Valid values: Preferred, Required, Disabled
  # vnetDNSOverrides and kubeDNSOverrides are both required, even when mode is Disabled
  # Each list must include the "." and "cluster.local" zones, and each zone must set all nine fields
  localDNS:
    mode: Disabled
    # vnetDNSOverrides apply to DNS traffic from pods with dnsPolicy:default and from kubelet
    vnetDNSOverrides:
      - zone: "."
        cacheDuration: "3600s"
        forwardDestination: VnetDNS   # the "." zone can't forward to ClusterCoreDNS in vnetDNSOverrides
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: PreferUDP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
      - zone: "cluster.local"
        cacheDuration: "3600s"
        forwardDestination: ClusterCoreDNS   # cluster.local can't forward to VnetDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: ForceTCP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
    # kubeDNSOverrides apply to DNS traffic from pods with dnsPolicy:ClusterFirst
    kubeDNSOverrides:
      - zone: "."
        cacheDuration: "3600s"
        forwardDestination: ClusterCoreDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: PreferUDP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"
      - zone: "cluster.local"
        cacheDuration: "3600s"
        forwardDestination: ClusterCoreDNS
        forwardPolicy: Sequential
        maxConcurrent: 1000
        protocol: ForceTCP
        queryLogging: Error
        serveStale: Immediate
        serveStaleDuration: "3600s"

  # Virtual network subnet configuration (optional)
  # If not specified, uses the default --vnet-subnet-id from Karpenter installation
  vnetSubnetID: "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"

  # OS disk size configuration
  # Default: 128 GB
  # Minimum: 30 GB
  osDiskSizeGB: 128

  # Maximum pods per node configuration
  # Default behavior depends on network plugin:
  # - Azure CNI with standard networking: 30 pods
  # - Azure CNI with overlay networking: 250 pods
  # - Other configurations: 110 pods
  # Range: 10-250
  maxPods: 30

  # GPU driver installation (optional)
  # Default: driver - NAP manages gpu driver installation
  # none skips gpu driver installation
  # Valid values: driver, none
  gpu:
    mode: 
      driver

  # Azure resource tags (optional)
  # Applied to all VM instances created with this AKSNodeClass
  tags:
    Environment: "production"
    Team: "platform-team"
    Application: "web-service"
    CostCenter: "engineering"

  # Kubelet configuration (optional)
  # All fields are optional with sensible defaults
  kubelet:
    # CPU management policy
    # Default: "none"
    # Valid values: none, static
    cpuManagerPolicy: "static"

    # CPU CFS quota enforcement
    # Default: true
    cpuCFSQuota: true

    # CPU CFS quota period
    # Default: "100ms"
    cpuCFSQuotaPeriod: "100ms"

    # Image garbage collection thresholds
    # imageGCHighThresholdPercent must be greater than imageGCLowThresholdPercent
    # Range: 0-100
    imageGCHighThresholdPercent: 85
    imageGCLowThresholdPercent: 80

    # Topology manager policy
    # Default: "none"
    # Valid values: none, restricted, best-effort, single-numa-node
    topologyManagerPolicy: "best-effort"

    # Allowed unsafe sysctls (optional)
    # Comma-separated list of unsafe sysctls or patterns
    allowedUnsafeSysctls:
      - "kernel.msg*"
      - "net.ipv4.route.min_pmtu"

    # Container log configuration
    # containerLogMaxSize default: "50Mi"
    containerLogMaxSize: "50Mi"
    
    # containerLogMaxFiles default: 5, minimum: 2
    containerLogMaxFiles: 5

    # Pod process limits
    # Default: -1 (unlimited)
    podPidsLimit: 4096

  security:
  # Enables trusted lunch
  # Valid values: true, false; default(or if not specified): false  
     trustedLaunch:
      secureBoot: true
      vTPM: true
  # Encryption at host
     encryptionatHost: 
      # acceptable values: [true, false] default(or if not specified): false  
      false
```