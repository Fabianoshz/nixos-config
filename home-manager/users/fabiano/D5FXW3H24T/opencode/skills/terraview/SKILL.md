---
name: terraview
dependencies:
  - bash: command -v terraview
    error: "Install Terraview go/terraview"
allowed-tools:
  - Bash(terraview:*)
  - Bash(jq:*)
description: >
  Uses the `terraview` CLI to inspect Terraform Cloud runs, workspaces,
  organizations, JSON schemas, and CI plan summaries from an LLM context. Use
  when investigating TFC run IDs, org/workspace paths, plan diffs, diagnostics,
  failed applies, org workspace health, or Terraform Cloud speculative plan
  summaries in CI. Covers non-interactive `terraview json`, `terraview schema`,
  and `terraview ci`.
---

# Terraview: LLM Usage Guide

`terraview` inspects Terraform Cloud. For agent and automation workflows, use
the non-interactive commands:

```bash
terraview json <target>    # structured JSON for run, workspace, or org
terraview schema           # annotated schemas for terraview json output
terraview ci ...           # markdown TFC plan summary for CI/PR comments
```

The old `terraview --json <target>` flag is hidden for backward compatibility.
Prefer `terraview json <target>` in new guidance and examples.

## Authentication

Terraview reads Terraform Cloud credentials from `terraform login` credentials.
Env vars override that file:

```bash
export TFE_TOKEN=<token>          # highest-priority TFC token
export TF_TOKEN=<token>           # fallback TFC token
export TFE_HOST=app.terraform.io  # default; override for Terraform Enterprise
```

Never print token values. If a token must be supplied in CI, pass it through the
environment or a secret manager.

## JSON Mode

Use `terraview json` for all LLM-driven Terraform inspection. It writes JSON to
stdout; fatal errors go to stderr with a non-zero exit code. Partial failures
such as missing plan JSON are represented in the top-level `errors[]` array while
the rest of the output remains usable.

```bash
# Inspect a specific run: run metadata, plan summary, diffs, diagnostics, apply
terraview json run-YDiX5myA5JLkf4TQ

# Inspect a run from a Terraform Cloud URL
terraview json https://app.terraform.io/app/org/workspaces/ws/runs/run-YDiX5myA5JLkf4TQ

# List workspace metadata plus recent runs
terraview json org-name/workspace-name

# Same workspace mode by ws-* ID
terraview json ws-abc123

# List all workspaces in an org with current run status
terraview json org-name
```

Run `terraview schema` when exact fields matter. The schema command is generated
from the current Terraview structs and is the source of truth.

## JSON Schemas

These field names and shapes match the current `terraview schema` output. For
exact optionality, run `terraview schema`; fields omitted by Terraview are
normally absent rather than set to `null`. In successful lookups, the mode's
primary object (`run`, `workspace`, or `workspaces`) should be present.

### Run Output

Produced by `terraview json <run-id>` or `terraview json <run-url>`.

```json
{
  "version": "string",
  "mode": "string",
  "timestamp": "string",
  "run": {
    "id": "string",
    "status": "string",
    "source": "string",
    "message": "string",
    "created_at": "string",
    "created_by": "string",
    "terraform_version": "string",
    "plan_id": "string",
    "apply_id": "string"
  },
  "plan": {
    "summary": {
      "add": 0,
      "change": 0,
      "remove": 0,
      "import": 0
    },
    "resources": [
      {
        "address": "string",
        "action": "string",
        "diffs": [
          {
            "key": "string",
            "kind": "string",
            "old_value": "string",
            "new_value": "string"
          }
        ]
      }
    ],
    "diagnostics": [
      {
        "severity": "string",
        "summary": "string",
        "detail": "string",
        "file": "string",
        "line": 0,
        "column": 0,
        "snippet": "string"
      }
    ],
    "drift": [
      {
        "address": "string",
        "action": "string",
        "diffs": []
      }
    ],
    "outputs": {
      "<name>": {
        "value": null,
        "type": null,
        "sensitive": false,
        "action": "string"
      }
    }
  },
  "apply": {
    "status": "string",
    "additions": 0,
    "changes": 0,
    "destructions": 0
  },
  "errors": [
    {
      "source": "string",
      "message": "string"
    }
  ]
}
```

