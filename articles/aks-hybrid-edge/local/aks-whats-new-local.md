---
layout: Conceptual
title: What's new in AKS Hybrid and Edge on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/aks-whats-new-local
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
description: Learn about what's new in AKS Hybrid and Edge on Azure Local.
ms.topic: overview
ms.date: 2026-10-24T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2026-08-13T00:00:00.0000000Z
ms.custom: local
locale: en-us
document_id: 67c81b46-aae9-8b20-25ad-7d36478a0ae2
document_version_independent_id: ed006772-7f4b-49e7-c34b-fbe53f8f4a4f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/aks-whats-new-local.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/local/aks-whats-new-local
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/aks-whats-new-local.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 7bafb93b-a36b-b5c2-0634-d08e5e2b502f
---

# What's new in AKS Hybrid and Edge on Azure Local | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article summarizes features, improvements, and important notices for AKS on Azure Local (AKS Hybrid and Edge). It highlights release-specific updates, such as supported Kubernetes versions, platform and tooling changes, security advisories, and notable bug fixes. Use this information to help you plan upgrades and manage clusters. For details about a particular release, see the release sections that follow.

Note

AKS on Azure Local requires Azure Local version 23H2 or later.

## AKS Hybrid and Edge releases

This section lists the new features and improvements in AKS in each release of Azure Local.

### Release 2610

#### Kubernetes versions in 2610

The Kubernetes versions included in the 2610 release are: 1.32.10, 1.32.11, 1.33.6, 1.33.7, 1.34.3, and 1.34.4.

### Release 2607

There are no AKS-specific changes in the 2607 release. Supported Kubernetes versions, features, and deprecations for AKS on Azure Local remain the same as in release 2602.

### Release 2602

#### Kubernetes versions in 2602

The Kubernetes versions included in the 2602 release are: 1.31.12, 1.31.13, 1.32.8, 1.32.9, 1.33.4, 1.33.5.

#### Announcements for 2602

- Kubernetes version 1.30 is no longer supported.

### Release 2510

#### Announcements for 2510

