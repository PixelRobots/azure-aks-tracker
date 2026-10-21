---
layout: Conceptual
title: Set up Container Network Observability for Azure Kubernetes Service (AKS) - Azure managed Prometheus and Grafana - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/container-network-observability-how-to
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
description: Get started with Container Network Observability for your AKS cluster using Azure managed Prometheus and Grafana.
author: Khushbu-Parekh
ms.author: kparekh
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2024-05-10T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: a49be392-8fe4-c717-c07a-34dfe3ca8834
document_version_independent_id: d13222b2-4f67-0cf6-25df-42a6c9cc1195
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/container-network-observability-how-to.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/container-network-observability-how-to
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/container-network-observability-how-to.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: e732439b-307c-de0b-bf7f-bd8cf3ddd2f4
---

# Set up Container Network Observability for Azure Kubernetes Service (AKS) - Azure managed Prometheus and Grafana - Azure Kubernetes Service | Microsoft Learn

This article shows you how to set up Container Network Observability for Azure Kubernetes Service (AKS) using Managed Prometheus and Grafana and BYO Prometheus and Grafana and to visualize the scraped metrics

You can use Container Network Observability to collect data about the network traffic of your AKS clusters. It enables a centralized platform for monitoring application and network health. Currently, metrics are stored in Prometheus and Grafana can be used to visualize them. Container Network Observability also offers the ability to enable Hubble. These capabilities are supported for both Cilium and non-Cilium clusters.

Container Network Observability is one of the features of Advanced Container Networking Services. For more information about Advanced Container Networking Services for Azure Kubernetes Service (AKS), see [What is Advanced Container Networking Services for Azure Kubernetes Service (AKS)?](advanced-container-networking-services-overview)

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- The minimum version of Azure CLI required for the steps in this article is 2.56.0. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

### Enable Advanced Container Networking Services

