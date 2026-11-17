---
name: review-bigbang-doc-examples
description: Review or revise Big Bang package documentation MRs for example-first administrator guidance. Use when auditing documentation migrations, removed YAML or command examples, dotted-key-only instructions, issuer/SSO/egress configuration, or applying Daniel's preference for concrete examples across open package MRs. Preserve integration workflows without duplicating the full upstream values schema.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Review Big Bang Documentation Examples

## Preference

**Explain decisions and constraints in prose; demonstrate configuration and
operations with minimal YAML or command examples.** Dotted keys such as
`issuerRef.name` are useful alongside an example, but are not a sufficient
replacement when an administrator needs to reconstruct nesting, resource
ownership, or an operational sequence.

This preference applies to all Big Bang package documentation MRs, not only
cert-manager or the issue 116 migration. It does not require an example for
every mentioned field or turn package guides into upstream configuration catalogs.
ADR 10's upstream-values policy is not a reason to delete a small integration
example, a resource reference, or useful package-specific troubleshooting.

## Scope and authorization

- Accept MR URLs, an explicitly selected package list, or a user-supplied MR
  inventory/tracking-page URL. Review only the requested set; do not interpret
  creating or loading this skill as authorization to process every open MR.
- Default to **review-only**. Edit, post comments, commit, or push only when the
  user authorizes the relevant actions. Do not merge MRs or force-push.
- For a batch, work sequentially unless parallel agent work is explicitly
  authorized. Do not spawn subagents merely because multiple MRs are supplied.
- Read applicable `AGENTS.md` files and inspect repository/worktree state first.
  Reuse an appropriate clean migration worktree without switching, stashing,
  resetting, or overwriting unrelated work.
- Keep package corrections documentation-only. Do not change runtime templates,
  values, schema, versions, dependencies, images, generated README, or maintainer
  development/maintenance guides without separate explicit approval.
- Keep umbrella architecture, orchestration, catalogs, navigation, and compiler
  changes outside a package assignment. Publication and old-link compatibility
  remain separate migration gates; better examples do not satisfy those gates.

## Review workflow

1. Fetch the MR's **current head SHA**, description, complete diff, and relevant
   discussions. GitLab work uses authenticated `glab api`; do not mistake a
   successful SSO HTML response for an existing documentation target. Resolve
   pagination and truncated/collapsed diffs before claiming a complete review.
2. Compare removed guidance against the full replacement and retained supporting
   pages at that exact head. Tracking-table guide commits may be stale. Classify
   each case as retained, moved, corrected, or lost; a large deletion is not
   automatically a problem.
3. Read the locked chart/dependency values, schema, templates, and relevant
   umbrella mappings. Verify canonical configuration names, passthrough parents,
   namespaces, labels, resource names, Secret keys, and version-specific APIs.
   Do not invent nesting or copy examples from an incompatible package version.
4. Identify instructions that require the reader to guess an action. Examples:
   - "Set `issuerRef.name` and `issuerRef.kind`" without a Certificate example.
   - "Set `scope` and `name`" without showing chart nesting and the paired
     consuming-resource reference.
   - "Enable Gateway API and set `parentRefs`" after all solver examples vanished.
   - "Use CIDR objects" without the full parent path or exclusion shape.
   - "Configure CA trust" without a verified Secret key, volume, mount, and flag.
   - "Add egress" without source-workload diagnostics and a narrow supported
     registration example.
   - "Verify permissions/readiness" without safe commands and expected outcomes.
5. Prioritize by impact. Missing or misleading instructions for a documented
   workflow should be addressed; an optional example for a straightforward
   setting is a suggestion. Explain the concrete obstacle rather than treating
   formatting preference as a runtime defect.

## Example requirements

- Label the configuration layer: **umbrella values**, **package values**,
  **upstream passthrough**, **Kubernetes resource**, or **resource fragment**.
  Do not say every block is Helm values when some blocks are CR manifests.
- Show enough parent nesting to establish where the values belong. For a
  Certificate, show `spec.issuerRef`, not a root-level Helm `issuerRef` setting.
- Prefer a small complete resource when it makes the workflow independently
  understandable. Label partial resources explicitly and explain what existing
  object/overlay they amend; do not present them as ready-to-apply manifests.
