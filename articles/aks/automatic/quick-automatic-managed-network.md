---
layout: Conceptual
title: 'Quickstart: Create an Azure Kubernetes Service (AKS) Automatic cluster - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/automatic/quick-automatic-managed-network
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in Azure Kubernetes Service (AKS) Automatic.
ms.topic: quickstart
ms.custom: build-2024, devx-track-azurecli, devx-track-bicep, devx-track-terraform, ignite-2024, build-2026
ms.date: 2026-09-15T00:00:00.0000000Z
author: wangyira
ms.author: wangamanda
zone_pivot_groups: bicep-azure-cli-portal-terraform
locale: en-us
document_id: d3eb1dd7-e332-db7f-159e-f2792f6a0110
document_version_independent_id: eb4c0553-a01d-5ae7-2591-9359edc5e413
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/automatic/quick-automatic-managed-network.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/automatic/quick-automatic-managed-network
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/automatic/quick-automatic-managed-network.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: f688fb37-2b72-1c33-058d-e403ff95301e
---

# Quickstart: Create an Azure Kubernetes Service (AKS) Automatic cluster - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic

[Azure Kubernetes Service (AKS) Automatic](../intro-aks-automatic) is a managed Kubernetes experience that automates AKS cluster setup and operations and embeds best practice configurations. AKS Automatic also includes a [pod readiness SLA][azure-sla] that guarantees 99.9% of qualifying pod readiness operations complete within 5 minutes, guaranteeing reliable, self-healing infrastructure for your applications. In this quickstart, you learn how to:

- Deploy an AKS Automatic cluster.
- Run a sample multi-container application with a group of microservices and web front ends simulating a retail scenario.

## Before you begin

