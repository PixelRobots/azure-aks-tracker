---
layout: Conceptual
title: Egress support for Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cert-manager-egress
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
ms.topic: how-to
description: Learn how to secure external egress traffic when using Certificate Management for Azure Arc-enabled Kubernetes.
locale: en-us
document_id: 37a97eec-94d5-9a6a-a980-0cd0b6b90f00
document_version_independent_id: 05222090-9e29-a4b5-142b-e51ce614aaa0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/cert-manager-egress.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/cert-manager-egress
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/cert-manager-egress.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5bd0510c-57b9-846f-ddee-b7e01d1597ba
---

# Egress support for Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

The Certificate Management for Azure Arc extension provides a cluster-level mechanism for managing certificates and distributing trusted CA material to workloads running inside an Azure Arc-enabled Kubernetes cluster.

In many scenarios, Kubernetes workloads must initiate outbound (egress) connections to systems that live outside the cluster boundary, such as factory devices, on‑premises services, or enterprise infrastructure. These external systems often use TLS certificates issued by private or enterprise Certificate Authorities (CAs) rather than publicly trusted CAs.

For these egress scenarios, the Certificate Management for Azure Arc extension doesn't terminate TLS or proxy outbound traffic. Instead, it focuses on:

- Managing trust material (CA certificates) required by workloads.
- Ensuring trust can be consistently distributed across namespaces and pods.
- Integrating with existing Kubernetes and cert‑manager primitives.

At a high level, the model is:

- The cluster administrator defines which external CAs to trust.
- The Certificate Management for Azure Arc extension distributes this trust material inside the cluster.
- Application pods consume the trust material and use it during outbound TLS handshakes.

This model keeps TLS enforcement and protocol semantics in the application, while the Certificate Management for Azure Arc extension handles trust distribution and lifecycle.

## Trust bundles and how workloads use them

A trust bundle is a collection of one or more CA certificates that represent the roots (and optionally intermediates) a workload should trust.

In an egress TLS scenario:

- The trust bundle typically contains the CA chain that the external system uses.
- You manage the bundle centrally, but workloads consume it locally.
- If workloads connect to the same external PKI, they can share the same trust bundle.
- The Certificate Management for Azure Arc extension uses trust-manager to distribute these bundles in a Kubernetes-native way. This approach avoids ad-hoc, per-pod certificate copying and keeps trust configuration declarative.

Using the Certificate Management for Azure Arc extension doesn't change application behavior. Workloads still perform TLS the same way they would outside Kubernetes.

Conceptually, a pod:

- Receives a trust bundle through a mounted file or environment-level configuration
- Configures its TLS client stack to trust that bundle
- Initiates outbound TLS connections as normal
- Testing and debugging at a high level

## Egress TLS validation

At a high level, validating egress TLS involves:

- Verifying the workload has the trust bundle
- Confirming the external service presents a certificate chain rooted in that bundle
- Ensuring application TLS libraries are configured to use the provided trust material

Common failure modes include:

- Missing or outdated CA certificates
- Incorrect certificate chains on the external system
- Application clients not reloading trust after updates

The Certificate Management for Azure Arc extension provides observability signals around certificate and trust distribution, but connection-level failures surface in application logs.