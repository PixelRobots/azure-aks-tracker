---
layout: Conceptual
title: AKS release tracker - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/release-tracker
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
description: Learn how to determine which Azure regions have AKS release deployments rolled out in real time.
ms.topic: overview
ms.date: 2026-02-05T00:00:00.0000000Z
ms.author: yudian
author: yudian
ms.custom: mvc, build-2023
locale: en-us
document_id: 90fc72e1-15cd-fd28-0cc6-14c03433247f
document_version_independent_id: 3e2f76f2-8f6c-0073-737e-27fb9b456c86
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/release-tracker.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/release-tracker
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/release-tracker.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e8deec08-fee9-398d-4a13-6dacbfb5522a
---

# AKS release tracker - Azure Kubernetes Service | Microsoft Learn

AKS regularly releases security patches, bug fixes, component updates, and feature updates for all AKS clusters. AKS release tracker provides real-time information on when these AKS releases are landing in the region your AKS cluster is located in.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Overview

With AKS release tracker, you can follow specific component updates present in an AKS version release, such as fixes shipped to a core add-on, and node image updates for Azure Linux, Ubuntu, and Windows. The tracker provides links to the specific version of the AKS [release notes](https://github.com/Azure/AKS/releases) to help you identify relevant release instances. Real time data updates allow you to track the release order and status of each region.

AKS release tracker provides a regional breakdown of the following three independent release trains:

- **AKS releases** ships updates, bug fixes, and security patches for features and add-ons. Some of the feature/add-on updates require upgrading the AKS cluster to a minimum required Kubernetes version. For more information, see the [AKS release notes](https://github.com/Azure/AKS/releases). These releases are automatically applied to the clusters when the release reaches the region where the cluster is located.
- **AKS Kubernetes versions** updates the [AKS supported Kubernetes minor and patch versions](supported-kubernetes-versions) and [long-term support (LTS) versions](long-term-support) available in each region. You can upgrade to new Kubernetes versions either manually or automatically using [cluster autoupgrade](auto-upgrade-cluster).
- **AKS node images** updates the latest node image available for Azure Linux, Ubuntu, and Windows in each region. You can upgrade to the latest node image version either manually or automatically using [autoupgrade for node images](auto-upgrade-node-os-image).

Note

You can use [planned maintenance](planned-maintenance) to control the schedule of AKS-initiated maintenance (AKS release train) and user-initiated maintenance (cluster autoupgrades and node image autoupgrades).

## Use the release tracker

To view the release tracker, visit the [AKS release status webpage](https://releases.aks.azure.com/webpage/index.html).

### AKS releases

The top half of the tracker shows the current latest version and three previously available release versions for each region and links to the corresponding release notes entries. This view is helpful when you want to track the available versions by region.

![Screenshot of the AKS release tracker's regional status table displayed in a web browser.](media/release-tracker/regional-status.png)

The bottom half of the tracker shows the release order. The table has two views: *By Region* and *By Version*.

![Screenshot of the AKS release tracker's release order table displayed in a web browser.](media/release-tracker/release-order.png)

### AKS supported Kubernetes versions release

AKS supports [three GA minor versions of Kubernetes](supported-kubernetes-versions) and might support any number of patches based on upstream community release availability for a given minor version. AKS also provides an [LTS option](long-term-support), which extends the support window for a Kubernetes version to give you more time to plan and test upgrades to newer Kubernetes versions. You can track all the real-time in-operation patch releases of AKS supported community versions and LTS versions by region with the **AKS Kubernetes Versions Release** tab in AKS Release Tracker. You can also reference the [AKS release calendar for minor versions](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions).

The top half of the tracker shows the regional status on the following:

- Supported [community versions of Kubernetes in AKS](supported-kubernetes-versions) and [LTS Kubernetes versions in AKS](long-term-support) that are **currently in operation** for each region.
- The **Recent Deprecated Version** column shows the latest out-of-support Kubernetes minor version for that region.

![Screenshot of the AKS release tracker's supported Kubernetes version regional status table displayed in a web browser.](media/release-tracker/kubernetes-version-status.png)

The bottom half of the tracker shows the regional release order of all [supported Kubernetes community versions in AKS](supported-kubernetes-versions) and [LTS Kubernetes versions in AKS](long-term-support). The table has two views: **By Region** and **By Version**.

![Screenshot of the AKS release tracker's supported Kubernetes version release order table displayed in a web browser.](media/release-tracker/kubernetes-version-order.png)

### AKS node image updates

The top half of **AKS Node Image** tab shows the latest node image version and three previously available node image versions for each region. This view is helpful when you want to track the available node image versions by region.

![Screenshot of the AKS release tracker's node image status table displayed in a web browser.](media/release-tracker/node-image-status.png)

The bottom half of **AKS Node Image** tab shows the node image update order. The table has two views: **By Region** and **By Version**.

![Screenshot of the AKS release tracker's node image order table displayed in a web browser.](media/release-tracker/node-image-order.png)

The **AKS Security Patch** tab shows the [last node image security patch version](auto-upgrade-node-os-image) for each region and update order.

![Screenshot of the AKS release tracker's security patch release status table displayed in a web browser.](media/release-tracker/security-patch.png)