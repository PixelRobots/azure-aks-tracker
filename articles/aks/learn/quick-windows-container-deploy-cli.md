---
layout: Conceptual
title: Deploy a Windows Server Container on an Azure Kubernetes Service (AKS) Cluster using Azure CLI - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli
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
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in a Windows Server container in Azure Kubernetes Service (AKS) using Azure CLI.
ms.topic: quickstart
ms.custom: devx-track-azurecli, innovation-engine, aks-windows
ms.date: 2026-07-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 7c6a6580-a6df-896e-c460-7b13897682ca
document_version_independent_id: a9abccb4-5211-999e-9580-be3dbbe9e475
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-windows-container-deploy-cli.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/learn/quick-windows-container-deploy-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-windows-container-deploy-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 595f833b-e70d-725f-916e-3ff1e014c6bd
---

# Deploy a Windows Server Container on an Azure Kubernetes Service (AKS) Cluster using Azure CLI - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this article, you use Azure CLI to deploy an AKS cluster that runs Windows Server containers. You also deploy an ASP.NET sample application in a Windows Server container to the cluster.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- This article requires version 2.87.0 or later of the Azure CLI. If you're using Azure Cloud Shell, the latest version is already installed there.
- Make sure that the identity you're using to create your cluster has the appropriate minimum permissions. For more information about access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).
- If you have multiple Azure subscriptions, select the appropriate subscription ID in which the resources should be billed using the [`az account set`](/en-us/cli/azure/account#az-account-set) command. For more information, see [How to manage Azure subscriptions – Azure CLI](/en-us/cli/azure/manage-azure-subscriptions-azure-cli?tabs=bash#change-the-active-subscription).

## Create a resource group

An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) is a logical group in which Azure resources are deployed and managed. When you create a resource group, you're asked to specify a location. This location is where resource group metadata is stored and where your resources run in Azure if you don't specify another region during resource creation.

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command. The following example creates a resource group named *myResourceGroup* in the *WestUS2* location.

    ```azurecli
    export RANDOM_SUFFIX=$(openssl rand -hex 3)
    export REGION="canadacentral"
    export MY_RESOURCE_GROUP_NAME="myAKSResourceGroup$RANDOM_SUFFIX"
    az group create --name $MY_RESOURCE_GROUP_NAME --location $REGION
    ```

    Results:

    ```output
    {
      "id": "/subscriptions/xxxxx-xxxxx-xxxxx-xxxxx/resourceGroups/myResourceGroupxxxxx",
      "location": "WestUS2",
      "managedBy": null,
      "name": "myResourceGroupxxxxx",
      "properties": {
        "provisioningState": "Succeeded"
      },
      "tags": null,
      "type": "Microsoft.Resources/resourceGroups"
    }
    ```

## Create an AKS cluster

In this section, we create an AKS cluster with the following configuration:

