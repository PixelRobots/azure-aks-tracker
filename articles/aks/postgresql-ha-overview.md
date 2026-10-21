---
layout: Conceptual
title: Deploying a PostgreSQL Database on AKS with CloudNativePG - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/postgresql-ha-overview
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
description: Learn the prerequisites, deployment process, and architecture for deploying a highly available PostgreSQL cluster on Azure Kubernetes Service (AKS) using Azure CLI.
ms.topic: overview
ms.date: 2025-06-18T00:00:00.0000000Z
author: KenKilty
ms.author: kkilty
ms.custom: aks-related-content, stateful-workloads
locale: en-us
document_id: 6d88d26e-9b7f-f4bc-577b-e5b2403fc9b7
document_version_independent_id: 18af3c8c-6064-ef7b-92cd-ca2e266aead9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/postgresql-ha-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/postgresql-ha-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/postgresql-ha-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/982661b3-cc41-45b1-b21d-18b4b6937344
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/bbee35d0-ba85-4062-b9c2-388c328eb4fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 220e20f4-1408-c677-3d0b-e5db51c7bafe
---

# Deploying a PostgreSQL Database on AKS with CloudNativePG - Azure Kubernetes Service | Microsoft Learn

In this guide, you deploy a highly available PostgreSQL cluster that spans multiple Azure availability zones on AKS with Azure CLI.

This article walks through the prerequisites for setting up a PostgreSQL cluster on [Azure Kubernetes Service (AKS)](what-is-aks) and provides an overview of the full deployment process and architecture.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Prerequisites

- This guide assumes a basic understanding of [core Kubernetes concepts](concepts-clusters-workloads) and [PostgreSQL](https://www.postgresql.org/).
- You need the **Owner** or **User Access Administrator** and the **Contributor**[Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles) on a subscription in your Azure account.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- You also need the following resources installed:

    - [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.56 or later.
    - [jq](https://jqlang.github.io/jq/), version 1.5 or later.
    - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.21.0 or later.
    - [Helm](https://helm.sh/docs/intro/install/) version 3.0.0 or later.
    - [openssl](https://www.openssl.org/) version 3.3.0 or later.
    - [Visual Studio Code](https://code.visualstudio.com/Download) or equivalent.
    - [Krew](https://krew.sigs.k8s.io/) version 0.4.4 or later.
    - [kubectl CloudNativePG (CNPG) Plugin](https://cloudnative-pg.io/documentation/current/kubectl-plugin/#using-krew).

## Deployment process

In this guide, you learn how to:

- Use Azure CLI to create a multi-zone AKS cluster.
- Deploy a highly available PostgreSQL cluster and database using the [CNPG operator](https://cloudnative-pg.io/documentation/current/kubectl-plugin/#using-krew).
- Set up monitoring for PostgreSQL using Prometheus and Grafana.
- Deploy a sample dataset to a PostgreSQL database.
- Perform PostgreSQL and AKS cluster upgrades.
- Simulate a cluster interruption and PostgreSQL replica failover.
- Perform backup and restore of a PostgreSQL database.

## Deployment architecture

This diagram illustrates a PostgreSQL cluster setup with one primary replica and two read replicas managed by the [CloudNativePG (CNPG)](https://cloudnative-pg.io/) operator. The architecture provides a highly available PostgreSQL running on an AKS cluster that can withstand a zone outage by failing over across replicas.

Backups are stored on [Azure Blob Storage](/en-us/azure/storage/blobs/), providing another way to restore the database in the event of an issue with streaming replication from the primary replica.

You might choose to host PostgreSQL on AKS when you need full control over database configuration, extensions, and deployment architecture. It’s ideal for integrating tightly with Kubernetes-native tooling, optimizing costs at scale, and fine-tuning performance through custom resource allocation, caching strategies, and storage configurations tailored to your workload.

[![Architecture diagram of CNPG Kubernetes operator for self-hosting a highly available PostgreSQL database on AKS.](media/postgresql-ha-overview/postgres-architecture-diagram.png)](media/postgresql-ha-overview/postgres-architecture-diagram.png#lightbox)

Note

For applications that require data separation at the database level, you can add more databases with postInitSQL commands and similar. It's currently not possible to add more databases in a declarative way with the CNPG operator. [Learn more](https://github.com/cloudnative-pg/cloudnative-pg) about the CNPG operator.

### Storage considerations

The type of storage you use can have large effects on PostgreSQL performance. Later in this guide, you select the option best suited for your goals and performance needs.

| Storage type | Compatible driver | Description |
| --- | --- | --- |
| [Premium SSD](/en-us/azure/virtual-machines/disks-types#premium-ssds) | Azure Disks CSI driver | **Maximum data resiliency**. Azure Premium SSD delivers high-performance storage and seamlessly works with Azure Premium zone-redundant storage (ZRS). Premium SSD is provisioned based on specific sizes, which each offer certain IOPS and throughput levels. |
| [Premium SSD v2](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2) | Azure Disks CSI driver | **Best price-performance**. Azure Premium SSD v2 offers higher performance than Azure Premium SSDs while also generally being less costly. Unlike Premium SSDs, Premium SSD v2 doesn't have dedicated sizes. You can set a Premium SSD v2 to any supported size you prefer, and make granular adjustments to the performance without downtime. Azure Premium SSD v2 disks have certain limitations that you should be aware of. For a complete list, see [Premium SSD v2 limitations](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2-limitations). |
| [Local NVMe or temp SSD (Ephemeral Disks)](/en-us/azure/storage/container-storage/use-container-storage-with-local-disk#what-is-ephemeral-disk) | Azure Container Storage only | **Maximum performance**. Ephemeral Disks are local NVMe and temporary SSD storage available on select VM families. They offer the highest possible IOPS, throughput, and submillisecond latency for your AKS cluster. You can also take advantage of Ephemeral Disks' high performance using [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction), a managed Kubernetes storage solution that dynamically provisions persistent volumes for stateful workloads like PostgreSQL. However, because these disks reside on the local VMs hosting the cluster, data isn't persisted to an Azure storage service. As a result, any data stored on these disks will be lost if the cluster is stopped or deallocated. To address this limitation, later sections in this guide show you how to set up periodic backups of your PostgreSQL data to [Azure Blob Storage](/en-us/azure/storage/blobs/). |