Important values:

| Field | Notes |
| --- | --- |
| `run.status` | TFC lifecycle status such as `pending`, `planning`, `planned`, `applying`, `applied`, `errored`, `canceled`, `discarded`, `planned_and_finished` |
| `plan.summary` | Aggregate counts: `add`, `change`, `remove`, `import` |
| `plan.resources[].action` | Usually `create`, `update`, `delete`, `replace`, or `read` |
| `plan.resources[].diffs[].kind` | Usually `added`, `removed`, `changed`, `unknown`, or `sensitive` |
| `plan.drift` | Resources changed outside Terraform, using the same shape as `resources` |
| `apply` | Omitted when no apply exists or the run never reached apply |
| `errors` | Non-fatal fetch or parse failures; always check this when plan data is empty |

### Workspace Output

Produced by `terraview json <org>/<workspace>` or `terraview json <ws-id>`.

```json
{
  "version": "string",
  "mode": "string",
  "timestamp": "string",
  "workspace": {
    "id": "string",
    "name": "string",
    "org": "string",
    "description": "string",
    "current_run_status": "string",
    "current_run_id": "string",
    "vcs_repo": "string",
    "vcs_branch": "string",
    "project_name": "string",
    "tags": ["string"],
    "updated_at": "string"
  },
  "runs": [
    {
      "id": "string",
      "status": "string",
      "message": "string",
      "source": "string",
      "created_at": "string",
      "is_destroy": false,
      "additions": 0,
      "changes": 0,
      "destructions": 0
    }
  ],
  "errors": [
    {
      "source": "string",
      "message": "string"
    }
  ]
}
```

`runs` contains up to the last 20 runs, newest first.

### Org Output

Produced by `terraview json <org>`.

```json
{
  "version": "string",
  "mode": "string",
  "timestamp": "string",
  "org": "string",
  "workspaces": [
    {
      "id": "string",
      "name": "string",
      "current_run_status": "string",
      "current_run_id": "string",
      "locked": false,
      "vcs_repo": "string",
      "project_name": "string",
      "health_state": "string",
      "updated_at": "string"
    }
  ],
  "errors": [
    {
      "source": "string",
      "message": "string"
    }
  ]
}
```

## jq Recipes

Always extract only the fields needed; full run output can be large.

```bash
# Current run status
terraview json run-XXX | jq '.run.status'

# Plan change counts
terraview json run-XXX | jq '.plan.summary'

# Errors and diagnostics for failure triage
terraview json run-XXX | jq '{
  run_status: .run.status,
  diagnostics: (.plan.diagnostics // []),
  errors: (.errors // [])
}'

# Error diagnostics only
terraview json run-XXX | jq '.plan.diagnostics[]? | select(.severity == "error")'

# Destroyed resources
terraview json run-XXX | jq '.plan.resources[]? | select(.action == "delete") | .address'

# Attribute diffs for one resource
terraview json run-XXX | jq '.plan.resources[]? | select(.address == "aws_s3_bucket.logs") | .diffs'

# Drift summary
terraview json run-XXX | jq '.plan.drift[]? | {address, action}'

# Workspaces in an org needing attention
terraview json my-org | jq '[
  .workspaces[] | select(.current_run_status == "errored" or .current_run_status == "planned" or .locked)
  | {name, current_run_status, current_run_id, locked}
]'

# Current run for a workspace, then inspect diagnostics
run_id=$(terraview json my-org/my-workspace | jq -r '.workspace.current_run_id')
terraview json "$run_id" | jq '.plan.diagnostics // []'

# Recent destroy runs in a workspace
terraview json my-org/my-workspace | jq '.runs[]? | select(.is_destroy) | {id, status, created_at}'

# Non-fatal errors
terraview json run-XXX | jq '.errors // []'
```

## Common Investigation Workflows

