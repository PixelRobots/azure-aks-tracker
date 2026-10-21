---
layout: Conceptual
title: Create Windows node pools | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/howto-create-windows-node-pools
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
description: Learn how to create Windows node pools in AKS Hybrid and Edge on Azure Local.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2025-09-22T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: dbf1a294-268a-af32-8131-5ae024766d0f
document_version_independent_id: 76ca0c61-ec01-58de-4e2e-537127fb7e12
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/howto-create-windows-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/howto-create-windows-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/howto-create-windows-node-pools.md
platformId: 5bd03707-9326-5cfc-e939-23f4fd67e40b
---

# Create Windows node pools | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes how to use Azure CLI to deploy a Windows node pool to an existing AKS cluster in order to run Windows Server containers. The article also describes how to deploy a sample ASP.NET application in a Windows Server container to the cluster.

## Prerequisites

Create an AKS cluster following the instructions in [How to create AKS clusters](../aks-create-clusters-cli).

Important

Windows Server node pools must be licensed using either the Windows Server subscription or Azure Hybrid Benefit, as described in [Activate Windows Server VMs on Azure Local](/en-us/azure/azure-local/manage/vm-activate).

### gMSA authentication isn't supported for Windows node pools on Azure Local 23H2 and 24H2

[Group Managed Service Account (gMSA)](/en-us/windows-server/identity/ad-ds/manage/group-managed-service-accounts/group-managed-service-accounts/group-managed-service-accounts-overview) authentication for Windows node pools isn't supported on AKS on Azure Local 23H2 and 24H2 or Windows node pools that require gMSA-based authentication for Active Directory access.

The gMSA components are preinstalled on Windows node pools, but the configuration path to set up gMSA authentication isn't available through CLI commands, APIs, or other management tools. Customers who follow standard Kubernetes documentation for Windows containers and create a credential spec receive anonymous sign-in failures because the required `HostAccountConfig` configuration isn't supported.

For example, after deploying a Windows container workload that requires gMSA-based authentication (Kerberos or NTLM), pods fail to authenticate against Active Directory. Applications receive `NT AUTHORITY\ANONYMOUS LOGON` errors for all Kerberos and NTLM authentication calls from the container.

An option to resolve this limitation is to move workloads to a platform that supports gMSA for Windows nodes, like Azure Kubernetes Service (AKS). For more information, see how to [enable gMSA for Windows Server nodes on an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/use-group-managed-service-accounts).

## Add a Windows node pool

By default, a Kubernetes cluster is created with a node pool that can run Linux containers. Starting with the Azure local 2509 release, the Windows node pool feature is disabled by default. You must first enable the Windows node pool feature before you can create a Windows node pool. For more information, see [Enable Windows node pools](howto-enable-windows-node-pools).

Add a node pool with Windows container hosts using the `az aksarc nodepool add` command with the parameter `--os-type Windows`. If the operating system SKU isn't specified, the node pool is set to the default OS based on the Kubernetes version of the cluster. Windows Server 2022 is the default operating system for Kubernetes versions 1.25.0 and higher.

To use Windows Server 2022, specify the following parameters:

- `--os-type` set to `Windows`.
- `--os-sku` set to `Windows2022` (optional).

The following command creates a new node pool named `$mynodepool` and adds it to `$myAKSCluster` with one Windows Server 2022 node:

```azurecli
az aksarc nodepool add --resource-group $myResourceGroup --cluster-name $myAKSCluster --name $mynodepool --node-count 1 --os-type Windows --os-sku Windows2022
```

## Connect to the AKS cluster

