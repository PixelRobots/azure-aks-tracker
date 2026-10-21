---
layout: Conceptual
title: Set up GPU profiling on Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/gpu-profiling
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
description: Learn how to set up GPU memory profiling with Inspektor Gadget, Pyroscope, Azure Managed Grafana, and Azure Monitor managed service for Prometheus on AKS.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2026-08-25T00:00:00.0000000Z
author: mayasingh17
ms.author: mayasingh
ai-usage: ai-assisted
locale: en-us
document_id: 5fc9ca92-ec6c-7bc7-d1b2-17a8cdc7a6c5
document_version_independent_id: 44701c28-0fa5-0102-5200-65f981b83e6a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/gpu-profiling.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/gpu-profiling
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/gpu-profiling.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 97f20339-46a7-4121-8706-5bdfcd223ff1
---

# Set up GPU profiling on Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn

GPU-based workloads, such as AI inference services, can be memory intensive and difficult to optimize without visibility into GPU activity. You might see out-of-memory (OOM) errors, unexpected latency spikes, or rising GPU memory pressure, but traditional Kubernetes metrics don't show where the code allocates memory. GPU profiling helps you identify the functions responsible for GPU memory use.

This article shows you how to deploy an eBPF-based GPU observability agent, store profiles in Pyroscope, and visualize GPU memory allocations in Grafana.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Prerequisites

