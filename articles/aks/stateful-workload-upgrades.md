---
layout: Conceptual
title: Stateful workload upgrade patterns for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/stateful-workload-upgrades
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
description: Plan AKS upgrades for PostgreSQL, Redis Cluster, and MongoDB workloads by coordinating database availability with node pool rolling upgrades.
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-08-07T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful, databases, high-availability
locale: en-us
document_id: 04cbdc44-b988-9394-ea04-7a6ac89450d9
document_version_independent_id: 4e7c1097-41f9-376e-8f35-8dd4c722fdd0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/stateful-workload-upgrades.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/stateful-workload-upgrades
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/stateful-workload-upgrades.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/982661b3-cc41-45b1-b21d-18b4b6937344
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/bbee35d0-ba85-4062-b9c2-388c328eb4fa
platformId: bda458d5-6770-9426-26a0-0953442f402d
---

# Stateful workload upgrade patterns for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Note

This article contains references to the term *slave* (replica), which is a term that Microsoft no longer uses. When the term is removed from the Redis software, we’ll remove it from this article.

Use these patterns to coordinate database availability with an Azure Kubernetes Service (AKS) node pool rolling upgrade.

The procedures in this article are planning frameworks, not availability or data durability guarantees. The outcome depends on your database topology, replication mode, storage, operator, disruption settings, client retry behavior, and workload. Rehearse the complete procedure in a representative environment and measure whether it meets your recovery time objective (RTO) and recovery point objective (RPO).

## Database upgrade patterns covered in this article

This article provides database-specific upgrade patterns for AKS clusters with stateful workloads, including:

- PostgreSQL controlled switchover.
- Redis Cluster replica-first rolling upgrade.
- MongoDB replica set secondary-first rolling upgrade.
- Emergency upgrade checklists for security responses.
- Validation and rollback planning.

Unlike a standard AKS node pool upgrade, these patterns coordinate database replication checks and role changes with Kubernetes node replacement. Database and AKS administrators can use these patterns. Use the documented switchover or upgrade operation for the database operator that manages your deployment. Don't substitute these patterns for operator-specific instructions.

For more information, see these related articles:

- To upgrade your production AKS clusters, see [AKS production upgrade strategies](aks-production-upgrade-strategies).
- To compare upgrade approaches for your AKS cluster, see [Upgrade options and recommendations](upgrade-options).
- To use the scenario hub to help you choose the right AKS upgrade approach, see [AKS upgrade scenarios: Choose your path](upgrade-scenarios-hub).

For a quick start, select the pattern for your deployed product and topology:

- Emergency upgrade checklist
- PostgreSQL controlled switchover
- Redis Cluster replica-first rolling upgrade
- MongoDB replica set secondary-first rolling upgrade

## Choose a database upgrade pattern

| Database type | Upgrade pattern | Availability consideration | Best for |
| --- | --- | --- | --- |
| PostgreSQL | Controlled switchover | Writes pause during connection drain and switchover. Measure the interval in your environment. | Primary and streaming-standby deployments with a supported failover mechanism |
| Redis Cluster | Replica-first rolling upgrade | Clients might receive transient errors or redirections during failover. Redis Cluster uses asynchronous replication. | Redis Cluster deployments with a replica for every primary |
| MongoDB | Secondary-first rolling upgrade | Writes fail from step-down until a new primary is elected. | Three-member or larger replica sets with an electable secondary |

## Emergency upgrade checklist

If you need an expedited upgrade to address a security issue, don't skip database health and recovery checks.

1. Verify the workload and AKS upgrade prerequisites:

    ```bash
    # Verify the database pods and their node placement.
    kubectl get pods -l tier=database -o wide
    
    # Confirm that the latest backup job completed.
    kubectl get job backup-job -o jsonpath='{.status.completionTime}'
    ```

    Also verify replication health by using a command supported by the database or operator. Restore the latest backup in an isolated environment, and confirm that clients retry transient connection and election errors.
