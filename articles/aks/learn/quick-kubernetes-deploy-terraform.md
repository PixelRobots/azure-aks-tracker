---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using Terraform - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform
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
description: Learn how to quickly deploy a Kubernetes cluster using Terraform and deploy an application in Azure Kubernetes Service (AKS).
ms.author: schaffererin
author: schaffererin
ms.topic: quickstart
ms.subservice: aks-developer
ms.date: 2024-03-22T00:00:00.0000000Z
ms.custom: devx-track-terraform, devx-track-extended-azdevcli, devx-track-azurecli
content_well_notification:
- AI-contribution
ai-usage: ai-assisted
zone_pivot_groups: aks-azure-developer-cli
locale: en-us
document_id: ae2a6d20-70d8-387e-564a-c89f557b0bf5
document_version_independent_id: dff8fa9c-b5e2-c368-cb36-de9e304ecb80
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-kubernetes-deploy-terraform.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/learn/quick-kubernetes-deploy-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-kubernetes-deploy-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8dffe612-8f04-997f-8d9f-94cdac2b629d
---

# Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using Terraform - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this quickstart, you:

- Deploy an AKS cluster using Terraform.
- Run a sample multi-container application with a group of microservices and web front ends simulating a retail scenario.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

- This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).
- You need an Azure account with an active subscription. If you don't have one, [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Follow the instructions based on your command line interface.

::: zone pivot="development-environment-azure-cli"

