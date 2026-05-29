---
name: pipeline-snapshot
description: >
  At-a-glance pipeline snapshot showing per-stage counts and progress deltas
  since the last snapshot. Use when the user says "pipeline snapshot", "at a
  glance", "phase counts", "quick pipeline view", "show me the funnel", "stage
  progress", "what changed in my pipeline", "weekly pipeline brief", or "daily
  pipeline brief". Designed to be baked into a daily or weekly Routine — see the
  "Bake it into a Routine" section. Read-only — no stage changes, no drafts, no
  archives. Related: pipeline-health-check for deep diagnostic with warning signs
  and recommendations, stage-conversion-analysis for stage-by-stage transcript
  deep dive, won-deal-analysis for closed deal patterns.
metadata:
  version: "1.0"
  author: linkninja
---

# Pipeline Snapshot

A scannable per-stage view of the pipeline. Two modes:

- **Interactive** — current counts per stage with turn/freshness breakdown. Run any time.
- **Routine** — per-stage deltas vs the last persisted snapshot, rendered as a push-shaped brief. Designed for a scheduled daily or weekly fire.

**This skill does NOT:**
- Diagnose or recommend (that is `pipeline-health-check`)
- Deep-dive into transcripts (that is `stage-conversion-analysis`)
- Change stages, draft messages, or archive

**This skill DOES:**
- Show counts in every stage in one table
- Track progress since the last snapshot
- Persist a baseline so the next run has something to diff against
- Output a compact brief suitable for a Telegram/email push from a routine

## Before Starting

1. Run `get_context()` to load the user's sales context.
2. Detect the mode:

| Trigger | Mode | Period |
|---------|------|--------|
| `/pipeline-snapshot` (no args) | Interactive | — |
| `/pipeline-snapshot daily` | Routine | daily |
| `/pipeline-snapshot weekly` | Routine | weekly |
| Invoked from a scheduled routine | Routine | from arg |

3. Check prerequisites:

| Check | How | If Not Met |
|-------|-----|------------|
| Pipeline has been classified | `pipeline_stats()` — at least one stage has > 0 | "Your pipeline is empty. Classify some conversations first — try **full-morning-triage** or `start_batch_classify()`." |
| Stages defined | `stages()` returns the user's stage list | Use the default 7-stage list (opening, chatting, qualified, discovery, closing, won, lost). |

4. Proceed to the workflow that matches the mode.

## Workflow — Interactive Mode

### Step 1: Current snapshot

```
pipeline_stats()
```

### Step 2: Render the per-stage table

| Stage | Count | My Turn | Their Turn | Cold | You Ghosted |
|-------|-------|---------|------------|------|-------------|
| Opening | — | — | — | — | — |
| Chatting | — | — | — | — | — |
| Qualified | — | — | — | — | — |
| Discovery | — | — | — | — | — |
| Closing | — | — | — | — | — |
| Won | — | — | — | — | — |
| Lost | — | — | — | — | — |
| **Active total** | **—** | **—** | **—** | **—** | **—** |

Active total excludes won + lost (they are closed outcomes, not active pipeline).

### Step 3: One-line heads-up

Below the table, a single line flagging the most urgent thing the data shows:

| Condition | Heads-up text |
|-----------|---------------|
| Total `my_turn` > 10 | "X conversations waiting on your reply." |
| Cold in discovery/closing > 0 | "X discovery/closing convos going cold." |
| You-ghosted > 5 | "X conversations you owe a reply." |
| None of the above | "Nothing flagged. Pipeline looks tended." |

Stop here. Do not write deltas in interactive mode — there is no baseline to diff against by default.

## Workflow — Routine Mode

### Step 1: Read the previous baseline

The baseline is a small JSON snapshot persisted between runs. Path:

```
~/.linkninja/state/pipeline-snapshot-<period>.json
```

Where `<period>` is `daily` or `weekly`.

Read it. If the file does not exist, this is the first run — note that and skip delta computation.

Expected shape:

```json
{
  "captured_at": "2026-05-22T08:00:00+10:00",
  "period": "weekly",
  "counts": {
    "opening": 35,
    "chatting": 18,
    "qualified": 13,
    "discovery": 3,
    "closing": 3,
    "won": 7,
    "lost": 11
  }
}
```

### Step 2: Current snapshot

```
pipeline_stats()
```

Extract per-stage counts into the same shape.

### Step 3: Compute per-stage deltas

For each stage in the user's stage list:

```
delta[stage] = current[stage] - previous[stage]
```

If previous is missing (first run), deltas are not computed.

### Step 4: Persist the new baseline

Overwrite the baseline file with the current snapshot. The next run reads this.

Use the Write tool to overwrite `~/.linkninja/state/pipeline-snapshot-<period>.json` with the new JSON.

### Step 5: Render the brief

Compact format, suitable for a push notification:

```
Pipeline brief — <period> ending <today>
(vs <previous captured_at date>)

| Stage | Now | Δ |
|-------|-----|---|
| Opening | 47 | +12 |
| Chatting | 23 | +5 |
| Qualified | 11 | −2 |
| Discovery | 4 | +1 |
| Closing | 3 | 0 |
| Won | 8 | +1 |
| Lost | 14 | +3 |

Active total: 88 (+17)
Closed this <period>: W1 / L3

Heads up: <one line — same rules as interactive mode>
```

Delta formatting:
- `+N` for positive
- `−N` (en-dash) for negative
- `0` for no change

On the first run (no baseline), omit the `Δ` column and include the line: "First snapshot captured. Next run will show deltas."

Stop after rendering. Do not take further action.

## Bake it into a Routine

A copy-paste recipe to fire this skill on a schedule and persist the baseline.

### Anthropic Routines (cloud)

