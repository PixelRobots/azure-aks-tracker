---
layout: Conceptual
title: Cluster connect access to Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-cluster-connect
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
ms.date: 2026-09-11T00:00:00.0000000Z
ms.topic: concept-article
description: Cluster connect allows developers to access their Azure Arc-enabled Kubernetes clusters from anywhere for interactive development and debugging.
locale: en-us
document_id: e87af22a-b4ef-bfaa-bbe7-4dd6a1c1e32a
document_version_independent_id: fa950816-ff27-889d-c3b4-74f432c1056f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-cluster-connect.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-cluster-connect
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-cluster-connect.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: e43bfdb9-7f93-28a3-007f-85587b0f41d6
---

# Cluster connect access to Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn

The Azure Arc-enabled Kubernetes *cluster connect* feature provides connectivity to the `apiserver` of the cluster without requiring any inbound port to be enabled on the firewall. A reverse proxy agent running on the cluster can securely start a session with the Azure Arc service in an outbound manner.

Cluster connect allows developers to access their clusters from anywhere for interactive development and debugging. It also lets cluster users and administrators access or manage their clusters from anywhere. You can even use hosted agents or runners of Azure Pipelines, GitHub Actions, or any other hosted CI/CD service to deploy applications to on-premises clusters, without requiring self-hosted agents.

## Architecture

![Diagram showing cluster connect architecture.](media/conceptual-cluster-connect.png)

*To download architecture diagrams in high resolution, visit [Jumpstart Gems](https://aka.ms/JumpstartGems_Docs).*

On the cluster side, a reverse proxy agent called `clusterconnect-agent`, deployed as part of the agent Helm chart, makes outbound calls to the Azure Arc service to establish the session.

When you run [`az connectedk8s proxy`](/en-us/cli/azure/connectedk8s#az-connectedk8s-proxy):

1. The Azure Arc proxy binary is downloaded and spun up as a process on the client machine.
2. The Azure Arc proxy fetches a `kubeconfig` file associated with the Azure Arc-enabled Kubernetes cluster on which the `az connectedk8s proxy`is invoked.
    - The Azure Arc proxy uses the caller's Azure access token and the Azure Resource Manager ID name.
3. The `kubeconfig` file, saved on the machine by the Azure Arc proxy, points the server URL to an endpoint on the Azure Arc proxy process.

When a user sends a request using this `kubeconfig` file:

1. The Azure Arc proxy maps the endpoint receiving the request to the Azure Arc service.
2. The Azure Arc service forwards the request to the `clusterconnect-agent` running on the cluster.
3. The `clusterconnect-agent` passes on the request to the `kube-aad-proxy` component, which performs Microsoft Entra authentication on the calling entity.
4. After Microsoft Entra authentication, `kube-aad-proxy` uses Kubernetes [user impersonation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation) to forward the request to the cluster's `apiserver`.