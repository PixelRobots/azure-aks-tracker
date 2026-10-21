---
layout: Conceptual
title: Add-ons, extensions, and other integrations with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/integrations
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
description: Learn about the add-ons, extensions, and open-source integrations you can use with Azure Kubernetes Service (AKS).
ms.topic: overview
ms.subservice: aks-integration
ms.date: 2023-05-22T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 237c3e49-60ed-57dd-46af-72de1cc8b298
document_version_independent_id: fd078d16-b8b6-c93b-ab9b-ae71105ca367
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/integrations.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/integrations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/integrations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3ebe5052-2498-6ca0-05eb-572da2a81b0b
---

# Add-ons, extensions, and other integrations with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) provides extra functionality for your clusters using add-ons and extensions. Open-source projects and third parties provide by more integrations that are commonly used with AKS. The [AKS support policy](support-policies) doesn't support the open-source and third-party integrations.

## Add-ons

Add-ons are a fully supported way to provide extra capabilities for your AKS cluster. The installation, configuration, and lifecycle of add-ons are managed on AKS. You can use the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command to install an add-on or manage the add-ons for your cluster.

AKS uses the following rules for applying updates to installed add-ons:

- Only an add-on's patch version can be upgraded within a Kubernetes minor version. The add-on's major/minor version isn't upgraded within the same Kubernetes minor version.
- The major/minor version of the add-on is only upgraded when moving to a later Kubernetes minor version.
- Any breaking or behavior changes to the add-on are announced well before, usually 60 days, for a GA minor version of Kubernetes on AKS.
- You can patch add-ons weekly with every new release of AKS, which is announced in the release notes. You can control AKS releases using the [maintenance windows](planned-maintenance) and [release tracker](release-tracker).

### Exceptions

- Add-ons are upgraded to a new major/minor version (or breaking change) within a Kubernetes minor version if either the cluster's Kubernetes version or the add-on version are in preview.
- There can be unavoidable circumstances, such as CVE security patches or critical bug fixes, when you need to update an add-on within a GA minor version.

### Available add-ons

