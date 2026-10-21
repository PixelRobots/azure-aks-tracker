---
layout: Conceptual
title: Troubleshoot the Open Service Mesh (OSM) add-on for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-troubleshoot
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
description: How to troubleshoot the Open Service Mesh (OSM) add-on for Azure Kubernetes Service (AKS).
ms.topic: troubleshooting
ms.subservice: aks-networking
ms.date: 2024-09-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: a2d1fb00-4a8a-f254-59e8-fadbceaaa052
document_version_independent_id: 3e33f262-bba9-8cd8-54ca-3b7b09a642a1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/open-service-mesh-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 14936b2e-d361-71c7-94f2-6c9507c452f2
---

# Troubleshoot the Open Service Mesh (OSM) add-on for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

When you deploy the Open Service Mesh (OSM) add-on for Azure Kubernetes Service (AKS), you may experience problems associated with the service mesh configuration. The article explores common troubleshooting errors and how to resolve them.

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Verifying and troubleshooting OSM components

### Check OSM Controller deployment, pod, and service

- Check the OSM Controller deployment, pod, and service health using the `kubectl get deployment,pod,service` command.

    ```azurecli
    kubectl get deployment,pod,service -n kube-system --selector app=osm-controller
    ```

    A healthy OSM controller gives an output similar to the following example output:

    ```output
    NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/osm-controller   2/2     2            2           3m4s
    
    NAME                                  READY   STATUS    RESTARTS   AGE
    pod/osm-controller-65bd8c445c-zszp4   1/1     Running   0          2m
    pod/osm-controller-65bd8c445c-xqhmk   1/1     Running   0          16s
    
    NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                       AGE
    service/osm-controller   ClusterIP   10.96.185.178   <none>        15128/TCP,9092/TCP,9091/TCP   3m4s
    service/osm-validator    ClusterIP   10.96.11.78     <none>        9093/TCP                      3m4s
    ```

    Note

    For the `osm-controller` services, the CLUSTER-IP is different. The service NAME and PORT(S) must be the same as the example output.

### Check OSM Injector deployment, pod, and service

- Check the OSM Injector deployment, pod, and service health using the `kubectl get deployment,pod,service` command.

    ```azurecli
    kubectl get deployment,pod,service -n kube-system --selector app=osm-injector
    ```

    A healthy OSM Injector gives an output similar to the following example output:

    ```output
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/osm-injector   2/2     2            2           4m37s
    
    NAME                                READY   STATUS    RESTARTS   AGE
    pod/osm-injector-5c49bd8d7c-b6cx6   1/1     Running   0          4m21s
    pod/osm-injector-5c49bd8d7c-dx587   1/1     Running   0          4m37s
    
    NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/osm-injector   ClusterIP   10.96.236.108   <none>        9090/TCP   4m37s
    ```

### Check OSM Bootstrap deployment, pod, and service

- Check the OSM Bootstrap deployment, pod, and service health using the `kubectl get deployment,pod,service` command.

    ```azurecli
    kubectl get deployment,pod,service -n kube-system --selector app=osm-bootstrap
    ```

    A healthy OSM Bootstrap gives an output similar to the following example output:

    ```output
    NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/osm-bootstrap   1/1     1            1           5m25s
    
    NAME                                 READY   STATUS    RESTARTS   AGE
    pod/osm-bootstrap-594ffc6cb7-jc7bs   1/1     Running   0          5m25s
    
    NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
    service/osm-bootstrap   ClusterIP   10.96.250.208   <none>        9443/TCP,9095/TCP   5m25s
    ```

### Check validating and mutating webhooks

1. Check the OSM Validating Webhook using the `kubectl get ValidatingWebhookConfiguration` command.

    ```azurecli
    kubectl get ValidatingWebhookConfiguration --selector app=osm-controller
    ```

    A healthy OSM Validating Webhook gives an output similar to the following example output:

    ```output
    NAME              WEBHOOKS   AGE
    aks-osm-validator-mesh-osm   1      81m
    ```
