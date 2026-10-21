---
layout: Conceptual
title: Use a Public Standard Load Balancer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard
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
description: Learn how to use a public load balancer with a Standard SKU to expose your services with Azure Kubernetes Service (AKS).
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2026-09-10T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 30d080dc-2a2b-46ce-2433-ec1eddd5ffc8
document_version_independent_id: 6e30ff27-5ab1-75a8-23a0-13e3927d888a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/load-balancer-standard.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/load-balancer-standard
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/load-balancer-standard.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 026c0d8e-89b5-4dd7-726d-2f2a726737fd
---

# Use a Public Standard Load Balancer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

The [Azure Load Balancer](/en-us/azure/load-balancer/load-balancer-overview) operates at layer 4 of the Open Systems Interconnection (OSI) model that supports both inbound and outbound scenarios. It distributes inbound flows that arrive at the load balancer's front end to the back end pool instances.

A **public** load balancer integrated with AKS serves two purposes:

- Provide outbound connections to the cluster nodes inside the AKS virtual network (VNet) by translating the private IP address to a public IP address part of its *outbound pool*.
- Provide access to applications via Kubernetes services of type `LoadBalancer`, enabling you to easily scale your applications and create highly available services.

This article covers integration with a public load balancer on AKS. For internal load balancer integration, see [Use an internal load balancer in AKS](internal-lb).

## Prerequisites

