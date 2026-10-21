---
layout: Conceptual
title: AKS Edge Essentials deployment configuration JSON parameters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-deployment-config-json
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
description: Description of deployment configuration JSON parameters in AKS Edge Essentials.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-concept, edge-essentials
locale: en-us
document_id: c45e6a24-6bd5-943c-1d07-4d2beff82d66
document_version_independent_id: 95d9ac7f-87eb-c989-b48a-c3bbd59c3c59
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-deployment-config-json.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-deployment-config-json
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-deployment-config-json.md
platformId: dfc30db4-4176-449d-508a-d7c28695a5a7
---

# AKS Edge Essentials deployment configuration JSON parameters | Microsoft Learn

This page describes the AKS Edge Essentials deployment schema used in the `aksedge-config.json`.

You can find the complete JSON schema file at `C:\Program Files\AksEdge\aksedge-dcschema.json`.

| Attribute | Value type | Description | Default value | Applicable deployment types |
| --- | --- | --- | --- | --- |
| `SchemaVersion` | String | Specifies the version of the schema/format of the JSON. | `1.9` | Single-machine and full deployment |
| `Version` | `1.0` | Specifies the version of the JSON instance. | `1.0` | Single-machine and full deployment |
| `DeploymentType` | [`SingleMachineCluster` / `ScalableCluster`] | Specifies deployment type. In `ScalableCluster`, you can add more machines to the cluster infrastructure. | `SingleMachineCluster` | Single-machine and full deployment |
| `Init.ServiceIPRangeStart` | IPv4 address `A.B.C.x`. | Reserved IP start address for your Kubernetes services. This IP range must be free on your subnet **A.B.C.0**. | None | Single-machine and full deployment |
| `Init.ServiceIPRangeSize` | `[0-127]` | Number of reserved IP start addresses for your Kubernetes services. Based on the size, we allocate a range of free IP addresses on your subnet. | `0` | Single-machine and full deployment |
| `Init.KmsPlugin.Enable` | Boolean | Specifies whether the KMS plugin is enabled or not. | false | Single-machine and full deployment |
| `Join.ClusterJoinToken` | String | `Reserved` | None | Full deployment only |
| `Join.DiscoveryTokenHash` | String | `Reserved` | None | Full deployment only |
| `Join.CertificateKey` | String | `Reserved` | None | Full deployment only |
| `Join.ClusterId` | String | `Reserved` | None | Full deployment only |
| `Arc.ClusterName` | String | Preferred name for the cluster to show in the Azure portal. | `<Machinename>-cluster` | Single-machine and full deployment |
| `Arc.Location` | String | Location of resource group. | None | Single-machine and full deployment |
| `Arc.ResourceGroupName` | String | Resource group name. | None | Single-machine and full deployment |
| `Arc.SubscriptionId` | GUID | Azure subscription ID. | None | Single-machine and full deployment |
| `Arc.TenantId` | GUID | TenantID for the Azure subscription. | None | Single-machine and full deployment |
| `Arc.ClientId` | GUID | AppID of the service principal. You can use the **App Registrations** page in the Microsoft Entra resource page on the Azure portal, to list and manage the service principals in a tenant. | None | Single-machine and full deployment |
| `Arc.ClientSecret` | String | Secret associated with the service principal. | None | Single-machine and full deployment |
| `Network.ControlPlaneEndpointIp` | IPv4 address `A.B.C.x` | A free IP address on your subnet **A.B.C**. The control plane (API server) gets this address. |  | Full deployment only |
| `Network.NetworkPlugin` | [`calico` / `flannel`] | CNI plugin choice for the Kubernetes network model. For K8s cluster, always use `calico` and for K3s cluster, always use `flannel`. | `flannel` | Single-machine and full deployment |
| `Network.Ip4GatewayAddress` | IPv4 address `A.B.C.x` | Gateway address; typically the router address. |  | Full deployment only |
| `Network.Ip4PrefixLength` | `[1-31]` | The IP address subnet **A.B.C** prefix length. For example, use **24** if your network is **192.168.1.0/24**. | `24` | Full deployment only |
| `Network.Ip4AddressPrefix` | Subnet mask `A.B.C.0/24` | The subnet from which IP addresses are allotted in single machine deployments. For example, if you specify **192.168.1.0/24**, then the gateway address is **192.168.1.1**, the Linux node is **192.168.1.2**, the Windows node is **192.168.1.3**, and the service IPs are assigned **192.168.1.4** and onwards. This parameter is optional, and you must ensure that the IP addresses are available for use. If this parameter is not specified, AKS Edge Essentials determines available IP addresses on a best effort basis. |  | Single machine deployment only |
| `Network.DnsServers` | IPv4 address `A.B.C.x` | IP address of your DNS (typically the router address). To view what DNS your machine uses, issue the command `Get-DnsClientServerAddress -AddressFamily IPv4`. |  | Full deployment only |
| `Network.InternetDisabled` | Boolean | Whether your cluster has access to the internet. The default is `false`, meaning your cluster by default has access to the internet. | `false` | Single-machine and full deployment |
| `Network.SkipAddressFreeCheck` | Boolean | Ignores IP Address check failures and continues with deployment. | `false` | Full deployment |
| `Network.SkipDnsCheck` | Boolean | If you have provided DNS servers in the `Network.DnsServers` parameter, this flag ignores the DNS check and continues with deployment. | `false` | Single-machine and full deployment |
| `Network.Proxy.Http` | String | HttpProxy link. |  | Single-machine and full deployment |
| `Network.Proxy.Https` | String | HttpsProxy link. |  | Single-machine and full deployment |
| `Network.Proxy.No` | String | No proxy config for bypassing the proxy. |  | Single-machine and full deployment |
| `User.AcceptEula` | Boolean | Accept or decline the EULA. | `false` | Single-machine and full deployment |
| `User.AcceptOptionalTelemetry` | Boolean | Accept or decline the `optional` telemetry. The `required` telemetry is always enabled. | `false` | Single-machine and full deployment |
| `User.VolumeLicense.EnrollmentID` | String | If volume licensing is applicable, provide your enrollment ID. |  | Single-machine and full deployment |
| `User.VolumeLicense.PartNumber` | String | If volume licensing is applicable, provide the part number. |  | Single-machine and full deployment |
| `Machines[].ArcHybridComputeMachineId` | String | `Reserved` | `null` | Single-machine and full deployment |
| `Machines[].NetworkConnection.AdapterName` | String | NetAdapterName for VSwitch. It's mandatory for a full Kubernetes deployment. You can run `Get-NetAdapter -Physical` to view the `Name` column for the adapter of your choice. |  | Single-machine and full deployment |
| `Machines[].NetworkConnection.Mtu` | Number | The maximum transmission unit (MTU) for the network. | `0` | Single-machine and full deployment |
| `Machines[].LinuxNode.ControlPlane` | Boolean | Specifies whether you want this new deployment to be a control plane. If `false`, it's a worker node. Only for Linux VMs. | `false` | Single-machine and full deployment |
| `Machines[].LinuxNode.CpuCount` | [`2-x`] | Number of CPU cores reserved for VM/VMs. | `2` | Single-machine and full deployment |
| `Machines[].LinuxNode.MemoryInMB` | [`2048-2x`] | RAM in MBs reserved for VM/VMs. | `2048` | Single-machine and full deployment |
| `Machines[].LinuxNode.DataSizeInGB` | Number | Size of the data partition. For large applications, we recommend increasing this number. Only for Linux VMs. | `10` | Single-machine and full deployment |
| `Machines[].LinuxNode.LogSizeInGB` | Number | Size of the log partition in GB. Maximum log partition size is capped at 10 GB with minimum and default at 1 GB. Available only on Linux nodes. | `1` | Single-machine and full deployment |
| `Machines[].LinuxNode.Ip4Address` | `A.B.C.x` | Specifies the IP address your VM takes. |  | Single-machine and full deployment |
| `Machines[].LinuxNode.MacAddress` | `00:00:00:00:00:00` | Specifies the MAC address your VM takes. |  | Single-machine and full deployment |
| `Machines[].LinuxNode.TimeoutSeconds` | Number | Timeout provided for the Kubernetes cluster to complete the bootstrap process. It's recommended that you use the default value. | `300` | Single-machine and full deployment |
| `Machines[].LinuxNode.TpmPassthrough` | Boolean | Enables TPM access from the Linux node. | `false` | Single-machine and full deployment |
| `Machines[].LinuxNode.SecondaryNetworks` | Array | Specifies a secondary network to be added to the Linux node. You can specify an array of `VMSwitchName` with optional static IP information. (`Ip4Address,Ip4GatewayAddress and Ip4PrefixLength`) | `null` | Single-machine and full deployment |
| `Machines[].WindowsNode.CpuCount` | [`2-x`] | Number of CPU cores reserved for VM/VMs. | `2` | Single-machine and full deployment |
| `Machines[].WindowsNode.MemoryInMB` | [`2048-2x`] | RAM in MBs reserved for VM/VMs (multiples of 2). | `2048` | Single-machine and full deployment |
| `Machines[].WindowsNode.Ip4Address` | `A.B.C.x` | Specifies the IP address your VM takes. |  | Single-machine and full deployment |
| `Machines[].WindowsNode.MacAddress` | `00:00:00:00:00:00` | Specifies the MAC address your VM takes. |  | Single-machine and full deployment |
| `Machines[].WindowsNode.TimeoutSeconds` | Number | Timeout provided for the kubernetes cluster to complete the bootstrap process. It's recommended that you use the default value. | `900` | Single-machine and full deployment |