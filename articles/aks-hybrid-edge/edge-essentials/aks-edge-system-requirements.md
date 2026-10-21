---
layout: Conceptual
title: AKS Edge Essentials system requirements | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-system-requirements
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Requirements and supported versions for AKS Edge Essentials.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: limits-and-quotas
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-concept, edge-essentials
locale: en-us
document_id: 6c979d3b-f29b-f8ab-6c36-96666def090f
document_version_independent_id: 7d5acecd-d411-653f-3a6b-542bb9ab44cc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-system-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-system-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-system-requirements.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/e0ffb20c-01c6-407b-a9bd-29111652a1dc
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/3904bce4-d817-48cf-85fd-b6146fca83b7
platformId: 20623e53-6999-9f4a-aebb-064463c24529
---

# AKS Edge Essentials system requirements | Microsoft Learn

This article describes the requirements for the host machine that runs AKS Edge Essentials.

## Hardware requirements

| Specs | Local cluster | Arc-connected cluster and GitOps |
| --- | --- | --- |
| Host OS | Windows 10/11 IoT Enterprise/Enterprise/Pro and Windows Server 2019, 2022 |  |
| Total physical memory | 4 GB with at least 2.5 GB free | 8 GB with at least 4.5 GB free |
| CPU | 2 vCPUs, clock speed at least 1.8 GHz | 4 vCPUs, clock speed at least 1.8 GHz |
| Disk space | At least 14 GB free | At least 19 GB free |
| Disk type | SSD | SSD |

To better understand the concept of vCPUs, [see this article](https://social.technet.microsoft.com/wiki/contents/articles/1234.hyper-v-concepts-vcpu-virtual-processor-q-a.aspx).

To better understand the etcd hardware recommendations, [see this article](https://etcd.io/docs/v3.5/op-guide/hardware/).

You can run AKS Edge Essentials in an Azure VM. You can create a Windows VM with either Windows 10/11 IoT Enterprise/Enterprise/Pro and Windows Server 2019, 2022 SKU, on a VM image that supports nested virtualization such as the [Dv5 and Dsv5-series](/en-us/azure/virtual-machines/dv5-dsv5-series) virtual machines. When using an Azure VM, a premium SSD is required, per the [Azure Virtual Machine documentation](/en-us/azure/virtual-machines/disks-types#disk-type-comparison).

You can also run AKS Edge Essentials in a virtual machine on VMware and Hyper-V as described [here.](aks-edge-howto-setup-nested-environment)

### OS requirements

Install Windows 10/11 IoT Enterprise/Enterprise/Pro on your machine and activate Windows. We recommend using the latest [client version 22H2 (OS build 19045)](/en-us/windows/release-health/release-information) or [Server 2022 (OS build 20348)](/en-us/windows/release-health/windows-server-release-info). You can [download a version of Windows 10 here](https://www.microsoft.com/software-download/windows10) or [Windows 11 here](https://www.microsoft.com/software-download/windows11).

Note

Windows 10 IoT Enterprise, Windows 11 IoT Enterprise, and Windows Server 2022 IoT Enterprise are binary-equivalent to the non-IoT releases, differing in [licensing and distribution](/en-us/windows/iot/iot-enterprise/getting_started).

## Maximum hardware specifications supported

| Parameter | Permissible limit |
| --- | --- |
| Maximum number of VMs per machine | 1 Linux VM + 1 Windows VM (optional) |
| Maximum number of vCPUs assigned to virtual machines | 16 vCPUs |
| Maximum number of machines per cluster | 15 machines |

Note

The vCPU limit is per-host, not per-node.

## GA feature support matrix

- **Supported Kubernetes distribution**: currently supported Kubernetes versions on both K3s and K8s [are described in this table](aks-edge-howto-setup-machine#download-aks-edge-essentials).
- **Deployment options**: single-machine clusters and full Kubernetes deployment on single machines only. Full deployment across multiple machines isn't supported in GA.
- **Workloads**: only Linux worker nodes.
- **Network plugins**: Calico on K8s, Flannel on K3s.
- **Secret encryption**: [KMS provider for AKS Edge Essentials](aks-edge-howto-secret-encryption).

## Experimental or prerelease features

- **Deployment options**: Full Kubernetes deployment on multiple machines.
- **Workloads**: Windows worker nodes.
- **GPU**: [GPU-PV](aks-edge-gpu).
- **Secret Encryption**: [KMS plugin for AKS Edge Essentials](aks-edge-howto-secret-encryption).
- **Security**: [Workload identity](aks-edge-workload-identity). Workload identity federation is only available for deployment of Azure IoT Operations on top of AKS Edge Essentials.
- **Network plugins**: Calico on K3S (discontinued).