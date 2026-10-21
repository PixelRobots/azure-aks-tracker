---
layout: Conceptual
title: Troubleshoot LocalDNS problems in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/dns/troubleshoot-localdns
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
description: Learn a step-by-step workflow to troubleshoot LocalDNS issues in AKS, identify DNS failure patterns, and resolve problems faster. Start now.
ms.date: 2026-10-19T00:00:00.0000000Z
ms.reviewer: v-rekhanain, v-leedennis, josebl, v-weizhu, qasimsarfraz, amaljuna
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
ai-usage: ai-assisted
locale: en-us
document_id: 835002bb-8793-7c50-8d14-df7ebc9f9bb2
document_version_independent_id: 835002bb-8793-7c50-8d14-df7ebc9f9bb2
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/dns/troubleshoot-localdns.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/dns/troubleshoot-localdns
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/dns/troubleshoot-localdns.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 98d957fc-c20f-b7fa-9689-319a6fb0e285
---

# Troubleshoot LocalDNS problems in AKS - Azure | Microsoft Learn

## Summary

This article describes how to troubleshoot LocalDNS problems in Azure Kubernetes Service (AKS). Use a step-by-step workflow to identify Domain Name System (DNS) failure patterns, collect LocalDNS query logs, and resolve resolution failures faster. To learn more about LocalDNS, see [DNS Resolution in Azure Kubernetes Service (AKS)](/en-us/azure/aks/dns-concepts#localdns-in-azure-kubernetes-service-preview).

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) command-line tool

    Note

    To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The [systemctl](https://man7.org/linux/man-pages/man1/systemctl.1.html) command-line tool.
- The [journalctl](https://www.man7.org/linux/man-pages/man1/journalctl.1.html) command-line tool.

## Identify patterns in DNS failures

Before you begin diagnosing the issues seen with LocalDNS, identify potential patterns with your DNS failures. Some patterns include:

1. DNS resolution failure - is this happening all the time or intermittently?
2. Are you seeing the DNS issues from all the nodes, a specific node pool, a subset of nodes, or just a single node?
3. Are you seeing DNS issues from nodes in a specific Azure zone? Or from all the zones?
4. What protocols are failing? Is it both TCP (Transmission Control Protocol) and UDP (User Datagram Protocol), or just one of them?
5. What zones are failing? Is it all zones or a specific zone?

    Note

    In this case, "zone" refers to DNS zones like *cluster.local* and root (.) and not to physical zones in Azure.

## Diagnose LocalDNS with a test DNSUtil pod

### Step 0: Confirm LocalDNS is enabled and running

Before you generate test traffic, confirm the feature is active on the node pool and the service is healthy on the node.

Check that the node pool has LocalDNS enabled:

```azurecli
az aks nodepool show --resource-group <resourceGroup> --cluster-name <clusterName> --name <nodePoolName> --query "localDNSProfile"
```

[Connect to the affected node](/en-us/azure/aks/node-access#connect-using-kubectl-debug), then confirm the service is active and listening on both local listener IPs:

```bash
# Service state
systemctl status localdns

# Listener IPs should be bound (node listener and cluster listener)
ss -lunp | grep -E '169\.254\.10\.1[01]'
```

If `localdns` is inactive or failed, inspect the unit logs (`journalctl -u localdns`) before continuing.

### Step 1: Deploy a test dnsutils pod

Option 1 - Deploy a test pod to your cluster using the following command:

```bash
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
```

Option 2 - If you're seeing DNS issues in specific nodes, you can control the deployment of the test pod using nodeSelector:

```bash
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils2
  namespace: default
spec:
  nodeSelector:
    kubernetes.io/hostname: <NODE>
  containers:
    - name: dnsutils
      image: registry.k8s.io/e2e-test-images/agnhost:2.39
      command:
        - sleep
        - "infinity"
      imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF
```

Option 3 - If you run both Linux and Windows nodes in your cluster, you can configure the test pod to deploy to all Linux nodes.

```bash
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: dnsutils
  namespace: default
spec:
  selector:
    matchLabels:
      app: dnsutils
  template:
    metadata:
      labels:
        app: dnsutils
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
        - name: dnsutils
          image: registry.k8s.io/e2e-test-images/agnhost:2.39
          command:
            - sleep
            - "infinity"
          imagePullPolicy: IfNotPresent
EOF
```

### Enable query logging for LocalDNS

Most use cases require query logging to be turned off in production because of its high memory usage and performance implications. However, for troubleshooting purposes, you should enable query logging in your localDNS configuration to root cause the source of your errors. Once the analysis is complete, you can turn it off.

Option 1 - Enable Query logging on all nodes

You can modify your LocalDNS configuration to reflect *queryLogging: Log* for a single or multiple DNS zones.

```json
{
  "mode": "Required",
  "vnetDNSOverrides": {
    ".": {
      "queryLogging": "Log",
      "protocol": "PreferUDP",
      "forwardDestination": "VnetDNS",
      "forwardPolicy": "Sequential",
      "maxConcurrent": 1000,
      "cacheDurationInSeconds": 3600,
      "serveStaleDurationInSeconds": 3600,
      "serveStale": "Immediate"
    },
    "cluster.local": {
      "queryLogging": "Log",
      "protocol": "ForceTCP",
      "forwardDestination": "ClusterCoreDNS",
      "forwardPolicy": "Sequential",
      "maxConcurrent": 1000,
      "cacheDurationInSeconds": 3600,
      "serveStaleDurationInSeconds": 3600,
      "serveStale": "Immediate"
    }
  },
  "kubeDNSOverrides": {
    ".": {
      "queryLogging": "Log",
      "protocol": "PreferUDP",
      "forwardDestination": "ClusterCoreDNS",
      "forwardPolicy": "Sequential",
      "maxConcurrent": 1000,
      "cacheDurationInSeconds": 3600,
      "serveStaleDurationInSeconds": 3600,
      "serveStale": "Immediate"
    },
    "cluster.local": {
      "queryLogging": "Log",
      "protocol": "ForceTCP",
      "forwardDestination": "ClusterCoreDNS",
      "forwardPolicy": "Sequential",
      "maxConcurrent": 1000,
      "cacheDurationInSeconds": 3600,
      "serveStaleDurationInSeconds": 3600,
      "serveStale": "Immediate"
    }
  }
}
```

You can enable this change on the node pool by using Azure CLI.

```bash
az aks nodepool update --name mynodepool1 --cluster-name myAKSCluster --resource-group myResourceGroup --localdns-config ./localdnsconfig.json
```

Note

Making changes to the LocalDNS configuration triggers a reimage operation in the chosen node pool.

Option 2 - Enable query logging on a specific node

You can diagnose LocalDNS issues on a specific node by temporarily rewriting the LocalDNS configuration. You can [connect to the node](/en-us/azure/aks/node-access#connect-using-kubectl-debug) manually and update the core file used by LocalDNS, only restarting the specific LocalDNS service.

Note

The changes made this way are ephemeral in nature and don't persist once the troubleshooting is complete.

```bash
# You need to connect to the node before running the following commands

## open the configuration file for LocalDNS 
vi /opt/azure/containers/localdns/localdns.corefile

<Manually change errors to log for a zone or all zones>

# ***********************************************************************************
# WARNING: Changes to this file will be overwritten and not persisted.
# ***********************************************************************************
# whoami (used for health check of DNS)
health-check.localdns.local:53 {
    bind 169.254.10.10 169.254.10.11
    whoami
}
# VnetDNS overrides apply to DNS traffic from pods with dnsPolicy:default or kubelet (referred to as VnetDNS traffic).
.:53 {
    errors
    bind 169.254.10.10
    forward . 168.63.129.16 {
        policy sequential
        max_concurrent 1000
    }
    ready 169.254.10.10:8181
    cache 3600s {
        success 9984
        denial 9984
        serve_stale 3600s verify
        servfail 0
    }
    loop
    nsid localdns
    prometheus :9253
    template ANY ANY internal.cloudapp.net {
        match "^(?:[^.]+\.){4,}internal\.cloudapp\.net\.$"
        rcode NXDOMAIN
        fallthrough
    }
    template ANY ANY reddog.microsoft.com {
        rcode NXDOMAIN
    }
}
cluster.local:53 {
    errors
    bind 169.254.10.10
    forward . 10.0.0.10 {
        force_tcp
        policy sequential
        max_concurrent 1000
    }
    ready 169.254.10.10:8181
    cache 3600s {
        success 9984
        denial 9984
        serve_stale 3600s verify
        servfail 0
    }
    loop
    nsid localdns
    prometheus :9253
}
...

```

Save the changes.

Note

The excerpt earlier shows the forwarding server blocks bound to the node listener (`169.254.10.10`), which serves VnetDNS traffic. The Corefile also contains server blocks bound to the cluster listener (`169.254.10.11`), which serves KubeDNS traffic. Enable `log` on the zone and listener that matches the failure pattern you identified earlier.

Restart the LocalDNS service:

```bash
systemctl restart localdns
```

Once restarted, LocalDNS should begin collecting all logs for the chosen zones.

### Generate traffic from dnsutils pod

The next step is to trigger some DNS traffic on LocalDNS. LocalDNS has two IPs - The KubeDNS traffic goes to the ClusterListenerIP - 169.254.10.11, while VnetDNSTraffic goes to the NodeListenerIP - 169.254.10.10

#### Test KubeDNS zone traffic

```bash
kubectl exec dnsutils -- dig bing.com +ignore +noedns +search +noshowsearch +time=10 +tries=6

; <<>> DiG 9.16.27 <<>> bing.com +ignore +noedns +search +noshowsearch +time=10 +tries=6
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7452
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;bing.com.                      IN      A

;; ANSWER SECTION:
bing.com.               30      IN      A       150.171.27.10
bing.com.               30      IN      A       150.171.28.10

;; Query time: 3 msec
;; SERVER: 169.254.10.11#53(169.254.10.11)
;; WHEN: Thu Jul 03 16:57:42 UTC 2025
;; MSG SIZE  rcvd: 74
```

#### Test VnetDNS zone traffic

```bash
kubectl exec dnsutils -- dig bing.com +ignore +noedns +search +noshowsearch +time=10 +tries=6 @169.254.10.10

; <<>> DiG 9.16.27 <<>> bing.com +ignore +noedns +search +noshowsearch +time=10 +tries=6 @169.254.10.10
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3580
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;bing.com.                      IN      A

;; ANSWER SECTION:
bing.com.               1315    IN      A       150.171.28.10
bing.com.               1315    IN      A       150.171.27.10

;; Query time: 7 msec
;; SERVER: 169.254.10.10#53(169.254.10.10)
;; WHEN: Thu Jul 03 16:59:07 UTC 2025
;; MSG SIZE  rcvd: 74
```

### View LocalDNS logs collected

Lastly, you can now view the logs from your LocalDNS instances. To view the logs, you can connect to the node and run the following commands.

```bash
# view the logs for the localdns service
journalctl -u localdns

# To view logs in reverse chronological order (latest logs first)
journalctl -u localdns --reverse

# To continuously follow the logs.
journalctl -u localdns -f

# sample output using journalctl for the bing.com responses
journalctl -u localdns | grep bing.com
Jul 03 16:57:42 aks-userpool-24995383-vmss000000 localdns-coredns[2491520]: [INFO] 10.244.0.95:41796 - 7452 "A IN bing.com. udp 26 false 512" NOERROR qr,rd,ra 74 0.004490668s
Jul 03 16:59:07 aks-userpool-24995383-vmss000000 localdns-coredns[2491520]: [INFO] 10.244.0.95:58454 - 3580 "A IN bing.com. udp 26 false 512" NOERROR qr,rd,ra 74 0.001570158s
```

If you see logs for your traffic, the pod is able to reach the LocalDNS service.

## Interpret the results

Use the pattern you identified earlier together with the query logs to narrow the cause.

| Observation | Likely cause | Action |
| --- | --- | --- |
| Test pod gets no response from `169.254.10.11` (KubeDNS listener) | Pod isn't reaching LocalDNS, or LocalDNS isn't running | Confirm the service with `systemctl status localdns`. Verify the pod `/etc/resolv.conf` points to the cluster DNS service IP. |
| `cluster.local` names fail but external names resolve | Cache-miss forwarding to CoreDNS is failing | The `cluster.local` block forwards to CoreDNS with `force_tcp`. Confirm NSGs and firewalls allow **TCP** 53 from the node to the cluster DNS service IP, not only UDP 53 |
| External names fail but `cluster.local` resolves | Upstream (VnetDNS) forwarding is failing | Check the `.:53` block upstream target and node-to-upstream reachability on UDP/TCP 53. |
| Private DNS zone names return public IPs or `NXDOMAIN` | LocalDNS is forwarding to Azure DNS instead of your custom DNS | See LocalDNS restarts and custom DNS. |
| Intermittent failures correlated with LocalDNS restarts | Service restart behavior | See LocalDNS restarts and custom DNS. |
| Failures on one node only | Node-local service or network issue | Restart `localdns` on that node and retest. If it persists, collect node logs. |

### LocalDNS restarts and custom DNS

In environments that use custom VNet DNS (for example, hub-and-spoke topologies with private DNS zones), confirm that LocalDNS detected the correct upstream DNS servers after it started. On the affected node:

```bash
journalctl -u localdns | grep -i "upstream VNET DNS servers"
```

If the detected upstream shows the LocalDNS listener IP (`169.254.10.10`) instead of your custom DNS server IPs, LocalDNS didn't pick up the custom upstream, and private DNS zone resolution can fail. Perform a graceful restart so the service re-detects the correct upstream:

```bash

systemctl restart localdns.service

```

Then rerun the upstream check to confirm your custom DNS server IPs are listed.

To reduce the chance of recurrence, keep node images current.