2. Check the OSM Mutating Webhook using the `kubectl get MutatingWebhookConfiguration` command.

    ```azurecli
    kubectl get MutatingWebhookConfiguration --selector app=osm-injector
    ```

    A healthy OSM Mutating Webhook gives an output similar to the following example output:

    ```output
    NAME              WEBHOOKS   AGE
    aks-osm-webhook-osm   1      102m
    ```

### Check for the service and CA bundle of the Validating Webhook

- Check for the service and CA bundle of the OSM Validating Webhook using the `kubectl get ValidatingWebhookConfiguration` command with `aks-osm-validator-mesh-osm` and `jq '.webhooks[0].clientConfig.service'`.

    ```azurecli
    kubectl get ValidatingWebhookConfiguration aks-osm-validator-mesh-osm -o json | jq '.webhooks[0].clientConfig.service'
    ```

    A well-configured Validating Webhook configuration looks like the following example JSON output:

    ```json
    {
      "name": "osm-config-validator",
      "namespace": "kube-system",
      "path": "/validate-webhook",
      "port": 9093
    }
    ```

### Check for the service and CA bundle of the Mutating webhook

- Check for the service and CA bundle of the OSM Mutating Webhook using the `kubectl get MutatingWebhookConfiguration` command with `aks-osm-validator-mesh-osm` and `jq '.webhooks[0].clientConfig.service'`.

    ```azurecli
    kubectl get MutatingWebhookConfiguration aks-osm-webhook-osm -o json | jq '.webhooks[0].clientConfig.service'
    ```

    A well-configured Mutating Webhook configuration looks like the following example JSON output:

    ```json
    {
      "name": "osm-injector",
      "namespace": "kube-system",
      "path": "/mutate-pod-creation",
      "port": 9090
    }
    ```

### Check the `osm-mesh-config` resource

1. Check the OSM MeshConfig resource exists using the `kubectl get meshconfig` command.

    ```azurecli
    kubectl get meshconfig osm-mesh-config -n kube-system
    ```
2. Check the contents of the OSM MeshConfig resource using the `kubectl get meshconfig` command with `-o yaml`.

    ```azurecli
    kubectl get meshconfig osm-mesh-config -n kube-system -o yaml
    ```

    ```output
    apiVersion: config.openservicemesh.io/v1alpha1
    kind: MeshConfig
    metadata:
      creationTimestamp: "0000-00-00A00:00:00A"
      generation: 1
      name: osm-mesh-config
      namespace: kube-system
      resourceVersion: "2494"
      uid: 6c4d67f3-c241-4aeb-bf4f-b029b08faa31
    spec:
      certificate:
        serviceCertValidityDuration: 24h
      featureFlags:
        enableEgressPolicy: true
        enableMulticlusterMode: false
        enableWASMStats: true
      observability:
        enableDebugServer: true
        osmLogLevel: info
        tracing:
          address: jaeger.kube-system.svc.cluster.local
          enable: false
          endpoint: /api/v2/spans
          port: 9411
      sidecar:
        configResyncInterval: 0s
        enablePrivilegedInitContainer: false
        envoyImage: mcr.microsoft.com/oss/envoyproxy/envoy:v1.18.3
        initContainerImage: mcr.microsoft.com/oss/openservicemesh/init:v0.9.1
        logLevel: error
        maxDataPlaneConnections: 0
        resources: {}
      traffic:
        enableEgress: true
        enablePermissiveTrafficPolicyMode: true
        inboundExternalAuthorization:
          enable: false
          failureModeAllow: false
          statPrefix: inboundExtAuthz
          timeout: 1s
        useHTTPSIngress: false
    ```

#### `osm-mesh-config` resource values

