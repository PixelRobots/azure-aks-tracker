---
layout: Conceptual
title: Troubleshoot network validation errors | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/network-validation-errors
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
description: Learn how to troubleshoot general network validation errors in AKS.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.lastreviewed: 2025-07-16T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: d06ee96c-9501-3258-1046-b6c34e32281e
document_version_independent_id: fce7088b-9f21-f2d9-32cf-72e070314f56
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/network-validation-errors.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/network-validation-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/network-validation-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: b42c8608-562e-07c1-70b9-7e07335e87aa
---

# Troubleshoot network validation errors | Microsoft Learn

This article describes how to identify and resolve various network validation errors you might encounter during cluster creation. The article emphasizes the importance of pre-checks for early issue detection. These errors are detected by pre-checks designed to highlight issues early, allowing for easier resolution before the cluster is created.

The article summarizes error codes, their potential causes, and actionable mitigation steps to help you resolve issues effectively.

## CloudAgentConnectivityError

Error: Network validation failed during cluster creation.

### Description

Detailed message: `Not able to connect to http://cloudagent.contoso.local:50000. Error returned: action failed after 5 attempts: Get "http://cloudagent.contoso.local:50000": dial tcp: lookup http://cloudagent.contoso.local: Temporary failure in name resolution`

The MOC cloud agent is created using one of the IP addresses from the [Management IP pool](/en-us/azure/azure-local/plan/cloud-deployment-network-considerations#management-ip-pool) on port 5500 and the control plane node VM is given IP addresses from the Arc VM logical network. This error occurs when the MOC cloud agent is not reachable from the control plane VM, or when the DNS servers specified in the Arc VM logical network are unable to resolve the MOC cloud agent FQDN.

### Causes of failure

Logical network IP addresses can't connect to management IP pool addresses, due to:

- Incorrect DNS server resolution.
- Firewall rules between the Arc VM logical network and the cloud agent endpoint.
- The logical network is in a different VLAN than the management IP pool and there's no cross-VLAN connectivity.

### Mitigation

To resolve this error, you can take the following steps:

- Make sure that the DNS servers specified in the Arc VM logical network can resolve the MOC cloud agent FQDN.
- Make sure that the logical network IP addresses can connect to all the management IP pool addresses on the required ports. For a detailed list of ports that need to be opened, see [AKS network port and cross-VLAN requirements](network-system-requirements#network-port-and-cross-vlan-requirements).

## InternetConnectivityError

Error: Network validation failed during cluster creation.

### Description

Detailed message: `Not able to connect to https://mcr.microsoft.com. Error returned: action failed after 5 attempts: Get "https://mcr.microsoft.com": dial tcp: lookup mcr.microsoft.com on <>: read udp <>: i/o timeout`.

This error indicates that the required URLs are not reachable from the AKS cluster control plane node VM.

### Causes of failure

- Control plane node VM has no outbound internet access.
- Required URLs aren't allowed through the firewall.

### Mitigation

To resolve this error, ensure that the logical network IP addresses have outbound internet access. If there's a firewall, ensure that the [AKS required URLs](network-system-requirements#firewall-url-exceptions) are accessible from the Arc VM logical network.

## InternetConnectivityError (in Arc Gateway scenario)

Error: Network validation failed during cluster creation.

### Description

Detailed message: `Not able to connect to https://mcr.microsoft.com. Error returned: action failed after 5 attempts: Get "https://mcr.microsoft.com": proxyconnect tcp: dial tcp 192.168.2.100:40343: connect: connection refused`.

### Causes of failure

- The control plane VM can't reach the Azure Local cluster IP on port **40343**, which is required when Arc Gateway is enabled.
- The firewall or network security rules block traffic between the AKS subnet and the cluster IP.
- Proxy settings are incorrect, or the proxy does not allow connections to `mcr.microsoft.com`.

### Mitigation

To resolve this error, you can take the following steps:

- Ensure that the **AKS subnet has connectivity to the Azure Local Cluster IP on port `40343`**.
- Verify that the Arc Gateway service on the Azure Local Cluster is running and listening on port `40343`.
- Check firewall or NSG rules to ensure that traffic between the AKS VMs and the Cluster IP on `40343` is allowed.
- Confirm that proxy settings (if used) are correct and that the proxy can forward requests to `https://mcr.microsoft.com`.
- Test connectivity to `https://mcr.microsoft.com` from the control plane VM, either directly or via the configured proxy.

For more information, see [Use Azure Arc Gateway with Azure Local](network-system-requirements#use-azure-arc-gateway-preview-with-azure-local).

## VMNotReachableError

Error: Network validation failed during cluster creation.

### Description

Detailed message: `VM IP : <> is not reachable from management cluster`.

This error indicates that the AKS cluster control plane VM is not reachable from the Arc Resource Bridge (ARB).

### Causes of failure

The Arc VM logical network is not reachable from management IP pool addresses.

### Mitigation

To resolve this error, you can take the following steps:

- Make sure that the management IP pool addresses can reach the logical network IP addresses.
- For a detailed list of ports that need to be opened, see [AKS network port and cross-VLAN requirements](network-system-requirements#network-port-and-cross-vlan-requirements).

## DNSResolutionError

This error occurs when DNS servers specified in the Arc VM logical network can't resolve the MOC cloud FQDN or the required URLs.

### Causes of failure

DNS servers specified in a logical network can't resolve the MOC cloud FQDN or the required URLs.

### Mitigation

To resolve this error, check the DNS servers specified in the logical network so that they can resolve the MOC cloud FQDN or the required URLs.

## Contact Microsoft Support

If problems persist, [collect AKS cluster logs](get-on-demand-logs) before you [create a support request](aks-troubleshoot#open-a-support-request).