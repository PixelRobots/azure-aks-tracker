---
layout: Conceptual
title: Release notes for ALB Controller | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/alb-controller-release-notes
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
learn_banner_products:
- azure
manager: kumud
ms.reviewer: mbender
description: This article lists updates made to the Application Gateway for Containers ALB Controller.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: release-notes
ms.date: 2026-10-23T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: e5385f2c-ab07-4af4-84d5-8f03b90be2be
document_version_independent_id: 34c8c138-f847-7492-6c5b-251c8f5db7c2
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/alb-controller-release-notes.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/alb-controller-release-notes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/alb-controller-release-notes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 88729bb8-3b09-f7f2-756a-bb548ed91317
---

# Release notes for ALB Controller | Microsoft Learn

This article provides details about changes to the ALB Controller for Application Gateway for Containers.

The ALB Controller is a Kubernetes deployment that orchestrates configuration and deployment of Application Gateway for Containers. It uses both Azure Resource Manager and configuration APIs to propagate configuration to the Application Gateway for Containers Azure deployment.

Each release of ALB Controller has a documented helm chart version and supported Kubernetes cluster version.

Instructions for new or existing deployments of ALB Controller deployed with Helm are found in the following links:

- [New deployment of ALB Controller with Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm#for-new-deployments)
- [Upgrade existing ALB Controller with Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm#for-existing-deployments)

If using the AKS add-on, updates are automatically applied to the cluster.

## Latest Helm release

| ALB Controller Version | Gateway API Version | Gateway API Inference Extension Version | Minimum Kubernetes Version | Release notes |
| --- | --- | --- | --- | --- |
| 1.12.4 | v1.5.1 | v1.3.1 | v1.32 | Security patches |

## AKS add-on releases

The Application Gateway for Containers add-on uses a pinned version of ALB Controller based on the AKS cluster version. The AKS version determines the supported Gateway API bundle, which in turn determines the compatible ALB Controller version. The AKS managed Gateway API documentation lists the Gateway API bundle supported by each Kubernetes version.

| AKS cluster version | ALB Controller version |
| --- | --- |
| v1.26.x – v1.35.x | v1.10.x |
| v1.36.x and later | v1.11.x |

Reference: [AKS Managed Gateway API installation](/en-us/azure/aks/managed-gateway-api#supported-kubernetes-versions-for-gateway-api-bundle-versions)

## Release history

| ALB Controller Version | Gateway API Version | Gateway API Inference Extension Version | Minimum Kubernetes Version | Release Notes |
| --- | --- | --- | --- | --- |
| 1.12.2 | v1.5.1 | v1.3.1 | v1.32 | Security patches |
| 1.12.1 | v1.5.1 | v1.3.1 | v1.32 | Security patches, bug fixes [helm chart pre-delete tolerations](https://github.com/Azure/AKS/issues/5729)[session affinity cookie fix](https://github.com/Azure/AKS/issues/5805), request mirror |
| 1.11.7 | v1.5.1 | v1.3.1 | v1.27 | Security patches |
| 1.11.6 | v1.5.1 | v1.3.1 | v1.27 | Security patches |
| 1.11.5 | v1.5.1 | v1.3.1 | v1.27 | Security patches, bug fix for AKS automatic |
| 1.11.3 | v1.5.1 | v1.3.1 | v1.27 | Security patches, WAF fixes, Istio service mesh integration - cert-rotation fix |
| 1.11.1 | v1.5.1 | v1.3.1 | v1.27 | Implement Gateway API v1.5.1, Gateway API Inference Extension support, ALB Controller on Arm64 node support, support for CORS, Gateway API HTTPRoute timeouts (succeed RoutePolicy timeouts), HTTP redirect 307/308 support, helm subcharts fix [GitHub Issue: #5475](https://github.com/Azure/AKS/issues/5475), Helm logging enum fix [GitHub Issue: #5480](https://github.com/Azure/AKS/issues/5480) |
| 1.10.40 | v1.2.1 | - | v1.27 | Security patches |
| 1.10.39 | v1.2.1 | - | v1.27 | Security patches |
| 1.10.37 | v1.2.1 | - | v1.27 | Security patches + bug fixes |
| 1.10.32 | v1.2.1 | - | v1.27 | Security patches, Istio service mesh integration - cert-rotation fix |
| 1.10.28 | v1.2.1 | - | v1.27 | Security updates |
| 1.10.27 | v1.2.1 | - | v1.27 | Hotfix for pod crash [GitHub issue 5758](https://github.com/Azure/AKS/issues/5758) |
| 1.10.26 | v1.2.1 | - | v1.27 | Istio service mesh integration fix, security patches |
| 1.10.21 | v1.2.1 | - | v1.27 | Load Aware Routing, fixes for AGC + AKS Istio add-on, fix [readiness probe for ingress](https://github.com/Azure/AKS/issues/5644), security patches |
| 1.9.13 | v1.2.1 | - | v1.27 | Concurrency-related pod crash fix, security updates |
| 1.9.11 | v1.2.1 | - | v1.27 | [allowPrivilegeEscalation false](https://github.com/Azure/AKS/issues/5389), [Integration with AKS Istio Service Mesh Add-on](https://github.com/Azure/AKS/issues/5479), [fix for NAP with Karpenter](https://github.com/Azure/AKS/issues/5486), general image updates |
| 1.8.12 | v1.2.1 | - | v1.27 | WAF improvements |
| 1.8.9 | v1.2.1 | - | v1.27 | [Slow start load balancing algorithm](api-specification-kubernetes#alb.networking.azure.io/v1.BackendLoadBalancingPolicy), Image updated to use [Azure Linux 3.0](https://github.com/microsoft/azurelinux), [nodeSelector fix](https://github.com/Azure/AKS/issues/5302), miscellaneous bug fixes and enhancements |
| 1.7.12 | v1.2.1 | - | v1.27 | Hotfix for pod crash due to [invalid Provider ID](https://github.com/Azure/AKS/issues/5310) |
| 1.7.9 | v1.2.1 | - | v1.27 | [Web Application Firewall (WAF) Public Preview](https://aka.ms/agc/waf), Updated to Gateway API v1.2.1, [nodeSelector support](https://github.com/Azure/AKS/issues/4370#issuecomment-2894487836), [Permissions fix for Overlay networks](https://github.com/Azure/AKS/issues/5039), fix for SAN regex matching, miscellaneous performance improvements |
| 1.6.7 | v1.1.1 | - | v1.27 | [Fix for SSE timeout value of 0](https://aka.ms/qa2153620), [Overlay CNI fix](https://github.com/Azure/AKS/issues/4950), [support readinessProbe port by name](https://github.com/Azure/AKS/issues/4861), apply init container during bootstrap, miscellaneous bug fixes and improvements |
| 1.5.2 | v1.1.1 | - | v1.26 | Support for Azure CNI Overlay |
| 1.4.12 | v1.1.1 | - | v1.26 | Updated to Gateway API version 1.1.1, Regex match support for path and header match in HTTP and GRPC routes, [Wildcard hostname fix](https://github.com/Azure/AKS/issues/4713), miscellaneous bug fixes, and improvements |
| 1.3.7 | v1.1 | - | v1.26 | Minor fixes and improvements |
| 1.2.3 | v1.1 | - | v1.26 | Gateway API v1.1, gRPC support, frontend mutual authentication, readiness probe fixes, custom health probe port and TLS mode |
| 1.0.2 | v1 | - | v1.26 | ECDSA + RSA certificate support for both Ingress and Gateway API, Ingress fixes, Server-sent events support |
| 1.0.0 | v1 | - | v1.26 | General Availability! URL redirect for both Gateway and Ingress API, v1beta1 -&gt; v1 of Gateway API, quality improvementsBreaking Changes: TLS Policy for Gateway API [PolicyTargetReference](https://gateway-api.sigs.k8s.io/reference/api-spec/main/spec/#localpolicytargetreferencewithsectionname)Listener is now referred to as [SectionName](https://gateway-api.sigs.k8s.io/reference/api-spec/main/spec/#sectionname)Fixes: Request timeout of 3 seconds, [HealthCheckPolicy interval](https://github.com/Azure/AKS/issues/4086), [pod crash for missing API fields](https://github.com/Azure/AKS/issues/4087) |
| 0.6.3 | v1beta1 | - | v1.25 | Hotfix to address handling of Application Gateway for Containers frontends during controller restart in managed scenario |
| November 6, 2023 - 0.6.1 | v1beta1 | - | v1.25 | Gateway / Ingress API - Header rewrite support, Ingress API - URL rewrite support, Ingress multiple-TLS listener bug fix, two certificates maximum per host, adopting [semantic versioning (semver)](https://semver.org/), quality improvements |
| September 25, 2023 - 0.5.024542 | v1beta1 | - | v1.25 | Custom Health Probes, Controller HA, Multi-site support for Ingress, [helm_release via Terraform fix](https://github.com/Azure/AKS/issues/3857), Path rewrite for Gateway API, status for Ingress resources, quality improvements |
| July 25, 2023 - 0.4.023971 | v1beta1 | - | v1.25 | Ingress + Gateway coexistence improvements |
| July 24, 2023 - 0.4.023961 | v1beta1 | - | v1.25 | Improved Ingress support |
| July 24, 2023 - 0.4.023921 | v1beta1 | - | v1.25 | Initial release of ALB Controller |