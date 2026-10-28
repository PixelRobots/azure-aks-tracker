---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Container Linux (ACL) AKS Cluster using an ARM Template | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/quick-deploy-azure-container-linux-aks-arm
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
description: Learn how to quickly deploy an Azure Container Linux (ACL) AKS cluster using an Azure Resource Manager (ARM) template and connect to it using `kubectl`.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 42c6ce76-9fdf-5426-427a-89a37197b7cb
document_version_independent_id: 6784171f-e19b-f536-22b9-d3f0782a7ac6
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/quick-deploy-azure-container-linux-aks-arm.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/quick-deploy-azure-container-linux-aks-arm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/quick-deploy-azure-container-linux-aks-arm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: be0f6b27-5e61-47e1-c568-58a07eb2e1d3
---

# Quickstart: Deploy an Azure Container Linux (ACL) AKS Cluster using an ARM Template | Microsoft Learn

In this quickstart, you use an Azure Resource Manager (ARM) template to create an Azure Kubernetes Service (AKS) cluster that runs Azure Container Linux (ACL) as the node operating system (OS). After installing the prerequisites, you create an SSH key pair, review the template, deploy the template, and connect to the cluster.

## Azure Container Linux (ACL) considerations and limitations

Before you begin, review the following considerations and limitations for ACL:

- ACL is generally available starting AKS v1.34.
- ACL requires [Trusted Launch](/en-us/azure/aks/use-trusted-launch) with Secure Boot and vTPM. Non-Trusted Launch variants aren't available.
- ACL on Arm64 requires Cobalt-based (v6) SKUs to enable Trusted Launch compatibility.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image). `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Prerequisites

Note

You can use either [Azure Cloud Shell](/en-us/azure/cloud-shell/overview) or a local installation of the Azure CLI to run the commands in this quickstart.

- If you're running the Azure CLI locally, [install the Azure CLI](/en-us/cli/azure/install-azure-cli). If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).
- If you're using a local installation, sign in to the Azure CLI using the [`az login`](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Sign in with the Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
- If you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
- Azure Container Linux requires Azure CLI version 2.86.0 or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the Azure CLI version and dependent libraries that are installed. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.
- If you don't already have kubectl installed, install it through Azure CLI using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command or follow the [upstream instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).
- To create an AKS cluster using an ARM template, you need to provide an SSH public key. If you need this resource, go to the Create an SSH key pair section to generate one before deploying the template. If you already have an SSH key pair, you can skip to the Review the template section.
- The identity you're using to create your cluster needs to have the appropriate minimum permissions. For more information on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](/en-us/azure/aks/concepts-identity).
- To deploy an ARM template, you need write access on the resources you're deploying and access to all operations on the Microsoft.Resources/deployments resource type. For example, to deploy a virtual machine (VM), you need Microsoft.Compute/virtualMachines/write and Microsoft.Resources/deployments/\* permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

### Create an SSH key pair

To access AKS nodes, you connect using an SSH key pair (public and private), which you generate using the `ssh-keygen` command. By default, these files are created in the *~/.ssh* directory. Running the `ssh-keygen` command overwrites any SSH key pair with the same name already existing in the given location.

1. Go to https://shell.azure.com to open Cloud Shell in your browser.
2. Run the `ssh-keygen` command. The following example creates an SSH key pair using RSA encryption and a bit length of 4096:

    ```console
    ssh-keygen -t rsa -b 4096
    ```

For more information about creating SSH keys, see [Create and manage SSH keys for authentication in Azure](/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

## Review the template

The following deployment uses an ARM template from [Azure Quickstart Templates](https://github.com/Azure/azure-quickstart-templates/):

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "clusterName": {
      "type": "string",
      "defaultValue": "aclakscluster",
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
        "description": "Disk size (in GB) to provision for each of the agent pool nodes. Specifying 0 applies the default disk size for that agentVMSize."
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
        "description": "Configure all linux machines with the SSH RSA public key string."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2026-03-01",
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
            "osSKU": "AzureContainerLinux",
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

## Deploy the template

1. Select **Deploy to Azure** to sign in and open a template.

    [![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-container-linux%2Fazuredeploy.json)
2. On the **Basics** page, leave the default values for the **OS Disk Size GB**, **Agent Count**, **Agent VM Size**, and **OS Type**, and configure the following template parameters:

    - **Subscription**: Select an Azure subscription.
    - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *myACLResourceGroup*, and then select **OK**.
    - **OS SKU**: Specify **AzureContainerLinux**.
    - **Location**: Select a location, such as **West US**.
    - **Cluster name**: Enter a unique name for the AKS cluster, such as *myACLCluster*.
    - **DNS prefix**: Enter a unique DNS prefix for your cluster, such as *myaclcluster*.
    - **Linux Admin Username**: Enter a username to connect using SSH, such as *azureuser*.
    - **SSH public key source**: Select **Use existing public key**.
    - **Key pair name**: Copy and paste the *public* part of your SSH key pair (by default, the contents of *~/.ssh/id\_rsa.pub*).
3. Select **Review + Create** &gt; **Create**.

    It takes a few minutes to create the AKS cluster. Wait for the deployment to complete before you connect to the cluster.

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). `kubectl` is already installed if you use Azure Cloud Shell. To install `kubectl` locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group myACLResourceGroup --name myACLCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following example output shows the three nodes created in the previous steps. Make sure the node status is *Ready*:

    ```output
    NAME                       STATUS   ROLES   AGE     VERSION
    aks-agentpool-12345678-0   Ready    agent   6m44s   v1.34.0
    aks-agentpool-12345678-1   Ready    agent   6m46s   v1.34.0
    aks-agentpool-12345678-2   Ready    agent   6m45s   v1.34.0
    ```

## Delete the cluster

If you no longer need the resources you created in this quickstart, you can clean them up to avoid Azure charges.

Delete the Azure resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command:

```azurecli
az group delete --name myACLResourceGroup --yes --no-wait
```