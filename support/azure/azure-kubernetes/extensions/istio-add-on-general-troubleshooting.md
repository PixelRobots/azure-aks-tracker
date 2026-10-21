---
layout: Conceptual
title: General Istio Service Mesh Add-on Troubleshooting - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: nshankar13
ms.author: nshankar
ms.topic: troubleshooting
description: Troubleshoot the Istio service mesh add-on in Azure Kubernetes Service (AKS) by using proven steps and fixes to address common mesh errors quickly.
ms.date: 2025-03-18T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: fuyuanbie, shasb, kochhars, ddama, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 2b4d8011-6d6e-f93e-1c57-8c109e1bec0b
document_version_independent_id: 2b4d8011-6d6e-f93e-1c57-8c109e1bec0b
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 33e3321b-bc1d-d3d9-ebc8-e1f92cd0dfad
---

# General Istio Service Mesh Add-on Troubleshooting - Azure | Microsoft Learn

## Summary

This article discusses general strategies (that use `kubectl`, `istioctl`, and other tools) to troubleshoot issues that are related to the Istio service mesh add-on for Microsoft Azure Kubernetes Service (AKS). This article also provides a list of possible error messages, reasons for error occurrences, and recommendations to resolve these errors.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool to connect to the cluster

    **Note:** To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The Istio [istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/) command-line tool
