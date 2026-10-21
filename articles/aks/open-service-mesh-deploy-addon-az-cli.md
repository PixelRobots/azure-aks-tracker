---
layout: Conceptual
title: Install the Open Service Mesh (OSM) add-on using Azure CLI - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-deploy-addon-az-cli
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
description: Use Azure CLI to install the Open Service Mesh (OSM) add-on on an Azure Kubernetes Service (AKS) cluster.
ms.topic: how-to
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
ms.date: 2024-09-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 72de4932-954d-7101-3d16-1b3d030b90ce
document_version_independent_id: 3073a793-8ff1-9834-1641-f3aa7bc356b0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-deploy-addon-az-cli.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/open-service-mesh-deploy-addon-az-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-deploy-addon-az-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9f589d87-88de-3910-7452-bc7b14d82050
---

# Install the Open Service Mesh (OSM) add-on using Azure CLI - Azure Kubernetes Service | Microsoft Learn

This article shows you how to install the Open Service Mesh (OSM) add-on on an Azure Kubernetes Service (AKS) cluster. The OSM add-on installs the OSM mesh on your cluster. The OSM mesh is a service mesh that provides traffic management, policy enforcement, and telemetry collection for your applications. For more information about the OSM mesh, see [Open Service Mesh](https://openservicemesh.io/).

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Based on the version of Kubernetes your cluster is running, the OSM add-on installs a different version of OSM.

| Kubernetes version | OSM version installed |
| --- | --- |
| 1.24.0 or greater | 1.2.5 |
| Between 1.23.5 and 1.24.0 | 1.1.3 |
| Below 1.23.5 | 1.0.0 |

Older versions of OSM might not be available for install or be actively supported if the corresponding AKS version reached end of life. Check the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions) for information on AKS version support windows.

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI installed](/en-us/cli/azure/install-azure-cli).

## Install the OSM add-on on your cluster

1. If you don't have one already, create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name myResourceGroup --location eastus
    ```
2. Create a new AKS cluster with the OSM add-on installed using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and specify `open-service-mesh` for the `--enable-addons` parameter.

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --enable-addons open-service-mesh \
        --generate-ssh-keys
    ```

Important

You can't enable the OSM add-on on an existing cluster if an OSM mesh is already on your cluster. Uninstall any existing OSM meshes on your cluster before enabling the OSM add-on.

When installing on an existing clusters, use the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command. The following code shows an example:

```azurecli
az aks enable-addons \
 --resource-group myResourceGroup \
 --name myAKSCluster \
 --addons open-service-mesh
```

## Get the credentials for your cluster

- Get the credentials for your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

## Verify the OSM add-on is installed on your cluster

- Verify the OSM add-on is installed on your cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with and specify `'addonProfiles.openServiceMesh.enabled'` for the `--query` parameter. In the output, under `addonProfiles`, the `enabled` value should show as `true` for `openServiceMesh`.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster  --query 'addonProfiles.openServiceMesh.enabled'
    ```

## Verify the OSM mesh is running on your cluster

1. Verify the version, status, and configuration of the OSM mesh running on your cluster using the `kubectl get deployment` command and display the image version of the *osm-controller* deployment.

    ```azurecli
    kubectl get deployment -n kube-system osm-controller -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
    ```

    The following example output shows version *0.11.1* of the OSM mesh:

    ```output
    mcr.microsoft.com/oss/openservicemesh/osm-controller:v0.11.1
    ```
2. Verify the status of the OSM components running on your cluster using the following `kubectl` commands to show the status of the `app.kubernetes.io/name=openservicemesh.io` deployments, pods, and services.

    ```azurecli
    kubectl get deployments -n kube-system --selector app.kubernetes.io/name=openservicemesh.io
    kubectl get pods -n kube-system --selector app.kubernetes.io/name=openservicemesh.io
    kubectl get services -n kube-system --selector app.kubernetes.io/name=openservicemesh.io
    ```

    Important

    If any pods have a status other than `Running`, such as `Pending`, your cluster might not have enough resources to run OSM. Review the sizing for your cluster, such as the number of nodes and the virtual machine's SKU, before continuing to use OSM on your cluster.
3. Verify the configuration of your OSM mesh using the `kubectl get meshconfig` command.

    ```azurecli
    kubectl get meshconfig osm-mesh-config -n kube-system -o yaml
    ```

    The following example output shows the configuration of an OSM mesh:

    ```yaml
    apiVersion: config.openservicemesh.io/v1alpha1
    kind: MeshConfig
    metadata:
      creationTimestamp: "0000-00-00A00:00:00A"
      generation: 1
      name: osm-mesh-config
      namespace: kube-system
      resourceVersion: "2494"
      uid: 6c4d67f3-c241-4aeb-bf4f-b029b08faa31
    spec:
      certificate:
        serviceCertValidityDuration: 24h
      featureFlags:
        enableEgressPolicy: true
        enableMulticlusterMode: false
        enableWASMStats: true
      observability:
        enableDebugServer: true
        osmLogLevel: info
        tracing:
          address: jaeger.osm-system.svc.cluster.local
          enable: false
          endpoint: /api/v2/spans
          port: 9411
      sidecar:
        configResyncInterval: 0s
        enablePrivilegedInitContainer: false
        envoyImage: mcr.microsoft.com/oss/envoyproxy/envoy:v1.18.3
        initContainerImage: mcr.microsoft.com/oss/openservicemesh/init:v0.9.1
        logLevel: error
        maxDataPlaneConnections: 0
        resources: {}
      traffic:
        enableEgress: true
        enablePermissiveTrafficPolicyMode: true
        inboundExternalAuthorization:
          enable: false
          failureModeAllow: false
          statPrefix: inboundExtAuthz
          timeout: 1s
        useHTTPSIngress: false
    ```

    The example output shows `enablePermissiveTrafficPolicyMode: true`, which means OSM has permissive traffic policy mode enabled. With this mode enabled in your OSM mesh:

    - The [SMI](https://smi-spec.io/) traffic policy enforcement is bypassed.
    - OSM automatically discovers services that are a part of the service mesh.
    - OSM creates traffic policy rules on each Envoy proxy sidecar to be able to communicate with these services.

## Delete your cluster

- When you no longer need the cluster, you can delete it using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command, which removes the resource group, the cluster, and all related resources.

    ```azurecli
    az group delete --name myResourceGroup --yes --no-wait
    ```

Note

Alternatively, you can uninstall the OSM add-on and the related resources from your cluster. For more information, see [Uninstall the Open Service Mesh add-on from your AKS cluster](open-service-mesh-uninstall-add-on).