2. Choose only the pattern that matches your product and topology:

    - **PostgreSQL**: Use controlled switchover.
    - **Redis Cluster**: Use replica-first rolling upgrade.
    - **MongoDB replica set**: Use secondary-first rolling upgrade.

    For other database products, follow the upgrade guidance for that product or its Kubernetes operator.
3. Run with a safety net:

    - Always test rollback procedures in advance.
    - Monitor application metrics during the upgrade.
    - Keep the database team on standby.
    - Stop the upgrade if replication, quorum, slot coverage, or application health degrades.

## PostgreSQL controlled switchover

Use this controlled switchover pattern for a PostgreSQL primary with streaming standbys. The examples show health checks, but the commands that promote, fence, and rejoin members depend on your PostgreSQL operator or high-availability implementation.

Important

Don't promote a standby until application writes are paused, the candidate is caught up, and your high-availability mechanism can fence or reconfigure the old primary. Promoting a standby while the old primary accepts writes can create divergent database timelines.

### Prerequisites

- Use a supported PostgreSQL version and a supported operator or high-availability implementation.
- Place members across failure domains. Configure Pod Disruption Budgets and topology spread constraints for your deployment.
- Verify a recent backup by restoring it in an isolated environment.
- Confirm that the application reconnects after a primary change.
- Record the operator-specific commands for switchover, rollback, and rejoin before starting the AKS upgrade.

### Step 1: Validate the replication topology

Run the following query on the current primary:

```bash
kubectl exec <current-primary-pod> -- psql -X -c "
SELECT application_name, state, sync_state, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;"
```

The intended switchover candidate must be in the `streaming` state. If your RPO requires synchronous replication, also verify that the candidate has the expected `sync_state` for your configuration.

Run the following query on the intended standby:

```bash
kubectl exec <candidate-standby-pod> -- psql -X -c "
SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
```

Confirm that `pg_is_in_recovery()` returns `true` and that the receive and replay locations meet your tested switchover threshold. PostgreSQL streaming replication is asynchronous by default, so a ready pod alone doesn't establish that the standby is caught up.

### Step 2: Pause writes and switch primaries

If all application traffic passes through PgBouncer, connect to the PgBouncer administration database and pause the application database:

```bash
kubectl exec <pgbouncer-pod> -- psql -p 6432 -U <admin-user> pgbouncer -c "PAUSE app_db;"
```

`PAUSE` waits for server connections to be released according to the configured pooling mode. Verify that application writes can't bypass PgBouncer before you rely on this control.

With writes paused, complete these actions by using your operator or high-availability implementation:

1. Recheck the candidate's WAL receive and replay positions.
2. Run the supported switchover operation.
3. Verify that exactly one writable primary exists.
4. Verify that the former primary is fenced or reconfigured as a standby.
5. Verify that the writer service or endpoint resolves to the new primary.

Resume PgBouncer only after these checks pass:

```bash
kubectl exec <pgbouncer-pod> -- psql -p 6432 -U <admin-user> pgbouncer -c "RESUME app_db;"
```

### Step 3: Validate the switchover

```bash
# Verify the new primary is writable and no longer in recovery.
kubectl exec <new-primary-pod> -- psql -X -c "SELECT pg_is_in_recovery();"

# Verify all expected standbys stream from the new primary.
kubectl exec <new-primary-pod> -- psql -X -c "
SELECT application_name, state, sync_state, replay_lsn
FROM pg_stat_replication;"
```

Test application reads, writes, transactions, and reconnection behavior. Compare how long writes were unavailable and the replication outcome with your RTO and RPO before continuing.

### Optional synchronous replication configuration

Synchronous replication can reduce the RPO for acknowledged transactions, but it adds commit latency and can reduce write availability if the required standbys aren't available. The following example waits for any two named, directly connected standbys to replay each committed transaction:

```yaml
# Use synchronous replication with multiple standbys
# postgresql.conf
synchronous_standby_names = 'ANY 2 (standby1, standby2, standby3)'
synchronous_commit = 'remote_apply'
```

Choose `synchronous_standby_names` and `synchronous_commit` based on measured latency, failure-domain placement, and durability requirements. This configuration doesn't guarantee a specific switchover duration.

### Success validation

