---
layout: Conceptual
title: Deploy a sample application on AKS on bare metal (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-deploy-application
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
description: Learn how to deploy a containerized application to your Azure Kubernetes Service on bare metal cluster.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: e357617f-c73b-4560-7444-450e52e4857d
document_version_independent_id: 21d0f1b4-312d-d9e3-b389-4e2a4029b751
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-deploy-application.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-deploy-application
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-deploy-application.md
platformId: 9722f0ae-ae7a-024d-faa9-2a5913b9d31d
---

# Deploy a sample application on AKS on bare metal (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article walks you through deploying a sample application to your AKS on bare metal cluster and accessing it.

## Prerequisites

- An AKS on bare metal cluster in a **Succeeded** state
- Connected to the cluster via `az connectedk8s proxy` (see [Connect to your cluster](aks-bare-metal-connect-to-cluster))
- `kubectl` installed and configured

## Deploy a sample nginx application

Follow the steps below to deploy a nginx deployment on your AKS on bare metal cluster.

### Step 1: Create the deployment

```bash
kubectl create deployment nginx --image=mcr.microsoft.com/cbl-mariner/base/nginx:1.22
```

### Step 2: Verify the pod is running

```bash
kubectl get pods
```

Wait until the STATUS shows **Running**:

```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-1ab234c5d6-xyz12   1/1     Running   0          30s
```

### Step 3: Expose the deployment as a service

```bash
kubectl expose deployment nginx --port=80 --type=NodePort
```

### Step 4: Find the NodePort

```bash
kubectl get svc nginx
```

Output:

```
NAME    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.96.45.123   <none>        80:31234/TCP   5s
```

The NodePort in this example is `31234`.

### Step 5: Access the application

From a machine that can reach the bare metal host's network:

```
http://<bare-metal-host-ip>:<nodeport>
```

For example: `http://10.0.0.10:31234`

## Deploy using a YAML manifest

For more complex applications, use a YAML manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-app
  template:
    metadata:
      labels:
        app: hello-app
    spec:
      containers:
      - name: hello-app
        image: mcr.microsoft.com/cbl-mariner/base/nginx:1.22
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: hello-app
spec:
  type: NodePort
  selector:
    app: hello-app
  ports:
  - port: 80
    targetPort: 80
```

Apply the manifest:

```bash
kubectl apply -f hello-app.yaml
```

## Best practices for preview clusters

Since AKS on bare metal runs a single-node cluster during public preview:

- **Set resource requests and limits**: Prevents workloads from consuming all host resources and starving the control plane
- **Reserve capacity for the control plane**: The Kubernetes control plane requires approximately 2-GB RAM and 1 CPU core
- **Use NodePort for external access**: LoadBalancer type isn't supported during preview
- **Pull images from MCR**: Microsoft Container Registry (`mcr.microsoft.com`) images are guaranteed to be accessible

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Pod stuck in `ErrImagePull` | Verify the host can reach `mcr.microsoft.com`. Check DNS and firewall rules |
| Pod stuck in `Pending` | Check node resources: `kubectl describe node`. Look for CPU or memory pressure |
| Service not accessible | Verify you're using the correct NodePort and host IP. Check firewall allows the port |
| `context deadline exceeded` on kubectl | The `az connectedk8s proxy` isn't running. Restart it in another terminal |

## Clean up

To remove the sample application:

```bash
kubectl delete deployment nginx
kubectl delete svc nginx
```