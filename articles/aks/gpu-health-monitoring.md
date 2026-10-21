---
layout: Conceptual
title: GPU health monitoring in Node Problem Detector (NPD) in Azure Kubernetes Service (AKS) nodes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/gpu-health-monitoring
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
description: Learn about how AKS uses Node Problem Detector to expose issues on GPU-enabled nodes.
ms.topic: how-to
ms.date: 2026-02-27T00:00:00.0000000Z
author: sachidesai
ms.author: sachidesai
locale: en-us
document_id: 5ffd1836-a5a9-9086-e057-ca7dacce83db
document_version_independent_id: dd82e994-5d9b-ec23-40ba-8491fcb902ea
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/gpu-health-monitoring.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/gpu-health-monitoring
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/gpu-health-monitoring.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 2daeb987-a0e0-5c00-5819-1db9e0afa3b0
---

# GPU health monitoring in Node Problem Detector (NPD) in Azure Kubernetes Service (AKS) nodes - Azure Kubernetes Service | Microsoft Learn

This article describes how Azure Kubernetes Service (AKS) uses Node Problem Detector (NPD) to monitor the health of GPU-enabled node pools. NPD is a Kubernetes component that detects and reports node-level issues, including hardware faults, driver errors, and connectivity problems that can affect the performance and availability of GPU workloads.

## About GPU health monitoring in NPD

AKS supports GPU health monitoring through [Node Problem Detector (NPD)](node-problem-detector), enabling automatic detection and reporting of issues that affect GPU-enabled node pools on an AKS cluster. GPU health monitoring helps Kubernetes operators keep GPU nodes healthy and performant by surfacing hardware faults, communication failures, and system-level errors. NPD sets GPU-related node conditions and enables platform engineering teams to take action before issues impact application performance or availability.

These health signals are vital for ensuring optimal performance and reliability across a range of GPU workloads, including:

- Machine learning (ML) training and inference.
- AI model development.
- High-performance computing (HPC).
- Graphics rendering and data-intensive simulations.

## Limitations

AKS Node Problem Detector ***does not*** run GPU health checks on node pools with `--gpu-driver none`, where **self-managed** or custom GPU driver was installed on the nodes.

## Supported GPU health checks

NPD regularly monitors GPU-enabled node pools and sets conditions when anomalies are detected. The following GPU health checks are currently supported:

- **GPUMissing**: NPD verifies that the number of GPUs detected by the `nvidia-smi` utility matches the expected GPU count for the VM SKU assigned to the node.

    - A mismatch might indicate a hardware fault, driver issue, or misconfiguration. Accurate GPU enumeration is critical for ensuring scheduling accuracy and workload availability on GPU nodes.
- **GPUXIDErrors**: Checks for XID (eXecution ID) errors emitted by the GPU driver in the kernel logs. XID errors are low-level GPU faults that typically occur when:

    - The driver misprograms the GPU.
    - There's a corruption in the command stream sent to the GPU.
    - A hardware failure or instability affects GPU operation.

    For more information, see [XID errors on NVIDIA GPUs](https://docs.nvidia.com/deploy/xid-errors/index.html).
- **NVLink Status**: For NVIDIA VM SKUs that support NVLink, this condition confirms that NVLink is active and functioning.

    - NVLink is a high-speed interconnect used to facilitate data transfer between multiple GPUs.
    - If NVLink is inactive or degraded, multi-GPU workloads might experience reduced performance or communication bottlenecks.

    For more information, see [NVIDIA NVLink](https://www.nvidia.com/en-us/data-center/nvlink/).
- **InfiniBand Link Flapping**: NPD monitors for InfiniBand (IB) link flapping, or intermittent connectivity of the IB network device.

    - Link flapping shouldn't occur under normal operating conditions and might result in degraded inter-node communication for distributed workloads.
    - It can also signal physical layer issues, misconfigured firmware, or driver instability.
- **GPUClockThrottling**: NPD monitors GPU clock throttling conditions that may indicate performance degradation due to thermal, power, or hardware constraints. The check queries `nvidia-smi` for active clock throttle reasons and flags problematic conditions such as:

    - Hardware slowdown (`HW_SLOWDOWN`)
    - Software thermal slowdown (`SW_THERMAL_SLOWDOWN`)
    - Hardware thermal slowdown (`HW_THERMAL_SLOWDOWN`)
    - Hardware power brake slowdown (`HW_POWER_BRAKE_SLOWDOWN`)

    Normal or expected throttling states such as GPU idle, no throttling, or user-configured software power caps aren't flagged.

    For more information, see [NVIDIA clock throttle reasons](https://docs.nvidia.com/deploy/nvml-api/group__nvmlClocksThrottleReasons.html).
- **UnhealthyNvidiaDevicePlugin**: For [AKS-managed GPU node pools](aks-managed-gpu-nodes), NPD monitors the health of the NVIDIA device plugin systemd service (`nvidia-device-plugin.service`).

    - The NVIDIA device plugin is responsible for advertising GPU resources to the Kubernetes scheduler. If the service is not active, GPU resources might not be available for scheduling workloads.
    - This check applies only to AKS-managed GPU node pools.
- **NVIDIA GRID Driver License Check**: For NVIDIA VM SKUs that support GRID driver, this condition verifies license status of the installed GRID driver on [supported NVIDIA VM SKUs](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nvadsa10v5-series).

    - Invalid might indicate the installed GRID driver is not licensed.

## Frequently asked questions

### Does Node Problem Detector (NPD) automatically remediate GPU node issues?

NPD doesn't take direct action to remediate GPU-enabled node issues. NPD detects and reports problems by publishing Kubernetes node conditions and events. Any remediation (for example: draining a node, restarting workloads, or replacing faulty hardware) must be handled manually, through external automation, or alerting systems configured by the Kubernetes operator.

### On which Azure VM sizes does AKS conduct GPU health monitoring through NPD?

NPD conducts health checks on all GPU node pools that use AKS-managed GPU drivers (that is, node pools not created with `--gpu-driver none`). This covers the full range of NVIDIA GPU-enabled VM SKUs across the NC, ND, and NV series supported by AKS.

### Does NPD monitor the health of multi-instance GPU (MIG) node pools?

Yes, NPD health monitoring is supported on [MIG-enabled AKS node pools](gpu-multi-instance).