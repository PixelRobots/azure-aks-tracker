---
layout: Conceptual
title: Data exchanged between Azure Arc-enabled Kubernetes cluster and Azure - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-data-exchange
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
ms.date: 2026-06-04T00:00:00.0000000Z
ms.topic: concept-article
description: The scenarios enabled by Azure Arc-enabled Kubernetes involve exchange of desired state configurations, metadata, and other scenario specific operational data.
locale: en-us
document_id: 2a4ec865-34df-dccd-15ee-3e8490077d36
document_version_independent_id: e1a91040-3c4c-40d0-cee9-84219b53254f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-data-exchange.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-data-exchange
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-data-exchange.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 75c43131-5f9c-12f4-69ab-9198479e734e
---

# Data exchanged between Azure Arc-enabled Kubernetes cluster and Azure - Azure Arc | Microsoft Learn

Azure Arc-enabled Kubernetes scenarios involve exchange of desired state configurations, metadata, and other scenario specific operational data between the Azure Arc-enabled Kubernetes cluster environment and Azure service. For all types of data, the [Azure Arc agents](conceptual-agent-overview) initiate outbound communication to Azure services, so they require only egress access to endpoints listed in the [network prerequisites](network-requirements). Enabling inbound ports on firewall isn't required for the Azure Arc agents.

The following table describes the data exchanged between these environments for different scenarios.

## Data exchange between cluster and Azure

| Scenario | Metadata | Communication mode |
| --- | --- | --- |
| Cluster metadata | Kubernetes cluster version | Agent pushes to Azure |
| Cluster metadata | Number of nodes in the cluster | Agent pushes to Azure |
| Cluster metadata | Agent version | Agent pushes to Azure |
| Cluster metadata | Kubernetes distribution type | Azure CLI pushes to Azure |
| Cluster metadata | Infrastructure type (AWS/GCP/vSphere/...) | Azure CLI pushes to Azure |
| Cluster metadata | vCPU count of nodes in the cluster | Agent pushes to Azure |
| Resource Health | Agent heartbeat | Agent pushes to Azure |
| Diagnostics and supportability | Resource consumption (memory/CPU) by agents | Agent pushes to Azure |
| Diagnostics and supportability | Logs of all agent containers | Agent pushes to Azure |
| Agent upgrade | Agent upgrade availability | Agent pulls from Azure |
| Configuration (GitOps) | Desired state of configuration: Git repository URL, flux operator parameters, private key, known hosts content, HTTPS username, token, or password | Agent pulls from Azure |
| Configuration (GitOps) | Status of flux operator installation | Agent pushes to Azure |
| Extensions | Desired state of extension: extension type, configuration settings, protected configuration settings, release train, auto-upgrade settings | Agent pulls from Azure |
| Azure Policy | Azure Policy assignments that need Gatekeeper enforcement within cluster | Agent pulls from Azure |
| Azure Policy | Audit and compliance status of in-cluster policy enforcements | Agent pushes to Azure |
| Azure Monitor | Metrics and logs of customer workloads | Agent pushes to Log Analytics workspace resource in customer's tenant and subscription |
| Cluster Connect | Requests sent to cluster | Outbound session established with Arc service by clusterconnect-agent used to send requests to cluster |
| Custom Location | Metadata on namespace and ClusterRoleBinding/RoleBinding for authorization | Outbound session established with Arc service by clusterconnect-agent used to send requests to cluster |
| Resources on top of custom location | Desired specifications of databases or application instances | Outbound session established with Arc service by clusterconnect-agent used to send requests to cluster |