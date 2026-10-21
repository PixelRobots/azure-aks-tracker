---
layout: Conceptual
title: Introduction to Azure Kubernetes Service (AKS) Automatic - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/intro-aks-automatic
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
description: Simplify deployment and management of container-based applications in Azure by learning about the features and benefits of Azure Kubernetes Service Automatic.
ms.topic: overview
ms.custom: build-2024, biannual, build-2026
ms.date: 2026-07-07T00:00:00.0000000Z
author: wangyira
ms.author: wangamanda
locale: en-us
document_id: 5fbda896-b6c3-41fc-5b30-a81b6bdc3b4d
document_version_independent_id: 996a5f43-bb9b-a3b8-9e51-ca31c5272d1a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/intro-aks-automatic.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/intro-aks-automatic
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/intro-aks-automatic.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 14d2d9ba-2814-325c-27fd-2cea27b7e5aa
---

# Introduction to Azure Kubernetes Service (AKS) Automatic - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic

Azure Kubernetes Service (AKS) Automatic offers an experience that makes the most common tasks on Kubernetes fast and frictionless, while preserving the flexibility, extensibility, and consistency of Kubernetes. Azure takes care of your cluster setup, including node management, scaling, security, and preconfigured settings that follow AKS well-architected recommendations. Automatic clusters dynamically allocate compute resources based on your specific workload requirements and are tuned for running production applications.

- **Production ready by default**: Clusters are preconfigured for optimal production use, suitable for most applications. They offer fully managed node pools that automatically allocate and scale resources based on your workload needs. Pods are bin packed efficiently, to maximize resource utilization.
- **Guaranteed pod readiness**: AKS Automatic includes a [pod readiness SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services) that guarantees 99.9% of qualifying pod readiness operations complete within five minutes. This means your workloads start running promptly during scaling events and node provisioning, giving you confidence in your application's responsiveness without manual tuning.
- **Built-in best practices and safeguards**: AKS Automatic clusters have a hardened default configuration, with many cluster, application, and networking security settings enabled by default. AKS automatically patches your nodes and cluster components while adhering to any planned maintenance schedules.
- **Code to Kubernetes in minutes**: Go from a container image to a deployed application that adheres to best practices patterns within minutes, with access to the comprehensive capabilities of the Kubernetes API and its rich ecosystem.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Service level agreement

The service level agreement (SLA) for AKS Automatic clusters includes the following components:

- Pod readiness
- Uptime

For more information, see [Service Level Agreements (SLA) for Online Services](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services).

### Pod readiness SLA

AKS Automatic includes a [pod readiness SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services), a financially backed guarantee that 99.9% of qualifying pod readiness operations complete within 5 minutes. This SLA covers pod scheduling and node provisioning when needed.

The pod readiness SLA benefits workloads that depend on predictable scaling behavior, such as:

- **Web and API workloads** that need to scale out quickly during traffic spikes without degrading response times.
- **Event-driven processing** where new consumer pods must be ready promptly to avoid message backlog.
- **CI/CD and batch jobs** that require consistent pod startup times for reliable pipeline execution.

This guarantee is exclusive to AKS Automatic and is backed by the [Microsoft Online Services SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services). You don't need to configure anything to enable it and it comes included with every AKS Automatic cluster.

### Uptime SLA

AKS Automatic includes [uptime SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services), a financially backed guarantee for 99.95% availability of the Kubernetes API server. You don't need to configure anything to enable it and it comes included with every AKS Automatic cluster.

## AKS Automatic and Standard feature comparison

The following table provides a comparison of options that are available, preconfigured, and default in both AKS Automatic and AKS Standard. For more information on whether specific features are available in Automatic, you can check the documentation for that feature.

**Preconfigured** features are always enabled and you can't disable or change their settings. **Default** features are configured for you but can be changed. **Optional** features are available for you to configure and aren't enabled by default.

When enabling optional features, you can follow the linked feature documentation. When you reach a step for cluster creation, follow steps to create an [AKS Automatic cluster](automatic/quick-automatic-managed-network) instead of creating an AKS Standard cluster.

### Application deployment, monitoring, and observability

Application deployment can be streamlined using [automated deployments](automated-deployments) from source control, which creates Kubernetes manifest and generates CI/CD workflows. Additionally, the cluster is configured with monitoring tools such as Managed Prometheus for metrics, Managed Grafana for visualization, and Container Insights for log collection.

