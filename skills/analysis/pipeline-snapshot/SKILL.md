---
name: pipeline-snapshot
description: >
  At-a-glance pipeline snapshot with Sell By Chat-aligned metrics. Three
  cadences: daily (action focus), weekly (operator throughput), summary (manager
  scorecard with conversion vs playbook benchmarks). Tracks per-stage deltas,
  my-turn backlog by age, follow-up cadence health, and the "abandoned before
  touch 5" Sell By Chat persistence metric. Use when the user says "pipeline
  snapshot", "stage progress", "daily brief", "weekly brief", "weekly summary",
  "operator scorecard", "how is my pipeline this week", "where are we vs
  benchmarks". Designed to be baked into a Routine — see "Bake it into a
  Routine". Read-only — no stage changes, no drafts, no archives. Related:
  pipeline-health-check for deep diagnostic, stage-conversion-analysis for
  stage-by-stage transcript deep dive, cold-rescue for acting on abandoned
  touches, reminder-engine for cadence enforcement.
metadata:
  version: "2.0"
  author: linkninja
---

# Pipeline Snapshot

Pipeline state with Sell By Chat-aligned movement metrics. Four modes — pick the one that matches the cadence you want to be paged on:

| Mode | Cadence | What you get |
|------|---------|--------------|
| Interactive | ad hoc | Current per-stage table, no deltas |
| `daily` | daily | Per-stage deltas + my-turn backlog by age + you-ghosted + heads-up |
| `weekly` | weekly | Daily metrics + flow (new chats / replies / calls / closes) + cold rate |
| `summary` | weekly | Weekly metrics + conversion funnel vs Sell By Chat benchmarks + persistence (touch 5 rule) + touch count distribution |

**This skill does NOT:**
- Diagnose individual conversations (that is `pipeline-health-check`)
- Read transcripts deeply (that is `stage-conversion-analysis`)
- Change stages, draft messages, or archive

## Before Starting

1. Run `get_context()` to load the user's sales context.
2. Detect the mode from the argument: `daily`, `weekly`, `summary`, or none (interactive).
3. Check prerequisites:

| Check | How | If Not Met |
|-------|-----|------------|
| Pipeline has been classified | `get_stats()` — at least one stage has > 0 | "Pipeline is empty. Classify with **full-morning-triage** or `start_batch_classify()` first." |
| Stages defined | `list_stages()` returns user's stage list | Use 7-stage default (opening, chatting, qualified, discovery, closing, won, lost). |
| For `summary` mode | At least 30 classified conversations | "Summary mode needs at least 30 conversations for meaningful benchmark comparison. Use **daily** or **weekly** until you have more data." |

## Sell By Chat Benchmarks (used in `summary` mode)

From the methodology — see `references/sell-by-chat-methodology.md`.

| Transition | LinkNinja stages | Healthy | Half (critical) |
|------------|------------------|---------|-----------------|
| Chats → replies | opening → chatting+ | 30% | 15% |
| Replies → engagement | chatting → qualified+ | 50% | 25% |
| Engagement → calls booked | qualified → discovery+ | 20% | 10% |
| Calls booked → showed up | discovery → closing+ | 80% | 40% |
| Showed up → closed | closing → won | 50% | 25% |
| **Overall** | opening → won | **1%** | **0.5%** |

Status logic per transition:
- `≥ healthy`: **OK**
- `≥ half, < healthy`: **LOW**
- `< half`: **CRITICAL** — this is the leaky stage to fix first

Plus the persistence rule: **80% of sales close after the 5th touchpoint.** Conversations abandoned before touch 5 are potential losses from quitting early.

## Workflow — Interactive Mode

### Step 1: Current snapshot

