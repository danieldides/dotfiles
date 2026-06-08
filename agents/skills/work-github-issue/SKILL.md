---
name: work-github-issue
description: Works a GitHub issue end-to-end using gh CLI: reads the issue, implements it, opens a PR, runs local PR feedback, requests up to three Codex reviews, waits for feedback, addresses feedback, and hands off to merge-github-pr-when-ready. Use when the user asks to work, implement, or complete a GitHub issue.
metadata:
  author: Daniel Dides
  version: "2.0"
---

# Work GitHub Issue (gh CLI)

## When to use this skill

Use this skill when the user wants an issue worked end-to-end: read the issue,
implement the requested change, open a PR, run local subagent review feedback,
request bounded Codex connector review, wait for reviewer or automation
feedback, address feedback when it appears, and then merge through the dedicated
PR merge-readiness workflow.

## Required input

Gather or infer:

1. **Issue id**: issue number or full issue URL.
2. **Repository**: `owner/repo` from the current git remote when possible.
3. **Base branch**: default to `main` unless the user specifies one.

If the issue or repository cannot be inferred, ask for the missing input.

## Preconditions

- `gh` is authenticated with repo access.
- GPG signing is configured for git.
- The working tree is clean before branch creation.

If the working tree has uncommitted changes, stop and ask the user how to
proceed before changing branches.

## Guardrails

- Ask the user only when blocked by missing input, dirty worktree state,
  ambiguous product/API decisions, merge approval, or conflict resolution.
- Keep exactly one commit for the issue. Amend when changing the branch; squash
  without an interactive editor if extra commits appear.
- Use `--force-with-lease`, never `--force`, after rewriting PR branch history.
- Do not paste issue body content into commit messages or PR descriptions.
- Do not merge directly from this skill. Use `merge-github-pr-when-ready` for
  final readiness checks and ff-only merge.
- Use `address-github-pr-feedback` for posted reviewer feedback, requested
  changes, unresolved review threads, or comments requiring a response.
- Use `local-github-pr-feedback` after opening the PR and after every pushed fix
  so local subagent review findings are posted to the PR and processed through
  the same feedback path.
- Request Codex connector review at most three times total for a PR. Count the
  initial request and every follow-up request after fixes. Do not request a
  fourth review; report that the cap was reached instead.
- Use `wait-github-pr-feedback` after opening the PR to distinguish posted
  feedback from a PR that is ready to attempt merge.

## Branch naming

Use `<issue-number>-<slugified-issue-title>`.

Slug rules: lowercase ASCII; replace non-alphanumeric runs with `-`; collapse
repeated `-`; trim edges; keep practical length, such as 60 characters.

If the branch exists, append a short numeric or timestamp suffix.

## Commit + PR message rules

- Commit must be signed: `git commit -S`.
- Commit subject must be a valid conventional commit.
- Commit body is required and must be:

```markdown
Closes #<issue-number>

## Summary

- <change 1>
- <change 2>
- <change 3>
```

- Keep summary concise and implementation-focused.
- PR title must match the commit subject.
- Create the PR with commit fill so the PR body comes from the commit body:
  `gh pr create --fill-verbose`.

## Workflow

1. Resolve repository and issue context.

   ```bash
   gh repo view
   gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state,labels,assignees
   gh repo view <owner>/<repo> --json defaultBranchRef
   ```

   Stop if the issue is closed or inaccessible.

2. Create and sync the issue branch.

   ```bash
   git fetch origin
   git checkout <base-branch>
   git pull --ff-only origin <base-branch>
   git checkout -b <issue-number>-<slug>
   ```

3. Implement the issue.

   - Make the smallest correct code changes that satisfy the issue.
   - Add or update tests when behavior changes or a regression needs coverage.
   - Run targeted validation first, then broader validation when practical.
   - If the issue requires a product or API decision that is not clear from the
     issue, ask the user before changing behavior.

4. Create one signed commit.

   ```bash
   git add <intended-files>
   git commit -S
   git log --oneline origin/<base-branch>..HEAD
   ```

   If there is more than one commit, squash before opening the PR:

   ```bash
   git reset --soft origin/<base-branch>
   git commit -S -m '<final conventional commit subject>'
   ```

