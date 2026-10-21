---
layout: Conceptual
title: Rearchitect AWS EKS web application for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-web-rearchitect
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
description: Understand the architectural differences and steps to replicate the AWS EKS web application workload and AWS WAF protection in Azure.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2024-10-31T00:00:00.0000000Z
ms.custom: aks-migration - migration - aws-to-azure - eks-to-aks
locale: en-us
document_id: 03f0af22-e0b4-3005-92d3-e40eb1627edb
document_version_independent_id: c82973e8-f8e2-b480-afb3-5e4398f49b23
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-web-rearchitect.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-web-rearchitect
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-web-rearchitect.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 9080b251-370d-ab0b-907e-f9df1e0bd4f1
---

# Rearchitect AWS EKS web application for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Now that you have a better understanding of the platform differences between AWS and Azure, let's examine the web application architecture on AWS and the modifications needed to make it compatible with [Azure Kubernetes Service (AKS)](what-is-aks).

## Yelb application architecture

The [Yelb](https://github.com/mreferre/yelb/) sample web application consists of a front-end component called `yelb-ui` and an application component called `yelb-appserver`.

![Architecture diagram of the Yelb web application.](media/eks-web-rearchitect/yelb-architecture.png)

The `yelb-ui` serves JavaScript code to the browser. This code is compiled from an [Angular](https://angular.dev/) application. The `yelb-ui` component might also include an `nginx` proxy depending on the deployment model. The `yelb-appserver` is a [Sinatra](https://sinatrarb.com/) application that interacts with a cache server (`redis-server`) and a Postgres back-end database (`yelb-db`). [Redis Cache](https://redis.io/solutions/caching/) stores the number of page views, while [PostgreSQL](https://www.postgresql.org/) persists the votes. Both services are deployed on [Kubernetes](https://kubernetes.io/) without using any managed service for storing data on AWS or Azure.

The original Yelb application is self-contained and doesn't rely on external services, so you can migrate it from AWS to Azure without any code changes. On Azure, you can use [Azure Managed Redis](/en-us/azure/redis/overview) and [Azure Database for PostgreSQL](/en-us/azure/postgresql/flexible-server/service-overview) as replacements for the Redis Cache and PostgreSQL services deployed on [AKS](what-is-aks).

The sample Yelb application allows users to vote on a set of alternatives (restaurants) and dynamically updates pie charts based on the number of votes received. The application also keeps track of the number of page views and displays the hostname of the `yelb-appserver` instance serving the API request upon a vote or a page refresh. This feature enables you to demo the application independently or collaboratively.

![Screenshot of the Yelb service interface.](media/eks-web-rearchitect/yelb-user-interface.png)

## Architecture on AWS

To help protect web applications and APIs from common web exploits, AWS offers [AWS Web Application Firewall (WAF)](https://aws.amazon.com/waf/) and [AWS Firewall Manager](https://aws.amazon.com/firewall-manager/).

## Map AWS services to Azure services

To recreate the AWS workload in Azure with minimal changes, use an Azure equivalent for each AWS service. The following table summarizes the service mappings:

| **Service mapping** | **AWS service** | **Azure service** |
| --- | --- | --- |
| Web access firewall | [AWS Web Application Firewall (WAF)](https://aws.amazon.com/waf/) | [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) |
| Application load balancing | [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/application-load-balancer) | [Azure Application Gateway](/en-us/azure/application-gateway/overview)[Application Gateway for Containers (AGC)](/en-us/azure/application-gateway/for-containers/overview) |
| Content delivery network | [Amazon CloudFront](https://aws.amazon.com/cloudfront) | [Azure Front Door (AFD)](/en-us/azure/frontdoor/front-door-overview) |
| Orchestration | [Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/en_us/eks/latest/userguide/what-is-eks.html) | [Azure Kubernetes Service (AKS)](what-is-aks) |
| Secrets vault | [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/) | [Azure Key Vault](/en-us/azure/key-vault/general/overview) |
| Container registry | [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr) | [Azure Container Registry (ACR)](/en-us/azure/container-registry/container-registry-intro) |
| Domain Name System (DNS) | [Amazon Route 53](https://aws.amazon.com/it/route53/) | [Azure DNS](/en-us/azure/dns/dns-overview) |
| Caching | [Amazon ElastiCache](https://aws.amazon.com/it/elasticache/) | [Azure Managed Redis](/en-us/azure/redis/overview) |
| NoSQL | [Amazon DynamoDB](https://aws.amazon.com/it/dynamodb/) | [Azure Database for PostgreSQL](/en-us/azure/postgresql/flexible-server/service-overview) |

For a comprehensive comparison between Azure and AWS services, see [AWS to Azure services comparison](/en-us/azure/architecture/aws-professional/services).

## Architecture on Azure

In this solution, the [Yelb](https://github.com/mreferre/yelb/) application is deployed to an AKS cluster and is exposed via an ingress controller like the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx). The ingress controller service is exposed via an [internal (or private) load balancer](/en-us/azure/load-balancer/load-balancer-overview). For more information on how to use an internal load balancer to restrict access to your applications in AKS, see [Use an internal load balancer with Azure Kubernetes Service (AKS)](internal-lb).

This sample supports installing a [managed NGINX ingress controller with the application routing add-on](app-routing) or an unmanaged [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) using the [Helm chart](https://kubernetes.github.io/ingress-nginx). The application routing add-on with NGINX ingress controller provides the following features:

- Easy configuration of managed NGINX ingress controllers based on [Kubernetes NGINX ingress controller](https://github.com/kubernetes/ingress-nginx).
- Integration with [Azure DNS](/en-us/azure/dns/dns-overview) for public and private zone management.
- SSL termination with certificates stored in [Azure Key Vault](/en-us/azure/key-vault/general/overview).

For other configurations, see the following articles:

- [DNS and SSL configuration](app-routing-dns-ssl)
- [Application routing add-on configuration](app-routing-nginx-configuration)
- [Configure internal NGINX ingress controller for Azure private DNS zone](create-nginx-ingress-private-controller)

The [Yelb](https://github.com/mreferre/yelb/) application is secured with an [Azure Application Gateway](/en-us/azure/application-gateway/overview) resource deployed in a dedicated subnet within the same virtual network as the AKS cluster or in a peered virtual network. You can secure access to the Yelb application using [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview), which provides centralized protection of web applications from common exploits and vulnerabilities.

### Solution architecture design

The following diagram shows the recommended architecture on Azure:

[![Diagram of the solution based on Application Gateway WAFv2 and NGINX ingress controller.](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-https.png)](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-https.png#lightbox)

The solution architecture consists of the following:

1. The Application Gateway handles TLS termination and communicates with the backend application over HTTPS.
2. The Application Gateway Listener uses an SSL certificate obtained from [Azure Key Vault](/en-us/azure/key-vault/general/overview).
3. The Azure WAF Policy associated to the Listener runs OWASP rules and custom rules against the incoming requests and blocks malicious attacks.
4. The Application Gateway Backend HTTP Settings invoke the Yelb application via HTTPS on port 443.
5. The Application Gateway Backend Pool and Health Probe call the NGINX ingress controller through the AKS internal load balancer using HTTPS.
6. The NGINX ingress controller uses the AKS internal load balancer.
7. The AKS cluster is configured with the [Azure Key Vault provider for Secrets Store CSI Driver add-on](/en-us/azure/aks/csi-secrets-store-driver) to retrieve secrets, certificates, and keys from Azure Key Vault via a [CSI volume](https://kubernetes-csi.github.io/docs/).
8. A [SecretProviderClass](/en-us/azure/aks/hybrid/secrets-store-csi-driver) retrieves the same certificate used by the Application Gateway from Azure Key Vault.
9. An [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) object employs the NGINX ingress controller to expose the application via HTTPS through the AKS internal load balancer.
10. The Yelb service is of type `ClusterIP` and is exposed via the NGINX ingress controller.

For comprehensive instructions on deploying the [Yelb application](https://github.com/mreferre/yelb/) on AKS using this architecture, see the [companion sample](https://github.com/Azure-Samples/aks-web-application-replicate-from-aws).

## Alternative solutions

Azure offers several options for deploying a web application on an AKS cluster and securing it with a web application firewall:

# [Application Gateway Ingress Controller](#tab/agic)
The [Application Gateway Ingress Controller (AGIC)](/en-us/azure/application-gateway/ingress-controller-overview) is a Kubernetes application, so you can leverage Azure's native [Application Gateway](https://azure.microsoft.com/services/application-gateway/) L7 load-balancer to expose cloud software to the Internet for your [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/services/kubernetes-service/) workloads. AGIC monitors the Kubernetes cluster it's hosted on and continuously updates an Application Gateway so that selected services are exposed to the Internet.

[![Diagram of the solution based on Azure Application Gateway Ingress Controller.](media/eks-web-rearchitect/application-gateway-ingress-controller-azure-kubernetes-service-http.png)](media/eks-web-rearchitect/application-gateway-ingress-controller-azure-kubernetes-service-http.png#lightbox)

The Ingress Controller runs in its own pod on the AKS cluster. AGIC monitors a subset of Kubernetes Resources for changes, translates the state of the cluster to an Application Gateway specific configuration, and applies it to [Azure Resource Manager (ARM)](/en-us/azure/azure-resource-manager/management/overview). For more information, see [What is Application Gateway Ingress Controller?](/en-us/azure/application-gateway/ingress-controller-overview).

The following table outlines advantages and disadvantages of the Application Gateway Ingress Controller (AGIC):

| Advantages | Disadvantages |
| --- | --- |
| \* **Native integration**: AGIC provides native integration with Azure services, specifically Azure Application Gateway, which allows for seamless and efficient routing of traffic to services running on AKS.  \* **Simplified deployments**: Deploying AGIC as an AKS add-on is straightforward and simpler compared to other methods. It enables a quick and easy setup of an Application Gateway and an AKS cluster with AGIC enabled.  \* **Fully managed service**: AGIC as an add-on is a fully managed service, providing benefits such as automatic updates and increased support from Microsoft. It ensures the Ingress Controller remains up-to-date and adds an extra layer of support. | \* **Single cloud approach**: AGIC is primarily adopted by customers who adopt a single-cloud approach. It might not be the best choice if you require a multicloud architecture where deployment across different cloud platforms is a requirement. In this case, you might want to use a cloud-agnostic ingress controller such as NGINX, Traefik, or HAProxy to avoid vendo-lockin issues. |

For more information, see the following resources:

- [What is Application Gateway Ingress Controller?](/en-us/azure/application-gateway/ingress-controller-overview)
- [Documentation for Application Gateway Ingress Controller](https://azure.github.io/application-gateway-kubernetes-ingress/)

# [Azure Application Gateway for Containers](#tab/agc)
[Azure Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview) provides load balancing and dynamic traffic management for applications in Kubernetes clusters.

[![Diagram of the solution based on Azure Application Gateway for Containers.](media/eks-web-rearchitect/application-gateway-for-containers-azure-kubernetes-service.png)](media/eks-web-rearchitect/application-gateway-for-containers-azure-kubernetes-service.png#lightbox)

#### Key features

Azure Application Gateway for Containers builds upon the capabilities of [Application Gateway Ingress Controller (AGIC)](/en-us/azure/application-gateway/ingress-controller-overview) and allows you to use Azure's native Application Gateway load balancer. Key features include:

- [**Load balancing**](/en-us/azure/application-gateway/for-containers/overview#load-balancing-features): Efficiently distributes incoming traffic across multiple containers for optimal performance and scalability.
- [**Gateway API implementation**](/en-us/azure/application-gateway/for-containers/overview#implementation-of-gateway-api): Supports the Gateway API, allowing you to define routing rules and policies in a Kubernetes-native way.
- [**Custom health probes**](/en-us/azure/application-gateway/for-containers/custom-health-probe): Define custom health probes to monitor container health and automatically route traffic away from unhealthy instances.
- [**Session affinity**](/en-us/azure/application-gateway/for-containers/session-affinity?tabs=session-affinity-gateway-api): Provides session affinity, routing subsequent requests from the same client to the same container for a consistent user experience.
- [**TLS policy**](/en-us/azure/application-gateway/for-containers/tls-policy?tabs=tls-policy-gateway-api): Supports TLS termination, allowing SSL/TLS encryption and decryption to be offloaded to the gateway.
- **Header rewrites**: Rewrite HTTP headers of client requests and responses from backend targets using the `IngressExtension` custom resource definition. For more information, see [Ingress API](/en-us/azure/application-gateway/for-containers/how-to-header-rewrite-ingress-api) and [Gateway API](/en-us/azure/application-gateway/for-containers/how-to-header-rewrite-gateway-api).
- **URL rewrites**: Modify the URL of client requests, including hostname and/or path, and include the newly rewritten URL when initiating requests to backend targets. For more information, see [Ingress API](/en-us/azure/application-gateway/for-containers/how-to-url-rewrite-ingress-api) and [Gateway API](/en-us/azure/application-gateway/for-containers/how-to-url-rewrite-gateway-api).

#### Limitations

Currently, Azure Application Gateway for Containers doesn't support the following features:

- [Azure Web Application Firewall](/en-us/azure/application-gateway/waf-overview)
- [Azure CNI Overlay](/en-us/azure/aks/azure-cni-overlay)
- [WebSockets](https://datatracker.ietf.org/doc/html/rfc6455)
- Private front ends

For more information, see [Deploying an Azure Kubernetes Service (AKS) Cluster with Application Gateway for Containers](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/deploying-an-azure-kubernetes-service-aks-cluster-with/ba-p/3967434).

# [Azure Front Door](#tab/afd)
[Azure Front Door](/en-us/azure/frontdoor/front-door-overview) is global layer 7 load balancer that securely exposes and protects workloads running in AKS using the [Azure Web Application Firewall](/en-us/azure/web-application-firewall/overview) and an [Azure Private Link](/en-us/azure/private-link/private-link-service-overview) service.

[![Diagram of the solution based on Azure Front Door.](media/eks-web-rearchitect/front-door-azure-kubernetes-service.png)](media/eks-web-rearchitect/front-door-azure-kubernetes-service.png#lightbox)

This solution uses [Azure Front Door Premium](/en-us/azure/frontdoor/front-door-overview), [end-to-end TLS encryption](/en-us/azure/frontdoor/end-to-end-tls), [Azure Web Application Firewall](/en-us/azure/web-application-firewall/overview), and a [Private Link service](/en-us/azure/private-link/private-link-service-overview) to securely expose and protect a workload that runs in [AKS](/en-us/azure/aks/intro-kubernetes).

Azure Front Door TLS and Secure Sockets Layer (SSL) offload capability to terminate TLS connections and decrypt incoming traffic at the front door. Azure Front Door reencrypts the incoming traffic before forwarding it to the AKS-hosted web application. This practice enforces end-to-end TLS encryption for the entire request process, from the client to the origin. For more information, see [Secure your origin with Private Link in Azure Front Door Premium](/en-us/azure/frontdoor/private-link).

The [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) exposes the AKS-hosted web application. It's configured to use a private IP address as a front-end IP configuration of the `kubernetes-internal` internal load balancer, and it uses HTTPS as the transport protocol to expose the web application. For more information, see [Create an ingress controller by using an internal IP address](/en-us/azure/aks/ingress-basic#create-an-ingress-controller-using-an-internal-ip-address).

We recommend this solution for scenarios where you're deploying the same web application across multiple regional AKS clusters for business continuity and disaster recovery, or even across multiple cloud platforms or on-premises installations. In this case, Front Door can forward incoming calls to one of the backends (also known as *origins*) using one of the following routing methods:

- [**Latency**](/en-us/azure/frontdoor/routing-methods#latency): Latency-based routing ensures that requests are sent to the lowest latency origins acceptable within a sensitivity range. In other words, requests get sent to the nearest set of origins in respect to network latency.
- [**Priority**](/en-us/azure/frontdoor/routing-methods#priority): You can set priorities to origins when you want to configure a primary origin to service all traffic. The secondary origin can be a backup in case the primary origin becomes unavailable.
- [**Weighted**](/en-us/azure/frontdoor/routing-methods#weighted): You can assign a weight to your origins when you want to distribute traffic across a set of origins evenly or according to the weight coefficients. Traffic gets distributed by the weight value if the latencies of the origins are within the acceptable latency sensitivity range in the origin group.
- [**Session affinity**](/en-us/azure/frontdoor/routing-methods#affinity): You can configure session affinity for your frontend hosts or domains to ensure requests from the same end user gets sent to the same origin.

For more information, see [Use Azure Front Door to secure AKS workloads](/en-us/azure/architecture/example-scenario/aks-front-door/aks-front-door).

# [NGINX ingress controller](#tab/nginx)
The following solution uses the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) to expose the Yelb application and ModSecurity to block any malicious or suspicious traffic based on predefined OWASP or custom rules. [ModSecurity](https://github.com/SpiderLabs/ModSecurity) is an open-source web application firewall (WAF) that's compatible with popular web servers such as Apache, NGINX, and ISS. It provides protection from a wide range of attacks by using a powerful rule-definition language.

[![Diagram of the solution based on NGINX ingress controller and ModSecurity.](media/eks-web-rearchitect/nginx-modsecurity-azure-kubernetes-service.png)](media/eks-web-rearchitect/nginx-modsecurity-azure-kubernetes-service.png#lightbox)

You can use [ModSecurity](https://github.com/SpiderLabs/ModSecurity) with the NGINX ingress controller to provide an extra layer of security to web applications exposed via Kubernetes. The NGINX ingress controller acts as a reverse proxy, forwarding traffic to the web application, while ModSecurity inspects the incoming requests and blocks any malicious or suspicious traffic based on the defined rules.

Using ModSecurity with NGINX Ingress controllers in Kubernetes provides a cloud-agnostic solution that you can deploy to any managed Kubernetes cluster on any cloud platform. This solution enables you to switch between cloud providers or have a multicloud setup while maintaining consistent security measures.

---