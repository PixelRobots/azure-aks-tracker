---
layout: Conceptual
title: Deploy a Kubernetes cluster using an Azure Resource Manager template | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/resource-manager-quickstart
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to deploy a Kubernetes cluster in Azure Kubernetes Service (AKS) Hybrid and Edge using an Azure Resource Manager template.
ms.topic: quickstart-arm
ms.custom: devx-track-arm-template, devx-track-azurecli, local
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2026-01-09T00:00:00.0000000Z
ms.reviewer: rbaziwane
locale: en-us
document_id: 1b799484-f070-097a-928f-9f9c50341a4b
document_version_independent_id: 0169d54b-f728-ec28-89f1-d0015e4c3db1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/resource-manager-quickstart.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/local/resource-manager-quickstart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/resource-manager-quickstart.md
platformId: b4fce269-f14b-4710-7655-233964033dfd
---

# Deploy a Kubernetes cluster using an Azure Resource Manager template | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This quickstart shows how to deploy a Kubernetes cluster in Azure Kubernetes Service (AKS) Arc using an Azure Resource Manager template (ARM template). Azure Arc extends Azure management capabilities to Kubernetes clusters anywhere, providing a unified approach to managing different environments.

## Before you begin

This article assumes a basic understanding of Kubernetes concepts.

To deploy an ARM template, you need write access on the resources you're deploying, and access to all operations on the `Microsoft.Resources/deployments` resource type. For example, to deploy a virtual machine, you need `Microsoft.Compute/virtualMachines/write` and `Microsoft.Resources/deployments/*` permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

### Prerequisites

- An Azure account with an active subscription.
- An Azure Local cluster.
- The [latest version of Azure CLI](/en-us/cli/azure/install-azure-cli).

## Step 1: Prepare your Azure account

1. Sign in to Azure: open your terminal or command prompt and sign in to your Azure account using the Azure CLI:

    ```azurecli
    az login
    ```
2. Set your subscription: replace `<your-subscription-id>` with your subscription ID:

    ```azurecli
    az account set --subscription "<your-subscription-id>"
    ```

## Step 2: Create an SSH key pair

Create an SSH key pair in Azure and store the private key file for troubleshooting and log collection purposes. For detailed instructions, see [Configure SSH keys for an AKS cluster](hyperconverged/configure-ssh-keys) to create SSH keys, or use [Restrict SSH access](hyperconverged/restrict-ssh-access) during cluster creation. To access nodes afterward, see [Connect to Windows or Linux worker nodes with SSH](hyperconverged/ssh-connect-to-windows-and-linux-worker-nodes).

1. [Open a Cloud Shell session](https://shell.azure.com/) in your web browser or launch a terminal on your local machine.
2. Create an SSH key pair using the [az sshkey create](/en-us/cli/azure/sshkey#az-sshkey-create) command:

    ```azurecli
    az sshkey create --name "mySSHKey" --resource-group $<resource_group_name>
    ```

    or, use the `ssh-keygen` command:

    ```azurecli
    ssh-keygen -t rsa -b 4096 
    ```
3. Retrieve the value of your public key from Azure or from your local machine under */.ssh/id\_rsa.pub*.

## Step 3: Deploy the cluster using ARM templates

For detailed instructions on deploying an AKS cluster using ARM templates, see the [AKSArc deployment templates repository](https://github.com/Azure/aksArc/tree/main/deploymentTemplates/aksarc-ARM-azlocal/Cluster). The repository includes:

- **CreateWithExistingLnet**: Deploy a cluster using an existing logical network.
- **CreateWithoutExistingLnet**: Deploy a cluster and create a new logical network.
- Complete deployment instructions and examples.
- Parameter file templates.

To deploy your cluster, follow the instructions in the repository's [README](https://github.com/Azure/aksArc/blob/main/deploymentTemplates/aksarc-ARM-azlocal/Cluster/README.md) file.

## Step 4: Connect to the cluster

1. To connect to the cluster, run the [az connectedk8s proxy](/en-us/cli/azure/connectedk8s) command. The command downloads and runs a proxy binary on the client machine, and fetches a `kubeconfig` file associated with the cluster.

    ```azurecli
    az connectedk8s proxy --name <cluster name> -g <resource group>
    ```

    Or, use the Kubernetes command-line client, `kubectl`. If you use Azure Cloud Shell, `kubectl` is already installed. To install and run `kubectl` locally, run [az-aks-install-cli](/en-us/cli/azure/aks#az-aks-install-cli) or download from the [Kubernetes](https://kubernetes.io/docs/tasks/tools/#kubectl) website.

    Configure `kubectl` to connect to your Kubernetes cluster using the `az aksarc get-credentials` command. This command downloads credentials and configures the Kubernetes CLI to use the credentials.

    ```azurecli
    az aksarc get-credentials --resource-group "<resource-group-name>" --name "<cluster-name>"
    ```
2. Verify the connection to your cluster using the `kubectl get` command. This command returns a list of the cluster nodes.

    ```cmd
    kubectl get nodes -A --kubeconfig .\<path to kubecofig> 
    ```

    The following example output shows the three nodes created in the previous steps. Make sure the node status is `Ready`.

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-agentpool-27442051-vmss000000   Ready    agent   10m   v1.27.7
    aks-agentpool-27442051-vmss000001   Ready    agent   10m   v1.27.7
    aks-agentpool-27442051-vmss000002   Ready    agent   11m   v1.27.7
    ```

## Deploy node pools (optional)

To add more node pools to your cluster using ARM templates, see the [ARM template to deploy/update an AKS node pool](https://github.com/Azure/aksArc/tree/main/deploymentTemplates/aksarc-ARM-azlocal/Nodepool). The repository includes complete instructions for deploying and managing node pools.