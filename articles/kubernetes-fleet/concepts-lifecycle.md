---
layout: Conceptual
title: Azure Kubernetes Fleet Manager hub cluster overview | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-lifecycle
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
learn_banner_products:
- azure
description: This article provides an overview on the Azure Kubernetes Fleet Manager hub cluster.
ms.date: 2026-10-07T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
ai-usage: ai-assisted
locale: en-us
document_id: 762f8caf-55a6-6f8c-ecd0-b2dfe3fc15ee
document_version_independent_id: 95ebd456-6082-f527-72a2-d4db24f56957
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-lifecycle.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-lifecycle
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-lifecycle.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a1b01667-090b-5973-c008-600e3c657437
---

# Azure Kubernetes Fleet Manager hub cluster overview | Microsoft Learn

When enabled, the Fleet Manager hub cluster serves as the central management point for Kubernetes resource propagation across member clusters using [resource placement](concepts-resource-placement).

## What are Fleet Manager hub clusters?

In Azure Kubernetes Fleet Manager, hub clusters play a crucial role in managing multiple member clusters, but they're optional.

The hub cluster facilitates resource placement and Fleet Managed Namespaces via a managed version of [KubeFleet](https://kubefleet.dev/).

In this configuration, a fleet consists of the following components:

![A diagram of the fleet resource when configured with a hub cluster, including the hub cluster agent and the member cluster agent.](media/concepts-fleet/fleet-architecture.png)

- **fleet-hub-agent**: A Kubernetes controller that creates and reconciles all the fleet-related custom resources (CRs) in the hub cluster.
- **fleet-member-agent**: A Kubernetes controller that creates and reconciles all the fleet-related CRs in the member clusters. This controller pulls the latest CRs from the hub cluster and consistently reconciles the member clusters to match the desired state.

## Hub cluster configuration

A Fleet Manager hub cluster is a fully managed Azure Kubernetes Service (AKS) cluster that has the following properties:

- **Cluster name and location:** the hub cluster is always named `hub` and is created in the same Azure region as the Fleet Manager.
- **Azure Resource Group for hub cluster:** the hub cluster AKS resource is created in a managed resource group with the naming format `FL_{fleet_manager_resource_group}_{fleet_manager_name}_{azure_region}`.
- **Azure Resource Group for hub cluster resources:** like any AKS cluster, the hub cluster has Azure resources such as an agent node pool virtual machine scale set and virtual network that are created in a managed resource group with the naming format `MC_FL_{fleet_manager_resource_group}_{fleet_manager_name}_{azure_region}`.
- **Hub cluster node:** The hub cluster has a node pool with a single node running Azure Linux. The node doesn't run any pods and doesn't affect hub cluster performance. When creating a hub cluster from the Azure CLI, you can choose the node Virtual Machine (VM) SKU type by using the `--vm-size` parameter.
- **Network configuration:** public hub clusters have a public API server, with an associated public IP address. When configured for private access, the API server is only accessible via an Azure virtual network.

## Hub cluster restrictions

The hub cluster has the following restrictions that ensure it functions as required for resource propagation and management:

- **Command Invocation Disabled:** Using command invocation via the Azure CLI ([az aks command invoke](/en-us/azure/aks/access-private-cluster)) is disabled for hub clusters.
- **Local Authentication Disabled:** Access via admin `kubeconfig` is disabled, ensuring that authentication is exclusively handled through Microsoft Entra ID, enhancing security by centralizing access control. Use [az fleet get-credentials](/en-us/cli/azure/fleet#az-fleet-get-credentials) to obtain the `kubeconfig` for the hub cluster.
- **Deny Assignments:** Changes to the Azure configuration of the hub cluster and associated resources are blocked through [Azure Deny Assignments](/en-us/azure/role-based-access-control/deny-assignments). The following Deny Assignments are used:
    - `FLRG-DenyAssignments-{guid}`: Applied on the hub cluster resource group, preventing users from modifying the hub cluster.
    - `kubernetes.azure.com/{guid}` (optional): This deny assignment prevents users from modifying the hub cluster AKS resources (Virtual Machine Scale Sets, networks), as described in [AKS node resource group lockdown](/en-us/azure/aks/node-resource-group-lockdown).
- **Applied Resources not instantiated:** The hub cluster doesn't schedule applied Kubernetes resources onto the hub cluster node. Some Kubernetes resources must be applied using an envelope object to avoid side effects on the hub cluster. For more information about envelope objects, see the [documentation of Envelope Objects](quickstart-envelope-reserved-resources).

### Protected-resource access restrictions

Important

Starting January 31, 2027, Fleet Manager hub clusters deny access to protected service-managed resources and privileged interfaces. These restrictions apply in addition to Azure role-based access control (Azure RBAC). An Azure role assignment that previously allowed a request doesn't override these restrictions.

The following Kubernetes API requests are denied:

- All identity impersonation requests.
- All operations other than `get`, `list`, and `watch` in namespaces with names that begin with `fleet-` or `kube-`.
- `get`, `list`, and `watch` requests for pods, secrets, service accounts, roles, and role bindings in namespaces with names that begin with `fleet-` or `kube-`.
- Cross-namespace `list` and `watch` requests for pods, secrets, service accounts, roles, and role bindings.
- Write requests for cluster roles and cluster role bindings.
- Read and write requests to the `nodes/proxy` subresource.
- Write requests for validating admission policies, validating admission policy bindings, and validating webhook configurations with names that begin with `fleet-builtin-`.
- Collection deletion requests for validating admission policies, validating admission policy bindings, and validating webhook configurations.

Other supported operations in customer-managed namespaces remain available.

#### Identify affected Fleet Manager resources and automation

A Fleet Manager resource is potentially affected if it has a hub cluster enabled. Use [Azure Resource Graph Explorer](/en-us/azure/governance/resource-graph/first-query-portal) to find these resources:

```kusto
Resources
| where type =~ "microsoft.containerservice/fleets"
| where isnotnull(properties.hubProfile)
| project id, name, subscriptionId, resourceGroup, location
```

Having a hub cluster doesn't necessarily mean that you need to take action. You're affected only if your users, scripts, controllers, or CI/CD pipelines send one of the restricted requests to the hub cluster.

Review automation that accesses the hub cluster for:

- Impersonation options or headers, including `--as` and `--as-group`.
- Requests to `nodes/proxy`.
- Access to namespaces with names that begin with `fleet-` or `kube-`.
- Cluster-wide or `--all-namespaces` list and watch requests for protected resources.
- Changes to cluster roles or cluster role bindings.
- Changes to validation resources with names that begin with `fleet-builtin-`.
- Collection deletion of validation resources.

#### Update affected automation

Before January 31, 2027:

- Move customer-owned resources and automation out of namespaces with names that begin with `fleet-` or `kube-`.
- Scope list and watch requests for pods, secrets, service accounts, roles, and role bindings to customer-managed namespaces.
- For resource placement, wrap cluster roles and cluster role bindings in a `ClusterResourceEnvelope`. For more information, see [Use envelope objects to safely place resources](quickstart-envelope-reserved-resources).
- For programmatic access to the hub cluster, use a dedicated Microsoft Entra identity, assign it the least-privileged Fleet Manager RBAC role required, and don't use identity impersonation.
- Stop using the `nodes/proxy` subresource.
- Don't modify validation resources with names that begin with `fleet-builtin-`.
- Replace collection deletion of validation resources with requests scoped to customer-managed resources.
- Test the updated automation before the enforcement date.

If you don't update affected automation before January 31, 2027, its restricted requests receive authorization-denied responses. Scripts, controllers, deployments, or operational workflows that depend on those requests might fail or repeatedly retry. If you don't use any restricted operations, no action is required.

## Requirements from customers

In order for Fleet Manager to create and keep hub clusters up-to-date with the latest patches, ensure that:

- **Azure policy doesn't block cluster creation.** The hub cluster is a managed AKS cluster. If you can't create AKS clusters you can't create a Fleet Manager hub cluster.
- **Subscription has sufficient quota.** One extra VM instance of the hub cluster's node is required during the cluster upgrade process. For more information on increasing quota, see [documentation on quota](/en-us/azure/quotas/regional-quota-requests).
- **Hub cluster has internet access.** Outbound connectivity is required to install updates. Private hubs on networks with user-defined routing (UDR) or firewall rules might block outbound connectivity. For more information on outbound connectivity, see [documentation on AKS outbound network](/en-us/azure/aks/outbound-rules-control-egress).
- **No need to manage updates to the Fleet Manager hub cluster.** Microsoft automatically updates the hub cluster to the latest version of Kubernetes or node image as they become available from AKS. Update releases can be tracked on the [AKS Release Tracker](https://releases.aks.azure.com).