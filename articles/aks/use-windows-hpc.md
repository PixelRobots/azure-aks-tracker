---
layout: Conceptual
title: Use Windows HostProcess containers - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-windows-hpc
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
description: Learn how to use HostProcess & Privileged containers for Windows workloads on AKS
author: schaffererin
ms.author: schaffererin
ms.date: 2023-05-09T00:00:00.0000000Z
ms.topic: how-to
ms.custom: aks-windows - build-2025
locale: en-us
document_id: 5d3d319c-e9cb-b78a-f14c-930e2cb47125
document_version_independent_id: 5d1f03cb-8611-c25e-52dc-b4bc64890bdf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-windows-hpc.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-windows-hpc
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-windows-hpc.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c7d82397-9ccc-ab95-1b48-af6e944923a6
---

# Use Windows HostProcess containers - Azure Kubernetes Service | Microsoft Learn

HostProcess / Privileged containers extend the Windows container model to enable a wider range of Kubernetes cluster management scenarios. HostProcess containers run directly on the host and maintain behavior and access similar to that of a regular process. HostProcess containers allow users to package and distribute management operations and functionalities that require host access while retaining versioning and deployment methods provided by containers.

A privileged DaemonSet can carry out changes or monitor a Linux host on Kubernetes but not Windows hosts. HostProcess containers are the Windows equivalent of host elevation.

## Limitations

- HostProcess containers require Kubernetes 1.23 or greater.
- HostProcess containers require `containerd` 1.6 or higher container runtime.
- HostProcess pods can only contain HostProcess containers due to a limitation on the Windows operating system. Non-privileged Windows containers can't share a vNIC with the host IP namespace.
- HostProcess containers run as a process on the host. The only isolation those containers have from the host is the resource constraints imposed on the HostProcess user account.
- Filesystem isolation and Hyper-V isolation aren't supported for HostProcess containers.
- Volume mounts are supported and are mounted under the container volume. See Volume Mounts.
- A limited set of host user accounts are available for Host Process containers by default. See Choosing a User Account.
- Resource limits such as disk, memory, and cpu count, work the same way as fashion as processes on the host.
- Named pipe mounts and Unix domain sockets aren't directly supported, but can be accessed on their host path, for example `\\.\pipe\*`.

## Run a HostProcess workload

To use HostProcess features with your deployment, set *hostProcess: true* and *hostNetwork: true*:

```yaml
    spec:
      ...
      securityContext:
         windowsOptions:
           hostProcess: true
           ...
      hostNetwork: true
      containers:
      ...
```

To run an example workload that uses HostProcess features on an existing AKS cluster with Windows nodes, create `hostprocess.yaml` with the following contents:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: privileged-daemonset
  namespace: kube-system
  labels:
    app: privileged-daemonset
spec:
  selector:
    matchLabels:
      app: privileged-daemonset
  template:
    metadata:
      labels:
        app: privileged-daemonset
    spec:
      nodeSelector:
        kubernetes.io/os: windows
      securityContext:
        windowsOptions:
          hostProcess: true
          runAsUserName: "NT AUTHORITY\\SYSTEM"
      hostNetwork: true
      containers:
        - name: powershell
          image: mcr.microsoft.com/windows/nanoserver:ltsc2019 # or nanoserver:ltsc2022
          command:
            - powershell.exe
            - -Command
            - Start-Sleep -Seconds 2147483
      terminationGracePeriodSeconds: 0
```

Use `kubectl` to run the example workload:

```azurecli
kubectl apply -f hostprocess.yaml
```

You should see the following output:

```output
$ kubectl apply -f hostprocess.yaml
daemonset.apps/privileged-daemonset created
```

Verify that your workload uses the features of HostProcess containers by viewing the pod's logs.

Use `kubectl` to find the name of the pod in the `kube-system` namespace.

```output
$ kubectl get pods --namespace kube-system

NAME                                  READY   STATUS    RESTARTS   AGE
...
privileged-daemonset-12345            1/1     Running   0          2m13s
```

Use `kubectl log` to view the logs of the pod and verify the pod has administrator rights:

```output
$ kubectl logs privileged-daemonset-12345 --namespace kube-system
InvalidOperation: Unable to find type [Security.Principal.WindowsPrincipal].
Process has admin rights:
```