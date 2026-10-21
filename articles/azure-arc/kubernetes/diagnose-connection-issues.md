---
layout: Conceptual
title: Diagnose connection issues for Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/diagnose-connection-issues
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-03-30T00:00:00.0000000Z
ms.topic: how-to
description: Learn how to resolve common issues when connecting Kubernetes clusters to Azure Arc.
ms.custom:
- devx-track-azurecli
- sfi-image-nochange
locale: en-us
document_id: 932d8142-8768-f6da-f648-624446b072e9
document_version_independent_id: a7bebf00-26be-c5bd-38b7-7955ded556b9
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/diagnose-connection-issues.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/diagnose-connection-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/diagnose-connection-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 42aeea70-e96b-5cfc-651e-1f9688e468fb
---

# Diagnose connection issues for Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn

If you have trouble connecting a cluster to Azure Arc, the problem is likely one of the issues listed in this article. Two flowcharts provide guided help: one if you're not using a proxy server, and one that applies if your network connection uses a proxy server.

Tip

These flowcharts apply whether you're using Azure CLI or Azure PowerShell to [connect your cluster](quickstart-connect-cluster). However, some of the steps require the use of Azure CLI. If you didn't already [install Azure CLI](/en-us/cli/azure/install-azure-cli), be sure to do so before you begin.

## Connections without a proxy

Review this flowchart to diagnose your problem when attempting to connect a cluster to Azure Arc without a proxy server. More details about each step are provided in the following sections.