5. Push the branch and open the PR.

   ```bash
   git push -u origin <branch>
   gh pr create --repo <owner>/<repo> --base <base-branch> --head <branch> --fill-verbose
   ```

6. Request initial Codex connector review.

   Request Codex review using the repository's configured connector trigger. If
   the trigger command or PR comment syntax is unknown, ask the user once before
   requesting. Record this as Codex review request `1/3`.

   Do not wait indefinitely for Codex in this step. The `wait-github-pr-feedback`
   and `merge-github-pr-when-ready` skills own polling for the Codex connector
   reaction changing from 👀 to 👍.

7. Run local PR feedback.

   Use the `local-github-pr-feedback` skill for the new PR. If it posts local
   review findings, continue to step 9 so `address-github-pr-feedback` can
   process them. If it finds no actionable local feedback, continue to step 8.

8. Wait for PR feedback.

   Use the `wait-github-pr-feedback` skill for the new PR. If it reports posted
   reviewer feedback, requested changes, unresolved review threads, failed
   checks with actionable failures, or Codex connector feedback, continue to step
   9. If it reports no posted feedback and the PR is ready for merge readiness,
   continue to step 10.

9. Address feedback and keep the branch squashed.

   Use the `address-github-pr-feedback` skill for reviewer comments, requested
   changes, unresolved review threads, local review comments, or feedback
   requiring a threaded response.

   For failed checks or local issues that are not review comments:

   ```bash
   git checkout <branch>
   # implement the fix
   git add <intended-files>
   git commit --amend -S --no-edit
   git push --force-with-lease
   ```

   If multiple commits exist at any point, squash without an interactive editor:

   ```bash
   git fetch origin <base-branch>
   git reset --soft origin/<base-branch>
   git commit -S -m '<final conventional commit subject>'
   git push --force-with-lease
   ```

   After addressing feedback or failed checks, request a follow-up Codex review
   only when the pushed fixes materially changed code or behavior and fewer than
   three Codex reviews have been requested. Record the count as `2/3` or `3/3`.
   If three Codex reviews have already been requested, do not request another;
   report that the cap was reached and continue the loop with the latest
   available feedback.

   Then return to step 7 so local review runs again on the updated diff before
   remote feedback polling resumes.

10. Attempt merge readiness and merge.

   Use the `merge-github-pr-when-ready` skill for the PR. That skill owns final
   checks, unresolved conversation checks, Codex connector approval, single
   commit enforcement, rebase-on-divergence, and ff-only merge into `main`.

   If `merge-github-pr-when-ready` reports new feedback, requested changes,
   failed checks, or a fixable code issue, return to step 9. If it rebases or
   squashes the branch, restart from step 7 so checks and feedback are evaluated
   against the latest commit. Do not reset the Codex review request count after a
   rebase or squash.

## Progress updates to user

Report at these checkpoints:

1. Issue loaded, including number, title, and URL.
2. Branch created or checked out.
3. Implementation summary and validation result.
4. Commit SHA and PR URL.
5. Codex review request count, such as `1/3`.
6. Local feedback outcome.
7. Feedback polling outcome.
8. Feedback addressed, checks fixed, or user decision needed.
9. Merge-readiness outcome from `merge-github-pr-when-ready`.

## Output expected to user

Report:

1. Issue and PR URLs.
2. Branch name and final commit SHA.
3. Validation commands and results.
4. Codex review request count and final Codex connector status.
5. Local feedback result.
6. Feedback handled or reason no feedback handling was needed.
7. Merge outcome, or the exact blocker if the PR was not merged.

## Failure handling

- If a command fails, report the command, key error, and next action.
- If feedback requires a product or API decision, ask the user before changing
  behavior.
- If checks fail, fix the issue when it is clear, amend/squash, push with
  `--force-with-lease`, and restart feedback polling.
- If Codex has already been requested three times and still has not approved,
  stop requesting new Codex reviews. Continue with available feedback and let
  `merge-github-pr-when-ready` report Codex approval as the blocker if required.
- If rebase conflicts occur, stop and ask the user how to proceed unless the
  resolution is obvious and directly within the issue scope.
- If `--force-with-lease` fails, fetch and inspect the new remote commits before
  attempting another push.
- If policy, protection, or permissions block merge, do not bypass. Report the
  exact blocker.