- An AKS cluster with at least one GPU-enabled node pool.
- [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.72.0 or later. Run `az --version` to check your version.
- The `k8s-extension` Azure CLI extension. Run `az extension add --name k8s-extension` to install it.
- [Helm](https://helm.sh/docs/intro/install/) version 3.x or later. Run `helm version` to check your version.
- Azure Monitor, unless you use your own monitoring setup.
- Azure Managed Grafana, unless you use your own Grafana instance.

## Step 1: Enable GPU profiling via the Inspektor Gadget extension

[Inspektor Gadget](https://inspektor-gadget.io/) is an open-source eBPF-based observability framework for Kubernetes. For GPU profiling, it traces Compute Unified Device Architecture (CUDA) memory allocation calls without code changes, sidecars, or pod restarts.

Enable GPU profiling on your AKS cluster:

Note

This command assumes that you enabled Azure Monitor on your AKS cluster. If you use your own Prometheus setup, remove `--configuration-settings azureMonitor.enabled=true`. For more information, see the [GPU profiling FAQ](gpu-profiling-faq).

```azurecli
az k8s-extension create \
  --extension-type microsoft.inspektorgadget \
  --subscription <your-subscription-id> \
  --resource-group <your-resource-group> \
  --cluster-name <your-cluster-name> \
  --cluster-type managedClusters \
  --release-train preview \
  --name inspektor-gadget \
  --configuration-settings gpuObservability.enabled=true \
  --configuration-settings azureMonitor.enabled=true
```

Verify that the Inspektor Gadget pods are running:

```bash
kubectl get pods -n gadget -l k8s-app=gadget
```

Tip

GPU memory profiling captures memory allocation events as they occur. If your workload allocates GPU memory before you enable profiling, the profiler doesn't capture those events. For workloads such as vLLM that preallocate GPU memory during startup, enable profiling before you deploy the workload, or restart the workload to capture the initial memory allocation paths.

## Step 2: Enable profile visualization with Pyroscope

Note

If you have an existing Grafana and Pyroscope stack in your cluster, skip this step.

[Pyroscope](https://pyroscope.io/) is an open-source project that visualizes and stores performance profiles for memory optimization and troubleshooting.

Deploy a single [Pyroscope instance](https://grafana.com/docs/pyroscope/latest/deploy-kubernetes/helm/) to your cluster:

```bash
helm install pyroscope -n gadget \
  oci://ghcr.io/grafana/helm-charts/pyroscope \
  --version 1.15.0 \
  --set pyroscope.image.repository=grafana/pyroscope \
  --set-string pyroscope.image.tag=1.15.0 \
  --set pyroscope.replicaCount=1 \
  --set pyroscope.structuredConfig.self_profiling.disable_push=true \
  --set pyroscope.structuredConfig.storage.backend=filesystem \
  --set pyroscope.service.type=LoadBalancer \
  --set pyroscope.service.port=4040 \
  --set-string pyroscope.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"=true \
  --set-string pyroscope.service.annotations."service\.beta\.kubernetes\.io/azure-pls-create"=true \
  --set-string pyroscope.service.annotations."service\.beta\.kubernetes\.io/azure-pls-name"=pyroscope-pls \
  --set-string pyroscope.service.annotations."service\.beta\.kubernetes\.io/azure-pls-proxy-protocol"=false \
  --set-string pyroscope.service.annotations."service\.beta\.kubernetes\.io/azure-pls-visibility"='*' \
  --set alloy.enabled=false \
  --set minio.enabled=false
```

Verify that the Pyroscope pod is running:

```bash
kubectl get pods -n gadget pyroscope-0
```

Note

For a highly available deployment, see the [Pyroscope microservices documentation](https://grafana.com/docs/pyroscope/latest/reference-pyroscope-architecture/deployment-modes/#microservices-mode).

Note

This command stores profiles on the local filesystem, so profiling data is lost if the pod is recreated. To persist profiles across pod restarts, see the [GPU profiling FAQ](gpu-profiling-faq).

## Step 3: Connect Pyroscope to Azure Managed Grafana

Note

If you use your own Grafana instance, see the [GPU profiling FAQ](gpu-profiling-faq).

Tip

To view workload profiles directly in the Pyroscope UI, run `kubectl port-forward -n gadget pyroscope-0 4040:4040`.

Connect Pyroscope to Azure Managed Grafana through [Azure Private Link](/en-us/azure/private-link/private-link-service-overview).

Set the cluster and Grafana environment variables:

```bash
export RESOURCE_GROUP="<your-resource-group>"
export AKS_CLUSTER="<your-aks-cluster-name>"
export LOCATION="<your-aks-cluster-location>"
export GRAFANA_NAME="<your-azure-managed-grafana-name>"
export AKS_NODE_RG=$(az aks show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER" \
  --query 'nodeResourceGroup' \
  --output tsv)
```

Tip

If you don't have an Azure Managed Grafana instance, run `az grafana create --name "$GRAFANA_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --output none`.

Set the private endpoint environment variables:

```bash
export PYROSCOPE_PLS="pyroscope-pls"
export PYROSCOPE_MPE="pyroscope-mpe"
export PYROSCOPE_PORT="4040"
```

Create the private link:

Note

Creating the private link can take a few minutes.

```azurecli
# Check the Azure Managed Grafana extension version.
ver=$(az extension show --name amg --query version --output tsv)
[[ "${ver%%.*}" -ge 3 ]] && MPE="managed-private-endpoint" || MPE="mpe"

# Wait until the Pyroscope private link service is available.
until az network private-link-service show \
  --name "$PYROSCOPE_PLS" \
  --resource-group "$AKS_NODE_RG" \
  --output none 2>/dev/null; do
  sleep 10
done

PYRO_PLS_ID=$(az network private-link-service show \
  --name "$PYROSCOPE_PLS" \
  --resource-group "$AKS_NODE_RG" \
  --query 'id' \
  --output tsv)

az grafana $MPE create \
  --workspace-name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PYROSCOPE_MPE" \
  --private-link-resource-id "$PYRO_PLS_ID" \
  --location "$LOCATION" \
  --output none

sleep 30

PYRO_CONN=$(az network private-link-service show \
  --name "$PYROSCOPE_PLS" \
  --resource-group "$AKS_NODE_RG" \
  --query "privateEndpointConnections[?privateLinkServiceConnectionState.status=='Pending' && starts_with(name, 'grafana-${GRAFANA_NAME}')].name | [0]" \
  --output tsv)

az network private-link-service connection update \
  --name "$PYRO_CONN" \
  --service-name "$PYROSCOPE_PLS" \
  --resource-group "$AKS_NODE_RG" \
  --connection-status Approved \
  --output none

az grafana $MPE refresh \
  --workspace-name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --output none

echo "Successfully created private link."
```

Create the Pyroscope data source in Azure Managed Grafana:

```azurecli
ver=$(az extension show --name amg --query version --output tsv)
[[ "${ver%%.*}" -ge 3 ]] && MPE="managed-private-endpoint" || MPE="mpe"

PYRO_IP=$(az grafana $MPE show \
  --workspace-name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PYROSCOPE_MPE" \
  --query 'privateLinkServicePrivateIP' \
  --output tsv)

export PYROSCOPE_URL="http://${PYRO_IP}:${PYROSCOPE_PORT}"

az grafana data-source create \
  --name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --definition "{
    \"name\": \"local-pyroscope\",
    \"uid\": \"local-pyroscope\",
    \"type\": \"grafana-pyroscope-datasource\",
    \"access\": \"proxy\",
    \"url\": \"${PYROSCOPE_URL}\",
    \"jsonData\": { \"keepCookies\": [\"pyroscope_git_session\"] }
  }" \
  --output none

echo "Successfully created the local-pyroscope data source."
```

Verify that the data source has a valid URL:

```azurecli
az grafana data-source show \
  --name "$GRAFANA_NAME" \
  --data-source local-pyroscope
```

## Step 4: Connect Grafana to Azure Monitor managed service for Prometheus

Note

These steps are based on [Connect Azure Monitor managed service for Prometheus to Grafana](/en-us/azure/azure-monitor/metrics/prometheus-grafana?tabs=azure-managed-grafana). Make sure Grafana's managed identity has the **Monitoring Data Reader** role on the Azure Monitor workspace, especially if the workspace is in a different resource group or subscription.

Set the Azure Monitor workspace environment variables:

```bash
export AMP_NAME="<your-azure-monitor-workspace-name>"
export AMP_RESOURCE_GROUP="<your-azure-monitor-workspace-resource-group>"
```

Tip

Run `az resource list --resource-type Microsoft.Monitor/accounts --resource-group "$AMP_RESOURCE_GROUP" --output table` to list Azure Monitor workspaces in the resource group. To search the subscription, omit `--resource-group`.

Create the Prometheus data source:

```azurecli
AMP_ENDPOINT=$(az resource show \
  --resource-type Microsoft.Monitor/accounts \
  --name "$AMP_NAME" \
  --resource-group "$AMP_RESOURCE_GROUP" \
  --query properties.metrics.prometheusQueryEndpoint \
  --output tsv)

az grafana data-source create \
  --name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --definition "{
    \"name\": \"$AMP_NAME\",
    \"type\": \"prometheus\",
    \"access\": \"proxy\",
    \"url\": \"$AMP_ENDPOINT\",
    \"jsonData\": {
      \"httpMethod\": \"POST\",
      \"azureCredentials\": { \"authType\": \"msi\" }
    }
  }"
```

Verify the data source:

```azurecli
az grafana data-source show \
  --name "$GRAFANA_NAME" \
  --data-source "$AMP_NAME"
```

## Step 5: Set up dashboards in Grafana

Import the GPU observability dashboard:

```azurecli
az grafana dashboard create \
  --name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --definition "$(curl -sSL https://raw.githubusercontent.com/inspektor-gadget/grafana-dashboards/refs/heads/main/dashboards/gpu-observability/AdvancedGPUObservability.json)"
```

Get the dashboard URL:

```bash
GRAFANA_URL=$(az grafana show \
  --name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.endpoint \
  --output tsv)

echo "${GRAFANA_URL}/d/AdvancedGPUObservability"
```

To interpret the profiling data, see [Analyze GPU profiling flame graphs](analyze-gpu-profiling-flame-graphs).

## Clean up resources

Remove the in-cluster GPU observability stack:

```bash
helm uninstall pyroscope -n gadget
az k8s-extension delete \
  --name inspektor-gadget \
  --cluster-name <your-cluster-name> \
  --resource-group <your-resource-group> \
  --cluster-type managedClusters \
  --yes
kubectl delete namespace gadget
```

## Reading flame graphs

To interpret profiling results and identify GPU memory hotspots, see [Analyze GPU profiling flame graphs](analyze-gpu-profiling-flame-graphs).

## FAQ

For custom Prometheus and Grafana integrations and persistent Pyroscope storage, see the [GPU profiling FAQ](gpu-profiling-faq).