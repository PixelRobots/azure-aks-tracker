---
layout: Conceptual
title: Customize CoreDNS for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/coredns-custom
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
description: Learn how to customize CoreDNS to add subdomains, extend custom DNS endpoints, and change scaling logic using Azure Kubernetes Service (AKS).
ms.subservice: aks-networking
author: schaffererin
ms.topic: how-to
ms.date: 2025-09-08T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: d84eccf3-f5cb-f9e7-3b3b-0128912cc2d2
document_version_independent_id: 22fc9403-71f9-a0b3-1e8b-468cd080068f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/coredns-custom.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/coredns-custom
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/coredns-custom.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ff9d4329-871c-a81f-bfab-8003b0452333
---

# Customize CoreDNS for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) uses [CoreDNS](https://coredns.io/) for cluster DNS management and resolution with all *1.12.x* and higher clusters. AKS is a managed service, so you can't modify the main configuration for CoreDNS (a *CoreFile*). Instead, you use a Kubernetes *ConfigMap* to override the default settings. To see the default AKS CoreDNS ConfigMaps, use the `kubectl get configmaps --namespace=kube-system coredns --output yaml` command.

This article shows you how to use ConfigMaps for basic CoreDNS customization options in Azure Kubernetes Service (AKS).

Note

Previously, AKS used `kube-dns` for cluster DNS management and resolution, but it's now deprecated. `kube-dns` offered different [customization options](https://www.danielstechblog.io/using-custom-dns-server-for-domain-specific-name-resolution-with-azure-kubernetes-service/) via a Kubernetes config map. CoreDNS is **not** backwards compatible with `kube-dns`. You must update any previous customizations to work with CoreDNS.

## Prerequisites

- This article assumes that you have an existing AKS cluster. If you need an AKS cluster, you can create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- Verify the version of CoreDNS you're running. The configuration values might change between versions.

## Plugin support

All built-in CoreDNS plugins are supported. No add-on/third party plugins are supported.

Important

When you create configurations like the ones in this article, the names you specify in the `data` section must end in `.server` or `.override`. This naming convention is defined in the default AKS CoreDNS ConfigMap, which you can view using the `kubectl get configmaps --namespace=kube-system coredns --output yaml` command.

## Configure DNS name rewrites

1. Create a file named `corednsms.yaml` and paste in the following example configuration. Make sure to replace `<domain to be rewritten>` with your own fully qualified domain name (FQDN).

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      test.server: |
        <domain to be rewritten>.com:53 {
        log
        errors
        rewrite stop {
          name regex (.*)\.<domain to be rewritten>\.com {1}.default.svc.cluster.local
          answer name (.*)\.default\.svc\.cluster\.local {1}.<domain to be rewritten>.com
        }
        forward . /etc/resolv.conf # You can redirect this to a specific DNS server such as 10.0.0.10, but that server must be able to resolve the rewritten domain name
        }
    ```

    Important

    If you redirect to a DNS server, such as the CoreDNS service IP, that DNS server must be able to resolve the rewritten domain name.
2. Create the ConfigMap using the [`kubectl apply configmap`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f corednsms.yaml
    ```
3. Verify the customizations were applied using the [`kubectl get configmaps`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get configmaps --namespace=kube-system coredns-custom -o yaml
    ```
4. Perform a rolling restart to reload the ConfigMap and enable the Kubernetes Scheduler to restart CoreDNS without downtime using the [`kubectl rollout restart`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command.

    ```bash
    kubectl --namespace kube-system rollout restart deployment coredns
    ```

## Specify a forward server for your network traffic

1. Create a file named `corednsms.yaml` and paste in the following example configuration. Make sure to replace the `forward` name and `<domain to be rewritten>` with your own values.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      test.server: | # You can select any name here, but it must end with the .server file extension
        <domain to be rewritten>.com:53 {
            forward foo.com 1.1.1.1
        }
    ```
2. Create the ConfigMap using the [`kubectl apply configmap`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f corednsms.yaml
    ```
3. Perform a rolling restart to reload the ConfigMap and enable the Kubernetes Scheduler to restart CoreDNS without downtime using the [`kubectl rollout restart`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command.

    ```bash
    kubectl --namespace kube-system rollout restart deployment coredns
    ```

## Use custom domains

You might want to configure custom domains that can only be resolved internally. For example, you might want to resolve the custom domain *puglife.local*, which isn't a valid top-level domain. Without a custom domain ConfigMap, the AKS cluster can't resolve the address.

1. Create a new file named `corednsms.yaml` and paste in the following example configuration. Make sure to update the custom domain and IP address with your own values.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      puglife.server: | # You can select any name here, but it must end with the .server file extension
        puglife.local:53 {
            errors
            cache 30
            forward . 192.11.0.1  # This is my test/dev DNS server
        }
    ```
2. Create the ConfigMap using the [`kubectl apply configmap`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f corednsms.yaml
    ```
3. Perform a rolling restart to reload the ConfigMap and enable the Kubernetes Scheduler to restart CoreDNS without downtime using the [`kubectl rollout restart`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command.

    ```bash
    kubectl --namespace kube-system rollout restart deployment coredns 
    ```

## Configure stub domains

1. Create a file named `corednsms.yaml` and paste the following example configuration. Make sure to update the custom domains and IP addresses with your own values.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      test.server: | # You can select any name here, but it must end with the .server file extension
        abc.com:53 {
         errors
         cache 30
         forward . 1.2.3.4
        }
        my.cluster.local:53 {
            errors
            cache 30
            forward . 2.3.4.5
        }
    
    ```
2. Create the ConfigMap using the [`kubectl apply configmap`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify.

    ```bash
    kubectl apply -f corednsms.yaml
    ```
3. Perform a rolling restart to reload the ConfigMap and enable the Kubernetes Scheduler to restart CoreDNS without downtime using the [`kubectl rollout restart`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command.

    ```bash
    kubectl --namespace kube-system rollout restart deployment coredns
    ```

## Add custom host-to-IP mappings

1. Create a file named `corednsms.yaml` and paste the following example configuration. Make sure to update the IP addresses and hostnames with your own values.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom # This is the name of the ConfigMap you can overwrite with your changes
      namespace: kube-system
    data:
        test.override: | # You can select any name here, but it must end with the .override file extension
              hosts { 
                  10.0.0.1 example1.org
                  10.0.0.2 example2.org
                  10.0.0.3 example3.org
                  fallthrough
              }
    ```
2. Create the ConfigMap using the [`kubectl apply configmap`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f corednsms.yaml
    ```
3. Perform a rolling restart to reload the ConfigMap and enable the Kubernetes Scheduler to restart CoreDNS without downtime using the [`kubectl rollout restart`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command.

    ```bash
    kubectl --namespace kube-system rollout restart deployment coredns
    ```