| Key | Type | Default Value | Kubectl Patch Command Examples |
| --- | --- | --- | --- |
| spec.traffic.enableEgress | bool | `true` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"enableEgress":true}}}'  --type=merge` |
| spec.traffic.enablePermissiveTrafficPolicyMode | bool | `true` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"enablePermissiveTrafficPolicyMode":true}}}'  --type=merge` |
| spec.traffic.useHTTPSIngress | bool | `false` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"useHTTPSIngress":true}}}'  --type=merge` |
| spec.traffic.outboundPortExclusionList | array | `[]` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"outboundPortExclusionList":[6379,8080]}}}'  --type=merge` |
| spec.traffic.outboundIPRangeExclusionList | array | `[]` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"outboundIPRangeExclusionList":["10.0.0.0/32","1.1.1.1/24"]}}}'  --type=merge` |
| spec.traffic.inboundPortExclusionList | array | `[]` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"inboundPortExclusionList":[6379,8080]}}}'  --type=merge` |
| spec.certificate.serviceCertValidityDuration | string | `"24h"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"certificate":{"serviceCertValidityDuration":"24h"}}}'  --type=merge` |
| spec.observability.enableDebugServer | bool | `true` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"observability":{"enableDebugServer":true}}}'  --type=merge` |
| spec.observability.tracing.enable | bool | `false` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"observability":{"tracing":{"enable":true}}}}'  --type=merge` |
| spec.observability.tracing.address | string | `"jaeger.kube-system.svc.cluster.local"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"observability":{"tracing":{"address": "jaeger.kube-system.svc.cluster.local"}}}}'  --type=merge` |
| spec.observability.tracing.endpoint | string | `"/api/v2/spans"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"observability":{"tracing":{"endpoint":"/api/v2/spans"}}}}'  --type=merge' --type=merge` |
| spec.observability.tracing.port | int | `9411` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"observability":{"tracing":{"port":9411}}}}'  --type=merge` |
| spec.observability.tracing.osmLogLevel | string | `"info"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"observability":{"tracing":{"osmLogLevel": "info"}}}}'  --type=merge` |
| spec.sidecar.enablePrivilegedInitContainer | bool | `false` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"enablePrivilegedInitContainer":true}}}'  --type=merge` |
| spec.sidecar.logLevel | string | `"error"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"logLevel":"error"}}}'  --type=merge` |
| spec.sidecar.maxDataPlaneConnections | int | `0` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"maxDataPlaneConnections":"error"}}}'  --type=merge` |
| spec.sidecar.envoyImage | string | `"mcr.microsoft.com/oss/envoyproxy/envoy:v1.19.1"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"envoyImage":"mcr.microsoft.com/oss/envoyproxy/envoy:v1.19.1"}}}'  --type=merge` |
| spec.sidecar.initContainerImage | string | `"mcr.microsoft.com/oss/openservicemesh/init:v0.11.1"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"initContainerImage":"mcr.microsoft.com/oss/openservicemesh/init:v0.11.1"}}}' --type=merge` |
| spec.sidecar.configResyncInterval | string | `"0s"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"configResyncInterval":"30s"}}}'  --type=merge` |
| spec.featureFlags.enableWASMStats | bool | `"true"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableWASMStats":"true"}}}'  --type=merge` |
| spec.featureFlags.enableEgressPolicy | bool | `"true"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableEgressPolicy":"true"}}}'  --type=merge` |
| spec.featureFlags.enableMulticlusterMode | bool | `"false"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableMulticlusterMode":"false"}}}'  --type=merge` |
| spec.featureFlags.enableSnapshotCacheMode | bool | `"false"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableSnapshotCacheMode":"false"}}}'  --type=merge` |
| spec.featureFlags.enableAsyncProxyServiceMapping | bool | `"false"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableAsyncProxyServiceMapping":"false"}}}'  --type=merge` |
| spec.featureFlags.enableIngressBackendPolicy | bool | `"true"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableIngressBackendPolicy":"true"}}}'  --type=merge` |
| spec.featureFlags.enableEnvoyActiveHealthChecks | bool | `"false"` | `kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"featureFlags":{"enableEnvoyActiveHealthChecks":"false"}}}'  --type=merge` |

### Check namespaces

Note

The `kube-system` namespace never participates in a service mesh and is never labeled and/or annotated with the following key/values.

The `osm namespace add` command allows you to join namespaces to a given service mesh. When you want a K8s namespace to be part of the mesh, it must have the following annotation and label.

