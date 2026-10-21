---
layout: Conceptual
title: Pod sandboxing in Azure Kubernetes Service (AKS) overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-pod-sandboxing
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
description: Learn how to use Pod sandboxing in Azure Kubernetes Service (AKS) to isolate workloads in lightweight pod virtual machines (VMs) for stronger compute isolation.
ms.topic: how-to
ms.date: 2026-09-17T00:00:00.0000000Z
ms.subservice: aks-security
ms.author: schaffererin
author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 4b859a0a-647f-0b6d-c476-95b099d01043
document_version_independent_id: a0a35740-76c3-07cb-3455-a35c062f9c40
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-pod-sandboxing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-pod-sandboxing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-pod-sandboxing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1261b528-abcc-e56f-b6fd-8b226ab55992
---

# Pod sandboxing in Azure Kubernetes Service (AKS) overview - Azure Kubernetes Service | Microsoft Learn

As AKS clusters scale and host workloads from multiple teams or tenants, shared infrastructure can make isolation more complex. You might need stronger isolation to prevent resource-intensive or bursty workloads from disrupting predictable workloads. You might also need to isolate sensitive workloads to meet security requirements.

To meet these requirements, you might isolate your workloads through logical or physical isolation strategies. For logical isolation, use [Kubernetes namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) to separate resources and deployments. Namespaces share the underlying cluster infrastructure, so they don't provide the same physical isolation boundary as separate clusters. While separate clusters provide a physical boundary, this strategy can increase costs when the clusters don't use their full capacity.

Pod sandboxing on AKS introduces the ability to run your workloads in separate lightweight pod virtual machines (VMs). Each pod VM provides a compute isolation boundary: the workload runs with its own guest kernel and is isolated from the host kernel and workloads in other pod VMs.

Pod sandboxing is built on the open-source [Kata Containers](https://katacontainers.io/) project.

Important

The pod VM boundary provides compute isolation only. It doesn't isolate the AKS control plane, storage or data paths, or actions performed by users with cluster-admin access. Pod sandboxing alone doesn't provide complete hard multitenancy. For a multitenant deployment, review the [AKS guidance for multitenant solutions](/en-us/azure/architecture/guide/multitenant/service/aks) and apply the required identity, network, storage, and governance controls.

## Architecture and components

Pod sandboxing uses the Kata Containers runtime to create a lightweight pod VM for each sandboxed pod. The following diagram shows how the host-side components create and manage the isolated pod VM and how the guest-side components run the workload.

- In the pod manifest, set `runtimeClassName: kata-vm-isolation` to select the Kata Containers runtime.
- Containerd invokes the Kata shim (`containerd-shim-kata-v2`) instead of the standard runtime shim.
- The Kata shim starts the Cloud Hypervisor virtual machine monitor (VMM), which creates a pod VM with a separate guest kernel and the Kata agent.
- The Kata agent creates and manages the containers and workload processes inside the pod VM.
- When the pod VM is deleted, the Kata shim shuts down the pod VM and releases its resources back to the container host.

## Benefits and use cases

Pod sandboxing isolates each sandboxed pod in a lightweight pod VM with its own guest kernel. This compute boundary separates the workload from the host kernel and workloads in other pod VMs. Combine pod sandboxing with controls such as network policies and Azure Policy to address network and governance risks that the pod VM boundary doesn't cover. For guidance on selecting controls for multitenant deployments, see [AKS guidance for multitenant solutions](/en-us/azure/architecture/guide/multitenant/service/aks).

### Common use cases

Pod sandboxing can help you:

- Host workloads from different tenants on the same AKS cluster while providing a separate compute isolation boundary for each sandboxed pod.
- Isolate untrusted workloads from the host kernel and workloads in other pod VMs while continuing to use shared cluster capacity.
- Protect sensitive or high-value workloads from workloads running in other pod VMs.
- Reduce the effect of resource-intensive or bursty workloads on other sandboxed pods by applying CPU and memory requests and limits to each pod VM.
- Limit the compute blast radius of a workload failure to its pod VM.

### Workload isolation

[![Screenshot of architecture diagram showing workload isolation in AKS Pod sandboxing.](media/concepts-pod-sandboxing/workload-isolation.png)](media/concepts-pod-sandboxing/workload-isolation.png#lightbox)

Pod sandboxing lets you colocate workloads on shared cluster nodes while maintaining a separate compute isolation boundary for each sandboxed pod.

You can declare resource requests and limits for your workloads. AKS applies default values when you omit them. The pod VM limits a resource-intensive workload to the CPU and memory allocated to that VM. If a workload causes its pod VM to fail, the compute isolation boundary protects workloads in other pod VMs from that failure.

### Flexibility

You can run sandboxed and standard pods in the same cluster. This flexibility lets you apply pod VM isolation only to workloads that require it.

### Open-source components

Pod sandboxing uses open-source components, including the [Cloud Hypervisor](https://github.com/cloud-hypervisor/cloud-hypervisor) VMM and the [Kata Containers](https://katacontainers.io/) runtime. Open development provides transparency into the isolation components and enables community review. The architecture also separates the guest kernel in each pod VM from the [Azure Linux](https://github.com/microsoft/azurelinux) host kernel.

## Migrate existing workloads

For a basic deployment, add the Kata runtime class to an existing pod specification to run the workload in a pod VM. This manifest change doesn't guarantee behavior identical to a pod that uses the standard `runc` runtime. Before migration, validate the workload's operational behavior and Kubernetes feature compatibility, and account for the pod VM's resource sizing and overhead. For more information, see [Considerations for Pod sandboxing](considerations-pod-sandboxing).