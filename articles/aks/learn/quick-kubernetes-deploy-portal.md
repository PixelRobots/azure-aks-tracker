---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using the Azure portal - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal
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
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in Azure Kubernetes Service (AKS) using the Azure portal.
ms.topic: quickstart
ms.date: 2025-12-19T00:00:00.0000000Z
ms.custom: mvc, mode-ui, aks-getting-started
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 77136f12-0407-9038-0358-691867118427
document_version_independent_id: 0596ba99-9dd4-efa6-6277-8957efb081ad
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-kubernetes-deploy-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: ../toc.json
asset_id: aks/learn/quick-kubernetes-deploy-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-kubernetes-deploy-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 94abbf8f-4db1-c865-619b-8412867826c8
---

# Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using the Azure portal - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this quickstart, you:

- Deploy an AKS cluster using the Azure portal.
- Run a sample multi-container application with a group of microservices and web front ends simulating a retail scenario.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- If you're unfamiliar with the Azure Cloud Shell, review [Overview of Azure Cloud Shell](/en-us/azure/cloud-shell/overview).
- Make sure that the identity you use to create your cluster has the appropriate minimum permissions. For more information about access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Create an AKS cluster

1. Sign in to the [Azure portal](https://portal.azure.com).
2. On the Azure portal home page, select **Create a resource**.
3. In the **Categories** section, select **Infrastructure Services** &gt; **Azure Kubernetes Service (AKS)**.
4. On the **Basics** tab, configure the following settings:

    - Under **Project details**:

        - **Subscription**: Select the Azure subscription you want to use for this AKS cluster.
        - **Resource group**: Select **Create new**, enter a resource group name, like *myResourceGroup*, and then select **Ok**. While you can select an existing resource group, for testing or evaluation purposes, we recommend creating a resource group to temporarily host these resources and avoid impacting your production or development workloads.
    - Under **Cluster details**:

        - **Cluster preset configuration**: Select **Dev/Test**. For more details about preset configurations, see [Cluster configuration presets in the Azure portal](../quotas-skus-regions#cluster-configuration-presets-in-the-azure-portal). You can change the preset configuration when creating your cluster by selecting **Compare presets** and choosing a different option.

        [![Screenshot of Create AKS cluster - portal preset options.](media/quick-kubernetes-deploy-portal/cluster-presets.png)](media/quick-kubernetes-deploy-portal/cluster-presets.png#lightbox)

        - **Kubernetes cluster name**: Enter a cluster name, like *myAKSCluster*.
        - **Region**: Select a region, like *East US 2*.
        - **Fleet manager**: **None**
        - **Availability zones**: **None**. Deselect any selected zones.
        - **AKS pricing tier**: Select **Free**.
        - Leave the default values for the remaining settings, and select **Next**.

            [![Screenshot showing how to configure an AKS cluster in Azure portal.](media/quick-kubernetes-deploy-portal/create-cluster.png)](media/quick-kubernetes-deploy-portal/create-cluster.png#lightbox)
5. On the **Node pools** tab, configure the following settings:

    - Select **Add node pool** and select **Add a Virtual Machine Scale Set node pool**
    - **Name**: Enter a name like *nplinux*.
    - **Mode**: Select **User**.
    - **OS SKU**: Select **Ubuntu Linux**.
    - **Availability zones**: Select **None**.
    - Leave the **Enable Azure Spot instances** checkbox unchecked.
    - **Node size**: Select **Choose a size**. On the **Select a VM size** page, search for **D2s\_v5**, select that VM size, and **Select**.
    - Use the default values for the remaining settings, and select **Add**.

        [![Screenshot showing how to create a node pool running Ubuntu Linux.](media/quick-kubernetes-deploy-portal/create-linux-node-pool.png)](media/quick-kubernetes-deploy-portal/create-linux-node-pool.png#lightbox)
6. Select **Review + create** to run validation on the cluster configuration. After validation completes, select **Create**.

    It takes a few minutes to create the AKS cluster. When your deployment is complete, navigate to your resource by selecting **Go to resource**, or by browsing to the AKS cluster resource group and selecting the AKS resource.

## Connect to the cluster

You use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/), to manage Kubernetes clusters. `kubectl` is already installed if you use Azure Cloud Shell. If you're unfamiliar with the Cloud Shell, review [Overview of Azure Cloud Shell](/en-us/azure/cloud-shell/overview).

If you're using Cloud Shell, open it with the `>_` button on the top of the Azure portal. If you're using PowerShell locally, connect to Azure via the `Connect-AzAccount` command. If you're using Azure CLI locally, connect to Azure via the `az login` command.

# [Azure CLI](#tab/azure-cli)
1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
2. Verify the connection to your cluster using `kubectl get` to return a list of the cluster nodes.

    ```azurecli
    kubectl get nodes
    ```

    The following example output shows the single node created in the previous steps. Make sure the node status is *Ready*.

    ```output
    NAME                       STATUS   ROLES   AGE     VERSION
    aks-nodepool1-31718369-0   Ready    agent   6m44s   v1.15.10
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
2. Verify the connection to your cluster using `kubectl get` to return a list of the cluster nodes.

    ```azurepowershell
    kubectl get nodes
    ```

    The following example output shows the single node created in the previous steps. Make sure the node status is *Ready*.

    ```output
    NAME                       STATUS  ROLES   AGE     VERSION
    aks-nodepool1-31718369-0   Ready   agent   6m44s   v1.15.10
    ```

---

## Deploy the application

You use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A Kubernetes manifest file defines a cluster's desired state, like which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/quick-kubernetes-deploy-portal/aks-store-architecture.png)](media/quick-kubernetes-deploy-portal/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, like Rabbit MQ, without persistent storage for production. These containers are used here for simplicity, but we recommend using managed services, like Azure Cosmos DB or Azure Service Bus.

1. In the Cloud Shell, open an editor and create a file named `aks-store-quickstart.yaml`.
2. Paste the following manifest into the editor:

    ```YAML
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

    For a breakdown of YAML manifest files, see [Deployments and YAML manifests](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

    If you create and save the YAML file locally, then you can upload the manifest file to your default directory in CloudShell by selecting the **Upload/Download files** button and selecting the file from your local file system.
3. Deploy the application using the `kubectl apply` command and specify the name of your YAML manifest:

    ```bash
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

1. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make sure all pods are `Running` before proceeding.

    ```bash
    kubectl get pods
    ```
2. Check for a public IP address for the `store-front` application. Monitor progress using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```azurecli
    kubectl get service store-front --watch
    ```

    The **EXTERNAL-IP** output for the `store-front` service initially shows as *pending*:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   <pending>     80:30025/TCP   4h4m
    ```

    Once the **EXTERNAL-IP** address changes from *pending* to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.

    The following example output shows a valid public IP address assigned to the service:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   20.62.159.19   80:30025/TCP   4h5m
    ```
3. Open a web browser to the external IP address of your service to see the Azure Store app in action.

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-portal/aks-store-application.png)](media/quick-kubernetes-deploy-portal/aks-store-application.png#lightbox)

## Delete the cluster

If you don't plan on going through the [AKS tutorial series](../tutorial-kubernetes-prepare-app), clean up unnecessary resources to avoid Azure charges.

1. In the Azure portal, navigate to your AKS cluster resource group.
2. Select **Delete resource group**.
3. Enter the name of the resource group to delete, and then select **Delete** &gt; **Delete**.

    Note

    The AKS cluster was created with a system-assigned managed identity. This identity is managed by the platform and doesn't require removal.