To proceed, you must have an AKS cluster with [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.

The `az aks create` command with the Advanced Container Networking Services flag, `--enable-acns`, creates a new AKS cluster with all Advanced Container Networking Services features. These features encompass:

- **Container Network Observability:** Provides insights into your network traffic. To learn more visit [Container Network Observability](advanced-container-networking-services-overview#container-network-observability).
- **Container Network Security:** Offers security features like FQDN filtering. To learn more visit [Container Network Security](advanced-container-networking-services-overview#container-network-security).

# [Cilium](#tab/cilium)
Note

Clusters with the Cilium data plane support Container Network Observability and Container Network security starting with Kubernetes version 1.29.

```azurecli
# Set an environment variable for the AKS cluster name. Make sure to replace the placeholder with your own value.
export CLUSTER_NAME="<aks-cluster-name>"

# Create an AKS cluster
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --generate-ssh-keys \
    --location eastus \
    --max-pods 250 \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --network-dataplane cilium \
    --node-count 2 \
    --pod-cidr 192.168.0.0/16 \
    --kubernetes-version 1.29 \
    --enable-acns
```

# [Non-Cilium](#tab/non-cilium)
Note

[Container Network Security](advanced-container-networking-services-overview#container-network-security) feature isn't available for clusters that do not use the Cilium data plane.

When you use Advanced Container Networking Services (ACNS) on non-Cilium data planes, FIPS support isn't available on Ubuntu 20.04 nodes due to kernel restrictions. To enable FIPS in this scenario, you must use an Ubuntu 22.04 node pool or an Azure Linux node pool. Refer to the FIPS support matrix in the following table:

> 
> 
> | Operating System | FIPS Support |
> | --- | --- |
> | Azure Linux 3.0 | Yes |
> | Azure Linux 2.0 | Yes |
> | Ubuntu 20.04 | No |
> | Ubuntu 22.04 | Yes |
> 

```azurecli
# Set an environment variable for the AKS cluster name. Make sure to replace the placeholder with your own value.
export CLUSTER_NAME="<aks-cluster-name>"

# Create an AKS cluster
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --generate-ssh-keys \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --pod-cidr 192.168.0.0/16 \
    --enable-acns
```

---

### Enable Advanced Container Networking Services on an existing cluster

The [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the Advanced Container Networking Services flag, `--enable-acns`, updates an existing AKS cluster with all Advanced Container Networking Services features that includes [Container Network Observability](advanced-container-networking-services-overview#container-network-observability) and the [Container Network Security](advanced-container-networking-services-overview#container-network-security) feature.

Note

Only clusters with the Cilium data plane support Container Network Security features of Advanced Container Networking Services.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns
```

## Get cluster credentials

Once you have Get your cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

## Azure managed Prometheus and Grafana

Skip this Section if using BYO Prometheus and Grafana

Use the following example to install and enable Prometheus and Grafana for your AKS cluster.

### Create Azure Monitor resource

```azurecli
#Set an environment variable for the Grafana name. Make sure to replace the placeholder with your own value.
export AZURE_MONITOR_NAME="<azure-monitor-name>"

# Create Azure monitor resource
az resource create \
    --resource-group $RESOURCE_GROUP \
    --namespace microsoft.monitor \
    --resource-type accounts \
    --name $AZURE_MONITOR_NAME \
    --location eastus \
    --properties '{}'
```

### Create Azure Managed Grafana instance

Use [az grafana create](/en-us/cli/azure/grafana#az-grafana-create) to create a Grafana instance. The name of the Grafana instance must be unique.

```azurecli
# Set an environment variable for the Grafana name. Make sure to replace the placeholder with your own value.
export GRAFANA_NAME="<grafana-name>"

# Create Grafana instance
az grafana create \
    --name $GRAFANA_NAME \
    --resource-group $RESOURCE_GROUP 
```

### Place the Azure Managed Grafana and Azure Monitor resource IDs in variables

Use [az grafana show](/en-us/cli/azure/grafana#az-grafana-show) to place the Grafana resource ID in a variable. Use [az resource show](/en-us/cli/azure/resource#az-resource-show) to place the Azure Monitor resource ID in a variable. Replace **myGrafana** with the name of your Grafana instance.

```azurecli
grafanaId=$(az grafana show \
                --name $GRAFANA_NAME \
                --resource-group $RESOURCE_GROUP \
                --query id \
                --output tsv)
azuremonitorId=$(az resource show \
                    --resource-group $RESOURCE_GROUP \
                    --name $AZURE_MONITOR_NAME \
                    --resource-type "Microsoft.Monitor/accounts" \
                    --query id \
                    --output tsv)
```

### Link Azure Monitor and Azure Managed Grafana to the AKS cluster

Use [az aks update](/en-us/cli/azure/aks#az-aks-update) to link the Azure Monitor and Grafana resources to your AKS cluster.

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --enable-azure-monitor-metrics \
    --azure-monitor-workspace-resource-id $azuremonitorId \
    --grafana-resource-id $grafanaId
```

## Visualization

### Visualization using Azure Managed Grafana

Skip this step if using BYO Grafana

Note

The `hubble_flows_processed_total` metric isn't scraped by default due to high metric cardinality in large scale clusters. Because of this, the *Pods Flows* dashboards have panels with missing data. To enable this metric and populate the missing data, you need to modify the ama-metrics-settings-configmap. Specifically, update the default-targets-metrics-keep-list section. Follow the below steps to update the configmap:

1. Get the latest ama-metrics-settings-configmap.(https://github.com/Azure/prometheus-collector/blob/main/otelcollector/configmaps/ama-metrics-settings-configmap.yaml)
2. Locate the networkobservabilityHubble = ""
3. Change it to networkobservabilityHubble = "hubble.\*"
4. Now the Pod flow metrics should populate.

To learn more about what minimal ingestion, see the [Minimal Ingestion Documentation](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-configuration-minimal).

1. Make sure the Azure Monitor pods are running using the `kubectl get pods` command.

    ```azurecli
    kubectl get pods -o wide -n kube-system | grep ama-
    ```

    Your output should look similar to the following example output:

    ```output
    ama-metrics-5bc6c6d948-zkgc9          2/2     Running   0 (21h ago)   26h
    ama-metrics-ksm-556d86b5dc-2ndkv      1/1     Running   0 (26h ago)   26h
    ama-metrics-node-lbwcj                2/2     Running   0 (21h ago)   26h
    ama-metrics-node-rzkzn                2/2     Running   0 (21h ago)   26h
    ama-metrics-win-node-gqnkw            2/2     Running   0 (26h ago)   26h
    ama-metrics-win-node-tkrm8            2/2     Running   0 (26h ago)   26h
    ```
2. We have created sample dashboards. They can be found under the **Dashboards &gt; Azure Managed Prometheus** folder. They have names like **"Kubernetes / Networking / `<name>`"**. The suite of dashboards includes:

    - **Clusters:** shows Node-level metrics for your clusters.
    - **DNS (Cluster):** shows DNS metrics on a cluster or selection of Nodes.
    - **DNS (Workload):** shows DNS metrics for the specified workload (for example, Pods of a DaemonSet or Deployment such as CoreDNS).
    - **Drops (Workload):** shows drops to/from the specified workload (for example, Pods of a Deployment or DaemonSet).
    - **Pod Flows (Namespace):** shows L4/L7 packet flows to/from the specified namespace (i.e. Pods in the Namespace).
    - **Pod Flows (Workload):** shows L4/L7 packet flows to/from the specified workload (for example, Pods of a Deployment or DaemonSet).

### Visualization using BYO Grafana

Skip this step if using Azure managed Grafana

1. Add the following scrape job to your existing Prometheus configuration and restart your Prometheus server:

    ```yml
    - job_name: networkobservability-hubble
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        - target_label: cluster
          replacement: myAKSCluster
          action: replace
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_pod_label_k8s_app]
          regex: kube-system;(retina|cilium)
          action: keep
        - source_labels: [__address__]
          action: replace
          regex: ([^:]+)(?::\d+)?
          replacement: $1:9965
          target_label: __address__
        - source_labels: [__meta_kubernetes_pod_node_name]
          target_label: instance
          action: replace
      metric_relabel_configs:
        - source_labels: [__name__]
          regex: '|hubble_dns_queries_total|hubble_dns_responses_total|hubble_drop_total|hubble_tcp_flags_total' # if desired, add |hubble_flows_processed_total
          action: keep
    ```
2. In **Targets** of Prometheus, verify the **network-obs-pods** are present.
3. Sign in to Grafana and import following example dashboards using the following IDs:

    - **Clusters:** shows Node-level metrics for your clusters. (ID: [18814](https://grafana.com/grafana/dashboards/18814-kubernetes-networking-clusters/))
    - **DNS (Cluster):** shows DNS metrics on a cluster or selection of Nodes.(ID: [20925](https://grafana.com/grafana/dashboards/20925-kubernetes-networking-dns-cluster/))
    - **DNS (Workload):** shows DNS metrics for the specified workload (for example, Pods of a DaemonSet or Deployment such as CoreDNS). (ID: [20926] https://grafana.com/grafana/dashboards/20926-kubernetes-networking-dns-workload/)
    - **Drops (Workload):** shows drops to/from the specified workload (for example, Pods of a Deployment or DaemonSet).(ID: [20927](https://grafana.com/grafana/dashboards/20927-kubernetes-networking-drops-workload/)).
    - **Pod Flows (Namespace):** shows L4/L7 packet flows to/from the specified namespace (i.e. Pods in the Namespace). (ID: [20928](https://grafana.com/grafana/dashboards/20928-kubernetes-networking-pod-flows-namespace/))
    - **Pod Flows (Workload):** shows L4/L7 packet flows to/from the specified workload (for example, Pods of a Deployment or DaemonSet). (ID: [20929](https://grafana.com/grafana/dashboards/20929-kubernetes-networking-pod-flows-workload/))

## Clean up resources

If you don't plan on using this application, delete the other resources you created in this article using the [`az group delete`](/en-us/cli/azure/#az-group-delete) command.

```azurecli
  az group delete --name $RESOURCE_GROUP
```