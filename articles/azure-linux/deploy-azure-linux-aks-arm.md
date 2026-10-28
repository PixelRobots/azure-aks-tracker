---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Linux Container Host for AKS Cluster using an ARM Template | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/deploy-azure-linux-aks-arm
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
description: Learn how to quickly deploy an Azure Linux Container Host for Azure Kubernetes Service (AKS) cluster using an Azure Resource Manager (ARM) template.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 6b4a93c1-c1c2-a420-7d0d-13e7dbcbf30e
document_version_independent_id: 5ce790c4-d450-8d69-bc5c-202b57f9c799
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/deploy-azure-linux-aks-arm.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/deploy-azure-linux-aks-arm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/deploy-azure-linux-aks-arm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e679802f-0a5b-a8a7-3b1b-02942f7748ff
---

# Quickstart: Deploy an Azure Linux Container Host for AKS Cluster using an ARM Template | Microsoft Learn

Get started with the Azure Linux Container Host by using an Azure Resource Manager (ARM) template to deploy an Azure Linux Container Host cluster.

In this quickstart, you learn how to:

- Install the Kubernetes CLI, `kubectl`.
- Create an SSH key pair.
- Review the ARM template.
- Deploy the ARM template and validate it.

An [Azure Resource Manager template](/en-us/azure/azure-resource-manager/templates/overview) is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax. You describe your intended deployment without writing the sequence of programming commands to create the deployment.

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Azure Cloud Shell Quickstart - Bash](/en-us/azure/cloud-shell/quickstart).

    [![Launch Cloud Shell](../reusable-content/ce-skilling/azure/media/cloud-shell/launch-cloud-shell-button.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install the Azure CLI](/en-us/cli/azure/install-azure-cli). If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI using the [`az login`](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Sign in with the Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [`az version`](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade).
- If you don't already have kubectl installed, install it through Azure CLI using the [`az aks install-cli`](/en-us/cli/azure/aks#az_aks_get_credentials) command or follow the [upstream instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).
- To create an AKS cluster using an ARM template, you provide an SSH public key. If you need this resource, see the following section; otherwise skip to the Review the template section.
- The identity you're using to create your cluster has the appropriate minimum permissions. For more information on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](/en-us/azure/aks/concepts-identity).
- To deploy a Bicep file or ARM template, you need write access on the resources you're deploying and access to all operations on the Microsoft.Resources/deployments resource type. For example, to deploy a virtual machine (VM), you need *Microsoft.Compute/virtualMachines/write* and *Microsoft.Resources/deployments/\** permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

### Create an SSH key pair

To access AKS nodes, you connect using an SSH key pair (public and private), which you generate using the `ssh-keygen` command. By default, these files are created in the *~/.ssh* directory. Running the `ssh-keygen` command overwrites any SSH key pair with the same name already existing in the given location.

1. Navigate to https://shell.azure.com to open Cloud Shell in your browser.
2. Run the `ssh-keygen` command. The following example creates an SSH key pair using RSA encryption and a bit length of 4096:

    ```bash
    ssh-keygen -t rsa -b 4096
    ```

For more information about creating SSH keys, see [Create and manage SSH keys for authentication in Azure](/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

## Review the template

The following deployment uses an ARM template from [Azure Quickstart Templates](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.kubernetes/aks-azure-linux):

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.1",
  "parameters": {
    "clusterName": {
      "type": "string",
      "defaultValue": "azurelinuxakscluster",
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
      "defaultValue": "Standard_DS2_v2",
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
    },
    "osType": {
      "type": "string",
      "defaultValue": "Linux",
      "allowedValues": [
        "Linux"
      ],
      "metadata": {
        "description": "The type of operating system."
      }
    },
    "osSKU": {
      "type": "string",
      "defaultValue": "AzureLinux",
      "allowedValues": [
        "AzureLinux",
        "AzureLinux3",
        "Ubuntu",
        "Ubuntu2204",
        "Ubuntu2404"
      ],
      "metadata": {
        "description": "The Linux SKU to use."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2021-03-01",
      "name": "[parameters('clusterName')]",
      "location": "[parameters('location')]",
      "properties": {
        "dnsPrefix": "[parameters('dnsPrefix')]",
        "agentPoolProfiles": [
          {
            "name": "agentpool",
            "mode": "System",
            "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
            "count": "[parameters('agentCount')]",
            "vmSize": "[parameters('agentVMSize')]",
            "osType": "[parameters('osType')]",
            "osSKU": "[parameters('osSKU')]",
            "storageProfile": "ManagedDisks"
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
      },
      "identity": {
          "type": "SystemAssigned"
      }
    }
  ],
  "outputs": {
    "controlPlaneFQDN": {
      "type": "string",
      "value": "[reference(parameters('clusterName')).fqdn]"
    }
  }
}
```

To add Azure Linux to an existing ARM template, you need to add `"osSKU": "AzureLinux"` and `"mode": "System"` to `agentPoolProfiles` and set the `apiVersion` to 2021-03-01 or newer (`"apiVersion": "2021-03-01"`).

## Deploy the template

1. Select the following button to sign in to Azure and open a template:

    [![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-linux%2Fazuredeploy.json)
2. Configure the template parameters in the **Custom deployment** page. For this quickstart, leave the default values for the *OS Disk Size GB*, *Agent Count*, *Agent VM Size*, *OS Type*, and *Kubernetes Version*. Provide your own values for the following template parameters:

    - **Subscription**: Select an Azure subscription.
    - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *testAzureLinuxResourceGroup*, then choose **OK**.
    - **Location**: Select a location, such as **East US**.
    - **Cluster name**: Enter a unique name for the AKS cluster, such as *testAzureLinuxCluster*.
    - **DNS prefix**: Enter a unique DNS prefix for your cluster, such as *myAzureLinuxCluster*.
    - **Linux Admin Username**: Enter a username to connect using SSH, such as *azureUser*.
    - **SSH RSA Public Key**: Copy and paste the *public* part of your SSH key pair (by default, the contents of ~/.ssh/id\_rsa.pub).
3. Select **Review + Create**.

It takes a few minutes to create the Azure Linux Container Host cluster. Wait for the cluster to be successfully deployed before you move on to the next step.

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/).

1. Install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az_aks_get_credentials) command. If you're using Azure Cloud Shell, `kubectl` is already installed.

    ```azurecli
    az aks install-cli
    ```
2. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group testAzureLinuxResourceGroup --name testAzureLinuxCluster
    ```
3. Verify the connection to your cluster using the `kubectl get` command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following output example shows the three nodes created in the previous steps. Make sure the node status is *Ready*:

    ```output
    NAME                       STATUS   ROLES   AGE     VERSION
    aks-agentpool-12345678-0   Ready    agent   6m44s   v1.12.6
    aks-agentpool-12345678-1   Ready    agent   6m46s   v1.12.6
    aks-agentpool-12345678-2   Ready    agent   6m45s   v1.12.6
    ```

## Delete the cluster

If you no longer need them, you can clean up unnecessary resources to avoid Azure charges.

Delete the Azure resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```