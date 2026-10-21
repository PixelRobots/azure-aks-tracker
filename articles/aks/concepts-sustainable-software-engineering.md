---
layout: Conceptual
title: Concepts - Sustainable software engineering in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-sustainable-software-engineering
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
description: Learn about sustainable software engineering in Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.custom: aks-getting-started
ms.date: 2023-06-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 6f90a959-6812-15a2-2374-747355db2567
document_version_independent_id: a19058e6-fc49-3a3f-5a22-414b46505954
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-sustainable-software-engineering.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-sustainable-software-engineering
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-sustainable-software-engineering.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7ac2bfb3-4fd0-7753-da39-1f633154c8cb
---

# Concepts - Sustainable software engineering in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn

The sustainable software engineering principles are a set of competencies to help you define, build, and run sustainable applications. The overall goal is to reduce the carbon footprint in every aspect of your application. The Azure Well-Architected Framework guidance for sustainability aligns with the Principles of Sustainable Software Engineering from the [Green Software Foundation](https://greensoftware.foundation/) and provides an overview of the principles of sustainable software engineering.

Sustainable software engineering is a shift in priorities and focus. In many cases, the way most software is designed and run highlights fast performance and low latency. Sustainable software engineering focuses on reducing as much carbon emission as possible.

- Applying sustainable software engineering principles can give you faster performance or lower latency, such as lowering total network traversal.
- Reducing carbon emissions may cause slower performance or increased latency, such as delaying low-priority workloads.

The following guidance focuses on services you're building or operating on Azure with Azure Kubernetes Service (AKS). This article includes design and configuration checklists, recommended design practices, and configuration options. Before applying sustainable software engineering principles to your application, review the priorities, needs, and trade-offs of your application.

## Prerequisites

- Understanding the Well-Architected Framework sustainability guidance can help you produce a high quality, stable, and efficient cloud architecture. We recommend that you start by reading more about [sustainable workloads](/en-us/azure/architecture/framework/sustainability/sustainability-get-started) and reviewing your workload using the [Microsoft Azure Well-Architected Review](https://aka.ms/assessments) assessment.
- It's crucial you have clearly defined business requirements when building applications, as they might have a direct impact on both cluster and workload architectures and configurations. When building or updating existing applications, review the Well-Architected Framework sustainability design areas, alongside your application's holistic lifecycle.

## Understanding the shared responsibility model

Sustainability is a shared responsibility between the cloud provider and the customer or partner designing and deploying AKS clusters on the platform. Deploying AKS doesn't automatically make it sustainable, even if the [data centers are optimized for sustainability](https://infrastructuremap.microsoft.com/fact-sheets). Applications that aren't properly optimized may still emit more carbon than necessary.

Learn more about the [shared responsibility model for sustainability](/en-us/azure/architecture/framework/sustainability/sustainability-design-methodology#a-shared-responsibility).

## Design principles

- **[Carbon Efficiency](https://learn.greensoftware.foundation/practitioner/carbon-efficiency)**: Emit the least amount of carbon possible.

    A carbon efficient cloud application is one that's optimized, and the starting point is the cost optimization.
- **[Energy Efficiency](https://learn.greensoftware.foundation/practitioner/energy-efficiency/)**: Use the least amount of energy possible.

    One way to increase energy efficiency is to run the application on as few servers as possible with the servers running at the highest utilization rate, also increasing hardware efficiency.
- **[Hardware Efficiency](https://learn.greensoftware.foundation/practitioner/hardware-efficiency)**: Use the least amount of embodied carbon possible.

    There are two main approaches to hardware efficiency:

    - For end-user devices, it's extending hardware lifespan.
    - For cloud computing, it's increasing resource utilization.
- **[Carbon Awareness](https://learn.greensoftware.foundation/practitioner/carbon-awareness)**: Do more when the electricity is cleaner and do less when the electricity is dirtier.

    Being carbon aware means responding to shifts in carbon intensity by increasing or decreasing your demand.

## Design patterns and practices

Before reviewing the detailed recommendations in each of the design areas, we recommend you carefully consider the following design patterns for building sustainable workloads on AKS:

| Design pattern | Applies to workload | Applies to cluster |
| --- | --- | --- |
| Design for independent scaling of logical components | ✔️ |  |
| Design for event-driven scaling | ✔️ |  |
| Aim for stateless design | ✔️ |  |
| Enable cluster and node autoupdates |  | ✔️ |
| Install supported add-ons and extensions | ✔️ | ✔️ |
| Containerize your workload where applicable | ✔️ |  |
| Use energy efficient hardware |  | ✔️ |
| Match the scalability needs and utilize autoscaling and bursting capabilities |  | ✔️ |
| Turn off workloads and node pools outside of business hours | ✔️ | ✔️ |
| Delete unused resources | ✔️ | ✔️ |
| Tag your resources | ✔️ | ✔️ |
| Optimize storage utilization | ✔️ | ✔️ |
| Choose a region that is closest to users |  | ✔️ |
| Reduce network traversal between nodes |  | ✔️ |
| Evaluate using a service mesh |  | ✔️ |
| Optimize log collection | ✔️ | ✔️ |
| Cache static data | ✔️ | ✔️ |
| Evaluate whether to use TLS termination | ✔️ | ✔️ |
| Use cloud native network security tools and controls | ✔️ | ✔️ |
| Scan for vulnerabilities | ✔️ | ✔️ |

## Application design

Explore this section to learn more about how to optimize your applications for a more sustainable application design.

### Design for independent scaling of logical components

A microservice architecture may reduce the compute resources required, as it allows for independent scaling of its logical components and ensures they're scaled according to demand.

- Consider using the [Dapr Framework](https://dapr.io/) or [other CNCF projects](/en-us/azure/architecture/example-scenario/apps/build-cncf-incubated-graduated-projects-aks) to help you separate your application functionality into different microservices and to allow independent scaling of its logical components.

### Design for event-driven scaling

When you scale your workload based on relevant business metrics, such as HTTP requests, queue length, and cloud events, you can help reduce resource utilization and carbon emissions.

- Use [Keda](https://keda.sh/) when building event-driven applications to allow scaling down to zero when there's no demand.

### Aim for stateless design

Removing state from your design reduces the in-memory or on-disk data required by the workload to function.

- Consider [stateless design](operator-best-practices-multi-region#remove-service-state-from-inside-containers) to reduce unnecessary network load, data processing, and compute resources.

## Application platform

Explore this section to learn how to make better informed platform-related decisions around sustainability.

### Enable cluster and node autoupdates

An up-to-date cluster avoids unnecessary performance issues and ensures you benefit from the latest performance improvements and compute optimizations.

- Enable [cluster autoupgrade](auto-upgrade-cluster) and [apply security updates to nodes automatically using GitHub Actions](node-upgrade-github-actions) to ensure your cluster has the latest improvements.

### Install supported add-ons and extensions

Add-ons and extensions covered by the [AKS support policy](support-policies) provide further supported functionalities to your cluster while allowing you to benefit from the latest performance improvements and energy optimizations throughout your cluster lifecycle.

- Install [KEDA](integrations#available-add-ons) as an add-on.
- Install [GitOps & Dapr](cluster-extensions?tabs=azure-cli#currently-available-extensions) as extensions.

### Containerize your workload where applicable

Containers allow for reducing unnecessary resource allocation and making better use of the resources deployed as they allow for bin packing and require less compute resources than virtual machines.

- Use [Draft](draft) to simplify application containerization by generating Dockerfiles and Kubernetes manifests.

### Use energy efficient hardware

Ampere's Cloud Native Processors are uniquely designed to meet both the high performance and power efficiency needs of the cloud.

- Evaluate if nodes with [Ampere Altra Arm–based processors](https://azure.microsoft.com/blog/azure-virtual-machines-with-ampere-altra-arm-based-processors-generally-available/) are a good option for your workloads.

### Match the scalability needs and utilize autoscaling and bursting capabilities

An oversized cluster doesn't maximize utilization of compute resources and can lead to a waste of energy. Separate your applications into different node pools to allow for cluster right-sizing and independent scaling according to the application requirements. As you run out of capacity in your AKS cluster, grow from AKS to ACI to scale out extra pods to serverless nodes and ensure your workload uses all the allocated resources efficiently.

- Size your cluster to match the scalability needs of your application. Use the [cluster autoscaler](cluster-autoscaler) with [virtual nodes](virtual-nodes) to rapidly scale and maximize compute resource utilization.
- You can also [enforce resource quotas](operator-best-practices-scheduler#enforce-resource-quotas) at the namespace level and [scale user node pools to zero](scale-cluster?tabs=azure-cli#scale-user-node-pools-to-0) when there's no demand.

### Turn off workloads and node pools outside of business hours

Workloads may not need to run continuously and could be turned off to reduce energy waste and carbon emissions. You can completely turn off (stop) your node pools in your AKS cluster, allowing you to also save on compute costs.

- Use the [node pool stop/start](start-stop-nodepools) to turn off your node pools outside of business hours.
- Use the [KEDA CRON scaler](https://keda.sh/docs/2.7/scalers/cron/) to scale down your workloads (pods) based on time.

## Operational procedures

Explore this section to set up your environment for measuring and continuously improving your workloads cost and carbon efficiency.

### Delete unused resources

You should identify and delete any unused resources, such as unreferenced images and storage resources, as they have a direct impact on hardware and energy efficiency. To ensure continuous energy optimization, you must treat identifying and deleting unused resources as a process rather than a point-in-time activity.

- Use [Azure Advisor](/en-us/azure/advisor/advisor-cost-recommendations) to identify unused resources.
- Use [ImageCleaner](image-cleaner?tabs=azure-cli) to clean up stale images and remove an area of risk in your cluster.

### Tag your resources

Getting the right information and insights at the right time is important for producing reports about performance and resource utilization.

- Set [Azure tags on your cluster](use-tags) to enable monitoring of your workloads.

## Storage

Explore this section to learn how to design a more sustainable data storage architecture and optimize existing deployments.

### Optimize storage utilization

The data retrieval and data storage operations can have a significant impact on both energy and hardware efficiency. Designing solutions with the correct data access pattern can reduce energy consumption and embodied carbon.

- Understand the needs of your application to [choose the appropriate storage](operator-best-practices-storage#choose-the-appropriate-storage-type) and define it using [storage classes](operator-best-practices-storage#create-and-use-storage-classes-to-define-application-needs) to avoid storage underutilization.
- Consider [provisioning volumes dynamically](operator-best-practices-storage#dynamically-provision-volumes) to automatically scale the number of storage resources.

## Network and connectivity

Explore this section to learn how to enhance and optimize network efficiency to reduce unnecessary carbon emissions.

### Choose a region that is closest to users

The distance from a data center to users has a significant impact on energy consumption and carbon emissions. Shortening the distance a network packet travels improves both your energy and carbon efficiency.

- Review your application requirements and [Azure geographies](https://azure.microsoft.com/explore/global-infrastructure/geographies/#overview) to choose a region closest to where most network packets are going.

### Reduce network traversal between nodes

Placing nodes in a single region or a single availability zone reduces the physical distance between the instances. However, for business critical workloads, you need to ensure your cluster is spread across multiple availability zones, which may result in more network traversal and increase in your carbon footprint.

- Consider deploying your nodes within a [proximity placement group](/en-us/azure/virtual-machines/co-location) to reduce the network traversal by ensuring your compute resources are physically located close to each other.
- For critical workloads, configure [proximity placement groups with availability zones](reduce-latency-ppg#configure-proximity-placement-groups-with-availability-zones).

### Evaluate using a service mesh

A service mesh deploys extra containers for communication, typically in a [sidecar pattern](/en-us/azure/architecture/patterns/sidecar), to provide more operational capabilities, which leads to an increase in CPU usage and network traffic. Nevertheless, it allows you to decouple your application from these capabilities as it moves them out from the application layer and down to the infrastructure layer.

- Carefully consider the increase in CPU usage and network traffic generated by [service mesh](servicemesh-about) communication components before making the decision to use one.

### Optimize log collection

Sending and storing all logs from all possible sources (workloads, services, diagnostics, and platform activity) can increase storage and network traffic, which impacts costs and carbon emissions.

- Make sure you're collecting and retaining only the necessary log data to support your requirements. [Configure data collection rules for your AKS workloads](/en-us/azure/azure-monitor/containers/container-insights-data-collection-configmap#data-collection-settings) and implement design considerations for [optimizing your Log Analytics costs](/en-us/azure/azure-monitor/best-practices-cost).

### Cache static data

Using Content Delivery Network (CDN) is a sustainable approach to optimizing network traffic because it reduces the data movement across a network. It minimizes latency through storing frequently read static data closer to users, and helps reduce network traffic and server load.

- Ensure you [follow best practices](/en-us/azure/architecture/best-practices/cdn) for CDN.
- Consider using [Azure CDN](/en-us/azure/cdn/cdn-how-caching-works?toc=%2fazure%2ffrontdoor%2fTOC.json) to lower the consumed bandwidth and keep costs down.

## Security

Explore this section to learn more about the recommendations leading to a sustainable, right-sized security posture.

### Evaluate whether to use TLS termination

Transport Layer Security (TLS) ensures that all data passed between the web server and web browsers remain private and encrypted. However, terminating and re-establishing TLS increases CPU utilization and might be unnecessary in certain architectures. A balanced level of security can offer a more sustainable and energy efficient workload, while a higher level of security may increase the compute resource requirements.

- Review the information on TLS termination when using [Application Gateway](/en-us/azure/application-gateway/ssl-overview) or [Azure Front Door](/en-us/azure/application-gateway/ssl-overview). Determine whether you can terminate TLS at your border gateway, and continue with non-TLS to your workload load balancer and workload.

### Use cloud native network security tools and controls

Azure Front Door and Application Gateway help manage traffic from web applications, while Azure Web Application Firewall provides protection against OWASP top 10 attacks and load shedding bad bots at the network edge. These capabilities help remove unnecessary data transmission and reduce the burden on the cloud infrastructure with lower bandwidth and fewer infrastructure requirements.

- Use [Application Gateway Ingress Controller (AGIC) in AKS](/en-us/azure/architecture/example-scenario/aks-agic/aks-agic) to filter and offload traffic at the network edge from reaching your origin to reduce energy consumption and carbon emissions.

### Scan for vulnerabilities

Many attacks on cloud infrastructure seek to misuse deployed resources for the attacker's direct gain leading to an unnecessary spike in usage and cost. Vulnerability scanning tools help minimize the window of opportunity for attackers and mitigate any potential malicious usage of resources.

- Follow recommendations from [Microsoft Defender for Cloud](/en-us/security/benchmark/azure/security-control-vulnerability-management).
- Run automated vulnerability scanning tools, such as [Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-vulnerability-assessment-azure), to avoid unnecessary resource usage. These tools help identify vulnerabilities in your images and minimize the window of opportunity for attackers.