To validate your progress, use the following checklist:

- New primary accepts reads and writes.
- All replicas show healthy replication.
- Application reconnects automatically.
- Data-integrity and application consistency checks pass.
- Backup and restore tests pass on the new primary.

### Upgrade the AKS node pool

An `az aks nodepool upgrade` operation upgrades the entire node pool. AKS adds surge capacity, cordons and drains old nodes, reimages them, and repeats the process according to the node pool upgrade settings. Don't run the command once for each node or manually drain the nodes before the managed operation.

1. List the supported upgrade targets for the cluster:

    ```azurecli
    az aks get-upgrades \
       --resource-group <resource-group-name> \
       --name <cluster-name> \
       --output table
    ```
2. Confirm that the control plane is already at the selected target version. Configure the node pool's rolling-upgrade settings based on tested workload behavior, quota, and available subnet addresses. The following example uses the recommended production `maxSurge` value:

    ```azurecli
    az aks nodepool update \
       --resource-group <resource-group-name> \
       --cluster-name <cluster-name> \
       --name <node-pool-name> \
       --max-surge 33% \
       --drain-timeout <minutes> \
       --node-soak-duration <minutes>
    ```
3. Start one managed upgrade for the node pool, using a target returned by `az aks get-upgrades`:

    ```azurecli
    az aks nodepool upgrade \
       --resource-group <resource-group-name> \
       --cluster-name <cluster-name> \
       --name <node-pool-name> \
       --kubernetes-version <target-version>
    ```
4. Monitor AKS upgrade events and database health throughout the operation:

    ```bash
    kubectl events --all-namespaces
    kubectl get pods -l app=postgres -o wide --watch
    ```

    Monitor replication, database availability, application errors, latency, and storage health in your observability system. If a Pod Disruption Budget blocks a drain, correct the workload availability problem instead of bypassing the budget.

### Validate and recover

After the managed upgrade finishes, verify the node versions, PostgreSQL topology, and application behavior:

```bash
kubectl get nodes
kubectl get pods -l app=postgres -o wide
kubectl exec <current-primary-pod> -- psql -X -c "
SELECT application_name, state, sync_state, replay_lsn
FROM pg_stat_replication;"
```

AKS doesn't support downgrading a cluster or node pool to an earlier Kubernetes version. If the database is unhealthy, stop application writes and use the database operator's supported recovery or switchover procedure. Don't redirect writes to the former PostgreSQL primary unless it safely rejoined the current timeline and was promoted by the high-availability mechanism. If the Kubernetes upgrade causes an unrecoverable compatibility problem, restore service by moving the workload to a tested cluster or node pool and restoring or replicating data according to your recovery plan.

## Redis Cluster replica-first rolling upgrade

Use this pattern for a Redis Cluster with at least three primary nodes and at least one replica for every primary. The documented Redis Cluster node-upgrade order is to upgrade replicas first, manually fail over each primary to an upgraded replica, and then upgrade the demoted former primary. Redis Cluster can return transient errors or redirections during topology changes. Because Redis Cluster uses asynchronous replication, it can lose acknowledged writes. Validate client retry behavior and the acceptable RPO before the upgrade.

Note

If a Redis operator manages the cluster, use its documented rolling-upgrade workflow. Don't combine manual cluster commands with an active operator unless its documentation directs you to do so.

### Step 1: Record and validate the topology

```bash
kubectl exec <redis-pod> -- redis-cli CLUSTER NODES
kubectl exec <redis-pod> -- redis-cli --cluster check 127.0.0.1:6379
```

Record each node ID, role, primary-to-replica assignment, and hash-slot range. Don't continue unless all 16,384 slots are covered, every primary has a healthy replica in a different failure domain, and the cluster reports `cluster_state:ok`.

### Step 2: Upgrade replicas

For each replica, one at a time:

1. Use your operator or workload deployment mechanism to replace or restart the replica on upgraded AKS capacity.
2. Wait for the pod to become ready and for replication to catch up.
3. Confirm with `CLUSTER NODES` that it remains assigned to the expected primary.