- Use actual supported value names and APIs for the selected version. Correct
  stale examples instead of restoring them verbatim. Distinguish chart-managed
  resources from those an environment must already provide.
- Pair producer and consumer configuration when needed: issuer scope/name and
  Certificate reference, OIDC claims and RBAC subjects, CA Secret key and mount,
  or external endpoint and the workload that makes the request.
- State assumptions, readiness/order, namespace and scope, replacement fields,
  expected results, and safety boundaries. Explain array replacement and the
  need to retain existing entries; do not imply every overlay is additive.
- Use reserved example domains and documentation CIDRs. Identify illustrative
  IPs as syntax examples, not working provider allowlists. Never include real
  credentials, private keys, licenses, bearer tokens, or user data.
- Keep staging, webhook-readiness, least-privilege, TLS validation, and
  sidecar/ambient caveats. No `cluster-admin`, `ALLOW_ANY`, blanket internet
  access, policy disabling, or TLS bypass as a routine convenience fix.
- Keep commands targeted and read-only by default. Authorization reviews do not
  read the target data, but still require API access/impersonation permissions.
  Clearly label approved mutating commands and require the intended kubeconfig
  and disposable targets. Never execute documented live commands as validation.
- One maintained example with a precise link is preferable to duplicated
  walkthroughs. Verify the linked page actually contains the promised example
  and has no circular references. An Ingress solver is not a Gateway API example.
- Retain general upstream reference links for the complete schema. Do not copy
  exhaustive values, generic cloud/bootstrap tutorials, or unsafe credential
  creation commands merely to make the page self-contained.
- Preserve useful heading anchors when restoring/restructuring guidance.

## Pattern: issuer reference

Instead of only "set `issuerRef.name` to `cert-manager-selfsigned` and
`issuerRef.kind` to `Issuer`", explain that the issuer must first be Ready and
show a **Kubernetes Certificate resource**, not a Helm overlay:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-selfsigned
  namespace: cert-manager
spec:
  secretName: example-selfsigned-tls
  dnsNames:
    - app.example.com
  issuerRef:
    name: cert-manager-selfsigned
    kind: Issuer
    group: cert-manager.io
```

Verify the selected chart's actual issuer name. Explain same-namespace matching
for `Issuer`, the intentional authorization expansion of `ClusterIssuer`, and
that issuance neither establishes public trust nor wires the Secret to a gateway.

## Implementation and validation

When edits are authorized, change only the reviewed documentation and keep the
surrounding correct safety/ownership guidance. Validate all new examples:

1. Run repository formatting/Markdown checks and `git diff --check`.
2. Parse YAML and run shell snippets through `bash -n` without executing them.
3. Render values examples with the locked dependencies; use upgrade rendering
   for upgrade-only resources, rather than changing `createOnInstall` to make
   the test pass. Assert names, kinds, references, ports, namespaces, scope, and
   preserved defaults. Explain any manually supplied umbrella defaults.
4. Check CR examples against version-matched API/CRD requirements and their
   rendered producer resources. Do not send manifests to a live API server
   merely for validation. Distinguish syntax/schema/reference checks from runtime
   reconciliation, SSO, ACME, provider connectivity, durability, or trust evidence.
5. Run relevant existing offline chart checks. Inspect artifacts afterward;
   do not commit generated snapshots or runtime changes in a docs-only correction.
6. Validate local links/anchors and new external targets. Report unverified
   publication routes or missing CI honestly; do not claim a full-site build
   passed on the strength of focused checks.
7. If committing/pushing is authorized, stage exact documentation paths, push
   without force to the intended MR branch, and verify remote/MR heads. Leave
   unrelated files untouched and return for human review without merging.

## Report

For each MR, provide:

- Current head reviewed and exact file/line references.
- Actionable findings, separating lost workflows from moved/stale examples.
- Proposed or implemented examples with their configuration layer and caveats.
- Validation actually performed, limitations, and any remaining blockers.
- Commit/MR links if authorized changes were pushed, plus a statement that no
  runtime/maintenance changes or merge occurred.

For a batch, include coverage and skipped/closed MRs. "No matching finding" is
not blanket approval of technical accuracy, CI, or migration publication gates.
