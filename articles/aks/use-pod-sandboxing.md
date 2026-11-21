---
layout: Conceptual
title: Pod sandboxing with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-pod-sandboxing
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to deploy Pod sandboxing on an Azure Kubernetes Service (AKS) cluster to isolate workloads in lightweight pod virtual machines (VMs) for stronger compute isolation.
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli, build-2023
zone_pivot_groups: pod-sandboxing-runtime-class
ms.date: 2026-11-17T00:00:00.0000000Z
author: allyford
ms.author: allyford
ai-usage: ai-assisted
locale: en-us
document_id: 4d02652c-0561-5da7-df0b-e4bea13a97b8
document_version_independent_id: 8a559b86-f35b-13be-16f9-31c9ab01c451
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-pod-sandboxing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-pod-sandboxing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-pod-sandboxing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0cd1644d-bf1b-47b0-0fb6-9f7dee133a4e
---

# Pod sandboxing with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Pod sandboxing on AKS uses Kata Containers to run each sandboxed pod in a lightweight virtual machine (VM) with its own guest kernel. This compute boundary isolates the workload from the host kernel and workloads in other pod VMs. To learn about the architecture, benefits, and use cases, see [Overview of Pod sandboxing in Azure Kubernetes Service (AKS)](concepts-pod-sandboxing).

In this article, you deploy Pod sandboxing on a new or existing Azure Linux AKS cluster, deploy an application with the Kata runtime, and optionally verify kernel isolation.

For clusters that use node auto-provisioning (NAP), follow Use Pod sandboxing with node auto-provisioning instead of the Azure CLI node pool creation steps.

