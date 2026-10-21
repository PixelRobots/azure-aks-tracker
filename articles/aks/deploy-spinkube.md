---
layout: Conceptual
title: Deploy SpinKube to Azure Kubernetes Service (AKS) to run serverless WebAssembly (Wasm) workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-spinkube
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to deploy the open-source stack SpinKube to Azure Kubernetes Service (AKS) to run serverless WebAssembly (Wasm) workload on Kubernetes.
ms.topic: how-to
ms.custom: aks-data-messaging
ms.date: 2024-11-11T00:00:00.0000000Z
author: thorstenhans
ms.author: schaffererin
locale: en-us
document_id: 7518244a-f8c8-713c-1258-1724c1958947
document_version_independent_id: 138e6a0f-b53b-27cf-1200-5bf97596ede4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-spinkube.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-spinkube
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-spinkube.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e9152a4c-c6b6-542e-9f35-8482ebd1f26b
---

# Deploy SpinKube to Azure Kubernetes Service (AKS) to run serverless WebAssembly (Wasm) workloads - Azure Kubernetes Service | Microsoft Learn

This article shows you how to deploy SpinKube to Azure Kubernetes Service (AKS) to run serverless WebAssembly (Wasm) workloads.

## Overview

[WebAssembly (Wasm)](https://webassembly.org/) is a binary format optimized for fast download and near-native execution speed. It runs in a sandbox isolated from the host computer provided by a Wasm runtime. By default, WebAssembly modules can't access resources, including sockets and environment variables, on the host outside of the sandbox unless they're explicitly allowed. The [WebAssembly System Interface (WASI)](https://wasi.dev/) standard defines a set of interfaces for Wasm runtimes to provide access to WebAssembly modules to the environment and resources outside the host using a capability-based security model.

[SpinKube](https://spinkube.dev/) is an open-source project that runs serverless Wasm workloads (Spin Apps) built with open-source [Spin](https://spin.fermyon.dev/) in Kubernetes. In contrast to earlier Wasm runtimes for Kubernetes, SpinKube executes Spin Apps natively on the underlying Kubernetes nodes and doesn't rely on containers. Spin Apps are regular Wasm modules that align with the [WebAssembly Component Model](https://github.com/WebAssembly/component-model) specification.

By running Spin Apps on Kubernetes with SpinKube, you can run the following workloads:

- Run Wasm workloads next to existing containerized applications.
- Run similar workloads while consuming fewer resources.
- Run more workloads on a given set of resources.
- Run workloads on different architectures (such as `amd64` and `arm64`) without cross-compiling them.

SpinKube consists of two top-level components:

- **`spin-operator`**: A Kubernetes operator allowing the deployment and management of Spin Apps by using custom resources.
- **`kube` plugin for `spin`**: A `spin` CLI plugin allowing users to scaffold Kubernetes deployment manifests for Spin Apps.

## Prerequisites

- Azure CLI version `2.64.0` or later. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) version `1.31.0` or later.
- [`helm`](https://helm.sh) version `3.15.4` or later.
- [`spin`](https://developer.fermyon.com/spin/v3/install) version `3.0.0` or later.
- [Node.js](https://nodejs.org/en) version `21.6.2`.
- An existing AKS cluster. If you don't have one, see [Create an AKS cluster](learn/quick-kubernetes-deploy-cli).

## Limitations

- The Kubernetes node `os-type` must be Linux.
- You can't use the Azure portal to deploy SpinKube to an AKS cluster.

## Deploy SpinKube to an existing cluster

### Connect to your AKS cluster

- Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --name <aks-cluster-name> --resource-group <resource-group-name>
    ```

### Deploy `cert-manager`

If you haven't deployed [`cert-manager`](https://cert-manager.io/) to your AKS cluster yet, you can install it by deploying its Custom Resource Definitions (CRDs) followed by the `cert-manager` Helm chart provided through the `jetstack` repository.

1. Deploy the `cert-manager` CRDs and Helm chart using the `kubectl apply` command.

    ```bash
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml
    ```
2. Add and update the Jetstack repository using the `helm repo add` and `helm repo update` commands.

    ```bash
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    ```
3. Install the `cert-manager` Helm chart using the `helm install` command.

    ```bash
    helm install \
      cert-manager jetstack/cert-manager --version v1.14.3 \
      --namespace cert-manager --create-namespace \
      --wait
    ```

### Deploy `runtime-class-manager` (also known as KWasm)

The `runtime-class-manager` (also known as [KWasm](https://kwasm.sh)) is responsible for deploying and managing [`containerd-shim`](https://github.com/containerd/containerd/blob/main/core/runtime/v2/README.md#runtime-shim) on the desired Kubernetes nodes.

1. Add the KWasm Helm repository using the `helm repo add` command.

    ```bash
    helm repo add kwasm http://kwasm.sh/kwasm-operator/
    ```
2. Install the KWasm operator using the `helm install` command.

    ```bash
    helm install \
      kwasm-operator kwasm/kwasm-operator \
      --namespace kwasm --create-namespace \
      --version 0.2.3 \
      --set kwasmOperator.installerImage=ghcr.io/spinframework/containerd-shim-spin/node-installer:v0.19.0
    ```

#### Provision containerd-shim-spin to Kubernetes nodes

Once `runtime-class-manager` is installed on your AKS cluster, you must annotate the Kubernetes nodes that should be able to run Spin Apps with `kwasm.sh/kwasm-node=true`. You can use `kubectl annotate node` to annotate all the nodes or only specific nodes in your AKS cluster. In this example, we annotate all nodes in the AKS cluster with the `kwasm.sh/kwasm-node=true` annotation.

1. Provision `containerd-shim-spin` to all nodes in the AKS cluster using the `kubectl annotate node --all` command.

    ```bash
    kubectl annotate node --all kwasm.sh/kwasm-node=true
    ```
2. After you annotate the Kubernetes nodes, `runtime-class-manager` uses a Kubernetes *Job* to modify the desired nodes. After successful deployment of `containerd-shim-spin`, the nodes are labeled with a `kwasm.sh/kwasm-provisioned` label. You can check if the desired nodes have the `kwasm.sh/kwasm-provisioned` label assigned using the `kubectl get nodes --show-labels` command.

    ```bash
    kubectl get nodes --show-labels
    ```

### Deploy the `spin-operator`

The `spin-operator` consists of two Custom Resource Definitions (CRDs) that you need to deploy to your AKS cluster: the RuntimeClass for `spin` and a `SpinAppExecutor`.

1. Deploy the CRDs and the RuntimeClass for `spin` using the `kubectl apply` command.

    ```bash
    kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
    kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.runtime-class.yaml
    ```
2. Deploy the `spin-operator` using the `helm install` command.

    ```bash
    helm install spin-operator --version 0.5.0 \
      --namespace spin-operator --create-namespace \
      --wait oci://ghcr.io/spinframework/charts/spin-operator
    ```
3. Create a `SpinAppExecutor` in the default namespace using the `kubectl apply` command.

    ```bash
    kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml
    ```

## Run a Spin App on AKS

In this section, you verify the SpinKube installation by creating a simple Spin App using the `spin` CLI and JavaScript.

### Create a new Spin App

1. Create a new Spin App using the `spin new` command with the `http-js` template.

    ```bash
    spin new -t http-js --accept-defaults hello-spinkube
    ```
2. Change to the `hello-spinkube` directory using the `cd` command.

    ```bash
    cd hello-spinkube
    ```
3. Install the dependencies using the `npm install` command.

    ```bash
    npm install
    ```
4. Use the `spin` CLI create a basic *Hello, World* application.

    ```bash
    spin build
    ```

### Create container registry and authenticate the `spin` CLI

1. Spin Apps are packaged as OCI artifacts and distributed via an OCI compliant registry like Azure Container Registry (ACR). Create a new ACR instance using the [`az acr create`](/en-us/cli/azure/acr#az-acr-create) command.

    ```azurecli
    az acr create --name <acr-name> --resource-group <resource-group-name> --location <location> --sku Basic --admin-enabled true
    ```
2. Get the ACR login server endpoint and the admin password using the [`az acr show`](/en-us/cli/azure/acr#az-acr-show) and [`az acr credential show`](/en-us/cli/azure/acr#az-acr-credential-show) commands.

    ```azurecli
    ACR_LOGIN_SERVER=$(az acr show -n <acr-name> -g <resource-group-name> --query 'loginServer' -otsv)
    ACR_PASSWORD=$(az acr credential show -n <acr-name> -g <resource-group-name> --query 'passwords[0].value' -otsv)
    ```
3. Authenticate your `spin` CLI using the `spin registry login` command.

    ```bash
    spin registry login -u $ACR_NAME -p $ACR_PASSWORD $ACR_LOGIN_SERVER
    ```

### Package, distribute, and deploy the Spin App

1. Now that the `spin` CLI is authenticated against the ACR instance, you can package and distribute the Spin App using the `spin registry push` command followed by an OCI artifact reference (which follows the `<your acr login server>/<repository-name>:<tag>` naming scheme).

    ```bash
    spin registry push $ACR_LOGIN_SERVER/hello-spinkube:0.0.1
    ```
2. Create a Kubernetes Secret of type `docker-registry` for referencing during the deployment of the Spin App to your AKS cluster using the `kubectl create secret` command. In this example, the secret is named `spinkube-on-aks`.

    ```bash
    kubectl create secret docker-registry spinkube-on-aks \
      --docker-server=$ACR_LOGIN_SERVER \
      --docker-username=$ACR_NAME\
      --docker-password $ACR_PASSWORD
    ```
3. Create the necessary Kubernetes deployment manifests using the `spin kube scaffold` command.

    ```bash
    spin kube scaffold --from $ACR_LOGIN_SERVER/hello-spinkube:0.0.1 -s spinkube-on-aks > spinapp.yaml
    ```

    The `spinapp.yaml` file contains a preconfigured instance of the `SpinApp` CRD, which should look like this:

    ```yaml
    apiVersion: core.spinoperator.dev/v1alpha1
    kind: SpinApp
    metadata:
      name: hello-spinkube
    spec:
      image: "<your acr name>.azurecr.io/hello-spinkube:0.0.1"
      executor: containerd-shim-spin
      replicas: 2
      imagePullSecrets:
        - name: spinkube-on-aks
    ```
4. Deploy the Spin App to the AKS cluster using the `kubectl apply` command.

    ```bash
    kubectl apply -f spinapp.yaml
    ```

## Explore the Spin App in AKS

### Retrieve the list of Spin Apps

- Retrieve the list of Spin Apps using the `kubectl get spinapps` command.

    ```bash
    kubectl get spinapps
    ```

    ```output
    NAME             READY   DESIRED   EXECUTOR
    hello-spinkube   2       2         containerd-shim-spin
    ```

### Retrieve the Kubernetes primitives created by the `spin-operator`

Upon deployment, the `spin-operator` creates underlying Kubernetes primitives such as a *Service*, a *Deployment*, and corresponding *Pods*.

1. Retrieve the list of services using the `kubectl get service` command.

    ```bash
    kubectl get service
    ```

    ```output
    NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
    hello-spinkube   ClusterIP   10.43.35.78   <none>        80/TCP    24s
    ```
2. Retrieve the list of deployments using the `kubectl get deployment` command.

    ```bash
    kubectl get deployment
    ```

    ```output
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    hello-spinkube   2/2     2            2           38s
    ```
3. Retrieve the list of pods using the `kubectl get pod` command.

    ```bash
    kubectl get pod
    ```

    ```output
    NAME                              READY   STATUS    RESTARTS   AGE
    hello-spinkube-5b8579448d-zmc6x   1/1     Running   0          51s
    hello-spinkube-5b8579448d-bhkp9   1/1     Running   0          51s
    ```

### Invoke the Spin App

To invoke the Spin App, you configure port-forwarding to the service provisioned by the `spin-operator` and use `curl` for sending HTTP requests.

1. Establish port forwarding to the `hello-spinkube` service using the `kubectl port-forward` command.

    ```bash
    kubectl port-forward svc/hello-spinkube 8080:80
    ```

    ```output
    Forwarding from 127.0.0.1:8080 -> 80
    Forwarding from [::1]:8080 -> 80
    ```
2. Open a new terminal instance and use the following `curl` command to send an HTTP request to `localhost:8080`.

    ```bash
    curl -iX GET localhost:8080
    ```

    ```output
    HTTP/1.1 200 OK
    content-type: text/plain
    content-length: 17
    date: Tue, 28 May 2024 08:55:50 GMT
    Hello from JS-SDK
    ```

## Clean up resources

1. Remove the Spin App from the AKS cluster using the `kubectl delete` command.

    ```bash
    kubectl delete spinapp hello-spinkube
    ```
2. Remove the docker-registry Secret (spinkube-on-aks) using the `kubectl delete secret` command.

    ```bash
    kubectl delete secret spinkube-on-aks
    ```
3. Remove the ACR instance you created as part of this tutorial using the [`az acr delete`](/en-us/cli/azure/acr#az-acr-delete) command.

    ```azurecli
    az acr delete --name <acr-name> --resource-group <resource-group-name> --yes
    ```
4. Remove the SpinKube components from the AKS cluster using the following commands.

    ```bash
    # Remove the spin-operator
    helm delete spin-operator --namespace spin-operator
    
    # Remove the SpinAppExecutor
    kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml
    
    # Remove the RuntimeClass for Spin
    kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.runtime-class.yaml
    
    # Remove the SpinKube CRDs
    kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
    
    # Remove runtime-class-manager (also known as KWasm)
    helm delete kwasm-operator --namespace kwasm
    
    # Remove cert-manager Helm Release
    helm delete cert-manager --namespace cert-manager
    
    # Remove cert-manager CRDs
    kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml
    ```