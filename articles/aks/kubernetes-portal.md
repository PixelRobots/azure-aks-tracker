---
layout: Conceptual
title: Access Kubernetes Resources using the Azure Portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-portal
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
description: Learn how to access and manage your Azure Kubernetes Service (AKS) resources using the Azure portal.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.date: 2026-01-26T00:00:00.0000000Z
locale: en-us
document_id: 43bb2465-05b5-5907-9455-ecd506dc1849
document_version_independent_id: 455f9fc6-0f9b-b2fc-4ada-6fb5e8106ed8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/kubernetes-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/970f20f1-2f12-4aa9-9c95-c00fe1f5e722
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/432c4950-b799-4ed5-93d5-b9b2934edf7d
platformId: 4f305a40-9212-8c60-bfa3-0e3002f41404
---

# Access Kubernetes Resources using the Azure Portal - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to access and manage your Azure Kubernetes Service (AKS) resources using the Azure portal.

## Prerequisites

- An existing AKS cluster. Any cluster is supported, but if you're using Microsoft Entra integration, your cluster must use [Microsoft Entra integration](managed-azure-ad).
- If your cluster uses legacy Microsoft Entra ID, you can upgrade your cluster in the portal or with the [Azure CLI](managed-azure-ad#migrate-a-legacy-azure-ad-cluster-to-integration). You can also use the [Azure portal](learn/quick-kubernetes-deploy-portal) to create a new AKS cluster.

## View Kubernetes resources

Select **Kubernetes resources**. The Kubernetes resources list displays the following categories:

- **Namespaces** shows information about the namespaces of your cluster.
- **Workloads** shows information about deployments, pods, replica sets, stateful sets, daemon sets, jobs, and cron jobs deployed to your cluster.
- **Services and ingresses** shows all of your cluster's service and ingress resources.
- **Network policies** shows the network policy resources that control traffic flow between pods within your cluster.
- **Storage** shows your Azure storage classes and persistent volume information.
- **Configuration** shows your cluster's config maps and secrets.
- **Custom resources** shows any custom resources deployed to your cluster.
- **Events** shows all events related to your cluster.
- **Run command** allows you to remotely invoke commands, like `kubectl` and `helm`, on your cluster through the Azure API without directly connecting to the cluster.

[![Screenshot showing the Kubernetes resources displayed in the Azure portal.](media/kubernetes-portal/kubernetes-resources.png)](media/kubernetes-portal/kubernetes-resources.png#lightbox)

## Connect to your AKS cluster

To deploy the Azure Store application, you need to connect to your AKS cluster. Follow these steps to connect to your cluster using the Azure portal:

1. From the **Overview** page of your AKS cluster, select **Connect**.
2. Follow the instructions to connect to your cluster using *Cloud Shell*, *Azure CLI*, or *Run command*.

## Deploy the Azure Store application

In this section, we deploy the Azure Store application from the [AKS quickstart](learn/quick-kubernetes-deploy-portal).

1. From the **Kubernetes resources** list, select **Services and ingresses**.
2. Select **Create** &gt; **Apply a YAML**.
3. Copy and paste the following YAML into the editor:

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
              image: mcr.microsoft.com/azurelinux/base/rabbitmq-server:3.13
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
                  cpu: 100m
                  memory: 256Mi
          initContainers:
            - name: wait-for-rabbitmq
              image: busybox
              command: ["sh", "-c", "until nc -zv rabbitmq 5672; do echo waiting for rabbitmq; sleep 2; done;"]
              resources:
                requests:
                  cpu: 1m
                  memory: 50Mi
                limits:
                  cpu: 100m
                  memory: 256Mi
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
                  cpu: 2m
                  memory: 20Mi
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
4. Select **Apply**.

    Once the application finishes deploying, you see the following services in the *Services* list:

    - `order-service`
    - `product-service`
    - `rabbitmq`
    - `store-front`

    [![Screenshot of the Azure Store application services displayed in the Azure portal.](media/kubernetes-portal/portal-services.png)](media/kubernetes-portal/portal-services.png#lightbox)

## Monitor deployment insights

### Enable the monitoring add-on on your AKS cluster

AKS clusters with [Container Insights](/en-us/azure/azure-monitor/containers/container-insights-enable-existing-clusters) enabled can access various deployment insights in the Azure portal. If you don't have monitoring enabled on your cluster, you can enable it using the following steps:

1. From the service menu of your AKS cluster resource, select **Monitoring** &gt; **Insights** &gt; **Configure monitoring**.
2. On the **Configure Container Insights** page, select **Configure**.

    It might take a few minutes for the monitoring solution to deploy and begin collecting data.

### View deployment insights

1. From the service menu of your AKS cluster resource, select **Workloads**.
2. Select a deployment from the list to view deployment insights, such as CPU and memory usage.

Tip

You can also select **Monitoring** &gt; **Insights** to view more in-depth information about specific nodes and containers.

## Clean up resources

If you no longer need the Azure Store application, you can delete the services to avoid incurring Azure costs.

1. From the **Kubernetes resources** list, select **Services and ingresses**.
2. Select the services you want to delete, then select **Delete**.

## Troubleshooting

### Unauthorized access

To access the Kubernetes resources, you need access to the AKS cluster, Kubernetes API, and Kubernetes objects. Make sure you're either a **Cluster Administrator** or a user with the appropriate permissions delegated to access the AKS cluster. For more information, see [Access and identity options for AKS](concepts-identity).

### Viewing Kubernetes resources is inaccessible

You might need to configure authorized IP ranges to enable the Kubernetes resource view for existing clusters.

Tip

You can add the AKS feature for [**API server authorized IP ranges**](api-server-authorized-ip-ranges) to limit API server access to only the firewall's public endpoint. Another option is to update the `--api-server-authorized-ip-ranges`/`-ApiServerAccessAuthorizedIpRange` to include access for a local client computer or the IP address range from which you're browsing the Azure portal. To allow this access, you need the computer's public IPv4 address. You can find this address using the following Azure CLI or Azure PowerShell commands.

# [Azure CLI](#tab/azure-cli)
1. Retrieve your IP address using the following command:

    ```azurecli
    CURRENT_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
    ```
2. Add your IP address to the AKS approved list using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--api-server-authorized-ip-ranges` parameter.

    ```azurecli
    az aks update --resource-group <resource-group-name> --name <cluster-name> --api-server-authorized-ip-ranges $CURRENT_IP/32
    ```
3. After updating your cluster's authorized IP ranges, run the following command to update and merge your kubeconfig:

    ```azurecli
    az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
    ```

    The expected output informs you of this update:

    ```output
    Merged "<cluster-name>" as current context ...
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Retrieve your IP address using the following command:

    ```azurepowershell
    $CURRENT_IP = (Invoke-RestMethod -Uri http://ipinfo.io/json).ip
    ```
2. Add your IP address to the AKS approved list using the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) command with the `-ApiServerAccessAuthorizedIpRange` parameter.

    ```azurepowershell
    Set-AzAksCluster -ResourceGroupName <resource-group-name> -Name <cluster-name> -ApiServerAccessAuthorizedIpRange $CURRENT_IP/32
    ```
3. After updating your cluster's authorized IP ranges, run the following command to update and merge your kubeconfig:

    ```azurepowershell
    Get-AzAksCredential -ResourceGroupName <resource-group-name> -Name <cluster-name>
    ```

    The expected output informs you of this update:

    ```output
    Merged "<cluster-name>" as current context ...
    ```

---

If your AKS cluster is configured as a *private cluster*, you must access the Azure portal from a network that can reach the subnet where your AKS cluster resides. Otherwise, AKS resources are inaccessible in the portal due to network connectivity issues. To learn more, see [Access an AKS private cluster](/en-us/azure/architecture/guide/security/access-azure-kubernetes-service-cluster-api-server#access-an-aks-private-cluster).