1. View the annotations using the `kubectl get namespace` command with `jq '.metadata.annotations'`.

    ```azurecli
    kubectl get namespace bookbuyer -o json | jq '.metadata.annotations'
    ```

    You must see the following annotation in the output:

    ```output
    {
      "openservicemesh.io/sidecar-injection": "enabled"
    }
    ```
2. View the labels using the `kubectl get namespaces` command with `jq '.metadata.labels'`.

    ```azurecli
    kubectl get namespace bookbuyer -o json | jq '.metadata.labels'
    ```

    You must see the following label in the output:

    ```output
    {
      "openservicemesh.io/monitored-by": "osm"
    }
    ```

If a namespace doesn't have the `"openservicemesh.io/sidecar-injection": "enabled"` annotation or the `"openservicemesh.io/monitored-by": "osm"` label, the OSM Injector doesn't add Envoy sidecars.

Note

After `osm namespace add` is called, only **new** pods are injected with an Envoy sidecar. Existing pods must be restarted with `kubectl rollout restart deployment ...`

### Verify OSM CRDs

1. Check the cluster has the required CRDs using the `kubectl get crds` command.

    ```azurecli
    kubectl get crds
    ```

    The following CRDs must be installed on the cluster:

    - egresses.policy.openservicemesh.io
    - httproutegroups.specs.smi-spec.io
    - ingressbackends.policy.openservicemesh.io
    - meshconfigs.config.openservicemesh.io
    - multiclusterservices.config.openservicemesh.io
    - tcproutes.specs.smi-spec.io
    - trafficsplits.split.smi-spec.io
    - traffictargets.access.smi-spec.io
2. Get the versions of the SMI CRDs installed using the `osm mesh list` command.

    ```azurecli
    osm mesh list
    ```

    Your output should look similar to the following example output:

    ```output
    MESH NAME   MESH NAMESPACE   VERSION   ADDED NAMESPACES
    osm         kube-system      v0.11.1
    
    MESH NAME   MESH NAMESPACE   SMI SUPPORTED
    osm         kube-system      HTTPRouteGroup:v1alpha4,TCPRoute:v1alpha4,TrafficSplit:v1alpha2,TrafficTarget:v1alpha3
    
    To list the OSM controller pods for a mesh, please run the following command passing in the mesh's namespace
            kubectl get pods -n <osm-mesh-namespace> -l app=osm-controller
    ```

    OSM Controller v0.11.1 requires the following versions:

    - traffictargets.access.smi-spec.io - [v1alpha3](https://github.com/servicemeshinterface/smi-spec/blob/v0.6.0/apis/traffic-access/v1alpha3/traffic-access.md)
    - httproutegroups.specs.smi-spec.io - [v1alpha4](https://github.com/servicemeshinterface/smi-spec/blob/v0.6.0/apis/traffic-specs/v1alpha4/traffic-specs.md#httproutegroup)
    - tcproutes.specs.smi-spec.io - [v1alpha4](https://github.com/servicemeshinterface/smi-spec/blob/v0.6.0/apis/traffic-specs/v1alpha4/traffic-specs.md#tcproute)
    - udproutes.specs.smi-spec.io - Not supported
    - trafficsplits.split.smi-spec.io - [v1alpha2](https://github.com/servicemeshinterface/smi-spec/blob/v0.6.0/apis/traffic-split/v1alpha2/traffic-split.md)
    - \*.metrics.smi-spec.io - [v1alpha1](https://github.com/servicemeshinterface/smi-spec/blob/v0.6.0/apis/traffic-metrics/v1alpha1/traffic-metrics.md)

### Certificate management

For more information on how OSM issues and manages certificates to Envoy proxies running on application pods, see the [OSM certificates guide](https://docs.openservicemesh.io/docs/guides/certificates/).

### Upgrading Envoy

When you create a new pod in a namespace monitored by the add-on, OSM injects an [Envoy proxy sidecar](https://docs.openservicemesh.io/docs/guides/app_onboarding/sidecar_injection/) in that pod. For more information on how to update the Envoy version, see the [OSM upgrade guide](https://docs.openservicemesh.io/docs/getting_started/).