---
layout: Conceptual
title: Set up Layer 7(L7) policies with Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/how-to-apply-l7-policies
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
description: Get started with Layer 7(L7) Feature for Advanced Container Networking Services (ACNS) for your AKS cluster using Azure managed Cilium Network Policies.
author: Khushbu-Parekh
ms.author: kparekh
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2024-03-14T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: eea3f6d3-1958-3c6a-b178-14cf1004bbaf
document_version_independent_id: d3b6df06-d5e7-e28c-6546-f2cbd96bb0d9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/how-to-apply-l7-policies.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/how-to-apply-l7-policies
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/how-to-apply-l7-policies.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7587e10a-5811-c6c9-e3e1-8428db092c60
---

# Set up Layer 7(L7) policies with Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn

This article demonstrates how to set up L7 policies with Advanced Container Networking Services in AKS clusters. Continue only after you have reviewed the limitations and considerations listed on the [Layer 7 Policy Overview](container-network-security-l7-policy-concepts) page.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

The minimum version of Azure CLI required for the steps in this article is 2.79.0. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

### Enable Advanced Container Networking Services

To proceed, you must have an AKS cluster with [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.

The `az aks create` command with the Advanced Container Networking Services flag, `--enable-acns`, creates a new AKS cluster with all Advanced Container Networking Services features. These features encompass:

- **Container Network Observability:** Provides insights into your network traffic. To learn more visit [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability).
- **Container Network Security:** Offers security features like Fully Qualified Domain Name (FQDN) filtering. To learn more visit [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security).

# [Cilium](#tab/cilium)
Note

Clusters with the Cilium data plane support Container Network Observability and Container Network security starting with Kubernetes version 1.29.

For this demo, the `--acns-advanced-networkpolicies` parameter must be set to "L7" to enable L7 policies. Setting this parameter to "L7" also enables FQDN filtering. If you only want to enable FQDN filtering, set the parameter to "FQDN". To disable both features, you can follow the instructions provided in [Disable Container Network Security](advanced-container-networking-services-overview).

```azurecli

export CLUSTER_NAME="<aks-cluster-name>"

# Create an AKS cluster
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --generate-ssh-keys \
    --network-plugin azure \
    --network-dataplane cilium \
    --enable-acns \
    --acns-advanced-networkpolicies L7
```

# [Non-Cilium](#tab/non-cilium)
Note

[L7 Policy](container-network-security-l7-policy-concepts) feature is not available for Non-Cilium clusters.

---

### Enable Advanced Container Networking Services on an existing cluster

The [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the Advanced Container Networking Services flag, `--enable-acns`, updates an existing AKS cluster with all Advanced Container Networking Services features which includes [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability) and the [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security) feature.

Note

Only clusters with the Cilium data plane support Container Network Security features of Advanced Container Networking Services.

For this demo, the `--acns-advanced-networkpolicies` parameter must be set to "L7" to enable L7 policies. Setting this parameter to "L7" also enables FQDN filtering. If you only want to enable FQDN filtering, set the parameter to "FQDN". To disable both features, you can follow the instructions provided in [Disable Container Network Security](advanced-container-networking-services-overview).

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-advanced-networkpolicies L7
```

## Get cluster credentials

Get your cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

## Set up http-server application on your AKS cluster

Apply the below YAML to your AKS cluster to set up the `http-server` application.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: http-server
  labels:
    app: http-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: http-server
  template:
    metadata:
      labels:
        app: http-server
    spec:
      containers:
      - name: http-server
        image: nginx:latest
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config

---
apiVersion: v1
kind: Service
metadata:
  name: http-server
spec:
  selector:
    app: http-server
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  default.conf: |
    server {
        listen 8080;

        location / {
            return 200 "Hello from the server root!\n";
        }

        location /products {
            return 200 "Listing products...\n";
        }
    }
```

## Set up http-client application on your AKS Cluster

Apply the below YAML to your AKS cluster to set up the `http-client` application.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: http-client
  labels:
    app: http-client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: http-client
  template:
    metadata:
      labels:
        app: http-client
    spec:
      containers:
      - name: http-client
        image: curlimages/curl:latest
        command: ["sleep", "infinity"]
```

## Test connectivity with a policy

Next, apply the following Layer 7 policy to allow only `GET` requests from the `http-client` application to the `/products` endpoint on the `http-server`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-get-products
spec:
  description: "Allow only GET requests to /products from http-client to http-server"
  endpointSelector:
    matchLabels:
      app: http-server
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: http-client
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/products"
```

### Verify policy

To verify the policy's enforcement, execute these commands from the `http-client` pod:

```azurecli
kubectl exec -it <your-http-client-pod-name> -n default -- curl -v http://http-server:80/products
```

You should expect an output like `Listing products...` when you run the above command

```azurecli
kubectl exec -it <your-http-client-pod-name> -n default -- curl -v -XPOST http://http-server:80/products -d "test=data"
```

You should expect an output like `Access Denied` when you run the above command

### Observing L7 metrics

If you have Advanced Container Network Service's container network observability enabled, you can visualize the traffic on Grafana.

To simplify the analysis of these L7 metrics, we provide preconfigured Azure Managed Grafana dashboards. You can find them under the **Dashboards &gt; Azure Managed Prometheus** folder, with filenames like **"Kubernetes/Networking/L7 (Namespace)"** and **"Kubernetes/Networking/L7 (Workload)"**.

You should see metrics similar to the following:

[![Screenshot showing Grafana dashboard for L7 traffic.](media/advanced-container-networking-services/l7-traffic-grafana.png)](media/advanced-container-networking-services/l7-traffic-grafana.png#lightbox)

## Clean up resources

If you don't plan on using this application, delete the other resources you created in this article using the [`az group delete`](/en-us/cli/azure/#az-group-delete) command.

```azurecli
  az group delete --name $RESOURCE_GROUP
```