---
layout: Conceptual
title: Capture a TCP dump from a Windows node in an AKS cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-tcp-dump-windows-node-aks
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
description: Learn how to capture a TCP dump from a Windows node in an AKS cluster, download trace files, and troubleshoot network issues—start now.
ms.date: 2024-10-14T00:00:00.0000000Z
ms.reviewer: erbookbi, jopalhei, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Monitoring and Logging
locale: en-us
document_id: f7ea088c-38ec-3513-506a-a4015598b06b
document_version_independent_id: f7ea088c-38ec-3513-506a-a4015598b06b
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/logs/capture-tcp-dump-windows-node-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/logs/capture-tcp-dump-windows-node-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/logs/capture-tcp-dump-windows-node-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c741f93e-f3f0-548e-e50e-6b1ae45a0862
---

# Capture a TCP dump from a Windows node in an AKS cluster - Azure | Microsoft Learn

## Summary

Networking problems can occur when you use a Microsoft Azure Kubernetes Service (AKS) cluster. To help you investigate these problems, this article explains how to capture a TCP dump from a Windows node in an AKS cluster, and then download the capture to your local machine.

## Prerequisites

- Azure CLI, version 2.0.59 or later. You can open [Azure Cloud Shell](/en-us/azure/cloud-shell/overview) in the web browser to enter Azure CLI commands. Or [install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli-windows) on your local machine. To find the version that's installed on your machine, run `az --version`.
- An AKS cluster. If you don't have an AKS cluster, [create one using Azure CLI](/en-us/azure/aks/kubernetes-walkthrough) or [through the Azure portal](/en-us/azure/aks/kubernetes-walkthrough-portal).

## Step 1: Find the nodes to troubleshoot

