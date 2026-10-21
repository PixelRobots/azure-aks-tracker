---
layout: Conceptual
title: Understand platform differences for the web application workload - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-web-understand
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
description: Learn about the key differences between the AWS and Azure platforms related to the web application hosting.
author: schaffererin
ms.author: schaffererin
ms.date: 2025-11-10T00:00:00.0000000Z
ms.topic: how-to
ms.custom: aks-migration
locale: en-us
document_id: 4aebc09c-2a4a-124d-22f5-d57e016d91c7
document_version_independent_id: 299fe3e4-7184-161f-85a8-ddcfbec4c72b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-web-understand.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-web-understand
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-web-understand.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 85fb5d41-ed06-2e17-c056-8def35652b96
---

# Understand platform differences for the web application workload - Azure Kubernetes Service | Microsoft Learn

Before you migrate the sample web application to Azure, make sure you have a solid understanding of the operational differences between the AWS and Azure platforms.

This article walks through some of the key concepts for this workload and provides links to resources for more information. For a comprehensive comparison between Azure and AWS services, see [AWS to Azure services comparison](/en-us/azure/architecture/aws-professional/services).

### Deployment

Both AKS and EKS provide multiple options for deploying a managed Kubernetes cluster on Azure and AWS. These options include native solutions and provisioning solutions based on third-party systems or open-source technologies.