### Why Did This Run Fail?

```bash
terraview json run-XXX | jq '{
  status: .run.status,
  summary: (.plan.summary // null),
  diagnostics: (.plan.diagnostics // []),
  errors: (.errors // [])
}'
```

Interpretation:

- If the command exits non-zero, report the stderr error as fatal.
- If `.errors[]` is non-empty, explain that output may be partial.
- If `.plan.diagnostics[]` contains `severity == "error"`, lead with those.
- If the run failed during apply, check `.apply` and TFC directly if logs are needed.

### What Will This Plan Change?

```bash
terraview json run-XXX | jq '{
  summary: .plan.summary,
  creates: [.plan.resources[]? | select(.action == "create") | .address],
  deletes: [.plan.resources[]? | select(.action == "delete") | .address],
  replaces: [.plan.resources[]? | select(.action == "replace") | .address],
  updates: [.plan.resources[]? | select(.action == "update") | .address]
}'
```

### Which Workspaces Need Attention?

```bash
terraview json my-org | jq '[
  .workspaces[]
  | select(.current_run_status == "errored" or .current_run_status == "planned" or .locked)
  | {name, status: .current_run_status, run_id: .current_run_id, locked, health_state}
]'
```

### Drill Into Failed Workspaces

```bash
terraview json my-org \
  | jq -r '.workspaces[] | select(.current_run_status == "errored") | .current_run_id' \
  | while read id; do
      printf '\n%s\n' "$id"
      terraview json "$id" | jq '{status: .run.status, diagnostics: (.plan.diagnostics // []), errors: (.errors // [])}'
    done
```

## CI Mode

Use `terraview ci` in CI to discover Terraform Cloud speculative plans from
GitHub commit statuses, wait for them to reach a terminal state, fetch plan
details, and render a markdown PR comment to stdout.

```bash
terraview ci \
  --org MyOrg \
  --repo owner/repo \
  --sha abc123 \
  --footer "Optional footer" \
  --discovery-timeout 3m \
  --completion-timeout 15m \
  --poll-interval 15s
```

Required inputs:

| Input | Source |
| --- | --- |
| `--org` | Terraform Cloud organization name |
| `--sha` | Git commit SHA whose commit statuses link to TFC runs |
| `--repo` | GitHub `owner/repo`; defaults to `GITHUB_REPOSITORY` |
| `--github-token` | GitHub API token; defaults to `GITHUB_TOKEN` |
| TFC token | `TFE_TOKEN`, `TF_TOKEN`, or `terraform login` credentials |

Timeout flags accept Go duration strings such as `30s`, `3m`, or `15m`.

CI behavior:

- Discovery polls GitHub commit statuses for contexts matching
  `Terraform Cloud/<org>/<workspace>`.
- Run IDs are extracted from each status target URL.
- After the first run is found, discovery waits a short grace period for more
  workspace statuses before moving on.
- Runs are polled until terminal status or `--completion-timeout`.
- Plan details are fetched for successful terminal statuses. Errored, canceled,
  discarded, or timed-out runs are summarized with a warning/caution section.
- Output is markdown only. Redirect stdout to a file when posting PR comments.
- Progress and operational logs go to stderr.

Example GitHub Actions pattern:

```bash
terraview ci \
  --org "$TFC_ORG" \
  --repo "$GITHUB_REPOSITORY" \
  --sha "$HEAD_SHA" \
  --footer "$COMMENT_FOOTER" \
  > "$RUNNER_TEMP/plan_comment.md"
```

## Error Handling Notes

- Non-zero exit code means a fatal failure such as auth, invalid target, network
  failure, or missing required CI inputs.
- `errors[]` in JSON output means partial data. Include those messages when
  summarizing results.
- `plan` and `apply` are optional. Guard jq access with `//` or `[]?`.
- Attribute `diffs` require plan JSON access. Without it, resources and actions
  may still be available from parsed plan logs.
- `terraview schema` is cheap and local; run it when updating parsers, tests, or
  agent instructions that depend on exact output shape.
