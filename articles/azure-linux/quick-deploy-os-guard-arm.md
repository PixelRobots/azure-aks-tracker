---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Linux with OS Guard for AKS (Preview) Cluster using an ARM Template | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/quick-deploy-os-guard-arm
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
description: Learn how to quickly deploy an Azure Linux with OS Guard for Azure Kubernetes Service (AKS) cluster using an Azure Resource Manager (ARM) template.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: c42acd1e-a6a8-d30d-88e3-34bce04a0045
document_version_independent_id: a68f6f9f-6709-ab01-a736-24449718d0ab
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/quick-deploy-os-guard-arm.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/quick-deploy-os-guard-arm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/quick-deploy-os-guard-arm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 6ca3e1cd-8483-e7f5-5a8d-30f8d85bb139
---

# Quickstart: Deploy an Azure Linux with OS Guard for AKS (Preview) Cluster using an ARM Template | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Linux with OS Guard (preview) is being replaced by Azure Container Linux (ACL).

Azure Container Linux is the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale.

For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

Get started with the Azure Linux Container Host by using an Azure Resource Manager (ARM) template to deploy an Azure Linux with OS Guard (preview) cluster on AKS.

In this quickstart, you learn how to:

- Install the `aks-preview` Azure CLI extension.
- Register the `AzureLinuxOSGuardPreview` feature flag.
- Install the Kubernetes CLI, `kubectl`.
- Create an SSH key pair.
- Review the ARM template.
- Deploy the ARM template and validate it.
- Deploy a sample application to the cluster.

An [Azure Resource Manager template](/en-us/azure/azure-resource-manager/templates/overview) is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax. You describe your intended deployment without writing the sequence of programming commands to create the deployment.

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Azure Cloud Shell Quickstart - Bash](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/ce-skilling/azure/media/cloud-shell/launch-cloud-shell-button.png)](https://portal.azure.com/#cloudshell/)
- If you prefer to run CLI reference commands locally, [install the Azure CLI](/en-us/cli/azure/install-azure-cli). If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI using the [`az login`](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Sign in with the Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [`az version`](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade).
- If you don't already have kubectl installed, install it through Azure CLI using the [`az aks install-cli`](/en-us/cli/azure/aks#az_aks_get_credentials) command or follow the [upstream instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).
- To create an AKS cluster using an ARM template, you provide an SSH public key. If you need this resource, see the following section; otherwise skip to the Review the template section.
- The identity you're using to create your cluster has the appropriate minimum permissions. For more information on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](/en-us/azure/aks/concepts-identity).
- To deploy a Bicep file or ARM template, you need write access on the resources you're deploying and access to all operations on the Microsoft.Resources/deployments resource type. For example, to deploy a virtual machine (VM), you need *Microsoft.Compute/virtualMachines/write* and *Microsoft.Resources/deployments/\** permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

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

### Create an SSH key pair

To access AKS nodes, you connect using an SSH key pair (public and private), which you generate using the `ssh-keygen` command. By default, these files are created in the *~/.ssh* directory. Running the `ssh-keygen` command overwrites any SSH key pair with the same name already existing in the given location.

1. Navigate to https://shell.azure.com to open Cloud Shell in your browser.
2. Run the `ssh-keygen` command. The following example creates an SSH key pair using RSA encryption and a bit length of 4096:

    ```bash
    ssh-keygen -t rsa -b 4096
    ```

For more information about creating SSH keys, see [Create and manage SSH keys for authentication in Azure](/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

## Review the template

The following deployment uses an ARM template from [Azure Quickstart Templates](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard):

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.1",
    "parameters": {
        "clusterName": {
            "defaultValue": "osguardakscluster",
            "type": "String",
            "metadata": {
                "description": "The name of the Managed Cluster resource."
            }
        },
        "location": {
            "defaultValue": "[resourceGroup().location]",
            "type": "String",
            "metadata": {
                "description": "The location of the Managed Cluster resource."
            }
        },
        "dnsPrefix": {
            "type": "String",
            "metadata": {
                "description": "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
            }
        },
        "agentCount": {
            "defaultValue": 3,
            "minValue": 1,
            "maxValue": 50,
            "type": "Int",
            "metadata": {
                "description": "The number of nodes for the cluster."
            }
        },
        "agentVMSize": {
            "defaultValue": "Standard_DS2_v2",
            "type": "String",
            "metadata": {
                "description": "The size of the Virtual Machine."
            }
        },
        "osSKU": {
            "defaultValue": "AzureLinuxOSGuard",
            "allowedValues": [
                "AzureLinuxOSGuard",
                "AzureLinux3OSGuard"
            ],
            "type": "String",
            "metadata": {
                "description": "The Linux SKU to use."
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.ContainerService/managedClusters",
            "apiVersion": "2025-05-01",
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
                        "mode": "System",
                        "count": "[parameters('agentCount')]",
                        "vmSize": "[parameters('agentVMSize')]",
                        "osType": "Linux",
                        "osSKU": "[parameters('osSKU')]",
                        "osDiskType": "Managed",
                        "enableFIPS": true,
                        "securityProfile": {
                            "enableSecureBoot": true,
                            "enableVTPM": true
                        },
                    }
                ]
            }
        }
    ],
    "outputs": {
        "controlPlaneFQDN": {
            "type": "String",
            "value": "[reference(parameters('clusterName')).fqdn]"
        }
    }
}
```

To add Azure Linux with OS Guard to an existing ARM template, you need to add the following properties to the `agentPoolProfiles` section of your template:

- `"osSKU": "AzureLinuxOSGuard"`
- `"mode": "System"` to `agentPoolProfiles`
- `"osDiskType": "Managed"` to `agentPoolProfiles`
- `"enableFIPS": true` to `agentPoolProfiles`
- `"securityProfile": {enableSecureBoot: true enableVTPM: true}` to `agentPoolProfiles`
- Set the `apiVersion` to `2025-05-01` or newer (`"apiVersion": "2025-05-01"`).

## Deploy the template

1. In the Azure Portal, select **Deploy a custom template** &gt; **Build your own template**, and then paste the ARM template into the template editor.
2. Configure the template parameters in the **Custom deployment** page. For this quickstart, leave the default values for the *OS Disk Size GB*, *Agent Count*, *Agent VM Size*, *OS Type*, and *Kubernetes Version*. Provide your own values for the following template parameters:

    - **Subscription**: Select an Azure subscription.
    - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *ttestAzureLinuxOSGuardResourceGroup*, then choose **OK**.
    - **Location**: Select a location, such as **East US**.
    - **Cluster name**: Enter a unique name for the AKS cluster, such as *testAzureLinuxOSGuardCluster*.
    - **DNS prefix**: Enter a unique DNS prefix for your cluster, such as *myAzureLinuxOSGuardCluster*.
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
    az aks get-credentials --resource-group testAzureLinuxOSGuardResourceGroup --name testAzureLinuxCluster
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