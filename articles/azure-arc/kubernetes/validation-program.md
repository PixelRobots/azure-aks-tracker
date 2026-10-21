---
layout: Conceptual
title: Azure Arc-enabled Kubernetes validation - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/validation-program
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
ms.date: 2025-09-26T00:00:00.0000000Z
ms.topic: how-to
description: Describes Arc validation program for Kubernetes distributions
locale: en-us
document_id: e466c696-a6a5-28d7-ac05-8add9a152ec0
document_version_independent_id: 410c4c1d-ad81-3347-c6b9-a22ef47e4795
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/validation-program.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/validation-program
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/validation-program.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 3a35a10a-c85f-e80e-85fc-756c41dcdb6d
---

# Azure Arc-enabled Kubernetes validation - Azure Arc | Microsoft Learn

The Azure Arc team works with key industry Kubernetes offering providers to validate Azure Arc-enabled Kubernetes with their Kubernetes distributions. Future major and minor versions of Kubernetes distributions released by these providers will be validated for compatibility with Azure Arc-enabled Kubernetes.

Important

Azure Arc-enabled Kubernetes works with any Kubernetes clusters that are certified by the Cloud Native Computing Foundation (CNCF), even if they are not listed on this page.

## Validated distributions

The following Microsoft-provided Kubernetes distributions and infrastructure providers successfully passed the conformance tests for Azure Arc-enabled Kubernetes:

| Distribution and infrastructure provider | Version |
| --- | --- |
| Cluster API Provider on Azure | Release version: [1.20.1](https://github.com/kubernetes-sigs/cluster-api-provider-azure/releases/tag/v1.20.1); API version v1.10.4; Kubernetes version: [v1.33.1](https://github.com/kubernetes/kubernetes/releases/tag/v1.33.1) |
| AKS Enabled by Azure Arc | Release version: [AKS on Azure Local version 2503](/en-us/azure/aks/aksarc/aks-whats-new-local#release-2503); Kubernetes version: [1.30.4](https://github.com/kubernetes/kubernetes/releases/tag/v1.30.4); [1.29.9](https://github.com/kubernetes/kubernetes/releases/tag/v1.29.9); [1.28.14](https://github.com/kubernetes/kubernetes/releases/tag/v1.28.14) |
| K8s on Azure Stack Edge | Release version: Azure Stack Edge 2501 (3.3.2501.1176); Kubernetes version: [1.29.4](https://github.com/kubernetes/kubernetes/releases/tag/v1.29.4) |
| AKS Edge Essentials | Release version [1.10.868.0](https://github.com/Azure/AKS-Edge/releases); Kubernetes version [1.29.9](https://github.com/kubernetes/kubernetes/releases/tag/v1.29.9) |

The following providers and their corresponding Kubernetes distributions successfully passed the conformance tests for Azure Arc-enabled Kubernetes:

| Provider name | Distribution name | Validated versions |
| --- | --- | --- |
| SUSE Rancher | [Rancher Kubernetes Engine (RKE/RKE2)](https://www.rancher.com/index.php/products/rke)/(https://docs.rke2.io/) | [v1.33.3-rc2+rke2r1](https://github.com/rancher/rke2/releases)v1.32.7-rc2+rke2r1v1.31.11-rc2+rke2r1 |
| SUSE Rancher | [K3s](https://rancher.com/products/k3s/) | [K3S version v1.33.2+k3s1](https://github.com/k3s-io/k3s/releases/tag/v1.33.2%2Bk3s1)[K3S version v1.32.3+k3s1](https://github.com/k3s-io/k3s/releases/tag/v1.32.3%2Bk3s1)[K3S version v1.31.5+k3s1](https://github.com/k3s-io/k3s/releases/tag/v1.31.5%2Bk3s1) |
| Red Hat | [OpenShift Container Platform](https://www.openshift.com/products/container-platform) | [4.19.4](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/release_notes/ocp-4-19-release-notes), [4.18.9](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/release_notes/ocp-4-18-release-notes), [4.17.5](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/release_notes/ocp-4-17-release-notes), |
| VMware | [Tanzu Kubernetes Grid/vSphere Kubernetes Service](https://tanzu.vmware.com/kubernetes-grid) | VKS 3.3, TKr v1.32.0+vmware.6-fips, Upstream K8s 1.32VKS 3.3, TKr v1.31.4+vmware.1-fips, Upstream K8s 1.31 |
| Canonical | [Charmed Kubernetes](https://ubuntu.com/kubernetes/charmed-k8s/docs) | [1.34](https://ubuntu.com/kubernetes/charmed-k8s/docs/1.34/components), [1.33](https://ubuntu.com/kubernetes/docs/1.33/components), [1.32](https://ubuntu.com/kubernetes/charmed-k8s/docs/1.32/components) |
| Wind River | [Wind River Cloud Platform](https://www.windriver.com/products/cloud-platform) | Wind River Cloud Platform 26.03; Upstream K8s version: 1.34.1 |

## Scenarios validated

The conformance tests run as part of the Azure Arc-enabled Kubernetes validation cover the following scenarios:

1. Connect Kubernetes clusters to Azure Arc:

    - Deploy Azure Arc-enabled Kubernetes agent Helm chart on cluster.
    - Agents send cluster metadata to Azure.
2. Configuration:

    - Create configuration on top of Azure Arc-enabled Kubernetes resource.
    - [Flux](https://docs.fluxcd.io/), needed for setting up [GitOps workflow](tutorial-use-gitops-flux2), is deployed on the cluster.
    - Flux pulls manifests and Helm charts from demo Git repo and deploys to cluster.