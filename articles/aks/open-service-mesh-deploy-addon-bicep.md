---
layout: Conceptual
title: Deploy the Open Service Mesh add-on using Bicep in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-deploy-addon-bicep
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
description: Use a Bicep template to deploy the Open Service Mesh (OSM) add-on to Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.subservice: aks-networking
ms.custom: devx-track-bicep
ms.date: 2024-09-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 22c4a3d1-5cdd-601c-dc68-c9483f39cac8
document_version_independent_id: 7b91b66a-1493-705d-9267-43c22c82054f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-deploy-addon-bicep.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/open-service-mesh-deploy-addon-bicep
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-deploy-addon-bicep.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 32baf49e-8fd1-3d6f-aaa1-b075634e9628
---

# Deploy the Open Service Mesh add-on using Bicep in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to deploy the Open Service Mesh (OSM) add-on to Azure Kubernetes Service (AKS) using a [Bicep](/en-us/azure/azure-resource-manager/bicep/) template.

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

Older versions of OSM might not be available for install or actively supported if the corresponding AKS version reached end of life. Check the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions) for information on AKS version support windows.

[Bicep](/en-us/azure/azure-resource-manager/bicep/overview) is a domain-specific language that uses declarative syntax to deploy Azure resources. You can use Bicep in place of creating [Azure Resource Manager templates](/en-us/azure/azure-resource-manager/templates/overview) to deploy your infrastructure-as-code Azure resources.

## Before you begin

Before you begin, make sure you have the following prerequisites in place:

