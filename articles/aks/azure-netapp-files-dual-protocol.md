---
layout: Conceptual
title: Provision Azure NetApp Files dual-protocol volumes for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-dual-protocol
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
description: Describes how to statically provision Azure NetApp Files dual-protocol volumes for Azure Kubernetes Service.
ms.topic: concept-article
ms.custom: 
ms.subservice: aks-storage
ms.date: 2024-11-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: a3df983a-00b1-b6ed-63e1-f4a2e5d42c6b
document_version_independent_id: 6180b91b-d0b5-be5a-d244-11a2ccb0c8c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-netapp-files-dual-protocol.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-netapp-files-dual-protocol
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-netapp-files-dual-protocol.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/817763f1-a87f-4500-8c55-f33726ccb985
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/96abba6e-173c-4fc4-bcc8-79d583b4fe9f
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6a2a2610-d0e8-df7b-d52a-a86e47356092
---

# Provision Azure NetApp Files dual-protocol volumes for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

After you [configure Azure NetApp Files for Azure Kubernetes Service](azure-netapp-files), you can provision Azure NetApp Files volumes for Azure Kubernetes Service.

Azure NetApp Files supports volumes using [NFS](azure-netapp-files-nfs) (NFSv3 or NFSv4.1), [SMB](azure-netapp-files-smb), and dual-protocol (NFSv3 and SMB, or NFSv4.1 and SMB).

This article shows you how to statically provisioning volumes for dual-protocol access using NFS or SMB.

## Before you begin

- Make sure you have already created a dual-protocol volume. See [create a dual-protocol volume for Azure NetApp Files](/en-us/azure/azure-netapp-files/create-volumes-dual-protocol).

## Provision a dual-protocol volume in Azure Kubernetes Service

This section describes how to expose an Azure NetApp Files dual-protocol volume statically to Kubernetes. Instructions are provided for both SMB and NFS protocols. You can expose the same volume via SMB to Windows worker nodes and via NFS to Linux worker nodes.

# [NFS](#tab/nfs)
### Create the persistent volume for NFS

1. Define variables for later usage. Replace *myresourcegroup*, *myaccountname*, *mypool1*, *myvolname* with an appropriate value from your dual-protocol volume.

    ```azurecli
    RESOURCE_GROUP="myresourcegroup"
    ANF_ACCOUNT_NAME="myaccountname"
    POOL_NAME="mypool1"
    VOLUME_NAME="myvolname"
    ```
