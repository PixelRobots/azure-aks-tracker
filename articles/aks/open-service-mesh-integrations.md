---
layout: Conceptual
title: Integrations with Open Service Mesh on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-integrations
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
description: Integrations with Open Service Mesh on Azure Kubernetes Service (AKS)
ms.topic: concept-article
ms.date: 2025-11-10T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-networking
locale: en-us
document_id: 271d5432-449b-9957-fa1d-1cbeb4ef0dc0
document_version_independent_id: b5567dcd-c4fa-f8ce-6fc0-b8c92efd317e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-integrations.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/open-service-mesh-integrations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-integrations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ec8041e7-8c22-6767-bb46-da90bcdf72aa
---

# Integrations with Open Service Mesh on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

The Open Service Mesh (OSM) add-on integrates with features provided by Azure and some open source projects.

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Integrations with open source projects aren't covered by the [AKS support policy](support-policies).

## Ingress

Ingress allows for traffic external to the mesh to be routed to services within the mesh. With OSM, you can configure most ingress solutions to work with your mesh, but OSM works best with one of the following solutions:

- [Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview)
- [Application Routing](app-routing)
- [NGINX ingress](https://release-v1-0.docs.openservicemesh.io/docs/demos/ingress_k8s_nginx/)
- [Contour ingress](https://release-v1-0.docs.openservicemesh.io/docs/guides/traffic_management/ingress/#1-using-contour-ingress-controller-and-gateway)

### Use the Azure Application Gateway for Containers with the OSM add-on for HTTP ingress

#### Create a namespace and deploy the application service

1. [Deploy Application Gateway for Containers' ALB Controller](/en-us/azure/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller).
2. [Create Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller) resource
3. Create a namespace for the application service using the `kubectl create ns` command.

    ```console
    kubectl create ns httpbin
    ```
4. Add the namespace to the mesh using the `osm namespace add` OSM CLI command.

    ```console
    osm namespace add httpbin
    ```
5. Deploy the application service to the namespace using the `kubectl apply` command.

    ```console
    export RELEASE_BRANCH=release-v1.2
    kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/$RELEASE_BRANCH/manifests/samples/httpbin/httpbin.yaml -n httpbin
    ```
6. Verify the pods are up and running and have the envoy sidecar injected using the `kubectl get pods` command.

    ```console
    kubectl get pods -n httpbin
    ```

    Your output should look similar to the following example output:

    ```output
    NAME                      READY   STATUS    RESTARTS   AGE
    httpbin-7c6464475-9wrr8   2/2     Running   0          6d20h
    ```
7. List the details of the service using the `kubectl get svc` command.

    ```console
    kubectl get svc -n httpbin
    ```

    Your output should look similar to the following example output:

    ```output
    NAME      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)     AGE
    httpbin   ClusterIP   10.0.92.135   <none>        14001/TCP   6d20h
    ```

#### Deploy the ingress configurations and verify access to the application service

1. Deploy the following `Gateway`, `HTTPRoute`, and `IngressBackend` configurations to allow external clients to access the `httpbin` service on port `14001` using the `kubectl apply` command.

    ```console
    kubectl apply -f <<EOF
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: gateway-01
      namespace: httpbin
      annotations:
        alb.networking.azure.io/alb-namespace: <alb-namespace>
        alb.networking.azure.io/alb-name: <alb-name>
    spec:
      gatewayClassName: azure-alb-external
      listeners:
      - name: httpbin-listener
        port: 80
        protocol: HTTP
        allowedRoutes:
          namespaces:
            from: Same
    ---
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: httpbin-route
      namespace: httpbin
    spec:
      parentRefs:
      - name: gateway-01
      rules:
      - backendRefs:
        - name: httpbin
          port: 14001
    ---
    kind: IngressBackend
    apiVersion: policy.openservicemesh.io/v1alpha1
    metadata:
      name: httpbin
      namespace: httpbin
    spec:
      backends:
     - name: httpbin
        port:
          number: 14001 # targetPort of httpbin service
          protocol: http
      sources:
     - kind: IPRange
        name: 10.0.0.0/8
    EOF
    ```
2. Verify the `Gateway` and `HTTPRoute` resources were successfully deployed using the `kubectl get gateway` and `kubectl get httproute` commands. Make note of the external fully qualified domain name on the Gateway resource.

    ```console
    # Gateway resource
    kubectl get gateway gateway-01 -n test-infra -o yaml
    # HTTPRoute resource
    kubectl get httproute contoso-route -n test-infra -o yaml
    ```

    Your `Gateway` output should look similar to the following example output:

    ```output
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
        name: https-listener
        supportedKinds:
        - group: gateway.networking.k8s.io
          kind: HTTPRoute
    ```
3. Verify the `IngressBackend` object was successfully deployed using the `kubectl get ingressbackend` command.

    ```console
    kubectl get ingressbackend -n httpbin
    ```

    Your output should look similar to the following example output:

    ```output
    NAME      STATUS
    httpbin   committed
    ```
4. Verify you can access the `httpbin` service using the external IP address of the ingress service and the following `curl` command.

    ```console
    fqdn=$(kubectl get gateway gateway-01 -n httpbin -o jsonpath='{.status.addresses[0].value}')
    curl -sI http://$fqdn/get
    ```
5. Confirm you receive a response with `status 200`.

## Metrics observability

Metrics observability allows you to view the metrics of your mesh and the deployments in your mesh. With OSM, you can use [Prometheus and Grafana](https://release-v1-0.docs.openservicemesh.io/docs/guides/observability/metrics/) for metrics observability, but those integrations aren't covered by the [AKS support policy](support-policies).

You can also integrate OSM with [Azure Monitor](/en-us/azure/azure-monitor/overview).

Before you can enable metrics on your mesh to integrate with Azure Monitor, make sure you have the following prerequisites:

- Enable Azure Monitor on your cluster.
- Enable the OSM add-on for your AKS cluster.
- Onboard your application namespaces to the mesh.

1. Enable metrics for a namespace in the mesh using the `osm metrics enable` command.

    ```console
    osm metrics enable --namespace myappnamespace
    ```
2. Create a ConfigMap in the `kube-system` namespace that enables Azure Monitor to monitor your namespaces. For example, create a `monitor-configmap.yaml` with the following contents to monitor the `myappnamespace`:

    ```yaml
    kind: ConfigMap
    apiVersion: v1
    data:
      schema-version: v1
      config-version: ver1
      osm-metric-collection-configuration: |-
        # OSM metric collection settings
        [osm_metric_collection_configuration]
          [osm_metric_collection_configuration.settings]
              # Namespaces to monitor
              monitor_namespaces = ["myappnamespace"]
    metadata:
      name: container-azm-ms-osmconfig
      namespace: kube-system
    ```
3. Apply the ConfigMap using the `kubectl apply` command.

    ```console
    kubectl apply -f monitor-configmap.yaml
    ```
4. Navigate to the Azure portal and select your AKS cluster.
5. Under **Monitoring**, select **Logs**.
6. In the **Monitoring** section, query the `InsightsMetrics` table to view metrics in the enabled namespaces. For example, the following query shows the *envoy* metrics for the *default* namespace:

    ```sh
    InsightsMetrics
    |     where Name contains "envoy"
    |     extend t=parse_json(Tags)
    |     where t.namespace == "default"
    ```

## Automation and developer tools

OSM can integrate with certain automation projects and developer tooling to help operators and developers build and release applications. For example, OSM integrates with [Flagger](https://release-v1-0.docs.openservicemesh.io/docs/guides/integrations/flagger/) for progressive delivery and [Dapr](https://release-v1-0.docs.openservicemesh.io/docs/guides/integrations/dapr/) for building applications. The OSM integrations with Flagger and Dapr aren't covered by the [AKS support policy](support-policies).

## External authorization

External authorization allows you to offload authorization of HTTP requests to an external service. OSM can use external authorization by integrating with [Open Policy Agent (OPA)](https://release-v1-0.docs.openservicemesh.io/docs/guides/integrations/external_auth_opa/), but that integration isn't covered by the [AKS support policy](support-policies).

## Certificate management

OSM has several types of certificates it uses to operate on your AKS cluster. OSM includes its own certificate manager called [Tresor](https://release-v1-0.docs.openservicemesh.io/docs/guides/certificates/#using-osms-tresor-certificate-issuer), which is used by default. Alternatively, OSM allows you to integrate with [Hashicorp Vault](https://release-v1-0.docs.openservicemesh.io/docs/guides/certificates/#using-hashicorp-vault) and [cert-manager](https://release-v1-0.docs.openservicemesh.io/docs/guides/certificates/#using-cert-manager), but those integrations aren't covered by the [AKS support policy](support-policies).