---
layout: Conceptual
title: RDP to AKS Windows Server nodes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/rdp
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
description: Learn how to create an RDP connection with Azure Kubernetes Service (AKS) cluster Windows Server nodes for troubleshooting and maintenance tasks.
ms.topic: how-to
ms.custom: devx-track-azurecli, devx-track-azurepowershell
ms.author: mattmcinnes
ms.date: 2023-04-26T00:00:00.0000000Z
author: schaffererin
locale: en-us
document_id: 052803c9-43d9-559f-10a6-004d614f5f13
document_version_independent_id: d8c46e3f-3445-2dfa-e21c-241ef89913d9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/rdp.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/rdp
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/rdp.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: bd58a75b-20b4-1937-426f-7491c149cd3b
---

# RDP to AKS Windows Server nodes - Azure Kubernetes Service | Microsoft Learn

Throughout the lifecycle of your Azure Kubernetes Service (AKS) cluster, you may need to access an AKS Windows Server node. This access could be for maintenance, log collection, or other troubleshooting operations. You can access the AKS Windows Server nodes using RDP. For security purposes, the AKS nodes aren't exposed to the internet.

Alternatively, if you want to SSH to your AKS Windows Server nodes, you need access to the same key-pair that was used during cluster creation. Follow the steps in [SSH into Azure Kubernetes Service (AKS) cluster nodes](ssh).

This article shows you how to create an RDP connection with an AKS node using their private IP addresses.

## Before you begin