2. List the details of your volume using the [`az netappfiles volume show`](/en-us/cli/azure/netappfiles/volume#az-netappfiles-volume-show) command.

    ```azurecli
    az netappfiles volume show \
        --resource-group $RESOURCE_GROUP \
        --account-name $ANF_ACCOUNT_NAME \
        --pool-name $POOL_NAME \
        --volume-name $VOLUME_NAME -o JSON
    ```

    The following output is an example of the above command executed with real values.

    ```output
    {
      ...
      "creationToken": "myfilepath2",
      ...
      "mountTargets": [
        {
          ...
          "ipAddress": "10.0.0.4",
          ...
        }
      ],
      ...
    }
    ```
3. Create a file named `pv-nfs.yaml` and copy in the following YAML. Make sure the server matches the output IP address from the previous step, and the path matches the output from `creationToken` above. The capacity must also match the volume size from Step 2.

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-nfs
    spec:
      capacity:
        storage: 100Gi
      accessModes:
        - ReadWriteMany
      mountOptions:
        - vers=3
      nfs:
        server: 10.0.0.4
        path: /myfilepath2
    ```
4. Create the persistent volume using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f pv-nfs.yaml
    ```
5. Verify the status of the persistent volume is *Available* by using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command:

    ```bash
    kubectl describe pv pv-nfs
    ```

### Create a persistent volume claim for NFS

1. Create a file named `pvc-nfs.yaml` and copy in the following YAML. This manifest creates a PVC named `pvc-nfs` for 100Gi storage and `ReadWriteMany` access mode, matching the PV you created.

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-nfs
    spec:
      accessModes:
        - ReadWriteMany
      storageClassName: ""
      resources:
        requests:
          storage: 100Gi
    ```
2. Create the persistent volume claim using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f pvc-nfs.yaml
    ```
3. Verify the *Status* of the persistent volume claim is *Bound* by using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command:

    ```bash
    kubectl describe pvc pvc-nfs
    ```

### Mount within a pod using NFS

1. Create a file named `nginx-nfs.yaml` and copy in the following YAML. This manifest defines a `nginx` pod that uses the persistent volume claim.

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: nginx-nfs
    spec:
      containers:
      - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
        name: nginx-nfs
        command:
        - "/bin/sh"
        - "-c"
        - while true; do echo $(date) >> /mnt/azure/outfile; sleep 1; done
        volumeMounts:
        - name: disk01
          mountPath: /mnt/azure
      volumes:
      - name: disk01
        persistentVolumeClaim:
          claimName: pvc-nfs
    ```
2. Create the pod using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)[kubectl-apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f nginx-nfs.yaml
    ```
3. Verify the pod is *Running* by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl describe pod nginx-nfs
    ```
4. Verify your volume has been mounted on the pod by using [`kubectl exec`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) to connect to the pod, and then use `df -h` to check if the volume is mounted.

    ```bash
    kubectl exec -it nginx-nfs -- sh
    ```

    ```output
    / # df -h
    Filesystem             Size  Used Avail Use% Mounted on
    ...
    10.0.0.4:/myfilepath2  100T  384K  100T   1% /mnt/azure
    ...
    ```

# [SMB](#tab/smb)
### Create a secret with the domain credentials

1. Create a secret on your AKS cluster to access the AD server using the [`kubectl create secret`](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/) command. This secret will be used by the Kubernetes persistent volume to access the Azure NetApp Files SMB volume. Use the following command to create the secret, replacing `USERNAME` with your username, `PASSWORD` with your password, and `DOMAIN_NAME` with your Active Directory domain name.

```bash
kubectl create secret generic smbcreds --from-literal=username=USERNAME --from-literal=password="PASSWORD" --from-literal=domain='DOMAIN_NAME'
```

1. To verify the secret has been created, run the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

```bash
kubectl get secret
```

```output
NAME       TYPE     DATA   AGE
smbcreds   Opaque   2      20h
```

### Install an SMB CSI driver

You must install a Container Storage Interface (CSI) driver to create a Kubernetes SMB `PersistentVolume`.

1. Install the SMB CSI driver on your cluster using helm. Be sure to set the `windows.enabled` option to `true`:

    ```bash
    helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts   
    helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.10.0 –-set windows.enabled=true
    ```

    For other methods of installing the SMB CSI Driver, see [Install SMB CSI driver master version on a Kubernetes cluster](https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/install-csi-driver-master.md).
2. Verify the `csi-smb` controller pod is running and each worker node has a pod running using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command:

    ```bash
    kubectl get pods -n kube-system | grep csi-smb
    ```

    ```output
    csi-smb-controller-68df7b4758-xf2m9   3/3     Running   0          3m46s
    csi-smb-node-s6clj                    3/3     Running   0          3m47s
    csi-smb-node-win-tfxvk                3/3     Running   0          3m47s
    ```

### Create the persistent volume for SMB

1. Define variables for later usage. Replace *myresourcegroup*, *myaccountname*, *mypool1*, *myvolname* with an appropriate value from your dual-protocol volume.

    ```azurecli
    RESOURCE_GROUP="myresourcegroup"
    ANF_ACCOUNT_NAME="myaccountname"
    POOL_NAME="mypool1"
    VOLUME_NAME="myvolname"
    ```
2. List the details of your volume using [`az netappfiles volume show`](/en-us/cli/azure/netappfiles/volume#az-netappfiles-volume-show) command.

    ```azurecli
    az netappfiles volume show \
        --resource-group $RESOURCE_GROUP \
        --account-name $ANF_ACCOUNT_NAME \
        --pool-name $POOL_NAME \
        --volume-name "$VOLUME_NAME -o JSON
    ```

    The following output is an example of the above command executed with real values.

    ```output
    {
      ...
      "creationToken": "myvolname",
      ...
      "mountTargets": [
        {
          ...
          "
             "smbServerFqdn": "ANF-1be3.contoso.com",
          ...
        }
      ],
      ...
    }
    ```
3. Create a file named `pv-smb.yaml` and copy in the following YAML. If necessary, replace `myvolname` with the `creationToken` and replace `ANF-1be3.contoso.com\myvolname` with the value of `smbServerFqdn` from the previous step. Be sure to include your AD credentials secret along with the namespace where it's located that you created in a prior step.

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: anf-pv-smb
    spec:
      storageClassName: ""
      capacity:
        storage: 100Gi
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain
      mountOptions:
        - dir_mode=0777
        - file_mode=0777
        - vers=3.0
      csi:
        driver: smb.csi.k8s.io
        readOnly: false
        volumeHandle: myvolname  # make sure it's a unique name in the cluster
        volumeAttributes:
          source: \\ANF-1be3.contoso.com\myvolname
        nodeStageSecretRef:
          name: smbcreds
          namespace: default
    ```
4. Create the persistent volume using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f pv-smb.yaml
    ```
5. Verify the status of the persistent volume is *Available* using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command:

    ```bash
    kubectl describe pv anf-pv-smb
    ```

### Create a persistent volume claim for SMB

1. Create a file name `pvc-smb.yaml` and copy in the following YAML.

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: anf-pvc-smb
    spec:
      accessModes:
        - ReadWriteMany
      volumeName: anf-pv-smb
      storageClassName: ""
      resources:
        requests:
          storage: 100Gi
    ```
2. Create the persistent volume claim using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f pvc-smb.yaml
    ```

    Verify the status of the persistent volume claim is *Bound* by using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command:

    ```bash
    kubectl describe pvc anf-pvc-smb
    ```

### Mount within a pod using SMB

1. Create a file named `iis-smb.yaml` and copy in the following YAML. This file will be used to create an Internet Information Services pod to mount the volume to path `/inetpub/wwwroot`.

    ```yaml
    apiVersion: v1
    kind: Pod 
    metadata:
      name: iis-pod
      labels:
         app: web
    spec:
      nodeSelector:
        "kubernetes.io/os": windows
      volumes:
      - name: smb
        persistentVolumeClaim:
          claimName: anf-pvc-smb 
      containers:
      - name: web
        image: mcr.microsoft.com/windows/servercore/iis:windowsservercore 
        resources:
          limits:
            cpu: 1
            memory: 800M
        ports:
          - containerPort: 80
        volumeMounts:
        - name: smb
          mountPath: "/inetpub/wwwroot"
          readOnly: false
    ```
2. Create the pod using the [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f iis-smb.yaml
    ```
3. Verify the pod is *Running* and `/inetpub/wwwroot` is mounted from SMB by using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command:

    ```bash
    kubectl describe pod iis-pod
    ```

    The output of the command resembles the following example:

    ```output
    Name:         iis-pod
    Namespace:    default
    Priority:     0
    Node:         akswin000001/10.225.5.246
    Start Time:   Fri, 05 May 2023 09:34:41 -0400
    Labels:       app=web
    Annotations:  <none>
    Status:       Running
    IP:           10.225.5.248
    IPs:
      IP:  10.225.5.248
    Containers:
      web:
        Container ID:   containerd://39a1659b6a2b6db298df630237b2b7d959d1b1722edc81ce9b1bc7f06237850c
        Image:          mcr.microsoft.com/windows/servercore/iis:windowsservercore
        Image ID:       mcr.microsoft.com/windows/servercore/iis@sha256:0f0114d0f6c6ee569e1494953efdecb76465998df5eba951dc760ac5812c7409
        Port:           80/TCP
        Host Port:      0/TCP
        State:          Running
          Started:      Fri, 05 May 2023 09:34:55 -0400
        Ready:          True
        Restart Count:  0
        Limits:
          cpu:     1
          memory:  800M
        Requests:
          cpu:        1
          memory:     800M
        Environment:  <none>
        Mounts:
          /inetpub/wwwroot from smb (rw)
          /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mbnv8 (ro)
    ...
    ```
4. Verify your volume has been mounted on the pod by using the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command to connect to the pod. Then use the `dir` command in the correct directory to check if the volume is mounted and the size matches the size of the volume you provisioned.

    ```bash
    kubectl exec -it iis-pod –- cmd.exe
    ```

    The output of the command resembles the following example:

    ```output
    Microsoft Windows [Version 10.0.20348.1668]
    (c) Microsoft Corporation. All rights reserved.
    
    C:\>cd /inetpub/wwwroot
    
    C:\inetpub\wwwroot>dir
     Volume in drive C has no label.
     Volume Serial Number is 86BB-AA55
    
     Directory of C:\inetpub\wwwroot
    
    05/04/2023  08:15 PM    <DIR>          .
    05/04/2023  08:15 PM    <DIR>          ..
               0 File(s)              0 bytes
               2 Dir(s)  107,373,838,336 bytes free
    ```

---