| Option | AKS Automatic | AKS Standard |
| --- | --- | --- |
| Application deployment | **Optional**:  • Use [automated deployments](automated-deployments) to containerize applications from source control, create Kubernetes manifests, and continuous integration/continuous deployment (CI/CD) workflows.  • Create deployment pipelines using [GitHub Actions for Kubernetes](kubernetes-action).  • Bring your own CI/CD pipeline. | **Optional**:  • Use [automated deployments](automated-deployments) to containerize applications from source control, create Kubernetes manifests, and continuous integration/continuous deployment (CI/CD) workflows.  • Create deployment pipelines using [GitHub Actions for Kubernetes](kubernetes-action).  • Bring your own CI/CD pipeline. |
| Monitoring, logging, and visualization | **Default**:  • [Managed Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview) for metric collection when using Azure CLI or the Azure portal.  • [Container insights](/en-us/azure/azure-monitor/containers/container-insights-overview) for log collection when using Azure CLI or the Azure portal.  • [Azure Monitor Dashboards with Grafana](/en-us/azure/azure-monitor/visualize/visualize-use-grafana-dashboards) for visualization is built in when using the Azure portal. **Optional**:  • [Managed Grafana](/en-us/azure/managed-grafana/overview) for visualization when using Azure CLI or the Azure portal. | **Default**: [Azure Monitor Dashboards with Grafana](/en-us/azure/azure-monitor/visualize/visualize-use-grafana-dashboards) for visualization is built in when using the Azure portal. **Optional**:  • [Managed Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview) for metric collection.  • [Managed Grafana](/en-us/azure/managed-grafana/overview) for visualization.  • [Container insights](/en-us/azure/azure-monitor/containers/container-insights-overview) for log collection.  • [Advanced Container Networking Services](advanced-container-networking-services-overview) container network observability for pod metrics, DNS, L4 metrics, and network flow logs. |

### Node management, scaling, and cluster operations

