---
layout: Conceptual
title: Configure dual-stack networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-dual-stack
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
description: Configure dual-stack networking in Azure Kubernetes Service (AKS) to enable both IPv4 and IPv6 support for your applications.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-09-10T00:00:00.0000000Z
ms.custom: devx-track-azurecli, build-2023
ai-usage: ai-assisted
locale: en-us
document_id: b3806186-51da-095d-8290-820b3667c196
document_version_independent_id: aae15ac1-5af8-7a6f-be74-16035fe4f4ae
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-dual-stack.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-dual-stack
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-dual-stack.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: c0893a13-f03b-432e-0dac-4f47f41bc9a2
---

# Configure dual-stack networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

You can deploy your AKS clusters in a dual-stack mode when using a dual-stack Azure virtual network. In this configuration, nodes receive both an IPv4 and IPv6 address from the Azure virtual network subnet. Pods receive both an IPv4 and IPv6 address from a logically different address space to the Azure virtual network subnet of the nodes. Network address translation (NAT) is then configured so that the pods can reach resources on the Azure virtual network. The source IP address of the traffic is NAT'd to the node's primary IP address of the same family (IPv4 to IPv4 and IPv6 to IPv6).

This article shows you how to use dual-stack networking with an AKS cluster. For more information on network options and considerations, see [Network concepts for Kubernetes and AKS](concepts-network).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Limitations

- In Azure Linux node pools, IPv6 services require `externalTrafficPolicy: Local`.
- Dual-stack networking is required for the Azure virtual network and the pod CIDR.
    - Single stack IPv6-only isn't supported for node or pod IP addresses. Services can be provisioned on IPv4 or IPv6.
- Azure CNI Overlay doesn't support Azure or Calico network policies with dual-stack networking. To use network policies, use Azure CNI Powered by Cilium.
- Standard NAT Gateway supports only IPv4. For dual-stack egress, use StandardV2 NAT Gateway. The AKS-managed `managedNATGatewayV2` outbound type is in preview.
- The virtual nodes add-on isn't supported with dual-stack networking.

## Prerequisites

- Azure CLI version 2.48.1 or later. Run [`az --version`](/en-us/cli/azure/reference-index#az-version) to find your installed version. To install or upgrade the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Use a [supported Kubernetes version in AKS](supported-kubernetes-versions) that's available in your region.

This article uses Azure CNI Overlay. You can also deploy a dual-stack cluster with [Azure CNI Powered by Cilium](azure-cni-powered-by-cilium#dual-stack-networking-with-azure-cni-powered-by-cilium) on Linux clusters running Kubernetes version 1.29 or later.

## Overview of dual-stack networking in Kubernetes

Kubernetes v1.23 brings stable upstream support for [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/) clusters, including pod and service networking. Nodes and pods are always assigned both an IPv4 and an IPv6 address, while services can be dual-stack or single-stack on either address family.

AKS configures the required supporting services for dual-stack networking. This configuration includes:

- If you use a managed virtual network, a dual-stack virtual network configuration.
- IPv4 and IPv6 node and pod addresses.
- Outbound rules for both IPv4 and IPv6 traffic.
- Load balancer setup for IPv4 and IPv6 services.

Note

When you use dual-stack networking with an [outbound type](egress-outboundtype) of user-defined routing, you can choose to have a default route for IPv6 depending on whether you need your IPv6 traffic to reach the internet. If you don't have a default route for IPv6, a warning appears when you create a cluster but doesn't prevent cluster creation.

## Dual-stack cluster parameters

The following parameters support dual-stack clusters:

| Parameter | Accepted values | Default value | Constraints |
| --- | --- | --- | --- |
| `--ip-families` | `ipv4` or `ipv4,ipv6` | Not specified | Provide a comma-separated list of IP families to enable on the cluster. |
| `--pod-cidrs` | Comma-separated CIDR ranges | `10.244.0.0/16,fd12:3456:789a::/64` | The count and order of ranges must match `--ip-families`. |
| `--service-cidrs` | Comma-separated CIDR ranges | `10.0.0.0/16,fd12:3456:789a:1::/108` | The count and order of ranges must match `--ip-families`. The IPv6 subnet can be no larger than `/108`. |

## Deploy a dual-stack AKS cluster

# [Azure CLI](#tab/azure-cli)
1. Create an Azure resource group for the cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --location <region> --name <resourceGroupName>
    ```
2. Create a dual-stack AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--ip-families` parameter set to `ipv4,ipv6`.

    ```azurecli
    az aks create \
        --location <region> \
        --resource-group <resourceGroupName> \
        --name <clusterName> \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --ip-families ipv4,ipv6 \
        --generate-ssh-keys
    ```
3. After you create the cluster, get the cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group <resourceGroupName> --name <clusterName>
    ```

# [Azure Resource Manager](#tab/azure-resource-manager)
1. Create the ARM template and set the `ipFamilies` property of the `networkProfile` object to `["IPv4", "IPv6"]`.

    ```json
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "clusterName": {
          "type": "string",
          "defaultValue": "aksdualstack"
        },
        "location": {
          "type": "string",
          "defaultValue": "[resourceGroup().location]"
        },
        "nodeCount": {
          "type": "int",
          "defaultValue": 3
        },
        "nodeSize": {
          "type": "string",
          "defaultValue": "Standard_B2ms"
        }
      },
      "resources": [
        {
          "type": "Microsoft.ContainerService/managedClusters",
          "apiVersion": "2026-03-01",
          "name": "[parameters('clusterName')]",
          "location": "[parameters('location')]",
          "identity": {
            "type": "SystemAssigned"
          },
          "properties": {
            "agentPoolProfiles": [
              {
                "name": "nodepool1",
                "count": "[parameters('nodeCount')]",
                "mode": "System",
                "vmSize": "[parameters('nodeSize')]"
              }
            ],
            "dnsPrefix": "[parameters('clusterName')]",
            "networkProfile": {
              "networkPlugin": "azure",
              "networkPluginMode": "overlay",
              "ipFamilies": [
                "IPv4",
                "IPv6"
              ]
            }
          }
        }
      ]
    }
    ```
2. After you create the cluster, get the cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group <resourceGroupName> --name <clusterName>
    ```

