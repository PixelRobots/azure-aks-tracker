---
layout: Conceptual
title: Validate Signed Container Images for AKS on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/validate-signed-container-images
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to validate signed container images for AKS on Azure Local deployments to ensure image integrity and prevent supply chain attacks.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.reviewer: leslielin
ms.lastreviewed: 2025-07-25T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: ca703119-3c30-7b64-ebc2-c8f3235ec5d4
document_version_independent_id: d5727f4f-ea64-0b26-8b55-ed60f8031425
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/validate-signed-container-images.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/validate-signed-container-images
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/validate-signed-container-images.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: 9de5dc64-9b14-919f-749e-2327532ce0f9
---

# Validate Signed Container Images for AKS on Azure Local | Microsoft Learn

> 
> Applies to: AKS on Azure Local

Container image signing verifies the integrity and authenticity of images before deployment, ensuring a trusted infrastructure. This verification is vital in production environments, regulated industries, and automated CI/CD pipelines, where validating image sources helps to both prevent supply chain attacks and maintain compliance.

This article describes how to validate signed container images for AKS on Azure Local deployments.

## Prerequisites

Before you begin, ensure you have the following prerequisites:

1. **Cluster configuration:** Deploy an AKS cluster with these requirements

    - One control plane node.
    - At least one Linux node.
    - (Optional) Add a Windows node pool if you need to validate Windows container images.
2. **A Windows machine jump box** is required to run the image validation script. The machine must meet these prerequisites:

    - **Network access**: The jump box must be able to communicate with the Azure Local physical boxes where the AKS cluster is deployed and route traffic to the IP addresses assigned to the AKS cluster, including all control plane and worker nodes.
    - **Required tools installed**: Install these tools on the jump box: **curl**, **ssh**, and **scp**. These tools enable secure remote access, file transfers, and HTTP-based interactions with your cluster or management endpoints.
    - **SSH access**: The private SSH key used during cluster creation must be present on the jump box.
        - This key enables connections to individual nodes (Linux or Windows).
        - For details on generating or retrieving the key, see [Configure SSH keys for a cluster](/en-us/azure/aks/aksarc/configure-ssh-keys).