```
get_stats()
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

Active total excludes won + lost.

### Step 3: One-line heads-up

| Condition | Heads-up |
|-----------|----------|
| Total `my_turn` > 10 | "X conversations waiting on your reply — Sell By Chat: speed wins." |
| Cold in discovery/closing > 0 | "X discovery/closing convos going cold — push through, 80% close after touch 5." |
| You-ghosted > 5 | "X conversations you owe a reply." |
| None of the above | "Nothing flagged. Pipeline looks tended." |

Stop here. No deltas in interactive mode.

## Workflow — Routine Modes (daily / weekly / summary)

### Step 1: Read previous baseline

Path: `~/.linkninja/state/pipeline-snapshot-<mode>.json` where `<mode>` is `daily`, `weekly`, or `summary`.

Read it. If missing, this is the first run — skip delta computation.

Shape:

```json
{
  "captured_at": "2026-05-22T08:00:00+10:00",
  "mode": "weekly",
  "counts": {"opening": 35, "chatting": 18, "qualified": 13, "discovery": 3, "closing": 3, "won": 7, "lost": 11}
}
```

### Step 2: Current snapshot

```
get_stats()
```

Extract per-stage counts.

### Step 3: Compute deltas (per stage)

`delta[stage] = current[stage] - previous[stage]`. First run: deltas skipped.

### Step 4: Mode-specific metric gathering

**Daily mode** — add 1 search for the my-turn backlog by age:

```
search_conversations(my_turn=true, compact=true)
```

Bucket by age of `last_message_at`:
- `<24h`, `1–3d`, `3–7d`, `7+d` (the 7+d bucket is the embarrassment number)

**Weekly mode** — daily metrics PLUS flow approximations:

```
search_conversations(my_turn=true, compact=true)
```

Flow metrics (derive from current vs previous baseline):
- **New chats this week** ≈ `Δ(total pipeline) + Δ(won + lost)` (net new entries)
- **Replies received** ≈ `Δ(chatting + qualified + discovery + closing + won + lost)` (net chats that have at least one reply)
- **Calls booked** ≈ `Δ(discovery) + Δ(closing) + max(0, Δ(won))` (forward movement into discovery+ plus net wins)
- **Deals closed** = `Δ(won)` and `Δ(lost)` reported separately as `W{n}/L{n}`
- **Cold rate (active)** = `cold_in_chatting+qualified+discovery+closing / total_active` × 100

**Summary mode** — weekly metrics PLUS conversion benchmarks + persistence:

```
export_conversations(include_messages=true, since="<7 days ago>")
```

Compute conversion rates from current `get_stats()` cumulative counts (or from flow deltas if first run):

| Rate | Formula |
|------|---------|
| Chats → replies | `(chatting + qualified + discovery + closing + won + lost) / total_ever_opened` |
| Replies → engagement | `(qualified + discovery + closing + won + lost) / (chatting + qualified + discovery + closing + won + lost)` |
| Engagement → calls | `(discovery + closing + won + lost) / (qualified + discovery + closing + won + lost)` |
| Calls → showed | `(closing + won + lost) / (discovery + closing + won + lost)` |
| Showed → closed | `won / (won + lost)` |
| Overall | `won / total_ever_opened` |

Compare each to the Sell By Chat benchmarks table. Flag the **leaky stage** (lowest rate vs benchmark — i.e. furthest below half).

**Touch count distribution** — from the exported transcripts, count outbound messages per conversation:

| Touches | Count | Sell By Chat note |
|---------|-------|-------------------|
| 1 (no reply yet) | — | Awaiting reply |
| 2 | — | First follow-up sent |
| 3 | — | Day 3 follow-up |
| 4 | — | Day 7 follow-up |
| 5+ | — | **Sell By Chat: 80% close after touch 5** |

**Abandoned before touch 5** — count of conversations in `chatting`/`qualified`/`discovery`/`closing` with `< 5` touches AND `last_message_at` over 14 days ago (likely abandoned by operator). These are recoverable — surface them.

### Step 5: Persist the new baseline

Use the Write tool to overwrite `~/.linkninja/state/pipeline-snapshot-<mode>.json` with the current snapshot.

If `get_stats()` returns zero conversations, skip the write — don't pollute the baseline with zeros.

### Step 6: Render the brief (mode-specific)

#### Daily brief

```
Pipeline brief — daily, <today> (vs <previous date>)

| Stage | Now | Δ |
|-------|-----|---|
| Opening | 47 | +5 |
| Chatting | 23 | +2 |
| Qualified | 11 | 0 |
| Discovery | 4 | +1 |
| Closing | 3 | 0 |
| Won | 8 | 0 |
| Lost | 14 | +1 |

