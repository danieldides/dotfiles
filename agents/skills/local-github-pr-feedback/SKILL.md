---
name: local-github-pr-feedback
description: Runs a local subagent code review for a GitHub PR using code-review-skill and posts actionable findings as structured PR comments. Use after opening or updating a PR so address-github-pr-feedback can process local review feedback.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Local GitHub PR Feedback (Subagent Review)

## When to use this skill

Use this skill after opening a PR or after pushing fixes to a PR branch. It runs
a local code-review subagent against the PR diff and posts actionable findings
back to the PR as comments so `address-github-pr-feedback` can process them in
the normal feedback loop.

## Required information

Gather or infer:

1. **Repository**: `owner/repo` from the current git remote when possible.
2. **PR identifier**: PR number or full PR URL.
3. **Base branch**: default to the PR base branch, normally `main`.

If the repository or PR cannot be inferred, ask for the missing input.

## Preconditions

- `gh` is authenticated with repo access.
- The local checkout is the PR head branch or can safely check it out.
- Working tree state is understood before running validation commands.

If the working tree has uncommitted changes that are not yours and overlap with
the PR diff, stop and ask the user how to proceed.

## Guardrails

- Use the Task tool to launch a local `general` subagent for the review. The
  subagent should apply `code-review-skill` and focus on correctness,
  regressions, security, maintainability, and missing tests.
- Do not post low-signal nits, style preferences, praise-only comments, or
  findings that are already covered by existing PR feedback.
- Post at most one top-level PR comment per local review run.
- Post no PR comment when there are no actionable findings.
- Make findings specific enough for `address-github-pr-feedback` to implement:
  include file path, line or function when possible, severity, exact concern,
  and suggested fix.
- Do not edit code in this skill. It only reviews and posts feedback.

## Workflow

1. Resolve PR context and check out the branch.

   ```bash
   gh repo view
   gh pr view <pr-number> --repo <owner>/<repo> --json number,title,url,body,state,isDraft,baseRefName,headRefName,files,commits
   gh pr checkout <pr-number> --repo <owner>/<repo>
   git fetch origin <base-branch>
   git status --short
   ```

   Stop if the PR is closed or inaccessible.

2. Gather local review context.

   ```bash
   git diff --stat origin/<base-branch>...HEAD
   git diff --name-only origin/<base-branch>...HEAD
   git diff origin/<base-branch>...HEAD
   gh pr view <pr-number> --repo <owner>/<repo> --json title,body,url,statusCheckRollup,reviewDecision
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments --paginate
   gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
   ```

   Use existing PR comments to avoid reposting duplicate feedback.

3. Dispatch a local subagent review.

   Launch a local `general` subagent with the Task tool and instructions
   equivalent to:

   ```markdown
   Use `code-review-skill` to review this PR diff locally.

   Scope:
   - Review `origin/<base-branch>...HEAD`.
   - Prioritize bugs, behavioral regressions, security issues, missing tests,
     and maintainability risks.
   - Ignore formatting, stylistic preferences, and issues already raised in PR
     comments.
   - Do not modify files or post comments.

   Return only actionable findings. For each finding include:
   - severity: blocking, important, or optional
   - file path and line/function when available
   - exact concern
   - suggested fix
   - validation that should be run after the fix

   If there are no actionable findings, return exactly: `NO_FINDINGS`.
   ```

4. Post actionable findings as PR feedback.

   If the subagent returns `NO_FINDINGS`, do not post a comment. Report that the
   local review found no actionable feedback.

   If there are findings, post one structured PR comment:

   ```bash
   gh pr comment <pr-number> --repo <owner>/<repo> --body '<local review body>'
   ```

   Comment format:

   ```markdown
   ## Local Review Feedback

   Source: `local-github-pr-feedback` using `code-review-skill`

   Please address these findings via `address-github-pr-feedback`.

   - [ ] 🔴 blocking: `<file>:<line>` - <exact concern>
     Suggested fix: <specific fix>
     Validation: `<command>`
   - [ ] 🟡 important: `<file>:<line>` - <exact concern>
     Suggested fix: <specific fix>
     Validation: `<command>`
   ```

   Use only severities that match the actual findings:

   - 🔴 `blocking`: must fix before merge.
   - 🟡 `important`: should fix before merge unless there is a clear reason not
     to.
   - 🟢 `optional`: non-blocking suggestion.

5. Hand off to the feedback loop.

   After posting local findings, use `address-github-pr-feedback` to process the
   posted comment. After fixes are pushed, run this skill again once before
   returning to `wait-github-pr-feedback` or `merge-github-pr-when-ready`.

## Output expected to user

Report:

1. PR URL and branch reviewed.
2. Local review result: no findings, or number of findings posted.
3. Comment URL when a PR comment was posted.
4. Recommended next step: `address-github-pr-feedback` if findings were posted,
   otherwise `wait-github-pr-feedback` or `merge-github-pr-when-ready`.

## Failure handling

- If the subagent review fails, report the failure and do not post an empty or
  partial review comment.
- If posting the PR comment fails, report the `gh pr comment` error and keep the
  generated review body available in the final response.
- If findings are ambiguous or too broad to implement safely, ask the user before
  posting them as PR feedback.