Now you can connect to your Kubernetes cluster by running the `az connectedk8s proxy` command from your local machine. Make sure you sign in to Azure before running this command. If you have multiple Azure subscriptions, select the appropriate subscription ID using the [az account set](/en-us/cli/azure/account#az-account-set) command.

The following command downloads the kubeconfig of your Kubernetes cluster to your local machine and opens a proxy connection channel to your on-premises Kubernetes cluster. The channel is open for as long as this command runs. Let this command run for as long as you want to access your cluster. If the command times out, close the CLI window, open a new one, then run the command again.

You must have Contributor permissions on the resource group that hosts the AKS cluster in order to run the following command successfully:

```azurecli
az connectedk8s proxy --name $aksclustername --resource-group $resource_group --file .\aks-arc-kube-config
```

Expected output:

```output
Proxy is listening on port 47011
Merged "aks-workload" as current context in .\aks-arc-kube-config
Start sending kubectl requests on 'aks-workload' context using kubeconfig at .\aks-arc-kube-config
Press Ctrl+C to close proxy.
```

Keep this session running and connect to your Kubernetes cluster from a different terminal/command prompt. Verify that you can connect to your Kubernetes cluster by running the `kubectl get` command. This command returns a list of the cluster nodes:

```azurecli
kubectl get node -A --kubeconfig .\aks-arc-kube-config
```

The following example output shows the node created in the previous steps. Make sure the node status is **Ready**:

```output
NAME              STATUS   ROLES           AGE     VERSION
moc-lesdc78871d   Ready    control-plane   6d8h    v1.26.3
moc-lupeeyd0f8c   Ready    <none>          6d8h    v1.26.3
moc-ww2c8d5ranw   Ready    <none>          7m18s   v1.26.3
```

## Deploy the sample application

A [Kubernetes manifest file](../../windows-server/kubernetes-concepts#deployments) defines a cluster's desired state, such as which container images to run.

You can use a YAML manifest to create all the objects needed to run the ASP.NET sample application in a Windows Server container. This manifest includes a [Kubernetes deployment](../../windows-server/kubernetes-concepts#deployments) for the ASP.NET sample application and a Kubernetes service to access the application from the internet.

The ASP.NET sample application is provided as part of the [.NET Framework samples](https://hub.docker.com/_/microsoft-dotnet-framework-samples/) and runs in a Windows Server container. AKS requires Windows Server containers to be based on images of Windows Server 2019 or later. The Kubernetes manifest file must also define a [node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) to ensure your ASP.NET sample application's pods are scheduled on a node that can run Windows Server containers.

1. Create a file named *sample.yaml* and paste the following YAML definition:

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

    For a breakdown of YAML manifest files, see [Deployments and YAML manifests](/en-us/azure/aks/concepts-clusters-workloads#deployments-and-yaml-manifests).
2. Deploy the application using the [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest:

    ```azurecli
    kubectl apply -f sample.yaml --kubeconfig .\\aks-arc-kube-config
    ```

The following example output shows that the deployment and service were created successfully:

```output
deployment.apps/sample created
service/sample created
```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete. Occasionally, the service can take longer than a few minutes to provision. Allow up to 10 minutes for provisioning.

1. Monitor progress using the [kubectl get service](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```azurecli
    kubectl get service sample --watch --kubeconfig .\aks-arc-kube-config
    ```

    Initially, the output shows the **EXTERNAL-IP** for the sample service as **pending**:

    ```output
    NAME   TYPE         CLUSTER-IP EXTERNAL-IP PORT(S)      AGE
    sample LoadBalancer 10.0.37.27 <pending>   80:30572/TCP 6s
    ```

    When the **EXTERNAL-IP** address changes from **pending** to an IP address, use CTRL-C to stop the kubectl watch process. The following example output shows a valid public IP address assigned to the service:

    ```output
    sample LoadBalancer 10.0.37.27 52.179.23.131 80:30572/TCP 2m
    ```
2. See the sample app in action by opening a web browser to the external IP address and port of the **sample** service.

    [![Screenshot showing ASP.NET sample application.](../../media/howto-create-windows-node-pools/sample-app.png)](../../media/howto-create-windows-node-pools/sample-app.png#lightbox)

    If you receive a connection timeout when trying to load the page, you should verify that the sample app is ready using the `kubectl get pods --watch` command. Sometimes, the Windows container isn't started by the time your external IP address is available.

## Delete node pool

Delete the node pool using the `az aksarc nodepool delete`command:

```azurecli
az aksarc nodepool delete -g $myResourceGroup --cluster-name $myAKSCluster --name $mynodepool --no-wait
```