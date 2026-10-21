---
layout: Conceptual
title: Service mesh integration with Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/service-mesh-integration
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
description: Learn how to integrate Application Gateway for Containers with Istio service mesh for secure ingress traffic.
services: application-gateway
author: JackStromberg
ms.service: azure-application-gateway-containers
ms.topic: how-to
ms.date: 2026-09-09T00:00:00.0000000Z
ms.author: jstrom
locale: en-us
document_id: 7afd4972-9d58-f27d-85c4-42257fe0b228
document_version_independent_id: 53623e11-560f-457c-222e-aa3ff0a1bba3
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/service-mesh-integration.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/service-mesh-integration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/service-mesh-integration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 4cf7e626-bc0b-7dde-b527-ef8f79b05fdd
---

# Service mesh integration with Application Gateway for Containers | Microsoft Learn

Service meshes handle east-west traffic between services and often use mutual TLS (mTLS) for security. When services need external access (north-south traffic), an ingress gateway simplifies connectivity. Application Gateway for Containers provides a service mesh extension that automates certificate lifecycle management and reduces configuration complexity.

While defining mTLS in ingress is possible, definition of mTLS configuration can become redundant and difficult to manage during certificate rotation.

To simplify communication from outside the Kubernetes cluster to the service mesh, Application Gateway for Containers has an optional service mesh extension that can be installed alongside ALB Controller. This extension can greatly decrease operational overhead by automating certificate lifecycle management and simplify ingress configuration.

Here's a diagram of Application Gateway for Containers integrating with Istio service mesh.

![Diagram depicting alb-controller and alb-controller-servicemesh-extension to establish mutual TLS to services part of the Istio mesh.](media/service-mesh-integration/service-mesh-istio-overview.svg)

## ALB Controller Service Mesh Extension

The ALB Controller Istio Extension consists of two pods, deployed in active / standby configuration to allow resiliency during node failure, handle certificate lifecycle management between Application Gateway for Containers and Istio, and implicitly handle mTLS configuration to the services participating in the service mesh.

Note

To use ALB Controller Service Mesh Extension, you must define your ingress intent using Gateway API. Ingress API isn't supported.

Note

This integration assumes an Istio sidecar-based service mesh. Ambient (sidecar-less) mode isn't supported.

### Install the ALB Controller Service Mesh Extension for Istio

Install the ALB Controller Service Mesh Extension using the Helm chart after provisioning ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm)). The ALB Controller Service mesh Extension is installed using a separate [helm chart](service-mesh-helm-chart).

The following helm command can be used to install the extension.

```bash
HELM_NAMESPACE='<namespace for deployment>'
CONTROLLER_NAMESPACE='azure-alb-system'
RESOURCE_GROUP='<your resource group name>'
AKS_NAME='<your aks cluster name>'

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

helm install alb-controller-servicemesh-extension oci://mcr.microsoft.com/application-lb/charts/alb-controller-servicemesh-extension \
     --namespace $HELM_NAMESPACE \
     --version 1.12.1
```

### Verify the ALB Controller installation

Verify the ALB Controller Service Extension pods are ready as prefixed by `alb-controller-istio-extension`.

```azurecli
kubectl get pods -n azure-alb-system
```

You should see the following output:

| NAME | READY | STATUS | RESTARTS | AGE |
| --- | --- | --- | --- | --- |
| alb-controller-6648c5d5c-sdd9t | 1/1 | Running | 0 | 4d6h |
| alb-controller-6648c5d5c-au234 | 1/1 | Running | 0 | 4d6h |
| alb-controller-istio-extension-69dc679455-94z7b | 2/2 | Running | 0 | 1h |
| alb-controller-istio-extension-69dc679455-ffqzx | 2/2 | Running | 0 | 1h |

### Integration with Istio

Application Gateway for Containers supports integration with Istio v1.24 and greater.

After the ALB Controller Service Mesh Extension is installed, if Istio is installed, the service mesh integration will attempt to provision a sidecar for integration into the mesh.