- AKS supports the *Standard* SKU Azure Load Balancer, which is used by default when you create an AKS cluster. The *Standard* SKU gives you access to functionality such as a larger backend pool, [multiple node pools](create-node-pools), [Availability Zones](reliability-availability-zones-configure), and is [secure by default](/en-us/azure/load-balancer/load-balancer-overview#securebydefault). The *Basic* SKU was retired on September 30, 2025, and AKS no longer supports it. If you have an existing AKS cluster that uses the *Basic* SKU, see [Upgrade from Basic Load Balancer on AKS](upgrade-basic-load-balancer-on-aks). For more information about Load Balancer SKUs, see [Azure Load Balancer SKU comparison](/en-us/azure/load-balancer/skus).
- For a full list of the supported annotations for Kubernetes services with type `LoadBalancer`, see [LoadBalancer annotations](https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/#loadbalancer-annotations).
- This article assumes you have an AKS cluster with the *Standard* SKU Azure Load Balancer. If you need an AKS cluster, you can create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [the Azure portal](learn/quick-kubernetes-deploy-portal).
- You need `kubectl` installed and configured to connect to your AKS cluster. To install `kubectl`, download your cluster credentials, and verify the connection, see [Connect to the cluster](learn/quick-kubernetes-deploy-cli#connect-to-the-cluster).

Important

If you'd prefer to use your own gateway, firewall, or proxy to provide outbound connection, you can skip the creation of the load balancer outbound pool and respective frontend IP by using [**outbound type as UserDefinedRouting (UDR)**](egress-outboundtype). The outbound type defines the egress method for a cluster and defaults to type `LoadBalancer`.

## Limitations

The following limitations apply when you create and manage AKS clusters that support a load balancer with the *Standard* SKU:

- AKS manages the lifecycle and operations of agent nodes. Modifying the IaaS resources associated with the agent nodes isn't supported. An example of an unsupported operation is making manual changes to the load balancer resource group.
- At least one public IP or IP prefix is required for allowing egress traffic from the AKS cluster. The public IP or IP prefix is required to maintain connectivity between the control plane and agent nodes and to maintain compatibility with previous versions of AKS. You have the following options for specifying public IPs or IP prefixes with a *Standard* SKU load balancer:

    - Provide your own public IPs.
    - Provide your own public IP prefixes.
    - Specify a number up to 100 to allow the AKS cluster to create that many *Standard* SKU public IPs in the same resource group as the AKS cluster. This resource group is usually named with `MC_` at the beginning. AKS assigns the public IP to the *Standard* SKU load balancer. By default, one public IP is automatically created in the same resource group as the AKS cluster if no public IP, public IP prefix, or number of IPs is specified. You also must allow public addresses and avoid creating any Azure policies that ban IP creation.
- A public IP created by AKS can't be reused as a custom bring your own (BYO) public IP address. You must create and manage all custom IP addresses.
- You can't change the load balancer SKU by directly modifying the AKS-managed load balancer resource. To migrate an existing AKS cluster from the retired *Basic* SKU to the *Standard* SKU, use the supported [AKS upgrade process](upgrade-basic-load-balancer-on-aks). The migration causes downtime and can't be rolled back after it begins.
- *Standard* SKU load balancers only support *Standard* SKU IP addresses.
- [Private Link Service](/en-us/azure/private-link/private-link-service-overview) isn't supported when the load balancer backend pool type is set to `nodeIP`.

## Create a load balancer service in AKS

After you create an AKS cluster with outbound type `LoadBalancer` (default), your cluster is ready to use the load balancer to expose services.

1. Verify that your cluster has at least one running, ready pod with the `app: public-app` label. The service manifest in the next step selects pods with this label but doesn't create a deployment.

    ```bash
    kubectl get pods -l app=public-app
    ```
2. Create a service manifest named `public-svc.yaml`, which creates a public service of type `LoadBalancer`.

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: public-svc
    spec:
      type: LoadBalancer
      ports:
      - port: 80
      selector:
        app: public-app
    ```

## Specify the load balancer IP address

If you want to use a specific IP address with the load balancer, you have two options to specify the IP address:

- **Set service annotations** (recommended): Use `service.beta.kubernetes.io/azure-pip-name` to specify an existing public IP resource by name. This annotation is the most efficient option and helps you avoid potential throttling. You can also use `service.beta.kubernetes.io/azure-load-balancer-ipv4` for an IPv4 address and `service.beta.kubernetes.io/azure-load-balancer-ipv6` for an IPv6 address. For public IP resource, resource group, and identity requirements, see [Use a static public IP address with the AKS load balancer](static-ip).
- **Add the *LoadBalancerIP* property to the load balancer YAML manifest**: Add the `Service.Spec.LoadBalancerIP` property to the load balancer YAML manifest. This field is deprecated following [upstream Kubernetes](https://github.com/kubernetes/kubernetes/pull/107235), and it doesn't support dual-stack. Current usage remains the same and existing services are expected to work without modification.

## Deploy the load balancer service manifest

1. Deploy the public service manifest using [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f public-svc.yaml
    ```

    The Azure Load Balancer is configured with a new public IP that fronts the new service. Since the Azure Load Balancer can have multiple frontend IPs, each new service that you deploy gets a new dedicated frontend IP to be uniquely accessed.
2. Confirm your service is created and the load balancer is configured by using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get service public-svc
    ```

    When you view the service details, the public IP address created for this service on the load balancer is shown in the *EXTERNAL-IP* column of the output. It might take a few minutes for the IP address to change from *&lt;pending&gt;* to an actual public IP address. The following example output shows successful creation of the service:

    ```output
    NAMESPACE     NAME          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)         AGE
    default       public-svc    LoadBalancer   10.0.39.110    203.0.113.187   80:32068/TCP    52s
    ```
3. Get more detailed information about your service by using the [`kubectl describe service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command.

    ```bash
    kubectl describe service public-svc
    ```

    The following example output is a condensed version of the output after you run `kubectl describe service`. *LoadBalancer Ingress* shows the external IP address exposed by your service. *IP* shows the internal addresses.

    ```output
    Name:                        public-svc
    Namespace:                   default
    Labels:                      <none>
    Annotations:                 <none>
    Selector:                    app=public-app
    ...
    IP:                          10.0.39.110
    ...
    LoadBalancer Ingress:        203.0.113.187
    ...
    TargetPort:                  80/TCP
    NodePort:                    32068/TCP
    ...
    Session Affinity:            None
    External Traffic Policy:     Cluster
    ...
    ```