- The Azure CLI version 2.20.0 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- An SSH public key used for deploying AKS. For more information, see [Create SSH keys using the Azure CLI](/en-us/azure/virtual-machines/ssh-keys-azure-cli).
- [Visual Studio Code](https://code.visualstudio.com/) with a Bash terminal.
- The Visual Studio Code [Bicep extension](/en-us/azure/azure-resource-manager/bicep/install).

## Install the OSM add-on for a new AKS cluster by using Bicep

For deployment of a new AKS cluster, you enable the OSM add-on at cluster creation. The following instructions use a generic Bicep template that deploys an AKS cluster by using ephemeral disks and the [`kubenet`](configure-kubenet) container network interface, and then enables the OSM add-on. For more advanced deployment scenarios, see [What is Bicep?](/en-us/azure/azure-resource-manager/bicep/overview)

### Create a resource group

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name <my-osm-bicep-aks-cluster-rg> --location <azure-region>
    ```

### Create the main and parameters Bicep files

1. Create a directory to store the necessary Bicep deployment files. The following example creates a directory named *bicep-osm-aks-addon* and changes to the directory:

    ```azurecli
    mkdir bicep-osm-aks-addon
    cd bicep-osm-aks-addon
    ```
2. Create the main file and the parameters file.

    ```azurecli
    touch osm.aks.bicep && touch osm.aks.parameters.json
    ```
3. Open the *osm.aks.bicep* file and copy in the following content:

    ```bicep
    // https://learn.microsoft.com/azure/aks/troubleshooting#what-naming-restrictions-are-enforced-for-aks-resources-and-parameters
    @minLength(3)
    @maxLength(63)
    @description('Provide a name for the AKS cluster. The only allowed characters are letters, numbers, dashes, and underscore. The first and last character must be a letter or a number.')
    param clusterName string
    @minLength(3)
    @maxLength(54)
    @description('Provide a name for the AKS dnsPrefix. Valid characters include alphanumeric values and hyphens (-). The dnsPrefix can\'t include special characters such as a period (.)')
    param clusterDNSPrefix string
    param k8Version string
    param sshPubKey string
    param location string
    param adminUsername string

    resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
      name: clusterName
      location: location
      identity: {
        type: 'SystemAssigned'
      }
      properties: {
        kubernetesVersion: k8Version
        dnsPrefix: clusterDNSPrefix
        enableRBAC: true
        agentPoolProfiles: [
          {
            name: 'agentpool'
            count: 3
            vmSize: 'Standard_DS2_v2'
            osDiskSizeGB: 30
            osDiskType: 'Ephemeral'
            osType: 'Linux'
            mode: 'System'
          }
        ]
        linuxProfile: {
          adminUsername: adminUserName
          ssh: {
            publicKeys: [
              {
                keyData: sshPubKey
              }
            ]
          }
        }
        addonProfiles: {
            openServiceMesh: {
                enabled: true
                config: {}
          }
        }
      }
    }
    ```
4. Open the *osm.aks.parameters.json* file and copy in the following content. Make sure you replace the deployment parameter values with your own values.

    Note

    The *osm.aks.parameters.json* file is an example template parameters file needed for the Bicep deployment. Update the parameters specifically for your deployment environment. The parameters you need to add values for include: `clusterName`, `clusterDNSPrefix`, `k8Version`, `sshPubKey`, `location`, and `adminUsername`. To find a list of supported Kubernetes versions in your region, use the `az aks get-versions --location <region>` command.

    ```json
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "clusterName": {
          "value": "<YOUR CLUSTER NAME HERE>"
        },
        "clusterDNSPrefix": {
          "value": "<YOUR CLUSTER DNS PREFIX HERE>"
        },
        "k8Version": {
          "value": "<YOUR SUPPORTED KUBERNETES VERSION HERE>"
        },
        "sshPubKey": {
          "value": "<YOUR SSH KEY HERE>"
        },
        "location": {
          "value": "<YOUR AZURE REGION HERE>"
        },
        "adminUsername": {
          "value": "<YOUR ADMIN USERNAME HERE>"
        }
      }
    }
    ```

### Deploy the Bicep files

1. Open a terminal and authenticate to your Azure account for the Azure CLI using the `az login` command.
2. Deploy the Bicep files using the [`az deployment group create`](/en-us/cli/azure/deployment/group#az-deployment-group-create) command.

    ```azurecli
    az deployment group create \
      --name OSMBicepDeployment \
      --resource-group osm-bicep-test \
      --template-file osm.aks.bicep \
      --parameters @osm.aks.parameters.json
    ```

## Validate installation of the OSM add-on

1. Query the add-on profiles of the cluster to check the enabled state of the installed add-ons. The following command should return `true`:

    ```azurecli
    az aks list -g <my-osm-aks-cluster-rg> -o json | jq -r '.[].addonProfiles.openServiceMesh.enabled'
    ```
2. Get the status of the *osm-controller* using the following `kubectl` commands.

    ```azurecli
    kubectl get deployments -n kube-system --selector app=osm-controller
    kubectl get pods -n kube-system --selector app=osm-controller
    kubectl get services -n kube-system --selector app=osm-controller
    ```

## Access the OSM add-on configuration

You can configure the OSM controller using the OSM MeshConfig resource, and you can view the OSM controller's configuration settings using the Azure CLI.

- View the OSM controller's configuration settings using the `kubectl get` command.

    ```azurecli
    kubectl get meshconfig osm-mesh-config -n kube-system -o yaml
    ```

    Here's an example output of MeshConfig:

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

    Notice that `enablePermissiveTrafficPolicyMode` is configured to `true`. In OSM, permissive traffic policy mode bypasses [SMI](https://smi-spec.io/) traffic policy enforcement. In this mode, OSM automatically discovers services that are a part of the service mesh. The discovered services will have traffic policy rules programmed on each Envoy proxy sidecar to allow communications between these services.

    Warning

    Before you proceed, verify that your permissive traffic policy mode is set to `true`. If it isn't, change it to `true` using the following command:

    ```OSM
    kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"enablePermissiveTrafficPolicyMode":true}}}' --type=merge
    ```

## Clean up resources

- When you no longer need the Azure resources, delete the deployment's test resource group using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

    ```azurecli
    az group delete --name osm-bicep-test
    ```

    Alternatively, you can uninstall the OSM add-on and the related resources from your cluster. For more information, see [Uninstall the Open Service Mesh add-on from your AKS cluster](open-service-mesh-uninstall-add-on).