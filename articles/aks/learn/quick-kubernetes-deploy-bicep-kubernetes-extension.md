---
layout: Conceptual
title: Deploy an AKS cluster using the Bicep Kubernetes extension - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep-kubernetes-extension
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
description: Learn how to quickly deploy a Kubernetes cluster using the Bicep Kubernetes extension and deploy an application in Azure Kubernetes Service (AKS).
author: schaffererin
ms.topic: quickstart
ms.subservice: aks-developer
ms.custom: devx-track-bicep
ms.date: 2024-01-11T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: 0484f51a-1250-4545-e135-c7397d625f73
document_version_independent_id: eef5bd22-8530-804c-e9d8-6cb67fd22b22
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-kubernetes-deploy-bicep-kubernetes-extension.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../toc.json
asset_id: aks/learn/quick-kubernetes-deploy-bicep-kubernetes-extension
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-kubernetes-deploy-bicep-kubernetes-extension.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f45d2af9-d67a-2eb7-0faf-a88532598aeb
---

# Deploy an AKS cluster using the Bicep Kubernetes extension - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this quickstart, you:

- Deploy an AKS cluster using the Bicep Kubernetes extension (preview).
- Run a sample multi-container application with a group of microservices and web front ends simulating a retail scenario.

Important

The Bicep Kubernetes extension is currently in preview. You can enable the feature from the [Bicep configuration file](/en-us/azure/azure-resource-manager/bicep/bicep-config#enable-experimental-features) by adding:

```json
{
 "experimentalFeaturesEnabled": {
   "extensibility": true,
 }
}
```

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Make sure that the identity you use to create your cluster has the appropriate minimum permissions. For more details on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).

[Bicep](/en-us/azure/azure-resource-manager/bicep/overview) is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. It provides concise syntax, reliable type safety, and support for code reuse. Bicep offers the best authoring experience for your infrastructure-as-code solutions in Azure.