# [Azure CLI](#tab/azure-cli)
This article assumes that you have an existing AKS cluster with a Windows Server node. If you need an AKS cluster, see the article on [creating an AKS cluster with a Windows container using the Azure CLI](learn/quick-windows-container-deploy-cli). You need the Windows administrator username and password for the Windows Server node you want to troubleshoot. You also need an RDP client such as [Microsoft Remote Desktop](https://aka.ms/rdmac).

If you need to reset the password, use `az aks update` to change the password.

```azurecli
az aks update --resource-group myResourceGroup --name myAKSCluster --windows-admin-password $WINDOWS_ADMIN_PASSWORD
```

If you need to reset the username and password, see [Reset Remote Desktop Services or its administrator password in a Windows VM](/en-us/troubleshoot/azure/virtual-machines/reset-rdp).

You also need the Azure CLI version 2.0.61 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

# [Azure PowerShell](#tab/azure-powershell)
This article assumes that you have an existing AKS cluster with a Windows Server node. If you need an AKS cluster, see the article on [creating an AKS cluster with a Windows container using the Azure PowerShell](learn/quick-windows-container-deploy-powershell). You need the Windows administrator username and password for the Windows Server node you want to troubleshoot. You also need an RDP client such as [Microsoft Remote Desktop](https://aka.ms/rdmac).

If you need to reset the password, use `Set-AzAksCluster` to change the password.

```azurepowershell
$cluster = Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster
$cluster.WindowsProfile.AdminPassword = $WINDOWS_ADMIN_PASSWORD
$cluster | Set-AzAksCluster
```

If you need to reset the username and password, see [Reset Remote Desktop Services or its administrator password in a Windows VM](/en-us/troubleshoot/azure/virtual-machines/reset-rdp).

You also need the Azure PowerShell version 7.5.0 or later installed and configured. Run `Get-InstalledModule -Name Az` to find the version. If you need to install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).

---

## Deploy a virtual machine to the same subnet as your cluster

The Windows Server nodes of your AKS cluster don't have externally accessible IP addresses. To make an RDP connection, you can deploy a virtual machine with a publicly accessible IP address to the same subnet as your Windows Server nodes.

The following example creates a virtual machine named *myVM* in the *myResourceGroup* resource group.

# [Azure CLI](#tab/azure-cli)
You need to get the subnet ID used by your Windows Server node pool and query for:

- The cluster's node resource group
- The virtual network
- The subnet's name
- The subnet ID

```azurecli
CLUSTER_RG=$(az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv)
VNET_NAME=$(az network vnet list --resource-group $CLUSTER_RG --query [0].name -o tsv)
SUBNET_NAME=$(az network vnet subnet list --resource-group $CLUSTER_RG --vnet-name $VNET_NAME --query [0].name -o tsv)
SUBNET_ID=$(az network vnet subnet show --resource-group $CLUSTER_RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)
```

Now that you've the SUBNET\_ID, run the following command in the same Azure Cloud Shell window to create the VM:

```azurecli
PUBLIC_IP_ADDRESS="myVMPublicIP"

az vm create \
    --resource-group myResourceGroup \
    --name myVM \
    --image win2019datacenter \
    --admin-username azureuser \
    --admin-password {admin-password} \
    --subnet $SUBNET_ID \
    --nic-delete-option delete \
    --os-disk-delete-option delete \
    --nsg "" \
    --public-ip-address $PUBLIC_IP_ADDRESS \
    --query publicIpAddress -o tsv
```

The following example output shows the VM has been successfully created and displays the public IP address of the virtual machine.

```console
13.62.204.18
```

Record the public IP address of the virtual machine. You'll use this address in a later step.

# [Azure PowerShell](#tab/azure-powershell)
You'll need to get the subnet ID used by your Windows Server node pool and query for:

- The cluster's node resource group
- The virtual network
- The subnet's name and address prefix
- The subnet ID

```azurepowershell
$CLUSTER_RG = (Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster).nodeResourceGroup
$VNET_NAME = (Get-AzVirtualNetwork -ResourceGroupName $CLUSTER_RG).Name
$ADDRESS_PREFIX = (Get-AzVirtualNetwork -ResourceGroupName $CLUSTER_RG).AddressSpace | Select-Object -ExpandProperty AddressPrefixes
$SUBNET_NAME = (Get-AzVirtualNetwork -ResourceGroupName $CLUSTER_RG).Subnets[0].Name
$SUBNET_ADDRESS_PREFIX = (Get-AzVirtualNetwork -ResourceGroupName $CLUSTER_RG).Subnets[0] | Select-Object -ExpandProperty AddressPrefix
```

Now that you have the VNet and subnet details, run the following commands in the same Azure Cloud Shell window to create the public IP address and VM:

```azurepowershell
$ipParams = @{
    Name              = 'myPublicIP'
    ResourceGroupName = 'myResourceGroup'
    Location          = 'eastus'
    AllocationMethod  = 'Dynamic'
    IpAddressVersion  = 'IPv4'
}
New-AzPublicIpAddress @ipParams

$vmParams = @{
    ResourceGroupName            = 'myResourceGroup'
    Name                         = 'myVM'
    Image                        = 'win2019datacenter'
    Credential                   = Get-Credential azureuser
    VirtualNetworkName           = $VNET_NAME
    AddressPrefix                = $ADDRESS_PREFIX
    SubnetName                   = $SUBNET_NAME
    SubnetAddressPrefix          = $SUBNET_ADDRESS_PREFIX
    PublicIpAddressName          = 'myPublicIP'
    OSDiskDeleteOption           = 'Delete'
    NetworkInterfaceDeleteOption = 'Delete'
    DataDiskDeleteOption         = 'Delete'
}
New-AzVM @vmParams

(Get-AzPublicIpAddress -ResourceGroupName myResourceGroup -Name myPublicIP).IpAddress
```

The following example output shows the VM has been successfully created and displays the public IP address of the virtual machine.

```console
13.62.204.18
```

Record the public IP address of the virtual machine and use the address in a later step.

---

## Allow access to the virtual machine

AKS node pool subnets are protected with NSGs (Network Security Groups) by default. To get access to the virtual machine, you'll have to enabled access in the NSG.

Note

The NSGs are controlled by the AKS service. Any change you make to the NSG will be overwritten at any time by the control plane.

# [Azure CLI](#tab/azure-cli)
First, get the resource group and name of the NSG to add the rule to:

```azurecli
CLUSTER_RG=$(az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv)
NSG_NAME=$(az network nsg list --resource-group $CLUSTER_RG --query [].name -o tsv)
```

Then, create the NSG rule:

```azurecli
az network nsg rule create \
 --name tempRDPAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 100 \
 --destination-port-range 3389 \
 --protocol Tcp \
 --description "Temporary RDP access to Windows nodes"
```

# [Azure PowerShell](#tab/azure-powershell)
First, get the resource group and name of the NSG to add the rule to:

```azurepowershell
$CLUSTER_RG = (Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster).nodeResourceGroup
$NSG_NAME = (Get-AzNetworkSecurityGroup -ResourceGroupName $CLUSTER_RG).Name
```

Then, create the NSG rule:

```azurepowershell
$nsgRuleParams = @{
    Name                     = 'tempRDPAccess'
    Access                   = 'Allow'
    Direction                = 'Inbound'
    Priority                 = 100
    SourceAddressPrefix      = 'Internet'
    SourcePortRange          = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange     = '3389'
    Protocol                 = 'Tcp'
    Description              = 'Temporary RDP access to Windows nodes'
}
Get-AzNetworkSecurityGroup -Name $NSG_NAME -ResourceGroupName $CLUSTER_RG | Add-AzNetworkSecurityRuleConfig @nsgRuleParams | Set-AzNetworkSecurityGroup
```

---

## Get the node address

# [Azure CLI](#tab/azure-cli)
To manage a Kubernetes cluster, you use [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client. If you use Azure Cloud Shell, `kubectl` is already installed. To install `kubectl` locally, use the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command:

```azurecli
az aks install-cli
```

To configure `kubectl` to connect to your Kubernetes cluster, use the [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

```azurecli
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

# [Azure PowerShell](#tab/azure-powershell)
To manage a Kubernetes cluster, you use [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client. If you use Azure Cloud Shell, `kubectl` is already installed. To install `kubectl` locally, use the [Install-AzAksKubectl](/en-us/powershell/module/az.aks/install-azaksclitool) cmdlet:

```azurepowershell
Install-AzAksKubectl
```

To configure `kubectl` to connect to your Kubernetes cluster, use the [Import-AzAksCredential](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. This command downloads credentials and configures the Kubernetes CLI to use them.

```azurepowershell
Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
```

---

List the internal IP address of the Windows Server nodes using the [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command:

```console
kubectl get nodes -o wide
```

The following example output shows the internal IP addresses of all the nodes in the cluster, including the Windows Server nodes.

```console
$ kubectl get nodes -o wide
NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                    KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-42485177-vmss000000   Ready    agent   18h   v1.12.7   10.240.0.4    <none>        Ubuntu 16.04.6 LTS          4.15.0-1040-azure   docker://3.0.4
aksnpwin000000                      Ready    agent   13h   v1.12.7   10.240.0.67   <none>        Windows Server Datacenter   10.0.17763.437
```

Record the internal IP address of the Windows Server node you wish to troubleshoot. You'll use this address in a later step.

## Connect to the virtual machine and node

Connect to the public IP address of the virtual machine you created earlier using an RDP client such as [Microsoft Remote Desktop](https://aka.ms/rdmac).

![Image of connecting to the virtual machine using an RDP client](media/rdp/vm-rdp.png)

After you have connected to your virtual machine, connect to the *internal IP address* of the Windows Server node you want to troubleshoot using an RDP client from within your virtual machine.

![Image of connecting to the Windows Server node using an RDP client](media/rdp/node-rdp.png)

You're now connected to your Windows Server node.

![Image of cmd window in the Windows Server node](media/rdp/node-session.png)

You can now run any troubleshooting commands in the *cmd* window. Since Windows Server nodes use Windows Server Core, there's not a full GUI or other GUI tools when you connect to a Windows Server node over RDP.

## Remove RDP access

# [Azure CLI](#tab/azure-cli)
When done, exit the RDP connection to the Windows Server node then exit the RDP session to the virtual machine. After you exit both RDP sessions, delete the virtual machine with the [az vm delete](/en-us/cli/azure/vm#az-vm-delete) command:

```azurecli
# Delete the virtual machine
az vm delete \
 --resource-group myResourceGroup \
 --name myVM
```

Delete the public IP associated with the virtual machine:

```azurecli
az network public-ip delete \
 --resource-group myResourceGroup \
 --name $PUBLIC_IP_ADDRESS
```

Delete the NSG rule:

```azurecli
CLUSTER_RG=$(az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv)
NSG_NAME=$(az network nsg list --resource-group $CLUSTER_RG --query [].name -o tsv)
az network nsg rule delete \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --name tempRDPAccess
```

# [Azure PowerShell](#tab/azure-powershell)
When done, exit the RDP connection to the Windows Server node then exit the RDP session to the virtual machine. After you exit both RDP sessions, delete the virtual machine with the [Remove-AzVM](/en-us/powershell/module/az.compute/remove-azvm) command:

```azurepowershell
Remove-AzVM -ResourceGroupName myResourceGroup -Name myVM
```

Delete the public IP associated with the virtual machine:

```azurepowershell
Remove-AzPublicIpAddress -ResourceGroupName myResourceGroup -Name myPublicIP
```

Delete the NSG rule:

```azurepowershell
$CLUSTER_RG = (Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster).nodeResourceGroup
$NSG_NAME = (Get-AzNetworkSecurityGroup -ResourceGroupName $CLUSTER_RG).Name

Get-AzNetworkSecurityGroup -Name $NSG_NAME -ResourceGroupName $CLUSTER_RG | Remove-AzNetworkSecurityRuleConfig -Name tempRDPAccess | Set-AzNetworkSecurityGroup
```

Delete the NSG created by default from New-AzVM:

```azurepowershell
Remove-AzNetworkSecurityGroup -ResourceGroupName myResourceGroup -Name myVM
```

---

## Connect with Azure Bastion

Alternatively, you can use [Azure Bastion](/en-us/azure/bastion/bastion-overview) to connect to your Windows Server node.

### Deploy Azure Bastion

To deploy Azure Bastion, you'll need to find the virtual network your AKS cluster is connected to.

1. In the Azure portal, go to **Virtual networks**. Select the virtual network your AKS cluster is connected to.
2. Under **Settings**, select **Bastion**, then select **Deploy Bastion**. Wait until the process is finished before going to the next step.

### Connect to your Windows Server nodes using Azure Bastion

Go to the node resource group of the AKS cluster. Run the command below in the Azure Cloud Shell to get the name of your node resource group:

# [Azure CLI](#tab/azure-cli)
```azurecli
az aks show --name myAKSCluster --resource-group myResourceGroup --query 'nodeResourceGroup' -o tsv
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
(Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster).nodeResourceGroup
```

---

1. Select **Overview**, and select your Windows node pool virtual machine scale set.
2. Under **Settings**, select **Instances**. Select a Windows server node that you'd like to connect to.
3. Under **Support + troubleshooting**, select **Bastion**.
4. Enter the credentials you set up when the AKS cluster was created. Select **Connect**.

You can now run any troubleshooting commands in the *cmd* window. Since Windows Server nodes use Windows Server Core, there's not a full GUI or other GUI tools when you connect to a Windows Server node over RDP.

Note

If you close out of the terminal window, press **CTRL + ALT + End**, select **Task Manager**, select **More details**, select **File**, select **Run new task**, and enter **cmd.exe** to open another terminal. You can also logout and re-connect with Bastion.

### Remove Bastion access

When you're finished, exit the Bastion session and remove the Bastion resource.

1. In the Azure portal, go to **Bastion** and select the Bastion resource you created.
2. At the top of the page, select **Delete**. Wait until the process is complete before proceeding to the next step.
3. In the Azure portal, go to **Virtual networks**. Select the virtual network that your AKS cluster is connected to.
4. Under **Settings**, select **Subnet**, and delete the **AzureBastionSubnet** subnet that was created for the Bastion resource.