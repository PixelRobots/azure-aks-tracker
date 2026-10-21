---
layout: Conceptual
title: Troubleshoot CoreDNS on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/coredns-troubleshoot
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
description: Learn how to troubleshoot common CoreDNS issues on Azure Kubernetes Service (AKS) clusters.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: troubleshooting-general
ms.date: 2025-09-08T00:00:00.0000000Z
locale: en-us
document_id: b927e49e-33c3-f2ff-f21f-267ada850ce5
document_version_independent_id: b6b4d2b9-9d3a-8ec6-dc47-1ad366ada075
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/coredns-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/coredns-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/coredns-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0ddab484-2ef6-8f8b-dbc1-178ddecfafa3
---

# Troubleshoot CoreDNS on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article provides troubleshooting guidance for various CoreDNS issues on Azure Kubernetes Service (AKS).

## Debug DNS resolution issues

For general CoreDNS troubleshooting steps, such as checking the endpoints or resolution, see [Debugging DNS resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/).

## Troubleshoot CoreDNS pod traffic imbalance

You might see one or two CoreDNS pods showing significantly higher CPU usage and handling more DNS queries than others, even with multiple CoreDNS pods running in your AKS cluster. This is a [known issue](https://github.com/kubernetes/kubernetes/issues/76517#issuecomment-490731578) in Kubernetes and can lead to one of the CoreDNS pods being overloaded and crashing.

This uneven distribution of DNS queries is primarily caused by User Datagram Protocol (UDP) load balancing limitations in Kubernetes. The platform uses a five-tuple hash (source IP, source port, destination IP, destination port, protocol) to distribute UDP traffic, so if an application reuses the same source port for DNS queries, all queries from that client are routed to the same CoreDNS pod. This distribution method can result in a single pod handling a disproportionate amount of traffic. Additionally, some applications use connection pooling and reuse DNS connections. This behavior can further concentrate DNS queries on a single CoreDNS pod, increasing the imbalance and the risk of overloading and potential crashes.

The following sections help you troubleshoot and mitigate this issue.

### Enable DNS query logging

Enable DNS query logging to capture required DNS query logs from CoreDNS pods.

1. Add the following configuration to your `coredns-custom` ConfigMap:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      log.override: | # You can select any name here, but it must end with the .override file extension
            log
    ```
2. Apply the ConfigMap changes using the [`kubectl apply configmap`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f corednsms.yaml
    ```
3. Perform a rolling restart to reload the ConfigMap and enable the Kubernetes Scheduler to restart CoreDNS without downtime using the [`kubectl rollout restart`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command.

    ```bash
    kubectl --namespace kube-system rollout restart deployment coredns
    ```
4. View the CoreDNS debug logging using the `kubectl logs` command.

    ```bash
    kubectl logs --namespace kube-system -l k8s-app=kube-dns
    ```

### Check your CoreDNS pod traffic distribution

1. Get the names of all CoreDNS pods in your cluster using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pods --namespace kube-system -l k8s-app=kube-dns
    ```
2. Review the logs for each CoreDNS pod to analyze DNS query patterns using the [`kubectl logs`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/) command. Repeat this command for all CoreDNS pods, replacing `<coredns-pod-x>` with the actual pod names.

    ```bash
    kubectl logs --namespace kube-system <coredns-pod-x>
    ```
3. In the outputs, look for repeated client IP addresses and ports that appear only in the logs of a single CoreDNS pod. This indicates that DNS queries from certain clients aren't being distributed evenly.

    Example log output:

    ```output
    [INFO] 10.244.0.247:5556 - 42621 "A IN myservice.default.svc.cluster.local. udp 28" NOERROR qr,aa,rd 106 0.000141s
    ```

    In this example log entry:

    - `10.244.0.247` is the client IP address making the DNS query.
    - `5556` is the client source port.
    - `42621` is the query ID.

    **If you see the same client IP and port repeatedly in only one pod's logs, this confirms a traffic imbalance**.

### Mitigate CoreDNS pod traffic imbalance

If you notice an imbalance, your application could be reusing UDP source ports or pooling their connections. Based on the root cause, you can take the following mitigation actions:

- **Caused by UDP source port reuse**: UDP source port reuse occurs when a client application sends multiple DNS queries from the same UDP source port. If this is the issue, update your applications or DNS clients to randomize source ports for each DNS query, which helps distribute requests more evenly across pods.
- **Caused by connection pooling**: Connection pools are mechanisms applications use to reuse existing network connections instead of creating a new connection for each request. While this improves efficiency, it can result in all DNS queries from an application being sent over the same connection, and thus routed to the same CoreDNS pod. To mitigate this, adjust your application's DNS connection handling by reducing connection Time to Live (TTL) or randomizing connection creation, ensuring queries aren't concentrated on a single CoreDNS pod.

These changes can help achieve a more balanced DNS query distribution and reduce the risk of overloading individual pods.

## Troubleshoot invalid search domain completions for internal.cloudapp.net and reddog.microsoft.com

Azure DNS configures a default search domain of `<VNET_ID>.<REGION>.internal.cloudapp.net` in virtual networks (VNets) using Azure DNS and a nonfunctional stub `reddog.microsoft.com` in VNets using custom DNS servers. For more information, see the [Name resolution for resources documentation](/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances).

Kubernetes configures pod DNS settings with `ndots: 5` to properly support cluster service hostname resolution. These two configurations combine to result in invalid search domain completion queries that never succeed being sent to upstream name servers while the system processes through the domain search list. These invalid queries cause name resolution delays and can place extra load on upstream DNS servers.

As of the *v20241025* AKS release, AKS configures CoreDNS to respond with `NXDOMAIN` in the following cases in order to prevent these invalid search domain completion queries from being forwarded to upstream DNS:

- Any query for the root domain or a subdomain of `reddog.microsoft.com`.
- Any query for a subdomain of `internal.cloudapp.net`that has seven or more labels in the domain name.
    - This configuration allows virtual machine (VM) resolution by hostname to still succeed. For example, CoreDNS sends `aks12345.myvnetid.myregion.internal.cloudapp.net` (*six* labels) to Azure DNS, but rejects `mcr.microsoft.com.myvnetid.myregion.internal.cloudapp.net` (*eight* labels).

This block is implemented in the default server block in the CoreFile for the cluster. If needed, you can disable this rejection configuration by creating custom server blocks for the appropriate domain with a forward plugin enabled:

1. Create a file named `corednsms.yaml` and paste in the following example configuration. Make sure to update the IP addresses and hostnames with your own values.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom # This is the name of the ConfigMap you can overwrite with your changes
      namespace: kube-system
    data:
        override-block.server: |
           internal.cloudapp.net:53 {
               errors
               cache 30
               forward . /etc/resolv.conf
           }
           reddog.microsoft.com:53 {
               errors
               cache 30
               forward . /etc/resolv.conf
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

## Troubleshoot CoreDNS autoscaling issues

To troubleshoot CoreDNS autoscaling issues, see [Autoscaling CoreDNS in Azure Kubernetes Service (AKS)](coredns-autoscale).