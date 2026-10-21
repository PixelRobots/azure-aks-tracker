---
layout: Conceptual
title: Set up FQDN filtering feature for Container Network Security in Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/how-to-apply-fqdn-filtering-policies
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
description: Get started with FQDN Filtering Feature for Advanced Container Networking Services (ACNS) for your AKS cluster using Azure managed Cilium Network Policies.
author: sf-msft
ms.author: samfoo
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2024-07-30T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: 0752e1f4-98aa-1f76-afd4-231677bcde6a
document_version_independent_id: 9791e238-71d5-592e-a001-cf180bf5df77
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/how-to-apply-fqdn-filtering-policies.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/how-to-apply-fqdn-filtering-policies
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/how-to-apply-fqdn-filtering-policies.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3d8845ac-127a-a6f6-4187-3abf5234aa98
---

# Set up FQDN filtering feature for Container Network Security in Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to set up Advanced Container Networking Services with Container Network Security feature in AKS clusters.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

The minimum version of Azure CLI required for the steps in this article is 2.71.0. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Limitations:

- Kubernetes service names aren't supported.
- FQDN pods might exhibit performance degradation when handling more than 1,000 requests per second.
- If Advanced Container Networking Services(ACNS) security is disabled, FQDN and L7 policies (HTTP, HTTPS, Kafka, and gRPC) will be blocked.
- Alpine-based container images might encounter DNS resolution issues when used with Cilium Network Policies. This is due to musl libc's limited search domain iteration. To work around this, explicitly define all search domains in the Network Policy's DNS rules using wildcard patterns, like the below example

```yml
rules:
  dns:
  - matchPattern: "*.example.com"
  - matchPattern: "*.example.com.*.*"
  - matchPattern: "*.example.com.*.*.*"
  - matchPattern: "*.example.com.*.*.*.*"
  - matchPattern: "*.example.com.*.*.*.*.*"
- toFQDNs:
  - matchPattern: "*.example.com"
```

### Enable Advanced Container Networking Services