Deploying Pod sandboxing by using Kata Containers is similar to the standard `runc` workflow to deploy containers. Clusters with Pod sandboxing enabled come with a specific runtime class that you can reference in a pod manifest, [`runtimeClassName: kata-vm-isolation` (GA)](/en-us/azure/aks/use-pod-sandboxing?pivots=kata-vm-isolation#deploy-an-application-with-the-kata-runtime) or [`runtimeClassName: kata-vm-isolation-v2` (preview)](/en-us/azure/aks/use-pod-sandboxing?pivots=kata-vm-isolation-v2-preview#use-kata-vm-isolation-v2-preview). For more information about runtime class defaults and customization, see [Considerations for Pod sandboxing](considerations-pod-sandboxing).

::: zone pivot="kata-vm-isolation"

## Limitations

The following constraints apply to Pod sandboxing with `kata-vm-isolation`:

- Kata containers might not reach the IOPS performance limits that traditional containers can reach on Azure Files and high-performance local SSD.
- [Microsoft Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-introduction) doesn't support assessing Kata runtime pods.
- [Kata host-network access](https://github.com/kata-containers/kata-containers/blob/main/docs/Limitations.md#host-network) isn't supported. You can't directly access host networking configuration from within the pod VM.
- CPU and memory allocation differs from `runc`. Each Kata pod runs in a pod VM whose size comes from pod limits:
- Pod sandboxing is supported only on Azure Linux. Ubuntu, Windows, and Azure Container Linux aren't supported. For more information, see [Azure Linux container host for AKS](use-azure-linux).
- You can't enable [Federal Information Processing Standard (FIPS)](enable-fips-nodes) or [Trusted Launch](use-trusted-launch) on a node pool that uses Pod sandboxing.
- Arm64 architecture isn't supported on a node pool that uses Pod sandboxing.

## Prerequisites

- The Azure CLI version 2.80.0 or later. Run `az --version` to find the version of your Azure CLI, and run `az upgrade` to upgrade. For more details, see the steps at [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- AKS supports Pod sandboxing on Kubernetes version 1.27.0 and higher. NAP-provisioned Pod sandboxing nodes require Kubernetes version 1.32 or later and Azure Linux 3.
- To manage a Kubernetes cluster, use the Kubernetes command-line client [`kubectl`](https://kubernetes.io/docs/reference/kubectl/). Azure Cloud Shell comes with `kubectl`. You can install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

::: zone-end

::: zone pivot="kata-vm-isolation-v2-preview"

## Limitations

The following constraints apply to Pod sandboxing with `kata-vm-isolation-v2`:

- `kata-vm-isolation-v2` is in preview. You must register the `KataVMIsolationV2Preview` feature flag and use Azure Linux node image version `202610.30.1` or later. Regional rollout can vary by region. For current availability, see the [AKS release tracker](https://releases.aks.azure.com/AKSRelease).
- Kata containers might not reach the IOPS performance limits that traditional containers can reach on Azure Files and high-performance local SSD.
- [Microsoft Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-introduction) doesn't support assessing Kata runtime pods.
- [Kata host-network access](https://github.com/kata-containers/kata-containers/blob/main/docs/Limitations.md#host-network) isn't supported. You can't directly access host networking configuration from within the pod VM.
- Runtime-class migration is an explicit workload change. Don't assume behavior is identical to `kata-vm-isolation` across all workload and storage patterns.
- For `emptyDir` volumes, explicitly set `medium: Memory` and `sizeLimit` in the pod spec. For more information, see [Pod sandboxing considerations](considerations-pod-sandboxing).
- CPU and memory sizing behavior can differ from `kata-vm-isolation` and `kata-vm-isolation-v2` when you initialize the template VM with the DaemonSet in Create sandboxed pods from a paused, preinitialized template VM (`kata-vm-isolation-v2` preview). After the template is initialized, each v2 pod receives a 2 GiB, 2 vCPU guest regardless of pod limits. For memory sizing and overhead details, see RuntimeClass memory overhead.
- Pod sandboxing is supported only on Azure Linux. Ubuntu, Windows, and Azure Container Linux aren't supported. For more information, see [Azure Linux container host for AKS](use-azure-linux).
- You can't enable [Federal Information Processing Standard (FIPS)](enable-fips-nodes) or [Trusted Launch](use-trusted-launch) on a node pool that uses Pod sandboxing.
- Arm64 architecture isn't supported on a node pool that uses Pod sandboxing.
- [Node auto-provisioning (NAP)](node-auto-provisioning) isn't supported with `kata-vm-isolation-v2`.

## Use kata-vm-isolation-v2 (preview)

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

The `kata-vm-isolation-v2` runtime class is available in preview. For its benefits and a comparison with v1, see [Runtime class v2 improvements](considerations-pod-sandboxing#runtime-class-v2-improvements). For memory sizing and overhead details, see [RuntimeClass memory overhead](considerations-pod-sandboxing#runtimeclass-memory-overhead).

Important

The node pool still uses `--workload-runtime KataVmIsolation` for both runtime classes. The v1/v2 choice is made in each workload manifest through `runtimeClassName`.

### Prerequisites for `kata-vm-isolation-v2`

Before you use `kata-vm-isolation-v2`, confirm all of the following prerequisites:

- The Azure CLI version 2.80.0 or later.
- `kubectl` is installed and configured for your cluster.
- The `KataVMIsolationV2Preview` feature is registered in your subscription.
- The cluster runs Kubernetes version 1.34.0 or later.
- The target Pod sandboxing node pool uses Azure Linux node image version `202610.30.1` or later. Regional rollout can vary by region. For current availability, see the [AKS release tracker](https://releases.aks.azure.com/AKSRelease).
- `kata-vm-isolation-v2` supports v6 and v7 VM SKUs in these families: Dasv6, Dadsv6, Dalsv6, Daldsv6, Easv6, Eadsv6, Falsv6, Fasv6, and Famsv6.

### Register the `KataVMIsolationV2Preview` feature flag

1. Register the `KataVMIsolationV2Preview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register \
      --namespace "Microsoft.ContainerService" \
      --name "KataVMIsolationV2Preview"
    ```
2. Verify the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show \
      --namespace "Microsoft.ContainerService" \
      --name "KataVMIsolationV2Preview"
    ```
3. When the status shows *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider by using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

::: zone-end

## Create a cluster with Pod sandboxing

Perform the following steps to deploy an Azure Linux AKS cluster using the Azure CLI.

1. Create an AKS cluster by running the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the following parameters:

::: zone pivot="kata-vm-isolation"

    | Parameter | Required value | Notes |
    | --- | --- | --- |
    | `--workload-runtime` | `KataVmIsolation` | Enables Pod sandboxing on the node pool. |
    | `--os-sku` | `AzureLinux` | Pod sandboxing supports only the Azure Linux OS SKU. |
    | `--node-vm-size` | A generation 2 VM size that supports nested virtualization | For example, use `Standard_D4ads_v6`. |
    | `--node-count` | `3` | Creates three nodes for this example. Adjust the value for your workload. |

::: zone-end

::: zone pivot="kata-vm-isolation-v2-preview"

    | Parameter | Required value | Notes |
    | --- | --- | --- |
    | `--workload-runtime` | `KataVmIsolation` | Enables Pod sandboxing on the node pool. |
    | `--os-sku` | `AzureLinux` | Pod sandboxing supports only the Azure Linux OS SKU. |
    | `--node-vm-size` | A generation 2 VM size that supports nested virtualization | For example, use `Standard_D4ads_v6`. |
    | `--node-count` | `3` | Creates three nodes for this example. Adjust the value for your workload. |

::: zone-end

    The following example creates a cluster named *myAKSCluster* with three nodes in *myResourceGroup*:

    ```azurecli
    az aks create \
        --name myAKSCluster \
        --resource-group myResourceGroup \
        --os-sku AzureLinux \
        --workload-runtime KataVmIsolation \
        --node-vm-size Standard_D4ads_v6 \
        --node-count 3 \
        --generate-ssh-keys
    ```
2. Run the following command to get access credentials for the Kubernetes cluster. Use the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command and replace the values for the cluster name and the resource group name.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
3. List all Pods in all namespaces by running the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pods --all-namespaces
    ```

## Enable Pod sandboxing on an existing cluster

# [standard node pool](#tab/standard-node-pool)
To use this feature with an existing AKS cluster, the following requirements must be met:

- The cluster runs Kubernetes version 1.27.0 or higher.
- Use the following command to enable Pod sandboxing by creating a node pool to host it.

1. Add a node pool to your AKS cluster by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the following parameters:

    | Parameter | Required value | Notes |
    | --- | --- | --- |
    | `--resource-group` | The resource group that contains the existing AKS cluster | For example, use `myResourceGroup`. |
    | `--cluster-name` | The name of the existing AKS cluster | For example, use `myAKSCluster`. |
    | `--name` | A unique node pool name | For example, use `nodepool2`. |
    | `--workload-runtime` | `KataVmIsolation` | Enables Pod sandboxing on the node pool. |
    | `--os-sku` | `AzureLinux` | Pod sandboxing supports only the Azure Linux OS SKU. |
    | `--node-vm-size` | A generation 2 VM size that supports nested virtualization | For example, use `Standard_D4ads_v6`. |
    | `--node-count` | `1` | Creates one node for this example. Adjust the value for your workload. |

    The following example adds a node pool to *myAKSCluster* with one node in *nodepool2* in the *myResourceGroup*:

    ```azurecli
    az aks nodepool add --cluster-name myAKSCluster --resource-group myResourceGroup --name nodepool2 --os-sku AzureLinux --workload-runtime KataVmIsolation --node-vm-size Standard_D4ads_v6 --node-count 1
    ```
2. Verify that the node pool was added successfully and that the Pod sandboxing node pool uses the expected workload runtime, OS SKU, and VM size.

    ```azurecli
    az aks show \
        --name myAKSCluster \
        --resource-group myResourceGroup \
        --query provisioningState \
        --output tsv
    ```

    ```azurecli
    az aks nodepool show \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name nodepool2 \
        --query "{workloadRuntime:workloadRuntime, osSku:osSku, vmSize:vmSize}" \
        --output table
    ```

    The cluster provisioning state should be `Succeeded`. The node pool output should show `KataVmIsolation`, `AzureLinux`, and the VM size you selected.

# [Node auto-provisioning node pool](#tab/nap-mode)
NAP supports pod sandboxing through the `spec.workloadRuntime` field on an `AKSNodeClass`. Use a Karpenter `NodePool` that references this class to provision nodes for Kata workloads, rather than creating an Azure CLI-managed node pool with `az aks nodepool add`.

#### Prerequisites for NAP

- Enable NAP on your cluster. For setup instructions, see [Enable node auto-provisioning](use-node-auto-provisioning).
- Use Kubernetes version 1.32 or later. NAP requires Azure Linux 3 for the Kata-enabled image.
- Set `imageFamily: AzureLinux` and `workloadRuntime: KataVmIsolation` on the `AKSNodeClass`. Don't enable FIPS or Trusted Launch.
- Allow compatible AMD64, generation 2 VM sizes in your `NodePool` requirements. Karpenter automatically filters for virtualization-capable sizes and selects the Kata-enabled image. You don't need to specify a VM size or add architecture and generation requirements to enable this filtering.

#### Configure a Kata node class and node pool

Create the NAP resources and verify the runtime class before you deploy a workload.

1. Save the following manifest as `kata-nap.yaml`. The `NodePool` references the Kata-enabled `AKSNodeClass`. The Cilium label and startup taint follow the [NAP node pool configuration](node-auto-provisioning-node-pools) for clusters that use Cilium.

    ```yaml
    apiVersion: karpenter.azure.com/v1beta1
    kind: AKSNodeClass
    metadata:
      name: kata
    spec:
      imageFamily: AzureLinux
      workloadRuntime: KataVmIsolation
    ---
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: kata
    spec:
      template:
        metadata:
          labels:
            kubernetes.azure.com/ebpf-dataplane: cilium
        spec:
          nodeClassRef:
            group: karpenter.azure.com
            kind: AKSNodeClass
            name: kata
          startupTaints:
            - key: node.cilium.io/agent-not-ready
              effect: NoExecute
              value: "true"
          requirements:
            - key: kubernetes.io/os
              operator: In
              values: ["linux"]
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]
    ```

    If your cluster doesn't use Cilium, omit the `kubernetes.azure.com/ebpf-dataplane: cilium` label and the `node.cilium.io/agent-not-ready` startup taint.
2. Apply the resources:

    ```bash
    kubectl apply -f kata-nap.yaml
    kubectl get aksnodeclass kata
    kubectl get nodepool kata
    ```
3. Verify that the AKS-managed `kata-vm-isolation` runtime class is available:

    ```bash
    kubectl get runtimeclass kata-vm-isolation -o yaml
    ```

    The runtime class specifies the `kubernetes.azure.com/kata-vm-isolation: "true"` scheduling selector. When you create a pod that references this runtime class, Kubernetes adds the selector and runtime overhead to the pod. Karpenter recognizes the selector when it provisions compatible nodes and accounts for runtime overhead during bin-packing. You don't need to add the Kata selector manually.

#### Deploy and verify a NAP-managed Kata workload

Deploy a pod that requests the Kata runtime to trigger provisioning.

1. Save the following manifest as `kata-nap-app.yaml`. Set resource requests and limits to account for your workload and the pod VM's guest components. For sizing guidance, see [Pod sandboxing considerations](considerations-pod-sandboxing).

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nap-isolated-pod
    spec:
      runtimeClassName: kata-vm-isolation
      containers:
        - name: kata
          image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
          command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5; done"]
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: "1"
              memory: 512Mi
    ```

    `runtimeClassName` is sufficient to select Kata-capable nodes. To target this specific Karpenter `NodePool`, optionally add the following to the pod specification:

    ```yaml
    nodeSelector:
      karpenter.sh/nodepool: kata
    ```
2. Apply the pod manifest and wait for the pod to become ready:

    ```bash
    kubectl apply -f kata-nap-app.yaml
    kubectl wait --for=condition=Ready pod/nap-isolated-pod --timeout=10m
    ```

    Karpenter provisions a compatible node if existing capacity can't accommodate the pod. Setting `workloadRuntime: KataVmIsolation` enables an additional runtime; standard pods can still run on the same node without VM isolation.
3. Verify that the pod runs on a Kata-enabled, NAP-managed node:

    ```bash
    kubectl get nodes -l 'karpenter.sh/nodepool=kata,kubernetes.azure.com/kata-vm-isolation=true'
    kubectl get pod nap-isolated-pod -o wide
    kubectl exec nap-isolated-pod -- uname -r
    kubectl get node "$(kubectl get pod nap-isolated-pod -o jsonpath='{.spec.nodeName}')" \
      -o jsonpath='{.status.nodeInfo.kernelVersion}{"\n"}'
    ```

    The pod's guest kernel differs from the node's host kernel. For another comparison using a standard pod, see Verify kernel isolation.

For field defaults, compatibility constraints, and the effect of changing the runtime on existing nodes, see [Workload runtime and Pod sandboxing](node-auto-provisioning-aksnodeclass#workload-runtime-and-pod-sandboxing).

::: zone pivot="kata-vm-isolation"

## Deploy applications using Pod sandboxing

By using Pod sandboxing, you can deploy a mix of standard pods that don't use the Kata runtime alongside Kata pods that use the runtime.

The runtime class selects the Kata runtime, but you should also define scheduling constraints when you need workloads to run on a specific Pod sandboxing node pool. For an Azure CLI-managed node pool, use the built-in AKS node pool label in a `nodeSelector`. Replace `nodepool2` with the name of your Pod sandboxing node pool. For a NAP-managed node pool, use `karpenter.sh/nodepool` instead, as shown in the NAP walkthrough.

```yaml
spec:
  runtimeClassName: kata-vm-isolation
  nodeSelector:
    kubernetes.azure.com/agentpool: nodepool2
```

For stronger separation, you can taint the Pod sandboxing node pool and add a matching toleration to Kata workloads. A taint without a matching toleration prevents other workloads from scheduling on that node pool. For more information, see [Use node taints in an AKS cluster](use-node-taints).

### Deploy an application with the Kata runtime

To deploy a pod with the Kata runtime on your AKS cluster, perform the following steps.

1. Create a file named *kata-app.yaml* to describe your Kata pod, and then paste the following manifest.

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: isolated-pod
    spec:
      runtimeClassName: kata-vm-isolation
      containers:
      - name: kata
        image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
        command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
    ```
2. Deploy the Kubernetes pod by running the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your *kata-app.yaml* file:

    ```bash
    kubectl apply -f kata-app.yaml
    ```

    The output of the command resembles the following example:

    ```output
    pod/isolated-pod created
    ```

::: zone-end

::: zone pivot="kata-vm-isolation-v2-preview"

## Deploy applications using Pod sandboxing

Use the following steps to run a new workload with `runtimeClassName: kata-vm-isolation-v2`. For an existing v1 workload, follow the migration instructions instead.

### Deploy an application with the Kata runtime (`kata-vm-isolation-v2`)

1. Confirm your target Pod sandboxing node pool is eligible (Kubernetes 1.34.0 or later and Azure Linux node image version `202610.30.1` or later).
2. Verify the runtime class and node label by using the steps in Verify the runtime class and node label.
3. Create a file named `kata-v2-app.yaml` with the following manifest.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: isolated-pod-v2
    spec:
      runtimeClassName: kata-vm-isolation-v2
      containers:
      - name: kata
        image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
        command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
    ```
4. Deploy the pod and verify that it uses the preview runtime class:

    ```bash
    kubectl apply -f kata-v2-app.yaml
    kubectl wait --for=condition=Ready pod/isolated-pod-v2 --timeout=120s
    kubectl get pod isolated-pod-v2 -o jsonpath='{.spec.runtimeClassName}'
    ```

    The last command should return `kata-vm-isolation-v2`.

Important

If you created a new cluster with a node pool that supports `--workload-runtime KataVmIsolation` , the runtimeclass should appear automatically. However, if you added a new node pool to an existing cluster, the reconciler might take a couple of minutes to update the cluster and add the `kata-vm-isolation-v2` runtimeclass.

### Create sandboxed pods from a paused, preinitialized template VM (`kata-vm-isolation-v2` preview)

`kata-vm-isolation-v2` creates new sandboxed pods by cloning from a paused, preinitialized template VM instead of cold-booting each pod VM.

Before you use this path, confirm the following limitations and requirements:

- The workload uses `runtimeClassName: kata-vm-isolation-v2`.
- The target node pool runs Azure Linux node image version `202610.30.1` or later. Regional rollout can vary by region. For current availability, see the [AKS release tracker](https://releases.aks.azure.com/AKSRelease).
- You initialize the template VM on each eligible node.
- In the current preview, the template path can use a fixed 2-GiB memory and 2-vCPU guest VM size after template initialization. Keep pod requests and limits aligned, and validate scheduling behavior for your workload.

Important

The init container runs kata-ctl factory init as root on the node, review with your security team before deploying.

To initialize the template VM on each node, you can use a DaemonSet such as the following:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kata-v2-factory-init
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: kata-v2-factory-init
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kata-v2-factory-init
    spec:
      automountServiceAccountToken: false
      hostPID: true
      nodeSelector:
        kubernetes.io/os: linux
        kubernetes.azure.com/kata-vm-isolation-v2: "true"
      initContainers:
        - name: factory-init
          image: mcr.microsoft.com/azurelinux/base/core:3.0
          command:
            - /bin/bash
            - -ec
            - |
              tdnf install -y util-linux
              exec /usr/bin/nsenter "$@"
            - kata-v2-factory-bootstrap
            - --target=1
            - --mount
            - --uts
            - --ipc
            - --net
            - --pid
            - --root=/proc/1/root
            - --wd=/
            - --
            - /bin/bash
            - -ec
            - |
              config=$1
              template=$2
              lock=$3
              test -r "$config"
              command -v kata-ctl >/dev/null
              exec 9>"$lock"
              flock --exclusive 9
              if test -f "$template/memory" &&
                 test -f "$template/state.json" &&
                 test -f "$template/config.json"; then
                printf 'Factory template already exists at %s\n' "$template"
                exit 0
              fi
              if mountpoint -q "$template" ||
                 { test -d "$template" && test -n "$(ls -A "$template")"; }; then
                printf 'Incomplete factory at %s; inspect and clean up manually before retrying.\n' "$template" >&2
                exit 1
              fi
              kata-ctl --config "$config" factory init
            - kata-v2-factory-init
            - /usr/share/defaults/kata-containers/configuration-clh-azure-runtime-rs-v2.toml
            - /run/vc/vm/template
            - /run/kata-v2-factory-init.lock
          securityContext:
            privileged: true
            runAsUser: 0
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
      containers:
        - name: initialized
          image: registry.k8s.io/pause:3.10
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 65534
            capabilities:
              drop:
                - ALL
            seccompProfile:
              type: RuntimeDefault
          resources:
            requests:
              cpu: 1m
              memory: 4Mi
            limits:
              memory: 16Mi
```

## Migrate workloads between runtime classes

Before you migrate, review the [runtime-class migration considerations](considerations-pod-sandboxing#runtime-class-migration-guidance-v1-to-v2-preview) and v2 limitations. Use these steps to migrate an existing workload from `kata-vm-isolation` (v1) to `kata-vm-isolation-v2` (preview):

1. Complete the v2 preview prerequisites and feature registration. If your existing node pool isn't using a supported VM size and node image, and if you created it before feature registration, you might need to recreate it.
2. Verify that the runtime class exists by running `kubectl get runtimeclass kata-vm-isolation-v2`.
3. Change [`runtimeClassName: kata-vm-isolation`](/en-us/azure/aks/use-pod-sandboxing?pivots=kata-vm-isolation#deploy-an-application-with-the-kata-runtime) to `runtimeClassName: kata-vm-isolation-v2` in your workload manifest. For a Deployment or another controller-managed workload, update the pod template.
4. Apply the updated controller manifest so the controller creates replacement pods. For a standalone Pod, delete the existing pod and recreate it from the updated manifest; you can't change `runtimeClassName` on an existing pod. Plan for any workload disruption before replacing pods.
5. Verify that the replacement pods are ready and that their `spec.runtimeClassName` is `kata-vm-isolation-v2`. Validate storage and mount behavior, startup latency, and resource usage in a preproduction environment before broad rollout. For memory-backed `emptyDir` volumes, follow the [v2 volume guidance](considerations-pod-sandboxing#emptydir-guidance-for-kata-vm-isolation-v2).
6. If you find compatibility issues, roll back by restoring [`runtimeClassName: kata-vm-isolation`](/en-us/azure/aks/use-pod-sandboxing?pivots=kata-vm-isolation#deploy-an-application-with-the-kata-runtime) in the manifest and replacing the pods through the same process.

::: zone-end

## Troubleshooting

::: zone pivot="kata-vm-isolation-v2-preview"

### Verify the runtime class and node label

1. Verify the v2 runtime class exists:

    ```bash
    kubectl get runtimeclass kata-vm-isolation-v2
    ```

    If the runtime class is missing, recheck feature registration, run `az aks update`, wait for reconciliation to complete, and run the command again.
2. Verify that nodes in the target Pod sandboxing pool carry the Kata runtime label. Replace `nodepool2` with your node pool name:

    ```bash
    kubectl get nodes \
      -l kubernetes.azure.com/agentpool=nodepool2 \
      -o 'custom-columns=NAME:.metadata.name,KATA_V2:.metadata.labels.kubernetes.azure.com/kata-vm-isolation-v2'
    ```

    If the label is missing, ensure the node pool meets the v2 prerequisites (supported VM SKU, required Kubernetes version, and Azure Linux node image version `202610.30.1` or later). Then upgrade the node image (`az aks nodepool upgrade --node-image-only`) and recheck. If the label is still missing, recreate the node pool with the required prerequisites.

### Check which runtime class your workloads use (optional)

If you're unsure which runtime class is used in your pods, you can check by listing the runtime class selected by each pod across all namespaces:

```bash
kubectl get pods --all-namespaces \
  -o 'custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,RUNTIMECLASS:.spec.runtimeClassName'
```

In the `RUNTIMECLASS` column, `kata-vm-isolation` identifies v1 pods, and `kata-vm-isolation-v2` identifies v2 preview pods. A value of `<none>` means the pod doesn't specify `runtimeClassName` and uses the node's default runtime. Listing available `RuntimeClass` resources alone doesn't show which runtime class your workloads select.

::: zone-end

### Reconcile cluster configuration after adding a Pod sandboxing node pool (optional)

In most cases, `az aks nodepool add` is sufficient and no extra reconcile step is required. If the runtime class or node labels don't appear as expected after adding a Pod sandboxing node pool, run [`az aks update`](/en-us/cli/azure/aks#az-aks-update) and then recheck.

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup
```

### Verify kernel isolation (optional)

This section uses the `isolated-pod` Kata pod ([`runtimeClassName: kata-vm-isolation`](/en-us/azure/aks/use-pod-sandboxing?pivots=kata-vm-isolation#deploy-an-application-with-the-kata-runtime)) that you created in Deploy an application with the Kata runtime. If you didn't deploy that pod, deploy it now.

1. To compare the kernels of Kata and non-Kata pods, create a file named *normal-app.yaml*. The following manifest defines a standard pod without the Kata runtime:

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: normal-pod
    spec:
      containers:
      - name: non-kata
        image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
        command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
    ```
2. Deploy the standard pod by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f normal-app.yaml
    ```
3. To access a container inside the AKS cluster, start a shell session by running the [`kubectl exec`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command. In this example, you're accessing the container inside *isolated-pod*.

    ```bash
    kubectl exec -it isolated-pod -- /bin/sh
    ```

    Kubectl connects to your cluster, runs `/bin/sh` inside the first container within `isolated-pod`, and forwards your terminal's input and output streams to the container's process. You can also start a shell session to the container hosting the non-Kata pod to see the differences.
4. After starting a shell session to the container from *isolated-pod*, run commands to verify that the *kata* container is running in a pod sandbox. It has a different kernel version compared to the non-Kata container outside the sandbox.

    To see the kernel version run the following command:

    ```bash
    uname -r
    ```

    The following example resembles output from the pod sandbox kernel:

    ```output
    [user]/# uname -r
    6.6.96.mshv1
    ```
5. Start a shell session to the container from *normal-pod* to verify the kernel output:

    ```bash
    kubectl exec -it normal-pod -- /bin/bash
    ```

    To see the kernel version run the following command:

    ```bash
    uname -r
    ```

    The following example resembles output from the VM that's running *normal-pod*, which is a different kernel than the Kata pod running within the pod sandbox:

    ```output
    6.6.100.mshv1-1.azl3
    ```

## Clean up resources

1. When you finish evaluating this feature, clean up resources you no longer need to avoid Azure charges. If you deployed a new cluster as part of your evaluation, run the following [`az aks delete`](/en-us/cli/azure/aks#az-aks-delete) command to delete the AKS cluster.

    ```azurecli
    az aks delete --resource-group myResourceGroup --name myAKSCluster
    ```
2. If you deployed Pod sandboxing on an existing cluster, you can remove the pods using the [`kubectl delete pod`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command.

    ```bash
    kubectl get pods
    kubectl delete pod <kata-pod-name>
    ```
3. If you followed the NAP walkthrough, remove its workload and NAP resources. Deleting the Karpenter `NodePool` also terminates its nodes, so first ensure that no workloads you want to retain are running on them.

    ```bash
    kubectl delete -f kata-nap-app.yaml
    kubectl delete nodepool kata
    kubectl delete aksnodeclass kata
    ```
4. To remove an Azure CLI-managed Pod sandboxing node pool, use the [`az aks nodepool delete`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command. Before deleting the node pool, ensure no workloads that you want to retain are running on it.

    ```azurecli
    az aks nodepool delete \
      --cluster-name myAKSCluster \
      --resource-group myResourceGroup \
      --name nodepool2
    ```

---