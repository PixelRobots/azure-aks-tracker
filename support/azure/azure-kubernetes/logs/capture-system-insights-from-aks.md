---
layout: Conceptual
title: Capture real-time system insights from an AKS cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-system-insights-from-aks
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Use Inspektor Gadget to capture real-time system insights from an AKS cluster, trace DNS and file activity, and troubleshoot faster—start now.
editor: v-jsitser
ms.reviewer: cssakscic, josebl, v-leedennis, mayasingh
ms.service: azure-kubernetes-service
ms.date: 2026-08-04T00:00:00.0000000Z
ms.custom: sap:Monitoring and Logging
locale: en-us
document_id: 5ea595d5-5a87-e369-6367-7e4b53ab3376
document_version_independent_id: 5ea595d5-5a87-e369-6367-7e4b53ab3376
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/logs/capture-system-insights-from-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/logs/capture-system-insights-from-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/logs/capture-system-insights-from-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 57f6c217-f7b4-d596-6736-c0b209d9d299
---

# Capture real-time system insights from an AKS cluster - Azure | Microsoft Learn

## Summary

Use Inspektor Gadget to capture real-time system insights from your Azure Kubernetes Service (AKS) cluster. This article shows you how to install it and use practical examples to troubleshoot issues faster.

## Demo: Real-time DNS troubleshooting and critical file-access alerting

