---
layout: Conceptual
title: Prepare to deploy Amazon Web Services (AWS) web application workload to Azure - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-web-prepare
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
description: Learn the steps to deploy your web application workload to Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2024-10-31T00:00:00.0000000Z
ms.custom: aks-migration
locale: en-us
document_id: 84d552e3-617f-402a-21ff-691f1f54865f
document_version_independent_id: 6cc56917-1a31-3e74-ce9e-78b6ff0cde12
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-web-prepare.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-web-prepare
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-web-prepare.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d76063e0-b362-6845-a74e-de8e0404e1dc
---

# Prepare to deploy Amazon Web Services (AWS) web application workload to Azure - Azure Kubernetes Service | Microsoft Learn

This article provides a comprehensive guide on how to deploy a robust and production-ready infrastructure to facilitate the hosting, protection, scaling, and monitoring of a web application on the Azure platform.

## Yelb deployment on AWS

The [Yelb](https://github.com/mreferre/yelb/) sample web application on AWS is deployed using Bash, [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html), [eksctl](https://eksctl.io/installation/), [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html), and [Helm](https://helm.sh/docs/intro/install/). The companion [sample](https://github.com/Azure-Samples/aks-web-application-replicate-from-aws) contains Bash scripts and YAML manifests that you can use to automate the deployment of the [Yelb](https://github.com/mreferre/yelb/) application on [AWS Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/en_us/eks/latest/userguide/what-is-eks.html). This solution demonstrates how to implement a web application firewall using [AWS WAF](https://aws.amazon.com/waf/) to protect a web application running on [Amazon Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/en_us/eks/latest/userguide/what-is-eks.html). You can use the Bash scripts to create an EKS cluster and deploy the [Yelb](https://github.com/mreferre/yelb/) application. The [Yelb](https://github.com/mreferre/yelb/) web application is exposed to the public internet using an [Amazon Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/application-load-balancer) and protected using [AWS WAF web access control list (web ACL)](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl.html). For detailed instructions, see [Porting a Web Application from AWS Elastic Kubernetes Service (EKS) to Azure Kubernetes Service (AKS)](https://github.com/Azure-Samples/aks-web-application-replicate-from-aws).

![Screenshot of the Yelb service interface.](media/eks-web-rearchitect/yelb-user-interface.png)

## Yelb deployment on Azure

In the following sections, you learn how to deploy the [Yelb](https://github.com/mreferre/yelb/) sample web application on an [Azure Kubernetes Service (AKS)](what-is-aks) cluster and expose it through an ingress controller like the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx). The ingress controller service is accessible via an [internal (or private) load balancer](/en-us/azure/load-balancer/load-balancer-overview), which balances traffic within the virtual network housing the AKS cluster. In a hybrid scenario, the load balancer frontend can be accessed from an on-premises network. To learn more about internal load balancing, see [Use an internal load balancer with Azure Kubernetes Service (AKS)](/en-us/azure/aks/internal-lb?tabs=set-service-annotations).

The companion [sample](https://github.com/Azure-Samples/aks-web-application-replicate-from-aws) supports installing a [managed NGINX ingress controller with the application routing add-on](app-routing) or an unmanaged [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) using the [Helm chart](https://kubernetes.github.io/ingress-nginx). The application routing add-on with NGINX ingress controller provides the following features:

- Easy configuration of managed NGINX ingress controllers based on [Kubernetes NGINX ingress controller](https://github.com/kubernetes/ingress-nginx).
- Integration with [Azure DNS](/en-us/azure/dns/dns-overview) for public and private zone management.
- SSL termination with certificates stored in [Azure Key Vault](/en-us/azure/key-vault/general/overview).

For other configurations,

- [DNS and SSL configuration](/en-us/azure/aks/app-routing-dns-ssl)
- [Application routing add-on configuration](/en-us/azure/aks/app-routing-nginx-configuration)
- [Configure internal NGIX ingress controller for Azure private DNS zone](/en-us/azure/aks/create-nginx-ingress-private-controller).

To enhance security, the [Yelb](https://github.com/mreferre/yelb/) application is protected by an [Azure Application Gateway](/en-us/azure/application-gateway/overview) resource. This resource is deployed in a dedicated subnet within the same virtual network as the AKS cluster or in a peered virtual network. The [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) secures access to the web application hosted on [Azure Kubernetes Service (AKS)](what-is-aks) and exposed via the [Azure Application Gateway](/en-us/azure/application-gateway/overview) against common exploits and vulnerabilities.

## Prerequisites

- An active [Azure subscription](/en-us/azure/guides/developer/azure-developer-guide#understanding-accounts-subscriptions-and-billing). If you don't have one, create a [free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- The **Owner**[Azure built-in role](/en-us/azure/role-based-access-control/built-in-roles), or the **User Access Administrator** and **Contributor** built-in roles, on a subscription in your Azure account.
- [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.61.0 or later. For more information, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- [Azure Kubernetes Service (AKS) preview extension](/en-us/azure/aks/draft#install-the-aks-preview-azure-cli-extension).
- [jq](https://jqlang.github.io/jq/) version 1.5 or later.
- [Python 3](https://www.python.org/downloads/) or later.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.21.0 or later
- [Helm](https://helm.sh/docs/intro/install/) version 3.0.0 or later
- [Visual Studio Code](https://code.visualstudio.com/Download) installed on one of the [supported platforms](https://code.visualstudio.com/docs/supporting/requirements#_platforms) along with the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep).
- An existing [Azure Key Vault](/en-us/azure/key-vault/general/overview) resource with a valid TLS certificate for the Yelb web application.
- An existing [Azure DNS Zone](/en-us/azure/dns/dns-overview) or equivalent DNS server for the name resolution of the [Yelb](https://github.com/mreferre/yelb/) application.

## Architecture

This sample provides a collection of [Bicep](/en-us/azure/azure-resource-manager/bicep/overview) templates, Bash scripts, and YAML manifests for building an AKS cluster, deploying the [Yelb](https://github.com/mreferre/yelb/) application, exposing the UI service using the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx), and protecting it with the [Azure Application Gateway](/en-us/azure/application-gateway/overview) and [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview).

This sample also includes two separate Bicep parameter files and two sets of Bash scripts and YAML manifests, each geared towards deploying two different solution options. For more information on Bicep, see [What is Bicep?](/en-us/azure/azure-resource-manager/bicep/overview)

## TLS termination at the Application Gateway and Yelb invocation via HTTP

In this solution, the [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) ensures the security of the system by blocking malicious attacks. The [Azure Application Gateway](/en-us/azure/application-gateway/overview) receives incoming calls from client applications, performs TLS termination, and forwards the requests to the AKS-hosted `yelb-ui` service. This communication is achieved through the internal load balancer and NGINX ingress controller using the HTTP transport protocol. The following diagram illustrates the architecture:

[![Diagram of the solution based on Application Gateway WAFv2 and NGINX ingress controller via HTTP.](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-http.png)](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-http.png#lightbox)

The message flow is as follows:

![Diagram of the message flow of the solution based on Application Gateway WAFv2 and NGINX ingress controller via HTTP.](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-http-detail.png)

1. The [Azure Application Gateway](/en-us/azure/application-gateway/overview) handles TLS termination and sends incoming calls to the AKS-hosted `yelb-ui` service over HTTP.
2. The Application Gateway Listener uses an SSL certificate obtained from [Azure Key Vault](/en-us/azure/key-vault/general/overview) to ensure secure communication.
3. The Azure WAF Policy associated with the Listener applies OWASP rules and custom rules to incoming requests, effectively preventing many types of malicious attacks.
4. The Application Gateway Backend HTTP Settings invoke the Yelb application via HTTP using port 80.
5. The Application Gateway Backend Pool and Health Probe call the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) through the AKS internal load balancer using the HTTP protocol for traffic management.
6. The [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) uses the AKS internal load balancer to ensure secure communication within the cluster.
7. A [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) object uses the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) to expose the application via HTTP through the internal load balancer.
8. The `yelb-ui` service with the `ClusterIP` type restricts its invocation to within the cluster or through the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx).

## Implementing end-to-end TLS using Azure Application Gateway

### TLS termination

[Azure Application Gateway](/en-us/azure/application-gateway/overview) supports TLS termination at the gateway level, which means that traffic is decrypted at the gateway before being sent to the backend servers. To configure TLS termination, you need to add a TLS/SSL certificate to the listener. The certificate should be in Personal Information Exchange (PFX) format, which contains both the private and public keys. You can import the certificate from Azure Key Vault to the Application Gateway. For more information, see [TLS termination with Key Vault certificates](/en-us/azure/application-gateway/key-vault-certs).

### Zero Trust security model

If you adopt a [Zero Trust](https://www.microsoft.com/security/business/zero-trust) security model, you should prevent unencrypted communication between a service proxy like Azure Application Gateway and the backend servers. With the Zero Trust security model, trust isn't automatically granted to any user or device trying to access resources within a network. Instead, it requires continuous verification of identity and authorization for each request, regardless of the user's location or network. In our scenario, implementing the Zero Trust security model involves using the Azure Application Gateway as a service proxy, which acts as a front-end for incoming requests. These requests then travel down to the NGINX ingress controller on Azure Kubernetes Service (AKS) in an encrypted format.

### End-to-end TLS with Application Gateway

You can implement a Zero Trust approach by configuring Azure Application Gateway for end-to-end TLS encryption with the backend servers. [End-to-end TLS encryption](/en-us/azure/application-gateway/ssl-overview#end-to-end-tls-encryption) allows you to securely transmit sensitive data to the backend while leveraging Application Gateway's layer 7 load balancing features, including cookie-based session affinity, URL-based routing, routing based on sites, and the ability to rewrite or inject X-Forwarded-\* headers.

When Application Gateway is configured with end-to-end TLS communication mode, it terminates the TLS sessions at the gateway and decrypts user traffic. It then applies the configured rules to select the appropriate backend pool instance to route the traffic to. Next, Application Gateway initiates a new TLS connection to the backend server and reencrypts the data using the backend server's public key certificate before transmitting the request to the backend. The response from the web server follows the same process before reaching the end user. To enable end-to-end TLS, you need to set the protocol setting in the Backend HTTP Setting to HTTPS and apply it to a backend pool. This approach ensures that your communication with the backend servers is secured and compliant with your requirements.

For more information, see [Application Gateway end-to-end TLS encryption](/en-us/azure/application-gateway/end-to-end-ssl-portal) and [Best practices for securing your Application Gateway](/en-us/security/benchmark/azure/baselines/application-gateway-security-baseline).

In this solution, the [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) ensures the security of the system by blocking malicious attacks. The [Azure Application Gateway](/en-us/azure/application-gateway/overview) handles incoming calls from client applications, performs TLS termination, and implements [end-to-end TLS](/en-us/azure/application-gateway/ssl-overview#end-to-end-tls-encryption) by invoking the underlying AKS-hosted `yelb-ui` service using the HTTPS transport protocol via the internal load balancer and NGINX ingress controller. The following diagram illustrates the architecture:

[![Diagram of the solution based on Application Gateway WAFv2 and NGINX ingress controller via HTTPS.](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-https.png)](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-https.png#lightbox)

The message flow is as follows:

1. The [Azure Application Gateway](/en-us/azure/application-gateway/overview) handles TLS termination and communicates with the backend application over HTTPS.
2. The Application Gateway Listener uses an SSL certificate obtained from [Azure Key Vault](/en-us/azure/key-vault/general/overview).
3. The Azure WAF Policy associated with the Listener runs OWASP rules and custom rules against incoming requests to block malicious attacks.
4. The Application Gateway Backend HTTP Settings are configured to invoke the AKS-hosted `yelb-ui` service via HTTPS on port 443.
5. The Application Gateway Backend Pool and Health Probe call the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) through the AKS internal load balancer using HTTPS.
6. The [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) is deployed to use the AKS internal load balancer.
7. The SAKS cluster is configured with the [Azure Key Vault provider for Secrets Store CSI Driver](/en-us/azure/aks/csi-secrets-store-driver) add-on to retrieve secrets, certificates, and keys from Azure Key Vault via a [CSI volume](https://kubernetes-csi.github.io/docs/).
8. A [SecretProviderClass](/en-us/azure/aks/hybrid/secrets-store-csi-driver) is used to retrieve the certificate used by the Application Gateway from Key Vault.
9. A [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) object uses the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) to expose the application via HTTPS through the AKS internal load balancer.
10. The `yelb-ui` service has a `ClusterIP` type, which restricts its invocation to within the cluster or through the [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx).

To help ensure the security and stability of the system, consider the following recommendations:

- Regularly update the Azure WAF Policy with the latest rules to ensure optimal security.
- Implement monitoring and logging mechanisms to track and analyze incoming requests and potential attacks.
- Regularly perform maintenance and updates of the AKS cluster, NGINX ingress controller, and Application Gateway to address any security vulnerabilities and maintain a secure infrastructure.
- Implement monitoring and logging mechanisms to track and analyze incoming requests and potential attacks.
- Regularly perform maintenance and updates of the AKS cluster, NGINX ingress controller, and Application Gateway to address any security vulnerabilities and maintain a secure infrastructure.

### Hostname

The Application Gateway Listener and the [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) are configured to use the same hostname. It's important to use the same hostname for a service proxy and a backend web application for the following reasons:

- **Preservation of session state**: When you use a different hostname for the proxy and the backend application, session state can get lost. This means that user sessions might not persist properly, resulting in a poor user experience and potential loss of data.
- **Authentication failure**: If the hostname differs between the proxy and the backend application, authentication mechanisms might fail. This approach can lead to users being unable to log in or access secure resources within the application.
- **Inadvertent exposure of URLs**: If the hostname isn't preserved, there's a risk that backend URLs might be exposed to end users. This can lead to potential security vulnerabilities and unauthorized access to sensitive information.
- **Cookie issues**: Cookies play a crucial role in maintaining user sessions and passing information between the client and the server. When the hostname differs, cookies might not work as expected, leading to issues such as failed authentication, improper session handling, and incorrect redirection.
- **End-to-end TLS/SSL requirements**: If end-to-end TLS/SSL is required for secure communication between the proxy and the backend service, a matching TLS certificate for the original hostname is necessary. Using the same hostname simplifies the certificate management process and ensures that secure communication is established seamlessly.

You can avoid these problems by using the same hostname for the service proxy and the backend web application. The backend application sees the same domain as the web browser, ensuring that session state, authentication, and URL handling function correctly.

### Message Flow

The following diagram shows the steps for the message flow during deployment and runtime.

[![Diagram of the message flow of the solution based on Application Gateway WAFv2 and NGINX ingress controller via HTTPS.](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-https-detail.png)](media/eks-web-rearchitect/application-gateway-azure-kubernetes-service-https-detail.png#lightbox)

#### Deployment workflow

The following steps describe the deployment process. This workflow corresponds to the green numbers in the preceding diagram.

1. A security engineer generates a certificate for the custom domain that the workload uses, and saves it in an Azure key vault. You can obtain a valid certificate from a well-known [certification authority (CA)](https://en.wikipedia.org/wiki/Certificate_authority).
2. A platform engineer specifies the necessary information in the *main.bicepparams*Bicep parameters file and deploys the Bicep templates to create the Azure resources. The necessary information includes:
    - A prefix for the Azure resources.
    - The name and resource group of the existing Azure Key Vault that holds the TLS certificate for the workload hostname and the Application Gateway listener custom domain.
3. You can configure the [deployment script](/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep)to install the following packages to your AKS cluster. For more information, check the parameters section of the Bicep module.
    - **[Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) using the [Prometheus community Kubernetes Helm charts](https://prometheus-community.github.io/helm-charts/)**: By default, this sample configuration doesn't install Prometheus and Grafana to the AKS cluster. Instead, it installs [Azure Managed Prometheus](/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-overview) and [Azure Managed Grafana](/en-us/azure/managed-grafana/overview).
    - [**cert-manager**](https://cert-manager.io/docs/): Certificate Manager isn't necessary in this sample, as both the Application Gateway and NGINX ingress controller use a pre-uploaded TLS certificate from Azure Key Vault.
    - **[NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) via a Helm chart**: If you use the [managed NGINX ingress controller with the application routing add-on](app-routing), you don't need to install another instance of the NGINX ingress controller via Helm.
4. The Application Gateway Listener retrieves the TLS certificate from Azure Key Vault.
5. The [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) object uses the certificate obtained from the [Azure Key Vault provider for Secrets Store CSI Driver](/en-us/azure/aks/csi-secrets-store-driver) to expose the Yelb UI service via HTTPS.
6. The Application Gateway Listener retrieves the TLS certificate from Azure key Vault.
7. The [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) object utilizes the certificate obtained from the [Azure Key Vault provider for Secrets Store CSI Driver](/en-us/azure/aks/csi-secrets-store-driver) to expose the Yelb UI service via HTTPS.

#### Runtime workflow

1. The client application calls the sample web application using its hostname. The DNS zone associated with the custom domain of the Application Gateway Listener uses an `A` record to resolve the DNS query with the address of the Azure public IP used by the front-end IP configuration of the Application Gateway.
2. The request is sent to the Azure public IP used by the front-end IP configuration of the Application Gateway.
3. The Application Gateway performs the following actions:
    1. The Application Gateway handles TLS termination and communicates with the backend application over HTTPS.
    2. The Application Gateway Listener uses an SSL certificate obtained from [Azure Key Vault](/en-us/azure/key-vault/general/overview).
    3. The Azure WAF Policy associated to the Listener runs OWASP rules and custom rules against the incoming request and blocks malicious attacks.
    4. The Application Gateway Backend HTTP Settings are configured to invoke the sample web application via HTTPS on port 443.
4. The Application Gateway Backend Pool calls the NGINX ingress controller through the AKS internal load balancer using HTTPS.
5. The request is sent to one of the agent nodes that hosts a pod of the NGINX ingress controller.
6. One of the NGINX ingress controller replicas handles the request and sends the request to one of the service endpoints of the `yelb-ui` service.
7. The `yelb-ui` calls the `yelb-appserver` service.
8. The `yelb-appserver` calls the `yelb-db` and `yelb-cache` services.
9. The `yelb-ui` calls the `yelb-appserver` service.
10. The `yelb-appserver` calls the `yelb-db` and `yelb-cache` services.

## Deployment

By default, Bicep templates install the AKS cluster with the [Azure CNI Overlay](azure-cni-overlay) network plugin and the [Cilium](azure-cni-powered-by-cilium) data plane. You can use an alternative network plugin. Additionally, the project shows how to deploy an AKS cluster with the following extensions and features:

- [Microsoft Entra Workload ID](/en-us/azure/aks/workload-identity-overview?tabs=dotnet)
- [Istio-based service mesh add-on](/en-us/azure/aks/istio-about)
- [API Server VNET integration](/en-us/azure/aks/api-server-vnet-integration)
- [Azure NAT Gateway](/en-us/azure/virtual-network/nat-gateway/nat-overview)
- [Event-driven autoscaling (KEDA) add-on](/en-us/azure/aks/keda-about)
- [Dapr extension](/en-us/azure/aks/dapr)
- [Flux V2 extension](/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli)
- [Vertical Pod Autoscaling](/en-us/azure/aks/vertical-pod-autoscaler)
- [Azure Key Vault Provider for Secrets Store CSI Driver](/en-us/azure/aks/csi-secrets-store-identity-access)
- [Image Cleaner](/en-us/azure/aks/image-cleaner?tabs=azure-cli)
- [Azure Kubernetes Service (AKS) Network Observability](/en-us/azure/aks/network-observability-overview)
- [Managed NGINX ingress with the application routing add-on](app-routing)

In a production environment, we strongly recommend deploying a [private AKS cluster](/en-us/azure/aks/private-clusters) with [Uptime SLA](/en-us/azure/aks/uptime-sla). For more information, see [private AKS cluster with a public DNS address](/en-us/azure/aks/private-clusters#create-a-private-aks-cluster-with-a-public-dns-address).

Alternatively, you can deploy a public AKS cluster and secure access to the API server using [authorized IP address ranges](/en-us/azure/aks/api-server-authorized-ip-ranges). For detailed information and instructions on how to deploy the infrastructure on Azure using Bicep templates, see the [companion Azure code sample](https://github.com/Azure-Samples/aks-web-application-replicate-from-aws).

In a production environment, we strongly recommend deploying a [private AKS cluster](/en-us/azure/aks/private-clusters) with [Uptime SLA](/en-us/azure/aks/uptime-sla). For more information, see [private AKS cluster with a Public DNS address](/en-us/azure/aks/private-clusters#create-a-private-aks-cluster-with-a-public-dns-address). Alternatively, you can deploy a public AKS cluster and secure access to the API server using [authorized IP address ranges](/en-us/azure/aks/api-server-authorized-ip-ranges). For detailed information and instructions on how to deploy the infrastructure on Azure using Bicep templates, refer to the [companion Azure code sample](https://github.com/Azure-Samples/aks-web-application-replicate-from-aws).