---
layout: Conceptual
title: Secure your network in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-secure-your-network
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
ai-usage: ai-assisted
description: Network security best practices for Azure Arc-enabled Kubernetes clusters, including segmentation, encryption, and access controls.
locale: en-us
document_id: a0353a57-8dee-545d-d71f-9fe87562a7f6
document_version_independent_id: 1536a58f-ed3c-f96b-b6d2-d539b4e76832
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-secure-your-network.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-secure-your-network
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-secure-your-network.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f1f2fd92-7193-4a24-462d-b3af1af42466
---

# Secure your network in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Network security provides an additional layer of defense for your Kubernetes clusters. This article discusses how to use network policies, infrastructure configuration, and Azure-specific features to control traffic flow, segment workloads, and help protect communications. Implementing these measures helps reduce the attack surface and limit unauthorized access to your resources.

## Configure Kubernetes network policy to control access to/from your workloads

In addition to [helping to protect your cluster’s workload data traffic via TLS](conceptual-secure-your-workloads#configure-tls-encryption-and-authentication-withintofrom-workloads), you can help further protect it by creating [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/). These policies control the pods, namespaces, and IP addresses from which ingress requests can be received, and to which egress requests can be sent. You need to deploy a Network Policy Engine to enforce these policies. Evaluate if you can use the [Calico](https://docs.tigera.io/calico/latest/network-policy/get-started/calico-policy/calico-network-policy) or [Cilium](https://docs.cilium.io/en/latest/security/policy/index.html) engines in your cluster.

### References

- [CIS Kubernetes Benchmark - Sections 1, 2, and 4](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Application Container Security Guide - Section 4.5.1-3](https://csrc.nist.gov/pubs/sp/800/190/final)
- [NSA Kubernetes Hardening Guidance – "Network policies"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Use Kubernetes network policies to control traffic"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Configure your network infrastructure for extra protection

You can create extra protection for both your management and data traffic by appropriately configuring the network of your underlying infrastructure. For example, consider fully separating management and data traffic if your workloads don't need to access the API server. If you're using AKS enabled by Azure Arc on an Azure Local hyperconverged deployment, review the [AKS network requirements](/en-us/azure/aks/aksarc/network-system-requirements) for cluster IP address planning. If you're using AKS bare-metal, you can [configure a dedicated control plane IP address](/en-us/azure/aks/aksarc/aks-bare-metal-create-cluster-portal#step-4-configure-networking).

Further, we recommend evaluating your organization’s external firewall rules so that they're consistent with the rules you set at the Kubernetes and infrastructure layers. Enable only those outbound and inbound destinations strictly required, and no more. You can also use [Azure Arc gateway](/en-us/azure/azure-arc/kubernetes/arc-gateway-simplify-networking?tabs=azure-cli) to simplify the firewall rules needed to enable your cluster’s access to Azure resources.

### References

- [NIST Application Container Security Guide - Section 4.3.3, 4.3.4, and 4.4.2](https://csrc.nist.gov/pubs/sp/800/190/final)
- [NSA Kubernetes Hardening Guidance – "Control plane hardening"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)

## Use Azure Private Link (preview) to access Azure resources

In addition to helping protect your traffic to Azure with [TLS and Workload Identity Federation](conceptual-secure-your-workloads#use-workload-identity-for-accessing-azure-resources), also consider using [Azure Private Link for Arc-enabled clusters (preview)](/en-us/azure/azure-arc/kubernetes/private-link). This feature sets up private endpoints inside your cloud virtual network for Azure Arc, and other services such as Azure Key Vault. This network itself can then be connected to your premises using [site-to-site VPN](/en-us/azure/vpn-gateway/tutorial-site-to-site-portal) or [ExpressRoute circuit](/en-us/azure/expressroute/expressroute-howto-linkvnet-arm). Evaluate the [advantages](/en-us/azure/azure-arc/kubernetes/private-link#advantages) and [current limitations](/en-us/azure/azure-arc/kubernetes/private-link#current-limitations) to decide if this solution works for you.