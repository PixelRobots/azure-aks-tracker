---
layout: Conceptual
title: SSL offloading with Application Gateway for Containers - Ingress API | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/how-to-ssl-offloading-ingress-api
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
description: Learn how to configure SSL offloading with Application Gateway for Containers using the Ingress API.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: how-to
ms.date: 2024-11-05T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: e32c4088-9d1a-2c34-d0e2-229ab030b30a
document_version_independent_id: 821b2ffc-97cf-8fbd-1665-a42a822c5714
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/how-to-ssl-offloading-ingress-api.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/how-to-ssl-offloading-ingress-api
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/how-to-ssl-offloading-ingress-api.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: e6a79ad9-8704-a59f-6425-f3a24284f8cc
---

# SSL offloading with Application Gateway for Containers - Ingress API | Microsoft Learn

This document helps set up an example application that uses the *Ingress* resource from [Ingress API](https://kubernetes.io/docs/concepts/services-networking/ingress/):

## Background

Application Gateway for Containers enables SSL [offloading](/en-us/azure/architecture/patterns/gateway-offloading) for better backend performance. See the following example scenario:

![A figure showing SSL offloading with Application Gateway for Containers.](media/how-to-ssl-offloading-ingress-api/ssl-offloading.png)

## Prerequisites

Note

Certificates for Application Gateway for Containers must be stored as Kubernetes secrets. Azure Key Vault integration via the [Secrets Store CSI driver](/en-us/azure/aks/csi-secrets-store-driver) is not supported because Application Gateway for Containers requires certificates to be local to the cluster and cannot mount them from external volumes. For automated certificate management, consider using [cert-manager with Let's Encrypt](how-to-cert-manager-lets-encrypt-ingress-api).

1. If you follow the BYO deployment strategy, ensure that you set up your Application Gateway for Containers resources and ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm))
2. If you follow the ALB managed deployment strategy, ensure that you provision your ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm)) and the Application Gateway for Containers resources via the [ApplicationLoadBalancer custom resource](quickstart-create-application-gateway-for-containers-managed-by-alb-controller).
3. Deploy a sample HTTPS application: Apply the following deployment.yaml file on your cluster to create a sample web application to demonstrate TLS/SSL offloading.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/refs/heads/main/articles/application-gateway/for-containers/examples/https-scenario/ssl-termination/deployment.yaml
    ```

    This command creates the following on your cluster:

    - a namespace called `test-infra`
    - one service called `echo` in the `test-infra` namespace
    - one deployment called `echo` in the `test-infra` namespace
    - one secret called `listener-tls-secret` in the `test-infra` namespace

## Deploy the required Ingress API resources

# [ALB managed deployment](#tab/alb-managed)
1. Create an Ingress

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-name: alb-test
    alb.networking.azure.io/alb-namespace: alb-test-infra
spec:
  ingressClassName: azure-alb-external
  tls:
  - hosts:
    - example.com
    secretName: listener-tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echo
            port:
              number: 80
EOF
```

Note

When the ALB Controller creates the Application Gateway for Containers resources in Azure Resource Manager, it uses the following naming convention for a frontend resource: `fe-<eight randomly generated characters>`.

If you want to change the name of the frontend resource created in Azure, consider following the [bring-your-own deployment strategy](overview#deployment-strategies).

# [Bring your own (BYO) deployment](#tab/byo)
1. Set the following environment variables

```bash
RESOURCE_GROUP='<resource group name of the Application Gateway For Containers resource>'
RESOURCE_NAME='alb-test'

RESOURCE_ID=$(az network alb show --resource-group $RESOURCE_GROUP --name $RESOURCE_NAME --query id -o tsv)
FRONTEND_NAME='frontend'
```

1. Create an Ingress resource.

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-id: $RESOURCE_ID
    alb.networking.azure.io/alb-frontend: $FRONTEND_NAME
spec:
  ingressClassName: azure-alb-external
  tls:
  - hosts:
    - example.com
    secretName: listener-tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echo
            port:
              number: 80
EOF
```

---

When the ingress resource is created, ensure the status shows the hostname of your load balancer and that both ports are listening for requests.

```bash
kubectl get ingress ingress-01 -n test-infra -o yaml
```

Example output of successful Ingress creation.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    alb.networking.azure.io/alb-frontend: FRONTEND_NAME
    alb.networking.azure.io/alb-id: /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzz
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.k8s.io/v1","kind":"Ingress","metadata":{"annotations":{"alb.networking.azure.io/alb-frontend":"FRONTEND_NAME","alb.networking.azure.io/alb-id":"/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzz"},"name"
:"ingress-01","namespace":"test-infra"},"spec":{"ingressClassName":"azure-alb-external","rules":[{"host":"example.com","http":{"paths":[{"backend":{"service":{"name":"echo","port":{"number":80}}},"path":"/","pathType":"Prefix"}]}}],"tls":[{"hosts":["example.com"],"secretName":"listener-tls-secret"}]}}
  creationTimestamp: "2023-07-22T18:02:13Z"
  generation: 2
  name: ingress-01
  namespace: test-infra
  resourceVersion: "278238"
  uid: 17c34774-1d92-413e-85ec-c5a8da45989d
spec:
  ingressClassName: azure-alb-external
  rules:
  - host: example.com
    http:
      paths:
      - backend:
          service:
            name: echo
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - example.com
    secretName: listener-tls-secret
status:
  loadBalancer:
    ingress:
    - hostname: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.fzyy.alb.azure.com
      ports:
      - port: 80
        protocol: TCP
      - port: 443
        protocol: TCP
```

## Test access to the application

Now we're ready to send some traffic to our sample application, via the FQDN assigned to the frontend. Use the command below to get the FQDN.

```bash
fqdn=$(kubectl get ingress ingress-01 -n test-infra -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Curling this FQDN should return responses from the backend as configured on the HTTPRoute.

```bash
fqdnIp=$(dig +short $fqdn)
curl -vik --resolve example.com:443:$fqdnIp https://example.com
```

Congratulations, you have installed ALB Controller, deployed a backend application and routed traffic to the application via Ingress on Application Gateway for Containers.