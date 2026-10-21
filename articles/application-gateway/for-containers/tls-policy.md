---
layout: Conceptual
title: TLS policy overview for Azure Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/tls-policy
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
description: Learn how to configure TLS policy for Azure Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2026-09-22T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: f9065e97-deb4-d895-7aed-e815d0eaf3bb
document_version_independent_id: 0d8dc7a8-413e-3403-acbe-652790f327c5
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/tls-policy.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/tls-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/tls-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 9df748ad-5fb6-755e-5e7d-58ca1a1c8736
---

# TLS policy overview for Azure Application Gateway for Containers | Microsoft Learn

You can use Azure Application Gateway for Containers to control TLS ciphers to meet compliance and security goals of the organization.

TLS policy includes definition of the TLS protocol version, cipher suites, and order in which ciphers are preferred during a TLS handshake. Application Gateway for Containers currently offers two predefined policies to choose from.

## Usage and version details

- A custom TLS policy allows you to configure the minimum protocol version, ciphers, and elliptical curves for your gateway.
- If no TLS policy is defined, a [default TLS policy](tls-policy#default-tls-policy) is used.
- TLS cipher suites used for the connection are also based on the type of the certificate being used. The cipher suites negotiated between client and Application Gateway for Containers are based on the *Gateway listener* configuration as defined in YAML. The cipher suites used in establishing connections between Application Gateway for Containers and the backend target are based on the type of server certificates presented by the backend target.

## Predefined TLS policy

Application Gateway for Containers offers two predefined security policies. You can choose either of these policies to achieve the appropriate level of security. Policy names are defined by year and month (YYYY-MM) of introduction. Additionally, an **-S** variant may exist to denote a more strict variant of ciphers that may be negotiated. Each policy offers different TLS protocol versions and cipher suites. These predefined policies are configured keeping in mind the best practices and recommendations from the Microsoft Security team. We recommend that you use the newest TLS policies to ensure the best TLS security.

The following table shows the list of cipher suites and minimum protocol version support for each predefined policy. The ordering of the cipher suites determines the priority order during TLS negotiation. To know the exact ordering of the cipher suites for these predefined policies.

| Predefined policy names | 2023-06 | 2023-06-S |
| --- | --- | --- |
| **Minimum protocol version** | TLS 1.2 | TLS 1.2 |
| **Enabled protocol versions** | TLS 1.2, TLS 1.3 | TLS 1.2, TLS 1.3 |
| TLS\_AES\_256\_GCM\_SHA384 | ✓ | ✓ |
| TLS\_AES\_128\_GCM\_SHA256 | ✓ | ✓ |
| TLS\_ECDHE\_ECDSA\_WITH\_AES\_256\_GCM\_SHA384 | ✓ | ✓ |
| TLS\_ECDHE\_ECDSA\_WITH\_AES\_128\_GCM\_SHA256 | ✓ | ✓ |
| TLS\_ECDHE\_RSA\_WITH\_AES\_256\_GCM\_SHA384 | ✓ | ✓ |
| TLS\_ECDHE\_RSA\_WITH\_AES\_128\_GCM\_SHA256 | ✓ | ✓ |
| **Elliptical curves** |  |  |
| P-384 | ✓ | ✓ |
| P-256 | ✓ | ✓ |

Protocol versions, ciphers, and elliptical curves not specified in the table above aren't supported and won't be negotiated.

Note

The 2023-06 and 2023-06-S policies currently enforce the same ciphers. In future releases, new policies will introduce different cipher sets.

### Default TLS policy

When no TLS Policy is specified within your Kubernetes configuration, **predefined policy 2023-06** will be applied.

## How to configure a TLS policy

# [Gateway API](#tab/tls-policy-gateway-api)
TLS policy can be defined in a [FrontendTLSPolicy](api-specification-kubernetes#alb.networking.azure.io/v1.FrontendTLSPolicy) resource, which targets defined gateway listeners. Specify a policyType of type `predefined` and use choose either predefined policy name: `2023-06` or `2023-06-S`

Example command to create a new FrontendTLSPolicy resource with the predefined TLS policy 2023-06-S.

```bash
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: FrontendTLSPolicy
metadata:
  name: policy-default
  namespace: test-infra
spec:
  targetRef:
    kind: Gateway
    name: target-01
    namespace: test-infra
    sectionNames:
    - https-listener
    group : gateway.networking.k8s.io
  default:
    policyType:
      type: predefined
      name: 2023-06-S
EOF
```

# [Ingress API](#tab/tls-policy-ingress-api)
TLS policy is currently not supported for Ingress resources and will automatically be configured to use the default TLS policy `2023-06`.

---