---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster with Flatcar Container Linux for AKS (preview) using an ARM template - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-flatcar-deploy-arm-template
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
description: Learn how to quickly deploy a Kubernetes cluster with Flatcar Container Linux for AKS (preview) using an Azure Resource Manager template and deploy an application in Azure Kubernetes Service (AKS).
ms.topic: quickstart
ms.date: 2025-11-10T00:00:00.0000000Z
author: allyford
ms.author: allyford
locale: en-us
document_id: c314cd20-6f04-d416-8427-c1835497be33
document_version_independent_id: 471ddd52-7311-11b6-a191-1d02762084b7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-flatcar-deploy-arm-template.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: ../toc.json
asset_id: aks/learn/quick-flatcar-deploy-arm-template
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-flatcar-deploy-arm-template.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ba3cc031-44b4-f3fb-fc47-fadf9ba99bb2
---

# Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster with Flatcar Container Linux for AKS (preview) using an ARM template - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this quickstart, you:

- Create an AKS cluster using Flatcar Container Linux for AKS (preview).
- Deploy an AKS cluster using an Azure Resource Manager template.
- Run a sample multi-container application with a group of microservices and web front ends simulating a retail scenario.

An [Azure Resource Manager template](/en-us/azure/azure-resource-manager/templates/overview) is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax. You describe your intended deployment without writing the sequence of programming commands to create the deployment.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This article assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Make sure that the identity you use to create your cluster has the appropriate minimum permissions. For more details on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).
- To deploy an ARM template, you need write access on the resources you're deploying and access to all operations on the `Microsoft.Resources/deployments` resource type. For example, to deploy a virtual machine, you need `Microsoft.Compute/virtualMachines/write` and `Microsoft.Resources/deployments/*` permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

After you deploy the cluster from the template, you can use either Azure CLI or Azure PowerShell to connect to the cluster and deploy the sample application.

## Register resource providers

You might need to register resource providers in your Azure subscription. For example, `Microsoft.ContainerService` is required.

Check the registration status using the [`az provider show`](/en-us/cli/azure/provider#az-provider-show) command.

```azurecli
az provider show --namespace Microsoft.ContainerService --query registrationState
```

If necessary, register the resource provider using the [az provider register](/en-us/cli/azure/provider#az-provider-register) command.

```azurecli
az provider register --namespace Microsoft.ContainerService
```

## Install `aks-preview` extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. **Flatcar Container Linux requires a minimum of 18.0.0b42**.

    ```azurecli
    az extension update --name aks-preview
    ```

## Register `AKSFlatcarPreview` feature flag

1. Register the `AKSFlatcarPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AKSFlatcarPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AKSFlatcarPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

### Create an SSH key pair

To create an AKS cluster using an ARM template, you provide an SSH public key. If you need this resource, follow the steps in this section. Otherwise, skip to the Review the template section.

To access AKS nodes, you connect using an SSH key pair (public and private). To create an SSH key pair:

1. Go to https://shell.azure.com to open Cloud Shell in your browser.
2. Create a resource group using the [az group create](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create \
      --name myResourceGroup \
      --location eastus
    ```
3. Create an SSH key pair using the [az sshkey create](/en-us/cli/azure/sshkey#az-sshkey-create) command or the `ssh-keygen` command.

    ```azurecli
    az sshkey create --name mySSHKey --resource-group myResourceGroup
    ```

    Or create an SSH key pair using ssh-keygen

    ```bash
    ssh-keygen -t rsa -b 4096
    ```
4. To deploy the template, you must provide the public key from the SSH pair. Retrieve the public key using the [`az sshkey show`](/en-us/cli/azure/sshkey#az-sshkey-show) command.

    ```azurecli
    az sshkey show --name mySSHKey --resource-group myResourceGroup --query publicKey
    ```

    By default, the SSH key files are created in the *~/.ssh* directory. Running the `az sshkey create` or `ssh-keygen` command overwrites any existing SSH key pair with the same name.

    For more information about creating SSH keys, see [Create and manage SSH keys for authentication in Azure](/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

## Review the template

The template used in this quickstart is from [Azure Quickstart Templates](https://azure.microsoft.com/resources/templates/aks/).

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.26.170.59819",
      "templateHash": "14823542069333410776"
    }
  },
  "parameters": {
    "clusterName": {
      "type": "string",
      "defaultValue": "aks101cluster",
      "metadata": {
        "description": "The name of the Managed Cluster resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location of the Managed Cluster resource."
      }
    },
    "dnsPrefix": {
      "type": "string",
      "metadata": {
        "description": "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
      }
    },
    "osDiskSizeGB": {
      "type": "int",
      "defaultValue": 0,
      "minValue": 0,
      "maxValue": 1023,
      "metadata": {
        "description": "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize."
      }
    },
    "agentCount": {
      "type": "int",
      "defaultValue": 3,
      "minValue": 1,
      "maxValue": 50,
      "metadata": {
        "description": "The number of nodes for the cluster."
      }
    },
    "agentVMSize": {
      "type": "string",
      "defaultValue": "standard_d2s_v3",
      "metadata": {
        "description": "The size of the Virtual Machine."
      }
    },
    "linuxAdminUsername": {
      "type": "string",
      "metadata": {
        "description": "User name for the Linux Virtual Machines."
      }
    },
    "sshRSAPublicKey": {
      "type": "string",
      "metadata": {
        "description": "Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example 'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm'"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2024-02-01",
      "name": "[parameters('clusterName')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "dnsPrefix": "[parameters('dnsPrefix')]",
        "agentPoolProfiles": [
          {
            "name": "agentpool",
            "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
            "count": "[parameters('agentCount')]",
            "vmSize": "[parameters('agentVMSize')]",
            "osType": "Linux",
            "mode": "System"
          }
        ],
        "linuxProfile": {
          "adminUsername": "[parameters('linuxAdminUsername')]",
          "ssh": {
            "publicKeys": [
              {
                "keyData": "[parameters('sshRSAPublicKey')]"
              }
            ]
          }
        }
      }
    }
  ],
  "outputs": {
    "controlPlaneFQDN": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '2024-02-01').fqdn]"
    }
  }
}
```

The resource type defined in the ARM template is [**Microsoft.ContainerService/managedClusters**](/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-arm-template).

For more AKS samples, see the [AKS quickstart templates](https://azure.microsoft.com/resources/templates/?term=Azure+Kubernetes+Service) site.

## Deploy the template

1. Select **Deploy to Azure** to sign in and open a template.

    [![Button to deploy the Resource Manager template to Azure.](../../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks%2Fazuredeploy.json)
2. On the **Basics** page, leave the default values for the *OS Disk Size GB*, *Agent Count*, *Agent VM Size*, and *OS Type*, and configure the following template parameters:

    - **Subscription**: Select an Azure subscription.
    - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *myResourceGroup*, then select **OK**.
    - **OS SKU**: Specify **flatcar**, if you do not update OS SKU, the default will be `Ubuntu`.
    - **Location**: Select a location, such as **East US**.
    - **Cluster name**: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
    - **DNS prefix**: Enter a unique DNS prefix for your cluster, such as *myakscluster*.
    - **Linux Admin Username**: Enter a username to connect using SSH, such as *azureuser*.
    - **SSH public key source**: Select **Use existing public key**.
    - **Key pair name**: Copy and paste the *public* part of your SSH key pair (by default, the contents of *~/.ssh/id\_rsa.pub*).
3. Select **Review + Create** &gt; **Create**.

It takes a few minutes to create the AKS cluster. Wait for the cluster to be successfully deployed before you move on to the next step.

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/).

# [Azure CLI](#tab/azure-cli)
If you use Azure Cloud Shell, `kubectl` is already installed. To install and run `kubectl` locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az_aks_install_cli) command.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials \
      --resource-group myResourceGroup \
      --name myAKSCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following example output shows the three nodes created in the previous steps. Make sure the node status is *Ready*:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-agentpool-38955149-vmss000000   Ready    <none>   5m53s   v1.32.7
    aks-agentpool-38955149-vmss000001   Ready    <none>   6m31s   v1.32.7
    aks-agentpool-38955149-vmss000002   Ready    <none>   6m35s   v1.32.7
    ```