| **Deployment Options** | **EKS** | **AKS** |
| --- | --- | --- |
| Portal | [AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html) | [Azure portal](/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli) |
| Native Infrastructure as Code | [AWS Cloud Formation](https://docs.aws.amazon.com/eks/latest/userguide/creating-resources-with-cloudformation.html) | [Bicep](/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep?tabs=azure-cli) and [Azure Resource Manager (ARM)](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template?tabs=azure-cli) |
| Native CLI | [AWS CLI](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) and [EKS CLI](https://eksctl.io/installation/) | [Azure CLI](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli), [Azure Developer CLI](/en-us/azure/aks/learn/quick-kubernetes-deploy-azd), and [PowerShell](/en-us/azure/aks/learn/quick-kubernetes-deploy-powershell) |
| Terraform | [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest?tab=resources) | [AzureRM Provider](/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli) |
| Pulumi | [EKS Cluster](https://www.pulumi.com/registry/packages/aws/api-docs/eks/cluster/) | [AKS ManagedCluster](https://www.pulumi.com/registry/packages/azure-native/api-docs/containerservice/managedcluster/) |
| Crossplane | [Yes](https://aws.amazon.com/it/tutorials/deploy-serverless-application-using-crossplane-on-eks/) | [Yes](https://github.com/Azure-Samples/aks-platform-engineering) |
| Cluster API | [Yes](https://cluster-api-aws.sigs.k8s.io/topics/eks/) | [Yes](https://github.com/kubernetes-sigs/cluster-api-provider-azure) |

The [Azure CLI](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli) is designed for simplicity and ease of use. You can create, upgrade, or delete a cluster with a single command. This streamlined approach reduces complexity of managing Kubernetes clusters on Azure. For more information, see [az aks](/en-us/cli/azure/aks) commands. By contrast, the EKS CLI uses a more manual approach that requires multiple steps in conjunction with using kubectl.

### Monitoring

Effective monitoring is essential for identifying and resolving issues in Kubernetes clusters. The following information outlines how AKS and EKS handle monitoring:

| **Monitoring Options** | **EKS** | **AKS** |
| --- | --- | --- |
| Native Monitoring | [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) | [Azure Monitor](/en-us/azure/aks/monitor-aks) |
| Managed Prometheus and Grafana | [Amazon Managed Service for Prometheus](https://aws.amazon.com/prometheus/) and [Amazon Managed Grafana](https://aws.amazon.com/grafana/) | [Azure Monitor managed service for Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview) and [Azure Managed Grafana](/en-us/azure/managed-grafana/overview) |
| Datadog | [Yes](https://docs.datadoghq.com/integrations/amazon_eks/) | [Yes](https://docs.datadoghq.com/integrations/azure_container_service/) |
| Dynatrace | [Yes](https://docs.dynatrace.com/docs/ingest-from/amazon-web-services/integrate-into-aws/aws-eks) | [Yes](https://docs.dynatrace.com/docs/ingest-from/microsoft-azure-services/azure-integrations/azure-aks) |

### Support for open source projects

Both AKS and EKS provide support for open-source projects, enabling you to utilize more capabilities and features. AKS provides managed capabilities for both KEDA and Karpenter as detailed below.

| **Open source projects** | **EKS** | **AKS** |
| --- | --- | --- |
| [Kubernetes Event-driven Autoscaling (KEDA)](https://keda.sh/) | [Yes](https://aws.amazon.com/it/blogs/mt/proactive-autoscaling-kubernetes-workloads-keda-metrics-ingested-into-aws-amp/) | [Yes](/en-us/azure/aks/keda-about) |
| [Karpenter](https://karpenter.sh/) | [Yes](https://docs.aws.amazon.com/eks/latest/best-practices/karpenter.html) | [Node Autoprovisioning](/en-us/azure/aks/node-autoprovision) and [AKS Karpenter Provider](https://github.com/Azure/karpenter-provider-azure) |

## Load balancing

[Azure Application Gateway For Containers](/en-us/azure/application-gateway/for-containers/overview) and [AWS Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/application-load-balancer) are two popular layer 7 load balancing solutions offered by Microsoft Azure and Amazon Web Services, respectively. These services play a crucial role in distributing incoming network traffic across multiple servers to ensure high availability and improved performance for applications.

### AWS Application Load balancer

An [AWS Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/application-load-balancer) is a component of Elastic Load Balancing in Amazon Web Services (AWS). ALB ensures traffic is routed only to healthy targets and scales with incoming traffic. It supports various load balancers, including Application, Network, Gateway, and Classic Load Balancers.

### Azure Application Gateway for Containers

[Azure Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview) is a layer 7 web traffic regional load balancer that enables customers to manage the inbound traffic to multiple downstream web applications and REST APIs. Azure Application Gateway for Containers is designed to optimize the delivery of web applications and provide enhanced security through features like [Azure Web Application Firewall](/en-us/azure/web-application-firewall/overview) for [Azure Kubernetes Service (AKS)](what-is-aks). It distributes incoming application traffic across multiple backend pools, which include public and private [Azure Load Balancers](/en-us/azure/load-balancer/load-balancer-overview), [Azure virtual machines (VMs)](/en-us/azure/virtual-machines/overview), [Azure Virtual Machine Scale Sets (VMSSs)](/en-us/azure/virtual-machine-scale-sets/overview), hostnames, [Azure App Service](/en-us/azure/app-service/overview), and on-premises/external servers.

### Compare Azure Application Gateway for Containers and AWS ALB

[Azure Application Gateway](/en-us/azure/application-gateway/for-containers/overview) and [AWS Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/application-load-balancer) provide a comparable feature set. The following table provides a comparison of the solutions:

| **Feature** | **Azure Application Gateway for Containers** | **AWS Application Load Balancer** |
| --- | --- | --- |
| Secure Sockets Layer (SSL/TLS) Termination | [Supported](/en-us/azure/application-gateway/features#secure-sockets-layer-ssltls-termination) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listeners-ssl) |
| Autoscaling | [Supported](/en-us/azure/application-gateway/for-containers/scaling-zone-resiliency) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-target-group.html) |
| Zone redundancy | [Supported](/en-us/azure/application-gateway/for-containers/scaling-zone-resiliency) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-components.html#zone-configuration) |
| Web Application Firewall | [Supported](/en-us/azure/application-gateway/for-containers/web-application-firewall) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#load-balancer-waf) |
| Ingress controller | [Supported](/en-us/azure/application-gateway/for-containers/application-gateway-for-containers-components) | [Supported](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) |
| URL-based routing | [Supported](/en-us/azure/application-gateway/for-containers/how-to-path-header-query-string-routing-gateway-api) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#url-based-routing) |
| Multiple-site hosting | [Supported](/en-us/azure/application-gateway/for-containers/how-to-multiple-site-hosting-gateway-api) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-target-group.html) |
| Redirection | [Supported](/en-us/azure/application-gateway/for-containers/how-to-url-redirect-gateway-api) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#add-https-listener) |
| Session affinity | [Supported](/en-us/azure/application-gateway/for-containers/session-affinity) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-group.html#sticky-sessions) |
| WebSocket and HTTP/2 traffic | [Supported](/en-us/azure/application-gateway/for-containers/websockets) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#websocket-protocol) |
| Mutual TLS authentication | [Supported](/en-us/azure/application-gateway/for-containers/how-to-frontend-mtls-gateway-api) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/mutual-authentication.html) |
| Connection draining | [Supported](/en-us/azure/application-gateway/for-containers/migrate-from-agic-to-agc#connection-draining) | [Supported](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-group.html#connection-draining) |
| Rewrite HTTP headers and URL | [Supported](/en-us/azure/application-gateway/for-containers/how-to-header-rewrite-gateway-api) | [Supported with AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/customizing-the-incoming-request.html) |

## Web Application Firewall

Ensuring web application security is crucial to protect against evolving cyber threats. Fully managed web application firewall services provide robust protection for web applications against threats and malicious attacks.

### AWS Web Access Firewall (WAF)

[AWS Web Access Firewall (WAF)](https://aws.amazon.com/waf/) is a web application firewall that monitors HTTP and HTTPS requests to your web applications. It protects multiple AWS resources, including those exposed via the AWS Application Load Balancer.

### Azure Web Application Firewall (WAF)

[Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) that provides centralized protection of web applications from common exploits and vulnerabilities. WAF can be deployed with [Azure Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview), [Azure Front Door](/en-us/azure/web-application-firewall/afds/afds-overview), and [Azure Content Delivery Network (CDN)](/en-us/azure/web-application-firewall/cdn/cdn-overview) service from Microsoft.

The Azure WAF comes with a preconfigured, platform-managed [OWASP (Open Web Application Security Project) ruleset](https://owasp.org/www-project-modsecurity-core-rule-set/) that provides protection against various types of attacks, including cross-site scripting and SQL injection. As a WAF administrator, you have the option to write your own [custom rules](/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview) to enhance the core rule set (CRS) rules. Azure WAF also supports a [Bot Protection ruleset](/en-us/azure/web-application-firewall/ag/bot-protection-overview) that you can use to prevent bad bots from scraping, scanning, and looking for vulnerabilities in your web application. The Azure WAF can be configured to run in the following two modes:

- Detection mode: Monitors and logs all threat alerts. You turn on logging diagnostics for Application Gateway for Containers in the Diagnostics section. You must also make sure that the WAF log is selected and turned on. Web application firewall doesn't block incoming requests when it's operating in Detection mode.
- Prevention mode: Blocks intrusions and attacks that the rules detect. The attacker receives a "403 unauthorized access" exception, and the connection is closed. Prevention mode records such attacks in the WAF logs.

Azure Web Application Firewall (WAF) monitoring and logging are provided through logging and integration with Azure Monitor and Azure Monitor logs. You can configure your [Azure Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/web-application-firewall), [Azure Front Door](/en-us/azure/web-application-firewall/afds/afds-overview), and [Azure Content Delivery Network (CDN)](/en-us/azure/web-application-firewall/cdn/cdn-overview) to use [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) and store diagnostic logs and metrics to a [Log Analytics workspace](/en-us/azure/azure-monitor/logs/log-analytics-overview). You can use the [Azure Monitor Metrics Explorer](/en-us/azure/azure-monitor/essentials/metrics-explorer) to analyze the Azure WAF metrics and the [Kusto Query Language](/en-us/kusto/query) to create and run queries against the diagnostics logs collected in the Log Analytics workspace.