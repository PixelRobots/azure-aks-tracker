---
layout: Conceptual
title: FQDN filtering with Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/container-network-security-fqdn-filtering-concepts
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
description: An overview of Advanced Container Networking Services' Security capabilities on Azure Kubernetes Service (AKS).
author: sf-msft
ms.author: samfoo
ms.subservice: aks-networking
ms.topic: concept-article
ms.date: 2024-07-30T00:00:00.0000000Z
locale: en-us
document_id: b91268e4-b959-4dbb-734a-55548ea44122
document_version_independent_id: 99887872-2c44-2d0b-9141-7f390bf115ce
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/container-network-security-fqdn-filtering-concepts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/container-network-security-fqdn-filtering-concepts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/container-network-security-fqdn-filtering-concepts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8b0b60db-9737-698b-9f50-0db138e55a07
---

# FQDN filtering with Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn

Containerized environments present unique security challenges. Traditional network security methods, often reliant on IP-based filtering, can become cumbersome and less effective as IP addresses frequently change. Additionally, understanding network traffic patterns and identifying potential threats can be complex.

FQDN filtering offers an efficient and user-friendly approach for managing network policies. By defining these policies based on domain names rather than IP addresses, organizations can significantly simplify the process of policy management. This approach eliminates the need for frequent updates that are typically required when IP addresses change, as a result reducing the administrative burden and minimizing the risk of configuration errors.

In a Kubernetes cluster, pod IP addresses can change often, which makes it challenging to secure the pods with security policies using IP addresses. FQDN filtering allows you to create pod level policies using domain names rather than IP addresses, which eliminates the need to update policies when an IP address changes.

Note

Azure CNI Powered by Cilium and Kubernetes version 1.29 or greater is required in order to use Container Network security features of Advanced Container Networking Services.

## Components of FQDN filtering

**Cilium Agent**: The Cilium Agent is a critical networking component that runs as a DaemonSet within Azure CNI clusters powered by Cilium. It handles networking, load balancing, and network policies for pods in the cluster. For pods with enforced FQDN policies, the Cilium Agent redirects packets to the ACNS Security Agent for DNS resolution and updates the network policy using the FQDN-IP mappings obtained from the ACNS Security Agent.

**ACNS Security Agent**: ACNS Security Agent runs as DaemonSet in Azure CNI powered by Cilium cluster with Advanced Container Networking services enabled. It handles DNS resolution for pods and on successful DNS resolution, it updates Cilium Agent with FQDN to IP mappings.

## How FQDN filtering works

When FQDN Filtering is enabled, DNS requests are first evaluated to determine if they should be allowed after which pods can only access specified domain names based on the network policy. The Cilium Agent marks DNS request packets originating from the pods, redirecting them to the ACNS Security Agent. This redirection occurs only for pods that are enforcing FQDN policies.

The ACNS Security Agent then decides whether to forward a DNS request to the DNS server based on the policy criteria. If permitted, the request is sent to the DNS server, and upon receiving the response, the ACNS Security Agent updates the Cilium Agent with FQDN mappings. This allows the Cilium Agent to update the network policy within the policy engine. The following image illustrates the high-level flow of FQDN Filtering.

[![Screenshot showing how ACNS Security Agent works in FQDN filtering.](media/advanced-container-networking-services/how-dns-proxy-works.png)](media/advanced-container-networking-services/how-dns-proxy-works.png#lightbox)

## Key benefits

**Scalable security policy management**: Cluster and security admins don't have to update security policies each time an IP address changes making operations more efficient.

**Enhanced security compliance**: FQDN filtering supports a Zero Trust security model. Network traffic is restricted to trusted domains only mitigating risks from unauthorized access.

**Resilient Policy enforcement**: The ACNS Security Agent that is implemented with FQDN filtering ensures that DNS resolution continues seamlessly even if the Cilium agent goes down and policies remains enforced. This implementation critically ensures that security and stability are maintained in dynamic and distributed environments.

## Considerations:

- Container Network Security features require Azure CNI Powered by Cilium and Kubernetes version 1.29 and above.
- Supported by `CiliumClusterwideNetworkPolicy` (CCNP). FQDN filtering can be applied cluster wide via `CiliumClusterwideNetworkPolicy`.

## Limitations:

- Kubernetes service names aren't supported.
- Other L7 policies aren't supported.
- FQDN pods may exhibit performance degradation when handling more than 1,000 requests per second.
- If Advanced Container Networking Services(ACNS) security is disabled, FQDN and L7 policies (HTTP(s), Kafka, and gRPC) are blocked.
- Alpine-based container images may encounter DNS resolution issues when used with Cilium Network Policies. This is due to musl libc's limited search domain iteration. To work around this restriction, explicitly define all search domains in the Network Policy's DNS rules using wildcard patterns, like the below example

```yml
rules:
  dns:
  - matchPattern: "*.example.com"
  - matchPattern: "*.example.com.*.*"
  - matchPattern: "*.example.com.*.*.*"
  - matchPattern: "*.example.com.*.*.*.*"
  - matchPattern: "*.example.com.*.*.*.*.*"
- toFQDNs:
  - matchPattern: "*.example.com"
```

## Pricing

Important

Advanced Container Networking Services is a paid offering. For more information about pricing, see [Advanced Container Networking Services - Pricing](https://azure.microsoft.com/pricing/details/azure-container-networking-services/).