Note

For more information on deploying Azure Resource Manager templates, see the [Azure Resource Manager documentation](/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-the-portal).

# [Bicep](#tab/bicep)
1. Create the Bicep template and set the `ipFamilies` property of the `networkProfile` object to `["IPv4", "IPv6"]`.

    ```bicep
    param clusterName string = 'aksdualstack'
    param location string = resourceGroup().location
    param nodeCount int = 3
    param nodeSize string = 'Standard_B2ms'
    
    resource aksCluster 'Microsoft.ContainerService/managedClusters@2026-03-01' = {
      name: clusterName
      location: location
      identity: {
        type: 'SystemAssigned'
      }
      properties: {
        agentPoolProfiles: [
          {
            name: 'nodepool1'
            count: nodeCount
            mode: 'System'
            vmSize: nodeSize
          }
        ]
        dnsPrefix: clusterName
        networkProfile: {
          networkPlugin: 'azure'
          networkPluginMode: 'overlay'
          ipFamilies: [
            'IPv4'
            'IPv6'
          ]
        }
      }
    }
    ```
2. After you create the cluster, get the cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group <resourceGroupName> --name <clusterName>
    ```

Note

For more information on deploying Bicep templates, see the [Bicep template documentation](/en-us/azure/azure-resource-manager/bicep/deploy-cli).

---

## Inspect the nodes to see both IP families

After the cluster is provisioned, confirm the nodes are provisioned with dual-stack networking by using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command.

```bash
kubectl get nodes -o=custom-columns="NAME:.metadata.name,ADDRESSES:.status.addresses[?(@.type=='InternalIP')].address,PODCIDRS:.spec.podCIDRs[*]"
```

The output from the `kubectl get nodes` command shows the nodes have addresses and pod IP assignment space from both IPv4 and IPv6.

```output
NAME                                ADDRESSES                           PODCIDRS
aks-nodepool1-14508455-vmss000000   10.240.0.4,2001:1234:5678:9abc::4   10.244.0.0/24,fd12:3456:789a::/80
aks-nodepool1-14508455-vmss000001   10.240.0.5,2001:1234:5678:9abc::5   10.244.1.0/24,fd12:3456:789a:0:1::/80
aks-nodepool1-14508455-vmss000002   10.240.0.6,2001:1234:5678:9abc::6   10.244.2.0/24,fd12:3456:789a:0:2::/80
```

## Create an example workload

Deploy an NGINX web server with three replicas to verify dual-stack pod IP assignment.

### Deploy an NGINX web server

# [kubectl](#tab/kubectl)
1. Create an NGINX web server by running the [`kubectl create deployment nginx`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_deployment/) command.

    ```bash
    kubectl create deployment nginx --image=nginx:latest --replicas=3
    ```
2. View the pod resources by running the `kubectl get pods` command.

    ```bash
    kubectl get pods -o custom-columns="NAME:.metadata.name,IPs:.status.podIPs[*].ip,NODE:.spec.nodeName,READY:.status.conditions[?(@.type=='Ready')].status"
    ```

    The output shows the pods have both IPv4 and IPv6 addresses. The pods don't show IP addresses until they're ready.

    ```output
    NAME                     IPs                                NODE                                READY
    nginx-55649fd747-9cr7h   10.244.2.2,fd12:3456:789a:0:2::2   aks-nodepool1-14508455-vmss000002   True
    nginx-55649fd747-p5lr9   10.244.0.7,fd12:3456:789a::7       aks-nodepool1-14508455-vmss000000   True
    nginx-55649fd747-r2rqh   10.244.1.2,fd12:3456:789a:0:1::2   aks-nodepool1-14508455-vmss000001   True
    ```

# [YAML](#tab/yaml)
1. Create an NGINX web server using the following YAML manifest.

    ```yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: nginx
      name: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - image: nginx:latest
            name: nginx
    ```
2. View the pod resources by running the `kubectl get pods` command.

    ```bash
    kubectl get pods -o custom-columns="NAME:.metadata.name,IPs:.status.podIPs[*].ip,NODE:.spec.nodeName,READY:.status.conditions[?(@.type=='Ready')].status"
    ```

    The output shows the pods have both IPv4 and IPv6 addresses. The pods don't show IP addresses until they're ready.

    ```output
    NAME                     IPs                                NODE                                READY
    nginx-55649fd747-9cr7h   10.244.2.2,fd12:3456:789a:0:2::2   aks-nodepool1-14508455-vmss000002   True
    nginx-55649fd747-p5lr9   10.244.0.7,fd12:3456:789a::7       aks-nodepool1-14508455-vmss000000   True
    nginx-55649fd747-r2rqh   10.244.1.2,fd12:3456:789a:0:1::2   aks-nodepool1-14508455-vmss000001   True
    ```

---

## Expose the workload via a `LoadBalancer` type service

Important

Azure Load Balancer sends health probes to IPv6 destinations from a link-local address. On Azure Linux node pools, traffic to IPv6 services that use `externalTrafficPolicy: Cluster` fails. The following examples set `externalTrafficPolicy: Local` on the IPv6 service so that `kube-proxy` responds to the probe on the node.

# [kubectl](#tab/kubectl)
1. Expose the NGINX deployment with separate IPv4 and IPv6 `LoadBalancer` services by using the [`kubectl expose deployment nginx`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_expose/) command.

    ```bash
    kubectl expose deployment nginx --name=nginx-ipv4 --port=80 --type=LoadBalancer
    kubectl expose deployment nginx --name=nginx-ipv6 --port=80 --type=LoadBalancer --overrides='{"spec":{"externalTrafficPolicy":"Local","ipFamilies":["IPv6"]}}'
    ```

    You receive output that shows the services are exposed.

    ```output
    service/nginx-ipv4 exposed
    service/nginx-ipv6 exposed
    ```
2. After you expose the deployment and fully provision the `LoadBalancer` services, get the IP addresses of the services by using the `kubectl get services` command.

    ```bash
    kubectl get services
    ```

    ```output
    NAME         TYPE           CLUSTER-IP               EXTERNAL-IP         PORT(S)        AGE
    nginx-ipv4   LoadBalancer   10.0.88.78               20.46.24.24         80:30652/TCP   97s
    nginx-ipv6   LoadBalancer   fd12:3456:789a:1::981a   2603:1030:8:5::2d   80:32002/TCP   63s
    ```
3. Verify functionality from a Linux VM or on-premises machine with an IPv6 address assigned and IPv6 routing configured. Azure Cloud Shell doesn't support IPv6.

    ```bash
    SERVICE_IP=$(kubectl get services nginx-ipv6 -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    curl -s "http://[${SERVICE_IP}]" | head -n5
    ```

    ```html
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    ```

# [YAML](#tab/yaml)
1. Expose the NGINX deployment with separate IPv4 and IPv6 `LoadBalancer` services by using the following YAML manifest.

    ```yml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: nginx
      name: nginx-ipv4
    spec:
      externalTrafficPolicy: Cluster
      ports:
        - port: 80
          protocol: TCP
          targetPort: 80
      selector:
        app: nginx
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: nginx
      name: nginx-ipv6
    spec:
      externalTrafficPolicy: Local
      ipFamilies:
        - IPv6
      ports:
        - port: 80
          protocol: TCP
          targetPort: 80
      selector:
        app: nginx
      type: LoadBalancer
    ```
2. After you expose the deployment and fully provision the `LoadBalancer` services, get the IP addresses of the services by using the `kubectl get services` command.

    ```bash
    kubectl get services
    ```

    ```output
    NAME         TYPE           CLUSTER-IP               EXTERNAL-IP         PORT(S)        AGE
    nginx-ipv4   LoadBalancer   10.0.88.78               20.46.24.24         80:30652/TCP   97s
    nginx-ipv6   LoadBalancer   fd12:3456:789a:1::981a   2603:1030:8:5::2d   80:32002/TCP   63s
    ```
3. Verify functionality from a Linux VM or on-premises machine with an IPv6 address assigned and IPv6 routing configured. Azure Cloud Shell doesn't support IPv6.

    ```bash
    SERVICE_IP=$(kubectl get services nginx-ipv6 -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    curl -s "http://[${SERVICE_IP}]" | head -n5
    ```

    ```html
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    ```

---