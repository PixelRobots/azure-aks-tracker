---
layout: Conceptual
title: Introduction to AKS Regulated Cluster for PCI DSS 4.0.1 - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-intro
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
description: Get started on your architecture design by addressing the applicable PCI DSS 4.0.1 requirements as a tenant on the AKS environment.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 9dc1d9b9-8f35-2f3a-4b75-5db9a0a082e1
document_version_independent_id: 3250811e-adcf-36dc-dc17-a35cdf1a1c71
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-intro.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-intro
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-intro.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0d1ff321-0c00-7e50-de38-40a0ff6f1681
---

# Introduction to AKS Regulated Cluster for PCI DSS 4.0.1 - Azure Kubernetes Service | Microsoft Learn

This reference architecture describes the considerations for an Azure Kubernetes Service (AKS) cluster designed to run a sensitive workload. The guidance is tied to the regulatory requirements of the Payment Card Industry Data Security Standard (PCI DSS 4.0.1).

PCI DSS 4.0.1 introduces significant changes from previous versions, including:

- The option to use a "customized approach" for meeting security objectives, allowing flexibility in cloud and container environments.
- Enhanced multifactor authentication (MFA) requirements for all access to the cardholder data environment (CDE), including administrative and non-console access.
- Stronger requirements for cryptography, encryption, and key management.
- Expanded and automated logging, monitoring, and tamper-proofing of logs, including ephemeral workloads like containers.
- Emphasis on continuous security, risk-based scoping, and regular validation of environment boundaries.
- Secure software development lifecycle (SDLC) practices, including automated vulnerability detection in CI/CD pipelines.
- Improved detection and response capabilities, including leveraging cloud-native and container-native security tools.
- Stronger requirements for remote access, zero trust architecture, and third-party/service provider management.

These changes are especially relevant for AKS and cloud-native architectures, where automation, dynamic scaling, and shared responsibility models are common. This guidance reflects the major updates in PCI DSS 4.0.1 and provides recommendations for leveraging Azure and AKS features to meet compliance objectives.

It's ***not* our goal to replace your configuration and/or setup of your compliance** with this series. The intent is to assist customers in getting started on architectural design by addressing the applicable PCI DSS 4.0.1 control objectives as a tenant on the AKS environment. The guidance covers compliance aspects of the environment, including infrastructure, workload interactions, operations, management, and service integrations, with a focus on the new requirements and flexibility introduced in PCI DSS 4.0.1.

Important

The reference architecture and implementation haven't been certified by an official authority. By completing this series and deploying the code assets, you don't clear audit for PCI DSS 4.0.1. Acquire compliance attestations from a third-party auditor. Always consult with a Qualified Security Assessor (QSA) familiar with cloud and containerized environments.

## Shared responsibility model

[**Microsoft Trust Center**](https://www.microsoft.com/trust-center/product-overview) provides specific principles for compliance-related cloud deployments. The security assurances, provided by Azure as the cloud platform and AKS as the host container, are regularly audited and attested by third-party Qualified Security Assessors (QSAs) for PCI DSS 4.0.1 compliance.

![Diagram of the shared responsibility model.](media/pci-dss/protection-everyone.svg)

- **Shared responsibility with Azure**

    The Microsoft Compliance team ensures all documentation of Microsoft Azure regulatory compliance is publicly available to customers. You can download the PCI DSS Attestation of Compliance for Azure under the PCI DSS section from the [Service Trust portal](https://servicetrust.microsoft.com). The responsibility matrix outlines who, between Azure and the customer, is responsible for each of the PCI DSS 4.0.1 requirements. For more information, see [Managing compliance in the cloud](https://www.microsoft.com/trust-center/compliance/compliance-overview).
- **Shared responsibility with AKS**

    Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications. AKS makes it simple to deploy a managed Kubernetes cluster on Azure. The AKS fundamental infrastructure supports large-scale applications in the cloud, and is a natural choice for running enterprise-scale applications in the cloud, including PCI workloads. Applications deployed in AKS clusters have certain complexities when deploying PCI-classified workloads, especially under the new requirements and flexibility of PCI DSS 4.0.1.
- **Your responsibility**

    As a workload owner, you're ultimately responsible for your own PCI DSS 4.0.1 compliance. Have a clear understanding of your responsibilities by reading the PCI DSS 4.0.1 requirements to understand the intent, studying the [matrix for Azure](https://servicetrust.microsoft.com), and completing this series to understand the AKS nuances. This process will help prepare your implementation for a successful assessment under PCI DSS 4.0.1.

## Before you begin

Before you begin this series, ensure that:

- You're familiar with Kubernetes concepts and workings of an [AKS cluster](/en-us/azure/aks).
- You've read the [AKS baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks).
- You've deployed the [AKS baseline reference implementation](https://github.com/mspnp/aks-secure-baseline).
- You're familiar with the official [PCI DSS 4.0.1 specification](https://www.pcisecuritystandards.org/document_library?category=pcidss)
- You've read the [Azure security baseline for Azure Kubernetes Service](/en-us/security/benchmark/azure/baselines/aks-security-baseline).

## Series overview

This series is split into several articles. Each article outlines the high-level PCI DSS 4.0.1 requirement followed by guidance about how to address the AKS-specific requirement, with a focus on the new and updated controls:

| Area of responsibility | Description |
| --- | --- |
| [Network segmentation](pci-network) | Protect cardholder data with firewall configuration and other network controls. Remove vendor-supplied defaults. Address dynamic segmentation and risk-based scoping as required by PCI DSS 4.0.1. |
| [Data protection](pci-data) | Encrypt all information, storage objects, containers, and physical media. Add security controls for data in transit and at rest, using updated cryptographic standards. |
| [Vulnerability management](pci-malware) | Run antivirus software, file integrity monitoring tools, and container scanners as part of your vulnerability detection and secure SDLC. |
| [Access controls](pci-identity) | Secure access through identity controls, including enhanced MFA and zero trust principles, for all access to the CDE. |
| [Monitoring operations](pci-monitor) | Maintain the security posture through automated and continuous monitoring operations, log integrity, and regular testing of your security design and implementation. |
| [Policy management](pci-policy) | Maintain thorough and updated documentation about your security processes and policies, including the use of the customized approach where applicable. |