---
layout: Conceptual
title: Support policy for flex nodes in AKS (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/flex-nodes-support-policy
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
description: Understand Microsoft and customer responsibilities, the documented preview configuration, and how to get help for flex nodes.
author: leslielin-5
ms.author: leslielin
ms.topic: concept-article
ms.date: 2026-09-22T00:00:00.0000000Z
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: 4081c418-15d5-8e50-3837-eccf9d0b1826
document_version_independent_id: efa5bd55-70f8-d932-a597-dd2b238477a8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/flex-nodes-support-policy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/flex-nodes-support-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/flex-nodes-support-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c6b102c0-c580-505b-1ddd-5757e39d3760
---

# Support policy for flex nodes in AKS (preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Flex nodes run on Linux hosts that you provide and manage. Azure Kubernetes Service (AKS) manages the Kubernetes control plane and provides the flex node integration, while you operate the external host, its operating system, identity, network connectivity, and workloads.

This article explains how the [AKS support policy](support-policies) applies to flex nodes during preview.

## Preview support

Flex nodes are a preview feature intended for evaluation and aren't recommended for production workloads. Preview features receive best-effort support as described in [Preview features or feature flags](support-policies#preview-features-or-feature-flags). For legal terms, see the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).

The deployment series documents the following configuration:

- A new or existing public or private AKS cluster. This deployment walkthrough creates a cluster without a built-in network plugin.
- Unbounded-Net configured across the AKS-managed and flex node network locations.
- Existing Layer 3 connectivity between the two node networks.
- A Linux host prepared according to the published flex node prerequisites.
- Azure VM managed identity, Azure Arc managed identity, or service principal authentication.
- Component versions and lifecycle operations documented in the flex nodes article series.
- An AKS region where the required AKS release is available. See [regional availability](plan-flex-nodes-deployment#regional-availability).

Other AKSFlexNode repository labs demonstrate additional configurations. A configuration appearing in a lab doesn't by itself change the Microsoft Learn support boundary.

## Limitations

The following limitations apply to flex nodes in AKS:

- You can't [stop a cluster](start-stop-cluster) that contains a flex node pool, including a cluster that also contains standard AKS node pools.
- You can't use Azure portal to create or manage flex node pools.

## Shared responsibility

| Area | Microsoft provides | You operate |
| --- | --- | --- |
| AKS control plane | The managed Kubernetes control plane under the AKS support policy. | A supported AKS cluster configuration and version. |
| Flex node integration | The AKS resource-provider integration, flex node agent, bootstrap workflow, Azure Machine operations, and documented management interfaces. | The documented setup and lifecycle commands on your hosts. |
| Host infrastructure | Azure platform operation when the host is an Azure resource. | Host provisioning, capacity, availability, hardware, firmware, storage, and recovery. |
| Host operating system | Published host prerequisites and flex node software requirements. | Operating-system installation, security, patching, monitoring, packages, and privileged host access. |
| Identity and access | Microsoft Entra ID, managed identity, Azure role-based access control, and supported flex node authentication integration. | Identity creation or enablement, credential protection, cluster-scoped role assignment, rotation, and removal. |
| Network connectivity | The AKS API endpoint and documented flex node integration points. | External routing, virtual network peering, firewalls, network security groups, DNS, proxies, address planning, and any VPN or ExpressRoute connection used by your network design. |
| Unbounded-Net | The documented integration used by this deployment series. | Installation, configuration, upgrades, and external network dependencies for the customer-managed networking layer. |
| Workloads | AKS platform behavior within the documented configuration. | Application deployment, configuration, security, monitoring, backup, data protection, and troubleshooting. |
| Host lifecycle | Documented pool and Machine management operations and flex node software. | Scheduling changes, drain readiness, running privileged update or removal commands, and verifying each result. |

Your responsibility for the host or external network doesn't remove Microsoft support for defects in the AKS control plane or the documented flex node integration.

## Host and component requirements

Use the host requirements referenced in [Prepare a flex node host and identity](prepare-flex-node-host-identity), and the supported version published for each flex node component in [Plan flex nodes for AKS](plan-flex-nodes-deployment#component-version-values).

For general AKS version availability, see [Supported Kubernetes versions in AKS](supported-kubernetes-versions).

## Network responsibility

The documented workflow requires connectivity among:

- The environment where you run management commands and the AKS API server.
- Each flex node host and the AKS API server.
- AKS-managed nodes and flex node hosts.
- Pods and Kubernetes services across both network locations.
- The AKS control plane and the kubelet on each flex node.

Microsoft provides the AKS endpoints and the documented flex node integration. You configure and operate the external network path, including routing, DNS, firewall rules, gateways, virtual network peering, proxies, and any VPN or ExpressRoute connection used by your design.

The deployment series uses Unbounded-Net to provide pod networking across an existing Layer 3 path. Follow the documented configuration and collect both AKS and Unbounded-Net state when an issue crosses that boundary.

## Host access and changes

Flex node bootstrap and lifecycle commands run with root privileges and change host state. Limit access to approved operators and use the documented commands and component versions.

You can access and maintain the host, but changes to the agent, systemd services, worker environment, container runtime, networking configuration, credentials, or required packages can affect the flex node integration. Record host changes and restore the documented configuration before requesting support when an unrelated customization might be involved.

Microsoft Support doesn't access a customer-managed host without your permission and assistance. Keep a supported management path available so your operators can collect diagnostics.

## Get help

For an active problem with AKS or the documented flex node integration, [create an Azure support request](/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request).

Use the [AKSFlexNode issue tracker](https://aka.ms/aks-flex-node/issues) for product feedback and reproducible issues in the public project. Don't include confidential information or credentials in a public issue.

Report security vulnerabilities through the [Microsoft Security Response Center](https://msrc.microsoft.com/create-report), not through a public GitHub issue.

Include the following information when you request help:

- AKS cluster and flex node pool resource IDs.
- AKS, flex node agent, and Unbounded-Net versions.
- Operation name, UTC timestamp, and correlation ID when available.
- Kubernetes Node and Azure Machine names and states.
- Flex node agent, operating-system, and network logs.
- A description of relevant host or network changes.

Run the following commands to collect most of this information:

| Command | Where to run | Provides |
| --- | --- | --- |
| `az aks show` | Bash environment | Cluster name, resource ID, and API server |
| `az aks nodepool show` | Bash environment | Flex node pool version and provisioning state |
| `az aks machine list` | Bash environment | Machine names, node names, versions, and states |
| `kubectl get nodes` | Bash environment | Registered node names, states, and kubelet versions |
| `kubectl unbounded version` | Bash environment | Unbounded-Net version |
| `sudo journalctl -u aks-flex-node-agent --no-pager -n 200` | Flex node host | Flex node agent logs |

These commands appear with their full parameters in the deployment and management articles in this series.

Don't include access tokens, bootstrap data, kubeconfig content, private keys, certificates with private keys, service principal credentials, or other secrets.