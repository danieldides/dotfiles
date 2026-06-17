---
name: work-multiple-github-issues
description: Sequentially works child GitHub issues from a parent tracking issue by dispatching an agent to run work-github-issue for each task. Use when the user asks to work, implement, or complete multiple GitHub issues from a parent, epic, meta, or tracking issue.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Work Multiple GitHub Issues (gh CLI)

## When to use this skill

Use this skill when the user provides a parent, epic, meta, or tracking GitHub
issue and wants the linked child issues worked sequentially. This skill is an
orchestrator: it discovers and orders the child issues, then dispatches one
agent at a time to execute the `work-github-issue` skill against each child
issue.

## Required input

Gather or infer:

1. **Parent issue id**: issue number or full issue URL for the tracking issue.
2. **Repository**: `owner/repo` from the current git remote when possible.
3. **Child issue order**: use the order in the parent issue body by default,
   unless the user specifies another order.
4. **Base branch**: default to `main` unless the user specifies one.

If the parent issue or repository cannot be inferred, ask for the missing input.
If child issue ordering is ambiguous, use the parent issue body order and report
that assumption before dispatching the first child.

## Preconditions

- `gh` is authenticated with repo access.
- The parent issue is readable.
- `work-github-issue` is available as a skill.
- The working tree is clean before the first child issue starts.

If the working tree has uncommitted changes before starting, stop and ask the
user how to proceed before dispatching any child issue agent.

## Guardrails

- Dispatch child issues sequentially, never in parallel.
- Wait for each dispatched agent to finish before starting the next child issue.
- Use a fresh agent invocation for each child issue unless the same child needs a
  continuation after a recoverable blocker.
- Do not implement child issues directly in this orchestration skill. Delegate
  implementation, PR creation, review handling, and merge readiness to
  `work-github-issue`.
- Do not skip a child issue unless it is closed, already completed, duplicated,
  blocked, or the user explicitly asks to skip it.
- Stop before starting the next child if a child issue agent reports a blocker,
  unresolved conflict, failed merge readiness, or a decision requiring user input.
- Do not create a batch branch or combined PR. Each child issue is handled by
  `work-github-issue` as its own branch, commit, PR, and merge workflow.
- Preserve the parent issue as the source of truth. Do not edit the parent issue
  unless the user explicitly asks for progress comments or checklist updates.

## Child issue discovery

1. Resolve repository and parent issue context.

   ```bash
   gh repo view
   gh issue view <parent-issue-number> --repo <owner>/<repo> --json number,title,body,url,state,comments
   ```

   Stop if the parent issue is inaccessible. Ask before continuing if the parent
   issue is closed.

2. Extract child issues from the parent issue body first, preserving order.

   Recognize common GitHub issue references:

   - `#123`
   - `owner/repo#123`
   - `https://github.com/<owner>/<repo>/issues/123`
   - Markdown checklist items such as `- [ ] #123` and `- [x] #123`

3. If the body does not clearly identify child issues, inspect parent comments.

   ```bash
   gh api repos/<owner>/<repo>/issues/<parent-issue-number>/comments
   ```

4. Deduplicate child issues while preserving first-seen order.

5. Exclude the parent issue itself if it appears in the extracted references.

6. Read each candidate child issue before dispatching work.

   ```bash
   gh issue view <child-issue-number> --repo <owner>/<repo> --json number,title,state,url,labels,assignees
   ```

   For cross-repository child references, use the referenced `owner/repo` for all
   commands and pass the full issue URL to the child agent.

## Child issue selection

Before dispatching the first child, produce a concise execution list:

```markdown
## Child Issues

1. #<number> <title> - <state> - <url>
2. #<number> <title> - <state> - <url>
```

Skip closed child issues by default and report them under `Skipped`. If a child
issue is open but appears complete because it has a merged closing PR or a label
such as `done`, `completed`, or `duplicate`, ask before skipping unless the
parent checklist marks it complete.

If no child issues can be found, stop and report that no actionable child issues
were discovered.

## Dispatch workflow

For each open, actionable child issue in order:

1. Confirm the working tree is clean.

   ```bash
   git status --short
   ```

   If the working tree is dirty, stop and ask the user how to proceed.

2. Dispatch a fresh general-purpose agent with a prompt that explicitly requires
   the `work-github-issue` skill.

   Prompt template:

   ```markdown
   Work GitHub issue <child-issue-url> end-to-end.

   Use the `work-github-issue` skill. Use repository `<owner>/<repo>` and base
   branch `<base-branch>` unless the issue requires otherwise. Follow that
   skill's workflow completely: read the issue, create the branch, implement the
   issue, validate, create one signed commit, open the PR, request bounded Codex
   review, run local PR feedback, wait for feedback, address feedback, and hand
   off to merge readiness. Do not return until the issue is merged, blocked, or
   requires user input.

   Return a concise final report with issue number, issue title, PR URL, merge
   status, validation commands run, and any blockers or follow-up required.
   ```

3. Wait for the child agent to complete.

4. Record the outcome before moving to the next child:

   - `completed`: PR merged and issue should be closed or closing.
   - `blocked`: child agent needs user input, conflict resolution, unavailable
     dependency, or product/API decision.
   - `failed`: child agent encountered an unrecoverable tool, auth, CI, or repo
     error.
   - `skipped`: child issue was closed, duplicate, already complete, or explicitly
     skipped.

5. If the outcome is `completed`, continue with the next child issue.

6. If the outcome is `blocked` or `failed`, stop the sequence and report the
   current status. Do not start later child issues until the blocker is resolved
   or the user explicitly asks to continue.

## Progress updates to user

Report at these checkpoints:

1. Parent issue loaded, including number, title, and URL.
2. Child issue execution list and skipped issues.
3. Start of each child issue, including current position such as `2/5`.
4. Outcome of each child issue before starting the next.
5. Final summary after all child issues complete or the sequence stops.

## Final report format

Use this structure:

```markdown
## Multiple Issue Work Summary

- Parent issue: #<number> <title> - <url>
- Completed: <count>
- Skipped: <count>
- Blocked or failed: <count>

## Results

- #<number> <title>: <completed|skipped|blocked|failed> - <PR URL or reason>

## Next Steps

- <Only include if blocked, failed, or follow-up work remains.>
```

## Failure handling

- If `gh` cannot read the parent issue, report the failing command and error.
- If child issue extraction is uncertain, ask the user to confirm the execution
  list before dispatching agents.
- If a dispatched child agent returns without using `work-github-issue`, stop and
  report that the child run did not follow the required workflow.
- If authentication, signing, or branch state blocks a child issue, stop the
  sequence and preserve the child issue result in the final report.
