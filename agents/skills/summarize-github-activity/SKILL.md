---
name: summarize-github-activity
description: Reviews GitHub activity for @danieldides over a recent time period and produces a Slack-ready markdown summary with inline PR and issue links. Use when the user asks for a GitHub activity summary, contribution recap, weekly update, or Slack status summary.
metadata:
  author: Daniel Dides
  version: "1.0"
---

# Summarize GitHub Activity

## When to use this skill

Use this skill when the user asks to summarize recent GitHub activity,
contributions, PRs, issues, reviews, commits, releases, or project work for
`@danieldides`.

The default reporting period is the last week unless the user specifies another
time period.

## Required information

Before gathering activity, determine:

1. **GitHub user**: Default to `danieldides`.
2. **Time period**: Default to the last 7 days. Accept natural-language periods
   such as `last week`, `last month`, `since Monday`, or explicit dates.
3. **Scope**: Default to all visible repositories and organizations accessible
   through the authenticated GitHub CLI session unless the user specifies a repo
   or organization.

If the requested period is ambiguous and materially affects the summary, ask one
short clarification question. Otherwise, use the default.

## Data gathering

Use the GitHub CLI (`gh`) first. Prefer GraphQL for cross-repository activity and
REST where it is simpler.

1. Verify authentication and viewer context:

   ```bash
   gh auth status
   gh api user --jq '{login,html_url}'
   ```

2. Convert the reporting period to ISO 8601 timestamps. For the default weekly
   report, use the last 7 days from the current date.

3. Search for pull requests authored by `danieldides` in the period:

   ```bash
   gh search prs --author danieldides --created ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,createdAt,updatedAt,closedAt
   ```

4. Search for issues authored by `danieldides` in the period:

   ```bash
   gh search issues --author danieldides --created ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,createdAt,updatedAt,closedAt
   ```

5. Search for PRs and issues updated by `danieldides` in the period when the
   authored searches miss relevant collaboration:

   ```bash
   gh search prs --involves danieldides --updated ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,author,createdAt,updatedAt,closedAt

   gh search issues --involves danieldides --updated ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,author,createdAt,updatedAt,closedAt
   ```

6. Query review and comment activity when needed to identify important work that
   is not captured by authored PRs or issues:

   ```bash
   gh search prs --reviewed-by danieldides --updated ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,author,createdAt,updatedAt,closedAt

   gh search prs --commenter danieldides --updated ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,author,createdAt,updatedAt,closedAt

   gh search issues --commenter danieldides --updated ">=<start-date>" --limit 100 \
     --json repository,number,title,state,url,author,createdAt,updatedAt,closedAt
   ```

7. Use GraphQL when search results need more context about recent reviews or
   comments:

   ```bash
   gh api graphql -f query='query { search(type:ISSUE, query:"involves:danieldides updated:>=PLACEHOLDER", first:100) { nodes { ... on PullRequest { title url number state mergedAt updatedAt repository { nameWithOwner } author { login } reviews(first:20) { nodes { author { login } state submittedAt } } comments(first:20) { nodes { author { login } createdAt } } } ... on Issue { title url number state updatedAt repository { nameWithOwner } author { login } comments(first:20) { nodes { author { login } createdAt } } } } } }'
   ```

   Replace `PLACEHOLDER` with the start date in `YYYY-MM-DD` form before running
   the command. If GraphQL search is unnecessary or the data is already clear,
   skip this step.

8. If commit activity is important, search commits authored by the user in the
   period for the relevant repositories. Use this only to fill gaps, not as the
   primary source when PRs describe the work well:

   ```bash
   gh api "search/commits?q=author:danieldides+author-date:>=<start-date>" \
     --header 'Accept: application/vnd.github.cloak-preview+json'
   ```

## Analysis

Group raw activity into major contributions rather than listing every event.
Prioritize:

1. Merged or shipped PRs.
2. Open PRs with meaningful progress.
3. Issues created, closed, or substantially advanced.
4. Reviews, discussion, or cross-repository collaboration that unblocked work.
5. Operational or maintenance activity, such as releases, dependency updates, or
   cleanup work.

Use repository names and item titles to infer contribution themes. Verify details
with `gh pr view`, `gh issue view`, or `gh api` when a title alone is not enough
or when you need exact merge timestamps.

## Output format

Return only Slack-ready markdown. Keep it concise and easy to paste.

Use this Slack-compatible markdown structure:

```markdown
*GitHub activity summary for @danieldides (<period>)*

- <Major contribution with inline links such as <https://github.com/owner/repo/pull/123|PR #123> or <https://github.com/owner/repo/issues/45|issue #45>.>
- <Major contribution with inline links.>
- <Major contribution with inline links.>

_Generated from GitHub activity visible to the authenticated `gh` session._
```

Rules:

- Limit the summary to five bullet points unless more are absolutely necessary.
- Prefer one bullet per contribution theme, not one bullet per PR or issue.
- Include Slack-style inline links to relevant PRs and issues in the bullet where
  they are mentioned: `<https://github.com/owner/repo/pull/123|PR #123>`.
- Include repository names when activity spans multiple repositories or the repo
  is not obvious from the linked title.
- Mention the time period in the heading.
- Do not include raw JSON, command output, or internal analysis.
- Do not use tables; Slack markdown handles bullets and inline links better.
- If no meaningful activity is found, say so in one bullet and include the data
  sources checked.

## Quality bar

- Be specific about outcomes: merged, opened, reviewed, closed, unblocked, or
  advanced.
- Avoid overstating impact. If a PR is open or unmerged, say that clearly.
- Collapse small related updates into one bullet.
- Surface only major activity; omit noise such as tiny comments, bot-created
  updates, and incidental issue mentions.
