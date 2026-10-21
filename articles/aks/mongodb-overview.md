---
layout: Conceptual
title: Overview of deploying a MongoDB cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/mongodb-overview
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
description: This article provides an overview for deploying a MongoDB cluster on AKS.
ms.topic: overview
ms.date: 2025-09-15T00:00:00.0000000Z
author: fossygirl
ms.author: carols
ms.custom: aks-related-content, stateful-workloads
locale: en-us
document_id: 310ed38c-ebda-f04e-e1f4-78438647f9e0
document_version_independent_id: 63a12acc-66db-c0f3-f072-3b84b7ce8094
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/mongodb-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/mongodb-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/mongodb-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 02a8493a-5a63-b970-8aa3-04ff880059bc
---

# Overview of deploying a MongoDB cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article walks through prerequisite information for deploying a MongoDB cluster on [Azure Kubernetes Service (AKS)](what-is-aks). It also provides an overview of the deployment strategy.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## What is MongoDB?

[MongoDB](https://www.mongodb.com/) is a popular NoSQL database management system that is designed to handle large volumes of unstructured data. Unlike traditional relational databases that use tables and rows, MongoDB uses a flexible, document-oriented approach.

Note

MongoDB Community Edition isn't open-source software. It is licensed under the [Server Side Public License](https://www.mongodb.com/legal/licensing/server-side-public-license) with "source available."

### MongoDB sharded cluster

A [MongoDB sharded cluster](https://www.mongodb.com/docs/manual/core/sharded-cluster-components/) handles large datasets and high throughput by distributing data across multiple servers or shards. This architecture enables horizontal scaling, which is essential for applications that have growing data and performance needs.

Here's a breakdown of its key components and how it works:

- **Shards**: Individual MongoDB instances called [shards](https://www.mongodb.com/docs/manual/core/sharded-cluster-shards/) hold subsets of the data. Each shard is a replica set, or a group of MongoDB instances that replicate data among themselves. Replica sets help ensure high availability and fault tolerance.
- **Config servers**: The servers that store metadata and configuration settings for the sharded cluster are called [config servers](https://www.mongodb.com/docs/manual/core/sharded-cluster-config-servers/). They keep track of the cluster's data distribution and routing information. A cluster typically has three config servers to provide redundancy.
- **Mongos instances**: [Mongos](https://www.mongodb.com/docs/manual/core/sharded-cluster-query-router/) is a routing service that directs client requests to the appropriate shard. It acts as an intermediary between the client and the shards. An instance of Mongos manages query routing and aggregates results from shards.
- **Shard key**: When data is distributed across shards, it is based on a [shard key](https://www.mongodb.com/docs/manual/core/sharding-shard-key/), which is either a single indexed field or multiple fields in the documents. The shard key determines how data is partitioned among the shards. A well-chosen shard key helps ensure even data distribution and efficient querying.
- **Data distribution**: Data is distributed across shards based on the shard key. This distribution helps balance the load and manage large datasets effectively. MongoDB uses a [range-based](https://www.mongodb.com/docs/manual/core/ranged-sharding/) or [hash-based](https://www.mongodb.com/docs/manual/core/hashed-sharding/) sharding strategy, depending on the shard key.
- **High availability**: Each shard is a replica set, which means that it replicates its data across multiple nodes. This setup ensures that data remains available even if one or more nodes fail.

### Percona Operator for MongoDB

The Percona Operator for MongoDB is an open-source tool that [Percona](https://www.percona.com/) developed. It automates the deployment, management, and scaling of MongoDB clusters within Kubernetes environments. It simplifies operations by handling tasks such as provisioning, scaling, backup, and recovery. Its handling of all those tasks helps ensure high availability and performance of MongoDB clusters.

The operator uses Kubernetes custom resource definitions (CRDs) to manage MongoDB configurations declaratively and to handle failovers, monitoring, and alerts. The result is reduced administrative overhead and consistent management practices. The Percona Operator enhances the efficiency and reliability of MongoDB deployments, particularly in cloud-native applications. It's ideal for development, testing, and production scenarios.

[![Diagram that shows how the Percona Operator relates to a MongoDB cluster.](media/mongodb-overview/mongodb-shared-cluster.png)](media/mongodb-overview/mongodb-shared-cluster.png#lightbox)

## MongoDB solution overview

The goal of the proposed solution is to:

- Ensure that the MongoDB cluster can effectively handle large datasets and high-throughput operations.
- Maintain high availability and fault tolerance.

The solution accomplishes this goal by using replica sets, anti-affinity rules, and proper resource allocation.

### Deployment strategy

The MongoDB deployment strategy consists of the following components:

- A *sharded cluster* to enable the distribution of data across multiple shards, improving scalability and performance.
- *Configuration servers* managed by a three-member replica set to help ensure fault tolerance and high availability. Anti-affinity rules distribute these servers across failure domains.
- Three *Mongos instances* distributed across availability zones and exposed internally within the cluster. They provide load balancing and resiliency to route client requests.

## Contributors

*Microsoft maintains this article. The following contributors originally wrote it:*

- Ketan Chawda | Senior Customer Engineer
- Naveed Kharadi | Customer Experience Engineer
- Nelly Kiboi | Service Engineer
- Saverio Proto | Principal Customer Experience Engineer
- Don High | Principal Customer Engineer
- LaBrina Loving | Principal Service Engineer
- Ken Kilty | Principal TPM
- Russell de Pina | Principal TPM
- Colin Mixon | Product Manager
- Erin Schaffer | Content Developer 2
- Carol Smith | Senior Content Developer