---
layout: Conceptual
title: Tunnel connectivity issues - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/tunnel-connectivity-issues
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
description: Resolve tunnel connectivity issues in your Azure Kubernetes Service (AKS) cluster to restore logs, exec, and port-forward access. Follow the troubleshooting steps.
ms.date: 2026-06-18T00:00:00.0000000Z
ms.reviewer: chiragpa, andbar, v-leedennis, v-weizhu, albarqaw, andraciobanu
ms.service: azure-kubernetes-service
keywords: Azure Kubernetes Service, AKS cluster, Kubernetes cluster, tunnels, connectivity, tunnel-front, aks-link, Konnectivity agent, Cluster Proportional Autoscaler, CPA, Resource allocation, Performance bottlenecks, Networking reliability, Azure Kubernetes troubleshooting, AKS performance issues
ms.custom: sap:Connectivity
locale: en-us
document_id: cd1e1d57-0112-d5d7-1453-33397d75a48e
document_version_independent_id: cd1e1d57-0112-d5d7-1453-33397d75a48e
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/tunnel-connectivity-issues.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/tunnel-connectivity-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/tunnel-connectivity-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fdf93b0c-3dc7-41a6-b999-eb9ae4f3bb7f
---

# Tunnel connectivity issues - Azure | Microsoft Learn

## Summary

Tunnel connectivity problems in Azure Kubernetes Service (AKS) can disrupt secure communication between cluster nodes and the control plane. This article explains how to troubleshoot and resolve these problems to restore expected cluster operations.

