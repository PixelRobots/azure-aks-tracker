---
layout: Conceptual
title: Create a GPU Linux-based Azure Kubernetes Service (AKS) cluster using Azure CLI - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-create-gpu-linux-cluster-cli
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to create a Linux-based Azure Kubernetes Service cluster with a fully managed GPU node pool using Azure CLI.
ms.topic: quickstart
ms.date: 2026-07-01T00:00:00.0000000Z
author: bbenz
ms.author: bbenz
ms.custom: devx-track-azurecli, mode-api, linux-related-content
ai-usage: ai-assisted
locale: en-us
document_id: 3612c7bc-9f8f-cc7c-9f1c-f8ad96a7cc65
document_version_independent_id: 92ddc842-4bb8-78de-7164-63e40475709d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-create-gpu-linux-cluster-cli.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/learn/quick-create-gpu-linux-cluster-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-create-gpu-linux-cluster-cli.md
platformId: 858b3164-c7e0-bf59-da76-c4d98aa70962
---

# Create a GPU Linux-based Azure Kubernetes Service (AKS) cluster using Azure CLI - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that you can use to quickly deploy and manage clusters. In this quickstart, you learn how to:

- Deploy an AKS cluster by using Azure CLI.
- Add a Linux-based GPU node pool with managed GPU nodes enabled.
- Verify that AKS installed and configured the GPU software stack for scheduling.

Fully managed GPU nodes are a preview feature. When you enable managed GPU nodes, AKS installs and manages the NVIDIA GPU driver, NVIDIA Kubernetes device plugin, Data Center GPU Manager (DCGM) metrics exporter, and GPU health monitoring components for the GPU node pool. Managed GPU nodes also integrate real-time GPU metrics for ingestion in Azure Managed Prometheus and Azure Monitor managed service for Prometheus. For more information, see [Create a fully managed GPU node pool on Azure Kubernetes Service (AKS) (preview)](../aks-managed-gpu-nodes) and [GPU observability in Azure Kubernetes Service (AKS)](../monitor-gpu-metrics).

Note

