---
layout: Conceptual
title: Configure and deploy Apache Airflow on AKS using Helm - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/airflow-deploy
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
description: Configure storage and secrets to deploy Apache Airflow on Azure Kubernetes Service (AKS) using Helm.
ms.topic: how-to
ms.date: 2025-07-14T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: ec7c6f77-4a51-4dae-070e-0d040868a5b8
document_version_independent_id: f04aa40f-da3a-4357-b0df-9e671193867f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/airflow-deploy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/airflow-deploy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/airflow-deploy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
platformId: d682c0b4-e91a-cb3a-4263-088d7d3996f3
---

# Configure and deploy Apache Airflow on AKS using Helm - Azure Kubernetes Service | Microsoft Learn

In this article, you configure and deploy Apache Airflow on Azure Kubernetes Service (AKS) using Helm.

## Configure workload identity

1. Create a namespace for the Airflow cluster using the `kubectl create namespace` command.

    ```bash
    kubectl create namespace ${AKS_AIRFLOW_NAMESPACE} --dry-run=client --output yaml | kubectl apply -f -
    ```

    Example output:

    ```output
    namespace/airflow created
    ```
2. Create a service account and configure workload identity using the `kubectl apply` command.

    ```bash
    export TENANT_ID=$(az account show --query tenantId -o tsv)
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: "${MY_IDENTITY_NAME_CLIENT_ID}"
        azure.workload.identity/tenant-id: "${TENANT_ID}"
      name: "${SERVICE_ACCOUNT_NAME}"
      namespace: "${AKS_AIRFLOW_NAMESPACE}"
    EOF
    ```

    Example output:

    ```output
    serviceaccount/airflow created
    ```

## Install the External Secrets Operator

In this section, we use Helm to install the External Secrets Operator. The External Secrets Operator is a Kubernetes operator that manages the lifecycle of external secrets stored in external secret stores like Azure Key Vault.

1. Add the External Secrets Helm repository and update the repository using the `helm repo add` and `helm repo update` commands.

    ```bash
    helm repo add external-secrets https://charts.external-secrets.io
    helm repo update
    ```

    Example output:

    ```output
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "external-secrets" chart repository
    ```
2. Install the External Secrets Operator using the `helm install` command.

    ```bash
    helm install external-secrets \
    external-secrets/external-secrets \
    --namespace ${AKS_AIRFLOW_NAMESPACE} \
    --create-namespace \
    --set installCRDs=true \
    --wait
    ```

    Example output:

    ```output
    NAME: external-secrets
    LAST DEPLOYED: Thu Nov  7 11:16:07 2024
    NAMESPACE: airflow
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    external-secrets has been deployed successfully in namespace airflow!
    
    In order to begin using ExternalSecrets, you will need to set up a SecretStore
    or ClusterSecretStore resource (for example, by creating a 'vault' SecretStore).
    
    More information on the different types of SecretStores and how to configure them
    can be found in our Github: https://github.com/external-secrets/external-secrets
    ```

### Create secrets

1. Create a `SecretStore` resource to access the Airflow passwords stored in your key vault using the `kubectl apply` command.

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: external-secrets.io/v1
    kind: SecretStore
    metadata:
      name: azure-store
      namespace: ${AKS_AIRFLOW_NAMESPACE}
    spec:
      provider:
        # provider type: azure keyvault
        azurekv:
          authType: WorkloadIdentity
          vaultUrl: "${KEYVAULTURL}"
          serviceAccountRef:
            name: ${SERVICE_ACCOUNT_NAME}
    EOF
    ```

    Example output:

    ```output
    secretstore.external-secrets.io/azure-store created
    ```
2. Create an `ExternalSecret` resource, which creates a Kubernetes `Secret` in the `airflow` namespace with the `Airflow` secrets stored in your key vault, using the `kubectl apply` command.

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: airflow-aks-azure-logs-secrets
      namespace: ${AKS_AIRFLOW_NAMESPACE}
    spec:
      refreshInterval: 1h
      secretStoreRef:
        kind: SecretStore
        name: azure-store
    
      target:
        name: ${AKS_AIRFLOW_LOGS_STORAGE_SECRET_NAME}
        creationPolicy: Owner
    
      data:
        # name of the SECRET in the Azure KV (no prefix is by default a SECRET)
        - secretKey: azurestorageaccountname
          remoteRef:
            key: AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-NAME
        - secretKey: azurestorageaccountkey
          remoteRef:
            key: AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-KEY
    EOF
    ```

    Example output:

    ```output
    externalsecret.external-secrets.io/airflow-aks-azure-logs-secrets created
    ```
