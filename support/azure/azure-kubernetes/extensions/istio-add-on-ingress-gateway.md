---
layout: Conceptual
title: Istio Service Mesh Add-on Ingress Gateway Troubleshooting - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-ingress-gateway
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: nshankar13
ms.author: nshankar
ms.topic: troubleshooting
description: Troubleshoot Istio service mesh add-on ingress gateway issues in Azure Kubernetes Service (AKS) and restore traffic flow—follow the checklist now.
ms.date: 2025-03-18T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: fuyuanbie, shasb, kochhars, ddama, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 8205eddf-32fc-8cd8-4f00-8e451b0269f4
document_version_independent_id: 8205eddf-32fc-8cd8-4f00-8e451b0269f4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/istio-add-on-ingress-gateway.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/istio-add-on-ingress-gateway
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/istio-add-on-ingress-gateway.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8674a6cc-aedf-3b40-30d8-9c58acf1aad1
---

# Istio Service Mesh Add-on Ingress Gateway Troubleshooting - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot [ingress gateway](/en-us/azure/aks/istio-deploy-ingress) issues on the Istio service mesh add-on for Azure Kubernetes Service (AKS). The Istio ingress gateway is an [Envoy](https://www.envoyproxy.io)-based reverse proxy that you can use to route incoming traffic to workloads in the mesh.

For the Istio-based service mesh add-on, we offer the following ingress gateway options:

- An internal ingress gateway that uses a private IP address.
- An external ingress gateway that uses a publicly accessible IP address.

The add-on deploys Istio ingress gateway pods and deployments per revision. If you're doing a [canary upgrade](istio-add-on-minor-revision-upgrade), and you have two control plane revisions installed in your cluster, you might have to troubleshoot multiple ingress gateway pods across both revisions.

## Troubleshooting checklist

### Step 1: Make sure no firewall or NSG rules block the ingress gateway

Verify that you don't have firewall or [Network Security Group (NSG) rules](/en-us/azure/virtual-network/network-security-groups-overview) that block traffic to the ingress gateway. You have to explicitly add a Destination Network Address Translation (DNAT) rule to [allow inbound traffic](/en-us/azure/aks/limit-egress-traffic#allow-inbound-traffic-through-azure-firewall) through Azure Firewall to the ingress gateway.

Double check whether you set restrictions to allow traffic only to the subnets of your user node pools. If the ingress gateway pods are scheduled onto [system node pools](/en-us/azure/aks/use-system-pools?tabs=azure-cli), incoming traffic to these pods could be blocked. You can address this issue by allowing traffic to the subnets of your system node pools.

### Step 2: Configure gateways, virtual services, and destination rules correctly

When you configure gateways, virtual services, and destination rules for traffic routing through the ingress gateway, follow these steps:

1. Make sure that the ingress gateway selector in the gateway resource is set to one of the following text values if you're using an external or internal gateway, respectively:

    - `istio: aks-istio-ingressgateway-external`
    - `istio: aks-istio-ingressgateway-internal`
