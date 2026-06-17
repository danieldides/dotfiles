---
name: address-github-pr-feedback
description: Addresses GitHub PR review feedback using gh CLI: triages comments including Local Review Feedback, creates code patches when required, replies explaining changes or decisions, and squashes/amends commits after submitting fixes. Use when the user asks to address PR feedback, reviewer comments, requested changes, local review comments, or review threads.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Address GitHub PR Feedback (gh CLI)

## When to use this skill

Use this skill when the user wants review feedback on an existing GitHub pull
request addressed end-to-end: inspect reviewer comments, implement required
patches, respond to the feedback, and leave the PR with a clean squashed commit
history. This includes `## Local Review Feedback` comments posted by
`local-github-pr-feedback`.

## Required information

Gather or infer:

1. **Repository**: `owner/repo` from the current git remote when possible.
2. **PR identifier**: PR number or full PR URL.
3. **Feedback scope**: all unresolved feedback by default, or only the specific
   comments/threads the user names.

If the repository or PR cannot be inferred, ask for the missing input.

## Preconditions

- `gh` is authenticated with repo access.
- The local checkout is the PR head branch or can safely switch to it.
- Working tree state is understood before editing.

If the working tree has uncommitted changes that are not yours and overlap with
the files you need to edit, stop and ask the user how to proceed. Otherwise,
preserve unrelated changes and avoid touching them.

## Guardrails

- Address reviewer feedback directly; do not broaden scope unless required to
  make the requested change correct.
- Reply to every handled feedback item with either the change made or the reason
  no change was made.
- Treat unchecked `## Local Review Feedback` checklist items as actionable
  feedback. Implement or explicitly decline each blocking/important item.
- Treat Codex comments that imply no issues were found, such as `Didn't find
  any major issues.`, as non-blocking clearance. Do not tag Codex again or wait
  for another Codex response solely because of that comment.
- Keep reviewer-facing comments factual and concise. Include file/function names
  or test results when useful.
- Prefer resolving review threads only after the change is pushed and the reply
  has been posted.
- Squash by amending or interactive-free reset/recommit only after patches are
  complete and comments have been submitted.
- Use `--force-with-lease`, never `--force`, after rewriting PR branch history.
- Do not merge the PR unless the user explicitly asks.
- After feedback is addressed and pushed, return to `wait-github-pr-feedback` or
  `merge-github-pr-when-ready` rather than attempting to merge in this skill.

## Steps

1. Resolve repository and PR context.

   ```bash
   gh repo view
   gh pr view <pr-number> --repo <owner>/<repo> --json number,title,url,state,isDraft,baseRefName,headRefName,headRepositoryOwner,author,reviewDecision,statusCheckRollup
   ```

   Stop if the PR is closed, inaccessible, or from a fork you cannot push to.

2. Check out and sync the PR branch.

   ```bash
   gh pr checkout <pr-number> --repo <owner>/<repo>
   git status --short
   git fetch origin
   ```

3. Collect review feedback.

   Read inline review comments:

   ```bash
   gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
   ```

   Read PR conversation comments:

   ```bash
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments
   ```

   For comments headed `## Local Review Feedback`, inspect unchecked checklist
   items as feedback items. Preserve the comment ID so it can be updated after
   the items are handled.

   For comments from Codex, classify messages that imply no issues were found
   as already clear rather than actionable feedback. Examples include `Didn't
   find any major issues.` or equivalent wording.

   Read reviews and review states:

   ```bash
   gh api repos/<owner>/<repo>/pulls/<pr-number>/reviews
   ```

   When GraphQL is useful for unresolved thread state, query review threads:

   ```bash
   gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id databaseId author { login } body url createdAt } } } } } } } }' -f owner='<owner>' -f repo='<repo>' -F number=<pr-number>
   ```

4. Build a feedback checklist.

   For each item, record:

   - Comment URL or thread ID.
   - Author and exact concern.
   - Target file/line when present.
   - Whether it came from `Local Review Feedback` and the source checklist item.
   - Decision: patch, no-op with explanation, or needs user input.
   - Validation needed.