How do you determine which node to pull the TCP dump from? First, get the list of nodes in the AKS cluster by using the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/). Follow the instructions to connect to the cluster and run the `kubectl get nodes --output wide` command [using the Azure portal](/en-us/azure/aks/kubernetes-walkthrough-portal#connect-to-the-cluster) or [Azure CLI](/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster). A node list that's similar to the following output appears:

```output
$ kubectl get nodes --output wide
NAME                                STATUS   ROLES   AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION     CONTAINER-RUNTIME
akswin000000                        Ready    agent   3m8s    v1.20.9   10.240.0.4     <none>        Windows Server 2019 Datacenter   10.0.17763.2237    docker://20.10.6
akswin000001                        Ready    agent   3m50s   v1.20.9   10.240.0.115   <none>        Windows Server 2019 Datacenter   10.0.17763.2237    docker://20.10.6
akswin000002                        Ready    agent   3m32s   v1.20.9   10.240.0.226   <none>        Windows Server 2019 Datacenter   10.0.17763.2237    docker://20.10.6
```

## Step 2: Connect to a Windows node

The next step is to establish a connection to the AKS cluster node. Authenticate either by using a Secure Shell (SSH) key, or by using the Windows admin password in a Remote Desktop Protocol (RDP) connection. Both methods require creating an intermediate connection, because you can't currently connect directly to the AKS Windows node. Whether you connect to a node through SSH or RDP, you need to specify the user name for the AKS nodes. By default, this user name is *azureuser*. Besides using an SSH or RDP connection, you can connect to a Windows node from the HostProcess container.

# [HostProcess](#tab/hostprocess)
1. Create *hostprocess.yaml* with the following content. Replace `AKSWINDOWSNODENAME` with the AKS Windows node name.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        pod: hpc
      name: hpc
    spec:
      securityContext:
        windowsOptions:
          hostProcess: true
          runAsUserName: "NT AUTHORITY\\SYSTEM"
      hostNetwork: true
      containers:
        - name: hpc
          image: mcr.microsoft.com/windows/servercore:ltsc2022 # Use servercore:1809 for WS2019
          command:
            - powershell.exe
            - -Command
            - "Start-Sleep 2147483"
          imagePullPolicy: IfNotPresent
      nodeSelector:
        kubernetes.io/os: windows
        kubernetes.io/hostname: AKSWINDOWSNODENAME
      tolerations:
        - effect: NoSchedule
          key: node.kubernetes.io/unschedulable
          operator: Exists
        - effect: NoSchedule
          key: node.kubernetes.io/network-unavailable
          operator: Exists
        - effect: NoExecute
          key: node.kubernetes.io/unreachable
          operator: Exists
    ```
2. Run the `kubectl apply -f hostprocess.yaml` command to deploy the Windows HostProcess container in the specified Windows node.
3. Run the `kubectl exec -it [HPC-POD-NAME] -- powershell` command.
4. Run any PowerShell commands inside the HostProcess container to access the Windows node.

    Note

    To access the files in the Windows node, switch the root folder to `C:\` inside the HostProcess container.

# [SSH](#tab/ssh)
If you have an SSH key, [create an SSH connection to the Windows node](/en-us/azure/aks/ssh#create-the-ssh-connection-to-a-windows-node). The SSH key doesn't persist on your AKS nodes. The SSH key reverts to what was initially installed on the cluster during any:

- Reboot
- Version upgrade
- Node image upgrade

# [RDP](#tab/rdp)
If you don't have an SSH key, connect by using RDP and the Windows admin password. What if you don't have this password for your cluster? Then reset the password in Azure CLI by running the [az aks update](/en-us/cli/azure/aks#az-aks-update) command. Specify the resource group, cluster name, and the new password. The command displays the cluster details after it completes.

```azurecli
az aks update \
    --resource-group <myResourceGroup> \
    --name <myAKSCluster> \
    --windows-admin-password "<myNewPassword>"
```

By using your Windows admin password, [connect to the node with RDP](/en-us/azure/aks/rdp), which involves first deploying a "jump" virtual machine to the same subnet as your cluster.

### Redirect a data drive to the RDP connection

To transfer the capture files to your machine, you need to redirect a disk drive from your machine onto both the created virtual machine (VM) and the RDP connection to the AKS Windows node. This redirection lets you copy the capture files you generate later to your machine.

1. On your machine, select the Start menu, search for **Remote Desktop Connection**, and select it.
2. In the **Remote Desktop Connection** dialog box, select **Show Options**.

    ![Screenshot of the Remote Desktop Connection dialog box, with the Show Options expandable button highlighted.](media/capture-tcp-dump-windows-node-aks/remote-desktop-connection-show-options.png)
3. In the **Local Resources** tab, select **More**.

    ![Screenshot of the Remote Desktop Connection dialog box, with the Local Resources tab selected and the More button highlighted.](media/capture-tcp-dump-windows-node-aks/remote-desktop-connection-local-resources-more.png)
4. In a new **Remote Desktop Connection** dialog box, select **Drives** to expand the list of drives on your machine, and then select the drive you want to redirect.

    ![Screenshot of a new Remote Desktop Connection dialog box, showing the full expanded list of drives that you can choose to use in the remote session.](media/capture-tcp-dump-windows-node-aks/remote-desktop-connection-local-devices-and-resources.png)

Then finish connecting to the Windows virtual machine that you set up earlier.

---

## Step 3: Create a packet capture

When you connect to the Windows node through SSH or RDP, or from the HostProcess container, a form of the Windows command prompt appears:

```cmd
azureuser@akswin000000 C:\Users\azureuser>
```

Now open a command prompt and enter the [Network Shell](/en-us/windows-server/networking/technologies/netsh/netsh) (netsh) command for capturing traces ([netsh trace start](/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/jj129382%28v=ws.11%29#start)). This command starts the packet capture process.

```cmd
netsh trace start capture=yes tracefile=C:\temp\AKS_node_name.etl
```

Output appears that's similar to the following text:

```output
Trace configuration:
-------------------------------------------------------------------
Status:             Running
Trace File:         AKS_node_name.etl
Append:             Off
Circular:           On
Max Size:           250 MB
Report:             Off
```

While the trace is running, replicate your issue many times. This action ensures the issue is captured within the TCP dump. Note the time stamp while you replicate the issue. To stop the packet capture when you're done, enter `netsh trace stop`:

```output
azureuser@akswin000000 C:\Users\azureuser>netsh trace stop
Merging traces ... done
Generating data collection ... done
The trace file and additional troubleshooting information have been compiled as "C:\temp\AKS_node_name.cab".
File location = C:\temp\AKS_node_name.etl
Tracing session was successfully stopped.
```

## Step 4: Transfer the capture locally

# [HostProcess](#tab/hostprocess)
After you complete the packet capture, identify the HostProcess pod so that you can copy the dump locally.

1. On your local machine, open a second console, and then get a list of pods by running the `kubectl get pods` command:

    ```console
    kubectl get pods
    NAME                                                    READY   STATUS    RESTARTS   AGE
    azure-vote-back-6c4dd64bdf-m4nk7                        1/1     Running   2          3d21h
    azure-vote-front-85b4df594d-jhpzw                       1/1     Running   2          3d21h
    hpc                                                     1/1     Running   0          3m58s
    ```

    The HostProcess pod's default name is *hpc*, as shown in the third line.
2. Copy the TCP dump files locally by running the following commands. Replace the pod name with `hpc`.

    ```console
    kubectl cp -n default hpc:/temp/AKS_node_name.etl ./AKS_node_name.etl
    tar: Removing leading '/' from member names
    kubectl cp -n default hpc:/temp/AKS_node_name.etl ./AKS_node_name.cab
    tar: Removing leading '/' from member names
    ```

    The *.etl* and *.cab* files are now present in your local directory.

# [SSH](#tab/ssh)
After you complete the packet capture, identify the helper pod so you can copy the dump locally. Open a second console, and then get a list of pods by running `kubectl get pods`, as shown in the following example.

```console
kubectl get pods
NAME                                                    READY   STATUS    RESTARTS   AGE
azure-vote-back-6c4dd64bdf-m4nk7                        1/1     Running   2          3d21h
azure-vote-front-85b4df594d-jhpzw                       1/1     Running   2          3d21h
node-debugger-aks-nodepool1-38878740-vmss000000-6ztp6   1/1     Running   0          3m58s
```

The helper pod has a prefix of `node-debugger-aks`, as shown in the third row. Replace the pod name, and then run the following Secure Copy (scp) commands. These commands retrieve the event trace log (.etl) and archive (.cab) files, which are generated for the packet capture.

```console
scp -o 'ProxyCommand ssh -p 2022 -W %h:%p azureuser@127.0.0.1' azureuser@10.240.0.97:AKS_node_name.cab .
scp -o 'ProxyCommand ssh -p 2022 -W %h:%p azureuser@127.0.0.1' azureuser@10.240.0.97:AKS_node_name.etl .
```

You see output similar to the following text:

```output
$ scp -o 'ProxyCommand ssh -p 2022 -W %h:%p azureuser@127.0.0.1' azureuser@10.240.0.97:AKS_node_name.cab .

Authorized uses only. All activity may be monitored and reported.
AKS_node_name.cab                                                                  100%  571KB 984.0KB/s   00:00

scp -o 'ProxyCommand ssh -p 2022 -W %h:%p azureuser@127.0.0.1' azureuser@10.240.0.97:AKS_node_name.etl .

Authorized uses only. All activity may be monitored and reported.
AKS_node_name.etl                                                                  100% 1536KB   1.3MB/s   00:01
```

# [RDP](#tab/rdp)
First, transfer the TCP dump files from the AKS Windows node to the jump VM:

1. Connect to the AKS Windows node.
2. Run the following [net use](/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/gg651155%28v=ws.11%29) command to map the jump VM's shared resource to a drive name (z:). If the shared resource is something other than the c: drive, adjust the command.

    ```output
    C:\Users\bookbinder>net use z: \\tsclient\c
    The command completed successfully.
    ```
3. Run the following copy command to copy the TCP dump files to your jump VM:

    ```output
    C:\Users\azureuser>copy c:\temp\AKS_node_name.* z:\
    AKS_node_name.cab
    AKS_node_name.etl
            2 file(s) copied.
    ```

Now you can end your connection from the jump VM to the AKS Windows node. The two files you generated from the dump are now on the c: drive of the jump VM.

Next, copy the dump files from the jump VM to your machine:

1. In File Explorer on the jump VM, go to the root directory of your c: drive.
2. Choose the **AKS\_node\_name.cab** and **AKS\_node\_name.etl** files.
3. Drag the two files to the connection named **C on &lt;myComputerName&gt;**.

    [![Screenshot of File Explorer on the jump virtual machine. Drag AKS_node_name.cab and AKS_node_name.etl from the jump VM to your local machine drive.](media/capture-tcp-dump-windows-node-aks/jump-vm-file-explorer.png)](media/capture-tcp-dump-windows-node-aks/jump-vm-file-explorer.png#lightbox)

The dump files are now in the root directory of your machine's c: drive.

---