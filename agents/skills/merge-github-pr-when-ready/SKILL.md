---
name: merge-github-pr-when-ready
description: Polls a GitHub PR until checks, local review feedback, and reviewer feedback are complete, optionally waits briefly for Codex connector review, ensures a single commit, rebases on origin/main when needed, and merges to main with git --ff-only. Use when asked to wait for PR checks, merge when ready, poll a PR, or ff-only merge a reviewed branch.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Merge GitHub PR When Ready (gh CLI)

## When to use this skill

Use this skill when the user wants an existing GitHub pull request monitored and
merged after it is ready: automated checks complete successfully, review
feedback and local review feedback are resolved, the optional Codex connector
review has completed or the short wait for a Codex signal has expired, the PR
branch has exactly one commit, and the branch can be fast-forward merged into
`main`.

## Required information

Gather or infer:

1. **Repository**: `owner/repo` from the current git remote when possible.
2. **PR identifier**: PR number or full PR URL.
3. **Base branch**: default to `main` unless the user explicitly specifies a
   different branch.
4. **Polling limit**: default to a bounded wait with regular status reports if
   the user does not specify timing.

If the repository or PR cannot be inferred, ask for the missing input.

## Preconditions

- `gh` is authenticated with repo access.
- The local checkout can fetch, check out, rebase, and push the PR branch.
- Working tree state is understood before changing branches or rewriting
  commits.

If the working tree has uncommitted changes that are not yours, stop and ask the
user how to proceed before checking out, rebasing, squashing, or merging.

## Guardrails

- Do not merge unless all required gates pass.
- Do not bypass branch protection, failed checks, pending checks, or unresolved
  feedback.
- Treat Codex connector review as optional. Wait briefly for a Codex connector
  signal when one is expected, but do not block merge if Codex does not post an
  emoji reaction or feedback within that short wait.
- If Codex has posted feedback or a 👀 reaction, treat that as pending feedback
  and do not merge until it is resolved or changes to 👍.
- Keep the PR branch to exactly one commit before merge. Squash locally when
  necessary and push with `--force-with-lease`, never `--force`.
- Merge by updating local `main` with `git merge --ff-only <branch>` and pushing
  `main`. Do not use GitHub squash/rebase/merge buttons or `gh pr merge` unless
  the user explicitly asks.
- If the PR branch tip has diverged from `origin/main`, rebase the PR branch on
  `origin/main`, push with `--force-with-lease`, and restart polling from the
  checks/feedback gates.
- If rebase conflicts occur, stop and ask the user how to proceed unless the
  resolution is obvious and directly within the PR scope.

## Workflow

1. Resolve repository and PR context.

   ```bash
   gh repo view
   gh pr view <pr-number> --repo <owner>/<repo> --json number,title,url,state,isDraft,baseRefName,headRefName,headRepositoryOwner,author,mergeStateStatus,reviewDecision,statusCheckRollup,commits
   ```

   Stop if the PR is closed, inaccessible, draft, or targets a base branch other
   than `main` without explicit user approval.

2. Check out and sync the PR branch.

   ```bash
   gh pr checkout <pr-number> --repo <owner>/<repo>
   git status --short
   git fetch origin main
   ```

3. Ensure the branch is based on the current tip of `origin/main`.

   ```bash
   git merge-base --is-ancestor origin/main HEAD
   ```

   If `origin/main` is not an ancestor of `HEAD`, rebase and restart polling:

   ```bash
   git rebase origin/main
   git push --force-with-lease
   ```

4. Ensure the PR has exactly one commit.

   Count commits on top of `origin/main`:

   ```bash
   git log --oneline origin/main..HEAD
   ```

   If there is more than one commit, squash without an interactive editor:

   ```bash
   git reset --soft origin/main
   git commit -S -m '<final conventional commit subject>'
   git push --force-with-lease
   ```

   After squashing, restart polling because checks may need to re-run for the new
   commit SHA.

5. Poll automated checks until complete.

   Use the PR status rollup:

   ```bash
   gh pr view <pr-number> --repo <owner>/<repo> --json statusCheckRollup,mergeStateStatus
   ```

   Read the check list when a human-readable snapshot is useful:

   ```bash
   gh pr checks <pr-number> --repo <owner>/<repo>
   ```

   Proceed only when all non-skipped automated tasks are successful or neutral.
   Continue polling while any check is queued, pending, in progress, waiting,
   requested, or expected. Stop and report if any check fails, is cancelled, or
   requires action.

