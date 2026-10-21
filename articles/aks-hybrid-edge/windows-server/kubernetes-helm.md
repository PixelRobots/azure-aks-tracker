---
layout: Conceptual
title: Install existing applications with Helm | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/kubernetes-helm
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
description: Learn how to use the Helm packaging tool to deploy containers on Azure Kubernetes Service (AKS) clusters in AKS on Windows Server.
services: container-service
author: davidsmatlak
ms.topic: how-to
ms.custom: linux-related-content, windows-server
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: scooley
locale: en-us
document_id: 7788528d-d8df-6612-8f27-34ed1475fb84
document_version_independent_id: c78bdfce-ce67-bbe0-f2a6-5c95415fe887
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/kubernetes-helm.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/kubernetes-helm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/kubernetes-helm.md
platformId: b0e5ead3-e694-f45c-7c0f-c92966c25620
---

# Install existing applications with Helm | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to configure and use Helm to install and manage Kubernetes applications in a Kubernetes cluster in AKS on Windows Server.

[Helm](https://github.com/kubernetes/helm/) is an open-source packaging tool that helps you install and manage the lifecycle of Kubernetes applications. Similar to Linux package managers such as **APT** and **Sum**, Helm manages Kubernetes charts, which are packages of pre-configured Kubernetes resources.

## Before you begin

Verify that you have set up the following requirements:

- A [Kubernetes cluster](setup) with at least one Linux worker node that's up and running.
- You configured your local `kubectl` environment to point to your cluster. You can use the [Get-AksHciCredential](/en-us/azure/aks/aksarc/reference/ps/get-akshcicredential) PowerShell command to access your cluster using `kubectl`.
- [Helm v3](https://helm.sh/docs/intro/install/) command line and prerequisites are installed.
- You can use [Azure CLI](/en-us/cli/azure/install-azure-cli) to run commands, if you prefer this to PowerShell.

Important

Helm is intended to run on Linux nodes. If your cluster has Windows Server nodes, you must ensure that Helm pods are scheduled to run only on Linux nodes. You must also ensure that any Helm charts you install are scheduled to run on the correct nodes. The commands in this article use [node selectors](adapt-apps-mixed-os-clusters#node-selectors) to make sure pods are scheduled to the correct nodes, but not all Helm charts expose a node selector. You can also use other options, such as [taints](adapt-apps-mixed-os-clusters#taints-and-tolerations), on your cluster.

## Verify your version of Helm

Use the `helm version` command to verify you have Helm 3 installed:

```console
helm version
```

The following example shows Helm version 3.5.4 installed:

```output
version.BuildInfo{Version:"v3.5.4", GitCommit:"1b5edb69df3d3a08df77c9902dc17af864ff05d1", GitTreeState:"clean", GoVersion:"go1.15.11"}
```

## Install an application with Helm v3

### Add Helm repositories

Use the [helm repo](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository) command to add the *ingress-nginx* repository.

```console
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

### Find Helm charts

Helm charts are used to deploy applications into a Kubernetes cluster. To search for pre-created Helm charts, use the [helm search](https://helm.sh/docs/intro/using_helm/#helm-search-finding-charts) command:

```console
helm search repo ingress-nginx
```

The following condensed example output shows some of the Helm charts available for use:

```output
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
ingress-nginx/ingress-nginx     3.30.0          0.46.0          Ingress controller for Kubernetes using NGINX a...
```

To update the list of charts, use the [helm repo update](https://helm.sh/docs/intro/using_helm/#helm-repo-working-with-repositories) command.

```console
helm repo update
```

The following example shows a successful repo update:

```output
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
Update Complete. Happy Helming!
```

### Run Helm charts

To install charts with Helm, use the [helm install](https://helm.sh/docs/intro/using_helm/#helm-install-installing-a-package) command, and specify a release name and the name of the chart to install. To see a Helm chart installation in action, install a basic nginx deployment using a Helm chart.

The following command is provided twice, one for use in Azure CLI, and one for use in a PowerShell console:

```azurecli
helm install my-nginx-ingress ingress-nginx/ingress-nginx \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```

```powershell
helm install my-nginx-ingress ingress-nginx/ingress-nginx `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```

The following condensed example output shows the deployment status of the Kubernetes resources created by the Helm chart:

```output
>     --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
>     --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

NAME: my-nginx-ingress
LAST DEPLOYED: Fri May 14 17:43:27 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w my-nginx-ingress-ingress-nginx-controller'
...
```

Use the `kubectl get services` command to get the **EXTERNAL-IP** of your service:

```console
kubectl --namespace default get services -o wide -w my-nginx-ingress-ingress-nginx-controller
```

For example, the following command shows the **EXTERNAL-IP** for the **my-nginx-ingress-ingress-nginx-controller** service:

```output
NAME                                        TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
my-nginx-ingress-ingress-nginx-controller   LoadBalancer   10.98.53.215 <EXTERNAL-IP>    80:31553/TCP,443:30784/TCP   72s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=my-nginx-ingress,app.kubernetes.io/name=ingress-nginx
```

### List releases

To see a list of releases installed on your cluster, use the `helm list` command.

```console
helm list
```

The following example shows the **my-nginx-ingress** release deployed in the previous step:

```output
NAME                NAMESPACE    REVISION    UPDATED                                 STATUS      CHART                   APP VERSION
my-nginx-ingress    default      1           2021-05-14 17:43:27.1670709 +0000 UTC    deployed    nginx-ingress-3.30.0    0.46.0 
```

### Clean up resources

When you deploy a Helm chart, many Kubernetes resources are created. These resources include pods, deployments, and services. To clean up these resources, use the [helm uninstall](https://helm.sh/docs/intro/using_helm/#helm-uninstall-uninstalling-a-release) command and specify your release name, as found in the previous `helm list` command:

```console
helm uninstall my-nginx-ingress
```

The following example output shows that the release **my-nginx-ingress** has been uninstalled:

```output
release "my-nginx-ingress" uninstalled
```