My-turn backlog: 17 total
  <24h: 6 · 1–3d: 6 · 3–7d: 4 · 7+d: 1 ⚠

You-ghosted: 8 · Cold in discovery/closing: 2

Heads up: 1 conversation awaiting reply 7+ days — Sell By Chat: speed wins.
```

#### Weekly brief

```
Pipeline brief — week ending <today> (vs <previous date>)

[Per-stage table with Δ]

Flow this week:
- New chats: 14 (approx)
- Replies received: 9
- Calls booked: 3
- Deals closed: W1 / L3

Operator state:
- My-turn backlog: 17 (1 over 7 days)
- You-ghosted: 8
- Cold rate (active stages): 18%

Heads up: <one-line per heads-up table>
```

#### Summary brief (weekly summary — manager scorecard)

```
Weekly summary — week ending <today>

[Per-stage table with Δ]

Flow:
- New chats: 14 · Replies: 9 · Calls booked: 3 · Closed: W1/L3

Conversion vs Sell By Chat benchmarks:
| Transition | Rate | Benchmark | Status |
|------------|------|-----------|--------|
| Chats → replies | 23% | 30% | LOW |
| Replies → engagement | 47% | 50% | OK |
| Engagement → calls | 18% | 20% | OK |
| Calls → showed | 33% | 80% | CRITICAL |
| Showed → closed | 33% | 50% | LOW |
| Overall | 0.8% | 1% | LOW |

Leaky stage: Calls → showed at 33% (benchmark 80%). Investigate with /stage-conversion-analysis.

Persistence (Sell By Chat: 80% close after touch 5):
- Chats active past touch 5: 11
- Chats abandoned before touch 5: 8 ← recoverable, run /cold-rescue

Touch count distribution:
| Touches | Count |
|---------|-------|
| 1 (no reply) | 47 |
| 2 | 18 |
| 3 | 7 |
| 4 | 4 |
| 5+ | 11 |

Operator state:
- My-turn backlog: 17 (1 over 7 days)
- You-ghosted: 8
- Cold rate (active stages): 18%

Heads up: <one-line>
```

**Delta formatting:** `+N` positive, `−N` (en-dash) negative, `0` no change.

**First run:** omit Δ column, append "First <mode> snapshot captured. Next run will show deltas."

Stop after rendering.

## Bake it into a Routine

Pick a cadence — daily / weekly / summary. Each gets its own routine + baseline file. They are independent.

### Anthropic Routines (cloud)

```bash
# Daily — 8am every day
claude schedule create \
  --name "pipeline-daily" \
  --cron "0 8 * * *" \
  --timezone "Australia/Sydney" \
  --prompt-file ~/.claude/routines/pipeline-daily.prompt.md \
  --allowed-tools "get_context,get_stats,search_conversations,Read,Write"

# Weekly — Monday 8am
claude schedule create \
  --name "pipeline-weekly" \
  --cron "0 8 * * 1" \
  --timezone "Australia/Sydney" \
  --prompt-file ~/.claude/routines/pipeline-weekly.prompt.md \
  --allowed-tools "get_context,get_stats,search_conversations,Read,Write"

# Summary — Monday 9am (after weekly brief)
claude schedule create \
  --name "pipeline-summary" \
  --cron "0 9 * * 1" \
  --timezone "Australia/Sydney" \
  --prompt-file ~/.claude/routines/pipeline-summary.prompt.md \
  --allowed-tools "get_context,get_stats,search_conversations,export_conversations,Read,Write"
```

Prompt files (one per cadence). Daily example at `~/.claude/routines/pipeline-daily.prompt.md`:

```
Run the /pipeline-snapshot skill in routine mode for cadence "daily".

Steps:
1. get_context()
2. get_stats()
3. Read ~/.linkninja/state/pipeline-snapshot-daily.json (previous baseline). If missing, first run.
4. Compute per-stage deltas.
5. search_conversations(my_turn=true, compact=true) — bucket by age.
6. Write the new snapshot to ~/.linkninja/state/pipeline-snapshot-daily.json.
7. Output ONLY the daily brief — no preamble, no commentary.