- The cluster is configured with two nodes to ensure it operates reliably. A [node](../concepts-clusters-workloads#nodes) is an Azure virtual machine (VM) that runs the Kubernetes node components and container runtime.
- The `--windows-admin-password` and `--windows-admin-username` parameters set the administrator credentials for any Windows Server nodes on the cluster and must meet [Windows Server password requirements](/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements#reference).
- The node pool uses `VirtualMachineScaleSets`.

Use the following steps to create the AKS cluster with Azure CLI:

1. Create a username to use as administrator credentials for the Windows Server nodes on your cluster.

    ```bash
    export WINDOWS_USERNAME="winadmin"
    ```
2. Create a password for the administrator username you created in the previous step. The password must be a minimum of 14 characters and meet the [Windows Server password complexity requirements](/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements#reference).

    ```bash
    export WINDOWS_PASSWORD=$(echo "P@ssw0rd$(openssl rand -base64 10 | tr -dc 'A-Za-z0-9!@#$%^&*()' | cut -c1-6)")
    ```
3. Create your cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and specify the `--windows-admin-username` and `--windows-admin-password` parameters. The following example command creates a cluster using the values from `WINDOWS_USERNAME` and `WINDOWS_PASSWORD` you set in the previous commands. A random suffix is appended to the cluster name for uniqueness.

    ```azurecli
    export MY_AKS_CLUSTER="myAKSCluster$RANDOM_SUFFIX"
    az aks create \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER \
        --kubernetes-version 1.33 \
        --node-count 2 \
        --enable-addons monitoring \
        --generate-ssh-keys \
        --windows-admin-username $WINDOWS_USERNAME \
        --windows-admin-password $WINDOWS_PASSWORD \
        --vm-set-type VirtualMachineScaleSets \
        --network-plugin azure
    ```

    After a few minutes, the command completes and returns JSON-formatted information about the cluster. Occasionally, the cluster can take longer than a few minutes to provision. Allow up to 10 minutes for provisioning.

    If you get a password validation error, and the password that you set meets the length and complexity requirements, try creating your resource group in another region. Then try creating the cluster with the new resource group.

    If you don't specify an administrator username and password when creating the node pool, the username is set to *azureuser* and the password is set to a random value. For more information, see the [Windows Server FAQ](../windows-faq)

    You can't change the administrator username, but you can change the administrator password that your AKS cluster uses for Windows Server nodes using `az aks update`. For more information, see [Windows Server FAQ](../windows-faq).

    To run an AKS cluster that supports node pools for Windows Server containers, your cluster needs to use a network policy that uses [Azure CNI (advanced)](https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md) network plugin. The `--network-plugin azure` parameter specifies Azure CNI.

## Add a node pool

By default, all AKS clusters are created with a node pool that can run Linux containers. You must add a Windows node pool that can run Windows Server containers alongside the Linux node pool. To check if you have a Windows node pool in your cluster, you can view the nodes on your cluster using the `kubectl get nodes -o wide` command.

To create a Windows node pool, you need to specify a supported `OsType` and `OsSku`. Use the information in the following table to determine which is appropriate for your cluster:

| `OsType` | `OsSku` | Default | Supported K8s versions | Details |
| --- | --- | --- | --- | --- |
| `windows` | `Windows2025` | Default in K8s 1.36+ | 1.32+ | Updated defaults: `containerd` 2.0, Generation 2 image is used by default. FIPS is required - include `--enable-fips-image` when you create the node pool. |
| `windows` | `Windows2022` | Default in K8s 1.25-1.35 | Not available in K8s 1.37+ | Retires in June 2028. Updated defaults: FIPS is enabled by default. |

Windows Server 2025 is the default operating system for Kubernetes version 1.36 and later. Windows Server 2022 is the default for Kubernetes versions 1.25-1.35. If you don't specify a particular OS SKU, Azure creates the new node pool with the default SKU for the version of Kubernetes used by the cluster.

Important

Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

- Add a Windows node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with a specified `OsType` and `OsSku`. If you don't specify a particular OS SKU, Azure creates the new node pool with the default SKU for the version of Kubernetes used by the cluster. Windows Server 2025 node pools require a FIPS-enabled image, so the following command includes `--enable-fips-image`.

    ```azurecli
    az aks nodepool add \
      --resource-group $MY_RESOURCE_GROUP_NAME \
      --cluster-name $MY_AKS_CLUSTER \
      --os-type Windows \
      --os-sku Windows2025 \
      --enable-fips-image \
      --name npwin \
      --node-count 1
    ```

    This command creates a new node pool named *npwin* and adds it to *myAKSCluster*. The command also uses the default subnet in the default virtual network created when running `az aks create`.

## Connect to the cluster

You use [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client, to manage your Kubernetes clusters. If you use Azure Cloud Shell, `kubectl` is already installed. If you want to install and run `kubectl` locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_AKS_CLUSTER
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of the cluster nodes.

    ```bash
    kubectl get nodes -o wide
    ```

    The following example output shows all nodes in the cluster. Make sure the status of all nodes is *Ready*:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
    aks-nodepool1-20786768-vmss000000   Ready    agent   22h   v1.33.12   10.224.0.4    <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aks-nodepool1-20786768-vmss000001   Ready    agent   22h   v1.33.12   10.224.0.33   <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aksnpwin000000                      Ready    agent   20h   v1.33.12   10.224.0.62   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    ```

    Note

    The container runtime for each node pool is shown under *CONTAINER-RUNTIME*. The container runtime values begin with `containerd://`, which means that they each use `containerd` for the container runtime.

## Deploy the application

A Kubernetes manifest file defines a desired state for the cluster, such as what container images to run. In this article, you use a manifest to create all objects needed to run the ASP.NET sample application in a Windows Server container. This manifest includes a [Kubernetes deployment](../concepts-clusters-workloads#deployments-and-yaml-manifests) for the ASP.NET sample application and an external [Kubernetes service](../concepts-network-services) to access the application from the internet.

The ASP.NET sample application is provided as part of the [.NET Framework Samples](https://hub.docker.com/_/microsoft-dotnet-framework-samples/) and runs in a Windows Server container. AKS requires Windows Server containers to be based on images of *Windows Server 2022* or greater. The Kubernetes manifest file must also define a [node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) to tell your AKS cluster to run your ASP.NET sample application's pod on a node that can run Windows Server containers.

1. Create a file named `sample.yaml` and copy in the following YAML definition:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: sample
      labels:
        app: sample
    spec:
      replicas: 1
      template:
        metadata:
          name: sample
          labels:
            app: sample
        spec:
          nodeSelector:
            "kubernetes.io/os": windows
          containers:
          - name: sample
            image: mcr.microsoft.com/dotnet/framework/samples:aspnetapp
            resources:
              limits:
                cpu: 1
                memory: 800M
            ports:
              - containerPort: 80
      selector:
        matchLabels:
          app: sample
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: sample
    spec:
      type: LoadBalancer
      ports:
      - protocol: TCP
        port: 80
      selector:
        app: sample
    ```

    For a breakdown of YAML manifest files, see [Deployments and YAML manifests](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

    If you create and save the YAML file locally, then you can upload the manifest file to your default directory in CloudShell by selecting the **Upload/Download files** button and selecting the file from your local file system.
2. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f sample.yaml
    ```

    The following example output shows the deployment and service created successfully:

    ```output
    {
      "deployment.apps/sample": "created",
      "service/sample": "created"
    }
    ```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete. Occasionally, the service can take longer than a few minutes to provision. Allow up to 10 minutes for provisioning.

1. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make sure all pods are `Running` before proceeding.

    ```bash
    kubectl get pods
    ```
2. Monitor progress using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```bash
    while true; do
      export EXTERNAL_IP=$(kubectl get service sample -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2>/dev/null)
      if [[ -n "$EXTERNAL_IP" && "$EXTERNAL_IP" != "<pending>" ]]; then
        kubectl get service sample
        break
      fi
      echo "Still waiting for external IP assignment..."
      sleep 5
    done
    ```

    Initially, the output shows the *EXTERNAL-IP* for the sample service as *pending*:

    ```output
    NAME     TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
    sample   LoadBalancer   xx.xx.xx.xx    pending          xx:xxxx/TCP     2m
    ```
3. When the *EXTERNAL-IP* address changes from *pending* to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.

    The following example output replaces `<public-ip-address>` with a valid public IP address assigned to the service:

    ```output
    {
      "NAME": "sample",
      "TYPE": "LoadBalancer",
      "CLUSTER-IP": "10.0.37.27",
      "EXTERNAL-IP": "<public-ip-address>",
      "PORT(S)": "80:30572/TCP",
      "AGE": "2m"
    }
    ```
4. See the sample app in action by opening a web browser to the external IP address of your service after a few minutes.

    [![Screenshot of browsing to ASP.NET sample application.](media/quick-windows-container-deploy-cli/asp-net-sample-app.png)](media/quick-windows-container-deploy-cli/asp-net-sample-app.png#lightbox)