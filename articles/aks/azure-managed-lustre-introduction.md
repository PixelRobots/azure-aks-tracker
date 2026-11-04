---
layout: Conceptual
title: What is Azure Managed Lustre on AKS? - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-introduction
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
description: Learn how Azure Managed Lustre provides high-performance shared storage for AI and HPC workloads on Azure Kubernetes Service, including scale targets and MLPerf Storage results.
ms.topic: overview
ms.subservice: aks-storage
ms.date: 2026-10-30T00:00:00.0000000Z
author: wolfgang-desalvador
ms.author: wdesalvador
locale: en-us
document_id: 0792fed7-0f90-46f0-4603-c9d7a8a1f302
document_version_independent_id: 1bef8ae3-63a0-e352-3522-0a77eca5eb5b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-introduction.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-introduction
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-introduction.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8fd1cb70-ccf7-c2df-5746-aa3114295d2c
---

# What is Azure Managed Lustre on AKS? - Azure Kubernetes Service | Microsoft Learn

[Azure Managed Lustre](/en-us/azure/azure-managed-lustre/amlfs-overview) is a managed parallel file system for high-performance computing (HPC) and artificial intelligence (AI) workloads. It provides shared file storage while Azure manages the underlying file system infrastructure.

On Azure Kubernetes Service (AKS), the Azure Managed Lustre Container Storage Interface (CSI) driver makes this storage available to Linux workloads through persistent volumes and persistent volume claims. Multiple pods can access a shared file system using `ReadWriteMany` volumes.

## When to use Azure Managed Lustre

Consider Azure Managed Lustre when your containerized workloads need high aggregate file-system bandwidth across many workers:

- **AI training data access**: Read shared datasets concurrently to supply distributed training jobs.
- **Checkpointing and recovery**: Write model state and read checkpoints when restarting a job.
- **HPC and data processing**: Share input datasets and output files across parallel compute tasks.

You can also integrate the file system with Azure Blob Storage to import datasets and export results. For details, see [Azure Blob Storage integration](/en-us/azure/azure-managed-lustre/blob-integration).

## Performance and scale

Azure Managed Lustre supports petabyte-scale file systems, and published benchmark configurations demonstrate aggregate throughput of hundreds of gigabytes per second. Size the file system for both data capacity and workload bandwidth; the throughput tier and provisioned capacity determine its nominal bandwidth.

For example, the documented maximum for the 20 MBps tier without Blob integration is 25,632 TiB, approximately 25 PiB. Limits differ by tier and Blob integration configuration, and exceeding a subscription's default maximum requires a support request. Use the [Azure Managed Lustre scale targets](/en-us/azure/azure-managed-lustre/create-file-system-portal#throughput-configurations) for the current limits and capacity increments rather than treating a benchmark configuration as a deployment limit.

### MLPerf Storage results

The published [Azure Managed Lustre MLPerf Storage v3.0 results](/en-us/azure/azure-managed-lustre/mlperf-storage-v3-results) include these examples:

| Workload | Tested configuration | Measured aggregate bandwidth |
| --- | --- | --- |
| Training reads | AMLFS 125, 4,096 TiB, 70 simulated B200 accelerators | 379.1 GiB/s, or 407.1 GB/s. |
| Checkpoint writes and recovery reads | AMLFS 125, 4,096 TiB, 1250B-parameter checkpoint workload | 642.2 GiB/s writes and 489.6 GiB/s recovery reads, or 689.6 GB/s and 525.7 GB/s, respectively. |

[MLPerf Storage](https://mlcommons.org/benchmarks/storage/) exercises the storage data path with simulated accelerators. These figures are storage-system results, not per-pod throughput or measurements of AKS CSI-driver overhead, GPU computation, or end-to-end training time. GiB/s uses binary units; GB/s uses decimal units.

Benchmark results describe the tested configurations, not a performance guarantee. Validate your application with its intended data layout, concurrency, AKS node networking, and file system size. See the [complete results and sizing guidance](/en-us/azure/azure-managed-lustre/mlperf-storage-v3-results#how-to-use-the-data-as-a-sizing-reference) and [performance optimization guidance](/en-us/azure/azure-managed-lustre/optimize-performance).

## Use Azure Managed Lustre with AKS

Install the CSI driver with Helm or a script. Your workloads use Kubernetes storage classes and claims to access the file system:

- [Static provisioning](azure-managed-lustre-static-provisioning) connects an existing Azure Managed Lustre file system.
- [Dynamic provisioning](azure-managed-lustre-dynamic-provisioning) creates a file system for a persistent volume claim.

An alternative [AKS CLI installation option (preview)](azure-managed-lustre-install-cli-preview#install-with-aks-cli-options-preview) installs the driver as a managed extension. Neither installation method changes the service's capacity or performance limits.