| Name | Description | Articles | GitHub |
| --- | --- | --- | --- |
| ingress-appgw | Use Application Gateway Ingress Controller with your AKS cluster. | [What is Application Gateway Ingress Controller?](/en-us/azure/application-gateway/ingress-controller-overview) | [GitHub](https://github.com/Azure/application-gateway-kubernetes-ingress) |
| keda | Use event-driven autoscaling for the applications on your AKS cluster. | [Simplified application autoscaling with Kubernetes Event-driven Autoscaling (KEDA) add-on](keda-about) | [GitHub](https://github.com/Azure-Samples/aks-keda-addon-workload-identity) |
| monitoring | Use Container Insights and Managed Prometheus monitoring with your AKS cluster. | [Container insights overview](/en-us/azure/azure-monitor/containers/container-insights-overview)[Managed Prometheus overview](/en-us/azure/azure-monitor/containers/container-insights-overview) | [GitHub](https://github.com/Azure/AKS)[GitHub](https://github.com/Azure/prometheus-collector) |
| azure-policy | Use Azure Policy for AKS, which enables at-scale enforcements and safeguards on your clusters in a centralized, consistent manner. | [Understand Azure Policy for Kubernetes clusters](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#install-azure-policy-add-on-for-aks) | [GitHub](https://github.com/Azure/azure-policy) |
| azure-keyvault-secrets-provider | Use Azure Keyvault Secrets Provider add-on. | [Use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster](csi-secrets-store-driver) | [GitHub](https://github.com/Azure/secrets-store-csi-driver-provider-azure) |
| virtual-node | Use virtual nodes with your AKS cluster. | [Use virtual nodes](virtual-nodes) | [GitHub](https://github.com/virtual-kubelet/virtual-kubelet) |
| open-service-mesh | Use Open Service Mesh with your AKS cluster (retired). | [Open Service Mesh AKS add-on (retired)](open-service-mesh-about) | [GitHub](https://github.com/Azure/osm-azure) |

## Extensions

Cluster extensions build on top of certain Helm charts and provide an Azure Resource Manager-driven experience for installation and lifecycle management of different Azure capabilities on top of your Kubernetes cluster.

- For more information on the specific cluster extensions for AKS, see [Deploy and manage cluster extensions for Azure Kubernetes Service (AKS)](cluster-extensions?tabs=azure-cli).
- For more information on available cluster extensions, see [Currently available extensions](cluster-extensions?tabs=azure-cli#currently-available-extensions).

### Difference between extensions and add-ons

Extensions and add-ons are both supported ways to add functionality to your AKS cluster. When you install an add-on, the functionality is added as part of the AKS resource provider in the Azure API. When you install an extension, the functionality is added as part of a separate resource provider in the Azure API.

## GitHub Actions

GitHub Actions help you automate your software development workflows from within GitHub.

- For more information on using GitHub Actions with Azure, see [GitHub Actions for Azure](/en-us/azure/developer/github/github-actions).
- For an example of using GitHub Actions with an AKS cluster, see [Build, test, and deploy containers to Azure Kubernetes Service using GitHub Actions](kubernetes-action).

## Open-source and third-party integrations

There are many open-source and third-party integrations you can install on your AKS cluster. The [AKS support policy](support-policies) doesn't cover self-managed installations of the following projects. Some of these projects have managed experiences built on top of them (for example in the case of Prometheus, Grafana, and Istio). These managed experiences are noted in the 'More Details' column.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

| Name | Description | More details |
| --- | --- | --- |
| [Helm](https://helm.sh) | An open-source packaging tool that helps you install and manage the lifecycle of Kubernetes applications. | [Quickstart: Develop on Azure Kubernetes Service (AKS) with Helm](quickstart-helm) |
| [Prometheus](https://prometheus.io/) | Monitoring and alerting toolkit. | Managed experience - [Azure Monitor managed service for Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview); Self-managed experience - [Prometheus operator](https://github.com/prometheus-operator/kube-prometheus) |
| [Grafana](https://grafana.com/) | Dashboards for observability. | Managed experience - [Azure Managed Grafana](/en-us/azure/managed-grafana/overview); Self-managed experience - [Deploy Grafana on Kubernetes](https://grafana.com/docs/grafana/latest/installation/kubernetes/). |
| [Couchbase](https://www.couchbase.com/) | A distributed NoSQL cloud database. | [Install Couchbase and the Operator on AKS](https://docs.couchbase.com/operator/2.4/tutorial-aks.html) |
| [OpenFaaS](https://www.openfaas.com/) | An open-source framework for building serverless functions by using containers. | [Use OpenFaaS with AKS](openfaas) |
| [Apache Spark](https://spark.apache.org/) | An open-source, fast engine for large-scale data processing. | Running Apache Spark jobs requires a minimum node size of *Standard\_D3\_v2*. For more information on running Spark jobs on Kubernetes, see the [running Spark on Kubernetes](https://spark.apache.org/docs/latest/running-on-kubernetes.html) guide. |
| [Istio](https://istio.io/) | Service mesh | Managed experience - [Istio add-on for AKS](istio-about); Self-managed experience - [Istio open-source installation](https://istio.io/latest/docs/setup/install/) |
| [Linkerd](https://linkerd.io/) | An open-source service mesh. | [Linkerd Getting Started](https://linkerd.io/2.16/getting-started/) |
| [Consul](https://www.consul.io/) | An open-source, identity-based networking solution. | [Getting Started with Consul Service Mesh for Kubernetes](https://learn.hashicorp.com/tutorials/consul/service-mesh-deploy) |

### Third-party integrations for Windows containers

Microsoft collaborates with partners to ensure the build, test, deployment, configuration, and monitoring of your applications perform optimally with Windows containers on AKS.

For more information, see [Windows AKS partner solutions](windows-aks-partner-solutions).