6. Optionally wait briefly for the Codex connector review.

   Inspect PR comments, reviews, and reactions for the Codex connector signal:

   ```bash
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments --paginate -H 'Accept: application/vnd.github+json'
   gh api repos/<owner>/<repo>/pulls/<pr-number>/reviews
   ```

   For the Codex connector comment, read its reactions if they are not embedded
   in the comment response:

   ```bash
   gh api repos/<owner>/<repo>/issues/comments/<comment-id>/reactions -H 'Accept: application/vnd.github.squirrel-girl-preview+json'
   ```

   Find the latest Codex connector comment or review status item. If Codex has
   posted feedback or its latest reaction is 👀, treat that as pending feedback
   and do not merge until the feedback is resolved or the reaction changes to 👍.

   If the Codex connector comment/review cannot be found, poll briefly, such as
   for 2 to 5 minutes unless the user specified a different wait. If Codex still
   has not posted an emoji reaction or feedback after that short wait, continue
   without Codex review and report that Codex did not respond in time.

7. Verify there is no pending, open feedback.

   Read unresolved review threads:

   ```bash
   gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id databaseId author { login } body url createdAt } } } } } } } }' -f owner='<owner>' -f repo='<repo>' -F number=<pr-number>
   ```

   Read reviews and review states:

   ```bash
   gh api repos/<owner>/<repo>/pulls/<pr-number>/reviews
   ```

   Read PR conversation comments and look for unchecked local review findings:

   ```bash
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments --paginate
   ```

   Do not merge if any review thread is unresolved, any latest blocking review
   state is `CHANGES_REQUESTED`, any `## Local Review Feedback` comment has
   unchecked blocking or important items, or there is clearly pending reviewer
   feedback that has not been addressed. Report the blockers and use
   `address-github-pr-feedback` to address posted feedback before retrying this
   skill.

8. Re-check merge readiness immediately before merging.

   ```bash
   gh pr view <pr-number> --repo <owner>/<repo> --json state,isDraft,baseRefName,headRefName,mergeStateStatus,reviewDecision,statusCheckRollup,commits
   git fetch origin main
   git merge-base --is-ancestor origin/main HEAD
   git log --oneline origin/main..HEAD
   ```

   If `origin/main` is no longer an ancestor, rebase, push with
   `--force-with-lease`, and restart polling.

9. Merge to `main` with fast-forward only.

   ```bash
   git checkout main
   git pull --ff-only origin main
   git merge --ff-only <pr-branch>
   git push origin main
   ```

   If `git merge --ff-only` fails because the tips have diverged, return to the
   PR branch, rebase onto `origin/main`, push with `--force-with-lease`, and
   restart polling:

   ```bash
   git checkout <pr-branch>
   git fetch origin main
   git rebase origin/main
   git push --force-with-lease
   ```

10. Verify final state.

   ```bash
   gh pr view <pr-number> --repo <owner>/<repo> --json state,mergedAt,mergeCommit,url
   git status --short
   ```

## Polling behavior

- Poll at a practical interval, such as 30 to 60 seconds, unless the user asks
  for a specific cadence.
- Provide concise progress updates when status changes, when checks remain
  pending for a meaningful interval, and before any rebase, squash, force-push,
  or merge.
- Use a bounded wait by default. If checks remain pending beyond the bound,
  report pending checks and ask whether to continue waiting.

## Output expected to user

Report:

1. PR URL and branch handled.
2. Final check status, feedback status, and Codex connector status if present.
3. Whether commits were squashed and force-pushed.
4. Whether a rebase onto `origin/main` was required.
5. Merge result and final `main` push status.

## Failure handling

- If checks fail, are cancelled, or require action, do not merge. Report the
  failing task names and statuses. If the failure is fixable, make the smallest
  correct patch, amend or squash to one commit, push with `--force-with-lease`,
  and restart polling.
- If unresolved conversations, unchecked local review findings, or blocking
  reviews exist, do not merge. Report the thread/comment URLs when available and
  use `address-github-pr-feedback`.
- If the Codex connector is missing or did not post an emoji reaction or feedback
  within the short optional wait, report that and continue without Codex review.
- If Codex has posted feedback or a 👀 reaction, do not merge. Report the current
  reaction/status and address or wait for it like other pending feedback.
- If squashing is required but the final commit message is not clear, ask the
  user for the commit subject before rewriting history.
- If `--force-with-lease` fails, fetch and inspect the new remote commits before
  attempting another push.
- If branch protection or permissions prevent pushing `main`, do not bypass.
  Report the exact blocker.