Node management is automatically handled without the need for manual user node pool creation, [system node pools and components are managed](automatic/aks-automatic-managed-system-node-pools-about#key-features-and-benefits) by AKS. Scaling is seamless, with nodes created based on workload requests. Additionally, features for workload scaling like Horizontal Pod Autoscaler (HPA), [Kubernetes Event Driven Autoscaling (KEDA)](keda-about), and [Vertical Pod Autoscaler (VPA)](vertical-pod-autoscaler) are enabled. The [pod readiness SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services) that guarantees 99.9% of pod readiness operations complete within 5 minutes. Clusters are configured for automatic node repair, automatic cluster upgrades, and detection of deprecated Kubernetes standard API usage. You can also set a planned maintenance schedule for upgrades if needed.

| Option | AKS Automatic | AKS Standard |
| --- | --- | --- |
| System node pools | **Preconfigured**: [AKS Automatic with managed system node pools](automatic/aks-automatic-managed-system-node-pools-about#key-features-and-benefits) creates, scales, upgrades the system nodes and system components on your behalf and hosts them in the AKS subscriptions. | **Default**: You create and manage system node pools. |
| Node autoprovisioning | **Preconfigured**: AKS Automatic manages the node pools using [node autoprovisioning](node-autoprovision). | **Optional**: AKS Standard manages user node pools using [node autoprovisioning](node-autoprovision). |
| Scaling | **Preconfigured**: AKS Automatic creates nodes based on workload requests using [Node Autoprovisioning](node-autoprovision). [Horizontal Pod Autoscaler (HPA)](tutorial-kubernetes-scale#autoscale-pods), [Kubernetes Event Driven Autoscaling (KEDA)](keda-about), and [Vertical Pod Autoscaler (VPA)](vertical-pod-autoscaler) are enabled on the cluster. | **Default:** Manual scaling of node pools. **Optional**:  • [Cluster autoscaler](cluster-autoscaler-overview) • [Node Autoprovisioning](node-autoprovision) • [Kubernetes Event Driven Autoscaling (KEDA)](keda-about) • [Vertical Pod Autoscaler (VPA)](vertical-pod-autoscaler) |
| Cluster tier and Service Level Agreement (SLA) | **Preconfigured**: Standard tier cluster with up to 5,000 nodes, a [cluster uptime SLA](free-standard-pricing-tiers#uptime-sla-terms-and-conditions), and a [pod readiness SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services) that guarantees 99.9% of qualifying pod readiness operations complete within 5 minutes. | **Default**: Free tier cluster with 10 nodes but can support up to 1,000 nodes. **Optional**:  • Standard tier cluster with up to 5,000 nodes and a [cluster uptime SLA](free-standard-pricing-tiers#uptime-sla-terms-and-conditions).  • Premium tier cluster with up to 5,000 nodes, [cluster uptime SLA](free-standard-pricing-tiers#uptime-sla-terms-and-conditions), and [long term support](long-term-support). |
| Node operating system | **Preconfigured for system node pool**: [Azure Linux](use-azure-linux)**Optional for user nodes**:  • [Azure Linux](use-azure-linux) • Ubuntu | **Default**: Ubuntu **Optional**:  • [Azure Linux](use-azure-linux) • [Windows Server](windows-vs-linux-containers) |
| Node resource group | **Preconfigured**: [Fully managed node resource group](node-resource-group-lockdown) to prevent accidental or intentional changes to cluster resources. | **Default**: Unrestricted **Optional**: [Read only](node-resource-group-lockdown) with node resource group lockdown |
| Node auto-repair | **Preconfigured**: Continuously monitors the health state of worker nodes and performs [automatic node repair](node-auto-repair) if they become unhealthy. | **Preconfigured**: Continuously monitors the health state of worker nodes and performs [automatic node repair](node-auto-repair) if they become unhealthy. |
| Cluster upgrades | **Preconfigured**: Clusters are [automatically upgraded using the stable channel](auto-upgrade-cluster#cluster-autoupgrade-channels) to minor version N-1, where N is the latest supported minor version. | **Default**: Manual upgrade. **Optional**: Automatic upgrade using a selectable [upgrade channel](auto-upgrade-cluster#cluster-autoupgrade-channels). |
| Node OS image upgrades | **Preconfigured**: Clusters are [automatically upgraded using the NodeImage channel](auto-upgrade-node-os-image#available-node-os-upgrade-channels) with security fixes and bug fixes. | **Default**: Manual upgrade. **Optional**: Automatic upgrade using a selectable [node OS upgrade channel](auto-upgrade-node-os-image#available-node-os-upgrade-channels) |
| Kubernetes API breaking change detection | **Preconfigured**: Cluster upgrades are stopped on detection of [deprecated Kubernetes standard API usage](stop-cluster-upgrade-api-breaking-changes). | **Preconfigured**: Cluster upgrades are stopped on detection of [deprecated Kubernetes standard API usage](stop-cluster-upgrade-api-breaking-changes). |
| Planned maintenance windows | **Default**: Set [planned maintenance schedule](planned-maintenance) configuration to control upgrades. | **Optional**: Set [planned maintenance schedule](planned-maintenance) configuration to control upgrades. |

### Security and policies

Cluster authentication and authorization use [Azure Role-based Access Control (RBAC) for Kubernetes authorization](entra-id-authorization) and applications can use features like [workload identity with Microsoft Entra Workload ID](workload-identity-overview) and [OpenID Connect (OIDC) cluster issuer](use-oidc-issuer) to have secure communication with Azure services. [Deployment safeguards](deployment-safeguards) enforce Kubernetes best practices through Azure Policy controls and the built-in [image cleaner](image-cleaner) removes unused images with vulnerabilities, enhancing image security.

| Option | AKS Automatic | AKS Standard |
| --- | --- | --- |
| Cluster authentication and authorization | **Preconfigured**: [Azure RBAC for Kubernetes authorization](entra-id-authorization) for managing cluster authentication and authorization by using Azure role-based access control. | **Default**: Local accounts. **Optional**:  • [Azure RBAC for Kubernetes authorization](entra-id-authorization) • [Kubernetes RBAC with Microsoft Entra integration](kubernetes-rbac-entra-id) |
| Cluster security | **Preconfigured**: [API server virtual network integration](api-server-vnet-integration) enables network communication between the API server and the cluster nodes over a private network without requiring a private link or tunnel. | **Optional**: [API server virtual network integration](api-server-vnet-integration) enables network communication between the API server and the cluster nodes over a private network without requiring a private link or tunnel. |
| Application security | **Preconfigured**:  • [Workload identity with Microsoft Entra Workload ID](workload-identity-overview) • [OpenID Connect (OIDC) cluster issuer](use-oidc-issuer)**Optional**: • [Advanced Container Networking Services](container-network-security-wireguard-encryption-concepts) container network security for pod traffic with Wireguard node encryption. | **Optional**:  • [Workload identity with Microsoft Entra Workload ID](workload-identity-overview) • [OpenID Connect (OIDC) cluster issuer](use-oidc-issuer)**Optional**: • [Advanced Container Networking Services](container-network-security-wireguard-encryption-concepts) container network security for pod traffic with Wireguard node encryption. |
| Image security | **Preconfigured**: [Image cleaner](image-cleaner) to remove unused images with vulnerabilities. | **Optional**: [Image cleaner](image-cleaner) to remove unused images with vulnerabilities. |
| Policy enforcement | **Preconfigured**: [Deployment safeguards](deployment-safeguards) and [baseline Pod Security Standards](deployment-safeguards#turn-on-pod-security-standards) that enforce Kubernetes best practices in your AKS cluster through Azure Policy controls in enforce mode.  • [Security restrictions for managed system node pools](automatic/aks-automatic-managed-system-node-pools-about#security-restrictions-for-managed-system-node-pools) protect managed system components and preserve the boundary between customer workloads and AKS-managed infrastructure. **Optional**: • [Advanced Container Networking Services](how-to-apply-l7-policies) container network security for Cilium DNS and L7 policies. | **Optional**: [Deployment safeguards](deployment-safeguards) and [Pod Security Standards](deployment-safeguards#turn-on-pod-security-standards) enforce Kubernetes best practices in your AKS cluster through Azure Policy controls in enforce mode or warning mode. **Optional**: • [Advanced Container Networking Services](how-to-apply-l7-policies) container network security for Cilium DNS and L7 policies. |
| Managed namespaces | **Optional**: Use [Managed namespaces](managed-namespaces) to create preconfigured namespaces where you can define network policies for ingress/egress, resource quotas for memory/CPU, and set-up labels/annotations. | **Optional**: Use [Managed namespaces](managed-namespaces) to create preconfigured namespaces where you can define network policies for ingress/egress, resource quotas for memory/CPU, and set-up labels/annotations. |

### Networking

AKS Automatic clusters use [managed Virtual Network powered by Azure CNI Overlay with Cilium](azure-cni-powered-by-cilium) for high-performance networking and robust security. Ingress is handled by [managed NGINX using the application routing add-on](app-routing), integrating seamlessly with Azure DNS and Azure Key Vault. Egress uses a [managed NAT gateway](nat-gateway#create-an-aks-cluster-with-a-managed-nat-gateway) for scalable outbound connections.

| Option | AKS Automatic | AKS Standard |
| --- | --- | --- |
| Virtual network | **Default**: [Managed Virtual Network using Azure CNI Overlay powered by Cilium](azure-cni-powered-by-cilium) combines the robust control plane of Azure CNI with the data plane of Cilium to provide high-performance networking and security. **Optional**:  • [Custom virtual network](automatic/quick-automatic-custom-network) • [Custom virtual network](automatic/quick-automatic-private-custom-network) with private cluster. | **Default**: [Managed Virtual Network with kubenet](configure-kubenet)**Optional**:  • [Azure CNI](configure-azure-cni) • [Azure CNI Overlay](azure-cni-overlay) • [Azure CNI Overlay powered by Cilium](azure-cni-powered-by-cilium) • [Bring your own CNI](use-byo-cni) |
| Ingress | **Default**:  • Starting on AKS 1.36, [Kubernetes Gateway API via the application routing add-on](app-routing-gateway-api) for new clusters.  • Older version before AKS 1.36, [Managed NGINX using the application routing add-on](app-routing) with integrations for Azure DNS and Azure Key Vault. **Optional**:  • [Istio-based service mesh add-on for AKS](istio-deploy-ingress) ingress gateway with [Istio CNI](istio-cni) enabled. The add-on isn't auto-upgraded with the cluster, so you must [upgrade it](istio-upgrade) to keep it compatible and avoid blocking cluster auto-upgrade. | **Optional**:  • [Kubernetes Gateway API via the application routing add-on](app-routing-gateway-api) • [Istio-based service mesh add-on for AKS](istio-deploy-ingress) ingress gateway  • Bring your own ingress or gateway. |
| Egress | **Preconfigured**: [AKS managed NAT gateway](nat-gateway#create-an-aks-cluster-with-a-managed-nat-gateway) for a scalable outbound connection flows when used with managed virtual network **Optional (with custom virtual network)**:  • [Azure Load Balancer](egress-outboundtype#outbound-type-of-loadbalancer) • [User-assigned NAT gateway](nat-gateway#create-an-aks-cluster-with-a-managed-nat-gateway) • [User-defined routing (UDR)](egress-outboundtype#outbound-type-of-userdefinedrouting) | **Default**: [Azure Load Balancer](egress-outboundtype#outbound-type-of-loadbalancer)**Optional**:  • [User-assigned NAT gateway](nat-gateway#create-an-aks-cluster-with-a-managed-nat-gateway) • [AKS managed NAT gateway](nat-gateway#create-an-aks-cluster-with-a-userassignednatgateway) • [User-defined routing (UDR)](egress-outboundtype#outbound-type-of-userdefinedrouting) |
| [LocalDNS](dns-concepts#localdns-in-azure-kubernetes-service) | **Preconfigured** for AKS Automatic. | **Optional** for AKS Standard. |