```bash
claude schedule create \
  --name "pipeline-daily-brief" \
  --cron "0 8 * * *" \
  --timezone "Australia/Sydney" \
  --prompt-file ~/.claude/routines/pipeline-daily-brief.prompt.md \
  --allowed-tools "get_context,pipeline_stats,Read,Write"
```

Prompt file at `~/.claude/routines/pipeline-daily-brief.prompt.md`:

```
Run the /pipeline-snapshot skill in routine mode for period "daily".

Steps:
1. get_context()
2. pipeline_stats()
3. Read ~/.linkninja/state/pipeline-snapshot-daily.json (the previous baseline). If missing, this is the first run.
4. Compute per-stage deltas.
5. Write the new snapshot to ~/.linkninja/state/pipeline-snapshot-daily.json.
6. Output ONLY the brief — no preamble, no commentary, no recommendations.

This is read-only reporting. Do not change stages, write drafts, or archive anything.
```

For weekly, swap the cron to `0 8 * * 1` (Monday 8am) and the path to `pipeline-snapshot-weekly.json`.

### macOS launchd (local)

`~/Library/LaunchAgents/com.linkninja.pipeline-daily-brief.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.linkninja.pipeline-daily-brief</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/env</string>
    <string>bash</string>
    <string>-c</string>
    <string>claude -p "$(cat ~/.claude/routines/pipeline-daily-brief.prompt.md)" --allowedTools "get_context,pipeline_stats,Read,Write"</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>8</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>StandardOutPath</key><string>/tmp/pipeline-daily-brief.log</string>
  <key>StandardErrorPath</key><string>/tmp/pipeline-daily-brief.err</string>
</dict>
</plist>
```

Load with:

```
launchctl load ~/Library/LaunchAgents/com.linkninja.pipeline-daily-brief.plist
```

### Routine spec (universal)

```yaml
routine:
  slug: pipeline-daily-brief
  schedule: "0 8 * * *"
  timezone: <user's TZ>
  prompt_file: ~/.claude/routines/pipeline-daily-brief.prompt.md
  allowed_tools:
    - get_context
    - pipeline_stats
    - Read
    - Write
  caps:
    max_tool_calls_per_run: 6
    max_drafts_per_run: 0
    max_runs_per_day: 2
  on_failure:
    log_to_memory: true
    exit_clean: true
```

Caps rationale: the skill calls `get_context` (1) + `pipeline_stats` (1) + `Read` previous (1) + `Write` new (1) = 4 tool calls. Cap at 6 leaves slack for one optional `search` if the heads-up line needs a count. Zero drafts because this skill never drafts.

## Delivery Options

A raw Routine fires the prompt and writes the brief to its log — it does not push the brief to you. Wire delivery one of three ways:

| Option | How | When to choose |
|--------|-----|----------------|
| Wrap in a Monitor | `/monitor-architect` — same skill body, Monitor adds the Telegram / email / push delivery + a deep-link back to the dashboard | You want the brief delivered to a channel |
| Tail the log | `tail -f /tmp/pipeline-daily-brief.log` on local, or the cloud routine's log viewer | You want to spot-check, not be pinged |
| Read the baseline file | `cat ~/.linkninja/state/pipeline-snapshot-<period>.json` any time | You want the latest snapshot on demand without firing the skill |

Most users want option 1. The skill is identical — the Monitor wrapper just changes who hears the brief.

## Arguments

| Arg | Values | Effect |
|-----|--------|--------|
| `daily` | — | Routine mode using `pipeline-snapshot-daily.json` baseline |
| `weekly` | — | Routine mode using `pipeline-snapshot-weekly.json` baseline |
| (none) | — | Interactive mode (current state only, no deltas) |

Other periods (monthly, fortnightly) follow the same pattern — pick a `<period>` slug and the baseline file is named to match.

## Guidelines

- Read-only. Never change a stage, write a draft, or archive anything from this skill.
- One `pipeline_stats()` call is enough. Do not export full conversations — that is `stage-conversion-analysis`.
- The baseline file is the source of truth for deltas. If the user manually deletes it, the next run is treated as "first run" and skips deltas — that is correct behaviour.
- Do not interpolate. If a stage count fell by 5, do not speculate about why. The heads-up line is for surfacing flagged data, not for diagnosis.
- Routine mode output should be terse. The brief is meant to be glanced at, not read paragraph by paragraph. If the user wants depth, they will follow up with `/pipeline-health-check`.
- First run: render the brief without a `Δ` column and include "First snapshot captured." Do not invent baseline data.
- The skill assumes the user's stage list matches the 7-stage LinkNinja default. If `stages()` returns custom stages, use those names and order — the per-stage row pattern still applies.
- If `pipeline_stats()` returns zero conversations, render "Pipeline empty — nothing to snapshot yet." and skip the baseline write (don't pollute the file with zeros).
- Caps in the routine recipe are deliberate — six tool calls covers `get_context`, `pipeline_stats`, baseline read/write, and one optional `search` for the heads-up. Bigger caps are an antipattern for a snapshot skill.

## Related Skills

- **pipeline-health-check** — Full diagnostic with warning signs and prioritized recommendations. Use when the snapshot reveals a problem worth investigating.
- **stage-conversion-analysis** — Stage-by-stage transcript deep dive. Use when a stage's delta points at a bottleneck and you want to know why.
- **won-deal-analysis** — Pattern detection in closed deals. Use when the `Won` column moves and you want to learn what worked.
- **full-morning-triage** — Daily pipeline processing. Pairs naturally with this snapshot — read the brief, then process the pending replies.
- **reply-rate-analysis** — Opener performance. Use when the `Opening` delta is large but `Chatting` is flat.
