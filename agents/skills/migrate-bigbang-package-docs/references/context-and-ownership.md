# Context and ownership for issue #116

## Primary references

- Tracking issue: <https://repo1.dso.mil/big-bang/team/tools/bb-docs-compiler/-/work_items/116>
- ADR 10: umbrella `docs/community/adrs/0010-upstream-values-readme-documentation.md`
- ADR 5: umbrella `docs/community/adrs/0005-passthrough-chart.md`
- Documentation guidance: umbrella `docs/README.md`
- Related journey work: <https://repo1.dso.mil/big-bang/bigbang/-/work_items/3413>
- Compiler plan: `PACKAGE_DOCUMENTATION_MIGRATION_PLAN.md` on branch
  `116-package-documentation-migration`, draft MR !107.

Initial research on 2026-10-06 read all 34 checklist pages against umbrella
`e6f2cb0456a75919d39c4defd28e39c52937d7fb`. This is provenance, not a requirement
to use that commit forever. Fetch once and pin a fresh SHA per authorized batch.
Do not trust stale dates, MR state or facts from this reference without verification.

## Local layout and source access

- Umbrella: `~/Projects/big-bang/bigbang`; default branch `master`.
- Compiler: `~/Projects/big-bang/tools/bb-docs-compiler`; default branch `main`.
- Packages usually: `~/Projects/big-bang/product/<repo>`; branch new work from
  fetched `origin/main` and verify the remote.
- Package project URL generally:
  `https://repo1.dso.mil/big-bang/product/packages/<repo>`.
- Shared-library upstream guidance: `bb-common` and Gluon documentation, consulted
  only for integration actually used by the assigned package.

Repo1 browser pages can be incomplete or require SSO. Use `glab api --hostname
repo1.dso.mil` and URL-encoded project/file paths, or local `git show` at verified
commit refs. Respect pagination and never print tokens. Package metadata, source
pins and templates have greater factual authority than existing Markdown.

## Starting source-to-owner map

Paths below are relative to umbrella `docs/packages/`. Verify current issue scope
and metadata. A row with multiple owners means **separate assignments/MRs**, not
permission for one worker to edit all repositories.