2. Make sure that the ports are set correctly in gateways and virtual services. For the gateway, the port should be set to `80` for `http` or `443` for `https`. For the virtual service, the port should be set to the port that the corresponding service for the application is listening on.
3. Verify that the service is exposed within the `hosts` specification for both the gateway and the virtual service. If you experience issues that are related to the `Host` header in the requests, try adding all hosts that contain an asterisk wildcard ("\*") to the allowlist. See this [example gateway configuration](https://raw.githubusercontent.com/istio/istio/release-1.19/samples/bookinfo/networking/bookinfo-gateway.yaml). However, as a production practice, we recommend that you don't amend the allowlist. Also, the `hosts` specification should be [configured explicitly](https://istio.io/latest/docs/ops/best-practices/security/#avoid-overly-broad-hosts-configurations).

### Step 3: Fix the health of the ingress gateway pod

If the ingress gateway pod crashes or doesn't appear in the ready state, verify that the Istio daemon (`istiod`) control plane pod is in the ready state. The ingress gateway depends on having the `istiod` release be ready.

If the `istiod` pod doesn't appear in the ready state, make sure that the Istio custom resource definitions (CRDs) and the `base` Helm chart is installed correctly. To verify this state, run the following command:

```bash
helm ls --all --all-namespaces
```

You might see a broader error in which the add-on installation isn't configured specifically to the ingress gateway.

If the `istiod` pod is healthy, but the ingress gateway pods aren't responding, inspect the following ingress gateway resources in the `aks-istio-ingress` namespace to collect more information:

- Helm release
- Deployment
- Service

Additionally, you can find more information about gateway and sidecar debugging in [General Istio service mesh add-on troubleshooting](istio-add-on-general-troubleshooting).

### Step 4: Configure resource utilization

High resource usage occurs if the default min/max replica settings for Istiod and the gateways aren't sufficient. In this case, change [horizontal pod autoscaling](/en-us/azure/aks/istio-scale) configurations.

### Step 5: Troubleshoot the secure ingress gateway

If an [external ingress gateway is configured to expose a secure HTTPS service using simple or mutual TLS](/en-us/azure/aks/istio-secure-gateway), follow these troubleshooting steps:

1. Verify that the values of the `INGRESS_HOST_EXTERNAL` and `SECURE_INGRESS_PORT_EXTERNAL` environment variables are valid based on the output of the following command:

    ```bash
    kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external
    ```
2. Check for error messages in the gateway controller's logs:

    ```bash
    kubectl logs -n aks-istio-ingress <gateway-service-pod>
    ```
3. Verify that the secrets are created in the `aks-istio-ingress` namespace:

    ```bash
    kubectl -n aks-istio-ingress get secrets
    ```

For the example in [Secure ingress gateway for Istio service mesh add-on for Azure Kubernetes Service](/en-us/azure/aks/istio-secure-gateway), the `productpage-credential` secret should be listed.

After you enable the Azure Key Vault secrets provider add-on, you have to grant access for the user-assigned managed identity of the add-on to the Azure Key Vault. Setting up access to Azure Key Vault incorrectly prevents the `productpage-credential` secret from being created.

To make sure that secrets sync from Azure Key Vault to the cluster, verify that the `secrets-store-sync-productpage` sample pod that references this resource is successfully deployed after you create the `SecretProviderClass` resource.

### Step 6: Customize ingress gateway service settings

The add-on also supports [customizing the Kubernetes service for the Istio ingress gateway](/en-us/azure/aks/istio-deploy-ingress#ingress-gateway-service-customizations) for certain annotations and the `.spec.externalTrafficPolicy` setting. In certain cases, changing `.spec.externalTrafficPolicy` to `Local` can help troubleshooting connectivity and networking issues because it preserves the client source IP for the incoming request at the ingress gateway.

Note

Changing `.spec.externalTrafficPolicy` to `Local` might cause imbalanced traffic spreading. Before you apply this change, we recommend that you refer to the Kubernetes documentation about [Preserving the client source IP](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) to understand the tradeoffs between the different `externalTrafficPolicy` settings.

## References

- [Istio add-on ingress enablement and configuration](/en-us/azure/aks/istio-deploy-ingress)
- [Ingress control](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/)
- [Traffic management concepts for gateways](https://istio.io/latest/docs/concepts/traffic-management/#gateways)
- [Istio gateway configuration](https://istio.io/latest/docs/reference/config/networking/gateway/)
- [Istio virtual service configuration](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
- [Traffic management: Ingress gateway tasks (TLS termination, secure gateways, and so on)](https://istio.io/latest/docs/tasks/traffic-management/ingress/)
- [Istio security best-practices for gateways](https://istio.io/latest/docs/ops/best-practices/security/#gateways)
- [Traffic management and gateway pitfalls](https://istio.io/latest/docs/ops/common-problems/network-issues/#route-rules-have-no-effect-on-ingress-gateway-requests)
- [Istio and Kubernetes ingress](https://istio.io/latest/docs/tasks/traffic-management/ingress/kubernetes-ingress/)
- [Kubernetes Gateway API and Istio Ingress](https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.