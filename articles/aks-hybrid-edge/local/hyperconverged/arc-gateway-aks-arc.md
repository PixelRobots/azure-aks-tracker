---
layout: Conceptual
title: Simplify network configuration requirements with Azure Arc gateway | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/arc-gateway-aks-arc
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
description: Learn how to enable Arc gateway on AKS on Azure Local clusters to simplify network configuration requirements
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2026-04-20T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: cc1b51e6-1e09-c80b-c317-5f48b44155df
document_version_independent_id: d0730c37-13d0-1939-49b9-524e9086d9c3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/arc-gateway-aks-arc.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/arc-gateway-aks-arc
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/arc-gateway-aks-arc.md
platformId: 8181558b-49f4-d1ca-98ed-469e405f0f3e
---

# Simplify network configuration requirements with Azure Arc gateway | Microsoft Learn

If you use enterprise proxies to manage outbound traffic, Azure Arc gateway can help simplify the process of enabling connectivity. Before using Arc gateway with AKS on Azure Local, ensure you complete the [prerequisites for creating AKS clusters on Azure Local](network-system-requirements).

The AKS gateway lets you:

- Connect to Azure Arc by opening public network access to only seven fully qualified domain names (FQDNs).
- View and audit all traffic that the Arc agents send to Azure via the Arc gateway.

## How the Azure Arc gateway works

The Arc gateway works by introducing an Azure resource that serves as a common front end for Azure traffic. The gateway resource is served on a specific domain/URL that simplifies network configuration requirements.

For more information, see [how the Azure Arc gateway works](/en-us/azure/azure-local/deploy/deployment-azure-arc-gateway-overview).

## Required network endpoints

For the complete list of required URLs and endpoints that must be allowed through your enterprise firewall when using Arc gateway with AKS on Azure Local, see [Azure Local endpoints not redirected through Arc gateway](/en-us/azure/azure-local/deploy/deployment-azure-arc-gateway-overview#azure-local-endpoints-not-redirected).

## Using Arc gateway with AKS clusters

If Arc gateway is enabled in your environment, newly created AKS clusters automatically utilize it to simplify network connectivity.

## Other scenarios

Arc gateway covers endpoints required for AKS clusters, and a portion of endpoints required for more Arc-enabled scenarios. Based on the scenarios you adopt, more endpoints must still be allowed in your proxy.

All endpoints listed for the following scenarios must be allowed in your enterprise proxy when Arc gateway is in use:

- [Container insights in Azure Monitor](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-firewall):
    - `*.ods.opinsights.azure.com`
    - `*.oms.opinsights.azure.com`
    - `*.monitoring.azure.com`
- [Azure Key Vault](/en-us/azure/key-vault/general/access-behind-firewall):
    - `<vault-name>.vault.azure.net`
- [Azure Policy](/en-us/azure/governance/policy/concepts/policy-for-kubernetes):
    - `data.policy.core.windows.net`
    - `store.policy.core.windows.net`
- [Microsoft Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-enable?pivots=defender-for-container-arc&amp;toc=%2Fazure%2Fazure-arc%2Fkubernetes%2Ftoc.json&amp;bc=%2Fazure%2Fazure-arc%2Fkubernetes%2Fbreadcrumb%2Ftoc.json&amp;tabs=aks-deploy-portal%2Ck8s-deploy-asc%2Ck8s-verify-asc%2Ck8s-remove-arc%2Caks-removeprofile-api):
    - `*.ods.opinsights.azure.com`
    - `*.oms.opinsights.azure.com`
- [Azure Arc-enabled data services](/en-us/azure/azure-arc/network-requirements-consolidated?tabs=azure-cloud)
    - `*.ods.opinsights.azure.com`
    - `*.oms.opinsights.azure.com`
    - `*.monitoring.azure.com`