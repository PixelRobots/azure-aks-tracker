---
layout: Conceptual
title: AKS Hybrid and Edge data collection | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/data-collection
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
description: Learn about the data exchanged between Kubernetes clusters and Azure.
author: davidsmatlak
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.reviewer: rbaziwane
ms.custom: overview
locale: en-us
document_id: 47c25182-02af-0204-a641-bcd9dcb97e10
document_version_independent_id: 69acf000-b33c-aac7-3b91-4c5457403e4e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/data-collection.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../aks/toc.json
asset_id: aks-hybrid-edge/data-collection
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/data-collection.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 421a967f-f98a-57dc-729d-820e1408b280
---

# AKS Hybrid and Edge data collection | Microsoft Learn

[AKS Hybrid and Edge](windows-server/overview) is a service that enables you to run Kubernetes clusters in your own infrastructure, using Azure Arc to connect and manage them. AKS collects data from clusters and connected machines to provide you with features such as monitoring, policy enforcement, and security updates. This article explains what data is collected, how it's classified, and how you can control it.

During the deployment of AKS, you must furnish a subscription and an Azure region in which data is stored. The Azure region is a virtual representation of your on-premises resources and doesn't correspond to the actual physical on-premises location. It represents the region in which Microsoft-operated datacenters store this data.

Important

Microsoft does not collect any sensitive information that might be classified as [Personally Identifiable Information (PII)](https://www.microsoft.com/microsoft-365-life-hacks/privacy-and-safety/what-is-pii). For more information, see the following data collection section.

There are three separate tiers to consider when curating data collection and exchange for on-premises deployments. This article describes the data exchanged between Kubernetes clusters (Tier 2) and Azure. See the public documentation for descriptions of data collection and exchange between [tier 1](/en-us/azure/azure-arc/kubernetes/conceptual-data-exchange) and [tier 3](/en-us/azure-stack/hci/concepts/data-collection).

- Tier 1: Azure Arc-enabled services such as Azure Monitor, Azure Defender, Event Grid, etc.
- Tier 2: Kubernetes clusters: AKS Hybrid and Edge.
- Tier 3: Physical host, such as Windows Server or Azure Local.

## Data collection and residency

AKS data is sent in JSON format, and is stored in a secure Microsoft-operated datacenter, as follows:

- Billing data is sent to the respective resource of that region in which you registered the device.
- Telemetry data (classified as "non-personal data") is stored within the region you selected at the time of deployment, and is forwarded to a central US store for the engineering team to use for product improvement and business analytics.

For information about how Microsoft stores diagnostic data in Azure, see [Data residency in Azure](https://azure.microsoft.com/global-infrastructure/data-residency/).

## Data retention

After AKS collects this data, it's retained for 28 days. AKS might keep aggregated, de-identified data for a longer period in order to track reliability of the service and inform product improvements.

## What data is collected?

AKS collects the following types of data:

- **Events related to the Hyper-V host operating systems**: Details such as the operating system name, version, and model. Identifiers include event names and event dates for precise event tracking. Various flags, both integer and Boolean, denote specific conditions or statuses, device, and operating system attributes. These flags include the name, device ID, and ISO country code. The data schema for these events incorporates a range of data types, including strings, integers, datetimes, and Booleans.
- **Events associated with the Kubernetes clusters control plane**: Specific metrics include cluster creation timestamps, pods, and node counts, and resource metrics including vCore counts. This data is used for monitoring and management of the Kubernetes cluster. The data schema for these events includes a range of data types, including Boolean, string, integer, and double.
- **Events pertaining to Hyper-V host operating system**: Emitted errors are captured for diagnostic and monitoring purposes. The predominant data schema used is the string format to encapsulate both the error message and the associated stack trace. Support is currently extended to the Windows Server and Azure Local platforms.
- **Events pertaining to Mariner Linux VMs**: Includes system boot and shutdown, service status changes, kernel messages, application errors, and user authentication activities only for system namespaces.
- **Billing events**: Events related to metering or billing of core usage. This set of events includes the event datetime and the quantity of cores. The data types include datetime for the event timing, and a floating-point number for the quantity.
- **Security events**: Aggregated events related to renewal of digital certificates and the functioning of the Key Management Service (KMS) plugin. These events enable tracking of certificate lifecycles, encryption key statuses, revocations, and renewals. The underlying data schema employs string data types to encapsulate this important information.
- **Diagnostics settings**: By installing the **Microsoft.AKSArc.AzureMonitor** Arc Kubernetes extension, you can enable the collection of Kubernetes audit and diagnostic data via Azure Monitor from the cluster control plane. See the [kube-apiserver audit configuration documentation](https://kubernetes.io/docs/reference/config-api/apiserver-audit.v1/#resource-types). This data is saved to customer-configured storage, and any intermediate data that Microsoft collects to facilitate export to customer storage is deleted within 48 hours.

Note

All events use either the Windows Universal Telemetry Client (UTC) or the Mariner Azure Device Health Service (ADHS).

For more information about Azure data collection and privacy policies, see the [Microsoft Privacy Statement](https://privacy.microsoft.com/privacystatement).