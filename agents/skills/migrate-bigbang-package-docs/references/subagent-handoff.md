# Subagent handoff template

Fill every placeholder from the authorized batch. Attach concrete paths and commit
identities; a fresh subagent cannot rely on the coordinator's conversation history.
Use the harness's general-purpose execution agent. Do not grant extra cluster,
merge, or shared-repository write authority through this template.

```text
Use the `migrate-bigbang-package-docs` skill as a package-worker.
If the skill is not advertised, read its full entry file at
~/.agents/skills/migrate-bigbang-package-docs/SKILL.md, then its referenced files.

Assignment:
- Mode: <context-only | draft-mr>
- Package repository: <repository-derived-name>
- Canonical umbrella configuration key: <name>
- Compiler package directory name: <name>
- Project URL: <https://repo1.dso.mil/...>
- Package checkout: <absolute-path>
- Worktree: <absolute-unique-path>
- Job ID: <unique-id>
- New branch: 116-docs-<package>-<job-id>
- Source umbrella page(s): <full repo-relative docs/packages/... paths>
- Umbrella checkout (read-only): <absolute-path>
- Pinned umbrella commit SHA: <sha>
- Compiler checkout (read-only): <absolute-path>
- Pinned compiler commit SHA: <sha>
- Migration plan path/ref: <path and commit/ref>
- Tracking issue: https://repo1.dso.mil/big-bang/team/tools/bb-docs-compiler/-/work_items/116
- Context/results artifact directory: <absolute-unique-path outside tracked files>
- Additional package scope/exclusions: <explicit list or none>

Build fresh context before edits. Read the issue and notes, ADR 10 and documentation
guide, assigned source pages, all existing package documentation, relevant package
and locked upstream implementation, and the pinned umbrella integration. Produce
the claim/evidence map and validation plan required by the skill.

For context-only: return that context artifact and proposed edits; do not commit,
push, or open an MR. For draft-mr: you are authorized to implement documentation
only in the assigned isolated worktree, commit, push to this package repository,
and open exactly one draft MR targeting main with the `kind::docs` label. Verify
the label is present before handoff. Do not implement chart/runtime fixes.

Do not edit the umbrella checkout, compiler checkout, shared migration plan or
tracking issue. Do not run the full compiler in any shared working directory.
Use the skill's temporary publication check. Do not fetch/change the pinned
shared snapshots. Do not create a second MR for existing same-package work.

Return the skill's complete result contract, including the draft MR URL, commands
and actual results, compiler/umbrella handoffs, publication gate and blockers.
Stop after this package, leaving it for Daniel's review. Do not merge, select
another package, or spawn additional agents.
```

## Scheduling rules

- The user approves the batch before dispatch. Installation of the skill alone
  is not an instruction to run that batch.
- One active writer per package repository. Assign disjoint worktrees/branches;
  do not schedule two sections of the same repository concurrently.
- Example independent assignments: cert-manager, fluentbit and gateway-api.
  Packages sharing a source page can be independent only if ownership is explicit.
- The coordinator captures shared refs before starting, keeps shared state fixed
  during checks, and integrates handoffs after workers finish.
- Surface each draft link to Daniel as soon as available. Each worker stops after
  its MR, even if other authorized workers are still running.
- Only the coordinator posts tracking-issue comments/checklists. A blocked worker
  does not independently alter another assignment or delete source documentation.
