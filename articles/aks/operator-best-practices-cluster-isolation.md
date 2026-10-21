---
layout: Conceptual
title: Cluster isolation best practices for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-isolation
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
description: Learn the cluster operator best practices for isolation in Azure Kubernetes Service (AKS).
ms.topic: best-practice
ms.custom: aks-getting-started
ms.date: 2023-05-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: a201cc93-482c-1e54-8a8b-27ab3f0e5856
document_version_independent_id: 8f505877-5efa-6b6f-ace4-e03a23cb2786
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operator-best-practices-cluster-isolation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/operator-best-practices-cluster-isolation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operator-best-practices-cluster-isolation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
platformId: 93beb1fa-0d66-02c4-aa87-f95de9ed531b
---

# Cluster isolation best practices for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

As you manage clusters in Azure Kubernetes Service (AKS), you often need to isolate teams and workloads. AKS allows flexibility in how you run multi-tenant clusters and isolate resources. To maximize your investment in Kubernetes, it's important you understand AKS multi-tenancy and isolation features.

This best practices article focuses on isolation for cluster operators. In this article, you learn how to:

- Plan for multi-tenant clusters and separation of resources.
- Use logical or physical isolation in your AKS clusters.

## Design clusters for multi-tenancy

Kubernetes lets you logically isolate teams and workloads in the same cluster. The goal is to provide the least number of privileges scoped to the resources each team needs. A Kubernetes [Namespace](concepts-clusters-workloads#namespaces) creates a logical isolation boundary. Other Kubernetes features and considerations for isolation and multi-tenancy include the following areas:

- Best practices for cluster isolation in Azure Kubernetes Service (AKS)
    - Design clusters for multi-tenancy
        - Scheduling
        - Networking
        - Authentication and authorization
        - Containers
    - Logically isolated clusters
    - Physically isolated clusters
    - Next steps

### Scheduling

*Scheduling* uses basic features like resource quotas and pod disruption budgets. For more information about these features, see [Best practices for basic scheduler features in AKS](operator-best-practices-scheduler).

More advanced scheduler features include:

- Taints and tolerations.
- Node selectors.
- Node and pod affinity or anti-affinity.

For more information about these features, see [Best practices for advanced scheduler features in AKS](operator-best-practices-advanced-scheduler).

### Networking

*Networking* uses network policies to control the flow of traffic in and out of pods.

For more information, see [Secure traffic between pods using network policies in AKS](use-network-policies).

### Authentication and authorization

*Authentication and authorization* uses:

- Role-based access control (RBAC).
- Microsoft Entra integration.
- Pod identities.
- Secrets in Azure Key Vault.

For more information about these features, see [Best practices for authentication and authorization in AKS](concepts-cluster-authentication).

### Containers

*Containers* include:

- The Azure Policy add-on for AKS to enforce pod security.
- Pod security admission.
- Scanning images and runtime for vulnerabilities.
- Using App Armor or Seccomp (Secure Computing) to restrict container access to the underlying node.

## Logically isolated clusters

> 
> **Best practice guidance**
> 
> Separate teams and projects using *logical isolation*. Minimize the number of physical AKS clusters you deploy to isolate teams or applications.

With logical isolation, you can use a single AKS cluster for multiple workloads, teams, or environments. Kubernetes [Namespaces](concepts-clusters-workloads#namespaces) form the logical isolation boundary for workloads and resources.

![Logical isolation of a Kubernetes cluster in AKS](media/operator-best-practices-cluster-isolation/logical-isolation.png)

Logical separation of clusters usually provides a higher pod density than physically isolated clusters, with less excess compute capacity sitting idle in the cluster. When combined with the Kubernetes cluster autoscaler, you can scale the number of nodes up or down to meet demands. This best practice approach minimizes costs by running only the required number of nodes.

Kubernetes environments aren't entirely safe for hostile multi-tenant usage. In a multi-tenant environment, multiple tenants work on a shared infrastructure. If all tenants can't be trusted, you need extra planning to prevent tenants from impacting the security and service of others.

Other security features, like Kubernetes RBAC for nodes, efficiently block exploits. For true security when running hostile multi-tenant workloads, you should only trust a hypervisor. The security domain for Kubernetes becomes the entire cluster and not an individual node.

For these types of hostile multi-tenant workloads, you should use physically isolated clusters.

## Physically isolated clusters

> 
> **Best practice guidance**
> 
> Minimize the use of physical isolation for each separate team or application deployment and use *logical* isolation instead.

Physically separating AKS clusters is a common approach to cluster isolation. In this isolation model, teams or workloads are assigned their own AKS cluster. While physical isolation might look like the easiest way to isolate workloads or teams, it adds management and financial overhead. With physically isolated clusters, you must maintain multiple clusters and individually provide access and assign permissions. You're also billed for each individual node.

![Physical isolation of individual Kubernetes clusters in AKS](media/operator-best-practices-cluster-isolation/physical-isolation.png)

Physically isolated clusters usually have a low pod density. Since each team or workload has their own AKS cluster, the cluster is often over-provisioned with compute resources. Often, a few pods are scheduled on those nodes. Unclaimed node capacity can't be used for applications or services in development by other teams. These excess resources contribute to the extra costs in physically isolated clusters.