3. **Install the Kubernetes CLI**

    You can use the Kubernetes CLI, [kubectl](https://kubernetes.io/docs/reference/kubectl/), to connect to your Kubernetes cluster. Use the following Azure CLI or Azure PowerShell commands to install **kubectl**:

# [Azure CLI](#tab/cli)
Install **kubectl** locally using the [az aks install-cli](/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-install-cli&amp;preserve-view=true) command.

# [PowerShell](#tab/powershell)
Install **kubectl** locally using the [Install-AzAksCliTool](/en-us/powershell/module/az.aks/install-azaksclitool?view=azps-14.2.0&amp;preserve-view=true) cmdlet.

---

## Step 1: download the image validation script

1. Open a PowerShell window as an administrator and create a temporary folder at **c:\imagesign**:

    ```powershell
    mkdir c:\imagesign
    cd c:\imagesign
    ```
2. Run the following commands to download the [prerequisite.ps1](https://raw.githubusercontent.com/Azure/aksArc/refs/heads/main/scripts/ImageSignValidation/prerequisite.ps1) script to the jump box and save it in **c:\imagesign**:

    ```powershell
    $giturl = "https://raw.githubusercontent.com/Azure/aksArc/refs/heads/main/scripts/ImageSignValidation/prerequisite.ps1"
    Invoke-WebRequest -Uri $giturl -OutFile C:\imagesign\prerequisite.ps1 -UseBasicParsing
    Unblock-File .\prerequisite.ps1
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    ```
3. Execute the script

    ```powershell
    .\prerequisite.ps1
    ```

    Sample output:

    ```output
    2025-05-10 00:39:27 [INFO] The current folder is C:\imagesign
    2025-05-10 00:39:27 [INFO] Linux folder location is C:\imagesign\linux
    2025-05-10 00:39:28 [INFO] Executable not found at C:\imagesign\linux\notation. Proceeding with download and extraction.
    2025-05-10 00:39:28 [INFO] Downloading file from https://github.com/notaryproject/notation/releases/download/v1.3.1/notation_1.3.1_linux_amd64.tar.gz
    2025-05-10 00:39:36 [INFO] Extracting file to C:\imagesign\linux
    2025-05-10 00:39:36 [INFO] Downloading certificate from https://www.microsoft.com/pkiops/certs/Microsoft%20Supply%20Chain%20RSA%20Root%20CA%202022.crt
    2025-05-10 00:39:36 [INFO] Certificate downloaded to C:\imagesign\linux\ca.crt
    2025-05-10 00:39:36 [INFO] Downloading certificate from http://www.microsoft.com/pki/certs/MicRooCerAut_2010-06-23.crt
    2025-05-10 00:39:36 [INFO] Certificate downloaded to C:\imagesign\linux\tsa.crt
    2025-05-10 00:39:36 [INFO] Windows folder location is C:\imagesign\win
    2025-05-10 00:39:36 [INFO] Executable not found at C:\imagesign\win\notation.exe. Proceeding with download and extraction.
    2025-05-10 00:39:36 [INFO] Downloading file from https://github.com/notaryproject/notation/releases/download/v1.3.1/notation_1.3.1_windows_amd64.zip
    2025-05-10 00:39:44 [INFO] Extracting file to C:\imagesign\win
    2025-05-10 00:39:44 [INFO] Downloading certificate from https://www.microsoft.com/pkiops/certs/Microsoft%20Supply%20Chain%20RSA%20Root%20CA%202022.crt
    2025-05-10 00:39:44 [INFO] Certificate downloaded to C:\imagesign\win\ca.crt
    2025-05-10 00:39:44 [INFO] Downloading certificate from http://www.microsoft.com/pki/certs/MicRooCerAut_2010-06-23.crt
    2025-05-10 00:39:44 [INFO] Certificate downloaded to C:\imagesign\win\tsa.crt
    ```
4. Two folders will be created: **linux** for Linux files and **win** for Windows files.

# [Linux](#tab/linux)
Copy **LinuxImageValidate.py** to the **c:\imagesign\linux** folder:

    ```powershell
    $giturllinux = "https://raw.githubusercontent.com/Azure/aksArc/refs/heads/main/scripts/ImageSignValidation/LinuxImageValidate.py"
    Invoke-WebRequest -Uri $giturllinux -OutFile C:\imagesign\linux\LinuxImageValidate.py -UseBasicParsing
    Unblock-File C:\imagesign\linux\LinuxImageValidate.py
    ```

# [Windows](#tab/windows)
Copy **WindowsImageValidate.ps1** to the **c:\imagesign\win** folder:

    ```powershell
    $giturlwin = "https://raw.githubusercontent.com/Azure/aksArc/refs/heads/main/scripts/ImageSignValidation/WindowsImageValidate.ps1"
    Invoke-WebRequest -Uri $giturlwin -OutFile C:\imagesign\win\WindowsImageValidate.ps1 -UseBasicParsing
    Unblock-File C:\imagesign\win\WindowsImageValidate.ps1
    Invoke-WebRequest -Uri $giturlwin -OutFile C:\imagesign\win\WindowsImageValidate.py -UseBasicParsing
    Unblock-File C:\imagesign\win\WindowsImageValidate.py
    ```

---

## Step 2: get the control plane and worker node IP addresses

Follow steps 1 and 2 in the [Use SSH to connect to worker nodes](ssh-connect-to-windows-and-linux-worker-nodes#use-ssh-to-connect-to-worker-nodes) section to obtain IP addresses.

### Sample command

```powershell
kubectl --kubeconfig /path/to/aks-cluster-kubeconfig get nodes -o wide
```

Sample output:

| NAME | STATUS | ROLES | AGE | VERSION | INTERNAL-IP | EXTERNAL-IP | OS-IMAGE | KERNEL-VERSION | CONTAINER-RUNTIME |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| moc-lsbe393il9d | Ready | control-plane | 3h14m | 1.30.4 | 100.0.12.133 | None | CBL-Mariner/Linux | 5.15.173.1-2.cm2 | containerd://1.6.26 |
| moc-lzwagtkjah5 | Ready | None | 3h12m | 1.30.4 | 100.0.12.134 | None | CBL-Mariner/Linux | 5.15.173.1-2.cm2 | containerd://1.6.26 |
| moc-wlcjnwn5n02 | Ready | None | 14m | 1.30.4 | 100.0.12.135 | None | Windows Server 2022 Datacenter | 10.0.20348.2700 | containerd://1.6.21+Azure |

From this sample output:

- Control plane IP is 100.0.12.133 (where the ROLES value is `control-plane` and OS image is `CBL-Mariner/Linux`).
- Linux node IP is 100.0.12.134 (where the ROLES value is `none` and OS image is `CBL-Mariner/Linux`).
- Windows node IP is 100.0.12.135 (where the OS image is `Windows Server 2022`).

## Step 3: run the image validation script on the control plane and worker nodes

# [Linux](#tab/linux)
These steps work for both the control plane node and Linux worker node since they use the **CBL-Mariner/Linux** OS image.

1. Check if the commands can be run on the Linux VM (assuming the private key is in **C:\Users\Administrator.ssh**):

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" -o StrictHostKeyChecking=no clouduser@100.0.12.133 "sudo crictl images --no-trunc"
    ```
2. Copy the Linux-specific files to the Linux VM:

    ```bash
    scp -i "C:\Users\Administrator\.ssh\id_rsa" C:\imagesign\linux\* clouduser@100.0.12.133:.
    ```
3. Mark the notation binary file as executable:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" -o StrictHostKeyChecking=no clouduser@100.0.12.133 "sudo chmod +x notation"
    ```
4. Execute commands to validate image signature verification. This step can take around 2-5 minutes:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" -o StrictHostKeyChecking=no clouduser@100.0.12.133 "sudo python3 LinuxImageValidate.py"
    ```
5. Copy the output file to the local directory:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" -o StrictHostKeyChecking=no clouduser@100.0.12.133 "sudo cat imagevalidation_results_linux.json" > imagevalidation_results_controlplane.json
    ```
6. Clean up all files copied to the VM:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" -o StrictHostKeyChecking=no clouduser@100.0.12.133 rm LinuxImageValidate.py notation tsa.crt ca.crt LICENSE imagevalidation_results_linux.json results.yaml
    ```
7. Clean up the IP reference from the SSH cache:

    ```bash
    ssh-keygen -R 100.0.12.133
    ```

    Sample output:

    ```output
    {
     "failed_signed_images": [
     "mcr.microsoft.com/mssql/server:2017-latest",
     "mcr.microsoft.com/oss/kubernetes/coredns:v1.9.3",
     "mcr.microsoft.com/oss/kubernetes/pause:3.9"
     ],
     "passed_signed_images": [
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.28.3",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.28.5",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.28.9",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.29.2",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.29.4",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.29.7",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.29.9",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.30.3",
     "mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.30.4",
     "mcr.microsoft.com/oss/kubernetes/kube-rbac-proxy:v0.18.1",
     "mcr.microsoft.com/oss/kubernetes/kube-scheduler:v1.28.12-hotfix.20240719",
     "mcr.microsoft.com/oss/kubernetes/kube-scheduler:v1.28.14-hotfix.20240918",
     "mcr.microsoft.com/oss/kubernetes/kube-scheduler:v1.29.7",
     "mcr.microsoft.com/oss/kubernetes/kube-scheduler:v1.29.9",
     "mcr.microsoft.com/oss/kubernetes/kube-scheduler:v1.30.3",
     "mcr.microsoft.com/oss/kubernetes/kube-scheduler:v1.30.4",
     "mcr.microsoft.com/oss/kubernetes/pause:3.9-hotfix-20230808",
     "mcr.microsoft.com/oss/v2/kubernetes-csi/csi-driver-nfs:v4.9.0-1"
     ]
    }
    ```

    Note

    If the **failed\_signed\_images** list is empty, all images are signed correctly. Otherwise, the list shows images that failed signature verification.

# [Windows](#tab/windows)
These steps work on all supported Windows OS worker nodes.

1. Check if the commands can be run on the Windows VM (assuming the private key is in folder **C:\Users\Administrator.ssh**):

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" -o StrictHostKeyChecking=no Administrator@100.0.12.135 "crictl images --no-trunc"
    ```
2. Copy the Windows-specific files inside the Windows VM:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" Administrator@100.0.12.135 "powershell -ExecutionPolicy Bypass mkdir c:\win"
    scp -i "C:\Users\Administrator\.ssh\id_rsa" C:\imagesign\win\ca.crt Administrator@100.0.12.135:c:\win\ca.crt
    scp -i "C:\Users\Administrator\.ssh\id_rsa" C:\imagesign\win\notation.exe Administrator@100.0.12.135:c:\win\notation.exe
    scp -i "C:\Users\Administrator\.ssh\id_rsa" C:\imagesign\win\tsa.crt Administrator@100.0.12.135:c:\win\tsa.crt
    scp -i "C:\Users\Administrator\.ssh\id_rsa" C:\imagesign\win\WindowsImageValidate.ps1 Administrator@100.0.12.135:c:\win\WindowsImageValidate.ps1
    ```
3. Execute commands to validate image signature verification. This step can take around 2-5 minutes:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" Administrator@100.0.12.135 "powershell -ExecutionPolicy Bypass -File c:\win\WindowsImageValidate.ps1"
    ```
4. Copy the output file to the local directory:

    ```bash
    scp -i "C:\Users\Administrator\.ssh\id_rsa" Administrator@100.0.12.135:c:\win\imagevalidation_results_windows.json C:\imagesign\imagevalidation_results_windows.json
    ```
5. Clean up all files copied to the VM:

    ```bash
    ssh -i "C:\Users\Administrator\.ssh\id_rsa" Administrator@100.0.12.135 "powershell -ExecutionPolicy Bypass remove-item -force c:\win"
    ```
6. Clean up IP reference from the SSH cache:

    ```bash
    ssh-keygen -R 100.0.12.135
    ```

    Sample output:

    ```output
    {
     "failed_signed_images": [
     ],
     "passed_signed_images": [
     "mcr.microsoft.com/oss/kubernetes-csi/livenessprobe@sha256:20fd8754d36efc52ff0a837e646909102be5d47600a8656804aecd4eff52b7c7",
     "mcr.microsoft.com/oss/kubernetes/pause@sha256:2b5d81a9d7f04299f45ed1b6822de018188f463914fcbf5592f39087c9adead1",
     "mcr.microsoft.com/windows/nanoserver@sha256:f82cb05e20c4bfa93a007c9f073f83febd8bc6d16f98a3208f3baa486aafcdf4"
     ],
     "failed_signed_images": [
     ]
    }
    ```

    Note

    If the **failed\_signed\_images** list is empty, all images are signed correctly. Otherwise, the list shows images that failed signature verification.

---