3. Create a federated credential using the `az identity federated-credential create` command.

    ```azurecli
    az identity federated-credential create \
        --name external-secret-operator \
        --identity-name ${MY_IDENTITY_NAME} \
        --resource-group ${MY_RESOURCE_GROUP_NAME} \
        --issuer ${OIDC_URL} \
        --subject system:serviceaccount:${AKS_AIRFLOW_NAMESPACE}:${SERVICE_ACCOUNT_NAME} \
        --output table
    ```

    Example output:

    ```output
    Issuer                                                                                                                   Name                      ResourceGroup            Subject
    -----------------------------------------------------------------------------------------------------------------------  ------------------------  -----------------------  -------------------------------------
    https://$MY_LOCATION.oic.prod-aks.azure.com/c2c2c2c2-dddd-eeee-ffff-a3a3a3a3a3a3/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/  external-secret-operator  $MY_RESOURCE_GROUP_NAME  system:serviceaccount:airflow:airflow
    ```
4. Give permission to the user-assigned identity to access the secret using the [`az keyvault set-policy`](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command.

    ```azurecli
    az keyvault set-policy --name $MY_KEYVAULT_NAME --object-id $MY_IDENTITY_NAME_PRINCIPAL_ID --secret-permissions get --output table
    ```

    Example output:

    ```output
    Location       Name                    ResourceGroup
    -------------  ----------------------  -----------------------
    $MY_LOCATION   $MY_KEYVAULT_NAME       $MY_RESOURCE_GROUP_NAME
    ```

## Create a persistent volume for Apache Airflow logs

- Create a persistent volume using the `kubectl apply` command.

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-airflow-logs
      labels:
        type: local
    spec:
      capacity:
        storage: 5Gi
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain # If set as "Delete" container would be removed after pvc deletion
      storageClassName: azureblob-fuse-premium
      mountOptions:
        - -o allow_other
        - --file-cache-timeout-in-seconds=120
      csi:
        driver: blob.csi.azure.com
        readOnly: false
        volumeHandle: airflow-logs-1
        volumeAttributes:
          resourceGroup: ${MY_RESOURCE_GROUP_NAME}
          storageAccount: ${AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME}
          containerName: ${AKS_AIRFLOW_LOGS_STORAGE_CONTAINER_NAME}
        nodeStageSecretRef:
          name: ${AKS_AIRFLOW_LOGS_STORAGE_SECRET_NAME}
          namespace: ${AKS_AIRFLOW_NAMESPACE}
    EOF
    ```

    Example output:

    ```output
    persistentvolume/pv-airflow-logs created
    ```

## Create a persistent volume claim for Apache Airflow logs

- Create a persistent volume claim using the `kubectl apply` command.

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-airflow-logs
      namespace: ${AKS_AIRFLOW_NAMESPACE}
    spec:
      storageClassName: azureblob-fuse-premium
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 5Gi
      volumeName: pv-airflow-logs
    EOF
    ```

    Example output:

    ```output
    persistentvolumeclaim/pvc-airflow-logs created
    ```

## Deploy Apache Airflow using Helm

1. Configure an `airflow_values.yaml` file to change the default deployment configurations for the chart and update the container registry for the images.

    ```bash
    cat <<EOF> airflow_values.yaml
    
    images:
      airflow:
        repository: $MY_ACR_REGISTRY.azurecr.io/airflow
        tag: 3.0.2
        # Specifying digest takes precedence over tag.
        digest: ~
        pullPolicy: IfNotPresent
      # To avoid images with user code, you can turn this to 'true' and
      # all the 'run-airflow-migrations' and 'wait-for-airflow-migrations' containers/jobs
      # will use the images from 'defaultAirflowRepository:defaultAirflowTag' values
      # to run and wait for DB migrations .
      useDefaultImageForMigration: false
      # timeout (in seconds) for airflow-migrations to complete
      migrationsWaitTimeout: 60
      pod_template:
        # Note that `images.pod_template.repository` and `images.pod_template.tag` parameters
        # can be overridden in `config.kubernetes` section. So for these parameters to have effect
        # `config.kubernetes.worker_container_repository` and `config.kubernetes.worker_container_tag`
        # must be not set .
        repository: $MY_ACR_REGISTRY.azurecr.io/airflow
        tag: 3.0.2
        pullPolicy: IfNotPresent
      flower:
        repository: $MY_ACR_REGISTRY.azurecr.io/airflow
        tag: 3.0.2
        pullPolicy: IfNotPresent
      statsd:
        repository: $MY_ACR_REGISTRY.azurecr.io/statsd-exporter
        tag: v0.28.0
        pullPolicy: IfNotPresent
      pgbouncer:
        repository: $MY_ACR_REGISTRY.azurecr.io/airflow
        tag: airflow-pgbouncer-2025.03.05-1.23.1
        pullPolicy: IfNotPresent
      pgbouncerExporter:
        repository: $MY_ACR_REGISTRY.azurecr.io/airflow
        tag: airflow-pgbouncer-exporter-2025.03.05-0.18.0
        pullPolicy: IfNotPresent
      gitSync:
        repository: $MY_ACR_REGISTRY.azurecr.io/git-sync
        tag: v4.3.0
        pullPolicy: IfNotPresent

    # Airflow executor
    executor: "KubernetesExecutor"
    
    # Environment variables for all airflow containers
    env:
      - name: ENVIRONMENT
        value: dev
    
    extraEnv: |
      - name: AIRFLOW__CORE__DEFAULT_TIMEZONE
        value: 'America/New_York'
    
    # Configuration for postgresql subchart
    # Not recommended for production! Instead, spin up your own Postgresql server and use the `data` attribute in this
    # yaml file.
    postgresql:
      enabled: true
      image:
        registry: $MY_ACR_REGISTRY.azurecr.io
        repository: postgresql
        tag: 16.1.0-debian-11-r15
    
    # Enable pgbouncer. See https://airflow.apache.org/docs/helm-chart/stable/production-guide.html#pgbouncer
    pgbouncer:
      enabled: true
    
    dags:
      gitSync:
        enabled: true
        repo: https://github.com/donhighmsft/airflowexamples.git
        branch: main
        rev: HEAD
        depth: 1
        maxFailures: 0
        subPath: "dags"
        # sshKeySecret: airflow-git-ssh-secret
        # knownHosts: |
        #   github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
    
    logs:
      persistence:
        enabled: true
        existingClaim: pvc-airflow-logs
        storageClassName: azureblob-fuse-premium
    
    # We disable the log groomer sidecar because we use Azure Blob Storage for logs, with lifecyle policy set.
    triggerer:
      logGroomerSidecar:
        enabled: false
    
    scheduler:
      logGroomerSidecar:
        enabled: false
    
    workers:
      logGroomerSidecar:
        enabled: false
    
    EOF
    ```
2. Add the Apache Airflow Helm repository and update the repository using the `helm repo add` and `helm repo update` commands.

    ```bash
    helm repo add apache-airflow https://airflow.apache.org
    helm repo update
    ```

    Example output:

    ```output
    "apache-airflow" has been added to your repositories
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "apache-airflow" chart repository
    ```
3. Search the Helm repository for the Apache Airflow chart using the `helm search repo` command.

    ```bash
    helm search repo airflow
    ```

    Example output:

    ```output
    NAME                    CHART VERSION   APP VERSION     DESCRIPTION
    apache-airflow/airflow  1.15.0          3.0.2           The official Helm chart to deploy Apache Airflo...
    ```
4. Install the Apache Airflow chart using the `helm install` command.

    ```bash
    helm install airflow apache-airflow/airflow --version 1.15.0 --namespace airflow --create-namespace -f airflow_values.yaml --debug
    ```

    Example output:

    ```output
    NAME: airflow
    LAST DEPLOYED: Fri Nov  8 11:59:43 2024
    NAMESPACE: airflow
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    Thank you for installing Apache Airflow 3.0.2!
    
    Your release is named airflow.
    You can now access your dashboard(s) by executing the following command(s) and visiting the corresponding port at localhost in your browser:
    
    Airflow Webserver:     kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow
    Default Webserver (Airflow UI) Login credentials:
        username: admin
        password: admin
    Default Postgres connection credentials:
        username: postgres
        password: postgres
        port: 5432
    
    You can get Fernet Key value by running the following:
    
        echo Fernet Key: $(kubectl get secret --namespace airflow airflow-fernet-key -o jsonpath="{.data.fernet-key}" | base64 --decode)
    
    ###########################################################
    #  WARNING: You should set a static webserver secret key  #
    ###########################################################
    
    You are using a dynamically generated webserver secret key, which can lead to
    unnecessary restarts of your Airflow components.
    
    Information on how to set a static webserver secret key can be found here:
    https://airflow.apache.org/docs/helm-chart/stable/production-guide.html#webserver-secret-key
    ```
5. Verify the installation using the `kubectl get pods` command.

    ```bash
    kubectl get pods -n airflow
    ```

    Example output:

    ```output
    NAME                                                READY   STATUS      RESTARTS   AGE
    airflow-create-user-kklqf                           1/1     Running     0          12s
    airflow-pgbouncer-d7bf9f649-25fnt                   2/2     Running     0          61s
    airflow-postgresql-0                                1/1     Running     0          61s
    airflow-run-airflow-migrations-zns2b                0/1     Completed   0          60s
    airflow-scheduler-5c45c6dbdd-7t6hv                  1/2     Running     0          61s
    airflow-statsd-6df8564664-6rbw8                     1/1     Running     0          61s
    airflow-triggerer-0                                 2/2     Running     0          61s
    airflow-webserver-7df76f944c-vcd5s                  0/1     Running     0          61s
    external-secrets-748f44c8b8-w7qrk                   1/1     Running     0          3h6m
    external-secrets-cert-controller-57b9f4cb7c-vl4m8   1/1     Running     0          3h6m
    external-secrets-webhook-5954b69786-69rlp           1/1     Running     0          3h6m
    ```

## Access Airflow UI

1. Securely access the Airflow UI through port-forwarding using the `kubectl port-forward` command.

    ```bash
    kubectl port-forward svc/airflow-webserver 8080:8080 -n airflow
    ```
2. Open your browser and navigate to `localhost:8080` to access the Airflow UI.
3. To sign in, use the default webserver URL and sign-in credentials provided during the Airflow Helm chart installation.
4. Explore and manage your workflows securely through the Airflow UI.

## Integrate Git with Airflow

**Integrating Git with Apache Airflow** enables seamless version control and streamlined management of your workflow definitions, ensuring that all DAGs are both organized and easily auditable.

1. **Set up a Git repository for DAGs**. Create a dedicated Git repository to house all your Airflow DAG definitions. This repository serves as the central source of truth for your workflows, allowing you to manage, track, and collaborate on DAGs effectively.
2. **Configure Airflow to sync DAGs from Git**. Update Airflow's configuration to automatically pull DAGs from your Git repository by setting the Git repository URL and any required authentication credentials directly in Airflow's configuration files or through Helm chart values. This setup enables automated synchronization of DAGs, ensuring that Airflow is always up to date with the latest version of your workflows.

This integration enhances the development and deployment workflow by introducing full version control, enabling rollbacks, and supporting team collaboration in a production-grade setup.

## Make your Airflow on Kubernetes production-grade

The following best practices can help you make your **Apache Airflow on Kubernetes** deployment production-grade:

- Ensure you have a robust setup focused on scalability, security, and reliability.
- Use dedicated, autoscaling nodes, and select a resilient executor like **KubernetesExecutor**, **CeleryExecutor**, or **CeleryKubernetesExecutor**.
- Use a managed, high-availability database back end like MySQL or [PostgreSQL](deploy-postgresql-ha).
- Establish comprehensive monitoring and centralized logging to maintain performance insights.
- Secure your environment with network policies, SSL, and Role-Based Access Control (RBAC), and configure Airflow components (Scheduler, Web Server, Workers) for high availability.
- Implement CI/CD pipelines for smooth DAG deployment, and set up regular backups for disaster recovery.