| Source page                         | Package repository owner(s)                   | Particular checks                                                                    |
| ----------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------ |
| core/alloy.md                       | alloy                                         | Existing !189; do not duplicate. Collector roles, storage, destinations, hook guard. |
| core/cert-manager.md                | cert-manager                                  | CRD ownership, webhook port, ambient exclusion, issuer Secrets.                      |
| core/elasticsearch-kibana.md        | elasticsearch-kibana; assess eck-operator     | Operator boundary, storage, ingress and licensed SSO.                                |
| core/fluentbit.md                   | fluentbit                                     | Current passthrough shape, buffers, host mounts, SELinux.                            |
| core/gateway-api.md                 | gateway-api                                   | CRDs are cluster-scoped; no namespaced CRD workload. Ambient auto-enablement.        |
| core/istio.md                       | istio-crds, istiod, istio-cni, istio-gateway  | Per-repository implementation versus umbrella mesh orchestration.                    |
| core/kiali.md                       | kiali                                         | Prometheus/Grafana/Tempo wiring, current credentials and authentication.             |
| core/kyverno.md                     | kyverno, kyverno-policies, kyverno-reporter   | Admission, policy, reporter ownership; supported development exceptions.             |
| core/loki.md                        | loki                                          | Current strategies, object storage, ingestion and Grafana integration.               |
| core/monitoring.md                  | monitoring, grafana, prometheus-operator-crds | Grafana is separately owned; verify HA, monitors and CRD lifecycle.                  |
| core/neuvector.md                   | neuvector                                     | Runtime privileges, ingress, actual scaling and dependencies.                        |
| core/opa-gatekeeper.md              | policy                                        | Canonical key gatekeeper; verify current lifecycle and constraints.                  |
| core/renovate.md                    | renovate                                      | Canonical/legacy enablement, safe credentials, current dry-run behavior.             |
| core/tempo.md                       | tempo                                         | Current chart and UI availability; stale Tempo-Query/Jaeger guidance.                |
| core/twistlock.md                   | twistlock                                     | Console versus Defender, license and manual installation boundaries.                 |
| core/ztunnel.md                     | ztunnel                                       | Node-local availability, ambient dependencies, actual metric selectors.              |
| addons/anchore.md                   | anchore-enterprise                            | Remove obsolete Engine details; current enterprise license, storage, SSO.            |
| addons/argocd.md                    | argocd                                        | Actual OIDC, URL, Redis, monitoring; replace upstream HA recipes.                    |
| addons/authservice.md               | authservice                                   | Sidecar/waypoint protection, chain configuration, Redis state/routes.                |
| addons/external-secrets-operator.md | external-secrets                              | Canonical key externalSecrets; wrong Vault example, provider/webhook reachability.   |
| addons/fortify.md                   | fortify                                       | License/storage integration; avoid blanket policy weakening.                         |
| addons/gitlab.md                    | gitlab; assess gitlab-runner                  | Database/object-store wiring, SSO, production support boundaries.                    |
| addons/harbor.md                    | harbor                                        | Current routing/storage and obsolete sandbox links.                                  |
| addons/headlamp.md                  | headlamp                                      | RBAC, OIDC, namespace and common integrations.                                       |
| addons/keycloak.md                  | keycloak                                      | Current chart/server generation, TLS, probes, database and plugins.                  |
| addons/mattermost.md                | mattermost; assess mattermost-operator        | License-gated features, SSO/storage; obsolete E10/E20/OPA prose.                     |
| addons/metricserver.md              | metrics-server                                | Canonical key metricsServer; API detection, namespace, kubelet reachability.         |
| addons/mimir.md                     | mimir                                         | Verify tenancy, storage assumptions, backend forwarding and availability.            |
| addons/minio.md                     | minio, minio-operator                         | Tenant/operator ownership, networking, storage, auth; no license legal advice.       |
| addons/renovate.md                  | Compatibility stub, owned by coordinator      | Link to core guide; no second Renovate package MR.                                   |
| addons/sonarqube.md                 | sonarqube                                     | Node prerequisites, database, SSO, actual HA constraints.                            |
| addons/thanos.md                    | thanos                                        | Prometheus sidecar, Grafana, object store and auth.                                  |
| addons/vault.md                     | vault                                         | Current license authority, TLS, storage/unseal, metric setup.                        |
| addons/velero.md                    | velero                                        | Backup credentials, storage, provider plugins and integration.                       |

`core/istio-egress-gateway.md` exists but was not in #116's original checklist.
Do not expand scope without authorization. Related trust-manager/approver-policy
packages likewise do not become assigned merely because cert-manager mentions them.

## Publication and shared-work hazards

The compiler already includes package `docs`, `README.md`, `CHANGELOG.md`, and
`CONTRIBUTING.md`, extracts values where possible, and writes root package `.pages`.
Package `docs/.pages` is preserved by recursive copying. The normal generated guide
path is `packages/<repository-derived-name>/<package-relative-guide-without-.md>/`.
An `index.md` guide publishes at its containing directory, not `/index/`.

Links to excluded chart files are patched to Repo1 using the selected package ref.
Links to copied documentation stay relative. Workers must report missing files or
compiler shortcomings, not silently change shared compiler code.

Known shared follow-up: the compiler copies the umbrella package catalog into
`packages/index.md` without relocating its relative `core/` and `addons/` guide
links. Moving prose alone does not finish routing. Do not claim Packages overview
discovery is repaired based only on the focused package build.

Never use package `main` to fill holes in a release-pinned documentation site.
Merged docs may not yet exist in the tag selected by the umbrella. Source-page
removal must wait for package publication, working mixed/historical-ref compiler
routing, updated navigation/inbound links and old-bookmark compatibility.

Only the coordinator owns these follow-ups and issue checklist edits. Workers
provide exact source pages, guide filenames, aliases, required assets and inbound
references so those changes can be made serially in the existing compiler MR and
separate narrowly scoped umbrella follow-ups.