5. Implement patches when required.

   - Make the smallest correct code changes.
   - Preserve unrelated worktree changes.
   - Add or update tests when feedback changes behavior or guards a regression.
   - Run targeted validation first, then broader validation when practical.

6. Commit and push patch changes before replying.

   If the PR already has a single commit, amend it:

   ```bash
   git add <intended-files>
   git commit --amend --no-edit
   git push --force-with-lease
   ```

   If the PR has multiple commits and the repository expects a squashed PR,
   create a temporary fix commit first if needed, push it, reply to comments,
   then squash in step 9.

7. Reply to each feedback item as a response, not a top-level PR comment.

    For review threads collected through GraphQL, reply to the thread directly:

    ```bash
    gh api graphql -f query='mutation($threadId:ID!, $body:String!){ addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url } } }' -f threadId='<thread-id>' -f body='<reply body>'
    ```

    For inline review comments when only the review comment database ID is
    available, use the REST reply endpoint for that comment:

    ```bash
    gh api repos/<owner>/<repo>/pulls/<pr-number>/comments/<comment-id>/replies -f body='<reply body>'
    ```

    Do not use `gh pr comment` for handled feedback because it creates a
    top-level PR conversation comment rather than a response to the feedback.
    If a feedback item is a general PR conversation comment without a supported
    threaded reply API, report that limitation to the user instead of posting a
    top-level comment.

   Reply format:

   ```markdown
   Addressed in <short-sha>: <brief explanation of the change>.

   Validation: `<command>` passed.
   ```

   If no code change was made:

   ```markdown
   I did not change this because <specific reason>. <Optional supporting detail>.
   ```

   For `Local Review Feedback` comments, edit the original comment after all
   checklist items are handled so future polling does not treat the same items
   as new feedback:

   ```bash
   gh api repos/<owner>/<repo>/issues/comments/<comment-id> -X PATCH -f body='<updated body with handled items checked and short resolution notes>'
   ```

   Keep the original findings visible. Mark handled items with `[x]` and append
   concise notes such as `Addressed in <short-sha>` or `Declined: <reason>`.

8. Resolve handled review threads when appropriate.

   Only resolve threads after the patch is pushed and the explanatory reply is
   posted:

   ```bash
   gh api graphql -f query='mutation($threadId:ID!){ resolveReviewThread(input:{threadId:$threadId}) { thread { id isResolved } } }' -f threadId='<thread-id>'
   ```

9. Squash commits after submitting patches and replies.

   Determine the base branch and commits on the PR:

   ```bash
   gh pr view <pr-number> --repo <owner>/<repo> --json baseRefName,headRefName,commits
   git fetch origin <base-branch>
   git log --oneline origin/<base-branch>..HEAD
   ```

   If there is more than one PR commit, squash without using an interactive
   editor:

   ```bash
   git reset --soft origin/<base-branch>
   git commit -S -m '<final conventional commit subject>'
   git push --force-with-lease
   ```

   If there is already exactly one commit, amend it after patches instead of
   creating additional commits:

   ```bash
   git commit --amend --no-edit
   git push --force-with-lease
   ```

10. Verify final PR state.

    ```bash
    gh pr view <pr-number> --repo <owner>/<repo> --json reviewDecision,statusCheckRollup,commits,url
    git status --short
    ```

## Output expected to user

Report:

1. PR URL and branch handled.
2. Feedback items addressed, grouped by patch/no-change/user-input.
3. Validation commands and results.
4. Replies posted and threads resolved, if applicable.
5. Final commit count and whether history was force-pushed with
   `--force-with-lease`.
6. Recommended next step: usually `wait-github-pr-feedback`, then
   `merge-github-pr-when-ready` once feedback and checks are clear. If the only
   outstanding Codex signal is a no-issues-found message, proceed without
   tagging Codex again.

## Failure handling

- If a comment cannot be replied to because the API endpoint rejects it, do not
  post a top-level fallback comment. Report the failed reply with the original
  comment URL and error so the user can decide whether to comment manually.
- If checks fail after patches, do not squash until the failure is investigated
  or explicitly accepted by the user.
- If feedback requires a product or API decision, ask the user before changing
  behavior.
- If `--force-with-lease` fails, fetch and inspect the new remote commits before
  attempting another push.