- To learn more about creating a Windows Server node pool, see [Create an AKS cluster that supports Windows Server containers](quick-windows-container-deploy-cli).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- [Download kubectl](https://kubernetes.io/releases/download/).
- Create a random value for the Azure resource group name using [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet).
- Create an Azure resource group using [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).
- Access the configuration of the AzureRM provider to get the Azure Object ID using [azurerm_client_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config).
- Create a Kubernetes cluster using [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster).
- Create an AzAPI resource [azapi_resource](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource).
- Create an AzAPI resource to generate an SSH key pair using [azapi_resource_action](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource_action).

## Login to your Azure account

First, log into your Azure account and authenticate using one of the methods described in the following section.

Terraform only supports authenticating to Azure with the Azure CLI. Authenticating using Azure PowerShell isn't supported. Therefore, while you can use the Azure PowerShell module when doing your Terraform work, you first need to [authenticate to Azure](/en-us/azure/developer/terraform/authenticate-to-azure).

## Implement the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/201-k8s-cluster-with-tf-and-aks). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/201-k8s-cluster-with-tf-and-aks/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform)

1. Create a directory you can use to test the sample Terraform code and make it your current directory.
2. Create a file named `providers.tf` and insert the following code:

    ```terraform
    terraform {
      required_version = ">=1.0"
    
      required_providers {
        azapi = {
          source  = "azure/azapi"
          version = "~>1.5"
        }
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~>3.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~>3.0"
        }
        time = {
          source  = "hashicorp/time"
          version = "0.9.1"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    ```
3. Create a file named `ssh.tf` and insert the following code:

    ```terraform
    resource "random_pet" "ssh_key_name" {
      prefix    = "ssh"
      separator = ""
    }
    
    resource "azapi_resource_action" "ssh_public_key_gen" {
      type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
      resource_id = azapi_resource.ssh_public_key.id
      action      = "generateKeyPair"
      method      = "POST"
    
      response_export_values = ["publicKey", "privateKey"]
    }
    
    resource "azapi_resource" "ssh_public_key" {
      type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
      name      = random_pet.ssh_key_name.id
      location  = azurerm_resource_group.rg.location
      parent_id = azurerm_resource_group.rg.id
    }
    
    output "key_data" {
      value = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
    ```
4. Create a file named `main.tf` and insert the following code:

    ```terraform
    # Generate random resource group name
    resource "random_pet" "rg_name" {
      prefix = var.resource_group_name_prefix
    }
    
    resource "azurerm_resource_group" "rg" {
      location = var.resource_group_location
      name     = random_pet.rg_name.id
    }
    
    resource "random_pet" "azurerm_kubernetes_cluster_name" {
      prefix = "cluster"
    }
    
    resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
      prefix = "dns"
    }
    
    resource "azurerm_kubernetes_cluster" "k8s" {
      location            = azurerm_resource_group.rg.location
      name                = random_pet.azurerm_kubernetes_cluster_name.id
      resource_group_name = azurerm_resource_group.rg.name
      dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
    
      identity {
        type = "SystemAssigned"
      }
    
      default_node_pool {
        name       = "agentpool"
        vm_size    = "Standard_D2_v2"
        node_count = var.node_count
      }
      linux_profile {
        admin_username = var.username
    
        ssh_key {
          key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
        }
      }
      network_profile {
        network_plugin    = "kubenet"
        load_balancer_sku = "standard"
      }
    }
    ```
5. Create a file named `variables.tf` and insert the following code:

    ```terraform
    variable "resource_group_location" {
      type        = string
      default     = "eastus"
      description = "Location of the resource group."
    }
    
    variable "resource_group_name_prefix" {
      type        = string
      default     = "rg"
      description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
    }
    
    variable "node_count" {
      type        = number
      description = "The initial quantity of nodes for the node pool."
      default     = 3
    }
    
    variable "msi_id" {
      type        = string
      description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
      default     = null
    }
    
    variable "username" {
      type        = string
      description = "The admin username for the new cluster."
      default     = "azureadmin"
    }
    ```
6. Create a file named `outputs.tf` and insert the following code:

    ```terraform
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "kubernetes_cluster_name" {
      value = azurerm_kubernetes_cluster.k8s.name
    }
    
    output "client_certificate" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
      sensitive = true
    }
    
    output "client_key" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
      sensitive = true
    }
    
    output "cluster_ca_certificate" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
      sensitive = true
    }
    
    output "cluster_password" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
      sensitive = true
    }
    
    output "cluster_username" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
      sensitive = true
    }
    
    output "host" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
      sensitive = true
    }
    
    output "kube_config" {
      value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
      sensitive = true
    }
    ```

## Initialize Terraform

Run [terraform init](https://www.terraform.io/docs/commands/init.html) to initialize the Terraform deployment. This command downloads the Azure provider required to manage your Azure resources.

```console
terraform init -upgrade
```

**Key points:**

- The `-upgrade` parameter upgrades the necessary provider plugins to the newest version that complies with the configuration's version constraints.

## Create a Terraform execution plan

Run [terraform plan](https://www.terraform.io/docs/commands/plan.html) to create an execution plan.

```console
terraform plan -out main.tfplan
```

**Key points:**

- The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
- The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.

## Apply a Terraform execution plan

Run [terraform apply](https://www.terraform.io/docs/commands/apply.html) to apply the execution plan to your cloud infrastructure.

```console
terraform apply main.tfplan
```

**Key points:**

- The example `terraform apply` command assumes you previously ran `terraform plan -out main.tfplan`.
- If you specified a different filename for the `-out` parameter, use that same filename in the call to `terraform apply`.
- If you didn't use the `-out` parameter, call `terraform apply` without any parameters.

## Verify the results

1. Get the Azure resource group name using the following command.

    ```console
    resource_group_name=$(terraform output -raw resource_group_name)
    ```
2. Display the name of your new Kubernetes cluster using the [az aks list](/en-us/cli/azure/aks#az-aks-list) command.

    ```azurecli
    az aks list \
      --resource-group $resource_group_name \
      --query "[].{\"K8s cluster name\":name}" \
      --output table
    ```
3. Get the Kubernetes configuration from the Terraform state and store it in a file that `kubectl` can read using the following command.

    ```console
    echo "$(terraform output kube_config)" > ./azurek8s
    ```
4. Verify the previous command didn't add an ASCII EOT character using the following command.

    ```console
    cat ./azurek8s
    ```

    **Key points:**

    - If you see `<< EOT` at the beginning and `EOT` at the end, remove these characters from the file. Otherwise, you may receive the following error message: `error: error loading config file "./azurek8s": yaml: line 2: mapping values are not allowed in this context`
5. Set an environment variable so `kubectl` can pick up the correct config using the following command.

    ```console
    export KUBECONFIG=./azurek8s
    ```
6. Verify the health of the cluster using the `kubectl get nodes` command.

    ```console
    kubectl get nodes
    ```

**Key points:**

- When you created the AKS cluster, monitoring was enabled to capture health metrics for both the cluster nodes and pods. These health metrics are available in the Azure portal. For more information on container health monitoring, see [Monitor Azure Kubernetes Service health](/en-us/azure/azure-monitor/insights/container-insights-overview).
- Several key values classified as output when you applied the Terraform execution plan. For example, the host address, AKS cluster user name, and AKS cluster password are output.

## Deploy the application

To deploy the application, you use a manifest file to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo). A [Kubernetes manifest file](../concepts-clusters-workloads#deployments-and-yaml-manifests) defines a cluster's desired state, such as which container images to run. The manifest includes the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/quick-kubernetes-deploy-terraform/aks-store-architecture.png)](media/quick-kubernetes-deploy-terraform/aks-store-architecture.png#lightbox)

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
2. Deploy the application using the `kubectl apply` command and specify the name of your YAML manifest.

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

### Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete.

1. Check the status of the deployed pods using the `kubectl get pods` command. Make all pods are `Running` before proceeding.

    ```console
    kubectl get pods
    ```
2. Check for a public IP address for the store-front application. Monitor progress using the `kubectl get service` command with the `--watch` argument.

    ```azurecli
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

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-terraform/aks-store-application.png)](media/quick-kubernetes-deploy-terraform/aks-store-application.png#lightbox)

## Clean up resources

### Delete AKS resources

When you no longer need the resources created via Terraform, do the following steps:

1. Run [terraform plan](https://www.terraform.io/docs/commands/plan.html) and specify the `destroy` flag.

    ```console
    terraform plan -destroy -out main.destroy.tfplan
    ```

    **Key points:**

    - The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
    - The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.
2. Run [terraform apply](https://www.terraform.io/docs/commands/apply.html) to apply the execution plan.

    ```console
    terraform apply main.destroy.tfplan
    ```

### Delete service principal

1. Get the service principal ID using the following command.

    ```azurecli
    sp=$(terraform output -raw sp)
    ```
2. Delete the service principal using the [az ad sp delete](/en-us/cli/azure/ad/sp#az-ad-sp-delete) command.

    ```azurecli
    az ad sp delete --id $sp
    ```

::: zone-end

::: zone pivot="development-environment-azure-developer"

- [Install the Azure Developer CLI (AZD)](/en-us/azure/developer/azure-developer-cli/install-azd)
- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- You can review the application code used in the Azure-Samples/[aks-store-demo repo](https://github.com/Azure-Samples/aks-store-demo).

## Clone the Azure Developer CLI template

The Azure Developer CLI allows you to quickly download samples from the **Azure-Samples** repository. In our quickstart, you download the `aks-store-demo` application. For more information on the general uses cases, see the [`azd` overview](/en-us/azure/developer/azure-developer-cli).

1. Clone the AKS store demo template from the **Azure-Samples** repository using the [`azd init`](/en-us/azure/developer/azure-developer-cli/reference#azd-init) command with the `--template` parameter.

    ```azdeveloper
    azd init --template Azure-Samples/aks-store-demo
    ```
2. Enter an environment name for your project that uses only alphanumeric characters and hyphens, such as *aks-terraform-1*.

    ```output
    Enter a new environment name: aks-terraform-1
    ```

## Sign in to your Azure Cloud account

The `azd` template contains all the code needed to create the services, but you need to sign in to your Azure account in order to host the application on AKS.

1. Sign in to your account using the [`azd auth login`](/en-us/azure/developer/azure-developer-cli/reference#azd-auth-login) command.

    ```azdeveloper
    azd auth login
    ```
2. Copy the device code that appears in the output and press enter to sign in.

    ```output
    Start by copying the next code: XXXXXXXXX
    Then press enter and continue to log in from your browser...
    ```

    Important

    If you're using an out-of-network virtual machine or GitHub Codespace, certain Azure security policies cause conflicts when used to sign in with `azd auth login`. If you run into an issue here, you can follow the azd auth workaround provided, which involves using a `curl` request to the localhost URL you were redirected to after running [`azd auth login`](/en-us/azure/developer/azure-developer-cli/reference#azd-auth-login).
3. Authenticate with your credentials on your organization's sign in page.
4. Confirm that it's you trying to connect from the Azure CLI.
5. Verify the message "Device code authentication completed. Logged in to Azure." appears in your original terminal.

    ```output
    Waiting for you to complete authentication in the browser...
    Device code authentication completed.
    Logged in to Azure.
    ```

### azd auth workaround

This workaround requires you to have the [Azure CLI](/en-us/cli/azure/install-azure-cli) installed.

1. Open a terminal window and log in with the Azure CLI using the [`az login`](/en-us/cli/azure/#az-login) command with the `--scope` parameter set to `https://graph.microsoft.com/.default`.

    ```azurecli
    az login --scope https://graph.microsoft.com/.default
    ```

    You should be redirected to an authentication page in a new tab to create a browser access token, as shown in the following example:

    ```output
    https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?clientid=<your_client_id>.
    ```
2. Copy the localhost URL of the webpage you received after attempting to sign in with `azd auth login`.
3. In a new terminal window, use the following `curl` request to log in. Make sure you replace the `<localhost>` placeholder with the localhost URL you copied in the previous step.

    ```console
    curl <localhost>
    ```

    A successful login outputs an HTML webpage, as shown in the following example:

    ```output
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="refresh" content="60;url=https://docs.microsoft.com/cli/azure/">
        <title>Login successfully</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
    
            code {
                font-family: Consolas, 'Liberation Mono', Menlo, Courier, monospace;
                display: inline-block;
                background-color: rgb(242, 242, 242);
                padding: 12px 16px;
                margin: 8px 0px;
            }
        </style>
    </head>
    <body>
        <h3>You have logged into Microsoft Azure!</h3>
        <p>You can close this window, or we will redirect you to the <a href="https://docs.microsoft.com/cli/azure/">Azure CLI documentation</a> in 1 minute.</p>
        <h3>Announcements</h3>
        <p>[Windows only] Azure CLI is collecting feedback on using the <a href="https://learn.microsoft.com/windows/uwp/security/web-account-manager">Web Account Manager</a> (WAM) broker for the login experience.</p>
        <p>You may opt-in to use WAM by running the following commands:</p>
        <code>
            az config set core.allow_broker=true<br>
            az account clear<br>
            az login
        </code>
    </body>
    </html>
    ```
4. Close the current terminal and open the original terminal. You should see a JSON list of your subscriptions.
5. Copy the `id` field of the subscription you want to use.
6. Set your subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription <subscription_id>
    ```

## Create and deploy resources for your cluster

To deploy the application, you use the `azd up` command to create all the objects required to run the [AKS Store application](https://github.com/Azure-Samples/aks-store-demo).

- An `azure.yaml` file defines a cluster's desired state, such as which container images to fetch and includes the following Kubernetes deployments and services:

[![Diagram that shows the Azure Store sample architecture.](media/quick-kubernetes-deploy-terraform/aks-store-architecture.png)](media/quick-kubernetes-deploy-terraform/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production. These are used here for simplicity, but we recommend using managed services, such as Azure Cosmos DB or Azure Service Bus.

### Deploy application resources

The `azd` template for this quickstart creates a new resource group with an AKS cluster and an Azure Key Vault. The key vault stores client secrets and runs the services in the `pets` namespace.

1. Create all the application resources using the [`azd up`](/en-us/azure/developer/azure-developer-cli/reference#azd-up) command.

    ```azdeveloper
    azd up
    ```

    `azd up` runs all the hooks inside of the [`azd-hooks` folder](https://github.com/Azure-Samples/aks-store-demo/tree/main/azd-hooks) to preregister, provision, and deploy the application services.

    Customize hooks to add custom code into the `azd` workflow stages. For more information, see the [`azd` hooks](/en-us/azure/developer/azure-developer-cli/reference#azd-hooks) reference.
2. Select an Azure subscription for your billing usage.

    ```output
    ? Select an Azure Subscription to use:  [Use arrows to move, type to filter]
    > 1. My Azure Subscription (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    ```
3. Select a region to deploy your application to.

    ```output
    Select an Azure location to use:  [Use arrows to move, type to filter]
      1.  (South America) Brazil Southeast (brazilsoutheast)
      2.  (US) Central US (centralus)
      3.  (US) East US (eastus)
    > 43. (US) East US 2 (eastus2)
      4.  (US) East US STG (eastusstg)
      5.  (US) North Central US (northcentralus)
      6.  (US) South Central US (southcentralus)
    ```

    `azd` automatically runs the preprovision and postprovision hooks to create the resources for your application. This process can take a few minutes to complete. Once complete, you should see an output similar to the following example:

    ```output
    SUCCESS: Your workflow to provision and deploy to Azure completed in 9 minutes 40 seconds.
    ```

### Generate Terraform plans

Within your Azure Developer template, the `/infra/terraform` folder contains all the code used to generate the Terraform plan.

Terraform deploys and runs commands using `terraform apply` as part of `azd`'s provisioning step. Once complete, you should see an output similar to the following example:

```output
Plan: 5 to add, 0 to change, 0 to destroy.
...
Saved the plan to: /workspaces/aks-store-demo/.azure/aks-terraform-azd/infra/terraform/main.tfplan
```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete.

1. Set your namespace as the demo namespace `pets` using the [`kubectl set-context`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config-set-context) command.

    ```console
    kubectl config set-context --current --namespace=pets
    ```
2. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get-pods) command. Make sure all pods are `Running` before proceeding.

    ```console
    kubectl get pods
    ```
3. Check for a public IP address for the store-front application and monitor progress using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```console
    kubectl get service store-front --watch
    ```

    The **EXTERNAL-IP** output for the `store-front` service initially shows as *pending*:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   <pending>     80:30025/TCP   4h4m
    ```
4. Once the **EXTERNAL-IP** address changes from *pending* to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.

    The following sample output shows a valid public IP address assigned to the service:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   20.62.159.19   80:30025/TCP   4h5m
    ```
5. Open a web browser to the external IP address of your service to see the Azure Store app in action.

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-cli/aks-store-application.png)](media/quick-kubernetes-deploy-cli/aks-store-application.png#lightbox)

## Delete the cluster

Once you're finished with the quickstart, clean up unnecessary resources to avoid Azure charges.

1. Delete all the resources created in the quickstart using the [`azd down`](/en-us/azure/developer/azure-developer-cli/reference#azd-down) command.

    ```azdeveloper
    azd down
    ```
2. Confirm your decision to remove all used resources from your subscription by typing `y` and pressing `Enter`.

    ```output
    ? Total resources to delete: 14, are you sure you want to continue? (y/N)
    ```
3. Allow purge to reuse the quickstart variables if applicable by typing `y` and pressing `Enter`.

    ```output
    [Warning]: These resources have soft delete enabled allowing them to be recovered for a period or time after deletion. During this period, their names can't be reused. In the future, you can use the argument --purge to skip this confirmation.
    ```

::: zone-end

## Troubleshoot Terraform on Azure

[Troubleshoot common problems when using Terraform on Azure](/en-us/azure/developer/terraform/troubleshoot).