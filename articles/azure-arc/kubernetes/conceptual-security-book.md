---
layout: Conceptual
title: Security book for Azure Arc-enabled Kubernetes and AKS enabled by Azure Arc - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-security-book
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
ms.date: 2026-07-17T00:00:00.0000000Z
ms.topic: concept-article
description: Comprehensive security guidance and best practices for securing Azure Arc-enabled Kubernetes and AKS enabled by Azure Arc clusters, covering platform, workloads, operations, data, and network.
locale: en-us
document_id: e372dc29-0c97-75ea-28ba-25d617a972a7
document_version_independent_id: 5645fc96-c25d-69cc-bcbc-1a715bddb35f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-security-book.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-security-book
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-security-book.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 3a245115-6b50-70be-3f44-f9eac08757e4
---

# Security book for Azure Arc-enabled Kubernetes and AKS enabled by Azure Arc - Azure Arc | Microsoft Learn

Note

This content is one of a series of security books, offering recommendations and best practices to help secure Microsoft platforms. Other security books include [Azure Local security book](https://github.com/Azure-Samples/AzureLocal/blob/main/SecurityBook/Azure%20Local%20Security%20Book_04302025.pdf), [the Windows Server 2025 security book](https://techcommunity.microsoft.com/blog/microsoft-security-blog/windows-server-2025-security-book/4283981), and the [Windows Client security book](/en-us/windows/security/book/).

Your organization might have Kubernetes deployments that include clusters running at the edge (on-premises in data centers, factories, shops) or in multiple clouds. It's often a challenge to maintain a consistent and scalable security posture in these heterogeneous environments. You can help address this challenge and simplify your security workflows by running [Azure Kubernetes Service (AKS) enabled by Azure Arc](/en-us/azure/aks/hybrid/aks-overview) on your edge infrastructure, such as [Azure Local](/en-us/azure/azure-local/overview). Or you can connect existing non-Microsoft edge clusters, such as [K3s](https://k3s.io/), by using [Azure Arc-enabled Kubernetes](/en-us/azure/azure-arc/kubernetes/).

This book explains how these products can help you maintain a consistent and scalable security posture, covering both your cluster infrastructure and your application workloads. It advises how you can help guard against multiple threat vectors across supply chain risks, malicious external actors, or insider attacks. It builds on industry best practices such as those from:

- the [National Security Agency / Cybersecurity and Infrastructure Security Agency](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF) (NSA/CISA)
- the [Center for Internet Security (CIS)](https://www.cisecurity.org/benchmark/kubernetes)
- the [Open Worldwide application Security Project](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html) (OWASP)
- the [National Institute of Standards and Technology](https://csrc.nist.gov/pubs/sp/800/190/final) (NIST)
- the [Kubernetes project itself](https://kubernetes.io/docs/concepts/security/).

It also aligns with:

- the [Microsoft Threat Matrix for Kubernetes](https://microsoft.github.io/Threat-Matrix-for-Kubernetes/)
- [Microsoft’s security advice for AKS cloud clusters](/en-us/azure/aks/concepts-security), expanding this advice to include extra considerations for edge clusters
- [Microsoft's security advice for IoT solutions](/en-us/azure/iot/iot-overview-security?tabs=edge).

If you're a security professional, this book surveys all these factors and makes multiple recommendations. If you're a leader or engineer with direct responsibility for Kubernetes development, deployment, or operations, it further points you towards detailed practical advice on steps you can take.

[![Diagram showing the five categories of security challenges for edge Kubernetes.](media/conceptual-security-book/security-challenges.png)](media/conceptual-security-book/security-challenges.png#lightbox)

The security challenges fall into five categories:

1. Secure your platform. This category includes configuring your Kubernetes cluster to operate more securely, and doing the same for its underlying OS and hardware infrastructure as needed, appropriately using all their built-in capabilities.
2. Secure your workloads. This category includes building your containers more securely by following Kubernetes and Linux security standards. It also covers how to establish more secure authentication and authorization for requests to/from other services inside and outside of the clusters.
3. Secure your operations. This category includes controlling who can deploy to these clusters. It covers how to unify the cluster-local Kubernetes system for authentication and authorization with Microsoft Entra and Azure role-based access control (Azure RBAC) in the cloud. It also discusses how to better secure your software supply chain and enforce standards on your deployments through policies.
4. Secure your data. This category includes better securing access both to your workload application data and to the data that Kubernetes stores on your behalf, particularly secrets such as passwords.
5. Secure your network. This category includes configuring the extra defense in depth that comes from controlling management and data traffic at the network level. It discusses how to restrict which sources your clusters and workloads can receive from, and which targets they can they send to.

This book provides guidance on these challenges for Arc-enabled Kubernetes clusters in general and for AKS enabled by Azure Arc clusters in particular. There are multiple [deployment options](/en-us/azure/aks/aksarc/aks-overview#aks-enabled-by-azure-arc-deployment-options) for AKS enabled by Azure Arc. This book covers two of these deployment options on [Azure Local](/en-us/azure/azure-local/overview):

- [AKS enabled by Azure Arc](/en-us/azure/aks/aksarc/aks-overview) on an [Azure Local hyperconverged deployment](/en-us/azure/azure-local/overview/hyperconverged-overview), which runs on a hypervisor. This security book builds upon the [Azure Local security features](/en-us/azure/azure-local/concepts/security-features) and [security book](https://github.com/Azure-Samples/AzureLocal/blob/main/SecurityBook/Azure%20Local%20Security%20Book_04302025.pdf).
- [AKS on bare metal](/en-us/azure/aks/aksarc/aks-bare-metal-overview) on an [Azure Local small form factor deployment](/en-us/azure/azure-local/small-form-factor/small-form-factor-overview) (preview), which runs on physical hardware without a hypervisor layer. This security book builds upon the [security features](/en-us/azure/azure-local/small-form-factor/small-form-factor-security) for this type of Azure Local deployment.

Other deployment options might offer some, but not all, of the same benefits.