[![Flowchart showing a visual representation of checking for connection issues when not using a proxy.](media/diagnose-connection-issues/no-proxy-flowchart.png)](media/diagnose-connection-issues/no-proxy-flowchart.png#lightbox)

### Does the Azure identity have sufficient permissions?

Review the [prerequisites for connecting a cluster](quickstart-connect-cluster?tabs=azure-cli#prerequisites) and make sure that the identity you're using to connect the cluster has the necessary permissions.

### Are you running the latest version of Azure CLI?

Make sure you [have the latest version installed](/en-us/cli/azure/install-azure-cli).

If you connected your cluster by using Azure PowerShell, make sure you're [running the latest version](/en-us/powershell/azure/install-azure-powershell).

### Is the `connectedk8s` extension the latest version?

Update the Azure CLI `connectedk8s` extension to the latest version by running this command:

```azurecli
az extension update --name connectedk8s
```

If you didn't install the extension yet, install it by running the following command:

```azurecli
az extension add --name connectedk8s
```

### Is kubeconfig pointing to the right cluster?

Run `kubectl config get-contexts` to confirm the target context name. Then set the default context to the right cluster by running `kubectl config use-context <target-cluster-name>`.

### Are all required resource providers registered?

Make sure that the Microsoft.Kubernetes, Microsoft.KubernetesConfiguration, and Microsoft.ExtendedLocation resource providers are [registered](quickstart-connect-cluster#register-providers-for-azure-arc-enabled-kubernetes).

### Are all network requirements met?

Review the [network requirements](network-requirements) and make sure that no required endpoints are blocked.

### Are all pods in the `azure-arc` namespace running?

If everything is working correctly, your pods should all be in the `Running` state. Run `kubectl get pods -n azure-arc` to confirm whether any pod's state isn't `Running`.

### Still having problems?

The preceding steps resolve many common connection problems. If you still can't connect successfully, generate a troubleshooting log file and then [open a support request](../../azure-portal/supportability/how-to-create-azure-support-request) so the support team can investigate the problem.

To generate the troubleshooting log file, run the following command:

```azurecli
az connectedk8s troubleshoot -g <myResourceGroup> -n <myK8sCluster>
```

When you [create your support request](../../azure-portal/supportability/how-to-create-azure-support-request), use the **File upload** option in the **Additional details** section to upload the generated log file.

## Connections with a proxy server

If you use a proxy server on at least one machine, complete the first five steps of the non-proxy flowchart (through resource provider registration) for basic troubleshooting steps. Then, if you're still encountering problems, review the next flowchart for additional troubleshooting steps. More details about each step are provided in the following sections.

[![Flowchart showing a visual representation of checking for connection issues when using a proxy.](media/diagnose-connection-issues/proxy-flowchart.png)](media/diagnose-connection-issues/proxy-flowchart.png#lightbox)

### Is the machine executing commands behind a proxy server?

If the machine executes commands behind a proxy server, set all of the necessary environment variables. For more information, see [Connect using an outbound proxy server](quickstart-connect-cluster#connect-using-an-outbound-proxy-server).

For example:

```bash
export HTTP_PROXY="http://<proxyIP>:<proxyPort>"
export HTTPS_PROXY="https://<proxyIP>:<proxyPort>"
export NO_PROXY="<cluster-apiserver-ip-address>:<proxyPort>"
```

### Does the proxy server only accept trusted certificates?

Be sure to include the certificate file path by including `--proxy-cert <path-to-cert-file>` when running the `az connectedk8s connect` command.

```azurecli
az connectedk8s connect --name <cluster-name> --resource-group <resource-group> --proxy-cert <path-to-cert-file>
```

### Can the proxy server reach required network endpoints?

Review the [network requirements](network-requirements) and make sure that no required endpoints are blocked.

### Is the proxy server only using HTTP?

If your proxy server only uses HTTP, use `proxy-http` for both parameters.

If your proxy server is set up with both HTTP and HTTPS, run the `az connectedk8s connect` command with the `--proxy-https` and `--proxy-http` parameters specified. Use `--proxy-http` for the HTTP proxy and `--proxy-https` for the HTTPS proxy.

```azurecli
az connectedk8s connect --name <cluster-name> --resource-group <resource-group> --proxy-https https://<proxy-server-ip-address>:<port> --proxy-http http://<proxy-server-ip-address>:<port>
```

### Does the proxy server require skip ranges for service-to-service communication?

If you require skip ranges, use `--proxy-skip-range <excludedIP>,<excludedCIDR>` in your `az connectedk8s connect` command.

```azurecli
az connectedk8s connect --name <cluster-name> --resource-group <resource-group> --proxy-https https://<proxy-server-ip-address>:<port> --proxy-http http://<proxy-server-ip-address>:<port> --proxy-skip-range <excludedIP>,<excludedCIDR>
```

### Are all pods in the `azure-arc` namespace running?

If everything is working correctly, your pods should all be in the `Running` state. Run `kubectl get pods -n azure-arc` to confirm whether any pod's state isn't `Running`.

### Check whether the DNS resolution is successful for the endpoint

From within the pod, run a DNS lookup to the endpoint.

If you can't run the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command to connect to the pod and install the DNS Utils package, [start a test pod in the same namespace as the problematic pod](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#create-a-simple-pod-to-use-as-a-test-environment), and then run the tests.

Note

If the DNS resolution or egress traffic doesn't let you install the necessary network packages, use the `rishasi/ubuntu-netutil:1.0` Docker image. In this image, the required packages are already installed.

Here's an example procedure for checking DNS resolution:

1. Start a test pod in the same namespace as the problematic pod:

    ```bash
    kubectl run -it --rm test-pod --namespace <namespace> --image=debian:stable
    ```

    After the test pod is running, you gain access to the pod.
2. Run the following `apt-get` commands to install other tool packages:

    ```bash
    apt-get update -y
    apt-get install dnsutils -y
    apt-get install curl -y
    apt-get install netcat -y
    ```
3. After the packages are installed, run the [nslookup](/en-us/windows-server/administration/windows-commands/nslookup) command to test the DNS resolution to the endpoint:

    ```console
    $ nslookup microsoft.com
    Server:         10.0.0.10
    Address:        10.0.0.10#53
    ...
    ...
    Name:   microsoft.com
    Address: 20.53.203.50
    ```
4. Try the DNS resolution from the upstream DNS server directly. This example uses Azure DNS:

    ```console
    $ nslookup microsoft.com 168.63.129.16
    Server:         168.63.129.16
    Address:        168.63.129.16#53
    ...
    ...
    Address: 20.81.111.85
    ```
5. Run the `host` command to check whether the DNS requests are routed to the upstream server:

    ```console
    $ host -a microsoft.com
    Trying "microsoft.com.default.svc.cluster.local"
    Trying "microsoft.com.svc.cluster.local"
    Trying "microsoft.com.cluster.local"
    Trying "microsoft.com.00idcnmrrm4edot5s2or1onxsc.bx.internal.cloudapp.net"
    Trying "microsoft.com"
    Trying "microsoft.com"
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62884
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 27, AUTHORITY: 0, ADDITIONAL: 5
    
    ;; QUESTION SECTION:
    ;microsoft.com.                 IN      ANY
    
    ;; ANSWER SECTION:
    microsoft.com.          30      IN      NS      ns1-39.azure-dns.com.
    ...
    ...
    ns4-39.azure-dns.info.  30      IN      A       13.107.206.39
    
    Received 2121 bytes from 10.0.0.10#53 in 232 ms
    ```
6. Run a test pod in the Windows node pool:

    ```bash
    # For a Windows environment, use the Resolve-DnsName cmdlet.
    kubectl run dnsutil-win --image='mcr.microsoft.com/windows/servercore:1809' --overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "windows"}}}' -- powershell "Start-Sleep -s 3600"
    ```
7. Run the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command to connect to the pod by using PowerShell:

    ```bash
    kubectl exec -it dnsutil-win -- powershell
    ```
8. Run the [Resolve-DnsName](/en-us/powershell/module/dnsclient/resolve-dnsname) cmdlet in PowerShell to check whether the DNS resolution is working for the endpoint:

    ```console
    PS C:\> Resolve-DnsName www.microsoft.com 
    
    Name                           Type   TTL   Section    NameHost
    ----                           ----   ---   -------    --------
    www.microsoft.com              CNAME  20    Answer     www.microsoft.com-c-3.edgekey.net
    www.microsoft.com-c-3.edgekey. CNAME  20    Answer     www.microsoft.com-c-3.edgekey.net.globalredir.akadns.net
    net
    www.microsoft.com-c-3.edgekey. CNAME  20    Answer     e13678.dscb.akamaiedge.net
    net.globalredir.akadns.net
    
    Name       : e13678.dscb.akamaiedge.net 
    QueryType  : AAAA
    TTL        : 20
    Section    : Answer
    IP6Address : 2600:1408:c400:484::356e   

    Name       : e13678.dscb.akamaiedge.net 
    QueryType  : AAAA
    TTL        : 20
    Section    : Answer
    IP6Address : 2600:1408:c400:496::356e 

    Name       : e13678.dscb.akamaiedge.net
    QueryType  : A
    TTL        : 12
    Section    : Answer
    IP4Address : 23.200.197.152
    ```

If the DNS resolution isn't successful, verify the DNS configuration for the cluster.

### Still having problems?

The preceding steps resolve many common connection problems. If you still can't connect successfully, generate a troubleshooting log file and then [open a support request](../../azure-portal/supportability/how-to-create-azure-support-request) so the support team can investigate the problem.

To generate the troubleshooting log file, run the following command:

```azurecli
az connectedk8s troubleshoot -g <myResourceGroup> -n <myK8sCluster>
```

When you [create your support request](../../azure-portal/supportability/how-to-create-azure-support-request), use the **File upload** option in the **Additional details** section to upload the generated log file.