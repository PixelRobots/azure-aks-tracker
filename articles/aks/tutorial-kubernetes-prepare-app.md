---
layout: Conceptual
title: Kubernetes on Azure tutorial - Prepare an Application for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
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
description: In this Azure Kubernetes Service (AKS) tutorial, you learn how to prepare and build a multi-container app with Docker Compose that you can then deploy to AKS.
ms.topic: tutorial
ms.date: 2026-07-16T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: mvc, devx-track-extended-azdevcli, aks-getting-started
locale: en-us
document_id: e7a5b53c-69b0-bf87-e491-d38f2ee1585a
document_version_independent_id: 0ec153ec-bac0-a58e-913d-f7eb62e5ba7f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-prepare-app.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-prepare-app
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-prepare-app.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: db5e08df-9195-fa1c-17c8-ef2f8f93d974
---

# Kubernetes on Azure tutorial - Prepare an Application for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Tip

Short answer: Use [Kompose](https://kompose.io/) for quick scaffolding, [Move2Kube](https://move2kube.konveyor.io/) for broader modernization, [Docker Compose Bridge](https://docs.docker.com/compose/bridge/) if you use Docker Desktop, and [Podman](https://docs.podman.io/en/latest/markdown/podman-kube-generate.1.html) to export from running containers or pods. Then package the results with [Helm](https://helm.sh/docs/intro/using_helm/) or [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/) and iterate with [Skaffold](https://skaffold.dev/docs/quickstart/) or [Tilt](https://docs.tilt.dev/).

Top tools: Kompose, Move2Kube, Docker Compose Bridge, Podman, Helm, Kustomize, Skaffold, Tilt, and AI-assisted conversion.

In this tutorial, you prepare a multi-container application to use in Kubernetes. You can use this tutorial whether you're starting with a new sample app or adapting Docker Compose concepts for an app you plan to migrate to Azure Kubernetes Service (AKS). You use existing development tools like Docker Compose to locally build and test the application. You learn how to:

- Clone a sample application source from GitHub.
- Create a container image from the sample application source.
- Test the multi-container application in a local Docker environment.

Important

Starting fresh? Use this tutorial to prepare and test a sample app for AKS. Already using Docker Compose? See the Kubernetes documentation for [migrating Docker Compose to Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/) and the AKS [migration overview](aks-migration) for broader planning guidance.

Once completed, the following application runs in your local development environment:

[![Screenshot showing the Azure Store Front App running locally opened in a local web browser.](media/container-service-kubernetes-tutorials/aks-store-application.png)](media/container-service-kubernetes-tutorials/aks-store-application.png#lightbox)

In later tutorials, you upload the container image to an Azure Container Registry (ACR), and then deploy it into an AKS cluster.

## Before you begin

This tutorial assumes a basic understanding of core Docker concepts such as containers, container images, and `docker` commands. For a primer on container basics, see [Get started with Docker](https://docs.docker.com/get-started/).

To complete this tutorial, you need a local Docker development environment running Linux containers. Docker provides packages that configure Docker on a [Mac](https://docs.docker.com/desktop/install/mac-install/), [Windows](https://docs.docker.com/desktop/install/windows-install/), or [Linux](https://docs.docker.com/desktop/install/linux-install/) system.

Note

Azure Cloud Shell doesn't include the Docker components required to complete every step in these tutorials. Therefore, we recommend using a full Docker development environment.

## Get application code

The [sample application](https://github.com/Azure-Samples/aks-store-demo) used in this tutorial is a basic store front app including the following Kubernetes deployments and services:

[![Screenshot of Azure Store sample architecture.](media/container-service-kubernetes-tutorials/aks-store-architecture.png)](media/container-service-kubernetes-tutorials/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **RabbitMQ**: Message queue for an order queue.

# [Git](#tab/azure-cli)
1. Create a directory on your computer and switch to that directory in your terminal session, like Bash. This example uses a directory named *demorepo* but you can use any name you want.

    ```console
    mkdir demorepo
    cd demorepo
    ```
2. Use [git](https://git-scm.com/downloads) to clone the sample application to your development environment.

    ```console
    git clone https://github.com/Azure-Samples/aks-store-demo.git
    ```
3. Change into the cloned directory.

    ```console
    cd aks-store-demo
    ```

# [Azure Developer CLI](#tab/azure-azd)
1. If you're using [Azure Developer CLI](/en-us/azure/developer/azure-developer-cli/install-azd) locally, create an empty directory named `aks-store-demo` to host the azd template files.

    ```console
    mkdir aks-store-demo
    ```
2. Change into the new directory to load all the files from the azd template.

    ```console
    cd aks-store-demo
    ```
3. Clone the sample application into the `aks-store-demo` directory using the [`azd init`](/en-us/azure/developer/azure-developer-cli/reference#azd-init) command with the `--template` flag set to `aks-store-demo`.

    ```azdeveloper
    azd init --template aks-store-demo
    ```

---

## Review Docker Compose file

The sample application you create in this tutorial uses the [*docker-compose-quickstart* YAML file](https://github.com/Azure-Samples/aks-store-demo/blob/main/docker-compose-quickstart.yml) from the [repository](https://github.com/Azure-Samples/aks-store-demo/tree/main) you cloned.

The following table summarizes key defaults from the sample Compose file so you can quickly see which services, ports, and dependencies the tutorial uses:

| Service | Source | Exposed port | Key settings |
| --- | --- | --- | --- |
| RabbitMQ | `rabbitmq:4.3.2-management-alpine` image | `15672`, `5672` | Default username `username`, password `password` |
| Order service | `src/order-service` | `3000` | Connects to RabbitMQ on port `5672` and uses queue `orders` |
| Product service | `src/product-service` | `3002` | Uses `AI_SERVICE_URL=http://ai-service:5001/` |
| Store front | `src/store-front` | `8080` | Calls the product service on `3002` and order service on `3000` |

```YAML
services:
  rabbitmq:
    image: rabbitmq:4.3.2-management-alpine
    container_name: 'rabbitmq'
    restart: always
    environment:
      - "RABBITMQ_DEFAULT_USER=username"
      - "RABBITMQ_DEFAULT_PASS=password"
    ports:
      - 15672:15672
      - 5672:5672
    healthcheck:
      test: ["CMD", "rabbitmqctl", "status"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - backend_services
  order-service:
    build: src/order-service
    container_name: 'order-service'
    restart: always
    ports:
      - 3000:3000
    healthcheck:
      test: ["CMD", "wget", "-O", "/dev/null", "-q", "http://order-service:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    environment:
      - ORDER_QUEUE_HOSTNAME=rabbitmq
      - ORDER_QUEUE_PORT=5672
      - ORDER_QUEUE_USERNAME=username
      - ORDER_QUEUE_PASSWORD=password
      - ORDER_QUEUE_NAME=orders
    networks:
      - backend_services
    depends_on:
      rabbitmq:
        condition: service_healthy
  product-service:
    build: src/product-service
    container_name: 'product-service'
    restart: always
    ports:
      - 3002:3002
    healthcheck:
      test: ["CMD", "wget", "-O", "/dev/null", "-q", "http://product-service:3002/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    environment:
      - AI_SERVICE_URL=http://ai-service:5001/
    networks:
      - backend_services
  store-front:
    build: src/store-front
    container_name: 'store-front'
    restart: always
    ports:
      - 8080:8080
    healthcheck:
      test: ["CMD", "wget", "-O", "/dev/null", "-q", "http://store-front:80/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    environment:
      - VUE_APP_PRODUCT_SERVICE_URL=http://product-service:3002/
      - VUE_APP_ORDER_SERVICE_URL=http://order-service:3000/
    networks:
      - backend_services
    depends_on:
      - product-service
      - order-service
networks:
  backend_services:
    driver: bridge
```

## Create container images and run application

You can use [Docker Compose](https://docs.docker.com/compose/) to automate building container images and the deployment of multi-container applications.

Make sure Docker is running in Linux container mode before you run the following commands.

1. From the root of the cloned `aks-store-demo` repository, create the container image, download the RabbitMQ image, and start the application using the `docker compose` command:

    ```console
    docker compose -f docker-compose-quickstart.yml up -d
    ```
2. View the created images using the [`docker images`](https://docs.docker.com/engine/reference/commandline/images/) command.

    ```console
    docker images
    ```

    The following condensed example output shows the created images:

    ```output
    REPOSITORY                        TAG                          IMAGE ID
    aks-store-demo-product-service    latest                       72f5cd7e6b84
    aks-store-demo-order-service      latest                       54ad5de546f9
    aks-store-demo-store-front        latest                       1125f85632ae
    ...
    ```
3. View the running containers using the [`docker ps`](https://docs.docker.com/engine/reference/commandline/ps/) command.

    ```console
    docker ps
    ```

    The following condensed example output shows four running containers:

    ```output
    CONTAINER ID        IMAGE
    f27fe74cfd0a        aks-store-demo-product-service
    df1eaa137885        aks-store-demo-order-service
    b3ce9e496e96        aks-store-demo-store-front
    31df28627ffa        rabbitmq:4.3.2-management-alpine
    ```

## Test application locally

To see your running application, navigate to `http://localhost:8080` in a local web browser. The sample application loads, as shown in the following example:

[![Screenshot showing the Azure Store Front App opened in a local browser.](media/container-service-kubernetes-tutorials/aks-store-application.png)](media/container-service-kubernetes-tutorials/aks-store-application.png#lightbox)

On this page, you can view products, add them to your cart, and then place an order.

## Migrate your own Compose files

If you already have an application defined in a Docker Compose file, you can use this tutorial as a reference for local validation, then convert your existing Compose configuration into Kubernetes manifests. Use tools such as [Kompose](https://kompose.io/), [Move2Kube](https://move2kube.konveyor.io/), [Docker Compose Bridge](https://docs.docker.com/compose/bridge/), or [Podman](https://docs.podman.io/en/latest/markdown/podman-kube-generate.1.html) to convert Docker Compose definitions into Kubernetes resources. For the full end-to-end conversion path, see the Kubernetes documentation for [migrating Docker Compose to Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/) and the AKS [migration overview](aks-migration) if you're also moving from another orchestrator or modernization workflow.

## Choose a conversion tool

Use this table when you need a fast comparison of the most common Compose-to-Kubernetes options.

| Tool | One-line summary |
| --- | --- |
| [Kompose](https://kompose.io/) | Fast Compose-to-Kubernetes scaffold; run `kompose convert`; expect manual cleanup for storage and probes. |
| [Move2Kube](https://move2kube.konveyor.io/) | Broader modernization workflow; run `move2kube plan -s ./path && move2kube transform`; heavier than one-file converters. |
| [Docker Compose Bridge](https://docs.docker.com/compose/bridge/) | Docker Desktop-oriented conversion path; run `docker compose bridge convert -o ./k8s/`; see Docker docs for current support details. |
| [Podman](https://docs.podman.io/en/latest/markdown/podman-kube-generate.1.html) | Export YAML from running containers or pods; run `podman kube generate mypod > k8s.yaml`; best for Podman-based workflows. |
| [Helm](https://helm.sh/docs/intro/using_helm/) | Template and package manifests for repeated deployments; run `helm create mychart`; best after conversion. |
| [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/) | Overlay environment-specific changes; run `kubectl apply -k .`; best after conversion. |
| [Skaffold](https://skaffold.dev/docs/quickstart/) | Build a Kubernetes inner dev loop; run `skaffold init`; not a direct converter. |
| [Tilt](https://docs.tilt.dev/) | Live-update local Kubernetes development; run `tilt up`; requires a Kubernetes-focused workflow. |
| AI-assisted conversion | Draft or compare manifests with AI, then validate the output before deployment. |

### Which tool should I pick?

- If you want a quick proof of concept or starter manifests, use [Kompose](https://kompose.io/).
- If you use Docker Desktop and want a Docker-native path, use [Docker Compose Bridge](https://docs.docker.com/compose/bridge/).
- If you have a larger multi-service migration or modernization effort, use [Move2Kube](https://move2kube.konveyor.io/).
- If you want to export from running containers or pods, use [Podman](https://docs.podman.io/en/latest/markdown/podman-kube-generate.1.html).
- If you already have manifests and need packaging or overlays, use [Helm](https://helm.sh/docs/intro/using_helm/) or [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/).
- If you need a local Kubernetes dev loop after conversion, use [Skaffold](https://skaffold.dev/docs/quickstart/) or [Tilt](https://docs.tilt.dev/).
- If you want draft manifests or migration explanations, use AI assistance and validate the result against official Kubernetes and AKS guidance.

Other tools to consider:

- [8gwifi.org Kubernetes YAML Converter](https://8gwifi.org/kube.jsp): Useful for quick online experiments with small Compose files.
- [Okteto](https://www.okteto.com/): Useful when you want a cloud or remote Kubernetes development loop for application teams.
- [Devtron](https://devtron.ai/): Useful when you want a platform workflow around Kubernetes delivery after conversion.
- [Portainer](https://www.portainer.io/): Useful when you want a UI-driven container and Kubernetes management experience.

## Convert your Compose files

Use the following copyable commands as a starting point:

```text
kompose convert
move2kube plan -s ./path && move2kube transform
docker compose bridge convert -o ./k8s/
podman kube generate mypod > k8s.yaml
skaffold init
```

### Kompose conversion example

The open-source [Kompose](https://kompose.io/) tool converts common Docker Compose settings into Kubernetes objects such as Deployments and Services.

1. On Windows, install Kompose with the following command:

    ```console
    curl -L https://github.com/kubernetes/kompose/releases/latest/download/kompose-windows-amd64.exe -o kompose.exe
    ```

    For other installation options, see the [Kompose installation instructions](https://kompose.io/installation/).
2. Run Kompose from the directory that contains your `docker-compose.yml` file.

    ```console
    kompose convert
    ```
3. Review the generated Kubernetes YAML files before you deploy them to AKS.

### AI-assisted conversion

You can use an AI assistant to draft Kubernetes manifests, compare Compose settings to Kubernetes equivalents, or explain why a conversion needs manual changes.

Generic example prompt:

```text
Convert this docker-compose.yml into production-ready Kubernetes manifests. Use Apps/v1, move secrets to Kubernetes Secret objects, map local volumes to PersistentVolumeClaims, and add readiness and liveness probes for the web service.
```

AKS-targeted example prompt:

```text
Convert this docker-compose.yml into AKS-ready Kubernetes manifests. Target an AKS cluster, push images to Azure Container Registry, use Apps/v1 objects, move secrets to Kubernetes Secret objects, map local volumes to Azure Files or Azure Disks-backed PersistentVolumeClaims, and add readiness and liveness probes for the web service.
```

Always review AI output before you apply it. Validate `apiVersion` values, resource requests and limits, storage classes, service exposure, and health probes.

## Handle common translation issues

### How are volumes handled?

Compose `volumes` often need Kubernetes persistent volumes and a storage class. In AKS, replace local-only mounts with services such as [Azure Disks](azure-disks-dynamic-pv) or [Azure Files](azure-files-dynamic-pv).

### What replaces `depends_on`?

Compose `depends_on` doesn't enforce runtime readiness in Kubernetes. Replace it with readiness probes, startup probes, or init container logic when needed.

### How should I handle secrets and environment values?

Compose environment values often become Kubernetes `ConfigMap` or `Secret` resources, or Azure Key Vault integrations.

### What happens to ports and ingress?

Compose `ports` map to Kubernetes `Service` objects and sometimes ingress or Gateway API resources, depending on how you publish the application.

### How do health checks translate?

Compose `healthcheck` settings usually become Kubernetes liveness and readiness probes.

### What happens to Compose networks?

Compose networks usually translate to Kubernetes service discovery through Services and cluster DNS instead of custom bridge networks.

### How do I test locally with Kubernetes?

After conversion, deploy the generated manifests to a local Kubernetes environment such as kind or minikube, then use [Skaffold](https://skaffold.dev/docs/quickstart/) or [Tilt](https://docs.tilt.dev/) if you want a faster edit-build-deploy loop.

## Apply AKS-specific adjustments after conversion

Kompose gives you a starting point, but you typically need to make manual changes for AKS:

- Update image references to point to your Azure Container Registry (ACR).
- Replace local-only storage and bind mounts with persistent storage such as [Azure Disks](azure-disks-dynamic-pv) or [Azure Files](azure-files-dynamic-pv), depending on your workload needs.
- Replace Compose secrets or environment-specific values with Kubernetes Secrets, ConfigMaps, or Azure Key Vault integrations.
- Review networking and exposure settings, such as `LoadBalancer`, ingress, or gateway configuration, based on how you want to publish the app in AKS.
- Check whether stateful components should stay as Deployments or move to patterns such as StatefulSets when you need stable identity or storage behavior.
- Validate resource requests, probes, and any startup ordering assumptions because Compose behaviors such as `depends_on` don't translate directly into Kubernetes runtime behavior.

## Post-conversion workflow

1. Convert the Compose file with a tool such as Kompose, Move2Kube, Docker Compose Bridge, Podman, or an AI-reviewed draft.
2. Review and harden the manifests by fixing storage, secrets, service exposure, probes, and image references.
3. Package the manifests with Helm or layer environment-specific changes with Kustomize.
4. Push your images to a registry such as ACR, then deploy with GitOps, CI/CD, or direct `kubectl` workflows.

Example sequence: `kompose convert` -&gt; review manifests -&gt; push images to ACR -&gt; update image references -&gt; `kubectl apply` or `helm install`.

## Clean up resources

If you followed the Docker Compose workflow, you can stop and remove the running containers. **Don't delete the container images** because you use them in the next tutorial. If you followed the Azure Developer CLI workflow, use `azd down` instead of `docker compose down`.

Stop and remove the container instances and resources using the [`docker compose down`](https://docs.docker.com/compose/reference/down) command.

```console
docker compose down
```

## Azure Developer CLI commands

When you use `azd`, there are no manual container image dependencies. `azd` handles the provisioning, deployment, and clean up of your applications and clusters with the `azd up` and `azd down` commands, similar to Docker.

You can customize the preparation steps to use either Terraform or Bicep before deploying the cluster within the `infra` section of your `azure.yaml`. By default, this project uses Terraform:

```yml
infra:
  provider: terraform
  path: infra/terraform
```

If you want to change the provider to Bicep, update the `azure.yaml` file as follows:

```yml
infra:
  provider: bicep
  path: infra/bicep
```