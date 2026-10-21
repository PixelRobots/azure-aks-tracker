---
layout: Conceptual
title: Migrate from Windows Server 2019 to Windows Server 2022 | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/windows-server-migration-guide
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
description: Learn how to migrate AKS from Windows Server 2019 to 2022.
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.topic: how-to
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: 53c7e91a-1ad7-8b88-99b3-5e3adab59bd4
document_version_independent_id: b367ed8b-59dc-8e2a-df8e-9c86d690c008
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/windows-server-migration-guide.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/windows-server-migration-guide
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/windows-server-migration-guide.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 467697a6-7c98-f5b4-cb35-d92cf2151199
---

# Migrate from Windows Server 2019 to Windows Server 2022 | Microsoft Learn

To help ensure Azure remains the best possible experience with the highest standards of safety and reliability, migrate AKS Hybrid and Edge workloads from Windows Server 2019 to Windows Server 2022.

This guide helps you migrate your AKS Hybrid and Edge workloads from Windows Server 2019 to Windows Server 2022. The migration involves updating container images, creating new node pools, and redeploying applications to ensure compatibility with the newer operating system.

## What you'll accomplish

- Update container images to use Windows Server 2022 base images.
- Create new Windows Server 2022 node pools.
- Migrate workloads with zero downtime using rolling deployments.
- Remove legacy Windows Server 2019 infrastructure.

## Prerequisites

Before you begin the migration, ensure you have the following prerequisites in place:

- Azure CLI and `kubectl` installed
- Access to AKS clusters
- Permissions to create and delete node pools

## Step 1: identify affected clusters

To list clusters and check for Windows Server 2019 node pools, run the following commands:

```azurecli
az aksarc list --output table
az aksarc nodepool list --cluster-name <cluster-name> --resource-group <resource-group>
```

## Step 2: update container images

To use Windows Server 2022 base images, run the following command to update Dockerfiles:

```dockerfile
# Change from ltsc2019 to ltsc2022
FROM mcr.microsoft.com/windows/servercore:ltsc2022
```

Next, rebuild and push the images:

```bash
docker build -t myapp:ws2022 .
docker push myregistry.azurecr.io/myapp:ws2022
```

## Step 3: create Windows Server 2022 node pool

Add a new Windows Server 2022 node pool to your AKS cluster:

```azurecli
az aksarc nodepool add \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name ws2022pool \
  --os-type Windows \
  --os-sku Windows2022 \
  --node-count 3
```

Verify nodes are ready:

```bash
kubectl get nodes -l kubernetes.io/os=windows
```

## Step 4: update deployment manifests

Add node selectors to target Windows Server 2022:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-windows-app
spec:
  template:
    spec:
      nodeSelector:
        kubernetes.io/os: windows
        kubernetes.io/os-version: "10.0.20348"  # Windows Server 2022
      containers:
        - name: my-app
          image: myregistry.azurecr.io/myapp:ws2022
```

## Step 5: deploy and verify

Apply the updated deployment:

```bash
kubectl apply -f deployment.yaml
kubectl rollout status deployment/my-windows-app
```

Verify pods are running:

```bash
kubectl get pods -l app=my-windows-app -o wide
kubectl logs deployment/my-windows-app
```

## Step 6: Remove old node pools

Drain nodes:

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force
```

Delete the old pool:

```azurecli
az aksarc nodepool delete \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name <old-nodepool-name> \
  --yes
```

## Step 7: Validate

Confirm migration success:

```bash
kubectl get deployments --all-namespaces
kubectl get pods --all-namespaces -o wide
kubectl get nodes
```

## Common issues

If you encounter issues during migration, consider the following troubleshooting tips:

**Pods not scheduling:**

- Check node selectors match: `kubectl describe pod <pod-name>`
- Verify node labels: `kubectl describe node <node-name>`

**Image compatibility:**

- Rebuild images with Windows Server 2022 base
- Test in non-production environment first

**Network issues:**

- Verify network policies: `kubectl get networkpolicies`
- Check service endpoints: `kubectl get endpoints`

## Testing checklist

Before production migration:

- Container images build on Windows Server 2022
- Applications start without errors
- Network connectivity verified
- Storage mounts correctly
- Performance acceptable
- Monitoring operational