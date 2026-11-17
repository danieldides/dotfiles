---
name: monitor-crossplane-rollout
description: Monitors a Crossplane top-level cluster composite by cluster-name and reports immediately on first signs of rollout failure. Use when asked to monitor Crossplane, CCM, XEKSCluster, XAWSTalosCluster, or cluster composition rollout health.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Monitor Crossplane Rollout

## When to use this skill

Use this skill when the user asks an agent to monitor a Crossplane or CCM
cluster rollout and report back at the first sign of failure.

## Required argument

The skill requires one argument:

- `cluster-name`: the metadata name of the top-level cluster composite to
  monitor, for example `rapid-eks-no-karpenter`.

If `cluster-name` is missing, ask for it before monitoring.

## Defaults

- Namespace: `default` unless the user provides another namespace.
- Top-level kind: infer from existing resources, checking `XEKSCluster` first,
  then `XAWSTalosCluster`, then any matching Crossplane composite with the same
  name.
- Poll interval: 30 seconds unless the user asks for a different cadence.
- Monitoring duration: continue until the first actionable failure appears, the
  resource reaches Ready, or the user-provided timeout expires. If no timeout is
  provided, monitor for at least 10 minutes after the composite appears.

## Guardrails

- This skill is read-only. Do not modify, apply, patch, restart, or delete any
  resources.
- Report immediately when an actionable failure appears. Do not wait for the
  rollout to finish once an error symptom is visible.
- Do not treat ordinary dependency waits as failures unless the same condition
  is stuck, contradictory, or paired with Warning events/provider errors.
- Include exact command evidence in the final report when practical.

## Workflow

1. Resolve the top-level composite kind and namespace.

   ```bash
   kubectl get xekscluster <cluster-name> -n <namespace> -o yaml
   kubectl get xawstaloscluster <cluster-name> -n <namespace> -o yaml
   kubectl get composite -n <namespace>
   kubectl get xr -n <namespace>
   ```

   If the resource does not exist yet, keep polling until it appears or the
   timeout expires.

2. Inspect the top-level composite status on every poll.

   ```bash
   kubectl get <kind> <cluster-name> -n <namespace> -o yaml
   kubectl describe <kind> <cluster-name> -n <namespace>
   ```

   Watch for:

   - `Synced=False`
   - `Ready=False` with an error reason or non-transient message
   - `status.phase` stuck in one phase with no progress
   - `status.phaseMessage` naming a failed or missing dependency
   - stuck readiness contracts such as `networkAuthReady`, `controlPlaneReady`,
     `karpenterReady`, `s3Ready`, or `rdsReady`

3. Inspect composed resources owned by the composite.

   Prefer owner references and Crossplane composition resource annotations when
   available. Also inspect likely CCM child resources with the cluster name as a
   prefix or suffix.

   ```bash
   kubectl get managed -n <namespace>
   kubectl get composite -n <namespace>
   kubectl get xr -n <namespace>
   kubectl get all -n <namespace>
   ```

   Check child resources for `Synced=False`, `Ready=False`, provider errors,
   failed references, missing secrets, failed usages, failed Helm releases,
   Kubernetes ProviderConfig bridge errors, AWS provider errors, S3 errors, RDS
   errors, Karpenter errors, network errors, auth errors, control-plane errors,
   and node group errors.

4. Inspect events each poll and prioritize Warning events.

   ```bash
   kubectl get events -n <namespace> --sort-by=.lastTimestamp
   kubectl describe <kind> <cluster-name> -n <namespace>
   ```

   Report immediately on Warning events that reference the top-level composite,
   a composed child, Crossplane function pipeline execution, provider reconcile,
   dependency usage, connection secrets, Helm releases, or Kubernetes provider
   bridge resources.

5. Classify the first failure symptom.

   Use `transient wait` only for expected dependency waits with no Warning
   events and no provider/function error messages. Use `hard failure` for schema
   errors, function pipeline failures, invalid references, auth/permission
   failures, provider API errors, immutable field errors, missing required
   secrets, or repeated Warning events.

## Report format

When reporting a failure, use this structure:

```markdown
## Rollout Failure

- Cluster: `<cluster-name>`
- Namespace: `<namespace>`
- Top-level resource: `<kind>/<cluster-name>`
- Current phase: `<status.phase>`
- Phase message: `<status.phaseMessage>`
- Failing resource: `<kind>/<name>`
- Condition: `<type>=<status>`, reason `<reason>`, message `<message>`
- Event: `<Warning event text, if present>`
- Likely dependency: `<child resource or provider dependency>`
- Classification: `transient wait` or `hard failure`
```

If no failure appears before the bounded wait expires, report current rollout
state instead:

```markdown
## Rollout Status

- Cluster: `<cluster-name>`
- Namespace: `<namespace>`
- Top-level resource: `<kind>/<cluster-name>`
- Ready: `<Ready condition status>`
- Synced: `<Synced condition status>`
- Current phase: `<status.phase>`
- Phase message: `<status.phaseMessage>`
- Pending children: `<children not Ready, if any>`
- Warning events: `<none or latest relevant warning>`
```

## Prompt template

If dispatching another agent, pass this prompt and replace `<cluster-name>` with
the required argument:

```text
Monitor the Crossplane rollout for the top-level cluster composite named `<cluster-name>` in the `default` namespace.

Watch continuously and report back immediately at the first sign of failure. Do not wait for the rollout to finish if an error appears.

Focus on the top-level composite conditions, composed resources owned by the composite, Crossplane function pipeline errors, Kubernetes Warning events, provider errors, dependency Usage errors, connection secret errors, and stuck readiness contracts.

When reporting, include the first failing resource kind/name/namespace, exact condition reason and message, relevant Warning event text, current top-level status.phase and status.phaseMessage, likely failing child dependency, and whether this looks like a transient wait condition or a hard failure.

Do not modify, patch, apply, restart, or delete any resources.
```
