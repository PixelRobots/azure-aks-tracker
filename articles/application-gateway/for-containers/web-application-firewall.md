---
layout: Conceptual
title: Azure Web Application Firewall on Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/web-application-firewall
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
description: This article provides an overview of Azure Web Application Firewall on Application Gateway for Containers, including setup, limitations, and pricing.
services: application-gateway
author: JackStromberg
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2025-11-10T00:00:00.0000000Z
ms.author: jstrom
locale: en-us
document_id: 55bbb10e-0505-004b-849f-d1101a5173d9
document_version_independent_id: bfee2e62-72f5-d92e-08e4-1dcaba0617ba
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/web-application-firewall.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/web-application-firewall
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/web-application-firewall.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/e8fdebed-2921-4997-a75a-fa863723a535
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cf1e63a8-325f-42be-b60c-d84a95a42b1f
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 36aa7fe1-ef3d-5a8c-7f02-bc390d98d4af
---

# Azure Web Application Firewall on Application Gateway for Containers | Microsoft Learn

Azure Web Application Firewall provides centralized protection of your web applications from common exploits and vulnerabilities. All Azure Web Application Firewall functionality exists inside a policy, which can be referenced at listener or path-based routing rules within the Gateway API YAML configuration.

![Diagram that shows an Azure Web Application Firewall rule blocking a request.](media/how-to-web-application-firewall-gateway-api/web-application-firewall.png)

## Application Gateway for Containers implementation

### Security policy

Application Gateway for Containers introduces a new child resource called `SecurityPolicy` in Azure Resource Manager. The `SecurityPolicy` resource brings scope to which Azure Web Application Firewall policies the ALB Controller can reference.

### Kubernetes custom resource

Application Gateway for Containers introduces a new custom resource called `WebApplicationFirewallPolicy`. The custom resource is responsible for defining which Azure Web Application Firewall policy should be used at which scope.

The WebApplicationFirewallPolicy resource can target the following Kubernetes resources:

- `Gateway`
- `HTTPRoute`

The WebApplicationFirewallPolicy resource can also reference the following sections by name for further granularity:

- `Gateway`: `Listener`

### Example implementations

#### Scope a policy to a Gateway resource

Here's an example YAML configuration that shows targeting a Gateway resource, which would apply to all listeners on a given Application Gateway for Containers' frontend resource.

```yaml
apiVersion: alb.networking.azure.io/v1
kind: WebApplicationFirewallPolicy
metadata:
  name: sample-waf-policy
  namespace: test-infra
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: contoso-waf-route
    namespace: test-infra
  webApplicationFirewall:
    id: /subscriptions/.../Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/waf-policy-0
```

#### Scope policy to a specific listener of a Gateway resource

Within a `Gateway` resource, you may have different hostnames defined by different listeners (e.g. contoso.com and fabrikam.com). If contoso.com is a hostname of listenerA and fabrikam.com is a hostname of listenerB, you can define the `sectionNames` property to select the proper listener (for example, listenerA for contoso.com).

```yaml
apiVersion: alb.networking.azure.io/v1
kind: WebApplicationFirewallPolicy
metadata:
  name: sample-waf-policy
  namespace: test-infra
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: contoso-waf-route
    namespace: test-infra
    sectionNames: ["contoso-listener"]
  webApplicationFirewall:
    id: /subscriptions/.../Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/waf-policy-0
```

#### Scope policy across all routes and paths

This example shows how to target a defined HTTPRoute resource to apply the policy to any routing rules and paths within a given HTTPRoute resource.

```yaml
apiVersion: alb.networking.azure.io/v1
kind: WebApplicationFirewallPolicy
metadata:
  name: sample-waf-policy
  namespace: test-infra
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: contoso-pathA
    namespace: test-infra
  webApplicationFirewall:
    id: /subscriptions/.../Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/waf-policy-0
```

#### Scope policy to a particular path

To use different WAF policies to different paths of the same `Gateway` or Gateway -&gt; Listener sectionName, you can define two HTTPRoute resources, each with a unique path, that each references its applicable WAF policy.

```yaml
apiVersion: alb.networking.azure.io/v1
kind: WebApplicationFirewallPolicy
metadata:
  name: sample-waf-policy-A
  namespace: test-infra
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: contoso-pathA
    namespace: test-infra
  webApplicationFirewall:
    id: /subscriptions/.../Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/waf-policy-0
---
apiVersion: alb.networking.azure.io/v1
kind: WebApplicationFirewallPolicy
metadata:
  name: sample-waf-policy-B
  namespace: test-infra
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: contoso-pathB
    namespace: test-infra
  webApplicationFirewall:
    id: /subscriptions/.../Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/waf-policy-1
```

## Limitations

The following functionality is not supported on an Azure Web Application Firewall policy that's associated with Application Gateway for Containers:

- **Cross-region, cross-subscription policy**: Your WAF policy must be in the same subscription and region as your Application Gateway for Containers resource.
- **Core Rule Set (CRS) managed rules**: An Application Gateway for Containers WAF supports only Default Rule Set (DRS) 2.1 managed rule set.
- **Legacy Bot Manager Rule Set**: Bot Manager Ruleset 0.1 isn't supported, but Bot Manager Ruleset versions 1.0 and 1.1 are supported.
- **JavaScript challenge actions on Bot Manager rules**: You can't set the action on a Bot Manager rule to JavaScript challenge.
- **Captcha challenge actions on Bot Manager rules**: You can't set the action on a Bot Manager rule to Captcha.
- **Microsoft Security Copilot**: The Security Copilot is not supported on Application Gateway for Containers WAF.
- **Custom Block Response**: Setting a custom block response in your WAF policy is not supported on Application Gateway for Containers WAF.
- **X-Forwarded-For Header (XFF)**: Application Gateway for Containers WAF doesn't support the XFF variable in custom rules.
- **HTTP DDoS Ruleset**: This managed ruleset isn't currenlty supported on Application Gateway for Containers.

## Pricing

For pricing details, see [Understanding pricing for Application Gateway for Containers](understanding-pricing).