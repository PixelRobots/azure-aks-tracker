---
layout: Conceptual
title: Ingress support for Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cert-manager-ingress
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-08-28T00:00:00.0000000Z
ms.topic: how-to
description: Learn how to secure external ingress traffic when using Certificate Management for Azure Arc extension.
locale: en-us
document_id: 25cdd317-49ee-80ad-983d-4b01061c58e8
document_version_independent_id: b6b1ddee-3b2d-2215-37f1-fbf30076d73d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/cert-manager-ingress.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/cert-manager-ingress
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/cert-manager-ingress.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 48301ae2-757a-893b-5fd3-d4cb47afd8cb
---

# Ingress support for Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

You need ingress TLS support if your Kubernetes deployment accepts traffic securely from outside the cluster (and you're working within a zero-trust security model). Certificate Management for Azure Arc extension can observe ingress and gateway resources, create a certificate resource, store the resulting key pair in a Kubernetes secret, and renew it before expiration. The ingress or gateway controller uses that secret to terminate TLS and route traffic to your services.

This article describes how to secure external traffic to your Arc-enabled Kubernetes clusters by using TLS termination at the edge (ingress or gateway) with certificates that cert-manager automatically issues and renews.

## Choose between ingress and gateway API for TLS at the edge

When you secure external traffic incoming to your Kubernetes cluster, you have two primary options for managing TLS at the edge: the traditional [Ingress API](https://kubernetes.io/docs/concepts/services-networking/ingress/) and the newer [Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/). Both APIs enable you to automate certificate management by using cert-manager, but they differ in flexibility, feature set, and recommended use cases.

Ingress API is simpler and well-suited for existing deployments or rapid prototyping. It's easier to configure and has a stable feature set, with no further development planned. To use the Ingress API, you need an [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) running in your cluster.

Gateway API offers a more modern, extensible, and production-ready model for complex routing and traffic management. Gateway API makes it easier to separate gateway and route configurations. To use the Gateway API, you need to install the Gateway API CRDs and a gateway controller.

We recommend using the Gateway API for production deployments with your Arc-enabled Kubernetes clusters because of its enhanced capabilities and extensibility. However, the Ingress API remains a viable choice for existing deployments or prototyping.

## Configure cert-manager with the Gateway API

Follow these steps to configure Certificate Management for Azure Arc extension to work with the [Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/).

1. Install the Gateway API CRDs by running the following command:

    ```bash
    kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
    ```

    For more information, see [Getting started - Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api).
2. Configure cert-manager to enable Gateway API support by adding `--config cert-manager.config.enableGatewayAPI=true` to your `az k8s-extension` command. For example, use this command when installing the extension:

    ```azurecli
    az k8s-extension create \
      --resource-group ${RESOURCE_GROUP} \
      --cluster-name ${CLUSTER_NAME} \
      --cluster-type connectedClusters \
      --name "azure-cert-management" \
      --extension-type "microsoft.certmanagement" \
      --config cert-manager.config.enableGatewayAPI=true
    ```

    You can also include `--config cert-manager.config.enableGatewayAPI=true` with `az k8s-extension update` to enable Gateway API support on an existing cert-manager extension installation.
3. Create an Issuer or ClusterIssuer resource that cert-manager will use to issue certificates for the Gateway API resources. For example, create a self-signed ClusterIssuer:

    ```yaml
    cat <<EOF | kubectl apply -f -
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: ingresses-selfsigned-issuer
      spec:
        selfSigned: {}
    EOF
    ```
4. Add an annotation to the Gateway resource that tells cert-manager what issuer or cluster issuer to use, such as `cert-manager.io/cluster-issuer: yourIssuer`.

    You can add various [optional annotations](https://cert-manager.io/docs/usage/ingress/#supported-annotations) to further control the created certificate. For example, add the `cert-manager.io/duration` annotation to control the certificate duration.

    If you use an out-of-tree [issuer](https://cert-manager.io/docs/configuration/issuers/), you also need to install the issuer, and add `cert-manager.io/issuer-*` annotations to identify it.

    Ensure that the gateway resource [includes a `tls` section](https://gateway-api.sigs.k8s.io/reference/api-spec/main/spec/#listenertlsconfig) for each traffic type that it listens for. This section provides the secret name where cert-manager stores the certificate, and optional configuration for extended TLS support.

    The following example gateway resource includes annotations that trigger cert-manager to create certificates for this gateway, provided that you installed the Gateway API CRDs.

    ```yaml
    cat <<EOF | kubectl apply -f -
      apiVersion: gateway.networking.k8s.io/v1
      kind: Gateway
      metadata:
        name: gatewayapi
        namespace: cert-manager
        annotations:
          cert-manager.io/cluster-issuer: ingresses-selfsigned-issuer
          cert-manager.io/duration: 4h
          cert-manager.io/renew-before: 2h
      spec:
        gatewayClassName: gatewayclass
        listeners:
          - name: http
            hostname: your-host.com
            port: 443
            protocol: HTTPS
            allowedRoutes:
              namespaces:
                from: All
            tls:
              mode: Terminate
              certificateRefs:
                - name: gateway-api-secret
    EOF
    ```
5. Verify that the certificate was issued by running the following command:

    ```bash
    kubectl -n cert-manager describe certificate gateway-api-secret
    ```

    This command shows the certificate that cert-manager created for the gateway API resource. Confirm that the certificate was created successfully, and that the DNS Names in the certificate spec match those specified in the gateway API resource.

## Configure cert-manager with the Ingress API

Follow these steps to configure Certificate Management for Azure Arc extension to work with the [Ingress API](https://kubernetes.io/docs/concepts/services-networking/ingress/).

1. Create an Issuer or ClusterIssuer resource that cert-manager will use to issue certificates for the Ingress API resources. For example, create a self-signed ClusterIssuer:

    ```yaml
    cat <<EOF | kubectl apply -f -
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: ingresses-selfsigned-issuer
      spec:
        selfSigned: {}
    EOF
    ```
2. Add an annotation to the Ingress resource that tells cert-manager what issuer or cluster issuer to use, such as `cert-manager.io/cluster-issuer: yourIssuer`.

    You can add various [optional annotations](https://cert-manager.io/docs/usage/ingress/#supported-annotations) to further control the created certificate. For example, add the `cert-manager.io/duration` annotation to control the certificate duration.

    If you use an out-of-tree [issuer](https://cert-manager.io/docs/configuration/issuers/), you also need to install the issuer, and add `cert-manager.io/issuer-*` annotations to identify it.

    Ensure that the Ingress resource [includes a `tls` section](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/ingress-v1/#IngressSpec) that provides the hosts that are included in the TLS certificate, and the secret name where cert-manager stores the certificate.

    The following example ingress resource includes annotations that trigger cert-manager to create certificates for this ingress.

    ```yaml
    cat <<EOF | kubectl apply -f -
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        annotations:
          cert-manager.io/cluster-issuer: ingresses-selfsigned-issuer
          cert-manager.io/duration: 2h
          cert-manager.io/renew-before: 1h
        name: ingress
        namespace: cert-manager
      spec:
        rules:
        - host: your-host.com
          http:
            paths:
            - pathType: Prefix
              path: /
              backend:
                service:
                  name: your-service
                  port:
                    number: 80
        tls:
        - hosts:
          - your-host.com
          secretName: ingress-secret
    EOF
    ```
3. Verify that the certificate was issued by running the following command:

    ```bash
    kubectl -n cert-manager describe certificate ingress-secret
    ```

    This command shows the certificate that cert-manager created for the ingress. Confirm that the certificate was created successfully, and that the DNS Names in the certificate spec match those specified in the ingress resource.

## End-to-end setups for Gateway and Ingress APIs

This article shows how to integrate Certificate Management for Azure Arc extension with the Gateway and Ingress APIs, and how to verify the certificates cert-manager produces. For more information, see the cert-manager documentation, such as [Securing NGINX-ingress](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/), and the [Gateway API](https://gateway-api.sigs.k8s.io/docs/concepts/api-overview/) and [Ingress API](https://kubernetes.io/docs/concepts/services-networking/ingress/) documentation.