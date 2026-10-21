---
layout: Conceptual
title: Common issues when you run or scale large AKS clusters FAQ - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-at-scale-troubleshoot-guide
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Review common issues when you run or scale large AKS clusters. The article includes troubleshooting tips for resolving these issues.
ms.date: 2024-09-27T00:00:00.0000000Z
ms.reviewer: paahluwalia, mariochaves, v-leedennis, v-weizhu
editor: v-jsitser
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 13b8987a-183b-88d8-3ecf-96afd3d562b3
document_version_independent_id: 13b8987a-183b-88d8-3ecf-96afd3d562b3
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/aks-at-scale-troubleshoot-guide.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/aks-at-scale-troubleshoot-guide
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/aks-at-scale-troubleshoot-guide.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1ba4e147-1630-60ba-e632-6c03263f7c14
---

# Common issues when you run or scale large AKS clusters FAQ - Azure | Microsoft Learn

## Summary

This article answers frequently asked questions about common issues that might occur when you run or scale large clusters in Microsoft Azure Kubernetes Service (AKS). A large cluster is any cluster that runs at more than a 500-node scale.

## I get a "quota exceeded" error during creation, scale up, or upgrade

To resolve this issue, create a support request in the subscription in which you're trying to create, scale, or upgrade, and request a quota for the corresponding resource type. For more information, see [regional compute quotas](/en-us/azure/quotas/regional-quota-requests).

## I get an "insufficientSubnetSize" error when I deploy an AKS cluster that uses advanced networking

This error indicates that a subnet that's in use for a cluster no longer has available IPs within its CIDR for successful resource assignment. This issue can occur during upgrades, scale outs, or node pool creation. This issue occurs because the number of free IPs in the subnet is less than the result of the following formula:

> 
> number of nodes requested \* node pool `--max-pod` value

### Prerequisites

- To scale beyond 400 nodes, you have to use the [Azure CNI networking plug-in](/en-us/azure/aks/configure-azure-cni).
- To help plan your virtual network and subnets to accommodate the number of nodes and pods that you're deploying, see [planning IP addresses for your cluster](/en-us/azure/aks/configure-azure-cni#plan-ip-addressing-for-your-cluster). To reduce the overhead of subnet planning or cluster re-creation that you would do because of IP exhaustion, see [Dynamic IP allocation](/en-us/azure/aks/configure-azure-cni#dynamic-allocation-of-ips-and-enhanced-subnet-support).

### Solution

Because you can't update an existing subnet's CIDR range, you must have permission to create a new subnet to resolve this issue. Follow these steps:

1. Rebuild a new subnet that has a larger CIDR range that's sufficient for operation goals.
2. Create a new subnet that has a new non-overlapping range.
3. Create a new node pool on the new subnet.
4. Drain pods from the old node pool that resides in the old subnet that will be replaced.
5. Delete the old subnet and old node pool.

## I'm having sporadic egress connectivity failures because of SNAT port exhaustion

For clusters that run at a relatively large scale (more than 500 nodes), we recommend that you use the AKS [Managed Network Address Translation (NAT) Gateway](/en-us/azure/aks/nat-gateway) for greater scalability. Azure NAT Gateway allows up to 64,512 outbound UDP and TCP traffic flows per IP address, and a maximum of 16 IP addresses.

If you're not using Managed NAT, see [Troubleshoot source network address translation (SNAT) exhaustion and connection timeouts](/en-us/azure/load-balancer/troubleshoot-outbound-connection) to understand and resolve SNAT port exhaustion issues.

## I can't scale up to 5,000 nodes using the Azure portal

Use the Azure CLI to scale up to a maximum of 5,000 nodes by following these steps:

1. Create a minimum number of node pools in the cluster (because the maximum node pool node limit is 1,000) by running the following command:

    ```bash
    az aks nodepool add --resource-group MyResourceGroup --name nodepool1 --cluster-name MyManagedCluster
    ```
2. Scale up the node pools one at a time. Ideally, set five minutes of sleep time between consecutive scale-ups of 1,000. Run the following command:

    ```bash
    az aks nodepool scale --resource-group MyResourceGroup --name nodepool1 --cluster-name MyManagedCluster
    ```

## My upgrade is running, but it's slow

In its default configuration, AKS surges during an upgrade by taking the following actions:

- Creating one new node.
- Scaling the node pool beyond the desired number of nodes by one node.

For the max surge settings, a default value of one node means that AKS creates one new node before it drains the existing applications and replaces an earlier-versioned node. This extra node lets AKS minimize workload disruption.

When you upgrade clusters that have many nodes, it can take several hours to upgrade the entire cluster if you use the default value of `max-surge`. You can customize the `max-surge` property per node pool to enable a tradeoff between upgrade speed and upgrade disruption. By increasing the max surge value, you enable the upgrade process to finish sooner. However, a large value for max surge might also cause disruptions during the upgrade process.

Run the following command to increase or customize the max surge for an existing node pool:

```bash
az aks nodepool update --resource-group MyResourceGroup --name mynodepool --cluster-name MyManagedCluster --max-surge 5
```

It's also important to consider how your deployment settings might delay the completion of the upgrade or scale operation:

- [SKU family B series VMs are not supported](/en-us/azure/aks/use-system-pools#system-and-user-node-pools) by AKS in the system nodepool and they can experience low performance during and after updates.
- Check your deployment's PDB resource settings to ensure they are accurate for a successful upgrade. For more information, see [AKS workload best practices](/en-us/azure/architecture/operator-guides/aks/aks-upgrade-practices).

Tip

To get more insights about this behavior, you can [view error details on the Activity Log page in the Azure portal](troubleshoot-aks-cluster-creation-issues#view-error-details-in-the-azure-portal) or review the [resource logs](/en-us/azure/aks/monitor-aks-reference#resource-logs) on your cluster.

## My upgrade is reaching the quota (5,000 cluster) limit

To resolve this issue, see [Increase regional vCPU quotas](/en-us/azure/quotas/regional-quota-requests).

## My internal service creation at more than 750 nodes is slow or failing because of a time-out error

Standard Load Balancer (SLB) back-end pool updates are a known performance bottleneck. We're working on a new capability that will enable faster creation of services and SLB at scale. To send us your feedback about this issue, see [Azure Kubernetes support for load balancer with IP-based back-end pool](https://github.com/Azure/AKS/issues/3245).

### Solution

We recommend that you scale down the cluster to fewer than 750 nodes, and then create an internal load balancer for the cluster. To create an internal load balancer, create a `LoadBalancer` service type and `azure-load-balancer-internal` annotation, per the following example procedure.

#### Step 1: Create an internal load balancer

To create an internal load balancer, create a service manifest that's named *internal-lb.yaml* and that contains the `LoadBalancer` service type and the `azure-load-balancer-internal` annotation, as shown in the following example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: internal-app
```

#### Step 2: Deploy the internal load balancer

Deploy the internal load balancer by using the `kubectl apply` command, and specify the name of your YAML manifest, as shown in the following example:

```bash
kubectl apply -f internal-lb.yaml
```

After your cluster is created, you can also provision an internal load balancer (per this procedure), and keep an internal load-balanced service running. Doing this enables you to add more services to the load balancer at scale.

## SLB service creation at scale takes hours to run

SLB back-end pool updates are a known performance bottleneck. We're working on a new capability that will allow you to run load balanced services at scale with considerably faster performance for create, update, and delete operations. To send us your feedback, see [Azure Kubernetes support for load balancer with IP-based back-end pool](https://github.com/Azure/AKS/issues/3245).

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.