To begin, consider the following quick demo. Suppose that you need to figure out why the DNS requests from an application fail. By using Inspektor Gadget, you can run the [trace_dns gadget](https://go.microsoft.com/fwlink/?linkid=2260317) to capture the DNS traffic in the Kubernetes namespace in which your application is running:

```bash
kubectl gadget run trace_dns \
  --namespace my-ns \
  --fields k8s.node,k8s.podName,id,qr,name,rcode,nameserver
```

```output
K8S.NODE                          K8S.PODNAME  ID    QR  NAME          RCODE  NAMESERVER
aks-nodepool-41788306-vmss000002  demo-pod     13cc  Q   example.com.         1.2.3.4
aks-nodepool-41788306-vmss000002  demo-pod     13cc  Q   example.com.         1.2.3.4
```

From this information, you can see that the DNS requests are directed to the DNS server at IP address `1.2.3.4` (as indicated in the `NAMESERVER` column), but you only see the queries (`Q` in the `QR` column) and no responses (`R` in the `QR` column). This condition means that the DNS server didn't respond to the queries, which is why the application can't resolve the domain name `www.example.com`.

Now, suppose that `1.2.3.4` isn't the default name server configuration, and you suspect that a malicious process is modifying the configuration at runtime. In these kinds of cases, Inspektor Gadget goes beyond DNS diagnostics. It also enables you to monitor processes that access critical files (such as */etc/resolv.conf*) and have the intention of modifying those files. To do that, run the [trace_open gadget](https://go.microsoft.com/fwlink/?linkid=2260318) in the same namespace and filter the results by the file name and the flags that indicate [the intention to write to the file](https://linux.die.net/man/3/open) (`O_WRONLY` to open for writing only, or `O_RDWR` to open for reading and writing):

```bash
kubectl gadget run trace_open \
  --namespace my-ns \
  --filter fname==/etc/resolv.conf,flags~'(O_WRONLY|O_RDWR)' \
  --fields k8s.node,k8s.podName,comm,fname,flags,error
```

```output
K8S.NODE                          K8S.PODNAME  COMM            FNAME             FLAGS     ERROR
aks-nodepool-41788306-vmss000002  demo-pod     malicious-proc  /etc/resolv.conf  O_WRONLY
```

## What is Inspektor Gadget?

[Inspektor Gadget](https://go.microsoft.com/fwlink/?linkid=2260072) is a framework that makes it easy to monitor, troubleshoot, and secure workloads running on Linux and Kubernetes. It consists of tools (*Gadgets*) that leverage [eBPF](https://go.microsoft.com/fwlink/?linkid=2259866) programs. Their primary goal is to gather low-level kernel data to provide insights into specific system scenarios. The Inspektor Gadget framework manages the association of the collected data by using high-level references, such as Kubernetes resources. This integration ensures that a seamless connection exists between low-level insights and their corresponding high-level context. The integration streamlines the troubleshooting process and the collection of relevant information.

## Gadgets

Inspektor Gadget provides a set of built-in tools that are designed to debug and observe common situations on a system. For example, by using these gadgets, you can trace the following events in your cluster:

- Process creation
- File access
- Network activity, such as TCP connections or DNS resolution

The gadgets present the information they collect by using different mechanisms. For instance, some gadgets can inform you about the system status at specific times. Other gadgets can report every time a given event occurs, or they can provide periodic updates.

These are just a few examples. The [official documentation](https://go.microsoft.com/fwlink/?linkid=2260507) provides detailed descriptions and examples of each gadget so that you can determine the most suitable gadget for your specific use case. However, if you find a use case that the existing gadgets don't currently cover, Inspektor Gadget allows you to run your own eBPF programs by using the [run command](https://go.microsoft.com/fwlink/?linkid=2259865). Because the Inspektor Gadget framework handles the building, packaging, and deployment of your custom programs, it streamlines the process for your unique requirements. Also, it gathers high-level metadata to enrich the data that you collect in your program.

## Use cases

To complement the demo that's presented at the beginning of this article, the following list shows how Inspektor Gadget helps you tackle debugging challenges. The following examples showcase the potential of Inspektor Gadget. But the capabilities of this tool extend beyond these scenarios. This capability makes Inspektor Gadget an invaluable asset for navigating the complexities of Kubernetes debugging and observability.

| Problem area | Symptoms | Troubleshooting |
| --- | --- | --- |
| **Disk-intensive applications** | High memory or CPU usage, or inconsistent node readiness | An application might consistently engage in disk read/write operations, such as extensive logging. By using Inspektor Gadget, you can identify in real time which containers generate more [block I/O](https://go.microsoft.com/fwlink/?linkid=2260070). Or, more specifically, you can find the container that causes more reads and writes into a ⁠[file](https://go.microsoft.com/fwlink/?linkid=2260071). |
| **"It's always DNS"** | High application latency, timeouts, or poor end-user experience | By using Inspektor Gadget, you can [trace all the DNS](https://go.microsoft.com/fwlink/?linkid=2260317) queries and responses in the cluster. In particular, Inspektor Gadget provides the following information that helps you to determine whether the DNS is affecting your application's performance:<br><br>- Query success<br>- Whether the response contains an error<br>- The name server that's used for the lookup<br>- The query-response latency |
| **File system access** | Application misbehaves or can't function correctly | The application might be unable to access specific configurations, logs, or other vital files in the file system. In such scenarios, Inspektor Gadget enables you to [trace all the opened files](https://go.microsoft.com/fwlink/?linkid=2260318) inside pods to diagnose access issues. Whenever your application tries to open a file, you can discover the following information:<br><br>- The flags that are used to open the file (for example, [O_RDONLY, O_WRONLY, O_RDWR](https://linux.die.net/man/3/open), and so on)<br>- Whether the file opening attempt succeeds<br>- The returned error (if the file opening attempt fails)<br><br><br>For instance, if the attempt to open the file fails because of error 2 ([ENOENT](https://man7.org/linux/man-pages/man3/errno.3.html)), the application is probably trying to open a file that doesn't exist. This means that you might have a typo in the code, or the file is available in a different path. |
| **Remote code execution (RCE)** | Unauthorized code execution such as [cryptojacking](https://en.wikipedia.org/wiki/Cryptojacking) that's evident in high CPU usage during application idle periods | When attackers try to make this kind of attack on a system, they usually have to run the code by using `bash`. Inspektor Gadget enables you to [trace the creation of new processes](https://go.microsoft.com/fwlink/?linkid=2260319), particularly processes that involve critical commands such as `bash`. |

## How to install Inspektor Gadget in an AKS cluster

Learn how to deploy Inspektor Gadget in your cluster. Two installation methods are available:

- **AKS cluster extension (recommended)**: Installs and manages Inspektor Gadget through the Azure resource management plane by using `az k8s-extension` CLI commands. This approach provides Azure Resource Manager-driven lifecycle management, including installation, configuration, updates, and removal.
- **kubectl gadget plug-in**: Deploys Inspektor Gadget directly in your cluster by running the `kubectl gadget` plug-in. This approach requires manual lifecycle management but doesn't depend on the Azure resource management plane.

### Install Inspektor Gadget by using the AKS cluster extension

The [Inspektor Gadget cluster extension](/en-us/azure/aks/inspektor-gadget-overview) installs and manages Inspektor Gadget on your AKS cluster through the Azure resource management plane. This installation method is recommended because it provides a consistent, Azure Resource Manager-driven lifecycle for installation, configuration, updates, and removal. The extension pulls all container images and gadget images from Microsoft Artifact Registry (MCR).

Important

The Inspektor Gadget cluster extension is currently in preview. AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. For more information, see [AKS support policies](/en-us/azure/aks/support-policies).

#### Prerequisites

- An AKS cluster with `kubectl` access. If you don't have an AKS cluster, [create one by using Azure CLI](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli) or [by using the Azure portal](/en-us/azure/aks/learn/quick-kubernetes-deploy-portal).
- The Azure CLI with the `k8s-extension` extension installed.

    ```azurecli
    az extension add --name k8s-extension
    ```
- Any existing Inspektor Gadget installation removed before you install the extension. If you previously deployed it manually, run `kubectl gadget undeploy` or `helm uninstall`.

In the commands in this section, replace `myResourceGroup` and `myAKSCluster` with the values for your environment.

#### Install the extension

Install the Inspektor Gadget extension on your AKS cluster by using the [az k8s-extension create](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) command:

```azurecli
az k8s-extension create \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --extension-type microsoft.inspektorgadget \
    --release-train preview
```

Note

By default, the extension automatically upgrades its minor version. To keep it on the installed version instead, add `--auto-upgrade-minor-version false` to the install command.

#### Verify the installation

Confirm that the extension is provisioned successfully and that the DaemonSet is running:

```azurecli
az k8s-extension show \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget
```

```bash
kubectl get ds gadget -n gadget
kubectl get pods -n gadget -l k8s-app=gadget
```

The provisioning state should show `Succeeded`, and all gadget pods should be `Running` and `Ready`.

After you install the extension, you can start running gadgets by using the `kubectl gadget` plug-in. For instructions on installing the `kubectl gadget` plug-in on your workstation, see Part 1: Install the kubectl gadget plug-in on your workstation.

Note

You can configure the extension after installation by passing custom settings such as enabling Azure Monitor metrics export, changing the log level, or restricting which nodes run the DaemonSet. For the full list of configuration options, see [Install and configure the Inspektor Gadget extension on AKS](/en-us/azure/aks/inspektor-gadget-configure).

#### Remove the extension

When you no longer need Inspektor Gadget, delete the extension. This action removes the gadget pods, DaemonSet, and related resources:

```azurecli
az k8s-extension delete \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --yes
```

### Install Inspektor Gadget by using the AKS extension (preview)

Note

The AKS extension for Inspektor Gadget is currently in preview. For legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability, see the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).

#### Prerequisites

- The Azure CLI. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `k8s-extension` Azure CLI extension. If you don't have it installed, run the following command:

    ```azurecli
    az extension add --name k8s-extension
    ```

#### Install the Inspektor Gadget extension

To install Inspektor Gadget as an AKS extension, run the following Azure CLI command:

```azurecli
az k8s-extension create \
  --name inspektor-gadget \
  --extension-type microsoft.inspektorgadget \
  --release-train preview \
  --cluster-type managedClusters \
  --cluster-name <AKS_CLUSTER_NAME> \
  --resource-group <RESOURCE_GROUP_NAME>
```

### Alternative installation: Install Inspektor Gadget by running the "kubectl gadget" plug-in

This section outlines the steps for installing Inspektor Gadget in your AKS cluster by running the `kubectl gadget` plug-in. The installation consists of two parts:

1. Installing the `kubectl gadget` plug-in on your workstation
2. Running the `kubectl gadget` plug-in to deploy Inspektor Gadget in the cluster

Warning

Many mechanisms are available to deploy and use Inspektor Gadget. Each mechanism is tailored to specific use cases and requirements. You can use the `kubectl gadget` plug-in to apply several of these mechanisms, but not all of them. For example, deploying Inspektor Gadget by using the `kubectl gadget` plug-in depends on the availability of the Kubernetes API server. If you can't depend on this component because its availability might be occasionally compromised, avoid using the `kubectl gadget` deployment mechanism. For more information about this and other use cases, see the [Inspektor Gadget documentation](https://go.microsoft.com/fwlink/?linkid=2326106).

#### Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) command-line tool. If you have [Azure CLI](/en-us/cli/azure/install-azure-cli-linux), you can run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command to install kubectl.
- An AKS cluster. If you don't have an AKS cluster, [create one by using Azure CLI](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli) or [by using the Azure portal](/en-us/azure/aks/learn/quick-kubernetes-deploy-portal).

#### Part 1: Install the kubectl gadget plug-in on your workstation

Use the instructions for your OS:

- Azure Linux 3.0
- Ubuntu 18.04 / 20.04 / 22.04

Note

To install a specific release or compile it from the source, see [Install kubectl gadget](https://go.microsoft.com/fwlink/?linkid=2260075#installing-the-kubectl-gadget-client) on GitHub.

# [Azure Linux 3.0](#tab/azurelinux30)
1. Add the Microsoft Cloud-Native repository to your system:

    ```bash
    echo "[azurelinux-cloud-native]
    name=Azure Linux Cloud Native 3.0
    baseurl=https://packages.microsoft.com/azurelinux/3.0/prod/cloud-native/$(uname -i)
    gpgkey=file:///etc/pki/rpm-gpg/MICROSOFT-RPM-GPG-KEY
    gpgcheck=1
    repo_gpgcheck=1
    enabled=1
    skip_if_unavailable=True
    sslverify=1
    " > /etc/yum.repos.d/azurelinux-cloud-native.repo
    ```
2. Install the `kubectl gadget` plug-in:

    ```bash
    tdnf install --refresh -y kubectl-gadget
    ```

# [Ubuntu 22.04](#tab/ubuntu2204)
1. Get `curl` if you don't have it installed:

    ```bash
    apt update && apt install -y curl
    ```
2. Download the Microsoft GNU Privacy Guard (GPG) public key:

    ```bash
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | tee /usr/share/keyrings/microsoft.asc
    ```
3. Add the Microsoft Cloud-Native repository to your system:

    ```bash
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.asc] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" | tee /etc/apt/sources.list.d/packages-microsoft-prod.list
    ```
4. Update the package index:

    ```bash
    apt update
    ```
5. Install the `kubectl gadget` plug-in:

    ```bash
    apt install -y kubectl-gadget
    ```

# [Ubuntu 20.04](#tab/ubuntu2004)
1. Get `curl` if you don't have it installed:

    ```bash
    apt update && apt install -y curl
    ```
2. Download the Microsoft GNU Privacy Guard (GPG) public key:

    ```bash
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | tee /usr/share/keyrings/microsoft.asc
    ```
3. Add the Microsoft Cloud-Native repository to your system:

    ```bash
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.asc] https://packages.microsoft.com/ubuntu/20.04/prod focal main" | tee /etc/apt/sources.list.d/packages-microsoft-prod.list
    ```
4. Update the package index:

    ```bash
    apt update
    ```
5. Install the `kubectl gadget` plug-in:

    ```bash
    apt install -y kubectl-gadget
    ```

# [Ubuntu 18.04](#tab/ubuntu1804)
1. Get `curl` if you don't have it installed:

    ```bash
    apt update && apt install -y curl
    ```
2. Download the Microsoft GNU Privacy Guard (GPG) public key:

    ```bash
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | tee /usr/share/keyrings/microsoft.asc
    ```
3. Add the Microsoft Cloud-Native repository to your system:

    ```bash
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.asc] https://packages.microsoft.com/ubuntu/18.04/prod bionic main" | tee /etc/apt/sources.list.d/packages-microsoft-prod.list
    ```
4. Update the package index:

    ```bash
    apt update
    ```
5. Install the `kubectl gadget` plug-in:

    ```bash
    apt install -y kubectl-gadget
    ```

---

Now, verify the installation by running the `version` command:

```bash
kubectl gadget version
```

The command output shows you the version of the client (`kubectl gadget` plug-in) and that it isn't installed yet on the server (the cluster):

```output
Client version: vX.Y.Z
Server version: not installed
```

#### Part 2: Deploy Inspektor Gadget in the cluster

The following command deploys the [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) controller.

Note

Several options are available to customize the deployment, as shown in the following list:

- Use a specific container image
- Deploy to specific nodes
- Deploy into a custom namespace

To learn about these options, see the [Installing in the cluster](https://go.microsoft.com/fwlink/?linkid=2260075#installing-in-the-cluster) section of the official documentation.

```bash
kubectl gadget deploy
```

Verify the installation by running the `version` command again:

```bash
kubectl gadget version
```

This time, the client and the server are both shown to be correctly installed:

```output
Client version: vX.Y.Z
Server version: vX.Y.Z
```

When deploying Inspektor Gadget with the `kubectl gadget` plug-in available in the Microsoft Cloud-Native repository, the container image used for the DaemonSet is automatically pulled from the Microsoft Container Registry (MCR):

```bash
kubectl get daemonset gadget -n gadget -o jsonpath='{.spec.template.spec.containers[*].image}'
```

```output
mcr.microsoft.com/oss/v2/inspektor-gadget/inspektor-gadget:vX.Y.Z
```

Note

If you use the [krew](https://sigs.k8s.io/krew) package manager to install kubectl plug-ins and prefer to install Inspektor Gadget directly from its GitHub repository, you can easily install the `kubectl gadget` plug-in and deploy Inspektor Gadget in your cluster using the following commands:

```bash
kubectl krew install gadget
kubectl gadget deploy
```

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.