# [Azure PowerShell](#tab/azure-powershell)
If you use Azure Cloud Shell, `kubectl` is already installed. To install `kubectl` locally, use the [`Install-AzAksCliTool`](/en-us/powershell/module/az.aks/install-azaksclitool) cmdlet.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following example output shows the three nodes created in the previous steps. Make sure the node status is *Ready*:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-agentpool-38955149-vmss000000   Ready    <none>   5m53s   v1.32.7
    aks-agentpool-38955149-vmss000001   Ready    <none>   6m31s   v1.32.7
    aks-agentpool-38955149-vmss000002   Ready    <none>   6m35s   v1.32.7
    ```

---

## Deploy the application

To deploy the application, you use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A [Kubernetes manifest file](../concepts-clusters-workloads#deployments-and-yaml-manifests) defines a cluster's desired state, such as which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/quick-kubernetes-deploy-rm-template/aks-store-architecture.png)](media/quick-kubernetes-deploy-rm-template/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production. These are used here for simplicity, but we recommend using managed services, such as Azure Cosmos DB or Azure Service Bus.

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
2. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

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

1. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make all pods are `Running` before proceeding.

    ```bash
    kubectl get pods
    ```
2. Check for a public IP address for the store-front application. Monitor progress using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```bash
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
4. Open a web browser to the external IP address of your service to see the Azure Store app in action:

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-rm-template/aks-store-application.png)](media/quick-kubernetes-deploy-rm-template/aks-store-application.png#lightbox)

## Delete the cluster

If you don't plan on going through the [AKS tutorial](../tutorial-kubernetes-prepare-app), clean up unnecessary resources to avoid Azure charges.

# [Azure CLI](#tab/azure-cli)
- Remove the resource group, container service, and all related resources using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command.

```azurecli
az group delete --name myResourceGroup
```

# [Azure PowerShell](#tab/azure-powershell)
- Remove the resource group, container service, and all related resources using the [`Remove-AzResourceGroup`](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet.

    ```azurepowershell
    Remove-AzResourceGroup -Name myResourceGroup
    ```

---

Note

The AKS cluster was created with a system-assigned managed identity, which is the default identity option used in this quickstart. The platform manages this identity, so you don't need to manually remove it.