- This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).
- AKS Automatic [enables Azure Policy on your AKS cluster](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#install-azure-policy-add-on-for-aks), but you should preregister the `Microsoft.PolicyInsights` resource provider in your subscription. For more information, see [Azure resource providers and types](/en-us/cli/azure/provider#az-provider-register).

::: zone pivot="azure-cli"

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- Azure CLI version 2.86.0 or later. To find the version, run `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/get-started-with-azure-cli).
- If you have multiple Azure subscriptions, select the appropriate subscription ID to bill resources to using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

::: zone-end

::: zone pivot="bicep"

- To deploy a Bicep file, you need write access on the resources you create and access to all operations on the `Microsoft.Resources/deployments` resource type. For example, to create a virtual machine (VM), you need `Microsoft.Compute/virtualMachines/write` and `Microsoft.Resources/deployments/*` permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

::: zone-end

::: zone pivot="terraform"

- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).

Note

This sample creates the AKS Automatic cluster with the AzureRM provider's [`azurerm_kubernetes_automatic_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_automatic_cluster) resource, which requires AzureRM provider version `v4.81` or later. For an equivalent sample that uses the [AzAPI provider](https://registry.terraform.io/providers/Azure/azapi/latest/docs) instead, see [101-aks-automatic-azapi](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-automatic-azapi). Reach for AzAPI when you need direct control over the managed cluster API payload, or an API version or property that the AzureRM provider hasn't surfaced yet.

::: zone-end

Important

Starting on AKS 1.36, new AKS Automatic clusters will by default enable [Kubernetes Gateway API via the application routing add-on](../app-routing-gateway-api) instead of [Managed NGINX ingress with the application routing add-on](../app-routing) due to the upstream [Ingress NGINX retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/).

Existing Automatic clusters aren't affected but should begin migration to [Kubernetes Gateway API via the application routing add-on](../app-routing-gateway-api#enable-for-an-existing-cluster).

## Limitations

The following limitations apply to AKS Automatic clusters:

- AKS Automatic is generally available in the following regions: `australiacentral`, `australiaeast`, `australiasoutheast`, `austriaeast`, `belgiumcentral`, `brazilsouth`, `canadacentral`, `canadaeast`, `centralindia`, `centralus`, `chilecentral`, `denmarkeast`, `eastasia`, `eastus`, `eastus2`, `francecentral`, `germanywestcentral`, `indonesiacentral`, `israelcentral`, `italynorth`, `japaneast`, `japanwest`, `koreacentral`, `koreasouth`, `malaysiawest`, `mexicocentral`, `newzealandnorth`, `northcentralus`, `northeurope`, `norwayeast`, `polandcentral`, `southafricanorth`, `southcentralus`, `southeastasia`, `southindia`, `spaincentral`, `swedencentral`, `switzerlandnorth`, `uaenorth`, `uksouth`, `ukwest`, `westcentralus`, `westeurope`, `westus`, `westus2`, `westus3`.
- New AKS Automatic clusters by default enable managed system node pools and [LocalDNS](../dns-concepts#localdns-in-azure-kubernetes-service). You can't create AKS Automatic clusters without managed system node pools in any region.
- AKS Automatic cluster has [node resource group lockdown](../node-resource-group-lockdown) preconfigured, which doesn't allow changes to the `MC_` resource group, preventing virtual network links on the default Private DNS zone. For cross‑VNet or custom DNS scenarios, use custom network and private DNS by following [Create a private Azure Kubernetes Service (AKS) Automatic cluster in a custom virtual network](quick-automatic-private-custom-network).
- Azure CLI version 2.86.0 or later is required. To find the version, run `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/get-started-with-azure-cli).
- The following extensions aren't supported:
    - [Dapr](../dapr)
    - [Azure Machine Learning](/en-us/azure/machine-learning/how-to-attach-kubernetes-anywhere)
- Windows nodes aren't supported.
- Migration from AKS base SKU to automatic SKU isn't supported.
- Migration from an existing AKS Automatic cluster without managed system node pools to AKS Automatic with managed system node pools is supported in preview in regions where managed system node pools are generally available. Migration from AKS Automatic with managed system node pools back to AKS Automatic without managed system node pools isn't supported.

::: zone pivot="azure-cli,bicep"

## Create a resource group

An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) is a logical group in which Azure resources are deployed and managed.

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command. The following example creates a resource group named *myResourceGroup* in the *canadacentral* location:

```azurecli
az group create --name myResourceGroup --location canadacentral
```

The following sample output resembles successful creation of the resource group:

```output
{
  "id": "/subscriptions/<guid>/resourceGroups/myResourceGroup",
  "location": "canadacentral",
  "managedBy": null,
  "name": "myResourceGroup",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null
}
```

::: zone-end

::: zone pivot="azure-cli"

## Create an AKS Automatic cluster

Create an AKS Automatic cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--sku` parameter set to `automatic`. The following example creates a cluster named *myAKSAutomaticCluster* with Managed Prometheus and the Container Insights integration enabled:

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSAutomaticCluster \
    --sku automatic
    --enable-hosted-system
```

When the deployment finishes, the output shows a `hostedSystemProfile` property with the `enabled` property set to `true`. You can also run the following command to display the `hostedSystemProfile` properties:

```azurecli
az aks show \
  --resource-group myResourceGroup \
  --name myAKSAutomaticCluster \
  --query hostedSystemProfile
```

```output
{
  "enabled": true,
  "nodeSubnetId": null,
  "systemNodeSubnetId": null
}
```

::: zone-end

::: zone pivot="azure-portal"

## Create Automatic Kubernetes cluster

1. To create an AKS Automatic cluster, search for and select **Kubernetes services**. This takes you to the **Kubernetes center (preview)** page.
2. On the **Kubernetes center (preview)** page, select **Create** &gt; **Automatic Kubernetes cluster**.

    ![The screenshot of the Create Automatic AKS cluster button in the Azure portal.](../media/automatic/quick-automatic-managed-network/create-automatic-cluster.png)
3. On the **Basics** tab, fill in all the required fields (Subscription, Resource group, Kubernetes cluster name, and Region), and then select **Next**.

    ![The screenshot of the Create - Basics Tab for an AKS Automatic cluster in the Azure portal.](../media/automatic/quick-automatic-managed-network/create-automatic-cluster-basics.png)
4. On the **Monitoring** tab, select your desired monitoring configurations from Azure Monitor (Container Insights), Managed Prometheus, Grafana Dashboards, and Alerts, and then select **Next**.

    ![The screenshot of the Monitoring Tab while creating an AKS Automatic cluster in the Azure portal.](../media/automatic/quick-automatic-managed-network/create-automatic-cluster-monitoring.png)
5. On the **Advanced** tab, select your desired advanced configurations Private access, Azure Virtual Networking, Managed identity, Container Network Security (ACNS), and Managed Kubernetes Namespaces, and then select **Review + create**.

    ![The screenshot of the Advanced Tab while creating an AKS Automatic cluster in the Azure portal.](../media/automatic/quick-automatic-managed-network/create-automatic-cluster-advanced.png)
6. Review the configurations on the **Review + create** tab, and then select **Create** to deploy the AKS Automatic cluster.
7. Get started with configuring your first application from GitHub and set up an automated deployment pipeline.

    ![The screenshot of the Get Started Tab on Overview Blade after creating an AKS Automatic cluster in the Azure portal.](../learn/media/quick-automatic-kubernetes-portal/automatic-overview.png)

::: zone-end

::: zone pivot="bicep"

## Review the Bicep file

The following Bicep file defines an AKS Automatic cluster:

```bicep
@description('The name of the managed cluster resource.')
param clusterName string = 'myAKSAutomaticCluster'

@description('The location of the managed cluster resource.')
param location string = resourceGroup().location

resource aks 'Microsoft.ContainerService/managedClusters@2026-02-01' ' = {
  name: clusterName
  location: location
  sku: {
    name: 'Automatic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
```

For more information about the resource defined in the Bicep file, see the [**Microsoft.ContainerService/managedClusters**](/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=bicep&amp;pivots=deployment-language-bicep) reference.

## Deploy the Bicep file

1. Save the Bicep file as **main.bicep** to your local computer.

    Important

    The Bicep file sets the `clusterName` param to the string *myAKSAutomaticCluster*. If you want to use a different cluster name, make sure to update the string to your preferred cluster name before saving the file to your computer.
2. Deploy the Bicep file using the [`az deployment group create`][az-deployment-group-create] command.

    ```azurecli
    az deployment group create --resource-group myResourceGroup --template-file main.bicep
    ```

    It takes a few minutes to create the AKS cluster. Wait for the cluster to be successfully deployed before you move on to the next step.

::: zone-end

::: zone pivot="terraform"

## Review the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-automatic). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-automatic/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

1. Create a directory to test the sample Terraform code and set it as the current directory.
2. Create a file named `providers.tf` and insert the following code:

    ```terraform
    terraform {
      required_version = ">= 1.0"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~>5.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~>3.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    ```
3. Create a file named `main.tf` and add the following code:

    ```terraform
    # Create a random name for the resource group using random_pet
    resource "random_pet" "rg_name" {
      prefix = var.resource_group_name_prefix
    }
    
    # Create a resource group using the generated random name
    resource "azurerm_resource_group" "rg" {
      location = var.resource_group_location
      name     = random_pet.rg_name.id
    }
    
    # Create a random name for the AKS Automatic cluster
    resource "random_pet" "cluster_name" {
      prefix = var.cluster_name_prefix
    }
    
    # Create the AKS Automatic cluster
    resource "azurerm_kubernetes_automatic_cluster" "aks_automatic" {
      name                = random_pet.cluster_name.id
      location            = azurerm_resource_group.rg.location
      resource_group_name = azurerm_resource_group.rg.name
    
      identity {
        type = "SystemAssigned"
      }
    }
    ```
4. Create a file named `variables.tf` and add the following code:

    ```terraform
    variable "resource_group_location" {
      type        = string
      default     = "westus2"
      description = "Location of the resource group."
    }
    
    variable "resource_group_name_prefix" {
      type        = string
      default     = "rg"
      description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
    }
    
    variable "cluster_name_prefix" {
      type        = string
      default     = "aks-automatic"
      description = "Prefix of the AKS Automatic cluster name that's combined with a random ID so the name is unique in your Azure subscription."
    }
    ```
5. Create a file named `outputs.tf` and insert the following code:

    ```terraform
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "cluster_name" {
      value = azurerm_kubernetes_automatic_cluster.aks_automatic.name
    }
    
    output "cluster_id" {
      value = azurerm_kubernetes_automatic_cluster.aks_automatic.id
    }
    
    output "node_resource_group_id" {
      value = azurerm_kubernetes_automatic_cluster.aks_automatic.node_resource_group_id
    }
    
    output "fully_qualified_domain_name" {
      value = azurerm_kubernetes_automatic_cluster.aks_automatic.fully_qualified_domain_name
    }
    ```

## Initialize Terraform

Run [terraform init](https://developer.hashicorp.com/terraform/cli/commands/init) to initialize the Terraform deployment. This command downloads the Azure providers required to manage your Azure resources.

```console
terraform init -upgrade
```

## Create a Terraform execution plan

Run [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan) to create an execution plan.

```console
terraform plan -out main.tfplan
```

## Apply a Terraform execution plan

Run [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the execution plan to your cloud infrastructure.

```console
terraform apply main.tfplan
```

Creating an AKS Automatic cluster takes several minutes to complete.

## Verify the cluster

1. Get the Azure resource group name and cluster name.

    ```console
    resource_group_name=$(terraform output -raw resource_group_name)
    cluster_name=$(terraform output -raw cluster_name)
    ```
2. Run [az aks show](/en-us/cli/azure/aks#az-aks-show) to display the cluster and confirm it uses the `Automatic` SKU.

    ```azurecli
    az aks show --resource-group $resource_group_name --name $cluster_name --query "{name:name, sku:sku, provisioningState:provisioningState}"
    ```

::: zone-end

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). `kubectl` is already installed if you use Azure Cloud Shell. You can install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command. AKS Automatic clusters are configured with [Microsoft Entra ID for Kubernetes role-based access control (RBAC)](../entra-id-authorization).

Note

When you create a cluster using the Azure CLI, your user is [assigned built-in roles](../entra-id-authorization#create-role-assignments-for-cluster-access) for `Azure Kubernetes Service RBAC Cluster Admin`.

::: zone pivot="azure-cli,bicep,azure-portal"

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSAutomaticCluster
    ```

::: zone-end

::: zone pivot="terraform"

1. Configure `kubectl` to connect to your Kubernetes cluster by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group $resource_group_name --name $cluster_name
    ```

::: zone-end

1. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following sample output shows how you're asked to sign in:

    ```output
    To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code AAAAAAAAA to authenticate.
    ```

    After you sign in, the following sample output shows the managed system node pools. Make sure the node status is *Ready*.

    ```output
    NAME                           STATUS   ROLES    AGE   VERSION
    aks-hostedpool-16652789-vms1   Ready    <none>   19m   v1.34.7
    aks-hostedpool-16652789-vms2   Ready    <none>   19m   v1.34.7
    aks-hostedpool-16652789-vms3   Ready    <none>   19m   v1.34.7
    aks-system-surge-zq4d2         Ready    <none>   19m   v1.34.7
    ```

## Deploy the application

To deploy the application, you use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A [Kubernetes manifest file](../concepts-clusters-workloads#deployments-and-yaml-manifests) defines a cluster's desired state, such as which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](../learn/media/quick-kubernetes-deploy-portal/aks-store-architecture.png)](../learn/media/quick-kubernetes-deploy-portal/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production. These are used here for simplicity, but we recommend using managed services, such as Azure Cosmos DB or Azure Service Bus.

1. Create a namespace `aks-store-demo` to deploy the Kubernetes resources into.

    ```bash
    kubectl create ns aks-store-demo
    ```
2. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command into the `aks-store-demo` namespace. The YAML file defining the deployment is on [GitHub](https://github.com/Azure-Samples/aks-store-demo).

    ```bash
    kubectl apply -n aks-store-demo -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-ingress-quickstart.yaml
    ```

    The following sample output shows the deployments and services:

    ```output
    statefulset.apps/rabbitmq created
    configmap/rabbitmq-enabled-plugins created
    service/rabbitmq created
    deployment.apps/order-service created
    service/order-service created
    deployment.apps/product-service created
    service/product-service created
    deployment.apps/store-front created
    service/store-front created
    ingress/store-front created
    ```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete.

1. Check the status of the deployed pods using the [kubectl get pods](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make sure all pods are `Running` before proceeding. If this is the first workload you deploy, it might take a few minutes for [node auto provisioning](../node-autoprovision) to create a node pool to run the pods.

    ```bash
    kubectl get pods -n aks-store-demo
    ```
2. Check for a public IP address for the store-front application. Monitor progress using the [kubectl get service](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```bash
    kubectl get ingress store-front -n aks-store-demo --watch
    ```

    The **ADDRESS** output for the `store-front` service initially shows empty:

    ```output
    NAME          CLASS                                HOSTS   ADDRESS        PORTS   AGE
    store-front   webapprouting.kubernetes.azure.com   *                      80      12m
    ```
3. Once the **ADDRESS** changes from blank to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.

    The following sample output shows a valid public IP address assigned to the service:

    ```output
    NAME          CLASS                                HOSTS   ADDRESS        PORTS   AGE
    store-front   webapprouting.kubernetes.azure.com   *       4.255.22.196   80      12m
    ```
4. Open a web browser to the external IP address of your ingress to see the Azure Store app in action.

    [![Screenshot of AKS Store sample application.](../learn/media/quick-kubernetes-deploy-cli/aks-store-application.png)](../learn/media/quick-kubernetes-deploy-cli/aks-store-application.png#lightbox)

## Delete the cluster

If you don't plan on going through the [AKS tutorial](../tutorial-kubernetes-prepare-app), clean up unnecessary resources to avoid Azure charges.

::: zone pivot="azure-cli,bicep,azure-portal"

Remove the resource group, container service, and all related resources using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
az group delete --name myResourceGroup --yes --no-wait
```

Note

The AKS cluster was created with a system-assigned managed identity, which is the default identity option used in this quickstart. The platform manages this identity, so you don't need to manually remove it.

::: zone-end

::: zone pivot="terraform"

When you no longer need the resources you created by using Terraform, run [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan) and specify the `destroy` flag.

```console
terraform plan -destroy -out main.destroy.tfplan
```

Run [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the execution plan.

```console
terraform apply main.destroy.tfplan
```

::: zone-end