Read-only. Do not change stages, write drafts, or archive.
```

Weekly: swap the cadence to `weekly` and add the flow-metrics steps from Step 4. Summary: add `export_conversations(include_messages=true, since="<7 days ago>")` for touch counts + conversion benchmarks.

### Routine specs (universal)

```yaml
# Daily
routine:
  slug: pipeline-daily
  schedule: "0 8 * * *"
  prompt_file: ~/.claude/routines/pipeline-daily.prompt.md
  allowed_tools: [get_context, get_stats, search_conversations, Read, Write]
  caps: { max_tool_calls_per_run: 6, max_drafts_per_run: 0, max_runs_per_day: 2 }

# Weekly
routine:
  slug: pipeline-weekly
  schedule: "0 8 * * 1"
  prompt_file: ~/.claude/routines/pipeline-weekly.prompt.md
  allowed_tools: [get_context, get_stats, search_conversations, Read, Write]
  caps: { max_tool_calls_per_run: 8, max_drafts_per_run: 0, max_runs_per_day: 1 }

# Summary (heaviest — uses export_conversations)
routine:
  slug: pipeline-summary
  schedule: "0 9 * * 1"
  prompt_file: ~/.claude/routines/pipeline-summary.prompt.md
  allowed_tools: [get_context, get_stats, search_conversations, export_conversations, Read, Write]
  caps: { max_tool_calls_per_run: 12, max_drafts_per_run: 0, max_runs_per_day: 1 }
```

## Delivery Options

Routines write the brief to a log — they do not push it. To get it delivered:

| Option | How | When to choose |
|--------|-----|----------------|
| Wrap in a Monitor | `/monitor-architect` — same skill body, Monitor adds Telegram / email / push | You want it pushed to a channel |
| Tail the log | `tail -f /tmp/pipeline-<mode>.log` | Spot-check, not paged |
| Read the baseline | `cat ~/.linkninja/state/pipeline-snapshot-<mode>.json` | Latest snapshot on demand |

## Arguments

| Arg | Mode | Baseline file |
|-----|------|---------------|
| `daily` | Daily routine | `pipeline-snapshot-daily.json` |
| `weekly` | Weekly routine | `pipeline-snapshot-weekly.json` |
| `summary` | Weekly summary | `pipeline-snapshot-summary.json` |
| (none) | Interactive | (no file) |

## Guidelines

- Read-only. Never change a stage, draft, or archive from this skill.
- Each cadence has its own baseline. Don't cross-read (daily reads daily.json, etc.).
- First run for any cadence: render without Δ, mark "First snapshot captured."
- Flow metrics are approximations from delta math, not exact creation counts — the `since` filter on `search_conversations` is activity-based, not creation-based. Acceptable for directional signal.
- Summary mode uses `export_conversations(include_messages=true)` — expensive. Don't run it at daily cadence.
- Conversion rates in summary mode are cumulative-pipeline-based, not period-based. They drift toward the long-term rate as the pipeline matures.
- Benchmarks come from the Sell By Chat playbook (`references/sell-by-chat-methodology.md`). Status thresholds: ≥ benchmark = OK, ≥ half = LOW, < half = CRITICAL.
- The "abandoned before touch 5" metric is the Sell By Chat signal that matters most for persistence — surface it prominently in summary mode.
- Touch count = outbound messages per conversation. Derived from exported transcripts.
- If the pipeline returns zero conversations, render "Pipeline empty — nothing to snapshot." and skip baseline write.
- Heads-up lines should reference the playbook when relevant — "Sell By Chat: speed wins" / "80% close after touch 5" / "push through." Don't generic-ize.

## Related Skills

- **pipeline-health-check** — Full diagnostic with warning signs. Use when the snapshot flags a leak.
- **stage-conversion-analysis** — Deep transcript dive on the leaky stage flagged by summary mode.
- **cold-rescue** — Act on "abandoned before touch 5" conversations.
- **reminder-engine** — Enforce the Day 1/3/7/14/30 cadence the playbook prescribes.
- **won-deal-analysis** / **lost-deal-analysis** — Pattern detection on closed deals when the Won or Lost column moves.
- **full-morning-triage** — Daily pipeline processing. Pairs naturally with `daily` mode.