To proceed, you must have an AKS cluster with [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.

The `az aks create` command with the Advanced Container Networking Services flag, `--enable-acns`, creates a new AKS cluster with all Advanced Container Networking Services features. These features encompass:

- **Container Network Observability:** Provides insights into your network traffic. To learn more visit [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability).
- **Container Network Security:** Offers security features like Fully Qualified Domain Name (FQDN) filtering. To learn more visit [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security).

# [Cilium](#tab/cilium)
```azurecli
# Set an environment variable for the AKS cluster name. Make sure to replace the placeholder with your own value.
export CLUSTER_NAME="<aks-cluster-name>"

# Create an AKS cluster
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --generate-ssh-keys \
    --location eastus \
    --network-plugin azure \
    --network-dataplane cilium \
    --node-count 2 \
    --enable-acns
```

# [Non-Cilium](#tab/non-cilium)
Note

[FQDN filtering](container-network-security-fqdn-filtering-concepts) feature isn't available for Non-cilium clusters

---

### Enable Advanced Container Networking Services on an existing cluster

The [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the Advanced Container Networking Services flag, `--enable-acns`, updates an existing AKS cluster with all Advanced Container Networking Services features which includes [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability) and the [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security) feature

Note

Only clusters with the Cilium data plane support Container Network Security features of Advanced Container Networking Services.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns
```

## Get cluster credentials

Get your cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

## Test connectivity with a policy

This section demonstrates how to observe a policy being enforced through the Cilium Agent. A DNS request is made to an allowed FQDN and another case where it's blocked.

Create a file named `demo-policy.yaml` and paste the following YAML manifest:

Note

The field `spec.egress.toPorts.rules.dns.matchPattern` is **mandatory** when using to FQDNs in a policy. This section tells Cilium to inspect DNS queries and match them against specified patterns. Without this section, Cilium only allows the DNS traffic and not inspect its contents to learn which IPs are associated with the FQDNs. As a result, connections to those IPs (i.e., non-DNS traffic) are blocked because Cilium can't associate them with the allowed domain.

Make sure to check the limitations section first.

```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "allow-bing-fqdn"
spec:
  endpointSelector:
    matchLabels:
      app: demo-container
  egress:
    - toEndpoints:
      - matchLabels:
          "k8s:io.kubernetes.pod.namespace": kube-system
          "k8s:k8s-app": kube-dns
      toPorts:
        - ports:
           - port: "53"
             protocol: ANY
          rules:
            dns:
              - matchPattern: "*.bing.com"
    - toFQDNs:
      - matchPattern: "*.bing.com"
```

Specify the name of your YAML manifest and apply it by using [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply):

```console
kubectl create ns demo
kubectl apply -f demo-policy.yaml -n demo
```

### Create a demo pod

Create a `client` pod running Bash:

```bash
kubectl run -it client -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.43 --labels="app=demo-container" --command -- bash
```

A shell with utilities for testing FQDN should open with the following output:

```output
If you don't see a command prompt, try pressing enter.
bash-5.0#
```

In a separate window, run the following command to get the node of the running pod.

```bash
kubectl get po -n demo --sort-by="{spec.nodeName}" -o wide
```

The output should look similar to the following example:

```output
NAME     READY   STATUS    RESTARTS   AGE     IP              NODE                                NOMINATED NODE   READINESS GATES
client   1/1     Running   0          5m50s   192.168.0.139   aks-nodepool1-22058664-vmss000001   <none>           <none>
```

The pod is running on a node named `aks-nodepool1-22058664-vmss000001`. Obtain the Cilium Agent instance running on that node:

```bash
kubectl get po -n kube-system -o wide --field-selector spec.nodeName="aks-nodepool1-22058664-vmss000001" | grep "cilium"
```

The expected `cilium-s4x24` should be in the output.

```output
cilium-s4x24                          1/1     Running   0          47m   10.224.0.4      aks-nodepool1-22058664-vmss000001   <none>           <none>
```

### Inspect a Cilium Agent

Use the `cilium` CLI to monitor traffic being blocked.

```bash
kubectl exec -it -n kube-system cilium-s4x24 -- sh
```

```output
Defaulted container "cilium-agent" out of: cilium-agent, install-cni-binaries (init), mount-cgroup (init), apply-sysctl-overwrites (init), mount-bpf-fs (init), clean-cilium-state (init), block-wireserver (init)
#
```

Inside this shell, run `cilium monitor -t drop`:

```output
Listening for events on 2 CPUs with 64x4096 of shared memory
Press Ctrl-C to quit
time="2024-10-08T17:48:27Z" level=info msg="Initializing dissection cache..." subsys=monitor
```

### Verify policy

From the first shell, create a request to the allowed FQDN, `*.bing.com`, as specified by the policy. This request should succeed and allowed by the agent.

```bash
./agnhost connect www.bing.com:80
```

Then create another request to an FQDN expected to be blocked:

```bash
./agnhost connect www.example.com:80
```

Cilium Agent blocked the request with the output:

```output
xx drop (Policy denied) flow 0xfddd76f6 to endpoint 0, ifindex 29, file bpf_lxc.c:1274, , identity 48447->world: 192.168.0.149:45830 -> 93.184.215.14:80 tcp SYN
```

### Supported by CiliumClusterwideNetworkPolicy(CCNP)

`CiliumClusterwideNetworkPolicy` supports FQDN filtering.

Note

[Namespace specific information](https://docs.cilium.io/en/latest/security/policy/kubernetes/#namespace-specific-information) such as `io.kubernetes.pod.namespace` is only supported in cluster-wide policies.

```
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: allow-bing-fqdn
spec:
  endpointSelector: {} # Applies to all pods in the cluster
  egress:
    - toEndpoints:
      - matchLabels:
          "k8s:io.kubernetes.pod.namespace": kube-system
          "k8s:k8s-app": kube-dns
      toPorts:
        - ports:
           - port: "53"
             protocol: ANY
          rules:
            dns:
              - matchPattern: "*.bing.com"
    - toFQDNs:
      - matchPattern: "*.bing.com"
```

## Clean up resources

If you don't plan on using this application, delete the other resources you created in this article using the [`az group delete`](/en-us/cli/azure/#az-group-delete) command.

```azurecli
  az group delete --name $RESOURCE_GROUP
```