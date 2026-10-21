---
layout: Conceptual
title: Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cert-manager-overview
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-08-28T00:00:00.0000000Z
ms.topic: overview
ms.custom: references_regions
description: The Certificate Management for Azure Arc extension provides a unified, automated solution for managing TLS certificates and trust bundles in Arc-connected clusters.
locale: en-us
document_id: 0ec7cb8c-ccef-5f11-6ed7-16b12ed06657
document_version_independent_id: dc54ec54-2ef1-72b7-cab4-bc9f2901848d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/cert-manager-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/cert-manager-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/cert-manager-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d00e26f3-5227-6ab1-0356-f71b40f8299a
---

# Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

The Certificate Management for Azure Arc extension provides a unified, automated solution for managing TLS certificates and trust bundles in Arc-connected clusters. It simplifies the process of issuing, renewing, and managing certificates across hybrid and multicloud environments, providing secure communication and compliance with organizational policies.

The Certificate Management for Azure Arc extension installs a Microsoft-managed version of [cert-manager](https://cert-manager.io/) and [trust-manager](https://cert-manager.io/docs/trust/trust-manager/). Using the Certificate Management for Azure Arc extension provides the following benefits:

- **Automated certificate lifecycle**: No more manual certificate creation or renewal. Use cert-manager to issue certificates for your Kubernetes workloads or cluster components and renew them before they expire. This dramatically reduces the risk of service outages due to expired certificates and minimizes human error in certificate handling.
- **Centralized trust management**: Use trust-manager to propagate certification authority (CA) certificates (trust bundles) across namespaces in the cluster. This ensures that all pods and services share a consistent set of trusted CA certificates for TLS verifications, enabling secure service-to-service communication without manual intervention.
- **Integration with enterprise Public Key Infrastructure (PKI)**: The Certificate Management for Azure Arc extension supports both self‑signed CA certificates and external enterprise CA certificates. You can let it create a self‑signed cluster‑local CA certificate for internal certificates, or configure it to request certificates from your organization's existing PKI (for example, an external corporate CA or an ACME provider). In addition, you can create a cluster‑local issuer that is either a root self‑signed issuer or an intermediate issuer that chains to a key and certificate obtained from your enterprise PKI, which can be useful for air‑gapped or offline certificate issuance scenarios. This flexibility allows you to enforce enterprise compliance requirements by ensuring all certificates are ultimately issued from, or chained to, a known and trusted authority, while still fully automating certificate lifecycle management.
- **Offline and edge friendly**: The Certificate Management for Azure Arc extension is designed for edge scenarios. The extension can function for a period even if the cluster is temporarily disconnected from Azure or public networks. For example, certificates and trust info remains usable offline (limited by configured expiration and renewal periods), ensuring continued secure operation in intermittent connectivity scenarios.
- **Microsoft-supported distribution**: Unlike a self-managed open source deployment of cert-manager and trust-manager, this extension is maintained by Microsoft as part of Azure Arc. When you use the Certificate Management for Azure Arc extension, you receive proactive updates, security patches, and enterprise support for the cert-manager and trust-manager components. This extension aligns with Azure's security model and compliance standards, giving you peace of mind that certificate management meets corporate and regulatory requirements.

## How Certificate Management for Azure Arc works

After you install the Certificate Management for Azure Arc extension on your Arc-enabled Kubernetes cluster, Azure Arc deploys cert-manager and trust-manager services to the `cert-manager` namespace in the cluster. These services run with minimal footprint, and they continuously watch custom resources that describe certificate needs or trust bundles.

You can create Kubernetes custom resources such as Issuer/ClusterIssuer and Certificate objects to request certificates, or Bundle objects to distribute CA certificates. Cert-manager then works with the configured issuers to obtain the certificates (for example, generating a key pair and getting it signed by the specified CA) and stores the resulting certificate and key in a Kubernetes secret for your application to use. Trust-manager will pick up any Bundle resources and create the corresponding ConfigMaps of CA certificates in target namespaces, automatically managing updates and propagation.

## Validated Arc-enabled Kubernetes distributions

The current version of the Certificate Management for Azure Arc extension is validated on the following Arc-enabled Kubernetes distributions:

- Azure Kubernetes Service (AKS) enabled by Azure Arc: v1.32.7
- VMware Tanzu TKGm: v1.28.11
- K3s: v1.33.3+k3s1
- Red Hat OpenShift: v4.17.15, v4.18.9, v4.20.8
- SUSE Rancher RKE2: v1.33.6+rke2r1, v1.34.2+rke2r, v1.35.0+rke2r3
- AKS Edge Essentials: v1.30.5 and v1.31.5
- Azure Local version 2602 + Kubernetes versions 1.31.13, 1.32.9, 1.33.5

While you can deploy the extension to any Kubernetes cluster connected to Azure Arc, some functionality may not work as expected if your cluster is running a distribution that hasn't been validated.

## Regional support

Currently, Certificate Management for Azure Arc-enabled Kubernetes is available in the following Azure regions:

- Australia East
- Brazil South
- Canada Central
- Canada East
- Central India
- Central US
- East Asia
- East US
- East US 2
- France Central
- Germany West Central
- Israel Central
- Italy North
- Japan East
- Korea Central
- North Central US
- North Europe
- Norway East
- South Africa North
- South Central US
- South India
- Southeast Asia
- Sweden Central
- Switzerland North
- UAE North
- UK South
- UK West
- West Central US
- West Europe
- West US
- West US 2
- West US 3