---
layout: Conceptual
title: Configure Container network metrics filtering for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/how-to-configure-container-network-metrics-filtering
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
description: Learn how to configure container network metrics filtering to optimize data collection and reduce storage costs in Azure Kubernetes Service (AKS) with Cilium.
author: Khushbu-Parekh
ms.author: kparekh
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2025-10-30T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: 2f94fb84-8a5e-c335-8640-1ca2c387d787
document_version_independent_id: 5489ae09-5de4-483a-76ee-8e436cbda149
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/how-to-configure-container-network-metrics-filtering.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/how-to-configure-container-network-metrics-filtering
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/how-to-configure-container-network-metrics-filtering.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c8256b70-79d6-7c53-c34c-cb7cb34c186f
---

# Configure Container network metrics filtering for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to configure container network metrics filtering for Azure Kubernetes Service (AKS) with Cilium to optimize data collection, reduce storage costs, and focus on the metrics most relevant to your monitoring needs.

Configure container network metrics filtering enables dynamic management of Hubble metrics cardinality through Kubernetes Custom Resource Definitions (CRDs). This feature allows you to dynamically control the cardinality, dimensions, and targets of Hubble metrics without restarting Cilium agents or Prometheus servers.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- The minimum version of the Azure CLI required to complete the steps in this article is **2.85.0**. To find your version, run `az --version` in the Azure CLI. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- An AKS cluster with Cilium data plane and [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.
- Kubernetes version 1.32 or later.
- Container network metrics filtering works specifically with Cilium data planes.
- The minimum version of the `aks-preview` Azure CLI extension to complete the steps in this article is `20.0.0b4`.

### Install the aks-preview Azure CLI extension

Install or update the Azure CLI preview extension by using the [`az extension add`](/en-us/cli/azure/extension#az_extension_add) or [`az extension update`](/en-us/cli/azure/extension#az_extension_update) command.

```azurecli
# Install the aks-preview extension
az extension add --name aks-preview
# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
```

### Create a new AKS cluster with Cilium

If you already have an existing cluster, you can skip this step.

Use the `az aks create` command with the `--enable-acns` flag to create a new AKS cluster that has all Advanced Container Networking Services features. These features include:

- **Container Network Observability:** Provides insight into your network traffic. To learn more, see [Container Network Observability](advanced-container-networking-services-overview#container-network-observability).
- **Container Network Security:** Offers security features like FQDN filtering. To learn more, see [Container Network Security](advanced-container-networking-services-overview#container-network-security).

```azurecli
# Set environment variables
export RESOURCE_GROUP="cnm-testing-rg"
export CLUSTER_NAME="cnm-cilium-cluster"
export LOCATION="eastus2euap"  # Use canary region for preview features

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster with Cilium and ACNS enabled
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --location $LOCATION \
    --network-plugin azure \
    --network-dataplane cilium \
    --enable-acns \
    --enable-managed-identity \
    --generate-ssh-keys \
    --kubernetes-version 1.33
```

### Get cluster credentials

Get your cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command:

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing
```

## Configure custom resources for metrics filtering

Container network metrics filtering uses the `ContainerNetworkMetric` Custom Resource Definition (CRD) to define filtering rules. Only one CRD can exist per cluster, and changes take approximately 30 seconds to reconcile. If the CRD is not applied, all metrics will be collected.

```azurecli
apiVersion: acn.azure.com/v1alpha1
kind: ContainerNetworkMetric
metadata:
  name: : container-network-metric # Cluster scoped
spec:
  filters:
  - metric: flow
    includeFilters: # List of include filters
      - name: sample-filter # Filter name
        from:
          namespacedPod: # List of source namespace/pods. Prepend namespace with /
            - sample-namespace/sample-pod
          labelSelector: # Standard k8s label selector
            matchLabels:
              app: frontend
              k8s.io/namespace: sample-namespace
            matchExpressions:
              - key: environment
                operator: In
                values:
                  - production
                  - staging
          ip: # List of source IPs; can be CIDR
            - "192.168.1.10"
            - "10.0.0.1"
        to:
          namespacedPod:
            - sample-namespace2/sample-pod2
          labelSelector:
            matchLabels:
              app: backend
              k8s.io/namespace: sample-namespace2
            matchExpressions:
              - key: tier
                operator: NotIn
                values:
                  - dev
          ip:
            - "192.168.1.20"
            - "10.0.1.1"
        protocol: # List of protocols; can be tcp, udp, dns
          - tcp
          - udp
          - dns
        verdict: # List of verdicts; can be forwarded, dropped
          - forwarded
          - dropped
    metric: dns
    excludeFilters: # List of exclude filters
      - name: sample-filter # Filter name
        from:
          namespacedPod: # List of source namespace/pods. Prepend namespace with /
            - sample-namespace/sample-pod
          labelSelector: # Standard k8s label selector
            matchLabels:
              app: frontend
              k8s.io/namespace: sample-namespace
```

The following table describes the fields in the custom resource definition:

| Field | Type | Description | Required |
| --- | --- | --- | --- |
| `filters.metric` | String | Name of the metric you would like to apply the filter on. This is mandatory. The supported values are `dns`, `flow`, `tcp`, `drop` | Mandatory |
| `includeFilters` or `excludeFilters` | []filter | A list of filters that define network flows to include. Each filter specifies the source, destination, protocol, and other matching criteria. You must have at least one include or exclude filter. | Mandatory |
| `filters.name` | String | The name of the filter. | Optional |
| `filters.protocol` | []string | The protocols to match for this filter. Valid values are `tcp`, `udp`, and `dns`. Because it's an optional parameter, if it isn't specified, logs with all protocols are included. | Optional |
| `filters.verdict` | []string | The verdict of the flow to match. Valid values are `forwarded` and `dropped`. Because it's an optional parameter, if it isn't specified, logs with all verdicts are included. | Optional |
| `filters.from` | Endpoint | Specifies the source of the network flow. Can include IP addresses, label selectors, and namespace/pod pairs. | Optional |
| `Endpoint.ip` | []string | It can be a single IP or a CIDR. | Optional |
| `Endpoint.labelSelector` | Object | A label selector is a mechanism to filter and query resources based on labels, so you can identify specific subsets of resources. A label selector can include two components: `matchLabels` and `matchExpressions`. Use `matchLabels` for straightforward matching by specifying a key/value pair (for example, `{"app": "frontend"}`). For more advanced criteria, use `matchExpressions`, where you define a label key, an operator (such as `In`, `NotIn`, `Exists`, or `DoesNotExist`), and an optional list of values. Ensure that the conditions in both `matchLabels` and `matchExpressions` are met, because they're logically combined by `AND`. If no conditions are specified, the selector matches all resources. To match none, leave the selector null. Carefully define your label selector to target the correct set of resources. | Optional |
| `Endpoint.namespacedPod` | []string | A list of namespace and pod pairs (formatted as `namespace/pod`) for matching the source. `name` should match the RegEx pattern `^.+$`. | Optional |
| `filters.to` | Endpoint | Specifies the destination of the network flow. Can include IP addresses, label selectors, or namespace/pod pairs. | Optional |
| `Endpoint.ip` | []string | It can be a single IP or a CIDR. | Optional |
| `Endpoint.labelSelector` | Object | A label selector to match resources based on their labels. | Optional |
| `Endpoint.namespacedPod` | []string | A list of namespace and pod pairs (formatted as `namespace/pod`) to match the destination. | Optional |

Apply the `ContainerNetworkMetric` custom resource to enable log collection at the cluster:

```azurecli
kubectl apply -f <crd.yaml>
```

## Clean up and reset

To clean up filtering configuration:

```azurecli
# Delete the CRD
kubectl delete ContainerNetworkMetric container-network-metric
```

## Example filtering configuration

1. Create a basic filtering configuration that focuses on DNS metrics:

```yaml
# basic-dns-filter.yaml
apiVersion: acn.azure.com/v1alpha1
kind: ContainerNetworkMetric
metadata:
  name: container-network-metric
spec:
  filters:
    - metric: dns  # Supported: dns, flow, tcp, drop
      excludeFilters:
        - from:
            namespacedPod: ["kube-system/coredns"]
```

1. Configure filtering for TCP metrics with include and exclude filters:

```yaml
# tcp-metrics-filter.yaml
apiVersion: acn.azure.com/v1alpha1
kind: ContainerNetworkMetric
metadata:
  name: container-network-metric
spec:
  filters:
    - metric: tcp
      includeFilters:
          - from:
            labelSelector:
              matchLabels:
                tier: "frontend"
      excludeFilters:
        - to:
            namespacedPod: ["kube-system/metrics-server"]
```

1. Configure filtering for network flow metrics:

```yaml
# flow-metrics-filter.yaml
apiVersion: acn.azure.com/v1alpha1
kind: ContainerNetworkMetric
metadata:
  name: container-network-metric
spec:
  filters:
    - metric: flow
      includeFilters:
        - from:
            labelSelector:
              matchLabels:
                tier: "frontend"
        - to:
            labelSelector:
              matchLabels:
                tier: "backend"
      excludeFilters:
        - from:
            namespacedPod: ["default/test"]
```

1. Configure filtering for dropped packet metrics:

```yaml
# drop-metrics-filter.yaml
apiVersion: acn.azure.com/v1alpha1
kind: ContainerNetworkMetric
metadata:
  name: container-network-metric
spec:
  filters:
    - metric: drop
      excludeFilters:
        - from:
            namespacedPod: ["kube-system/"]
```

1. Configure filtering for multiple metric types in a single CRD:

```yaml
# multi-metrics-filter.yaml
apiVersion: acn.azure.com/v1alpha1
kind: ContainerNetworkMetric
metadata:
  name: container-network-metric
spec:
  filters:
    - metric: dns
      includeFilters:
        - protocol: ["dns"]
      excludeFilters:
        - from:
            namespacedPod: ["kube-system/*"]
    - metric: tcp
      includeFilters:
        - protocol: ["tcp"]
        - from:
            labelSelector:
              matchLabels:
                environment: "production"
    - metric: flow
      excludeFilters:
        - from:
            namespacedPod: ["default/debug-*"]
    - metric: drop
      includeFilters:
        - reason: ["Policy denied", "Invalid"]
```

## Best practices

- Ensure you do not have conflicting include and exclude filter on the CRD.
- Leverage Kubernetes label selectors for flexible filtering.
- Always validate filtering configurations in development or staging
- Regularly review filtered metrics to ensure important data isn't lost.
- Remember that only one CRD can exist per cluster.

## Troubleshooting

### Common issues

**Issue**: CRD configuration not applied

**Solution**: Check that the feature flag is registered and only one CRD exists:

```azurecli
# Verify feature registration
az feature show --namespace "Microsoft.ContainerService" --name "AdvancedNetworkingDynamicMetricsPreview"

# Check existing CRDs
kubectl get ContainerNetworkMetric
```

**Issue**: Metrics still showing after applying excludeFilters

**Solution**: Remember that preexisting metrics persist in Prometheus. You may need to wait for new metrics to be generated to see the filtering effects.

## Limitations

- This feature is specifically designed for Cilium data planes only
- Only one `ContainerNetworkMetric` CRD can exist per cluster
- Preexisting metrics persist in Prometheus; new filtering rules apply to newly generated metrics
- Requires Kubernetes version 1.32 or later