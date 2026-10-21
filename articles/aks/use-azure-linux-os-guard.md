---
layout: Conceptual
title: Use Azure Linux with OS Guard (preview) for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-azure-linux-os-guard
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
description: Learn about Azure Linux with OS Guard (preview) on Azure Kubernetes Service (AKS), including key features, region availability, and resources to get started.
ms.topic: overview
ms.custom: linux-related-content, references_regions
ms.date: 2025-10-29T00:00:00.0000000Z
author: florataagen
ms.author: florataagen
locale: en-us
document_id: 19a24340-32d7-6c15-7810-e86cb74c8ece
document_version_independent_id: 1cab97bf-9780-696b-e32d-ace700195f53
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-azure-linux-os-guard.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/use-azure-linux-os-guard
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-azure-linux-os-guard.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b5c547d4-30da-0cb5-c7af-32e570c8fbab
---

# Use Azure Linux with OS Guard (preview) for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

This article provides an overview of Azure Linux with OS Guard (preview) on Azure Kubernetes Service (AKS), including key features, region availability, and resources to get started.

## What is Azure Linux with OS Guard?

Azure Linux with OS Guard is a hardened, immutable variant of Azure Linux. It provides strong runtime integrity, tamper resistance, and enterprise-grade security for container hosts on AKS. OS Guard is built on Azure Linux and adds kernel and runtime features that enforce code integrity, protect the root file system from unauthorized changes, and apply mandatory access controls.

You can deploy Azure Linux with OS Guard node pools in a new cluster, add Azure Linux with OS Guard node pools to your existing Azure Linux or Ubuntu clusters, or migrate your Azure Linux or Ubuntu nodes to Azure Linux with OS Guard nodes.

To learn more about Azure Linux with OS Guard, see the [Azure Linux with OS Guard documentation](/en-us/azure/azure-linux/intro-azure-linux-os-guard).

## Why use Azure Linux with OS Guard on AKS?

Azure Linux with OS Guard on AKS builds on the benefits of [Azure Linux](/en-us/azure/azure-linux/intro-azure-linux#azure-linux-container-host-key-benefits) by adding enhanced security features that help protect your container workloads from advanced threats. OS Guard provides:

- **Immutability**: The `/usr` directory is mounted as a read-only volume protected by dm-verity, preventing execution of tampered or untrusted code.
- **Code integrity**: OS Guard integrates the [Integrity Policy Enforcement (IPE) Linux Security Module](https://docs.kernel.org/next/admin-guide/LSM/ipe.html) to ensure that only binaries from trusted, signed volumes are allowed to execute. (**IPE is running in audit mode during Public Preview**.)
- **Mandatory access controls**: OS Guard integrates SELinux to limit which processes can access sensitive resources in the system. (**SELinux is operating in permissive mode during Public Preview**.)
- **Integration with Azure security features**: Native support for [Trusted Launch](/en-us/azure/aks/use-trusted-launch) and Secure Boot provides measured boot protections and attestation.
- **Verified container layers**: Container images and layers are validated using signed dm-verity hashes. This ensures that only verified layers are used at runtime, reducing the risk of container escape or tampering.
- **Sovereign Supply Chain Security**: OS Guard inherits Azure Linux’s secure build pipelines, signed Unified Kernel Images (UKIs) and Software Bill of Materials (SBOMs).

Learn more about the [key features of Azure Linux with OS Guard](/en-us/azure/azure-linux/intro-azure-linux-os-guard).

## Regional availability

Azure Linux with OS Guard is available for use in the same [regions](/en-us/azure/aks/quotas-skus-regions) as AKS.

## Get started with Azure Linux with OS Guard on AKS

Get started with Azure Linux with OS Guard on AKS using the following resources:

- [Creating a cluster with Azure Linux with OS Guard](/en-us/azure/azure-linux/quickstart-os-guard-azure-cli)
- [How to upgrade Azure Linux with OS Guard clusters](/en-us/azure/azure-linux/tutorial-azure-linux-os-guard-upgrade)
- [Add an Azure Linux with OS Guard node pool to your existing cluster](/en-us/azure/azure-linux/tutorial-azure-linux-os-guard-add-node-pool)
- [Migrate to Azure Linux with OS Guard](/en-us/azure/azure-linux/tutorial-azure-linux-os-guard-migration)
- [Enable telemetry and monitoring on an Azure Linux with OS Guard cluster](/en-us/azure/azure-linux/tutorial-azure-linux-os-guard-telemetry-monitor)