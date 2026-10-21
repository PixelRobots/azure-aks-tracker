---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using Azure PowerShell - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-powershell
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
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in Azure Kubernetes Service (AKS) using PowerShell.
ms.topic: quickstart
ms.date: 2026-06-17T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: devx-track-azurepowershell, mode-api, aks-getting-started
ai-usage: ai-assisted
locale: en-us
document_id: df0729db-210c-b98d-1bfe-7ac20c6cb580
document_version_independent_id: c71f4c52-7711-69d4-36a1-c43bd140b15d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-kubernetes-deploy-powershell.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurepowershell
toc_rel: ../toc.json
asset_id: aks/learn/quick-kubernetes-deploy-powershell
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-kubernetes-deploy-powershell.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 638e28c1-cc6a-58ea-a780-ba4c4acd078a
---

# Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using Azure PowerShell - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this quickstart, you:

- Deploy an AKS cluster using Azure PowerShell.
- Run a sample multi-container application with a group of microservices and web front ends simulating a retail scenario.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This article assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- For ease of use, try the PowerShell environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Quickstart for Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    If you want to use PowerShell locally, then install the [Az PowerShell](/en-us/powershell/azure/new-azureps-module-az) module and connect to your Azure account using the [Connect-AzAccount](/en-us/powershell/module/az.accounts/Connect-AzAccount) cmdlet. Make sure that you run the commands with administrative privileges. For more information, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).
- Make sure that the identity you're using to create your cluster has the appropriate minimum permissions. For more details on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).
- If you have more than one Azure subscription, set the subscription that you wish to use for the quickstart by calling the [Set-AzContext](/en-us/powershell/module/az.accounts/set-azcontext) cmdlet. For more information, see [Manage Azure subscriptions with Azure PowerShell](/en-us/powershell/azure/manage-subscriptions-azureps#change-the-active-subscription).

## Create a resource group

An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) is a logical group in which Azure resources are deployed and managed. When you create a resource group, you're prompted to specify a location. This location is the storage location of your resource group metadata and where your resources run in Azure if you don't specify another region during resource creation.

The following example creates a resource group named *myResourceGroup* in the *eastus* location.

- Create a resource group using the [`New-AzResourceGroup`](/en-us/powershell/module/az.resources/new-azresourcegroup) cmdlet.

    ```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    ```

    The following example output resembles successful creation of the resource group:

    ```output
    ResourceGroupName : myResourceGroup
    Location          : eastus
    ProvisioningState : Succeeded
    Tags              :
    ResourceId        : /subscriptions/a0a0a0a0-bbbb-cccc-dddd-e1e1e1e1e1e1/resourceGroups/myResourceGroup
    ```

## Create AKS cluster

To create an AKS cluster, use the [`New-AzAksCluster`](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet. The following example creates a cluster named *myAKSCluster* with one node and enables a system-assigned managed identity.

```azurepowershell
New-AzAksCluster -ResourceGroupName myResourceGroup `
    -Name myAKSCluster `
    -NodeCount 1 `
    -EnableManagedIdentity `
    -GenerateSshKey
```

After a few minutes, the command completes and returns information about the cluster.

Note

When you create an AKS cluster, a second resource group called the *node resource group* is automatically created to store the AKS resources. For more information, see [Node resource group](../core-aks-concepts#node-resource-group). When you delete the resource group for the AKS cluster, the node resource group is also deleted. You also see a *NetworkWatcherRG* resource group created by default. This resource group is used by Azure Network Watcher to store monitoring data. You can safely ignore this resource group. For more information, see [Enable or disable Azure Network Watcher](/en-us/azure/network-watcher/network-watcher-create).

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). `kubectl` is already installed if you use Azure Cloud Shell. To install `kubectl` locally, call the `Install-AzAksCliTool` cmdlet.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```azurepowershell
    kubectl get nodes
    ```

    The following example output shows the single node created in the previous steps. Make sure the node status is *Ready*.

    ```output
    NAME                                STATUS   ROLES   AGE     VERSION
    aks-nodepool1-11853318-vmss000000   Ready    agent   2m26s   v1.27.7
    ```

## Deploy the application

To deploy the application, you use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A [Kubernetes manifest file](../concepts-clusters-workloads#deployments-and-yaml-manifests) defines a cluster's desired state, such as which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/quick-kubernetes-deploy-powershell/aks-store-architecture.png)](media/quick-kubernetes-deploy-powershell/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production. These are used here for simplicity, but we recommend using managed services, such as Azure CosmosDB or Azure Service Bus.

1. Create a file named `aks-store-quickstart.yaml` and copy in the following manifest:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: rabbitmq
    spec:
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
            resources:
              requests:
                cpu: 1m
                memory: 1Mi
              limits:
                cpu: 1m
                memory: 7Mi
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

    For a breakdown of YAML manifest files, see [Deployments and YAML manifests](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

    If you create and save the YAML file locally, then you can upload the manifest file to your default directory in CloudShell by selecting the **Upload/Download files** button and selecting the file from your local file system.
2. Deploy the application using the [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```console
    kubectl apply -f aks-store-quickstart.yaml
    ```

    The following example output shows the deployments and services:

    ```output
    deployment.apps/rabbitmq created
    service/rabbitmq created
    deployment.apps/order-service created
    service/order-service created
    deployment.apps/product-service created
    service/product-service created
    deployment.apps/store-front created
    service/store-front created
    ```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete.

1. Check the status of the deployed pods using the [kubectl get pods](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make all pods are `Running` before proceeding.

    ```console
    kubectl get pods
    ```
2. Check for a public IP address for the store-front application. Monitor progress using the [kubectl get service](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```console
    kubectl get service store-front --watch
    ```

    The **EXTERNAL-IP** output for the `store-front` service initially shows as *pending*:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   <pending>     80:30025/TCP   4h4m
    ```
3. Once the **EXTERNAL-IP** address changes from *pending* to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.

    The following example output shows a valid public IP address assigned to the service:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   20.62.159.19   80:30025/TCP   4h5m
    ```
4. Open a web browser to the external IP address of your service to see the Azure Store app in action.

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-powershell/aks-store-application.png)](media/quick-kubernetes-deploy-powershell/aks-store-application.png#lightbox)

## Delete resources

If you don't plan on going through the [AKS tutorial](../tutorial-kubernetes-prepare-app), clean up unnecessary resources to avoid Azure charges. Remove the resource group, container service, and all related resources by calling the [`Remove-AzResourceGroup`](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet.

```azurepowershell
Remove-AzResourceGroup -Name myResourceGroup
```

Note

The AKS cluster was created with system-assigned managed identity (default identity option used in this quickstart), the identity is managed by the platform and doesn't require removal.