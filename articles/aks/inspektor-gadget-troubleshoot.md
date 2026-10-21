---
layout: Conceptual
title: Troubleshoot the Inspektor Gadget extension on AKS (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/inspektor-gadget-troubleshoot
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
description: Troubleshoot common installation, configuration, and runtime errors with the Inspektor Gadget cluster extension on Azure Kubernetes Service (AKS).
author: mqasimsarfraz
ms.author: qasimsarfraz
ms.date: 2026-07-14T00:00:00.0000000Z
ms.topic: troubleshooting
ai-usage: ai-assisted
locale: en-us
document_id: 04d477da-2819-c4c8-9f74-3d700fd8a35d
document_version_independent_id: f4f62807-bae5-7936-1104-a3aa167f91d5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/inspektor-gadget-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,bash
toc_rel: toc.json
asset_id: aks/inspektor-gadget-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/inspektor-gadget-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4a73171f-a93b-8850-4492-0b2f83e0a97e
---

# Troubleshoot the Inspektor Gadget extension on AKS (preview) - Azure Kubernetes Service | Microsoft Learn

This article covers common error messages and failures you might encounter when you install, update, or use the [Inspektor Gadget](https://go.microsoft.com/fwlink/?LinkId=2260072) cluster extension on Azure Kubernetes Service (AKS). Each section follows a **Symptom → Cause → Resolution** format.

For installation instructions, see [Install and configure the Inspektor Gadget extension on AKS](inspektor-gadget-configure).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Diagnose the extension

The Inspektor Gadget extension deploys a DaemonSet named `gadget` into the `gadget` namespace on every worker node. Most failures surface through the extension status, the underlying Helm release, or the eBPF runtime on the node. When the extension reports a failure, start by inspecting its status and the state of the workload on the cluster.

Inspect the extension status:

```azurecli
az k8s-extension show \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget
```

The error message is captured in the `message` property of the `statuses[]` array in the output, and usually mirrors a Helm or Kubernetes API error.

Inspect the underlying workload on the cluster:

```bash
kubectl get pods -n gadget -o wide
kubectl describe daemonset -n gadget gadget
kubectl logs -n gadget -l k8s-app=gadget --tail=200
```

## Installation fails with a Helm rendering or value error

**Symptom:** The extension reports a status with code `InstallationFailed` and a message that contains a Helm template error, such as `executing "gadget/templates/..." at <.Values.inspektor-gadget.config.xxx>`.

**Cause:** A `--configuration-settings` key passed to `az k8s-extension create` doesn't match a value that the chart supports. The AKS extension uses an umbrella Helm chart that includes the Inspektor Gadget chart as a sub-chart aliased `inspektor-gadget`. Every value that targets Inspektor Gadget must be prefixed with `inspektor-gadget.`. The sub-chart splits configuration in two:

- Root-level keys configure Kubernetes resources, for example `inspektor-gadget.image`, `inspektor-gadget.nodeSelector`, and `inspektor-gadget.hostPID`.
- Keys under `config` configure the Inspektor Gadget runtime, for example `inspektor-gadget.config.daemonLogLevel` and `inspektor-gadget.config.hookMode`.

A common mistake is omitting the `inspektor-gadget.` prefix, or setting runtime options at the root level instead of under `config`.

**Resolution:**

1. Validate the key against the documented configuration options for the extension version you're installing.
2. If the previous installation left the release in a failed state, delete the extension before you retry:

    ```azurecli
    az k8s-extension delete \
        --cluster-type managedClusters \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name inspektor-gadget \
        --yes
    ```
3. Reissue the command with the corrected key, for example `inspektor-gadget.config.daemonLogLevel=info`.

## Installation fails to resolve the extension version

**Symptom:** The `az k8s-extension create` command fails with `ExtensionOperationFailed` and a message like `Failed to resolve the extension version from the given values ... does not support release train 'preview' for version '0.53.0'. Please try again with release train "stable".`

**Cause:** The `--release-train` and `--version` values don't match. The requested version isn't published on the release train you specified, so the version can't be resolved.

**Resolution:**

1. Install without specifying a version so the extension resolves the latest version on the release train automatically:

    ```azurecli
    az k8s-extension create \
        --cluster-type managedClusters \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name inspektor-gadget \
        --extension-type microsoft.inspektorgadget \
        --release-train preview
    ```
2. If you need a specific version, use the release train that publishes it. List the supported versions for the extension type on your cluster, then retry with a matching version and release train:

    ```azurecli
    az k8s-extension extension-types list-versions-by-cluster \
        --cluster-type managedClusters \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --extension-type microsoft.inspektorgadget \
        --release-train preview
    ```

## Installation fails because the gadget namespace contains conflicting resources

**Symptom:** Installation fails with a message similar to `rendered manifests contain a resource that already exists ... invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "gadget"`.

**Cause:** Inspektor Gadget was previously deployed by using `kubectl gadget deploy` or a different Helm release name, and wasn't fully removed before you installed the AKS extension.

**Resolution:**

1. If a previous `kubectl gadget deploy` is still installed, remove it:

    ```bash
    kubectl gadget undeploy
    ```
2. Otherwise, clean up any resources left in the `gadget` namespace manually:

    ```bash
    kubectl delete namespace gadget
    kubectl delete clusterrole gadget-cluster-role --ignore-not-found
    kubectl delete clusterrolebinding gadget-cluster-role-binding --ignore-not-found
    kubectl delete clusterimagepolicy gadget-image-policy --ignore-not-found
    ```
3. Retry the extension installation. For more information, see [Uninstalling from the cluster](https://go.microsoft.com/fwlink/?LinkId=2370530) in the Inspektor Gadget documentation.

## Gadget pods are stuck in ImagePullBackOff or ErrImagePull

**Symptom:** Pods in the `gadget` namespace fail to start and show `ImagePullBackOff` or `ErrImagePull`.

**Cause:** The cluster can't reach `mcr.microsoft.com` because of an egress firewall, a private cluster without an outbound rule, or a proxy that isn't configured on the nodes. Alternatively, a custom image supplied through `inspektor-gadget.image.repository` or `inspektor-gadget.image.tag` points to a private registry without a valid pull secret.

**Resolution:**

1. Identify the exact image and error by describing the failing pod, and review the **Events** section:

    ```bash
    kubectl describe pod -n gadget <gadget-pod-name>
    ```
2. For the default Microsoft Artifact Registry (MCR) image, verify that nodes can reach `mcr.microsoft.com`. If the cluster uses a user-defined outbound route, such as a private cluster with Azure Firewall, ensure that `mcr.microsoft.com` and `*.data.mcr.microsoft.com` are allowed in the egress rules. For more information, see [Outbound network and FQDN rules for AKS clusters](outbound-rules-control-egress).
3. For a custom private registry, create a pull secret in the `gadget` namespace and reference it in the extension configuration:

    ```bash
    kubectl create secret docker-registry gadget-pull-secret \
        --namespace gadget \
        --docker-server=<registry-server> \
        --docker-username=<username> \
        --docker-password=<password>
    ```

    ```azurecli
    az k8s-extension update \
        --cluster-type managedClusters \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name inspektor-gadget \
        --configuration-settings "inspektor-gadget.imagePullSecrets[0]=gadget-pull-secret"
    ```

## Installation fails with no matches for kind PodMonitor

**Symptom:** The extension reports a status with code `InstallationFailed` and a message similar to:

```output
unable to build kubernetes objects from release manifest: resource mapping not found for name: "inspektor-gadget" namespace: "gadget" from "": no matches for kind "PodMonitor" in version "azmonitoring.coreos.com/v1"
```

**Cause:** You installed the extension with `azureMonitor.enabled=true`. This setting creates a `PodMonitor` custom resource to export gadget metrics to Azure Monitor managed Prometheus. The `PodMonitor` CRD (`azmonitoring.coreos.com/v1`) is only available when the Azure Monitor metrics add-on is enabled on the cluster. If the add-on isn't enabled, Kubernetes can't find the CRD and the Helm release fails.

**Resolution:**

- **Option A – Enable Azure Monitor metrics on the cluster.** Enable the Azure Monitor managed Prometheus add-on so the `PodMonitor` CRD is registered, and then retry the extension installation:

    ```azurecli
    az aks update \
         --resource-group myResourceGroup \
         --name myAKSCluster \
         --enable-azure-monitor-metrics
    ```
- **Option B – Disable the Azure Monitor integration.** If you don't need the managed Prometheus integration, for example because you run your own Prometheus instance, set `azureMonitor.enabled` to `false`:

    ```azurecli
    az k8s-extension create \
         --cluster-type managedClusters \
         --cluster-name myAKSCluster \
         --resource-group myResourceGroup \
         --name inspektor-gadget \
         --extension-type microsoft.inspektorgadget \
         --release-train preview \
         --configuration-settings "azureMonitor.enabled=false"
    ```

    If the previous installation left the release in a failed state, delete the extension before you retry:

    ```azurecli
    az k8s-extension delete \
         --cluster-type managedClusters \
         --cluster-name myAKSCluster \
         --resource-group myResourceGroup \
         --name inspektor-gadget \
         --yes
    ```

    Tip

    When you use your own Prometheus instance, configure a scrape job that targets pods in the `gadget` namespace with the label `k8s-app=gadget` on port `2224` and path `/metrics`.

## Gadget pods crash on startup with eBPF or BTF errors

**Symptom:** The DaemonSet pods enter `CrashLoopBackOff`, and the logs include lines such as `no BTF found for kernel version` or `field <X> is not a known kernel type`.

**Cause:** Inspektor Gadget requires a Linux kernel with [BTF](https://www.kernel.org/doc/html/latest/bpf/btf.html) enabled and at least Linux 5.10. Individual gadgets might require newer kernel features beyond the 5.10 baseline.

**Resolution:**

1. Verify the kernel version on each node:

    ```bash
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.kernelVersion}{"\n"}{end}'
    ```
2. Check whether BTF is enabled on a node. If the `/sys/kernel/btf/vmlinux` file exists, BTF is enabled:

    ```bash
    kubectl debug node/<node-name> -it --image=mcr.microsoft.com/cbl-mariner/base/core:2.0 -- ls /sys/kernel/btf/vmlinux
    ```
3. If the kernel version is below the minimum that the gadget requires, upgrade the AKS node image or the node pool Kubernetes version to one that ships a newer kernel. See [Upgrade Azure Kubernetes Service (AKS) node images](upgrade-node-image).

## Gadget pods are stuck in Pending due to Azure Policy

**Symptom:** The DaemonSet pods stay in `Pending` state. The pod events show a denial from an admission webhook, such as `admission webhook "validation.gatekeeper.sh" denied the request: Privileged container is not allowed`.

**Cause:** An Azure Policy initiative, for example the **Kubernetes cluster should not allow privileged containers** policy, is assigned to the cluster or subscription and blocks the `gadget` DaemonSet from scheduling. The DaemonSet requires privileged access and the `SYS_ADMIN`, `SYS_PTRACE`, `SYS_RESOURCE`, `NET_ADMIN`, `NET_RAW`, and `IPC_LOCK` Linux capabilities to load eBPF programs and inspect host-level kernel events.

**Resolution:**

1. Create an Azure Policy exemption that excludes the `gadget` namespace from the restrictive policy assignment.
2. After the exemption is in place, delete the stuck pods so the DaemonSet recreates them:

    ```bash
    kubectl delete pods -n gadget --all
    ```

## kubectl gadget commands return a version skew error

**Symptom:** Running `kubectl gadget run ...` returns errors such as `version mismatch`, `unknown field`, or gRPC decode errors.

**Cause:** The `kubectl-gadget` client plugin and the in-cluster DaemonSet must be the exact same version. There's no supported cross-version compatibility.

**Resolution:**

1. Find the version deployed in the cluster:

    ```bash
    kubectl get daemonset -n gadget gadget -o jsonpath='{.spec.template.spec.containers[0].image}'
    ```
2. Install or upgrade the `kubectl-gadget` client to the matching version by using [Krew](https://krew.sigs.k8s.io/):

    ```bash
    kubectl krew install gadget
    kubectl krew upgrade gadget
    ```
3. Confirm that both sides match:

    ```bash
    kubectl gadget version
    ```

Note

If you configure the extension with auto-upgrade enabled, the cluster-side DaemonSet version might advance automatically. Pin the `kubectl-gadget` client to the same minor version to avoid unexpected skew.

## Image signature verification fails when running gadgets

**Symptom:** Pulling or running a gadget fails with `the image was not signed by the provided keys: crypto/rsa: verification error`.

**Cause:** The gadget image isn't signed with the public key that the Inspektor Gadget daemon trusts, or the key configured through `inspektor-gadget.config.operator.oci.public-keys` doesn't match the key used to sign the image. Recent versions enable image verification by default.

**Resolution:**

- Use official gadget images from `mcr.microsoft.com/oss/v2/inspektor-gadget/gadget/...`, which are signed with the project key and trusted by default.
- If you run gadgets from your own registry, sign them with your key and add the corresponding public key under `inspektor-gadget.config.operator.oci.public-keys` in the extension configuration. See [Verifying gadget images](https://go.microsoft.com/fwlink/?LinkId=2370721).

Warning

As a temporary workaround only, you can disable image verification by setting `inspektor-gadget.config.operator.oci.verify-image=false`. This isn't recommended for production because it allows running unsigned or tampered gadget images.

## Gadgets run but produce no output

**Symptom:** You deploy and run Inspektor Gadget, but `kubectl gadget run ...` returns empty output or misses events for specific workloads.

**Cause:** The daemon's container hook mode doesn't match the container runtime on the nodes. The gadget command is scoped to a namespace or pod selector that excludes the target workload. The gadget requires an eBPF feature that the node kernel doesn't provide.

**Resolution:**

1. Verify the container runtime on the nodes:

    ```bash
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.containerRuntimeVersion}{"\n"}{end}'
    ```
2. AKS nodes use containerd by default, so use `hookMode=auto` or `hookMode=podinformer`. If the nodes use CRI-O, configure the hook mode explicitly:

    ```azurecli
    az k8s-extension update \
        --cluster-type managedClusters \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name inspektor-gadget \
        --configuration-settings "inspektor-gadget.config.hookMode=crio"
    ```
3. Make sure you aren't unintentionally scoping the gadget to a namespace that excludes the target pods. Use `--all-namespaces`, or specify the correct namespace with `--namespace <namespace>`.
4. Check the daemon log for skipped or unsupported programs:

    ```bash
    kubectl logs -n gadget -l k8s-app=gadget --tail=500 | grep -i "skip\|unsupported\|error"
    ```

## Gadget fails to export data to a backend

**Symptom:** A gadget that exports data, such as `profile_cuda`, runs but repeatedly logs an export error. The daemon logs show entries similar to:

```output
{"gadget":"profile_cuda:v0.53.0","instanceName":"gpu-memory-profiles","level":"error","msg":"emitting and releasing \"allocs\" data: rpc error: code = Unavailable desc = name resolver error: produced zero addresses","type":"gadget-log"}
```

**Cause:** The gadget is configured to export to a backend, such as Pyroscope for profiles or an OpenTelemetry collector for metrics, but the backend isn't deployed or isn't reachable. The `produced zero addresses` message means the export endpoint's DNS name didn't resolve to any address.

**Resolution:**

1. Confirm that the target backend is deployed and that its service exists in the expected namespace:

    ```bash
    kubectl get service --all-namespaces | grep -i "pyroscope\|otel\|collector"
    ```
2. Verify that the export endpoint configured for the gadget matches the backend's service name, namespace, and port.
3. Deploy the missing backend, or update the gadget configuration to point to a reachable endpoint, then rerun the gadget. The errors stop once the endpoint resolves.

## Gadget pods don't schedule on virtual nodes

**Symptom:** Installation succeeds, but the DaemonSet pods don't schedule on virtual nodes. Gadgets return no events for workloads running there.

**Cause:** Inspektor Gadget runs as a privileged DaemonSet that loads eBPF programs directly on the host Linux kernel. Topologies where the node isn't a real Linux host, such as [virtual nodes](virtual-nodes) backed by Azure Container Instances, aren't supported.

**Resolution:** Use a node selector so the DaemonSet targets only standard Linux node pools and not virtual nodes:

```azurecli
az k8s-extension update \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --configuration-settings "inspektor-gadget.nodeSelector.kubernetes\.azure\.com\/agentpool=<nodepool-name>"
```

For more complex selectors or affinity rules, supply a values file with `--configuration-settings-file`.

## Uninstalling the extension leaves stale resources

**Symptom:** After you remove the extension, some resources remain in the cluster, such as `ClusterImagePolicy/gadget-image-policy`, user-provided `SeccompProfile` resources, or the `gadget` namespace itself.

**Cause:** The chart doesn't delete cluster-scoped or user-owned resources on uninstall, to prevent data loss.

**Resolution:** Manually clean up the remaining resources:

```bash
kubectl delete clusterimagepolicy gadget-image-policy --ignore-not-found
kubectl delete seccompprofile --all -n gadget --ignore-not-found
kubectl delete namespace gadget --ignore-not-found
```

Note

The `ClusterImagePolicy` CRD is only present when the [Image Integrity](/en-us/azure/aks/image-integrity) feature is enabled on the cluster. If you receive a `no matches for kind "ClusterImagePolicy"` error, you can safely ignore it.

## Collect diagnostics for a support request

Before you open a support request or a GitHub issue, collect the following diagnostic information.

Extension status:

```azurecli
az k8s-extension show \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --output json > extension.json
```

Cluster-side state, node inventory, and client version:

```bash
kubectl get all -n gadget -o yaml > gadget-resources.yaml
kubectl describe daemonset -n gadget gadget > gadget-daemonset.txt
kubectl get events -n gadget --sort-by='.lastTimestamp' > gadget-events.txt
kubectl logs -n gadget -l k8s-app=gadget --all-containers --tail=2000 > gadget-logs.txt
kubectl get nodes -o wide > nodes.txt
kubectl gadget version > version.txt 2>&1
```