This article includes steps to deploy a cluster for evaluation purposes only. Before you deploy a production-ready cluster, familiarize yourself with the [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- You need Azure CLI version 2.85.0 or later. To find the version, run `az --version`. If you need to install or upgrade Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Ensure that the identity you're using to create your cluster has the appropriate minimum permissions. For more information on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).
- If you have multiple Azure subscriptions, select the appropriate subscription ID for billing by using the [az account set](/en-us/cli/azure/account#az-account-set) command. For more information, see [How to manage Azure subscriptions - Azure CLI](/en-us/cli/azure/manage-azure-subscriptions-azure-cli?tabs=bash#change-the-active-subscription).
- Depending on your Azure subscription, you might need to request a vCPU quota increase for the GPU-enabled VM family you use in this quickstart. For more information, see [Increase VM-family vCPU quotas](/en-us/azure/quotas/per-vm-quota-requests).
- GPU-enabled VM sizes contain specialized hardware subject to higher pricing and regional availability. For more information, see [GPU optimized virtual machine sizes](/en-us/azure/virtual-machines/sizes-gpu).

## Install the `aks-preview` CLI extension

Install the `aks-preview` CLI extension by using the [az extension add](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update the extension to ensure you have the latest version by using the [az extension update](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

## Register the preview feature

Register the `ManagedGPUExperiencePreview` feature flag in your subscription by using the [az feature register](/en-us/cli/azure/feature#az-feature-register) command.

```azurecli
az feature register --namespace Microsoft.ContainerService --name ManagedGPUExperiencePreview
```

It takes a few minutes for the status to show **Registered**. Verify the registration status by using the [az feature show](/en-us/cli/azure/feature#az-feature-show) command.

```azurecli
az feature show --namespace Microsoft.ContainerService --name ManagedGPUExperiencePreview --query properties.state
```

When the status shows **Registered**, refresh the registration of the `Microsoft.ContainerService` resource provider by using the [az provider register](/en-us/cli/azure/provider#az-provider-register) command.

```azurecli
az provider register --namespace Microsoft.ContainerService
```

## Define environment variables

Define the following environment variables for use throughout this quickstart.

```bash
export RANDOM_STRING=$(printf '%05d%05d' "$RANDOM" "$RANDOM")
export RESOURCE_GROUP="myAKSResourceGroup$RANDOM_STRING"
export CLUSTER_NAME="myAKSCluster$RANDOM_STRING"
export GPU_NP="gpunp"
export GPU_VM_SIZE="Standard_NC4as_T4_v3"
export LOCATION="westus"
```

The `RANDOM_STRING` variable stores a random 10-digit string. The `RESOURCE_GROUP` and `CLUSTER_NAME` variable values are concatenated with the `RANDOM_STRING` value to create unique names. The `GPU_NP` variable stores the name for the managed GPU node pool. The `GPU_VM_SIZE` variable stores the GPU-enabled VM size for the node pool. The `LOCATION` variable has the value *westus*. You can use these variable values or create your own. Use the `echo` command to view variable values like `echo $RANDOM_STRING`.

## Create a resource group

An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) is a logical group for deploying and managing Azure resources. When you create a resource group, specify a location. This location is where the resource group metadata is stored and where your resources run in Azure if you don't specify another region during resource creation.

Use the [az group create](/en-us/cli/azure/group#az-group-create) command to create a resource group.

```azurecli
az group create --name $RESOURCE_GROUP --location $LOCATION
```

The following example shows the result.

```output
{
  "id": "/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myAKSResourceGroup<randomStringValue>",
  "location": "westus",
  "managedBy": null,
  "name": "myAKSResourceGroup<randomStringValue>",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create an AKS cluster

Use the [az aks create](/en-us/cli/azure/aks#az-aks-create) command to create an AKS cluster. The following example creates a cluster with one system node and enables a system-assigned managed identity.

```azurecli
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 1 \
  --generate-ssh-keys
```

When you create a new cluster, AKS automatically creates a second resource group to store the AKS resources. For more information, see [Why are two resource groups created with AKS?](../faq)

The cluster in this example specifies a node count of one to save time and resources. In a production environment, use a node count of three or more nodes. The `az aks create` command defaults to three nodes if you don't specify a node count.

## Add a managed GPU node pool

Add a Linux-based managed GPU node pool to your cluster by using the [az aks nodepool add](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The `--enable-managed-gpu=true` parameter configures AKS to install and manage the NVIDIA GPU driver, NVIDIA Kubernetes device plugin, DCGM metrics exporter, and GPU health monitoring components on the node pool.

# [Ubuntu Linux](#tab/ubuntu)
The following example adds a managed GPU node pool by using the default Ubuntu Linux operating system.

```azurecli
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $GPU_NP \
  --node-count 1 \
  --node-vm-size $GPU_VM_SIZE \
  --node-taints sku=gpu:NoSchedule \
  --enable-managed-gpu=true
```

# [Azure Linux](#tab/azure-linux)
The following example adds a managed GPU node pool by using Azure Linux.

```azurecli
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $GPU_NP \
  --node-count 1 \
  --os-sku AzureLinux \
  --node-vm-size $GPU_VM_SIZE \
  --node-taints sku=gpu:NoSchedule \
  --enable-managed-gpu=true
```

---

The `--node-taints sku=gpu:NoSchedule` parameter keeps non-GPU workloads off the GPU node pool unless the workloads include a matching toleration.

After you create the node pool, use the [az aks nodepool show](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command to confirm that the managed GPU profile is enabled.

```azurecli
az aks nodepool show \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $GPU_NP \
  --query "{Name:name, Mode:mode, VmSize:vmSize, Taints:nodeTaints, GpuProfile:gpuProfile}"
```

Your output should include the following values.

```output
{
  "GpuProfile": {
    "driver": "Install",
    "driverType": "",
    "nvidia": {
      "managementMode": "Managed",
      "migStrategy": null
    }
  },
  "Mode": "User",
  "Name": "gpunp",
  "Taints": [
    "sku=gpu:NoSchedule"
  ],
  "VmSize": "Standard_NC4as_T4_v3"
}
```

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). If you use Azure Cloud Shell, `kubectl` is already installed. To install `kubectl` locally, use the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

1. Configure `kubectl` to connect to your Kubernetes cluster by using the [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. Verify the connection to your cluster by using the [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes and shows the node pool for each node.

    ```bash
    kubectl get nodes -L kubernetes.azure.com/agentpool,kubernetes.azure.com/mode
    ```

    ```output
    NAME                                STATUS   ROLES    AGE     VERSION   AGENTPOOL   MODE
    aks-nodepool1-123456789-vmss000000  Ready    <none>   20m     v1.34.4   nodepool1   system
    aks-gpunp-123456789-vmss000000      Ready    <none>   5m36s   v1.34.4   gpunp       user
    ```
3. Verify that Kubernetes can schedule GPU workloads on the managed GPU node pool.

    ```bash
    kubectl get nodes -l kubernetes.azure.com/agentpool=$GPU_NP -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}'
    ```

    The output shows the allocatable GPU count for each node in the managed GPU node pool.

    ```output
    aks-gpunp-123456789-vmss000000  1
    ```

## Enable GPU metrics collection

Managed GPU node pools include the DCGM metrics exporter. To ingest the GPU metrics into Azure Managed Prometheus, first [enable Azure Monitor managed service for Prometheus on your AKS cluster](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli#enable-prometheus-and-grafana). Then, create a ConfigMap that enables the `dcgmexporter` scraping profile in the Azure Monitor agent.

```bash
cat <<EOF | kubectl create -f -
kind: ConfigMap
apiVersion: v1
data:
  schema-version:
    v1
  config-version:
    ver1
  default-scrape-settings-enabled: |-
    dcgmexporter = true
metadata:
  name: ama-metrics-settings-configmap
  namespace: kube-system
EOF
```

After you apply this ConfigMap, all existing and new NVIDIA GPU node pools on the cluster are scraped automatically. To view GPU metrics in Azure Managed Grafana, see [GPU observability in Azure Kubernetes Service (AKS)](../monitor-gpu-metrics).

## Deploy the application

Deploy a GPU workload to confirm that the managed GPU node pool can run real applications. This example runs [Ollama](https://ollama.com), which serves a small open-source large language model (Llama 3.2 1B) through an OpenAI-compatible API. Ollama is built on llama.cpp, which supports the NVIDIA T4 GPU in the `Standard_NC4as_T4_v3` node pool that this quickstart uses.

The following manifest creates a `Deployment` and a `Service`. The `Deployment` requests one GPU (`nvidia.com/gpu: 1`), includes a toleration for the `sku=gpu:NoSchedule` taint, and uses a node selector to target the managed GPU node pool. When the container starts, it launches the Ollama server and pulls the `llama3.2:1b` model so the pod is ready to serve requests.

Deploy the application by using the following command.

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  labels:
    app: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      # Schedule onto the managed GPU node pool created in this quickstart.
      nodeSelector:
        kubernetes.azure.com/agentpool: gpunp
      # Tolerate the GPU node pool taint (sku=gpu:NoSchedule).
      tolerations:
        - key: "sku"
          operator: "Equal"
          value: "gpu"
          effect: "NoSchedule"
      containers:
        - name: ollama
          image: ollama/ollama:0.30.10
          ports:
            - name: http
              containerPort: 11434
          env:
            # Listen on all interfaces so the Service and kubelet probes can reach it.
            - name: OLLAMA_HOST
              value: "0.0.0.0:11434"
            # Model to pull and serve on startup. Fits comfortably on a 16-GB T4.
            - name: MODEL
              value: "llama3.2:1b"
          # Start the server, wait until it's ready, and then pull the model so the
          # pod is self-contained (no manual "ollama pull" step required).
          command: ["/bin/sh", "-c"]
          args:
            - |
              ollama serve &
              pid=$!
              echo "Waiting for the Ollama server to be ready..."
              until ollama list >/dev/null 2>&1; do sleep 2; done
              echo "Server ready. Pulling model: $MODEL"
              ollama pull "$MODEL" || echo "WARN: pull failed; run 'kubectl exec deploy/ollama -- ollama pull $MODEL' manually"
              echo "Model $MODEL is ready to serve."
              wait $pid
          resources:
            requests:
              cpu: "1"
              memory: 4Gi
            limits:
              cpu: "4"
              memory: 16Gi
              nvidia.com/gpu: 1
          startupProbe:
            httpGet:
              path: /api/tags
              port: http
            periodSeconds: 5
            failureThreshold: 60
          readinessProbe:
            httpGet:
              path: /api/tags
              port: http
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: http
            periodSeconds: 20
          volumeMounts:
            - name: ollama-data
              mountPath: /root/.ollama
      volumes:
        - name: ollama-data
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
  labels:
    app: ollama
spec:
  type: ClusterIP
  selector:
    app: ollama
  ports:
    - name: http
      port: 11434
      targetPort: http
EOF
```

Note

This manifest targets the `gpunp` node pool. If you used a different value for the `GPU_NP` variable, update the `kubernetes.azure.com/agentpool` node selector value to match before you apply the manifest.

Confirm that the deployment is ready by using the [kubectl rollout status](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout) command. The initial model download can take a few minutes.

```bash
kubectl rollout status deployment/ollama --timeout=600s
```

Verify that the pod is running on the managed GPU node pool by using the [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

```bash
kubectl get pods -l app=ollama -o wide
```

Your output should show the pod running on a node in the `gpunp` node pool.

```output
NAME                      READY   STATUS    RESTARTS   AGE   IP            NODE                            NOMINATED NODE   READINESS GATES
ollama-5b8f6c9d4f-2xq7p   1/1     Running   0          5m    10.244.1.10   aks-gpunp-12345678-vmss000000   <none>           <none>
```

## Test the application

Forward a local port to the `Service` by using the [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward) command. Keep this command running, and open a second terminal for the remaining steps.

```bash
kubectl port-forward svc/ollama 11434:11434
```

In the second terminal, send a prompt to the model by using the OpenAI-compatible chat completions endpoint.

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:1b",
    "messages": [{"role": "user", "content": "In one sentence, what is Azure Kubernetes Service?"}]
  }'
```

The model returns a JSON response that contains a generated answer, which confirms that the workload is serving inference from the managed GPU node pool.

Confirm that the model is loaded on the GPU by using the `ollama ps` command. The `PROCESSOR` column shows `100% GPU` when the model runs on the T4.

```bash
kubectl exec deploy/ollama -- ollama ps
```

```output
NAME          ID              SIZE      PROCESSOR    CONTEXT   UNTIL
llama3.2:1b   baf6a787fdff    1.5 GB    100% GPU     4096      4 minutes from now
```

You can also view the GPU directly from inside the pod by using the `nvidia-smi` command.

```bash
kubectl exec deploy/ollama -- nvidia-smi
```

When you finish testing, stop the `kubectl port-forward` process by selecting Ctrl+C in its terminal. The application is removed when you delete the cluster in the next step.

## Delete the cluster

If you don't plan on doing the [AKS tutorial](../tutorial-kubernetes-prepare-app), clean up unnecessary resources to avoid Azure billing charges. You can remove the resource group, container service, and all related resources by using the [az group delete](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --no-wait --yes
```

You created the AKS cluster with a system-assigned managed identity, which is the default identity option used in this quickstart. The platform manages this identity so you don't need to manually remove it.