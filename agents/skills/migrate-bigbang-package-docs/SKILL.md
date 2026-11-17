---
name: migrate-bigbang-package-docs
description: Migrate Big Bang umbrella package documentation into one assigned package repository for bb-docs-compiler issue 116. Builds fresh issue, ADR, package, upstream, and umbrella context; validates publication; opens a small draft GitLab MR and stops for human review. Supports concurrent workers in isolated worktrees while keeping compiler and umbrella changes coordinator-owned.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Migrate Big Bang Package Documentation

Use this skill for the documentation migration tracked by
[bb-docs-compiler #116](https://repo1.dso.mil/big-bang/team/tools/bb-docs-compiler/-/work_items/116).
This is a GitLab workflow using `glab`, not the GitHub issue/PR skills.

Read `references/context-and-ownership.md` before work. Use
`references/subagent-handoff.md` to dispatch a fresh package worker. Supporting
files are relative to this skill directory, not the package repository.

## Invocation contract

Accept either **coordinator** or **package-worker** responsibility. Without an
explicit package assignment, prepare the batch plan; do not start migrations.

A package-worker assignment must identify:

- Package repository name, canonical configuration name, and source umbrella page(s).
- Checkout path, or authorization to discover it under `~/Projects/big-bang/`.
- Worktree root and a unique branch/job ID.
- Umbrella commit SHA for the batch and read-only compiler checkout/commit.
- Mode: `context-only` or `draft-mr`. Require explicit authorization for the
  latter, including commit, push, and draft MR creation.
- Tracking issue URL and any additional package-specific scope or exclusions.

Infer repository/configuration names from current metadata and remotes, not solely
from filenames. The reference inventory is a starting map, not executable truth.
Return a blocker if an assignment is ambiguous or conflicts with existing work.

## Non-negotiable boundaries

- One worker, one package repository, one small draft MR. A worker must not claim
  another package, spawn more workers, merge an MR, or continue after its handoff.
- Every draft MR opened by this skill must include the `kind::docs` label.
- Only the coordinator writes compiler code, the migration plan, umbrella source
  cleanup, shared progress/checklists, and tracking-issue comments.
- Keep exactly one compiler MR for the whole effort. Existing draft: compiler
  [!107](https://repo1.dso.mil/big-bang/team/tools/bb-docs-compiler/-/merge_requests/107),
  branch `116-package-documentation-migration`. Verify live state before reuse.
- Existing Alloy draft [!189](https://repo1.dso.mil/big-bang/product/packages/alloy/-/merge_requests/189)
  must not be duplicated or modified without an explicit review assignment.
- Concurrent preparation does not grant permission to merge or remove source
  pages. Every draft returns to Daniel for review. Do not launch another batch
  until authorized; sequential execution remains the default without a batch.
  An explicitly authorized concurrent batch supersedes the initial plan's serial
  scheduling only, not its per-package review or publication gates.
- Never switch, stash, reset, clean, or overwrite another person's checkout.
  Never force-push by default or create a branch from another feature branch.
- No chart/dependency/image upgrades or runtime behavior changes. Document runtime
  defects as separate follow-ups; do not "fix" implementation to match prose.
- No real credentials, license content, or private key material in artifacts,
  logs, examples, commits, or MR descriptions. No cluster/cloud mutations.
- No package MR closes #116. No checklist is complete until merge, release-ref
  publication, compiler routing, source removal and link checks are complete.

## Coordinator workflow for concurrent packages

1. Read live #116 and its notes, ADR 10, `docs/README.md`, all checklist pages,
   current migration plan, and relevant #3413 coordination. Do not claim to have
   read material from a previous session. Read full documents, not search snippets.
2. Verify existing MRs and git state. Fetch the umbrella's actual default branch
   (`master`) without switching its checkout. Capture `origin/master`'s commit SHA.
   Capture the compiler branch/commit once for the batch; do not change it during
   worker publication checks.
3. Select only the user-authorized package batch. Assign a unique job ID, worktree
   and branch per repository; never run two workers in the same package repository.
   Composite source pages can be read concurrently, but assign disjoint package
   ownership. Source deletion and shared links remain serialized.
4. Pass the complete handoff template to each worker. Each worker builds its own
   fresh context from primary sources. The coordinator's summary is not a substitute
   for reading assigned documents and implementation.
5. Collect each result as it arrives and report its MR link to Daniel. Do not wait
   for a full batch before surfacing blockers. A blocker in one package does not
   authorize changes to another package's scope or shared files.
6. Serialize deduplicated tracking-issue comments and shared-plan updates. Record
   draft links, ownership decisions, actual validation, compiler handoff details,
   and deferred publication/cleanup gates. Do not check completed boxes prematurely.
7. Integrate compiler requirements in !107 only. Schedule umbrella cleanup only
   after replacements exist at the umbrella-selected package refs and routing works.

When asked only to install this skill or plan a batch, do not dispatch workers.

## Worker workflow

### 1. Establish an isolated workspace

Discover the assigned checkout, commonly
`~/Projects/big-bang/product/<repository-name>`. Verify `origin` matches the
assigned Repo1 project; do not use compiler `submodules/` as source checkouts.

Inspect root/ancestor/nested `AGENTS.md`, git status, existing branches, worktrees,
and open MRs. Preserve existing changes. Use an isolated worktree even if the
original checkout is clean. If same-package work already exists, stop for an
explicit resume/review assignment instead of opening a duplicate MR.

```sh
git -C "$PACKAGE_CHECKOUT" status --short --branch
git -C "$PACKAGE_CHECKOUT" remote -v
git -C "$PACKAGE_CHECKOUT" worktree list
git -C "$PACKAGE_CHECKOUT" fetch origin main
git -C "$PACKAGE_CHECKOUT" worktree add -b "$BRANCH" "$WORKTREE" origin/main
```

Use `116-docs-<package>-<job-id>` for a new branch. A slash prefix such as `docs/`
can collide with an existing branch named `docs`; do not delete branches to fix it.
If `main` does not exist, report the actual default branch rather than silently
changing the assignment. Workers do not create umbrella or compiler worktrees.

### 2. Build primary-source context before editing

Read the issue body and notes through the authenticated API; Repo1 web fetches may
return a login page instead of the issue.

```sh
glab api --hostname repo1.dso.mil \
  'projects/big-bang%2Fteam%2Ftools%2Fbb-docs-compiler/issues/116'
glab api --hostname repo1.dso.mil \
  'projects/big-bang%2Fteam%2Ftools%2Fbb-docs-compiler/issues/116/notes?per_page=100'
```

Follow pagination when present. Do not expose authentication tokens.

Read the following fully, using `git show "$UMBRELLA_SHA:<path>"` for the pinned
umbrella snapshot rather than switching/fetching its shared checkout:

- ADR 10, ADR 5 when applicable, `docs/README.md`, and the current migration plan.
- Every assigned source page, relevant category/landing navigation, and any
  additional integration pages needed to understand the package's behavior.
- Every existing package documentation page, README generation instructions,
  contribution guidance, and applicable `AGENTS.md`.
- Package `Chart.yaml`, `Chart.lock`, values, relevant templates, tests, and locked
  upstream sources. Read archives without modifying vendored dependencies.
- Umbrella package metadata, canonical/legacy values/schema, source pin, values
  mapping, HelmRelease, dependencies, namespaces, Secrets and post-renderers.
- Version-appropriate authoritative upstream documentation for claims retained
  in the new guide. Use moving upstream docs only for version-independent concepts.

Keep a short context artifact **outside tracked package files** containing:
commit/ref identities, files read, entry points, configuration/ownership map,
claim-by-claim retain/update/remove decisions with evidence, proposed edits,
validation plan, and publication risks. Do not use source-page prose as evidence
for itself. For `context-only`, return this artifact and stop before edits.

### 3. Implement only the assigned package documentation

Prefer extending the existing overview/integration page to creating a competing
overview. Preserve useful, verified Big Bang-specific configuration, dependencies,
security modifications, operations, and caveats. Correct obsolete or unsafe
claims. Link product tutorials, general HA/health/architecture, upstream options,
and licensing to authoritative upstream sources instead of reproducing them.

ADR 10 means documenting the passthrough parent and version-appropriate upstream
values link, not copying nested upstream keys/defaults/descriptions. Describe
Big Bang-owned modifications and overrides where useful. Do not hand-edit a
generated README; use its established source/generator only when necessary.

Keep local links relative, update package inbound links and applicable `AGENTS.md`,
and respect `.pages`/landing-page conventions. Add only necessary source/asset
changes. Do not copy composite-page content owned by sibling packages.

### 4. Validate the exact draft

- `git diff --check`, established Markdown/format/link checks, and navigation
  validation. Specify `--parser yaml` for Prettier on `.pages`.
- Check every new/changed local link and fragment; verify authoritative external
  targets. A login page returning HTTP 200 does not verify a Repo1 source link;
  use its repository/API at the selected ref.
- Run documented read-only chart checks if applicable. Do not invoke cluster or
  registry operations just because a maintenance guide mentions them.
- Run the focused publication helper in this skill's `scripts/` using the assigned
  compiler environment. It copies docs into a unique temporary directory, uses
  real include/value/link-patching behavior and a strict MkDocs build, and verifies
  the expected guide URL. It does not fetch repos or overwrite shared output.

```sh
SKILL_DIR="$HOME/.agents/skills/migrate-bigbang-package-docs"
cd "$COMPILER_CHECKOUT"
PYTHONDONTWRITEBYTECODE=1 poetry run python \
  "$SKILL_DIR/scripts/validate_package_docs.py" \
  --compiler-repo "$COMPILER_CHECKOUT" --compiler-ref "$COMPILER_SHA" \
  --package-repo "$WORKTREE" --package "$COMPILED_PACKAGE_NAME" \
  --ref "$BRANCH" --guide "$PACKAGE_GUIDE_PATH"
```

`PACKAGE_GUIDE_PATH` is a package-relative Markdown path, e.g. `docs/overview.md`.
`COMPILED_PACKAGE_NAME` is the compiler repository-derived name, e.g. `policy`,
not necessarily the canonical umbrella name `gatekeeper`.

Report inherited failures separately from introduced failures. Do not weaken
strictness to claim success. This is a focused documentation publication check,
not a full umbrella compile, external-link checker, or live integration test.
Return any shared-compiler change needed as a handoff; workers must not edit it.

### 5. Commit, push, create one draft MR, then stop

Inspect the final diff and stage explicit files only. Use a focused conventional
documentation commit and preserve repository signing conventions. Keep package
MRs reviewable; do not include the worker context ledger in published docs.

```sh
git -C "$WORKTREE" push -u origin "$BRANCH"
glab mr create --repo "$PROJECT_URL" \
  --source-branch "$BRANCH" --target-branch main --draft \
  --label "kind::docs" \
  --title "docs: migrate <package> Big Bang integration guidance" \
  --description "$MR_DESCRIPTION" --yes
```

Always include `--label "kind::docs"`, preserving any additional required labels.
Verify the created MR has the label before returning the handoff; if it cannot be
applied, report a blocker rather than treating the draft as ready for review.

Use the repository MR template when available. The description must include
summary, relation to #116 (not `Closes`), retained/corrected/removed content,
validation commands and actual results, compiler target path, deferred publication
and umbrella cleanup, and `## Upgrade Notices`. For prose-only changes, say no
configuration/operational change is required; do not disguise existing behavior
as a new feature. Do not merge or automatically poll indefinitely.

Return the handoff below. The coordinator links the MR from #116 and prompts
Daniel for review. Leave the worktree intact for review fixes.

## Worker result contract

```text
Package / project / canonical and compiler names:
Source umbrella page(s), pinned umbrella SHA:
Package base SHA, branch, commit, worktree:
Docs added/updated and compiled guide path:
Draft MR URL (or context-only / blocked):
Context artifact path:
Retained / corrected / removed claims and primary evidence:
Validation commands, pass/fail/not-run, inherited failures:
CI status (if known; never equate local success with CI success):
Compiler handoff: repository-relative guide, source page(s), aliases/assets/links:
Umbrella handoff: inbound links/navigation, composite siblings still pending:
Publication gate: umbrella-selected package ref contains guide? yes/no/unknown:
Runtime findings requiring separate work:
Human review required; no additional package started:
```
