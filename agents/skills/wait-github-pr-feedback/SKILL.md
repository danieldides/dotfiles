---
name: wait-github-pr-feedback
description: Polls a GitHub PR for local review feedback, posted feedback, unresolved review threads, requested changes, failed checks, and Codex connector status. Use after opening a PR or when asked to wait for PR feedback before addressing comments or attempting merge.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Wait GitHub PR Feedback (gh CLI)

## When to use this skill

Use this skill after a PR is opened and before attempting final merge readiness.
It determines whether there is feedback to address, whether checks failed with
actionable issues, or whether the PR can be handed to
`merge-github-pr-when-ready`.

## Required information

Gather or infer:

1. **Repository**: `owner/repo` from the current git remote when possible.
2. **PR identifier**: PR number or full PR URL.
3. **Polling limit**: default to a bounded wait with concise progress updates.

If the repository or PR cannot be inferred, ask for the missing input.

## Guardrails

- This skill is read-only. Do not edit files, post replies, resolve threads,
  push commits, or merge.
- Return as soon as actionable feedback appears.
- Treat unresolved review threads, `CHANGES_REQUESTED`, explicit reviewer
  comments, `Local Review Feedback` comments, failed checks, and Codex connector
  feedback as actionable.
- Treat a Codex connector 👀 reaction as still reviewing and a 👍 reaction as
  approved.
- If no feedback appears before the bounded wait expires, report the current PR
  status and ask whether to continue waiting or attempt merge readiness.

## Workflow

1. Resolve repository and PR context.

   ```bash
   gh repo view
   gh pr view <pr-number> --repo <owner>/<repo> --json number,title,url,state,isDraft,baseRefName,headRefName,reviewDecision,statusCheckRollup,commits
   ```

   Stop if the PR is closed, inaccessible, or draft unless the user explicitly
   wants to wait on a draft PR.

2. Poll review threads and review decisions.

   ```bash
   gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ pullRequest(number:$number){ reviewDecision reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id databaseId author { login } body url createdAt } } } } } } } }' -f owner='<owner>' -f repo='<repo>' -F number=<pr-number>
   gh api repos/<owner>/<repo>/pulls/<pr-number>/reviews
   ```

   Return `feedback-posted` if any thread is unresolved, any latest blocking
   review state is `CHANGES_REQUESTED`, or a reviewer comment clearly requests a
   change or response.

3. Poll PR conversation comments.

   ```bash
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments --paginate
   ```

   Return `feedback-posted` if a new human or automation comment asks for a code
   change, clarification, or follow-up. Always treat a comment headed
   `## Local Review Feedback` with unchecked findings as `feedback-posted` so
   `address-github-pr-feedback` processes local subagent review findings.

4. Poll automated checks.

   ```bash
   gh pr view <pr-number> --repo <owner>/<repo> --json statusCheckRollup,mergeStateStatus
   gh pr checks <pr-number> --repo <owner>/<repo>
   ```

   Continue waiting while checks are queued, pending, in progress, waiting,
   requested, or expected. Return `checks-failed` if any required or relevant
   check fails, is cancelled, times out, or requires action. Return
   `checks-complete` only when all non-skipped checks are successful or neutral.

5. Poll Codex connector status.

   ```bash
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments --paginate -H 'Accept: application/vnd.github+json'
   gh api repos/<owner>/<repo>/pulls/<pr-number>/reviews
   gh api repos/<owner>/<repo>/issues/comments/<comment-id>/reactions -H 'Accept: application/vnd.github.squirrel-girl-preview+json'
   ```

   Continue waiting while the latest Codex connector reaction is 👀. Return
   `feedback-posted` if Codex posts requested changes or a blocking comment.
   Treat 👍 as Codex approval.

6. Decide the next action.

   Return one of these outcomes:

   - `feedback-posted`: use `address-github-pr-feedback`.
   - `checks-failed`: fix the issue, amend or squash, push with
     `--force-with-lease`, then poll again.
   - `still-waiting`: continue polling within the bounded wait.
   - `ready-for-merge-readiness`: use `merge-github-pr-when-ready`.
   - `blocked`: ask the user for a decision or missing permission.

## Polling behavior

- Poll at a practical interval, such as 30 to 60 seconds, unless the user asks
  for a specific cadence.
- Provide concise updates when status changes or when a meaningful interval has
  passed with no change.
- Use a bounded wait by default. If the bound expires, report the current checks,
  review, feedback, and Codex connector status.

## Output expected to user

Report:

1. PR URL and branch.
2. Current checks status.
3. Current review thread and review decision status.
4. Codex connector status, including 👀 or 👍 when found.
5. Outcome and recommended next skill or action.

## Failure handling

- If GitHub API calls fail, retry once after a short wait. If they continue to
  fail, report the endpoint and error.
- If the Codex connector comment cannot be found before the bounded wait expires,
  report it as missing rather than assuming approval.
- If feedback is ambiguous, report the exact comment URL and ask whether to treat
  it as actionable.
