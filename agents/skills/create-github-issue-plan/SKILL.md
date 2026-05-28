---
name: create-github-issue-plan
description: |
  Creates and comments a detailed implementation plan on a GitHub issue from an
  issue URL using the GitHub CLI (`gh`). Use when the user asks to plan, create
  an implementation plan, scope, or break down work for a GitHub issue.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Create GitHub Issue Implementation Plan (gh CLI)

## When to use this skill

Use this skill when the user provides a GitHub issue link and asks for a
detailed implementation plan, planning comment, work breakdown, or scoped plan
for that issue.

## Required information

Gather:

1. **Issue URL**: a full GitHub issue URL.
2. **Repository access**: `gh` must be authenticated with read access to the
   issue repository and write access to comment on the issue.

If the issue URL is missing, ask for it. Do not accept a bare issue number
unless the repository is unambiguous from the current git remote.

## Preconditions

- `gh` is authenticated with repo access.
- The issue is open or otherwise appropriate to plan. If the issue is closed,
  ask before commenting.
- The agent has enough repository context to create a concrete plan. If the
  issue depends on unavailable private services, missing product decisions, or
  unknown external systems, call that out in the plan instead of guessing.

## Guardrails

- Do not create a branch, edit files, commit, push, or open a PR.
- Do not start implementation unless the user explicitly asks for that after the
  plan is posted.
- Prefer concrete repository references over generic advice.
- Ask the user only when truly blocked. Otherwise, document assumptions and open
  questions in the plan.
- Avoid pasting unrelated issue text back into the comment. Use the issue body
  and comments as source material, then write a new implementation plan.

## Steps

1. Resolve repository and issue number from the provided issue URL.

   - For `https://github.com/<owner>/<repo>/issues/<number>`, use
     `<owner>/<repo>` and `<number>` directly.
   - Use `--repo <owner>/<repo>` on all `gh` commands.

2. Read issue details:

   ```bash
   gh issue view <issue-number> --repo <owner>/<repo> \
     --json number,title,author,state,labels,assignees,milestone,body,url,createdAt,updatedAt,comments
   ```

3. Read issue conversation comments when the issue has substantial discussion:

   ```bash
   gh api repos/<owner>/<repo>/issues/<issue-number>/comments
   ```

4. Inspect the repository before drafting the plan.

   - Identify the relevant packages, services, modules, tests, CI tasks, and
     conventions.
   - Search for existing related code, TODOs, docs, feature flags, migrations,
     APIs, and tests.
   - Read enough files to make the plan actionable and specific.
   - If the repository is not available locally, use GitHub API/file browsing
     through `gh` where practical and state any limitations in the plan.

5. Draft a detailed implementation plan using the required format below.

6. Review the plan for specificity.

   - Each implementation step should identify likely files, modules, or commands
     when known.
   - Testing should include exact test commands when they can be inferred.
   - Risks should include concrete behavioral, migration, rollout, or dependency
     concerns.

7. Comment the final plan on the original issue:

   ```bash
   gh issue comment <issue-number> --repo <owner>/<repo> --body "$(cat <<'EOF'
   <implementation plan markdown>
   EOF
   )"
   ```

8. Report the issue URL and confirm that the implementation plan comment was
   posted.

## Implementation plan comment format

Use this exact top-level structure:

```markdown
## Implementation Plan

### Summary

<Brief explanation of the intended approach and outcome.>

### Current Understanding

- <Relevant facts from the issue and repository inspection.>
- <Important constraints, existing behavior, or related code paths.>

### Proposed Changes

- <Concrete change 1, including likely files/modules when known.>
- <Concrete change 2.>
- <Concrete change 3.>

### Step-by-Step Plan

1. <First implementation step.>
2. <Second implementation step.>
3. <Third implementation step.>

### Testing and Validation

- <Exact test, lint, typecheck, build, or manual validation command.>
- <Additional targeted verification.>

### Risks and Considerations

- <Risk, migration concern, compatibility concern, or rollout consideration.>

### Open Questions

- <Question that must be answered before or during implementation.>
```

## Plan quality bar

- The plan should be detailed enough that another engineer can begin work
  without re-reading the whole repository from scratch.
- The plan should distinguish facts from assumptions.
- The plan should include any sequencing constraints, dependencies, database or
  configuration changes, and backward-compatibility concerns.
- If there are no open questions, write `- None identified.` under
  `### Open Questions`.
- If exact validation commands cannot be inferred, list the closest likely
  commands and mark them as assumptions.

## Failure handling

- If the issue cannot be read, report the failing command and error.
- If repository context is insufficient, post no comment until enough context is
  gathered or the user confirms that a best-effort plan is acceptable.
- If commenting fails, report the failing command and preserve the final plan in
  the response so it can be posted later.
