---
layout: Conceptual
title: Azure Kubernetes Service (AKS) managed NGINX ingress with the application routing add-on - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/app-routing
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
description: Use the application routing add-on to securely access applications deployed on Azure Kubernetes Service (AKS).
ms.subservice: aks-networking
ms.custom: devx-track-azurecli, biannual
author: schaffererin
ms.topic: how-to
ms.date: 2026-10-26T00:00:00.0000000Z
ai-usage: ai-assisted
ms.author: schaffererin
locale: en-us
document_id: ee35d171-5757-af15-8127-6e9fa6bd46ba
document_version_independent_id: 6cfdc0c8-1b03-2c70-2a3a-ab0935872cc0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/app-routing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/app-routing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/app-routing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 773201c5-a439-d386-8880-48c4b13d8120
---

# Azure Kubernetes Service (AKS) managed NGINX ingress with the application routing add-on - Azure Kubernetes Service | Microsoft Learn

Caution

The [Kubernetes SIG Network](https://github.com/kubernetes/community/blob/master/sig-network/README.md) and the Security Response Committee [announced the retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/) of the [Ingress NGINX project](https://github.com/kubernetes/ingress-nginx/), with maintenance that ended in March 2026. Microsoft will provide official support for critical security patches for application routing add-on NGINX Ingress resources through **November 2026**.

AKS aligns with upstream Kubernetes and uses **[Gateway API](https://gateway-api.sigs.k8s.io) as the long-term standard for ingress and L7 traffic management**. Migrate before support ends in November 2026, based on your requirements:

- **Application routing add-on users** and **OSS NGINX users**: Migrate to the [application routing Gateway API implementation](/en-us/azure/aks/app-routing-gateway-api) for a Gateway API-based ingress traffic management experience, or to [Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview), which supports both Ingress API and Gateway API.
- **Service mesh or advanced ingress requirements**: Consider [Gateway API ingress with the Istio service mesh add-on](/en-us/azure/aks/istio-gateway-api). You can use it for ingress without injecting sidecars into your workloads. If you need request header and body size limits, Lua scripts, or rate limiting, review the [Gateway API limitations and alternatives](/en-us/azure/aks/app-routing-gateway-api#limitations).

One way to route Hypertext Transfer Protocol (HTTP) and secure (HTTPS) traffic to applications running on an Azure Kubernetes Service (AKS) cluster is to use the [Kubernetes Ingress object](https://kubernetes.io/docs/concepts/services-networking/ingress/). When you enable the application routing add-on with NGINX, it creates, configures, and manages an Ingress controller in your AKS cluster.

This article shows you how to enable the managed NGINX Ingress controller and configure an Ingress object to route traffic to an application in your AKS cluster.

## Application routing add-on with NGINX features

The application routing add-on with NGINX delivers the following:

- Easy configuration of managed NGINX Ingress controllers based on [Kubernetes NGINX Ingress controller](https://kubernetes.github.io/ingress-nginx/).
- Integration with [Azure DNS](/en-us/azure/dns/dns-overview) for public and private zone management.
- SSL termination with certificates stored in Azure Key Vault.

For other configurations, see:

- [DNS and SSL configuration](app-routing-dns-ssl).
- [Application routing add-on configuration](app-routing-nginx-configuration).
- [Configure internal NGINX ingress controller for Azure private DNS zone](create-nginx-ingress-private-controller).

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.54.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Limitations

- The application routing add-on supports up to five Azure DNS zones.
- The application routing add-on can only be enabled on AKS clusters with [managed identity](use-managed-identity).
- All global Azure DNS zones integrated with the add-on have to be in the same resource group.
- All private Azure DNS zones integrated with the add-on have to be in the same resource group.
- Editing the ingress-nginx `ConfigMap` in the `app-routing-system` namespace isn't supported.
- If a snippet annotation value matches any of the following blocked values, the Ingress isn't configured:

    | Blocked value | Effect |
    | --- | --- |
    | `load_module` | The Ingress isn't configured. |
    | `lua_package` | The Ingress isn't configured. |
    | `_by_lua` | The Ingress isn't configured. |
    | `location` | The Ingress isn't configured. |
    | `root` | The Ingress isn't configured. |
    | `proxy_pass` | The Ingress isn't configured. |
    | `serviceaccount` | The Ingress isn't configured. |
    | `{` | The Ingress isn't configured. |
    | `}` | The Ingress isn't configured. |
    | `'` | The Ingress isn't configured. |
- The add-on doesn't officially support injecting non-Microsoft-managed sidecars (for example, custom telemetry, logging, or security agents) into the ingress-nginx proxy pods that it manages. If you choose to inject your own sidecar into a managed proxy pod, Microsoft provides only best-effort support for any issues you encounter.

## Multi-tenant clusters

Important

The managed NGINX Ingress controller doesn't isolate tenants at the namespace level. Don't use it as a security boundary between tenants that share a cluster.

The managed NGINX Ingress controller is based on the upstream ingress-nginx project. The ingress-nginx project assumes that users who can create Ingress objects are cluster administrators. The project says not to use ingress-nginx in multi-tenant production clusters. For more information, see [Multi-tenant Kubernetes](https://kubernetes.github.io/ingress-nginx/faq/#multi-tenant-kubernetes) in the ingress-nginx FAQ.

The following behaviors cross namespace boundaries:

- One NGINX Ingress controller serves the Ingress objects of its Ingress class from all namespaces. The controller merges the rules of these Ingress objects into one NGINX configuration. For more information, see [How it works](https://kubernetes.github.io/ingress-nginx/how-it-works/#building-the-nginx-model).
- An Ingress in one namespace can add paths to a host that an Ingress in a different namespace uses. If two Ingress objects use the same host, the oldest Ingress object controls the TLS settings and server-level annotations for that host. If they also use the same path, the oldest Ingress object gets the traffic for that path.
- The add-on allows snippet annotations, except for the blocked values in Limitations. Snippet annotations add NGINX configuration to the shared controller.
- The NGINX Ingress controller can read Secrets in all namespaces. The add-on enables the [`allow-cross-namespace-resources`](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#allow-cross-namespace-resources) option. By using this option, some annotations can reference a Secret or ConfigMap in a different namespace.
- A user who can create an Ingress can use any Ingress class. A separate `NginxIngressController` for each tenant doesn't isolate tenants.

To decrease this risk, use these practices:

- Give permission to create or update Ingress objects only to users that you trust at the same level as cluster administrators.
- If tenants don't trust each other, use a separate cluster for each tenant. For more information, see [Physically isolated clusters](operator-best-practices-cluster-isolation#physically-isolated-clusters).

## Enable the application routing add-on using Azure CLI

### Enable on a new cluster

To enable application routing on a new cluster, use the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command, specifying the `--enable-app-routing` flag.

```azurecli
az aks create \
    --resource-group <resource-group-name> \
    --name <cluster-name> \
    --location <location> \
    --enable-app-routing \
    --generate-ssh-keys
```

### Enable on an existing cluster

To enable application routing on an existing cluster, use the [`az aks approuting enable`](/en-us/cli/azure/aks/approuting#az-aks-approuting-enable) command.

```azurecli
az aks approuting enable --resource-group <resource-group-name> --name <cluster-name>
```

## Connect to your AKS cluster

To connect to the Kubernetes cluster from your local computer, you use [`kubectl`](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client. You can install it locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command. If you use the Azure Cloud Shell, `kubectl` is already installed.

Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
```

## Deploy an application

Kubernetes Ingress objects define routing rules for an Ingress controller. Use the application routing add-on's managed Ingress class and supported annotations to configure how its controller handles traffic.

1. Create the application namespace called `aks-store` to run the example pods using the `kubectl create namespace` command.

    ```bash
    kubectl create namespace aks-store
    ```
2. Deploy the AKS store application using the following YAML manifest file:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/sample-manifests/docs/app-routing/aks-store-deployments-and-services.yaml -n aks-store
    ```

This manifest creates `rabbitmq`, `order-service`, `product-service`, and `store-front` Deployments and corresponding Services. The `store-front` Service exposes port 80, which the Ingress routes to in the next section.

### Create the Ingress object

When you enable the application routing add-on, it creates an Ingress class named *webapprouting.kubernetes.azure.com*. Specify this class in an Ingress object to use the add-on's managed NGINX Ingress controller.

1. Copy the following YAML manifest into a new file named **ingress.yaml** and save the file to your local computer.

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: store-front
      namespace: aks-store
    spec:
      ingressClassName: webapprouting.kubernetes.azure.com
      rules:
      - http:
          paths:
          - backend:
              service:
                name: store-front
                port:
                  number: 80
            path: /
            pathType: Prefix
    ```
2. Create the ingress resource using the [`kubectl apply`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_apply/) command.

    ```bash
    kubectl apply -f ingress.yaml -n aks-store
    ```

    The following example output shows the created resource:

    ```output
    ingress.networking.k8s.io/store-front created
    ```

## Verify the managed Ingress resource

You can verify the managed Ingress was created using the `kubectl get ingress` command.

```bash
kubectl get ingress -n aks-store
```

The following example output shows the created managed Ingress:

```output
NAME          CLASS                                HOSTS   ADDRESS       PORTS   AGE
store-front   webapprouting.kubernetes.azure.com   *       51.8.10.109   80      110s
```

You can verify that the AKS store works by pointing your browser to the public IP address of the Ingress controller. The following command retrieves the external IP address assigned by the load balancer to the managed NGINX ingress controller's `nginx` Service in the `app-routing-system` namespace:

```bash
kubectl get service -n app-routing-system nginx -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
```

## Remove the application routing add-on

To remove the associated namespace, use the `kubectl delete namespace` command.

```bash
kubectl delete namespace aks-store
```

To remove the application routing add-on from your cluster, use the [`az aks approuting disable`](/en-us/cli/azure/aks/approuting#az-aks-approuting-disable) command.

```azurecli
az aks approuting disable --name <cluster-name> --resource-group <resource-group-name>
```

Note

To avoid potential disruption of traffic into the cluster when you disable the application routing add-on, some Kubernetes resources, including *configMaps*, *secrets*, and the *deployment* that runs the controller, remain on the cluster. These resources are in the *app-routing-system* namespace. You can remove these resources if they're no longer needed by deleting the namespace with `kubectl delete ns app-routing-system`.