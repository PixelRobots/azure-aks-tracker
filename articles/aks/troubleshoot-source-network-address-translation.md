---
layout: Conceptual
title: Troubleshoot SNAT Port Exhaustion for a Standard Load Balancer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/troubleshoot-source-network-address-translation
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
description: Learn how to troubleshoot SNAT port exhaustion issues for a Standard Load Balancer in Azure Kubernetes Service (AKS).
ms.topic: troubleshooting-general
ms.date: 2024-01-23T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-networking
locale: en-us
document_id: c7ef25cb-53ee-ae3b-0482-4ce0229c7f23
document_version_independent_id: 71448883-fcf8-805a-3c1c-1bbdcb4b4cca
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/troubleshoot-source-network-address-translation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/troubleshoot-source-network-address-translation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/troubleshoot-source-network-address-translation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: ffaccb2a-736a-71f3-3133-5ceb66bb39bb
---

# Troubleshoot SNAT Port Exhaustion for a Standard Load Balancer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

If you know that you're starting many outbound TCP or UDP connections to the same destination IP address and port, and you observe failing outbound connections or support notifies you that you're exhausting SNAT ports, you have several general mitigation options. Review these options and decide what's best for your scenario. It's possible that one or more can help manage your scenario. For detailed information, review the [outbound connections troubleshooting guide](/en-us/azure/load-balancer/troubleshoot-outbound-connection).

The root cause of SNAT exhaustion is frequently an anti-pattern for how outbound connectivity is established, managed, or configurable timers changed from their default values.

This article helps you troubleshoot SNAT port exhaustion issues when using a Standard Load Balancer in Azure Kubernetes Service (AKS).

## Steps to troubleshoot SNAT port exhaustion

Use the following steps to troubleshoot SNAT port exhaustion:

1. Check if your connections remain idle for a long time and rely on the default idle timeout for releasing that port. If so, the default timeout of 30 minutes might need to be reduced for your scenario.
2. Investigate how your application creates outbound connectivity (for example: code review or packet capture).
3. Determine if this activity is expected behavior or whether the application is misbehaving. Use [metrics](/en-us/azure/load-balancer/load-balancer-standard-diagnostics) and [logs](/en-us/azure/load-balancer/monitor-load-balancer) in Azure Monitor to substantiate your findings. For example, use the "Failed" category for SNAT connections metric.
4. Evaluate if appropriate design patterns are followed.
5. Evaluate if SNAT port exhaustion should be mitigated with [more outbound IP addresses and allocated outbound ports](configure-load-balancer-standard#configure-the-allocated-outbound-ports).

## SNAT port exhaustion design patterns

Take advantage of connection reuse and connection pooling whenever possible. These patterns help you avoid resource exhaustion problems and result in predictable behavior.

- Atomic requests (one request per connection) generally aren't a good design choice. Such anti-patterns limit scale, reduce performance, and decrease reliability. Instead, reuse HTTP/S connections to reduce the numbers of connections and associated SNAT ports. The application scale increases and performance improves because of reduced handshakes, overhead, and cryptographic operation cost when using TLS.
- If you're using out of cluster/custom DNS, or custom upstream servers on coreDNS, keep in mind that DNS can introduce many individual flows at volume when the client isn't caching the DNS resolvers result. Make sure to customize coreDNS first instead of using custom DNS servers and to define a good caching value.
- UDP flows (for example, DNS lookups) allocate SNAT ports during the idle timeout. The longer the idle timeout, the higher the pressure on SNAT ports. Use short idle timeout (for example, 4 minutes).
- Use connection pools to shape your connection volume.
- Never silently abandon a TCP flow and rely on TCP timers to clean up flow. If you don't let TCP explicitly close the connection, state remains allocated at intermediate systems and endpoints, and it makes SNAT ports unavailable for other connections. This pattern can trigger application failures and SNAT exhaustion.
- Don't change OS-level TCP close related timer values without expert knowledge of impact. While the TCP stack recovers, your application performance can be negatively affected when the endpoints of a connection have mismatched expectations. Wishing to change timers is usually a sign of an underlying design problem. Review following recommendations.