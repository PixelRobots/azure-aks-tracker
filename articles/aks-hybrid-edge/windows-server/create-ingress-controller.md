---
layout: Conceptual
title: Use an ingress controller in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-ingress-controller
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
description: Learn how to deploy an ingress controller in Azure Kubernetes Service in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: 27a80e53-0ebd-ea62-d657-b11e49087780
document_version_independent_id: c9bf699c-03fd-b6fa-3db1-467e86e2e1f7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-ingress-controller.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-ingress-controller
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-ingress-controller.md
platformId: ceea3593-1a93-25b2-738b-2038eb083477
---

# Use an ingress controller in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

An *ingress controller* is a Kubernetes resource that allows external access to services within the Kubernetes cluster. Ingress lets an operator expose a service to external network requests, usually HTTP or HTTPS. You configure access by creating a set of rules that define the inbound connections that reach specific services.

An ingress controller is software that provides configurable traffic routing for Kubernetes services. Kubernetes ingress resources are used to configure the ingress rules and routes for individual Kubernetes services. By using an ingress controller and ingress rules, you can use a single IP address to route traffic to multiple services in a Kubernetes cluster.

After you deploy the controller in your environment, you can then create and deploy the ingress manifest. Currently, you use ingress in AKS by using the NGINX ingress controller. For information about how to install, configure, and use the NGINX ingress controller, see [Installation with Manifests](https://kubernetes.github.io/ingress-nginx/deploy/#azure).

Ingress differs from the [NodePort and LoadBalancer](concepts-container-networking#kubernetes-services) in a unique way, and it improves traffic routing to your cluster in a less costly way. Defining NodePort services creates numerous random ports, and defining LoadBalancer services increases the cost for cloud resources more than you might want. When you define an ingress controller, you consolidate the traffic-routing rules into a single resource that runs as part of your cluster. The NodePort and LoadBalancer let you expose a service by specifying that value in the service's type, whereas ingress is an independent resource for the service. Ingress is defined, created, and destroyed separately from the service.

You can deploy ingress in various ways depending on the use case. Ingress resources are used to update the configuration within the ingress controller to determine how it functions.

## Use ingress to expose services through externally reachable URLs

An example of using ingress is shown in the following YAML manifest. The `ingress.class` appears within the metadata (in this example, `ingress-nginx`), and this setting lets the NGINX ingress controller know what it needs to monitor and update:

```yaml
apiVersion: networking.k8s.io/v1  
kind: Ingress  
metadata: 
      name: hello-world
      annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /
        kubernetes.io/ingress.class: "nginx"
  spec:  
      rules:
       - host: test.example.com
          http:
             paths: 
             - path: /hello-world
pathType: Prefix
backend:
    service: 
         name: hello-world 
                    port:  
                     number: 8080
```

The `spec` section provides information about what's configured. In this example, a rule (or set of rules) is defined and includes the following items:

- The host to which the rules are applied.
- Whether the traffic is HTTP or HTTPS.
- The monitored path.
- The internal service and port where the traffic is sent.

## Use ingress to load balance traffic

In the following example, another path is added to the manifest that permits load balancing between different backends of an application. In this example, the operator can split traffic and send it to different service endpoints and deployments based on the path described. Behind each path is a deployment and a service, which is helpful for endpoints that receive more traffic:

```yaml
apiVersion: networking.k8s.io/v1  
kind: Ingress  
metadata: 
      name: hello-world-and-earth
      annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /
  spec:  
      rules:
       - host: test.example.com
          http:
             paths: 
             - path: /hello-world
pathType: Prefix
backend:
    service: 
         name: hello-world 
                    port:  
                     number: 8080
               - path: /hello-earth
pathType: Prefix
backend:
    service: 
         name: hello-earth 
                    port:  
                     number: 8080
```

## Use ingress to route HTTP traffic to multiple host names on the same IP address

You can use a different ingress resource for each host, which lets you control the traffic with multiple host names. To use a different ingress resource, point multiple host names at the same public IP address that's used for the LoadBalancer service. In the following manifest file, a production version of `hello-world` was added. The hostname `prod.example.com` is used, and traffic is pointed to the new service `hello-world-prod`. Traffic comes in through the load balancer IP address and is routed based on the host name and the path that you provide:

```yaml
apiVersion: networking.k8s.io/v1  
kind: Ingress  
metadata: 
      name: hello-world-prod
      annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /
  spec:  
      rules:
       - host: test.example.com
          http:
             paths: 
             - path: /hello-world
pathType: Prefix
backend:
    service: 
         name: hello-world-test 
                    port:  
                     number: 8080
       - host: prod.example.com
          http:
              paths:
               - path: /hello-world
pathType: Prefix
backend:
    service: 
         name: hello-world-prod 
                    port:  
                     number: 8080
```