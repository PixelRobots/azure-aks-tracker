---
layout: Conceptual
title: Deploy metrics server on an AKS Edge Essentials cluster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-metric-server
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
description: Learn about the steps to deploy a metrics server on an AKS Edge Essentials cluster.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: b94949a9-a7ad-ec68-f80c-9641c69cbecb
document_version_independent_id: dacfcddc-46c6-5080-af3a-12465df70565
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-metric-server.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-metric-server
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-metric-server.md
platformId: ffbd8bbd-8479-5bf2-4dbc-e742237cbbcf
---

# Deploy metrics server on an AKS Edge Essentials cluster | Microsoft Learn

The [metrics server](https://github.com/kubernetes-sigs/metrics-server) is a tool that inspects your containers' resource consumption. You can find the [YAML file](https://github.com/Azure/AKS-Edge/blob/main/samples/others/metrics-server.yaml) for the metrics server deployment in the **/Samples/Other** folder [in the GitHub repo](https://github.com/Azure/AKS-Edge/).

## Deploy metrics server

Note

AKS Edge Essentials K8s does not support [Kubernetes TLS bootstrapping](https://kubernetes.io/docs/reference/access-authn-authz/kubelet-tls-bootstrapping/). To deploy the metrics server using K8s, be sure to include `--kubelet-insecure-tls` in your deployment YAML.

### Step 1: deploy the metrics server manifest

```powershell
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/others/metrics-server.yaml
```

Wait for the metrics server pods to reach the **running** status. It might take a few minutes.

```powershell
kubectl get pods -A --watch
```

[![Screenshot of results showing metrics pod running.](../media/aks-edge/metrics-pod-running.png)](../media/aks-edge/metrics-pod-running.png#lightbox)

#### Step 2: View your resource consumption

```powershell
kubectl top nodes
```

```powershell
kubectl top pods -A
```

[![Screenshot of results showing metrics server installed.](../media/aks-edge/metrics-server-installed.png)](../media/aks-edge/metrics-server-installed.png#lightbox)

If your metrics server fails to display, this could be a known MTU issue in which the Linux VM's MTU doesn't match that of your network. This issue can happen on Azure VMs. Set your MTU parameter to 1300 in your **AksEdgeConfig** file, as follows:

```json
{
    "LinuxVm": {
        "CpuCount": 4,
        "MemoryInMB": 4096,
        "Mtu": 1300
    }
}
```