If ALB Controller Service Mesh is installed prior to Istio, you must restart the ALB Controller Service Mesh extension deployment. Restart of the ALB Controller Service Mesh deployment can be done with the command: `kubectl rollout restart deployment/alb-controller-istio-extension`

### Routing traffic to Istio service mesh

Follow these five steps to configure Istio service mesh with Application Gateway for Containers:

- Define a namespace for istio sidecar injection
- Enable mTLS for the services in that namespace
- Deploy a sample application for testing (optional)
- Define a Gateway resource
- Define an HTTPRoute resource

#### Define the namespace

Depending on how Istio is installed, you'll need to configure the label used to enable Istio sidecar injection.

# [Open-source Istio](#tab/oss-istio)
ALB Controller Service Mesh Extension will implicitly define mutual authentication to the services in a namespace with the key/value label of `istio-injection: enabled`.

For example:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-infra
  labels:
    istio-injection: enabled
```

# [Istio AKS Add-on](#tab/istio-aks-add-on)
Unlike open-source Istio which uses `istio-injection=enabled`, the Istio AKS add-on uses the revision label (istio.io/rev) corresponding to the installed Istio version (e.g., asm-1-28, asm-1-27).

ALB Controller Service Mesh Extension will implicitly define mutual authentication to services part of a namespace with the key/value label of `istio.io/rev: asm-<version>`.

You can obtain the Istio version via Kubectl:

```bash
kubectl get configmap -n aks-istio-system | grep asm-
```

Which will output the following:

```
istio-asm-1-27                        2      90m
istio-sidecar-injector-asm-1-27       2      90m
```

Or Azure CLI:

```azurecli
az aks show --resource-group <rg> --name <cluster> --query "serviceMeshProfile"
```

Which will yield:

```json
{
  "istio": {
    "certificateAuthority": null,
    "components": {
      "egressGateways": null,
      "ingressGateways": [
        {
          "enabled": null,
          "mode": "Internal"
        },
        {
          "enabled": null,
          "mode": "External"
        }
      ]
    },
    "revisions": [
      "asm-1-27"
    ]
  },
  "mode": "Istio"
}
```

In both examples, `asm-1-27` is the version of Istio installed.

To configure sidecar injection, define the following using the Istio version for your environment:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-infra
  labels:
    istio.io/rev: asm-1-27 # Istio version obtained previously
```

---

#### Enable mTLS handling for services in the namespace

In this example, we define a `PeerAuthentication` Istio custom resource to require mTLS for incoming connections to the services in the `test-infra` namespace.

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: test-infra
spec:
  mtls:
    mode: STRICT
```

Note

Istio supports different modes to handle the behavior of mutual authentication. In Application Gateway for Containers' implementation, mTLS will always be enforced for services that are part of the namespace with the `istio-injection` or `istio.io/rev` label. If you wish to proxy traffic via clear-text or TLS, don't define the `istio-injection: enabled` or `istio.io/rev: asm-<version>` label on the namespace and Application Gateway for Containers will proxy traffic to the backend via the defined configuration in HTTPRoute and BackendTLSPolicy resources accordingly.

#### Deploy a sample application (optional)

In this step, we provision some test resources so we can validate the end-to-end scenario. If you have your own application, you can skip this step.

Apply the following deployment.yaml file on your cluster to create a sample web application to demonstrate sending traffic to an application part of the Istio service mesh.

```bash
kubectl apply -f https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/refs/heads/main/articles/application-gateway/for-containers/examples/traffic-split-scenario/deployment.yaml
```

This command creates the following on your cluster:

- A namespace called `test-infra`
- Two services called `backend-v1` and `backend-v2` in the `test-infra` namespace
- Two deployments called `backend-v1` and `backend-v2` in the `test-infra` namespace

#### Define Gateway resource

# [ALB managed deployment](#tab/alb-managed)
Create a gateway:

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-namespace: alb-test-infra
    alb.networking.azure.io/alb-name: alb-test
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
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
2. Create a Gateway

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: gateway-01
      namespace: test-infra
      annotations:
        alb.networking.azure.io/alb-id: $RESOURCE_ID
    spec:
      gatewayClassName: azure-alb-external
      listeners:
      - name: http
        port: 80
        protocol: HTTP
        allowedRoutes:
          namespaces:
            from: All
      addresses:
      - type: alb.networking.azure.io/alb-frontend
        value: $FRONTEND_NAME
    EOF
    ```

