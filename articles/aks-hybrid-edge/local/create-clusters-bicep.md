---
layout: Conceptual
title: Create Kubernetes clusters using Bicep | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/create-clusters-bicep
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
description: Learn how to create Kubernetes clusters in Azure Local using Bicep.
ms.topic: how-to
ms.custom: devx-track-azurecli, local
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: haojiehang
ms.lastreviewed: 2026-01-09T00:00:00.0000000Z
locale: en-us
document_id: c7982b29-aa67-36ad-587f-809909c30e24
document_version_independent_id: b502893e-2d14-2fdd-6206-11cdd8736511
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/create-clusters-bicep.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/local/create-clusters-bicep
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/create-clusters-bicep.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: c221b4b3-b507-395d-6813-e99c065e6392
---

# Create Kubernetes clusters using Bicep | Microsoft Learn

This article describes how to create Kubernetes clusters in Azure Local using Bicep. The workflow creates an SSH key pair and creates a Kubernetes cluster in Azure Local using Bicep. By default, the cluster is Azure Arc-connected. You then validate the deployment and connect to the cluster.

## Before you begin

Before you begin, make sure you have the following prerequisites:

1. Get the following details from your on-premises infrastructure administrator:

    - Azure subscription ID: the Azure subscription ID that uses Azure Local for deployment and registration.
    - Custom location name or ID: the Azure Resource Manager ID of the custom location. The custom location is configured during the Azure Local cluster deployment. Your infrastructure admin should give you the Resource Manager ID of the custom location. This parameter is required in order to create Kubernetes clusters. You can also get the Resource Manager ID using `az customlocation show --name "<custom location name>" --resource-group <azure resource group> --query "id" -o tsv`, if the infrastructure admin provides a custom location name and resource group name.
    - Logical network name or ID: the Azure Resource Manager ID of the Azure Local logical network that was created following these steps. Your admin should give you the ID of the logical network. This parameter is required in order to create Kubernetes clusters. You can also get the Azure Resource Manager ID using `az stack-hci-vm network lnet show --name "<lnet name>" --resource-group <azure resource group> --query "id" -o tsv` if you know the resource group in which the logical network was created.
2. Make sure you have the [latest version of Azure CLI](/en-us/cli/azure/install-azure-cli) on your development machine. You can also upgrade your Azure CLI version using `az upgrade`.
3. Download and install the Kubernetes command-line tool, `kubectl` on your development machine. You can use [az-aks-install-cli](/en-us/cli/azure/aks#az-aks-install-cli) or the [Kubernetes](https://kubernetes.io/docs/tasks/tools/#kubectl) website. Use `kubectl` to run commands against Kubernetes clusters, deploy applications, inspect and manage cluster resources, and view logs.

## Create an SSH key pair

Create an SSH key pair in Azure and store the private key file for troubleshooting and log collection purposes. For detailed instructions, see [Configure SSH keys for an AKS cluster](hyperconverged/configure-ssh-keys) to create SSH keys, or use [Restrict SSH access](hyperconverged/restrict-ssh-access) during cluster creation. To access nodes afterward, see [Connect to Windows or Linux worker nodes with SSH](hyperconverged/ssh-connect-to-windows-and-linux-worker-nodes).

1. [Open a Cloud Shell session](https://shell.azure.com/) in your web browser or launch a terminal on your local machine.
2. Create an SSH key pair using the [az sshkey create](/en-us/cli/azure/sshkey#az-sshkey-create) command.

    ```azurecli
    az sshkey create --name "mySSHKey" --resource-group $<resource_group_name>
    ```

    or, use the `ssh-keygen` command:

    ```azurecli
    ssh-keygen -t rsa -b 4096 
    ```
3. Retrieve the value of your public key from Azure or from your local machine under */.ssh/id\_rsa.pub*.

## Deploy the cluster using Bicep templates

For detailed instructions on deploying an AKS cluster using Bicep templates, see the [AKSArc Bicep deployment templates repository](https://github.com/Azure/aksArc/tree/main/deploymentTemplates/aksarc-bicep-azlocal/Cluster). The repository includes:

- **CreateWithExistingLnet**: Deploy a cluster using an existing logical network.
- **CreateWithoutExistingLnet**: Deploy a cluster and create a new logical network.
- Complete deployment instructions and examples.
- Parameter file templates.

To deploy your cluster, follow the instructions in the repository's [README](https://github.com/Azure/aksArc/blob/main/deploymentTemplates/aksarc-bicep-azlocal/Cluster/README.md) file.

## Connect to the cluster

After deployment, you can connect to your Kubernetes cluster by running the `az connectedk8s proxy` command from your development machine. You can also use `kubectl` to see the node and pod status. Follow the same steps as described in [Connect to the Kubernetes cluster](aks-create-clusters-cli#connect-to-the-kubernetes-cluster).

## Deploy node pools (optional)

To add more node pools to your cluster using Bicep templates, see the [Bicep template to deploy/update an AKS node pool](https://github.com/Azure/aksArc/tree/main/deploymentTemplates/aksarc-bicep-azlocal/Nodepool). The repository includes complete instructions for deploying and managing node pools.