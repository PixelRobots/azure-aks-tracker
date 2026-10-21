---
layout: Conceptual
title: Secure Container Access to Resources in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/secure-container-access
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
description: Learn how to limit access to actions that containers can perform, provide the least number of permissions, and avoid the use of root access or privileged escalation.
author: allyford
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2024-11-08T00:00:00.0000000Z
ms.author: allyford
zone_pivot_groups: secure-container-access
locale: en-us
document_id: 0083b015-8329-42cf-9ac1-53bbc8125060
document_version_independent_id: 02a59227-3bf6-1f25-0b46-16f9d5057b50
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/secure-container-access.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/secure-container-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/secure-container-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: eec64347-b87f-2257-64d4-b319a7e1f3ef
---

# Secure Container Access to Resources in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to secure container access to resources for your Azure Kubernetes Service (AKS) workloads using the *user namespaces*, *AppArmor*, and *seccomp* built-in Linux security features.

## Overview of container access security

In the same way that you should grant users or groups the minimum privileges required, you should also limit containers to only necessary actions and processes. To minimize the risk of attack, avoid configuring applications and containers that require escalated privileges or root access.

You can use built-in Kubernetes *pod security contexts* to define more permissions, such as the user or group to run as, the Linux capabilities to expose, or setting `allowPrivilegeEscalation: false` in the pod manifest. For more best practices, see [Secure pod access to resources](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

To improve the host isolation and decrease lateral movement on Linux, you can use *user namespaces*. For even more granular control of container actions, you can use built-in Linux security features such as *AppArmor* and *seccomp*. These features help you limit the actions that containers can perform by defining Linux security features at the node level and implementing them through a pod manifest.

Built-in Linux security features are only available on Linux nodes and pods.

Note

Currently, Kubernetes environments aren't safe for hostile multitenant usage. Other security features, like *Microsoft Defender for Containers*, *AppArmor*, *seccomp*, *user namespaces*, *Pod Security Admission*, or *Kubernetes Role-Based Access Control (RBAC) for nodes*, efficiently block exploits.

For true security when running hostile multitenant workloads, only trust a hypervisor. The security domain for Kubernetes becomes the entire cluster, not an individual node.

For these types of hostile multitenant workloads, you should use physically isolated clusters.

::: zone pivot="user-namespaces"

## Prerequisites for user namespaces

- An existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- Minimum Kubernetes version 1.33 for the control plane and worker nodes. If you're not using Kubernetes version 1.33 or higher, you need to [upgrade your Kubernetes version](upgrade-aks-cluster).
- Worker nodes running Azure Linux 3.0 or Ubuntu 24.04 to ensure you meet the minimum [stack requirements](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/#before-you-begin) to enable user namespaces. If you need to upgrade your operating system (OS) version, see [upgrade your OS version](upgrade-os-version).

## Limitations for user namespaces

- The user namespaces feature is for the Linux kernel and isn't supported for Windows node pools.
- Check the [Kubernetes documentation for user namespaces](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/) for any other limitations.

## Overview of user namespaces

Linux pods run using several namespaces by default: a network namespaces to isolate the network identity and a PID namespace to isolate the processes. A [user namespace (user_namespace)](https://man7.org/linux/man-pages/man7/user_namespaces.7.html) isolates the users inside the container from the users on the host. It also limits the scope of capabilities and the pod's interactions with the rest of the system.

The UIDs and GIDs inside the container are mapped to unprivileged users on the host, so all interaction with the rest of the host happen as those unprivileged UID and GID. For example, root inside the container (UID 0) can be mapped to user 65536 on the host. Kubernetes creates the mapping to guarantee it doesn't overlap with other pods using user-namespaces on the system.

The Kubernetes implementation has some key benefits. To learn more, see the [Kubernetes User Namespaces documentation](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/).

## Enable user namespaces

1. Create a file named `mypod.yaml` and copy in the following manifest. To use user-namespaces, the YAML needs to have the field `hostUsers: false`.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: userns
    spec:
      hostUsers: false
      containers:
      - name: shell
        command: ["sleep", "infinity"]
        image: debian
    ```
2. Deploy the application using the `kubectl apply` command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f mypod.yaml
    ```
3. Check the status of the deployed pods using the `kubectl get pods` command.

    ```bash
    kubectl get pods
    ```
4. Exec into the pod using the `kubectl exec` command.

    ```bash
    kubectl exec -ti userns -- bash
    ```
5. Inside the pod, check `/proc/self/uid_map` using the following command:

    ```bash
    cat /proc/self/uid_map
    ```

    The output should have *65536* in the last column. For example:

    ```output
    0  833617920      65536
    ```

    This output indicates that root inside the container (UID 0) is mapped to user 65536 on the host.

## Common vulnerabilities and exposures (CVEs) mitigated by user namespaces

The following table outlines some common vulnerabilities and exposures (CVEs) that are either partially or fully mitigated by using user\_namespaces:

| CVE | Severity score | Severity level |
| --- | --- | --- |
| [CVE-2019-5736](https://nvd.nist.gov/vuln/detail/CVE-2019-5736) | 8.6 | High |
| [CVE 2024-21262](https://github.com/opencontainers/runc/security/advisories/GHSA-xr7r-f8xq-vfvv) | 8.6 | High |
| [CVE 2022-0492](https://unit42.paloaltonetworks.com/cve-2022-0492-cgroups/) | 7.8 | High |
| [CVE-2021-25741](https://nvd.nist.gov/vuln/detail/CVE-2021-25741) | 8.1 / 8.8 | High / High |
| [CVE-2017-1002101](https://nvd.nist.gov/vuln/detail/CVE-2017-1002101) | 9.6 / 8.8 | Critical / High |

Keep in mind that this list isn't exhaustive. To learn more, see [Kubernetes v1.33: User Namespaces enabled by default](https://kubernetes.io/blog/2025/04/25/userns-enabled-by-default/).

::: zone-end

::: zone pivot="apparmor"

## AppArmor prerequisites

- An existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).

Note

Azure Linux 3.0 supports AppArmor as of the November 7, 2025 VHD release.

## Overview of AppArmor

To limit container actions, you can use the [AppArmor](https://kubernetes.io/docs/tutorials/clusters/apparmor/) Linux kernel security module. AppArmor is available as part of the underlying AKS node operating system (OS) and is enabled by default. You can create AppArmor profiles that restrict read, write, or execute actions, or system functions like mounting filesystems. Default AppArmor profiles restrict access to various `/proc` and `/sys` locations and provide a means to logically isolate containers from the underlying node. AppArmor works for any application that runs on Linux, not just Kubernetes pods.

Note

Before Kubernetes v1.30, AppArmor was specified through annotations. From v1.30 onwards, AppArmor is specified through the `securityContext` field in the pod specification. For more information, see the [Kubernetes AppArmor documentation](https://kubernetes.io/docs/tutorials/clusters/apparmor/).

![AppArmor profiles in use in an AKS cluster to limit container actions](media/operator-best-practices-container-security/apparmor.png)

## Secure pods with AppArmor

You can specify AppArmor profiles at the pod or container level. The container AppArmor profile takes precedence over the pod AppArmor profile. If neither is specified, the container runs unconfined. For more information on AppArmor profiles, see the [Securing a Pod with AppArmor Kubernetes documentation](https://kubernetes.io/docs/tutorials/clusters/apparmor/).

## Configure a custom AppArmor profile

The following example creates a profile that prevents writing to files from within a container.

1. [SSH](manage-ssh-node-access) to an AKS node.
2. Create a file named *deny-write.profile* and paste in the following content:

    ```bash
    #include <tunables/global>
    
    profile k8s-apparmor-example-deny-write flags=(attach_disconnected) {
      #include <abstractions/base>
    
      file,
    
      # Deny all file writes.
      deny /** w,
    }
    ```
3. Load the AppArmor profile onto the node.

    ```bash
    # This example assumes that node names match host names, and are reachable via SSH.
    NODES=($( kubectl get node -o jsonpath='{.items[*].status.addresses[?(.type == "Hostname")].address}' ))
    
    for NODE in ${NODES[*]}; do ssh $NODE 'sudo apparmor_parser -q <<EOF
    #include <tunables/global>
    
    profile k8s-apparmor-example-deny-write flags=(attach_disconnected) {
      #include <abstractions/base>
    
      file,
    
      # Deny all file writes.
      deny /** w,
    }
    EOF'
    done
    ```

## Deploy a pod with the custom AppArmor profile

1. Deploy a *"Hello AppArmor"* pod with the deny-write profile.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: hello-apparmor
    spec:
      securityContext:
        appArmorProfile:
          type: Localhost
          localhostProfile: k8s-apparmor-example-deny-write
      containers:
      - name: hello
        image: busybox:1.28
        command: [ "sh", "-c", "echo 'Hello AppArmor!' && sleep 1h" ]
    ```
2. Apply the pod manifest using the `kubectl apply` command.

    ```bash
    kubectl apply -f hello-apparmor.yaml
    ```
3. Exec into the pod and verify the container is running with the AppArmor profile.

    ```bash
    kubectl exec hello-apparmor -- cat /proc/1/attr/current
    ```

    The output should show the AppArmor profile in use. For example:

    ```output
    k8s-apparmor-example-deny-write (enforce)
    ```

::: zone-end

::: zone pivot="seccomp"

## Seccomp prerequisites

- An existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need to register the `KubeletDefaultSeccompProfilePreview` feature flag to use default seccomp profiles on your node pools.

### Register the `KubeletDefaultSeccompProfilePreview` feature flag

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

1. Register the `KubeletDefaultSeccompProfilePreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "KubeletDefaultSeccompProfilePreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "KubeletDefaultSeccompProfilePreview"
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Seccomp limitations

- AKS only supports the default seccomp profiles (`RuntimeDefault` and `Unconfined`). Custom seccomp profiles aren't supported.
- `SeccompDefault` isn't a supported parameter for Windows node pools.

## Overview of default seccomp profiles (preview)

While AppArmor works for any Linux application, [seccomp (or *secure computing*)](https://kubernetes.io/docs/reference/node/seccomp/) works at the process level. Seccomp is also a Linux kernel security module. The `containerd` runtime used by AKS nodes provides native support for seccomp. With seccomp, you can limit a container's system calls. Seccomp establishes an extra layer of protection against common system call vulnerabilities exploited by malicious actors and allows you to specify a default profile for all workloads in the node.

You can apply default seccomp profiles using [custom node configurations](/en-us/azure/aks/custom-node-configuration) when creating a new Linux node pool. AKS supports the `RuntimeDefault` and `Unconfined` values. Some workloads might require a lower number of syscall restrictions than others. This means that they can fail during runtime with the `RuntimeDefault` profile. To mitigate such a failure, you can specify the `Unconfined` profile. If your workload requires a custom profile, see Configure a custom seccomp profile.

### Restrict container system calls with seccomp

1. [Follow steps to apply a seccomp profile in your kubelet configuration](/en-us/azure/aks/custom-node-configuration) by specifying `"seccompDefault": "RuntimeDefault"`.
2. [Connect to the host](node-access).
3. Verify the configuration was applied to the nodes.

#### Resolve workload failures with seccomp

When `SeccompDefault` is enabled, the container runtime default seccomp profile is used by default for all workloads scheduled on the node, which might cause workloads to fail due to blocked syscalls. If a workload failure occurs, you might see errors such as:

- Workload is exiting unexpectedly after the feature is enabled, with "permission denied" error.
- Seccomp error messages can also be seen in auditd or syslog by replacing SCMP\_ACT\_ERRNO with SCMP\_ACT\_LOG in the default profile.

If you experience these errors, we recommend that you change your seccomp profile to `Unconfined`. `Unconfined` places no restrictions on syscalls, allowing all system calls to be executed.

## Overview of custom seccomp profiles

With a custom seccomp profile, you have more granular control over restricted syscalls for your containers. You can create your own seccomp profiles by:

- Using filters to specify what actions to allow or deny.
- Annotating within a pod YAML manifest to associate with the seccomp filter.

Note

For help with troubleshooting your seccomp profile, see [Troubleshoot seccomp profile configuration in Azure Kubernetes Service (AKS)](/en-us/troubleshoot/azure/azure-kubernetes/security/troubleshoot-seccomp-profiles).

### Configure a custom seccomp profile

To see seccomp in action, create a filter that prevents changing permissions on a file.

1. [SSH](manage-ssh-node-access) to an AKS node.
2. Create a seccomp filter named */var/lib/kubelet/seccomp/prevent-chmod*.
3. Copy and paste the following content:

    ```json
    {
      "defaultAction": "SCMP_ACT_ALLOW",
      "syscalls": [
        {
          "name": "chmod",
          "action": "SCMP_ACT_ERRNO"
        },
        {
          "name": "fchmodat",
          "action": "SCMP_ACT_ERRNO"
        },
        {
          "name": "chmodat",
          "action": "SCMP_ACT_ERRNO"
        }
      ]
    }
    ```

    In version 1.19 and later, you need to configure:

    ```json
    {
      "defaultAction": "SCMP_ACT_ALLOW",
      "syscalls": [
        {
          "names": ["chmod","fchmodat","chmodat"],
          "action": "SCMP_ACT_ERRNO"
        }
      ]
    }
    ```
4. From your local machine, create a pod manifest named *aks-seccomp.yaml* and paste the following content. This manifest defines an annotation for `seccomp.security.alpha.kubernetes.io` and references the existing *prevent-chmod* filter.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: chmod-prevented
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: localhost/prevent-chmod
    spec:
      containers:
      - name: chmod
        image: mcr.microsoft.com/dotnet/runtime-deps:6.0
        command:
          - "chmod"
        args:
         - "777"
         - /etc/hostname
      restartPolicy: Never
    ```

    In version 1.19 and later, you need to configure:

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: chmod-prevented
    spec:
      securityContext:
        seccompProfile:
          type: Localhost
          localhostProfile: prevent-chmod
      containers:
      - name: chmod
        image: mcr.microsoft.com/dotnet/runtime-deps:6.0
        command:
          - "chmod"
        args:
         - "777"
         - /etc/hostname
      restartPolicy: Never
    ```
5. Deploy the sample pod using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f ./aks-seccomp.yaml
    ```
6. View the pod status using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pods
    ```

    In the output, you should see the pod reports an error. The `chmod` command is prevented from running by the seccomp filter, as shown in the example output:

    ```output
    NAME                      READY     STATUS    RESTARTS   AGE
    chmod-prevented           0/1       Error     0          7s
    ```

::: zone-end

## Seccomp security profile options

Seccomp security profiles are a set of defined syscalls that are allowed or restricted. Most container runtimes have a default seccomp profile that's similar if not the same as the one Docker uses. For more information about available profiles, see the [Docker](https://kubernetes.io/docs/reference/node/seccomp/) or [containerd](https://github.com/containerd/containerd/blob/f0a32c66dad1e9de716c9960af806105d691cd78/contrib/seccomp/seccomp_default.go#L51) default seccomp profiles.

AKS uses the [containerd](https://github.com/containerd/containerd/blob/f0a32c66dad1e9de716c9960af806105d691cd78/contrib/seccomp/seccomp_default.go#L51) default seccomp profile for the `RuntimeDefault` when you configure seccomp using [custom node configuration](/en-us/azure/aks/custom-node-configuration).

### Significant syscalls blocked by default profile

Both [Docker](https://kubernetes.io/docs/reference/node/seccomp/) and [containerd](https://github.com/containerd/containerd/blob/f0a32c66dad1e9de716c9960af806105d691cd78/contrib/seccomp/seccomp_default.go#L51) maintain allow lists of safe syscalls. When changes are made to [Docker](https://kubernetes.io/docs/reference/node/seccomp/) and [containerd](https://github.com/containerd/containerd/blob/f0a32c66dad1e9de716c9960af806105d691cd78/contrib/seccomp/seccomp_default.go#L51), AKS updates the default configuration to match. Updates to this list might cause workload failure. For release updates, see [AKS release notes](https://github.com/Azure/AKS/releases).

The following table lists significant syscalls that are effectively blocked because they aren't on the allow list. This list isn't exhaustive. If your workload requires any of the blocked syscalls, don't use the `RuntimeDefault` seccomp profile.

| Blocked syscall | Description |
| --- | --- |
| `acct` | Accounting syscall, which could let containers disable their own resource limits or process accounting. Also gated by `CAP_SYS_PACCT`. |
| `add_key` | Prevent containers from using the kernel keyring, which isn't namespaced. |
| `bpf` | Deny loading potentially persistent bpf programs into kernel, already gated by `CAP_SYS_ADMIN`. |
| `clock_adjtime` | Time/date isn't namespaced. Also gated by `CAP_SYS_TIME`. |
| `clock_settime` | Time/date isn't namespaced. Also gated by `CAP_SYS_TIME`. |
| `clone` | Deny cloning new namespaces. Also gated by `CAP_SYS_ADMIN for CLONE_*` flags, except `CLONE_NEWUSER`. |
| `create_module` | Deny manipulation and functions on kernel modules. Obsolete. Also gated by `CAP_SYS_MODULE`. |
| `delete_module` | Deny manipulation and functions on kernel modules. Also gated by `CAP_SYS_MODULE`. |
| `finit_module` | Deny manipulation and functions on kernel modules. Also gated by `CAP_SYS_MODULE`. |
| `get_kernel_syms` | Deny retrieval of exported kernel and module symbols. Obsolete. |
| `get_mempolicy` | Syscall that modifies kernel memory and NUMA settings. Already gated by `CAP_SYS_NICE`. |
| `init_module` | Deny manipulation and functions on kernel modules. Also gated by `CAP_SYS_MODULE`. |
| `ioperm` | Prevent containers from modifying kernel I/O privilege levels. Already gated by `CAP_SYS_RAWIO`. |
| `iopl` | Prevent containers from modifying kernel I/O privilege levels. Already gated by `CAP_SYS_RAWIO`. |
| `kcmp` | Restrict process inspection capabilities, already blocked by dropping `CAP_SYS_PTRACE`. |
| `kexec_file_load` | Sister syscall of kexec\_load that does the same thing, slightly different arguments. Also gated by `CAP_SYS_BOOT`. |
| `kexec_load` | Deny loading a new kernel for later execution. Also gated by `CAP_SYS_BOOT`. |
| `keyctl` | Prevent containers from using the kernel keyring, which isn't namespaced. |
| `lookup_dcookie` | Tracing/profiling syscall, which could leak information on the host. Also gated by `CAP_SYS_ADMIN`. |
| `mbind` | Syscall that modifies kernel memory and NUMA settings. Already gated by `CAP_SYS_NICE`. |
| `mount` | Deny mounting, already gated by `CAP_SYS_ADMIN`. |
| `move_pages` | Syscall that modifies kernel memory and NUMA settings. |
| `nfsservctl` | Deny interaction with the kernel nfs daemon. Obsolete since Linux 3.1. |
| `open_by_handle_at` | Cause of an old container breakout. Also gated by `CAP_DAC_READ_SEARCH`. |
| `perf_event_open` | Tracing/profiling syscall, which could leak information on the host. |
| `personality` | Prevent container from enabling BSD emulation. Not inherently dangerous, but poorly tested, potential for kernel vulns. |
| `pivot_root` | Deny pivot\_root, should be privileged operation. |
| `process_vm_readv` | Restrict process inspection capabilities, already blocked by dropping `CAP_SYS_PTRACE`. |
| `process_vm_writev` | Restrict process inspection capabilities, already blocked by dropping `CAP_SYS_PTRACE`. |
| `ptrace` | Tracing/profiling syscall. Blocked in Linux kernel versions before 4.8 to avoid seccomp bypass. Tracing/profiling arbitrary processes is already blocked by dropping `CAP_SYS_PTRACE`, because it could leak information on the host. |
| `query_module` | Deny manipulation and functions on kernel modules. Obsolete. |
| `quotactl` | Quota syscall, which could let containers disable their own resource limits or process accounting. Also gated by `CAP_SYS_ADMIN`. |
| `reboot` | Don't let containers reboot the host. Also gated by `CAP_SYS_BOOT`. |
| `request_key` | Prevent containers from using the kernel keyring, which isn't namespaced. |
| `set_mempolicy` | Syscall that modifies kernel memory and NUMA settings. Already gated by `CAP_SYS_NICE`. |
| `setns` | Deny associating a thread with a namespace. Also gated by `CAP_SYS_ADMIN`. |
| `settimeofday` | Time/date isn't namespaced. Also gated by `CAP_SYS_TIME`. |
| `stime` | Time/date isn't namespaced. Also gated by `CAP_SYS_TIME`. |
| `swapon` | Deny start/stop swapping to file/device. Also gated by `CAP_SYS_ADMIN`. |
| `swapoff` | Deny start/stop swapping to file/device. Also gated by `CAP_SYS_ADMIN`. |
| `sysfs` | Obsolete syscall. |
| `_sysctl` | Obsolete, replaced by `/proc/sys`. |
| `umount` | Should be a privileged operation. Also gated by `CAP_SYS_ADMIN`. |
| `umount2` | Should be a privileged operation. Also gated by `CAP_SYS_ADMIN`. |
| `unshare` | Deny cloning new namespaces for processes. Also gated by `CAP_SYS_ADMIN` (except for `unshare --user`). |
| `uselib` | Older syscall related to shared libraries, unused for a long time. |
| `userfaultfd` | Userspace page fault handling, largely needed for process migration. |
| `ustat` | Obsolete syscall. |
| `vm86` | In kernel x86 real mode virtual machine. Also gated by `CAP_SYS_ADMIN`. |
| `vm86old` | In kernel x86 real mode virtual machine. Also gated by `CAP_SYS_ADMIN`. |