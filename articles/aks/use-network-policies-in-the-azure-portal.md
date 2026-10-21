---
layout: Conceptual
title: Use Network Policies for Azure Kubernetes Service (AKS) Clusters in the Azure Portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-network-policies-in-the-azure-portal
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
description: In this article, you learn how to create and manage network policies for AKS clusters in the Azure portal.
author: sasper0ni
ms.author: mirandawu
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2025-10-10T00:00:00.0000000Z
locale: en-us
document_id: 9f94bc9b-5c99-71e9-a131-9fde0386cbef
document_version_independent_id: f3d312d2-c631-af22-343a-0cdaa8c09908
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-network-policies-in-the-azure-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/use-network-policies-in-the-azure-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-network-policies-in-the-azure-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 267f2cfd-7d11-f48e-80d5-b6f28b4819a7
---

# Use Network Policies for Azure Kubernetes Service (AKS) Clusters in the Azure Portal - Azure Kubernetes Service | Microsoft Learn

Kubernetes network policies are essential for controlling component-level communication in many modern, microservices-based applications. This article shows you how to create and manage network policies for AKS clusters directly in the Azure portal.

For more information on network policies, you can visit the [Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/#networkpolicy-resource) or review the [Best practices for network policies in Azure Kubernetes Service (AKS)](network-policy-best-practices).

## Prerequisites

- An AKS cluster with a network policy engine installed. If you don't have one, see [Enable a network policy engine on an Azure Kubernetes Service (AKS) cluster](use-network-policies).

    To confirm whether your cluster has a managed network policy engine installed, go to the Azure portal and navigate to your AKS cluster resource. From the service menu, select **Networking**. Under the **Network profile**, verify you have a **Network policy engine**. For example:

    ![A screenshot of Azure portal configuration showing Cilium network policy engine enabled.](media/use-network-policies-in-the-azure-portal/network-policy-engine.png)

## Create a network policy

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Kubernetes resources**, select **Network policies**.
3. Select **+ Create** &gt; **Network policy**.

### Define a policy scope

- On the **Create a network policy** page, update the following fields:

    - Name
    - Namespace
    - Pod selector

    ![Screenshot showing the required fields to define network policy scope during the policy create process in Azure portal.](media/use-network-policies-in-the-azure-portal/create-policy-scope.png)

    This network policy affects any traffic to or from pods that fall under specified pod selectors in your namespace. If you don't provide a selector, all pods in the specified namespace fall under your policy scope. Your network policy resource is also created in this namespace.

### Add policy rules

Note

If you don't add any rules before creating your network policy, Kubernetes automatically denies all ingress traffic to pods in your policy scope.

1. On the **Create a network policy** page, under **Policy rules**, select **+ Add rule**.
2. On the **Add rule** page, select your **Rule type** and **Rule preset**. Each rule can apply to ingress or egress traffic. To control both ingress and egress traffic in one policy, you can add multiple rules. You can also apply rule presets to allow or deny all ingress or egress traffic. For more granular control, you can select **Allow custom traffic**.

    ![Screenshot showing options to set a rule type and preset during the network policy create process in Azure portal.](media/use-network-policies-in-the-azure-portal/add-rule-type-and-preset.png)

### Add allowed sources or destinations

1. On the **Add rule** page, select either **+ Add allowed source** or **+ Add allowed destination** depending on your rule type (ingress or egress).
2. Select one of the following options for an allowed source or destination for Kubernetes network policies:

    - Allow traffic from the same namespace
    - Allow traffic from other namespaces within the cluster
    - Allow traffic from IP blocks outside the cluster

        ![Screenshot showing available allowed sources for ingress rules.](media/use-network-policies-in-the-azure-portal/ingress-rule.png)

    Important

    We don't recommend identifying pods using pod IP addresses as these IP addresses are ephemeral in nature. Instead, use pod selectors and/or namespace selectors to specify targeted pods.

    Note

    If you select **Allow custom traffic** without specifying any allowed sources or destinations, Kubernetes interprets this rule as *denying all traffic* for your selected rule type (ingress/egress).
3. Configure settings for the allowed source or destination option you selected:

    - To target *specific pods*, you can apply a pod selector with the appropriate key-value identifiers. If this pod selector is left blank or you select **Allow all pods**, all pods in specified namespaces are targeted.
    - To target *other namespaces in the cluster*, you can apply a namespace selector and pod selector that function independently to select specific combinations of namespaces and pods. To target all pods in all namespaces, select **Allow traffic from other namespaces within the cluster**, **Allow all namespaces**, and **Allow all pods**.
    - To *allow traffic from or to external IP addresses*, you can specify a specific IP block or CIDR with optional excluded addresses or ranges. Similarly to the pod and namespace selectors, if the CIDR field is left blank, all external IP addresses are allowed.

    Important

    Any selector fields left blank under a source or destination allow traffic to or from all entities of this type (IP addresses, namespaces, pods, etc.). To prevent unintentionally allowing any traffic, delete any sources or destinations that shouldn't be allowed.

![Screenshot showing configuration options for custom traffic.](media/use-network-policies-in-the-azure-portal/origin-types.png)

### Specify allowed ports

1. On the **Add rule** page, under **Ports**, the **Allow all ports** option is selected by default. This setting permits traffic on all ports. If you want to specify which ports can receive or send traffic, deselect **Allow all ports**, select a **Protocol**, and *optionally* enter a **Port or port range**.

    Important

    When restricting outbound egress communication, make sure that all Azure or AKS required traffic is explicitly allowed. These requirements might differ based on your cluster configurations. For more information, see [Outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](outbound-rules-control-egress).
2. Select **Add**.

## Manage network policies

Once you create your network policy, you can view your existing policies by selecting **Network policies** from the service menu. From here, you can create another network policy, delete network policies, or view more details about your network policy resources by selecting the policy.

![Screenshot showing a network policy in the AKS resource grid in the Azure portal.](media/use-network-policies-in-the-azure-portal/manage-network-policies.png)

## Frequently asked questions (FAQ)

### What happens if I have multiple policies enabled that allow different traffic streams? Does one policy override another?

Kubernetes network policies are additive in effect. For example, if one policy allows ingress from pods in namespace A, and another policy allows ingress from pods in namespace B, ingress from pods in both namespaces A and B is allowed. As long as the traffic is permitted by at least one policy, it's allowed.

### Are CiliumNetworkPolicy or CiliumClusterWideNetworkPolicy resources supported?

At this time, the Azure portal only supports Kubernetes NetworkPolicy creation and management: Layer 3 and Layer 4 policy control. To learn more about advanced container network security for AKS, see [What is Container Network Security?](container-network-security-concepts)

### What happens if I create a network policy without a network policy engine installed?

You can create network policies without a network policy engine on your AKS cluster. However, these policies aren't enforced until you install a network policy engine. For more information, see [Secure traffic between pods using network policies in Azure Kubernetes Service (AKS)](use-network-policies).