[Tunnel connectivity is used specifically for API server to kubelet communication](/en-us/azure/aks/faq#how-does-the-managed-control-plane-communicate-with-my-nodes-) (not general pod-to-pod) or ingress traffic.

[![Screenshot of AKS tunnel architecture showing node-to-control-plane communication through the tunnel pod.](media/tunnel-connectivity-issues/kubernetes-tunnel-architecture.png)](media/tunnel-connectivity-issues/kubernetes-tunnel-architecture.png#lightbox)

Note

Previously, the AKS tunnel component was `tunnel-front`. It's now migrated to the [Konnectivity service](https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/#konnectivity-service), an upstream Kubernetes component. For more information about this migration, see the [AKS release notes](https://github.com/Azure/AKS/releases/tag/2021-10-28).

[API Server VNet Integration](/en-us/azure/aks/api-server-vnet-integration) enables nodes to communicate directly with the API server through an internal load balancer, without requiring a tunnel. Therefore, the `konnectivity-agent` component isn't expected in clusters where Konnectivity isn't required.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)

## Symptoms

You receive an error message that resembles the following examples about port 10250:

- Error from server: `Get "https\://\<aks-node-name>:10250/containerLogs/\<namespace>/\<pod-name>/\<container-name>": dial tcp \<aks-node-ip>:10250: i/o timeout`
- Error from server: `error dialing backend: dial tcp \<aks-node-ip>:10250: i/o timeout`
- Error from server: `Get "https\://\<aks-node-name>:10250/containerLogs/\<namespace>/\<pod-name>/\<container-name>": http: server gave HTTP response to HTTPS client`

The Kubernetes API server uses port 10250 to connect to a node's kubelet to retrieve the logs. If port 10250 is blocked, the `kubectl logs` and other features only work for pods that run on the nodes where the tunnel component is scheduled. This condition often results in partial failures, where commands succeed for some pods but fail for others depending on node placement.

For more information, see [Kubernetes ports and protocols: Worker nodes](https://kubernetes.io/docs/reference/ports-and-protocols/#node).

Because the tunnel components or the connectivity between the server and client can't be established, functionality such as the following features doesn't work as expected:

- Admission controller webhooks
- Ability to retrieve logs (using the [kubectl logs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs) command)
- Running a command in a container or getting inside a container (using the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command)
- Forwarding one or more local ports of a pod (using the [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward) command)

## Cause 1: A network security group (NSG) blocks port 10250

Note

This cause applies to any tunnel components that you might have in your AKS cluster.

Use an [Azure network security group](/en-us/azure/virtual-network/network-security-groups-overview) (NSG) to filter network traffic to and from Azure resources in an Azure virtual network. A network security group contains security rules that allow or deny inbound and outbound network traffic between several types of Azure resources. For each rule, you can specify source and destination, port, and protocol. For more information, see [How network security groups filter network traffic](/en-us/azure/virtual-network/network-security-group-how-it-works).

If the NSG blocks port 10250 at the virtual network level, tunnel functionalities (such as logs and code execution) work only for the pods that are scheduled on the nodes where tunnel pods are scheduled. The other pods don't work because their nodes can't reach the tunnel, and the tunnel is scheduled on other nodes. To verify this state, test the connectivity by using [netcat](https://nc110.sourceforge.io/) (`nc`) or telnet commands. Run the [az vmss run-command invoke](/en-us/cli/azure/vmss/run-command#az-vmss-run-command-invoke) command to conduct the connectivity test and verify whether it succeeds, times out, or causes some other issue:

```azurecli
az vmss run-command invoke --resource-group <infra-or-MC-resource-group> \
    --name <virtual-machine-scale-set-name> \
    --command-id RunShellScript \
    --instance-id <instance-id> \
    --scripts "nc -v -w 2 <ip-of-node-that-schedules-the-tunnel-component> 10250" \
    --output tsv \
    --query 'value[0].message'
```

### Solution 1: Add an NSG rule to allow access to port 10250

If you use an NSG and you have specific restrictions, make sure that you add a security rule that allows traffic for port 10250 at the virtual network level. The following [Azure portal](https://portal.azure.com) image shows an example security rule:

![Screenshot of the Add inbound security rule pane in the Azure portal. The Destination port ranges box is set to 10250 for the new security rule.](media/tunnel-connectivity-issues/add-inbound-security-rule.png)

If you want to be more restrictive, you can allow access to port 10250 at the subnet level only.

Note

Adjust the **Priority** field accordingly. For example, if you have a rule that denies multiple ports (including port 10250), the rule that's shown in the preceding image should have a lower priority number (lower numbers have higher priority). For more information about **Priority**, see [Security rules](/en-us/azure/virtual-network/network-security-groups-overview#security-rules). If you don't see any behavioral change after you apply this solution, you can re-create the tunnel component pods. Deleting these pods causes them to be re-created.

- Validate NSG rules for inbound and outbound port 10250.
- Use Netcat (nc), Telnet, or Azure Network Watcher checks.
- Verify node-to-node connectivity.

For more information, see [Troubleshoot connection issues to an app that's hosted in an AKS cluster](connection-issues-application-hosted-aks-cluster).

## Cause 2: The Uncomplicated Firewall (UFW) tool blocks port 10250

Note

This cause applies to any tunnel component that you have in your AKS cluster.

[Uncomplicated Firewall](https://wiki.ubuntu.com/UncomplicatedFirewall) (UFW) is a command-line program for managing a [netfilter](https://www.netfilter.org/) firewall. AKS nodes use Ubuntu. Therefore, UFW is installed on AKS nodes by default, but UFW is disabled.

By default, if you enable UFW, it blocks access to all ports, including port 10250. In this case, you can't use Secure Shell (SSH) to [connect to AKS cluster nodes for troubleshooting](/en-us/azure/aks/node-access). This restriction exists because UFW might also block port 22. To troubleshoot, run the [az vmss run-command invoke](/en-us/cli/azure/vmss/run-command#az-vmss-run-command-invoke) command to invoke a [ufw command](https://manpages.ubuntu.com/manpages/trusty/en/man8/ufw.8.html) that checks whether UFW is enabled:

```azurecli
az vmss run-command invoke --resource-group <infra-or-MC-resource-group> \
    --name <virtual-machine-scale-set-name> \
    --command-id RunShellScript \
    --instance-id <instance-id> \
    --scripts "ufw status" \
    --output tsv \
    --query 'value[0].message'
```

What if the results indicate that UFW is enabled, and it doesn't specifically allow port 10250? In this case, tunnel functionalities (like logs and code execution) don't work for the pods that are scheduled on the nodes that have UFW enabled. To fix the problem, apply one of the following solutions on UFW.

Important

Before you use this tool to make any changes, review the [AKS support policy](/en-us/azure/aks/support-policies) (especially [node maintenance and access](/en-us/azure/aks/support-policies#node-maintenance-and-access)) to prevent your cluster from entering into an unsupported scenario.

Note

If you don't see any behavioral change after you apply a solution, you can re-create the tunnel component pods. Deleting these pods causes them to be re-created.

### Solution 2a: Disable Uncomplicated Firewall

Run the following `az vmss run-command invoke` command to disable UFW:

```azurecli
az vmss run-command invoke --resource-group <infra-or-MC-resource-group> \
    --name <virtual-machine-scale-set-name> \
    --command-id RunShellScript \
    --instance-id <instance-id> \
    --scripts "ufw disable" \
    --output tsv \
    --query 'value[0].message'
```

### Solution 2b: Configure Uncomplicated Firewall to permit access to port 10250

To force UFW to allow access to port 10250, run the following `az vmss run-command invoke` command:

```azurecli
az vmss run-command invoke --resource-group <infra-or-MC-resource-group> \
    --name <virtual-machine-scale-set-name> \
    --command-id RunShellScript \
    --instance-id <instance-id> \
    --scripts "ufw allow 10250" \
    --output tsv \
    --query 'value[0].message'
```

## Cause 3: The iptables tool is blocking port 10250

Note

This cause applies to any tunnel component that you have in your AKS cluster.

The [iptables](https://www.netfilter.org/projects/iptables/) tool lets a system administrator configure the IP packet filter rules of a Linux firewall. You can configure the `iptables` rules to block communication on port 10250.

You can view the rules for your nodes to check whether port 10250 is blocked or the associated packets are dropped. To do this, run the following `iptables` command:

```bash
iptables --list --line-numbers
```

In the output, the data is grouped into several *chains*, including the `INPUT` chain. Each chain contains a table of rules under the following column headings:

- `num` (rule number)
- `target`
- `prot` (protocol)
- `opt`
- `source`
- `destination`

Does the `INPUT` chain contain a rule in which the target is `DROP`, the protocol is `tcp`, and the destination is `tcp dpt:10250`? If it does, `iptables` is blocking access to destination port 10250.

### Solution 3: Delete the iptables rule that blocks access on port 10250

Run one of the following commands to delete the `iptables` rule that prevents access to port 10250:

```bash
iptables --delete INPUT --jump DROP --protocol tcp --source <ip-number> --destination-port 10250
```

```bash
iptables --delete INPUT <input-rule-number>
```

To address your exact or potential scenario, check the [iptables manual](https://ipset.netfilter.org/iptables.man.html) by running the `iptables --help` command.

Important

Before you use this tool to make any changes, review the [AKS support policy](/en-us/azure/aks/support-policies) (especially [node maintenance and access](/en-us/azure/aks/support-policies#node-maintenance-and-access)) to prevent your cluster from entering into an unsupported scenario.

## Cause 4: Source Network Address Translation (SNAT) port exhaustion

Note

This cause applies to any tunnel component that you have in your AKS cluster. However, it doesn't apply to [private AKS clusters](/en-us/azure/aks/private-clusters). Source Network Address Translation (SNAT) port exhaustion can occur for public communication only. For private AKS clusters, the API server is inside the AKS virtual network or subnet.

If [SNAT port exhaustion](/en-us/azure/load-balancer/load-balancer-outbound-connections#port-exhaustion) occurs (failed [SNAT ports](/en-us/azure/load-balancer/load-balancer-outbound-connections#what-are-snat-ports)), the nodes can't connect to the API server. The tunnel container is on the API server side. Therefore, tunnel connectivity won't be established.

If the SNAT port resources are exhausted, the outbound flows fail until the existing flows release some SNAT ports. Azure Load Balancer reclaims the SNAT ports when the flow closes. It uses a four-minute idle time-out to reclaim the SNAT ports from the idle flows.

You can view the SNAT ports from either the AKS load balancer metrics or the service diagnostics, as described in the following sections. For more information about how to view SNAT ports, see [How do I check my outbound connection statistics?](/en-us/azure/load-balancer/load-balancer-standard-diagnostics#how-do-i-check-my-outbound-connection-statistics).

AKS load balancer metrics

To use AKS load balancer metrics to view the SNAT ports, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Kubernetes services**.
2. In the list of Kubernetes services, select the name of your cluster.
3. In the menu pane of the cluster, find the **Settings** heading, and then select **Properties**.
4. Select the name that's listed under **Infrastructure resource group**.
5. Select the **kubernetes** load balancer.
6. In the menu pane of the load balancer, find the **Monitoring** heading, and then select **Metrics**.
7. For the metric type, select **SNAT Connection Count**.
8. Select **Apply splitting**.
9. Set **Split by** to **Connection State**.

Service diagnostics

To use service diagnostics to view the SNAT ports, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Kubernetes services**.
2. In the list of Kubernetes services, select the name of your cluster.
3. In the menu pane of the cluster, select **Diagnose and solve problems**.
4. Select **Connectivity Issues**.
5. Under **SNAT Connection and Port Allocation**, select **View details**.
6. If necessary, use the **Time Range** button to customize the time frame.

### Solution 4a: Make sure the application uses connection pooling

This behavior might occur because an application isn't reusing existing connections. Don't create one outbound connection per request. Such a configuration can cause connection exhaustion. Check whether the application code follows best practices and uses connection pooling. Most libraries support connection pooling. Therefore, you shouldn't have to create a new outbound connection per request.

### Solution 4b: Adjust the allocated outbound ports

If everything is OK within the application, adjust the allocated outbound ports. For more information about outbound port allocation, see [Configure the allocated outbound ports](/en-us/azure/aks/configure-load-balancer-standard?tabs=create-cluster-ip-based%2Ccreate-cluster-managed-outbound-ips%2Ccreate-cluster-custom-ips%2Ccreate-cluster-custom-ip-prefixes%2Ccreate-cluster-outbound-ports-ips%2Ccreate-cluster-idle-timeout#configure-the-allocated-outbound-ports).

### Solution 4c: Use a Network Address Translation (NAT) Gateway when you create a cluster

Set up a new cluster to use a Network Address Translation (NAT) Gateway for outbound connections. For more information, see [Create an AKS cluster with a Managed NAT Gateway](/en-us/azure/aks/nat-gateway).

## Cause 5: Konnectivity agents performance problems with cluster growth

As the cluster grows, the performance of Konnectivity Agents might degrade because of increased network traffic, more requests, or resource constraints.

Note

This cause applies only to the `Konnectivity-agent` pods.

### Solution 6: Cluster Proportional Autoscaler for Konnectivity Agent

To manage scalability challenges in large clusters, implement the Cluster Proportional Autoscaler for your Konnectivity Agents. This approach aligns with industry standards and best practices. It ensures optimal resource usage and enhanced performance.

**Why make this change** Previously, the Konnectivity agent had a fixed replica count that could create a bottleneck as the cluster grew. By implementing the Cluster Proportional Autoscaler, you enable the replica count to adjust dynamically, based on node-scaling rules, to provide optimal performance and resource usage.

**How the Cluster Proportional Autoscaler works** The Cluster Proportional Autoscaler uses a ladder configuration to determine the number of Konnectivity agent replicas based on the cluster size. The ladder configuration is defined in the `konnectivity-agent-autoscaler` configmap in the `kube-system` namespace. Here's an example of the ladder configuration:

```
nodesToReplicas": [
    [1, 2],
    [100, 3],
    [250, 4],
    [500, 5],
    [1000, 6],
    [5000, 10]
]
```

This configuration ensures that the number of replicas scales appropriately with the number of nodes in the cluster to provide optimal resource allocation and improved networking reliability.

**How to use the Cluster Proportional Autoscaler** You can override default values by updating the `konnectivity-agent-autoscaler` configmap in the `kube-system` namespace. Here's a sample command to update the configmap:

```bash
kubectl edit configmap <pod-name> -n kube-system
```

This command opens the configmap in an editor so you can make the necessary changes.

**What you should check**

You need to monitor for Out Of Memory (OOM) kills on the nodes because misconfiguration of the Cluster Proportional Autoscaler can cause insufficient memory allocation for the Konnectivity agents. This misconfiguration occurs for the following key reasons:

**High Memory Usage:** As the cluster grows, the memory usage of Konnectivity agents can increase significantly. This increase can occur especially during peak loads or when handling large numbers of connections. If the Cluster Proportional Autoscaler configuration doesn't scale the replicas appropriately, the agents might run out of memory.

**Fixed Resource Limits:** If the resource requests and limits for the Konnectivity agents are set too low, they might not have enough memory to handle the workload, leading to OOM kills. Misconfigured Cluster Proportional Autoscaler settings can exacerbate this issue by not providing enough replicas to distribute the load.

**Cluster Size and Workload Variability:** The CPU and memory that the Konnectivity agents need can vary widely depending on the size of the cluster and the workload. If the Cluster Proportional Autoscaler ladder configuration isn't right-sized and adaptively resized for the cluster's usage patterns, it can cause memory overcommitment and OOM kills.

To identify and troubleshoot OOM kills, follow these steps:

1. Check for OOM Kills on nodes: Use the following command to check for OOM Kills on your nodes:

```
kubectl get events --all-namespaces | grep -i 'oomkill'
```

1. Inspect Node Resource Usage: Verify the resource usage on your nodes to make sure that they aren't running out of memory:

```
kubectl top nodes
```

1. Review Pod Resource Requests and Limits: Make sure that the Konnectivity agent pods have appropriate resource requests and limits set to prevent OOM Kills:

```
kubectl get pod <pod-name> -n kube-system -o yaml | grep -A5 "resources:"
```

1. Adjust Resource Requests and Limits: If necessary, adjust the resource requests and limits for the Konnectivity agent pods by editing the deployment:

```
kubectl edit deployment konnectivity-agent -n kube-system
```

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.