---
layout: Conceptual
title: What is AKS Hybrid and Edge? | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/aks-overview
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
description: Learn about AKS Hybrid and Edge and available deployment options.
ms.topic: overview
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2026-08-12T00:00:00.0000000Z
ms.custom: overview
locale: en-us
document_id: a789df47-f7a7-6767-9855-cddbb8ffc44b
document_version_independent_id: b98750e2-1eab-1c9f-4405-adc64de17d93
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/aks-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../aks/toc.json
asset_id: aks-hybrid-edge/aks-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/aks-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e5b781db-cc25-e603-1039-6660cd8b3613
---

# What is AKS Hybrid and Edge? | Microsoft Learn

Azure Kubernetes Service (AKS) Hybrid and Edge extends AKS beyond Azure regions to infrastructure you own or operate: datacenters, retail stores, manufacturing floors, remote sites, and other locations that need to run Kubernetes on-premises. It's part of Microsoft's **AKS everywhere** strategy: the same AKS engine, APIs, and operational model, available across a range of form factors, management models, and connectivity levels, so you can pick the deployment option that fits each location and scenario without adopting a different Kubernetes stack for each one.

## AKS everywhere

AKS Hybrid and Edge is part of Microsoft's vision for **AKS everywhere**: the same Azure Kubernetes Service you run in Azure regions is the same platform you run in sovereign and private clouds, and on your own hardware. One platform, every substrate, so the skills, tooling, and operational model you already know come with you wherever your applications need to run.

Every AKS Hybrid and Edge deployment option connects to the same Azure management plane, so you can use the same Azure portal, APIs, and policies to manage clusters no matter where they run. This consistency is what lets you standardize operations across cloud, datacenter, and edge locations, while each option is tuned for the infrastructure it targets.

AKS Hybrid and Edge provides the following features:

- Run Kubernetes clusters on-premises, at the edge, or in other cloud environments. This flexibility helps meet specific business or technical needs.
- Get a consistent experience for managing Kubernetes clusters across different infrastructures, similar to AKS in Azure.
- Manage Kubernetes clusters centrally through the Azure portal for deployment options that stay connected to Azure, including monitoring, updating, and scaling clusters.
- Extend Azure security and governance capabilities to Kubernetes clusters running anywhere. Apply Azure Policy for governance and use Microsoft Defender for Cloud for security monitoring and threat detection.
- Integrate with Azure services like Azure Monitor, Azure Policy, and Microsoft Defender for Cloud for a seamless operations and management experience.
- Use GitOps for configuration management and continuous deployment. This approach enables automated and consistent deployment processes.

## When to use AKS Hybrid and Edge

Here are some common use cases for AKS Hybrid and Edge:

- **Hybrid cloud deployments**: Run applications across on-premises and Azure environments with a consistent management layer.
- **Edge computing**: Deploy applications at the edge for low latency and local processing in places like retail stores, manufacturing floors, or remote locations.
- **Regulatory and compliance**: Meet regulatory and compliance requirements by deploying and managing Kubernetes clusters locally.

## AKS Hybrid and Edge deployment options

Here are the available deployment options:

- [**AKS on bare metal (preview)**](bare-metal/aks-bare-metal-overview): Runs Kubernetes directly on Azure Linux or Ubuntu hosts without a hypervisor. Azure Linux targets validated Azure Local hardware, while Ubuntu targets customer-provided hardware.
- [**AKS on Azure Local**](local/aks-local-overview): Managed from Azure, for teams running Kubernetes alongside other virtualized workloads on the same infrastructure.
- [**AKS Edge Essentials**](edge-essentials/aks-edge-overview): A lightweight, self-managed option for constrained or disconnected devices at the edge, such as retail stores or manufacturing floors.
- [**AKS on Windows Server**](windows-server/overview): A self-managed option for teams that want to run Kubernetes independently, without a dependency on Azure connectivity.

Tip

For a detailed, feature-by-feature comparison of these deployment options, see [Compare AKS features across cloud, edge, and on-premises platforms](aks-platforms-compare).