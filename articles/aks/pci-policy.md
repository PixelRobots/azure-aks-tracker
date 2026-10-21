---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Security Policies - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-policy
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
description: Security policies guidance for AKS clusters under PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 81da11c4-e998-7aca-b273-ec4473e9e962
document_version_independent_id: f416ba92-9262-68db-a41f-2c51a6ce4851
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-policy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c202ec83-d968-eed8-2caa-447e53ee38c0
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Security Policies - Azure Kubernetes Service | Microsoft Learn

This article describes security policy considerations for an Azure Kubernetes Service (AKS) cluster that's configured in accordance with the Payment Card Industry Data Security Standard (PCI DSS 4.0.1).

> 
> This article is part of a series. Read the [introduction](pci-intro).

## Maintain an information security policy

### Requirement 12: Maintain an information security policy for all personnel

Microsoft completes an annual PCI DSS assessment using an approved Qualified Security Assessor (QSA). This assessment covers all aspects of infrastructure, development, operations, management, support, and in-scope services. For more information, see [Payment Card Industry (PCI) Data Security Standard (DSS)](/en-us/compliance/regulatory/offering-PCI-DSS#use-microsoft-compliance-manager-to-assess-your-risk).

PCI DSS 4.0.1 requires organizations to establish, maintain, and regularly review a comprehensive information security policy. This policy must address roles, responsibilities, acceptable usage, and security objectives for all personnel, including third parties and cloud providers handling cardholder data. The policy should be reviewed at least annually and updated as risks evolve.

**Cloud and container considerations**:

- Define shared responsibility for security between your organization and the cloud/container provider in your policy.
- Ensure policies enforce inventory tracking of assets and services, including ephemeral resources like containers and cloud services.
- Communicate the policy to all personnel and relevant stakeholders, including those managing cloud and container environments.

Here are some general suggestions:

- Maintain thorough and updated documentation about processes and policies. Consider [using Microsoft Purview Compliance Manager to assess your risk](/en-us/compliance/regulatory/offering-PCI-DSS#use-microsoft-compliance-manager-to-assess-your-risk).
- In the annual review of the security policy, incorporate new guidance delivered by Microsoft, Kubernetes, and other third-party solutions that are part of your CDE. Use resources such as Microsoft Defender for Cloud, Azure Advisor, [Azure Well-Architected Review](/en-us/assessments/), [AKS Azure Security Baseline](/en-us/security/benchmark/azure/baselines/aks-security-baseline), and [CIS Azure Kubernetes Service Benchmark](https://www.cisecurity.org/blog/new-release-cis-azure-kubernetes-service-aks-benchmark/).
- When establishing your risk assessment process, align with a published standard where practical, for example [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final). Map publications from your vendor's published security list, such as the [Microsoft Security Response Center guide](https://msrc.microsoft.com/update-guide), to your risk assessment process.
- Keep up-to-date information about device inventory and personnel access documentation. Use device discovery capabilities, such as Microsoft Defender for Endpoint, and cloud-native inventory tools. For tracking access, use Microsoft Entra logs and cloud IAM logs.
    - [Device discovery](/en-us/microsoft-365/security/defender-endpoint/device-discovery)
    - [Entitlement management in Microsoft Entra ID Governance](/en-us/entra/id-governance/entitlement-management-reports)
- As part of your inventory management, maintain a list of approved solutions deployed as part of the PCI infrastructure and workload, including VM images, databases, and third-party solutions. Automate this process with a service catalog for self-service deployment using approved solutions in a specific configuration. For more information, see [Establish a service catalog](/en-us/azure/cloud-adoption-framework/manage/considerations/platform#establish-a-service-catalog).
- Make sure that a security contact receives Azure incident notifications from Microsoft. These notifications indicate if your resource is compromised and enable your security operations team to rapidly respond to potential security risks. Ensure administrator contact information in the Azure enrollment portal includes contact information that will notify security operations directly or rapidly through an internal process. For details, see [Security operations model](/en-us/azure/cloud-adoption-framework/secure/security-operations#security-operations-model).

For more information about planning for operational compliance, see the following resources:

- [Cloud management in the Cloud Adoption Framework](/en-us/azure/cloud-adoption-framework/manage/)
- [Governance in the Microsoft Cloud Adoption Framework for Azure](/en-us/azure/cloud-adoption-framework/govern/)