Don't run `CLUSTER FORGET` for a pod restart that preserves the Redis node identity. If the replacement has a new node identity, use `redis-cli --cluster add-node` with `--cluster-slave` and `--cluster-master-id` to add it as a replica of the intended primary. Wait until the new replica appears in the cluster topology.

```bash
kubectl exec <existing-redis-pod> -- redis-cli --cluster add-node \
   <new-replica-ip>:6379 127.0.0.1:6379 \
   --cluster-slave \
   --cluster-master-id <primary-node-id>
```

### Step 3: Fail over and upgrade primaries

For each primary, one at a time:

1. Choose an upgraded, caught-up replica of that primary.
2. Run `CLUSTER FAILOVER`**on the replica that you want to promote**, not on the current primary:

    ```bash
    kubectl exec <candidate-replica-pod> -- redis-cli CLUSTER FAILOVER
    ```
3. Poll `ROLE`, `INFO REPLICATION`, or `CLUSTER NODES` until the candidate is the primary and the former primary is its replica. An `OK` response only means that Redis accepted the failover request.
4. Replace or restart the demoted former primary on upgraded AKS capacity.
5. Wait for it to return as a caught-up replica before moving to the next primary.

Don't use `CLUSTER FAILOVER FORCE` or `TAKEOVER` during a planned upgrade. Those options bypass normal coordination and require separate failure-recovery procedures.

### Step 4: Validate Redis Cluster

```bash
kubectl exec <redis-pod> -- redis-cli CLUSTER INFO
kubectl exec <redis-pod> -- redis-cli CLUSTER NODES
kubectl exec <redis-pod> -- redis-cli --cluster check 127.0.0.1:6379
```

Check slot coverage, primary-to-replica assignments, replication health, application reads and writes, redirection handling, and the observed RPO.

## MongoDB replica set secondary-first rolling upgrade

Use this pattern for a three-member or larger MongoDB replica set that has an electable secondary. During primary step-down and election, writes fail until a new primary is elected. Applications must retry eligible writes and transient transactions according to the MongoDB driver guidance.

Note

If a MongoDB operator manages the replica set, use its documented rolling-upgrade workflow and readiness checks.

### Step 1: Validate the replica set

```bash
kubectl exec <mongodb-pod> -- mongosh --quiet --eval "rs.status()"
```

Confirm that all expected members are healthy, identify the current primary, and verify that at least one electable secondary is caught up. Also verify the latest backup through a test restore.

### Step 2: Upgrade secondaries

For each secondary, one at a time:

1. Replace or restart the member on upgraded AKS capacity by using the operator or workload deployment mechanism.
2. Wait for the pod to become ready.
3. Verify that the member returns to the `SECONDARY` state and catches up before updating another member.

    ```bash
    kubectl exec <mongodb-pod> -- mongosh --quiet --eval \
       "rs.status().members.map(member => ({name: member.name, state: member.stateStr, optime: member.optimeDate}))"
    ```

### Step 3: Step down the primary

Run `rs.stepDown()` only against the current primary. The first argument specifies how long the former primary can't be reelected. The second argument specifies how long an electable secondary has to catch up. Choose values based on your tested election behavior.

```bash
kubectl exec <current-primary-pod> -- mongosh --quiet --eval "rs.stepDown(60, 30)"
```

The command can disconnect or return an error as the primary steps down. Poll the replica-set status from another member until exactly one new primary is elected:

```bash
kubectl exec <mongodb-pod> -- mongosh --quiet --eval \
   "rs.status().members.map(member => ({name: member.name, state: member.stateStr}))"
```

If no electable secondary catches up within the configured period, the primary doesn't step down. Resolve replication health before retrying. Don't force the step-down during a planned upgrade.

### Step 4: Upgrade and validate the former primary

Replace or restart the former primary on upgraded AKS capacity. Wait for it to return as a healthy secondary, and then validate:

- Exactly one member is `PRIMARY`.
- All other data-bearing members are `SECONDARY` and caught up.
- Application reads, writes, retryable writes, and transactions behave as expected.
- The measured election interval meets the application RTO.
- Backup and restore checks pass.