- To set up your environment for Bicep development, see [Install Bicep tools](/en-us/azure/azure-resource-manager/bicep/install). After completing the steps, you have [Visual Studio Code](https://code.visualstudio.com/) and the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep). You also have either the latest [Azure CLI](/en-us/cli/azure/) version or the latest [Azure PowerShell module](/en-us/powershell/azure/new-azureps-module-az).
- To create an AKS cluster using a Bicep file, you provide an SSH public key. If you need this resource, see the following section. Otherwise, skip to Review the Bicep file.
- To deploy a Bicep file, you need write access on the resources you deploy and access to all operations on the `Microsoft.Resources/deployments` resource type. For example, to deploy a virtual machine, you need `Microsoft.Compute/virtualMachines/write` and `Microsoft.Resources/deployments/*` permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

### Create an SSH key pair

1. Go to https://shell.azure.com to open Cloud Shell in your browser.
2. Create an SSH key pair using the [az sshkey create](/en-us/cli/azure/sshkey#az-sshkey-create) Azure CLI command or the `ssh-keygen` command.

    ```azurecli
    # Create an SSH key pair using Azure CLI
    az sshkey create --name "mySSHKey" --resource-group "myResourceGroup"
    
    # Create an SSH key pair using ssh-keygen
    ssh-keygen -t rsa -b 4096
    ```

For more information about creating SSH keys, see [Create and manage SSH keys for authentication in Azure](/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

## Review the Bicep file

The Bicep file used to create an AKS cluster is from [Azure Quickstart Templates](https://azure.microsoft.com/resources/templates/aks/). For more AKS samples, see [AKS quickstart templates](https://azure.microsoft.com/resources/templates/?term=Azure+Kubernetes+Service).

```bicep
@description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
```

The resource defined in the Bicep file is [**Microsoft.ContainerService/managedClusters**](/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=bicep&amp;pivots=deployment-language-bicep).

Save a copy of the file as `main.bicep` to your local computer.

## Add the application definition

To deploy the application, you use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A [Kubernetes manifest file](../concepts-clusters-workloads#deployments-and-yaml-manifests) defines a cluster's desired state, such as which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/quick-kubernetes-deploy-bicep-kubernetes-extension/aks-store-architecture.png)](media/quick-kubernetes-deploy-bicep-kubernetes-extension/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production. These are used here for simplicity, but we recommend using managed services, such as Azure CosmosDB or Azure Service Bus.

1. Create a file named `aks-store-quickstart.yaml` in the same folder as `main.bicep` and copy in the following manifest:

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
2. Open `main.bicep` in Visual Studio Code.
3. Press Ctrl+Shift+P to open **Command Palette**.
4. Search for **bicep**, and then select **Bicep: Import Kubernetes Manifest**.

    [![Screenshot of Visual Studio Code import Kubernetes Manifest.](media/quick-kubernetes-deploy-bicep-kubernetes-extension/bicep-kubernetes-extension-import-kubernetes-manifest.png)](media/quick-kubernetes-deploy-bicep-kubernetes-extension/bicep-kubernetes-extension-import-kubernetes-manifest.png#lightbox)
5. Select `aks-store-quickstart.yaml` from the prompt. This process creates an `aks-store-quickstart.bicep` file in the same folder.
6. Open `main.bicep` and add the following Bicep at the end of the file to reference the newly created `aks-store-quickstart.bicep` module:

    ```bicep
    module kubernetes './aks-store-quickstart.bicep' = {
      name: 'buildbicep-deploy'
      params: {
        kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
      }
    }
    ```
7. Save both `main.bicep` and `aks-store-quickstart.bicep`.

## Deploy the Bicep file

# [Azure CLI](#tab/azure-cli)
1. Create an Azure resource group using the [az group create](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name myResourceGroup --location eastus
    ```
2. Deploy the Bicep file using the [az deployment group create](/en-us/cli/azure/deployment/group#az-deployment-group-create) command.

    ```azurecli
    az deployment group create --resource-group myResourceGroup --template-file main.bicep --parameters clusterName=<cluster-name> dnsPrefix=<dns-previs> linuxAdminUsername=<linux-admin-username> sshRSAPublicKey='<ssh-key>'
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Create an Azure resource group using the [New-AzResourceGroup](/en-us/powershell/module/az.resources/new-azresourcegroup) cmdlet.

    ```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    ```
2. Deploy the Bicep file using the [New-AzResourceGroupDeployment](/en-us/powershell/module/az.resources/new-azresourcegroupdeployment) cmdlet.

    ```azurepowershell
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep -clusterName=<cluster-name> -dnsPrefix=<dns-prefix> -linuxAdminUsername=<linux-admin-username> -sshRSAPublicKey="<ssh-key>"
    ```

---

Provide the following values in the commands:

- **Cluster name**: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
- **DNS prefix**: Enter a unique DNS prefix for your cluster, such as *myakscluster*.
- **Linux Admin Username**: Enter a username to connect using SSH, such as *azureuser*.
- **SSH RSA Public Key**: Copy and paste the *public* part of your SSH key pair (by default, the contents of *~/.ssh/id\_rsa.pub*).

It takes a few minutes to create the AKS cluster. Wait for the cluster successfully deploy before you move on to the next step.

## Validate the Bicep deployment

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. On the Azure portal menu or from the **Home** page, navigate to your AKS cluster.
3. Under **Kubernetes resources**, select **Services and ingresses**.
4. Find the **store-front** service and copy the value for **External IP**.
5. Open a web browser to the external IP address of your service to see the Azure Store app in action.

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-bicep-kubernetes-extension/aks-store-application.png)](media/quick-kubernetes-deploy-bicep-kubernetes-extension/aks-store-application.png#lightbox)

## Delete the cluster

If you don't plan on going through the [AKS tutorial](../tutorial-kubernetes-prepare-app), clean up unnecessary resources to avoid Azure charges.

# [Azure CLI](#tab/azure-cli)
Remove the resource group, container service, and all related resources using the [az group delete](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
az group delete --name myResourceGroup --yes --no-wait
```

# [Azure PowerShell](#tab/azure-powershell)
Remove the resource group, container service, and all related resources using the [Remove-AzResourceGroup](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet.

```azurepowershell
Remove-AzResourceGroup -Name myResourceGroup
```

---

Note

The AKS cluster was created with a system-assigned managed identity, which is the default identity option used in this quickstart. The platform manages this identity so you don't need to manually remove it.