---

Once the gateway resource is created, ensure the status is valid, the listener is *Programmed*, and an address is assigned to the gateway.

```bash
kubectl get gateway gateway-01 -n test-infra -o yaml
```

Example output of successful gateway creation.

```yaml
status:
  addresses:
  - type: Hostname
    value: xxxx.yyyy.alb.azure.com
  conditions:
  - lastTransitionTime: "2023-06-19T21:04:55Z"
    message: Valid Gateway
    observedGeneration: 1
    reason: Accepted
    status: "True"
    type: Accepted
  - lastTransitionTime: "2023-06-19T21:04:55Z"
    message: Application Gateway For Containers resource has been successfully updated.
    observedGeneration: 1
    reason: Programmed
    status: "True"
    type: Programmed
  listeners:
  - attachedRoutes: 0
    conditions:
    - lastTransitionTime: "2023-06-19T21:04:55Z"
      message: ""
      observedGeneration: 1
      reason: ResolvedRefs
      status: "True"
      type: ResolvedRefs
    - lastTransitionTime: "2023-06-19T21:04:55Z"
      message: Listener is accepted
      observedGeneration: 1
      reason: Accepted
      status: "True"
      type: Accepted
    - lastTransitionTime: "2023-06-19T21:04:55Z"
      message: Application Gateway For Containers resource has been successfully updated.
      observedGeneration: 1
      reason: Programmed
      status: "True"
      type: Programmed
    name: gateway-01-http
    supportedKinds:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
```

#### Define HTTPRoute resource

Once the gateway is created, create an HTTPRoute

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-split-mesh-route
  namespace: test-infra
spec:
  parentRefs:
  - name: gateway-01
    namespace: test-infra
  rules:
  - backendRefs:
    - name: backend-v1
      port: 8080
EOF
```

Once the HTTPRoute resource is created, ensure the route is *Accepted* and the Application Gateway for Containers resource is *Programmed*.

```bash
kubectl get httproute traffic-split-mesh-route -n test-infra -o yaml
```

Verify the status of the Application Gateway for Containers resource has been successfully updated.

```yaml
status:
  parents:
  - conditions:
    - lastTransitionTime: "2023-06-19T22:18:23Z"
      message: ""
      observedGeneration: 1
      reason: ResolvedRefs
      status: "True"
      type: ResolvedRefs
    - lastTransitionTime: "2023-06-19T22:18:23Z"
      message: Route is Accepted
      observedGeneration: 1
      reason: Accepted
      status: "True"
      type: Accepted
    - lastTransitionTime: "2023-06-19T22:18:23Z"
      message: Application Gateway For Containers resource has been successfully updated.
      observedGeneration: 1
      reason: Programmed
      status: "True"
      type: Programmed
    controllerName: alb.networking.azure.io/alb-controller
    parentRef:
      group: gateway.networking.k8s.io
      kind: Gateway
      name: gateway-01
      namespace: test-infra
```

#### Test access to the application

Now we're ready to send some traffic to our sample application, via the FQDN assigned to the frontend. Use the following command to get the FQDN:

```bash
fqdn=$(kubectl get gateway gateway-01 -n test-infra -o jsonpath='{.status.addresses[0].value}')
```

Curling this FQDN should return responses from the backends/pods as configured on the HTTPRoute.

```bash
curl http://$fqdn
```

Next, let's delete the PeerAuthentication resource to simulate removal of mTLS.

```bash
kubectl delete PeerAuthentication default -n test-infra
```

When you run the curl command again, you should see a 503 HTTP response code, indicating failure of mTLS negotiation between Application Gateway for Containers and the test application (as the test application is no longer expecting mutual authentication).

## Pricing

There's no extra price to enable service mesh integration.

## Limitations

- Ingress API isn't supported; consider migrating to Gateway API.