- The Client URL ([cURL](https://curl.se)) tool

## Troubleshooting checklist: using kubectl

The following troubleshooting steps use various `kubectl` commands to help you debug stuck pods or failures in the Istio daemon (Istiod).

### Step 1: Get Istiod pod logs

Get the Istiod pod logs by running the following [kubectl logs](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/) command:

```bash
kubectl logs --selector app=istiod --namespace aks-istio-system
```

### Step 2: Bounce (delete) a pod

You might have a good reason to restart a pod. Because Istiod is a deployment, you can safely delete the pod by running the [kubectl delete](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_delete/) command:

```bash
kubectl delete pods <istio-pod> --namespace aks-istio-system
```

The Istio pod is managed by a deployment. It's automatically re-created and redeployed after you delete it directly. Therefore, deleting the pod is an alternative method for restarting the pod.

Note

You can also restart the deployment directly by running the following [kubectl rollout restart](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/kubectl_rollout_restart/) command:

```bash
kubectl rollout restart deployment <istiod-asm-revision> --namespace aks-istio-system
```

### Step 3: Check the status of resources

If Istiod isn't scheduled, or if the pod isn't responding, you might want to check the status of the deployment and the replica sets. To do this step, run the [kubectl get](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command:

```bash
kubectl get <resource-type> [[--selector app=istiod] | [<resource-name>]]
```

The current resource status appears near the end of the output. The output might also display events that are associated with its controller loop.

### Step 4: Get custom resource definition types

To view the types of custom resource definitions (CRDs) that Istio uses, run the `kubectl get` command:

```bash
kubectl get crd | grep istio
```

To list all the resource names that are based on a particular CRD, run the following `kubectl get` command:

```bash
kubectl get <crd-type> --all-namespaces
```

### Step 5: View the list of Istiod pods

To view the list of Istiod pods, run the following `kubectl get` command:

```bash
kubectl get pod --namespace aks-istio-system --output yaml
```

### Step 6: Get more information about the Envoy configuration

If you have connectivity issues between pods, get more information about the Envoy configuration by running the following [kubectl exec](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/) command against Envoy's admin port:

```bash
kubectl exec --namespace <pod-namespace> \
    "$(kubectl get pods \
        --namespace <pod-namespace> \
        --selector app=sleep \
        --output jsonpath='{.items[0].metadata.name}')" \
    --container sleep \
-- curl -s localhost:15000/clusters
```

### Step 7: Get the sidecar logs for the source and destination sidecars

Retrieve the sidecar logs for the source and destination sidecars by running the following `kubectl logs` command two times (the first time for the source pod, and the second time for the destination pod):

```bash
kubectl logs <pod-name> --namespace <pod-namespace> --container istio-proxy
```

## Troubleshooting checklist: using istioctl

The following troubleshooting steps discuss how to collect information and debug your mesh environment by running various `istioctl` commands.

All `istioctl` commands must be run together with the `--istioNamespace aks-istio-system` flag to point to the AKS add-on installation of Istio.

Warning

Some `istioctl` commands send requests to all sidecars.

Note

Before you begin, notice that most `istioctl` commands require you to know the control plane revision. You can get this information from the suffix of either the Istiod deployments or the pods, or you can run the following [istioctl tag list](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-tag-list) command:

`istioctl tag list`

### Step 1: Make sure that Istio is installed correctly

To verify that you have a correct Istio add-on installation, run the following [istioctl verify-install](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-verify-install) command:

```bash
istioctl verify-install --istioNamespace aks-istio-system --revision <tag>
```

### Step 2: Analyze namespaces

To analyze all namespaces, or to analyze a specific namespace, run the following [istioctl analyze](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-analyze) command:

```bash
istioctl analyze --istioNamespace aks-istio-system \
    --revision <tag> \
    [--all-namespaces | --namespace <namespace-name>] \
    [--failure-threshold {Info | Warning | Error}]
```

### Step 3: Get the proxy status

To retrieve the proxy status, run the following [istioctl proxy-status](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-status) command:

```bash
istioctl proxy-status pod/<pod-name> \
    --istioNamespace aks-istio-system \
    --revision <tag> \
    --namespace <pod-namespace>
```

### Step 4: Download the proxy configuration

To download the proxy configuration, run the following [istioctl proxy-config all](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-all) command:

```bash
istioctl proxy-config all <pod-name> \
    --istioNamespace aks-istio-system \
    --namespace <pod-namespace> \
    --output json
```

Note

Instead of using the `all` variant of the `istioctl proxy-config` command, you can use one of the following variants:

- [istioctl proxy-config ecds](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-ecds) (extension configuration discovery service)
- [istioctl proxy-config bootstrap](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-bootstrap)
- [istioctl proxy-config cluster](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-cluster)
- [istioctl proxy-config endpoint](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-endpoint)
- [istioctl proxy-config listener](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-listener)
- [istioctl proxy-config log](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-log)
- [istioctl proxy-config route](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-route)
- [istioctl proxy-config secret](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-proxy-config-secret)

### Step 5: Check the injection status

To check the injection status of the resource, run the following `istioctl experimental check-inject` command:

```bash
istioctl experimental check-inject --istioNamespace aks-istio-system \
    --namespace <pod-namespace> \
    --labels <label-selector> | <pod-name> | deployment/<deployment-name>
```

### Step 6: Get a full bug report

A full bug report contains the most detailed information. However, running this report can be time-consuming on a large cluster because it includes all pods. You can limit the bug report to certain namespaces. You can also limit the report to certain deployments, pods, or label selectors.

To retrieve a bug report, run the following [istioctl bug-report](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-bug-report) command:

```bash
istioctl bug-report --istioNamespace aks-istio-system \
    [--include <namespace-1>[, <namespace-2>[, ...]]]
```

## Troubleshooting checklist: miscellaneous issues

### Step 1: Fix resource usage issues

If you encounter high memory consumption in Envoy, double-check your Envoy settings for [statistics data collection](https://istio.io/latest/docs/ops/configuration/telemetry/envoy-stats/). If you're [customizing Istio metrics](https://istio.io/latest/docs/tasks/observability/metrics/customize-metrics/) through [MeshConfig](istio-add-on-meshconfig), remember that certain metrics can have [high cardinality](https://istio.io/latest/about/faq/metrics-and-logs/#metric-expiry) and, therefore, create a higher memory footprint. Other fields in MeshConfig, such as concurrency, affect CPU usage and should be configured carefully.

By default, Istio adds information about all services that are in the cluster to every Envoy configuration. The [sidecar](https://istio.io/latest/docs/reference/config/networking/sidecar/) can limit the scope of this addition to workloads that are within specific namespaces only. For more information, see [Watch out for this Istio proxy sidecar memory pitfall](https://medium.com/geekculture/watch-out-for-this-istio-proxy-sidecar-memory-pitfall-8dbd99ea7e9d).

For example, the following `Sidecar` definition in the `aks-istio-system` namespace restricts the Envoy configuration for all proxies across the mesh to `aks-istio-system`, and other workloads within the same namespace as that specific application:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Sidecar
metadata:
  name: sidecar-restrict-egress
  namespace: aks-istio-system  # Needs to be deployed in the root namespace.
spec:
  egress:
  - hosts:
    - "./*"
    - "aks-istio-system/*"
```

You can also try to use the Istio [discoverySelectors](https://istio.io/latest/blog/2021/discovery-selectors/) option in [MeshConfig](istio-add-on-meshconfig#step-5-fix-memory-consumption-issues). The `discoverySelectors` option contains an array of Kubernetes selectors, and it can restrict Istiod's awareness to specific namespaces (as opposed to all namespaces in the cluster). For more information, see [Use discovery selectors to configure namespaces for your Istio service mesh](https://istio.io/v1.14/blog/2021/discovery-selectors/).

### Step 2: Fix traffic and security misconfiguration issues

To address common traffic management and security misconfiguration issues that Istio users frequently encounter, see [Traffic management problems](https://istio.io/latest/docs/ops/common-problems/network-issues/) and [Security problems](https://istio.io/latest/docs/ops/common-problems/security-issues/) on the Istio website.

For links to discussion about other issues, such as sidecar injection, observability, and upgrades, see [Common problems](https://istio.io/latest/docs/ops/common-problems/) on the Istio documentation site.

#### Verify AuthorizationPolicy evaluation rules

When you apply multiple authorization policies to a particular workload, consider the order in which Istio processes the different access control types. For more information, see the [Istio Authorization Policy documentation](https://istio.io/latest/docs/reference/config/security/authorization-policy/)

### Step 3: Verify protocol selection

Although Istio can automatically detect any TCP-based protocol, in certain cases, the protocol in the `Service` spec may have to be [explicitly declared](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/) in order to unblock communication issues. To make this declaration, set the protocol in the port `name` or in `appProtocol`. In this case, `appProtocol` takes precedence. For instance, certain scenarios might require you to set the protocol to `tcp` in order to proxy traffic as raw TCP, as opposed to HTTP or HTTPS.

### Step 4: Avoid CoreDNS overload

Issues that relate to CoreDNS overload might require that you change certain Istio DNS settings, such as the `dnsRefreshRate` field in the Istio MeshConfig definition.

### Step 5: Fix pod and sidecar race conditions

If your application pod starts before the Envoy sidecar starts, the application might become unresponsive, or it might restart. For instructions to avoid this problem, see [Pod or containers start with network issues if istio-proxy is not ready](https://istio.io/latest/docs/ops/common-problems/injection/#pod-or-containers-start-with-network-issues-if-istio-proxy-is-not-ready). Specifically, setting the `holdApplicationUntilProxyStarts` MeshConfig field under `defaultConfig` to `true` can help prevent these race conditions.

### Step 6: Verify OutboundTrafficPolicy mode and Service Entry configuration for outbound access

Issues that relate to outbound access or [egress gateways](istio-add-on-egress-gateway) might occur because of certain Istio configurations that pertain to external service configuration. Verify whether the `outboundTrafficPolicy.mode` is set to `REGISTRY_ONLY` in either the [Shared MeshConfig](istio-add-on-meshconfig) or `Sidecar` custom resources. If it is, then a `ServiceEntry` must be explicitly declared for external service to enable outbound access. When you use egress gateways, the resolution for the ServiceEntry must be set to `DNS`.

Also, remember that `ServiceEntries` is exported across all namespaces by default. To restrict the scope of a `ServiceEntry` to a particular namespace, use the `exportTo` field in the [spec](https://istio.io/latest/docs/reference/config/networking/service-entry/#ServiceEntry-export_to).

### Step 7: Configure a Service Entry when using an HTTP proxy for outbound traffic

If your cluster uses an HTTP proxy for outbound internet access, you have to configure a Service Entry. For more information, see [HTTP proxy support in Azure Kubernetes Service](/en-us/azure/aks/http-proxy#istio-add-on-http-proxy-for-external-services).

### Step 8: Enable Envoy access logging

You can enable [access logging](https://istio.io/latest/docs/tasks/observability/logs/access-log/) for Envoy to help identify and pinpoint issues in the gateways and sidecar proxies. For more information about logging and telemetry collection for the Istio add-on, see the documentation on [mesh configuration](/en-us/azure/aks/istio-meshconfig), [Telemetry API](/en-us/azure/aks/istio-telemetry), and [Istio metrics collection](/en-us/azure/aks/istio-metrics-managed-prometheus).

## Error messages

The following table contains a list of possible error messages (for deploying the add-on, enabling ingress gateways, and performing upgrades), the reason why an error occurs, and recommendations to resolve the error.

| Error | Reason | Recommendations |
| --- | --- | --- |
| `Azure service mesh is not supported in this region` | The feature isn't available in the region during preview (it's available in the public cloud but not the sovereign cloud). | Refer to public documentation about the feature on supported regions. |
| `Missing service mesh mode: {}` | You didn't set the mode property in the service mesh profile of the managed cluster request. | In the [ServiceMeshProfile](/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-arm-template#servicemeshprofile-1) field of the `managedCluster` API request, set the `mode` property to `Istio`. |
| `Invalid istio ingress mode: {}` | You set an invalid value for the ingress mode when adding ingress within the service mesh profile. | Set the ingress mode in the API request to either `External` or `Internal`. |
| `Too many ingresses for type: {}. Only {} ingress gateway are allowed` | You tried to create too many ingresses on the cluster. | Create, at most, one external ingress and one internal ingress on the cluster. |
| `Istio profile is missing even though Service Mesh mode is Istio` | You enabled the Istio add-on without providing the Istio profile. | When you enable the Istio add-on, specify component-specific (ingress gateway, plug-in CA) information for the Istio profile and the particular revision. |
| `Istio based Azure service mesh is incompatible with feature %s` | You tried to use another extension, add-on, or feature that's currently incompatible with the Istio add-on (for example, Open Service Mesh). | Before you enable the Istio add-on, disable the other feature first and clean up all corresponding resources. |
| `ServiceMeshProfile is missing required parameters: %s for plugin certificate authority` | You didn't provide all the required parameters for plug-in CA. | Provide all required parameters for the plug-in certificate authority (CA) feature (for more information, see [Set up Istio-based service mesh add-on with plug-in CA certificates](/en-us/azure/aks/istio-plugin-ca#set-up-istio-based-service-mesh-addon-with-plug-in-ca-certificates)). |
| `AzureKeyvaultSecretsProvider addon is required for Azure Service Mesh plugin certificate authority feature` | You didn't enable the AKS Secrets-Store CSI Driver add-on before you used the plug-in CA. | [Set up Azure Key Vault](/en-us/azure/aks/istio-plugin-ca#set-up-azure-key-vault) before you use the plug-in CA feature. |
| `'KeyVaultId': '%s' is not a valid Azure keyvault resource identifier. Please make sure that the format matches '/subscriptions//resourceGroups//providers/Microsoft.KeyVault/vaults/'` | You used an invalid AKS resource ID. | See the format that's mentioned in the error message to set a valid Azure Key Vault ID for the plug-in CA feature. |
| `Kubernetes version is missing in orchestrator profile` | Your request is missing the Kubernetes version. Therefore, it can't do a version compatibility check. | Make sure that you provide the Kubernetes version in Istio add-on upgrade operations. |
| `Service mesh revision %s is not compatible with cluster version %s. To find information about mesh-cluster compatibility, use 'az aks mesh get-upgrades'` | You tried to enable an Istio add-on revision that's incompatible with the current Kubernetes cluster version. | Use the [az aks mesh get-upgrades](/en-us/cli/azure/aks/mesh#az-aks-mesh-get-upgrades) Azure CLI command to learn which Istio add-on revisions are available for the current cluster. |
| `Kubernetes version %s not supported. Please upgrade to a supported cluster version first. To find compatibility information, use 'az aks mesh get-upgrades'` | You're using an unsupported Kubernetes version. | [Upgrade to a supported Kubernetes version](/en-us/azure/aks/upgrade-cluster). |
| `ServiceMeshProfile revision field must not be empty` | You tried to upgrade the Istio add-on without specifying a revision. | Specify the revision and all other parameters (for more information, see [Minor revision upgrade](/en-us/azure/aks/istio-upgrade#minor-revision-upgrade)). |
| `Request exceeds maximum allowed number of revisions (%d)` | You tried to do an upgrade operation even though there are already `(%d)` revisions installed. | [Complete or roll back the upgrade operation](/en-us/azure/aks/istio-upgrade#minor-revision-upgrade) before you upgrade to another revision. |
| `Mesh upgrade is in progress. Please complete or roll back the current upgrade before attempting to retrieve versioning and compatibility information` | You tried to access revisioning and compatibility information before completing or rolling back the current upgrade operation. | [Complete or roll back the current upgrade operation](/en-us/azure/aks/istio-upgrade#minor-revision-upgrade) before you retrieve revisioning and compatibility information. |

## References

- For general tips about Istio debugging, see [Istio diagnostic tools](https://istio.io/latest/docs/ops/diagnostic-tools/)
- [Istio service mesh add-on MeshConfig troubleshooting](istio-add-on-meshconfig)
- [Istio service mesh add-on ingress gateway troubleshooting](istio-add-on-ingress-gateway)
- [Istio service mesh add-on minor revision upgrade troubleshooting](istio-add-on-minor-revision-upgrade)
- [Istio service mesh add-on plug-in CA certificate troubleshooting](istio-add-on-plug-in-ca-certificate)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.