# Hammer Gate and Execution Authorization Contract

Canonical issue: [growthpigs/the-foundry#67](https://github.com/growthpigs/the-foundry/issues/67)

The Hammer Gate is the boundary between reversible planning and execution. It exists to keep the Foundry autonomous without becoming aggressive.

## Rule

HAMMER does not begin until the project has a GitHub-recorded Hammer Authorization Record.

Local markdown files may mirror the record, but GitHub is the source of truth. If a local note and the GitHub record disagree, GitHub wins.

## Authorizing Language

These phrases authorize HAMMER when scoped to a specific issue, epic, or milestone:

- `Drop the Hammer`
- `HAMMER_AUTHORIZED`
- `Start HAMMER for <specific issue/epic>`

These phrases do not authorize HAMMER:

- `go`
- `continue`
- `execute`
- `I trust you`
- `do your best`
- `act as CTO/PM`
- `keep going`

Non-authorizing phrases may continue planning, GitHub cleanup, backlog preparation, docs, reversible local analysis, or dry-run verification. They do not authorize code changes, live infrastructure changes, production-bound migrations, paid resource upgrades, deploys, merges, or destructive operations.

## Hammer Authorization Record

Before HAMMER begins, post this as a GitHub issue comment on the parent issue, PRD issue, or epic issue:

```md
## Hammer Authorization Record

Scope: <issue/epic/milestone URL>
Authorized by: Roderic
Authorization phrase: "Drop the Hammer"
Allowed operations:
- Branches, commits, tests, docs, issue comments, draft PRs
- <any extra explicitly approved operations>

Explicitly not authorized unless separately approved:
- Merges to main or production branches
- Production deploys
- Live database migrations or destructive SQL
- Paid infrastructure creation or upgrades
- Secrets rotation or credential changes
- External client/user communications
- Any operation outside the scoped issue/epic/milestone
```

HAMMER agents must read this record from GitHub before implementation. A local copy is not enough.

## Production-Bound Line Items

Even after HAMMER is authorized, these operations require their own explicit approval line in GitHub:

- Applying migrations to a live or production-bound database
- Creating, upgrading, or deleting paid infrastructure
- Changing secrets, auth providers, RLS policies, or credential paths
- Deploying to production or promoting staging to production
- Merging to `main`, `production`, or any release branch
- Destructive git operations such as force-push, branch deletion, or reset
- Partner-visible decisions, HR/accounting judgments, or binding arbitration outputs

If the authorization record does not mention the operation, stop and ask for that specific approval.

## Runtime Behavior

PLAN may create specs, issues, milestones, checklists, and dry-run validation. PLAN stops at backlog readiness unless the Hammer Authorization Record exists.

HAMMER starts with a preflight:

1. Find the canonical GitHub issue, PRD issue, or epic issue.
2. Read the issue body and latest comments.
3. Confirm a Hammer Authorization Record exists.
4. Confirm the requested work is inside the recorded scope.
5. Confirm any production-bound line item is explicitly approved.

If any check fails, do not implement. Post the missing authorization need to GitHub and report it to Roderic.
