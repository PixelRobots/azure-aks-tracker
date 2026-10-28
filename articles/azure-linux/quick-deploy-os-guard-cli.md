---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Linux with OS Guard (preview) AKS Cluster using the Azure CLI | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/quick-deploy-os-guard-cli
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
manager: kumud
description: Learn how to quickly deploy an Azure Linux with OS Guard (preview) AKS cluster using the Azure CLI and connect to the cluster using kubectl.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 33a34b55-e176-9d3b-8e0f-760223ef0b75
document_version_independent_id: 22790dc0-4d77-488c-15af-be2adb8acd87
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/quick-deploy-os-guard-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/quick-deploy-os-guard-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/quick-deploy-os-guard-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e80600e8-ae87-58fc-f32e-61e4d9906a03
---

# Quickstart: Deploy an Azure Linux with OS Guard (preview) AKS Cluster using the Azure CLI | Microsoft Learn

In this quickstart, you learn how to:

- Create an Azure Linux with OS Guard (preview) AKS cluster using the Azure CLI.
- Connect to the cluster using kubectl.
- Run a sample multi-container application in the cluster.

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Linux with OS Guard (preview) is being replaced by Azure Container Linux (ACL).

Azure Container Linux is the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale.

For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Azure Cloud Shell Quickstart - Bash](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/ce-skilling/azure/media/cloud-shell/launch-cloud-shell-button.png)](https://portal.azure.com/#cloudshell/)
- If you prefer to run CLI reference commands locally, [install the Azure CLI](/en-us/cli/azure/install-azure-cli). If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI using the [`az login`](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Sign in with the Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [`az version`](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade).

## Azure Linux with OS Guard considerations and limitations

Before you begin, review the following considerations and limitations for Azure Linux with OS Guard (preview):

- Kubernetes version 1.32.0 or higher is required for Azure Linux with OS Guard.
- All Azure Linux with OS Guard images have [Federal Information Process Standard (FIPS)](/en-us/azure/aks/enable-fips-nodes) and [Trusted Launch](/en-us/azure/aks/use-trusted-launch) enabled.
- Azure CLI and ARM templates are the only supported deployment methods for Azure Linux with OS Guard on AKS in preview. PowerShell and Terraform aren't supported.
- [Arm64](/en-us/azure/aks/use-arm64-vms) images aren't supported with Azure Linux with OS Guard on AKS in preview.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for Azure Linux with OS Guard on AKS. `Unmanaged` and `SecurityPatch` are incompatible with Azure Linux with OS Guard due to the immutable /usr directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Gen 1 virtual machines (VMs)](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az_extension_add) command.

```azurecli
az extension add --name aks-preview
```

Update the `aks-preview` extension to the latest version using the [`az extension update`](/en-us/cli/azure/extension#az_extension_update) command.

```azurecli
az extension update --name aks-preview
```

## Register the `AzureLinuxOSGuardPreview` feature flag

1. Register the `AzureLinuxOSGuardPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

## Set environment variables

Set the following environment variables to create unique resource names for each deployment. Replace `<your-resource-group-name>`, `<your-region>`, and `<your-cluster-name>` with your own values. You can optionally use the `openssl rand -hex 3` command to generate a random string to append to your resource group and cluster names (for example, `export RESOURCE_GROUP="myResourceGroup$RANDOM_ID"`).

```bash
# Create random string
export RANDOM_ID="$(openssl rand -hex 3)"

# Set environment variables
export RESOURCE_GROUP="<your-resource-group-name>"
export REGION="<your-region>"
export CLUSTER_NAME="<your-cluster-name>"
```

## Create a resource group

An Azure resource group is a logical group in which Azure resources are deployed and managed. When creating a resource group in Azure, you're required to specify a location. This location is the storage location of your resource group metadata and where your resources run in Azure if you don't specify another region when creating a resource.

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az_group_create) command.

```azurecli
az group create --name $RESOURCE_GROUP --location $REGION
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/$RESOURCE_GROUPxxxxxx",
  "location": "$REGION",
  "managedBy": null,
  "name": "$RESOURCE_GROUPxxxxxx",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create an Azure Linux with OS Guard cluster

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az_aks_create) command with the `--os-sku` parameter to provision the AKS cluster with an Azure Linux with OS Guard image.

```azurecli
az aks create --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --os-sku AzureLinuxOSGuard --node-osdisk-type Managed --enable-fips-image --enable-secure-boot --enable-vtpm 
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, `kubectl`. `kubectl` is already installed if you use Azure Cloud Shell. To install `kubectl` locally, use the `az aks install-cli` command.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. Verify the connection to your cluster using the `kubectl get` command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

## Deploy the application

To deploy the application, you use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A Kubernetes manifest file defines a cluster's desired state, such as which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/aks-store-architecture.png)](media/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production. These are used here for simplicity, but we recommend using managed services, such as Azure Cosmos DB or Azure Service Bus.

1. Create a file named `aks-store-quickstart.yaml` and copy in the following manifest:

    ```yaml
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: rabbitmq
    spec:
      serviceName: rabbitmq
      replicas: 1
      selector:
        matchLabels:
          app: rabbitmq
      template:
        metadata:
          labels:
            app: rabbitmq
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
          - name: rabbitmq
            image: mcr.microsoft.com/mirror/docker/library/rabbitmq:3.10-management-alpine
            ports:
            - containerPort: 5672
              name: rabbitmq-amqp
            - containerPort: 15672
              name: rabbitmq-http
            env:
            - name: RABBITMQ_DEFAULT_USER
              value: "username"
            - name: RABBITMQ_DEFAULT_PASS
              value: "password"
            resources:
              requests:
                cpu: 10m
                memory: 128Mi
              limits:
                cpu: 250m
                memory: 256Mi
            volumeMounts:
            - name: rabbitmq-enabled-plugins
              mountPath: /etc/rabbitmq/enabled_plugins
              subPath: enabled_plugins
          volumes:
          - name: rabbitmq-enabled-plugins
            configMap:
              name: rabbitmq-enabled-plugins
              items:
              - key: rabbitmq_enabled_plugins
                path: enabled_plugins
    ---
    apiVersion: v1
    data:
      rabbitmq_enabled_plugins: |
        [rabbitmq_management,rabbitmq_prometheus,rabbitmq_amqp1_0].
    kind: ConfigMap
    metadata:
      name: rabbitmq-enabled-plugins            
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: rabbitmq
    spec:
      selector:
        app: rabbitmq
      ports:
        - name: rabbitmq-amqp
          port: 5672
          targetPort: 5672
        - name: rabbitmq-http
          port: 15672
          targetPort: 15672
      type: ClusterIP
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: order-service
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: order-service
      template:
        metadata:
          labels:
            app: order-service
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
          - name: order-service
            image: ghcr.io/azure-samples/aks-store-demo/order-service:latest
            ports:
            - containerPort: 3000
            env:
            - name: ORDER_QUEUE_HOSTNAME
              value: "rabbitmq"
            - name: ORDER_QUEUE_PORT
              value: "5672"
            - name: ORDER_QUEUE_USERNAME
              value: "username"
            - name: ORDER_QUEUE_PASSWORD
              value: "password"
            - name: ORDER_QUEUE_NAME
              value: "orders"
            - name: FASTIFY_ADDRESS
              value: "0.0.0.0"
            resources:
              requests:
                cpu: 1m
                memory: 50Mi
              limits:
                cpu: 75m
                memory: 128Mi
            startupProbe:
              httpGet:
                path: /health
                port: 3000
              failureThreshold: 5
              initialDelaySeconds: 20
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /health
                port: 3000
              failureThreshold: 3
              initialDelaySeconds: 3
              periodSeconds: 5
            livenessProbe:
              httpGet:
                path: /health
                port: 3000
              failureThreshold: 5
              initialDelaySeconds: 3
              periodSeconds: 3
          initContainers:
          - name: wait-for-rabbitmq
            image: busybox
            command: ['sh', '-c', 'until nc -zv rabbitmq 5672; do echo waiting for rabbitmq; sleep 2; done;']
            resources:
              requests:
                cpu: 1m
                memory: 50Mi
              limits:
                cpu: 75m
                memory: 128Mi    
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: order-service
    spec:
      type: ClusterIP
      ports:
      - name: http
        port: 3000
        targetPort: 3000
      selector:
        app: order-service
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: product-service
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: product-service
      template:
        metadata:
          labels:
            app: product-service
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
          - name: product-service
            image: ghcr.io/azure-samples/aks-store-demo/product-service:latest
            ports:
            - containerPort: 3002
            env: 
            - name: AI_SERVICE_URL
              value: "http://ai-service:5001/"
            resources:
              requests:
                cpu: 1m
                memory: 1Mi
              limits:
                cpu: 2m
                memory: 20Mi
            readinessProbe:
              httpGet:
                path: /health
                port: 3002
              failureThreshold: 3
              initialDelaySeconds: 3
              periodSeconds: 5
            livenessProbe:
              httpGet:
                path: /health
                port: 3002
              failureThreshold: 5
              initialDelaySeconds: 3
              periodSeconds: 3
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: product-service
    spec:
      type: ClusterIP
      ports:
      - name: http
        port: 3002
        targetPort: 3002
      selector:
        app: product-service
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: store-front
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: store-front
      template:
        metadata:
          labels:
            app: store-front
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
          - name: store-front
            image: ghcr.io/azure-samples/aks-store-demo/store-front:latest
            ports:
            - containerPort: 8080
              name: store-front
            env: 
            - name: VUE_APP_ORDER_SERVICE_URL
              value: "http://order-service:3000/"
            - name: VUE_APP_PRODUCT_SERVICE_URL
              value: "http://product-service:3002/"
            resources:
              requests:
                cpu: 1m
                memory: 200Mi
              limits:
                cpu: 1000m
                memory: 512Mi
            startupProbe:
              httpGet:
                path: /health
                port: 8080
              failureThreshold: 3
              initialDelaySeconds: 5
              periodSeconds: 5
            readinessProbe:
              httpGet:
                path: /health
                port: 8080
              failureThreshold: 3
              initialDelaySeconds: 3
              periodSeconds: 3
            livenessProbe:
              httpGet:
                path: /health
                port: 8080
              failureThreshold: 5
              initialDelaySeconds: 3
              periodSeconds: 3
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: store-front
    spec:
      ports:
      - port: 80
        targetPort: 8080
      selector:
        app: store-front
      type: LoadBalancer
    ```

    If you create and save the YAML file locally, then you can upload the manifest file to your default directory in CloudShell by selecting the **Upload/Download files** button and selecting the file from your local file system.
2. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f aks-store-quickstart.yaml
    ```

## Test the application

You can validate that the application is running by visiting the public IP address or the application URL.

Get the application URL using the following commands:

```azurecli
runtime="5 minutes"
endtime=$(date -ud "$runtime" +%s)
while [[ $(date -u +%s) -le $endtime ]]
do
   STATUS=$(kubectl get pods -l app=store-front -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
   echo $STATUS
   if [ "$STATUS" == 'True' ]
   then
      export IP_ADDRESS=$(kubectl get service store-front --output 'jsonpath={..status.loadBalancer.ingress[0].ip}')
      echo "Service IP Address: $IP_ADDRESS"
      break
   else
      sleep 10
   fi
done
```

```azurecli
curl $IP_ADDRESS
```

Results:

```HTML
<!doctype html>
<html lang="">
   <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link rel="icon" href="/favicon.ico">
      <title>store-front</title>
      <script defer="defer" src="/js/chunk-vendors.df69ae47.js"></script>
      <script defer="defer" src="/js/app.7e8cfbb2.js"></script>
      <link href="/css/app.a5dc49f6.css" rel="stylesheet">
   </head>
   <body>
      <div id="app"></div>
   </body>
</html>
```

```output
echo "You can now visit your web server at $IP_ADDRESS"
```

## Delete the cluster

If you no longer need them, you can clean up unnecessary resources to avoid Azure charges.

Delete the Azure resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```