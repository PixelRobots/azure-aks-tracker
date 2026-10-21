---
layout: Conceptual
title: ECDSA and RSA Certificates for Azure Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/ecdsa-rsa-certificates
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
description: Learn how to configure a listener with both ECDSA and RSA certificates for Azure Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2024-05-09T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 1ceb6bef-357e-e1c2-860d-e618d2e67fa3
document_version_independent_id: 5ad3181c-2015-73dc-e4e5-30fd20dc8646
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/ecdsa-rsa-certificates.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/ecdsa-rsa-certificates
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/ecdsa-rsa-certificates.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 3446c1ea-bc47-f869-a1eb-35250effb0b4
---

# ECDSA and RSA Certificates for Azure Application Gateway for Containers | Microsoft Learn

Cryptography is vital in ensuring privacy, integrity, and security of data as it is transmitted between a client and server on a network. Two widely adopted cryptographic algorithms for asymmetric encryption are Rivest-Shamir-Adleman (RSA) and Elliptic Curve Digital Signature Algorithm (ECDSA).

- RSA asymmetric encryption was introduced in the 1970s and has wide device adoption today. RSA implements a simple mathematical approach to cryptography, which aids in adoption.
- ECDSA is an asymmetric encryption algorithm and successor to the Digital Signature Algorithm (DSA). ECDSA implements shorter key lengths than RSA, enabling excellent performance and scalability, while still retaining strong security. ECDSA was introduced in the 1990s, so some legacy devices might not be able to negotiate the algorithm.

## Implementation in Application Gateway for Containers

To provide flexibility, Application Gateway for Containers supports both ECDSA and RSA certificates. A listener can reference either ECDSA or RSA forcing a preferred encryption algorithm, or both can be supported in parallel. Running both algorithms in parallel enables both legacy and modern clients to negotiate a secure connection via RSA, while clients that support ECDSA can take advantage of the enhanced performance and security.

Configuration of the certificates used with Application Gateway for Containers is defined within the Gateway or Ingress resources within Kubernetes. The public and private key is defined as a Kubernetes secret and referenced by name from the Gateway or Ingress resources. No designation is required within the secret resource to specify if the certificate is RSA or ECDSA. Application Gateway for Containers is programmed based on the certificate details provided.

Application Gateway for Containers provides three variations for use of RSA and ECDSA secrets:

- Two secrets: one secret containing an RSA certificate, the other containing an ECDSA certificate
- One secret containing an RSA certificate
- One secret containing an ECDSA certificate

[![A diagram showing the Application Gateway for Containers with three variations of certificate configurations.](media/ecdsa-rsa-certificates/ecdsa-rsa-certificates.png)](media/ecdsa-rsa-certificates/ecdsa-rsa-certificates.png#lightbox)

## Configure both ECDSA and RSA certificates on the same listener

1. Configure Kubernetes secrets

Two secret resources are created, each with its own certificate. One certificate is generated ECDSA and the other RSA.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rsa-tls-secret
  namespace: test-infra
data:
  tls.crt: <base64encodedpublickey>
  tls.key: <base64encodedprivatekey>
type: kubernetes.io/tls
---
apiVersion: v1
kind: Secret
metadata:
  name: ecdsa-tls-secret
  namespace: test-infra
data:
  tls.crt: <base64encodedpublickey>
  tls.key: <base64encodedprivatekey>
type: kubernetes.io/tls
```

1. Reference the secrets via a listener

# [Gateway API](#tab/tls-policy-gateway-api)
Both ECDSA and RSA certificates on the same listener in Gateway API is supported by having two certificate references. A maximum of two certificates is supported: one ECDSA and one RSA.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  annotations:
    alb.networking.azure.io/alb-name: alb-test
    alb.networking.azure.io/alb-namespace: alb-test-infra
  name: gateway-01
  namespace: test-infra
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - allowedRoutes:
      namespaces:
        from: All
    name: http-listener
    port: 80
    protocol: HTTP
  - allowedRoutes:
      namespaces:
        from: All
    name: https-listener
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind : Secret
        group: ""
        name: ecdsa-tls-secret
        namespace: test-infra
      - kind : Secret
        group: ""
        name: rsa-tls-secret
        namespace: test-infra
```

# [Ingress API](#tab/tls-policy-ingress-api)
Both ECDSA and RSA certificates on the same host in Ingress API is supported by defining two host and secretName references. A maximum of two certificates is supported: one ECDSA and one RSA.

Warning

Ingress resources that reference the same frontend and define the same host must reference the same certificates. If there’s a discrepancy in the number of certificates between two Ingress resources (for example, one has a single certificate and the other has two), the configuration of the first defined Ingress resource will be implemented. The configuration of the second Ingress resource will be disregarded.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    alb.networking.azure.io/alb-name: alb-test
    alb.networking.azure.io/alb-namespace: alb-test-infra
  name: ingress-01
  namespace: test-infra
spec:
  ingressClassName: azure-alb-external
  tls:
  - hosts:
    - contoso.com
    secretName: ecdsa-tls-secret
  - hosts:
    - contoso.com
    secretName: rsa-tls-secret
  rules:
  - host: contoso.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-v1
            port:
              number: 8080
```

---