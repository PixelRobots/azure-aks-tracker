---
layout: Conceptual
title: Use Telepresence to develop and test microservices locally - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-telepresence-aks
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
description: Learn how to use Telepresence to debug microservices on AKS
ms.topic: tutorial
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2025-01-16T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: afba5548-7d59-2890-140c-3da9da621668
document_version_independent_id: 27c7f95d-89b4-2613-1c8b-2d19676bfdca
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-telepresence-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-telepresence-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-telepresence-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a5147b4d-ed4b-b049-6fbe-7cfc02292041
---

# Use Telepresence to develop and test microservices locally - Azure Kubernetes Service | Microsoft Learn

[Telepresence](https://www.telepresence.io/#gsc.tab=0) is a Cloud Native Computing Foundation (CNCF) Sandbox project created by the team at Ambassador Labs. Telepresence allows developers to run services locally on their development machine while connected to a remote Kubernetes cluster. This setup makes it easier to develop, debug, and test applications that interact with other services in the cluster without having to redeploy or rebuild the entire application in Kubernetes every time changes are made.

Note

Telepresence is an open-source CNCF project. Microsoft doesn't offer support for problems you might have using Telepresence. If you do have problems using Telepresence, visit their [Telepresence GitHub issue page](https://github.com/telepresenceio/telepresence/issues) and open an issue.

In this tutorial, you connect an AKS cluster to Telepresence and then modify a sample application running locally.

## How Telepresence works

Telepresence injects Traffic Agents into the workload pod as a sidecar. The Traffic Agents act as a proxy, rerouting inbound and outbound network traffic from the AKS cluster to your local machine. Then, you can develop and test in your local environment as though your local machine were in the AKS cluster. The process involves:

- Connecting to your AKS cluster to Telepresence.
- Specifying the service or deployment you want to intercept inbound and outbound traffic for and then reroute to your local environment.
- Running the local version of the service. Telepresence connects the local version of the service to the cluster through the proxy pod.

## Prerequisites

- An AKS cluster. If you don't have a cluster you can use for this tutorial, create one using [Tutorial - Create an Azure Kubernetes Service (AKS) cluster](tutorial-kubernetes-deploy-cluster).
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) is installed and on the path in command-line environment you use for development. This tutorial uses `kubectl` to manage the Kubernetes cluster. `kubectl` is already installed if you use Azure Cloud Shell. To install `kubectl` locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.
- Install [Node.js LTS](https://nodejs.org). Run the command `node --version` to verify that Node.js is installed.

## Connect to cluster using kubectl

Note

Set the values of $MY\_RESOURCE\_GROUP\_NAME and $MY\_AKS\_CLUSTER\_NAME accordingly.

Before you can install Telepresence and interact with your AKS cluster, make sure you're connected to your cluster. If you didn't install `kubectl` in the *Prerequisites* section, do that before continuing.

1. Configure `kubectl` to connect to your AKS cluster using the [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_AKS_CLUSTER_NAME
    ```
2. Verify the connection to your cluster using the [kubectl cluster-info](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command displays the name of the cluster so you can confirm you're connected to the cluster you want to work with.

    ```azurecli
    kubectl cluster-info
    ```

## Clone the sample app and deploy it your AKS cluster

The [aks-store-demo app](https://github.com/Azure-Samples/aks-store-demo) used in this tutorial is a basic store front app including the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/container-service-kubernetes-tutorials/aks-store-architecture.png)](media/container-service-kubernetes-tutorials/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

1. Use [git](https://git-scm.com/downloads) to clone the sample application to your development environment.

    ```console
    git clone https://github.com/Azure-Samples/aks-store-demo.git
    ```
2. Change into the cloned directory.

    ```console
    cd aks-store-demo
    ```
3. Deploy the app to your AKS cluster.

    ```console
    kubectl apply -f aks-store-quickstart.yaml
    ```

## Install Telepresence

To intercept traffic to and from your AKS cluster, you need to install the Telepresence client on your local machine and the traffic manager to your AKS cluster.

### Install the Telepresence client

Choose the OS you're using on your local machine and install that version of Telepresence.

- [GNU/Linux](https://www.telepresence.io/docs/install/client/?os=gnu-linux#gsc.tab=0)
- [Mac](https://www.telepresence.io/docs/install/client/?os=macos#gsc.tab=0)
- [Windows](https://www.telepresence.io/docs/install/client/?os=windows#gsc.tab=0)

Refer to the Telepresence documentation for installation instructions.

### Install the Telepresence traffic manager

To route cloud traffic to your local machine, Telepresence uses a traffic manager. Helm is used to deploy the traffic manager into your Kubernetes cluster.

```console
telepresence helm install
```

## Intercept traffic to your service

Complete the following steps to intercept traffic going to your service in the AKS cluster and route it to your local machine.

1. From the command line on your local machine, run `telepresence connect` to connect to your AKS cluster and the Kubernetes API server.

    ```console
    telepresence connect
    ```

    A successful response from `telepresence connect` shows the cluster name and default namespace that Telepresence connected to, similar to the following example.

    ```
    Connected to context myAKSCluster, namespace default (https://myAKSCluster-dns-ck7w5t5h.hcp.eastus2.azmk8s.io:443)
    ```
2. Use the `telepresence list` command to display a list of the services you can intercept.

    ```console
    telepresence list
    ```

    A successful response displays available services, similar to the following example.

    ```
    order-service  : ready to intercept (traffic-agent not yet installed)
    product-service: ready to intercept (traffic-agent not yet installed)
    rabbitmq       : ready to intercept (traffic-agent not yet installed)
    store-front    : ready to intercept (traffic-agent not yet installed)
    ```
3. Find the name of the port you need to intercept traffic from using `kubectl get service service-name --output yaml`. For this tutorial, enter the following command in the command line.

    ```console
    kubectl get service store-front -ojsonpath='{.spec.ports[0].port}'
    ```

    In this example, the port to intercept, 80, is returned.

    ```
    80
    ```
4. Intercept the traffic from your service in your AKS cluster using the `telepresence intercept` command with the following format: `$ telepresence intercept <service-name> --port <local-port>[:<remote-port>] --env-file <path-to-env-file>`

    - `--port` specifies the local port and the remote port for your AKS cluster.
    - `--env-file` specifies the path where Telepresence creates an env file containing the environment variables needed to intercept traffic. This file must exist to properly intercept your service's traffic to your local machine. If a file doesn't exist, telepresence creates it for you.

    Note

    `sshfs` is required in order for volume mounts to work correctly during intercepts for both Linux and macOS versions of Telepresence. If you don't have it installed, see the [Telepresence documentation](https://www.telepresence.io/docs/troubleshooting#volume-mounts-are-not-working-on-macos) for more information.

    For this tutorial, enter the following command to intercept the traffic.

    ```console
    cd src/store-front
    telepresence intercept store-front --port 8080:80 --env-file .env
    ```

    A successful response displays which connections Telepresence is intercepting, similar to the following example.

    ```
    Using Deployment store-front
    Intercept name         : store-front
    State                  : ACTIVE
    Workload kind          : Deployment
    Destination            : 127.0.0.1:8080
    Service Port Identifier: 80/TCP
    Volume Mount Point     : /tmp/telfs-3392425241
    Intercepting           : all TCP connections
    ```

## Modify your local code and see real-time changes

With Telepresence configured, you can seamlessly modify your local code and see the changes reflected in real time. This allows you to test and debug locally while leveraging your AKS cluster.

1. Navigate and open `components/TopNav.Vue` in the application you cloned previously.
2. Change the `Products` navigation item to `New Products`, as seen in the following example, and save the changes.

    ```console
    <template>
      <nav>
        <div class="logo">
          <router-link to="/">
            <img src="/contoso-pet-store-logo.png" alt="Contoso Pet Store Logo" />
          </router-link>
        </div>
        <button class="hamburger" @click="toggleNav">
          <span class="hamburger-icon"></span>
        </button>
        <ul class="nav-links" :class="{ 'nav-links--open': isNavOpen }">
          <li><router-link to="/" @click="closeNav">Products</router-link></li>
          <li>
            <router-link to="/cart" @click="closeNav">Cart ({{ cartItemCount }})</router-link>
          </li>
        </ul>
      </nav>
    </template>
    ```
3. Run the following commands to run the app locally.

    1. `npm install` - Installs the dependencies.
    2. `npm run serve` - Starts the development server.

When you go to the public IP of the `store-front` service in your AKS cluster, the updated navigation is present and traffic is being routed to your locally running version of the service. Your local changes are reflected in real-time and interact with other services in your AKS cluster.

## Video demo

The following video provides a clear and concise walkthrough of Telepresence's F5 debugging capabilities.