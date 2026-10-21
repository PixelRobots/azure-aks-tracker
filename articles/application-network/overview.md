---
layout: Conceptual
title: Overview of Azure Kubernetes Application Network for AKS (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/overview
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
description: Learn about Azure Kubernetes Application Network, a fully managed, ambient-based service network solution for Azure Kubernetes Service (AKS) that enables secure, policy-driven communication between services without sidecars or changes to your applications.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: overview
ms.date: 2025-11-04T00:00:00.0000000Z
ms.custom: references_regions
locale: en-us
document_id: f9ce3a85-6d47-3c42-8346-816531262843
document_version_independent_id: c7c6b6de-a8ff-9737-4c78-cb3facb36f85
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: application-network/overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a6c3a772-2aa6-215c-adae-69af7622107e
---

# Overview of Azure Kubernetes Application Network for AKS (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network provides a fully managed, [ambient-based](https://istio.io/latest/docs/ambient/) service network solution for Azure Kubernetes Service (AKS). It enables secure, policy-driven communication between services without requiring sidecars or changes to your applications. Azure manages both the control plane and data plane, so you can focus on your workloads instead of operating and maintaining service-network infrastructure.

When you create an Application Network resource, a dedicated, fully managed control and data plane is provisioned for service-to-service communication. You can then connect one or more AKS clusters to the Application Network resource to onboard them to the service network. Once connected, Application Network manages configuration, service identity, and version upgrades, providing consistent security and traffic policies across workloads with minimal configuration and operational overhead.

Important

Azure Kubernetes Application Network manages only service network-related components and policies. It doesn't manage or upgrade your AKS cluster, Kubernetes version, or node images.

Important

Azure Kubernetes Application Network doesn't store any customer data.

## Core capabilities

Application Network delivers a streamlined approach to zero-trust networking in AKS. Key capabilities include:

- **Ambient architecture**: Provides mesh functionality without sidecars, reducing resource usage and simplifying operations.
- **Automatic mutual TLS (mTLS)**: Secures service-to-service traffic by default, supporting both encrypted and unencrypted connections automatically.
- **Managed certificate authority**: Issues and rotates SPIFFE compliant workload certificates automatically.
- **Version and upgrade control**: Select minor versions manually or use release channels for automated upgrades. Rollout and patching are always managed by Application Network.
- **Integrated lifecycle management**: Operates as part of the AKS platform with control plane operations fully managed by Azure.

## Architecture overview

Application Network uses an **ambient mesh model** composed of lightweight node-level and optional L7 proxies:

- **Node-level proxies** secure all L4 service-to-service traffic in the cluster through mTLS, eliminating the need for sidecars.
- **Optional L7 proxies** provide advanced routing and policy enforcement at the service level.

This design separates the data plane from individual workloads, improving efficiency, and simplifying adoption. For more details, see [Azure Kubernetes Application Network architecture](architecture).

## Supported scenarios

Application Network supports single-cluster AKS deployments running **Linux-based node pools**. It's ideal for applications that require secure, in-cluster communication and simplified mesh management without managing sidecars or control plane components.

## Limitations

Application Network currently has the following limitations:

- Application Network requires AKS version 1.30 or higher. Refer to [Application Network supported versions](supported-versions) for each AKS version's specific compatibility information.
- AKS [private clusters](../aks/private-clusters) aren't currently supported.
- Linux only. Windows node pools aren't supported.
- Switching between upgrade modes `SelfManaged` and `FullyManaged` isn't supported.
- Currently supported only in the following regions:
    - centralus
    - eastus
    - eastus2
    - japaneast
    - northcentralus
    - northeurope
    - southindia
    - southeastasia
    - westcentralus
    - westus2
    - westus3
- Enabling the [Istio-based service mesh add-on for AKS](/en-us/azure/aks/istio-about) isn't supported on clusters connected to Application Network.
- An Application Network resource's location, subscription, and resource group are fixed when you create it and can't be changed afterward.
- An Application Network member resource's parent Application Network, location, subscription, and resource group are fixed when it joins and can't be changed afterward.