- Kubernetes version 1.29 is no longer supported.
- KMS v2 is now used to encrypt the Kubernetes secret store for all new clusters created on Azure Local 2510 and later. KMS v1 continues to be used by existing clusters. For more information, see [secrets encryption](hyperconverged/encrypt-etcd-secrets).
- Support for [Windows Server 2019 SKU](https://techcommunity.microsoft.com/blog/containers/announcing-the-3-year-retirement-of-windows-server-2019-on-azure-kubernetes-serv/3777341) for node pools ends in March 2026.

#### Kubernetes versions in 2510

Kubernetes version 1.32 is introduced in 2510. The versions included in the 2510 release are: 1.30.13, 1.30.14, 1.31.9, 1.31.10, 1.32.5, 1.32.6.

#### Features

- The KMS v2 provider is introduced for new cluster deployments in Azure Local 2510. [KMS v2](https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/) brings many improvements in performance, scalability, health check and status, and observability. These enhancements provide a reliable solution to encrypt all resources in Kubernetes clusters. When you create a new cluster after upgrading to 2510, the Kubernetes cluster is configured to use KMS v2 by default. For more information, [see the instructions here](hyperconverged/encrypt-etcd-secrets).

### Release 2509

#### Announcements for 2509

- Support for Kubernetes minor version 1.29 ends with this 2509 release.
- KMS v1 will be deprecated soon. We are adding support for KMS v2 in an upcoming Azure Local release. Please plan on upgrading your clusters once KMS v2 is available.
- Support for [Windows Server 2019 SKU](https://techcommunity.microsoft.com/blog/containers/announcing-the-3-year-retirement-of-windows-server-2019-on-azure-kubernetes-serv/3777341) for node pools ends in March 2026.

#### Kubernetes versions in 2509

No new Kubernetes versions were added in 2509. The versions included in the 2509 release are: 1.29.12, 1.29.13, 1.30.8, 1.30.9, 1.31.4, 1.31.5.

#### Features

- Starting with the Azure Local 2509 release, we disable the download of the Windows VHDs by default. This change helps save on bandwidth usage and reduces deployment times for customers who need only Linux-based containers. Customers who need to use Windows node pools can continue to do so by [enabling the Windows node pool feature](hyperconverged/howto-enable-windows-node-pools), and then performing Windows node pool-based operations.
- Increased the default OS disk size on virtual machines used as AKS nodes to 200 GB. These VMs are dynamically expanding virtual hard disks and you should [ensure sufficient physical disk space is available](/en-us/windows-server/virtualization/hyper-v/best-practices-analyzer/ensure-sufficient-physical-disk-space-is-available-when-virtual-machines-use-dynamically?source=recommendations) for the node pools that you create on AKS.

### Release 2508

#### Announcements for 2508

- Support for Kubernetes minor version 1.29 ends with the 2509 release.
- KMS v1 is deprecated. We're adding support for KMS v2 in an upcoming Azure Local release. Plan on upgrading your clusters when KMS v2 is available.

#### Kubernetes versions in 2508

The Kubernetes versions included in the 2508 release are: 1.29.12, 1.29.13, 1.30.8, 1.30.9, 1.31.4, 1.31.5.

#### Bug fixes

- Fixed an issue where cluster creation failed after kubeadm installation in the default node pool failed, due to a tdnf cache issue.

### Release 2507

Important

Azure Linux 2.0 (formerly CBL-Mariner) reaches its official end of life (EOL) on July 31, 2025. After this date, Azure Linux no longer receives updates, security patches, or support from the Azure Linux team. Starting with the [Azure Local 2507 release](/en-us/azure/azure-local/whats-new), AKS on Azure Local releases Azure Linux 3.0 images for all supported Kubernetes versions. To maintain security compliance and ensure continued support, migrate to [Azure Linux 3.0](/en-us/azure/azure-linux/intro-azure-linux#whats-new-with-azure-linux-30) as soon as possible by upgrading Azure Local instances to the 2507 release.

Support for Kubernetes minor version 1.28 ends on August 31, 2025. Kubernetes 1.31 is introduced in the next Azure Local release.

The following Kubernetes cluster deployment and management capabilities are available:

- **Disk space exhaustion**: Fixed issues due to disk space exhaustion on control plane VMs caused by accumulation of kube-apiserver audit logs.
- **Cluster upgrade**: Fixed AKS cluster and node pool create, scale, and upgrade issues due to unavailability of AKS VM images.
- **AKS Telemetry pod issue**: Fixed an issue in which the AKS telemetry pod consumed excess CPU and memory.
- **New checks**: Added new checks during cluster and node pool operations. These improvements allow the system to proactively detect and handle scenarios where there are insufficient IP addresses in the IP pool.
- **GPU resource allocation**: Added pre-checks for resource allocation for GPUs during Kubernetes cluster create operation.
- **Node pool improvements**: Accurate representation of node pool count and status on the Azure portal. This release also includes improvements to node pool creation and update flows to ensure that the Kubernetes cluster status accounts for corresponding node pool status.
- **Improvements to autoscaler capabilities**:
    - Fixed an issue in which secrets were updated repeatedly when the autoscaler was enabled. The fix ensures that the provider checks for an existing secret and only creates it if it's missing.
    - Fixed an issue in which you couldn't disable the autoscaler at the Kubernetes cluster level.
    - Improved conflict handling logic during cluster delete operations when the autoscaler or cluster controller tried to update or remove resources that were being changed simultaneously by another process.
    - Fixed an issue in which the node pools' minimum and maximum counts didn't get updated when the autoscaler was enabled.

#### Kubernetes versions in 2507

The Kubernetes versions supported in the 2507 release are: 1.28.12, 1.28.14, 1.29.7, 1.29.9, 1.30.3, and 1.30.4.

### Release 2503

The following Kubernetes cluster deployment and management capabilities are available:

- **Large VM SKUs for Kubernetes node pools**: Added two new VM SKUs - `Standard_D32s_v3`: 32 vCPU, 128 GiB and `Standard_D16s_v3`: 16 vCPU, 64 GiB - to support larger node pools on an AKS cluster. For more information about supported VM sizes, see [supported scale options](hyperconverged/scale-requirements).
- **Improved log collection experience**: Improved log collection for AKS control plane node VMs and node pool VMs, with support for passing multiple IP addresses and SSH key or directory path. For more information, see [on-demand log collection](hyperconverged/get-on-demand-logs) and [az aksarc get-logs CLI](/en-us/cli/azure/aksarc#az-aksarc-get-logs).
- **Improved diagnosability**: The [Diagnostic Checker tool](hyperconverged/aks-arc-diagnostic-checker) automatically runs if the Kubernetes cluster creation fails, and added new test cases.
- **Improved Kubernetes cluster delete**: Fixed deletion issues; for example, due to pod disruption budgets.
- **Improved AKS image download**: Fixed issues with AKS image downloads.
- **Improved GPU support**: Improved error handling for Kubernetes cluster creation with GPU enabled node pools. Fixed known issues with attaching persistent volumes on GPU enabled node pools.

To get started with these features in the 2503 release, update your [AKSArc CLI extension](/en-us/cli/azure/aksarc) to version 1.5.37 or higher.

#### Kubernetes versions in 2503

The Kubernetes versions supported in the 2503 release are: 1.28.12, 1.28.14, 1.29.7, 1.29.9, 1.30.3, and 1.30.4.

### Release 2411

The following Kubernetes cluster deployment and management capabilities are available:

- **Workload Identity (preview)**. You can now deploy AKS clusters with workload identity enabled and deploy application pods with the workload identity label to access Microsoft Entra ID protected resources, such as Azure Key Vault. For more information, see [Deploy and configure Workload Identity](hyperconverged/workload-identity).
- **Arc Gateway integration (preview)**. You can now deploy AKS clusters with pod-level Arc Proxy and communicate with the Arc gateway, reducing the list of outbound URLs to configure in an isolated network environment. For more information, see [Simplify network configuration requirements with Azure Arc Gateway](hyperconverged/arc-gateway-aks-arc).
- **Control Plane IP**. You can now deploy AKS clusters without specifying the control plane IP. The IP address is assigned automatically. For more information, see [this section in the network system requirements article](hyperconverged/network-system-requirements#logical-networks-for-aks-vms-and-control-plane-ip).
- **Disable Windows image download**. You can now disable Windows image downloads by disabling the Windows node pool after cluster creation, reducing network traffic over HTTP connections and providing better support for low bandwidth environments. For more information, see [Disable Windows nodepool feature on Azure Local](hyperconverged/disable-windows-nodepool).
- **Terraform (preview)**. You can now create AKS clusters with Terraform modules and smart defaults. For more information, see [Create clusters using Terraform](create-clusters-terraform).
- **Error handling**. Error handling is now improved to prevent logical network deletions with dependent cluster resources, GPU misconfigurations, and more.

To get started with these features in the 2411 release, update your [AKSArc CLI extension](/en-us/cli/azure/aksarc) to version 1.4.23 or higher.

#### Kubernetes versions in 2411

The Kubernetes versions supported in the 2411 release are 1.27.7, 1.27.9, 1.28.5, 1.28.9, 1.29.2, and 1.29.4.

### Release 2408

The following Kubernetes cluster deployment and management capabilities are available:

- **High availability improvements**. You can now deploy nodes with anti-affinity on specific physical hosts on Azure Local clusters. For more information, see [Availability sets](hyperconverged/availability-sets).
- **PowerShell**. You can now use PowerShell cmdlets to manage your AKS clusters on Azure Local with CRUD support. For more information, see the [PowerShell reference documentation](/en-us/powershell/module/az.aksarc/?view=azps-12.1.0&amp;preserve-view=true).
- **Error report improvements**. You can now get improved error case reporting with prechecks; for example, a check for incorrect Kubernetes versions and available GPU capacity.
- **Support for NVIDIA T4**. You can now create node pools in new VM sizes with GPU NVIDIA T4. For more information, see [Use GPUs](hyperconverged/deploy-gpu-node-pool).
- **Arc Gateway**. You can now use the Arc Gateway to configure a few of the outbound URLs to use AKS clusters on Azure Local.
- **Support pod CIDR**. You can now create an AKS cluster with a user-specified pod CIDR IP range.

#### Supported component versions for 2408

| Component | Version |
| --- | --- |
| AKS | 1.3.218 |
| Kubernetes versions | 1.27.7, 1.27.9, 1.28.5, 1.28.9, 1.29.2, 1.29.4 |

### Release 2405

The following Kubernetes cluster deployment and management capabilities are available:

- **Azure RBAC support**. You can now enable Azure RBAC for Kubernetes while creating AKS clusters by using Azure CLI and Azure Resource Manager templates.
- **Taints and labels update**. You can now update taints and labels during an AKS node pool update operation by using Azure CLI and Azure Resource Manager templates.
- **AKS cluster platform metrics and alerts**. You can now view AKS cluster metrics (platform metrics) and create metric-based alerts.
- **Auto cert repair**. You can now automatically repair certificates, managed by cert-tattoo, that expired when the cluster was shut down.
- **Download VHDs manually (offline download)**. This feature, now available only in private preview, enables you to download virtual machine images and upload them to the target center by using a manual process. This feature can help in environments in which downloading large files is inconvenient. If you're interested in using it, contact your Microsoft Account representative.

#### Supported component versions for 2405

The following component versions are supported in release 2405:

| Component | Version |
| --- | --- |
| AKS | 1.0.23.10605 |
| Kubernetes versions | 1.26.10, 1.26.12, 1.27.7, 1.27.9, 1.28.3, 1.28.5 |

### Release 2402

The following Kubernetes cluster deployment and management capabilities are available:

- **Autoscaling**. You can now enable the autoscaling feature when you create or update Kubernetes clusters and node pools.
- **Support for NVIDIA A16**. You can now create node pools in new VM sizes with GPU NVIDIA A16. For more information, see [Use GPUs for compute-intensive workloads](hyperconverged/deploy-gpu-node-pool).
- **Diagnostic settings**. You can export audit logs and other control plane logs to one or more destinations. For more information, see [Diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/diagnostic-settings).
- **Certificate expiration**. You can now shut down Kubernetes clusters for up to seven days without any certificate expiration issues.
- **Update status**. You can now view the status of ongoing Kubernetes cluster upgrades.