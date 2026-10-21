---
layout: Conceptual
title: Use OpenFaaS with AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/openfaas
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
description: Learn how to deploy and use OpenFaaS on an Azure Kubernetes Service (AKS) cluster to build serverless functions with containers in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.custom: windows-server - linux-related-content - sfi-ropc-nochange
locale: en-us
document_id: e5c6e863-7f12-6765-e004-58f88a64a345
document_version_independent_id: c276523a-d2f3-accf-8582-daa726c9c8bc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/openfaas.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/openfaas
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/openfaas.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/540ac133-a371-4dbb-8f94-28d6cc77a70b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/60bfc045-f127-4841-9d00-ea35495a5800
platformId: 8396ad35-c611-9944-2017-7f07bf37dd99
---

# Use OpenFaaS with AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

[OpenFaaS](https://www.openfaas.com/) is a framework for building serverless functions by using containers. As an open source project, it gained large-scale adoption within the community. This article describes installing and using OpenFaas on a Kubernetes cluster running on AKS on Windows Server.

## Prerequisites

In order to complete the steps in this article, make sure you have the following requirements:

- A basic understanding of [Kubernetes](kubernetes-concepts).
- A [Kubernetes cluster](setup) with at least one Linux worker node that's up and running.
- Your local `kubectl` environment is configured to point to your cluster. You can use the [Get-AksHciCredential](/en-us/azure/aks/aksarc/reference/ps/get-akshcicredential) PowerShell command to access your cluster using `kubectl`.
- [Helm v3](https://helm.sh/docs/intro/install/) command line and prerequisites are installed.
- You can use [Azure CLI](/en-us/cli/azure/install-azure-cli) to run commands if you prefer Azure CLI to PowerShell.
- Git command-line tools are installed on your system.
- The `OpenFaaS` CLI is installed. For installation options, see the [OpenFaaS CLI documentation](https://github.com/openfaas/faas-cli).

Important

Helm is intended to run on Linux nodes. If your cluster has Windows Server nodes, you must ensure that Helm pods are scheduled to run only on Linux nodes. You must also ensure that any Helm charts you install are scheduled to run on the correct nodes. The commands in this article use [node selectors](adapt-apps-mixed-os-clusters#node-selectors) to make sure pods are scheduled to the correct nodes, but not all Helm charts expose a node selector. You can also use other options, such as [taints](adapt-apps-mixed-os-clusters#taints-and-tolerations), on your cluster.

## Add the OpenFaaS Helm chart repo

With your **kubeconfig** file available, open your console to start the deployment process. If you're running on Windows, downloading and running Git Bash is the easiest way to follow along. From there, OpenFaaS maintains its own Helm charts to keep up to date with all the latest changes:

```console
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update
```

## Deploy OpenFaaS

As a best practice, OpenFaaS and OpenFaaS functions should be stored in their own Kubernetes namespace.

Create a namespace for the OpenFaaS system and functions:

```console
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
```

Generate a password for the OpenFaaS UI Portal and REST API:

```console
# generate a random password
PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)

kubectl -n openfaas create secret generic basic-auth \
--from-literal=basic-auth-user=admin \
--from-literal=basic-auth-password="$PASSWORD"
```

You can get the value of the secret with `echo $PASSWORD`.

The Helm chart uses the password you create here to enable basic authentication on the OpenFaaS Gateway, which is exposed externally through a load balancer.

A Helm chart for OpenFaaS is included in the cloned repository. Use this chart to deploy OpenFaaS on your Kubernetes cluster:

```console
helm upgrade openfaas --install openfaas/openfaas \
    --namespace openfaas  \
    --set basic_auth=true \
    --set functionNamespace=openfaas-fn \
    --set serviceType=LoadBalancer
```

Output:

```output
NAME:   openfaas
LAST DEPLOYED: Fri May 14 18:35:47 2021
NAMESPACE: openfaas
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

To verify that OpenFaas started, run the following command:

```console
kubectl --namespace=openfaas get deployments -l "release=openfaas, app=openfaas"
```

A public IP address is created for accessing the OpenFaaS gateway. To retrieve this IP address, use the [kubectl get service](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. It can take a minute for the IP address to be assigned to the service:

```console
kubectl get service -l component=gateway --namespace openfaas
```

Output:

```output
NAME               TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
gateway            ClusterIP      10.110.205.41  <none>         8080/TCP         7m
gateway-external   LoadBalancer   10.107.51.110  192.168.0.152  8080:32029/TCP   7m
```

To test the OpenFaaS system, browse to the external IP address on port 8080 - `http://192.168.0.152:8080` in this example. You are prompted to sign in. To retrieve your password, enter `echo $PASSWORD`.

![OpenFaaS UI](../media/container-service-serverless/openfaas.png)

Set `$OPENFAAS_URL` to the External-IP found in this example.

Sign in with your console. If you run commands in GitBash on Windows, you might need to use `faas-cli` instead of `./faas-cli` in the following command:

```console
export OPENFAAS_URL=http://192.168.0.152:8080
echo -n $PASSWORD | ./faas-cli login -g $OPENFAAS_URL -u admin --password-stdin
```

## Create first function

Now that OpenFaaS is operational, create a function using the OpenFaaS portal.

Select **Deploy New Function**, and search for **Figlet**. Select the Figlet function, and then click **Deploy**.

![Screenshot shows the Deploy A New Function dialog box in OpenFAAS, with &quot;figlet&quot; typed in the search line.](../media/container-service-serverless/figlet.png)

Use `curl` to invoke the function. Replace the IP address in the following example with the address of your OpenFaaS gateway.

```console
curl -X POST http://192.168.0.152:8080/function/figlet -d "Hello Azure"
```

Output:

```output
 _   _      _ _            _
| | | | ___| | | ___      / \    _____   _ _ __ ___
| |_| |/ _ \ | |/ _ \    / _ \  |_  / | | | '__/ _ \
|  _  |  __/ | | (_) |  / ___ \  / /| |_| | | |  __/
|_| |_|\___|_|_|\___/  /_/   \_\/___|\__,_|_|  \___|

```

### Clean up resources

When you deploy a Helm chart, many Kubernetes resources are created. These resources include pods, deployments, and services. To clean up these resources, use the `helm uninstall` command, and specify your release name, as found in the previous `helm list` command:

```console
helm uninstall openfaas
```

The following example shows that the release named **openfaas** was uninstalled:

```output
release "openfaas" uninstalled
```