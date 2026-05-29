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
| `daily` | daily | Activity today (chats opened, contacts messaged, back-and-forth) + per-stage deltas + my-turn backlog by age + you-ghosted + heads-up |
| `weekly` | weekly | Daily metrics rolled to 7 days + flow (new chats / replies / calls / closes) + cold rate |
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

**Daily mode** — activity metrics from real message data plus my-turn backlog:

```
search_conversations(my_turn=true, compact=true)
export_conversations(since="<24h ago, ISO>", include_messages=true)
```

From the export, compute the three core activity metrics — what the operator did today:

| Metric | How to count |
|--------|--------------|
| **Chats opened today** | Conversations where the first message timestamp is within the last 24h |
| **Contacts messaged today** | Distinct conversations with at least one outbound message in the last 24h |
| **Back-and-forth conversations** | Conversations with at least one outbound AND one inbound message in the last 24h |
| **Back-and-forth message count** | Total messages (inbound + outbound) across the back-and-forth conversations in the last 24h |

Then bucket the my-turn backlog by age of `last_message_at`:
- `<24h`, `1–3d`, `3–7d`, `7+d` (the 7+d bucket is the embarrassment number)

If `export_conversations` paginates (`has_more: true`), fetch additional pages — daily activity rarely exceeds one page but a busy operator can spill.

**Weekly mode** — same activity metrics rolled to 7 days plus flow approximations:

```
search_conversations(my_turn=true, compact=true)
export_conversations(since="<7 days ago, ISO>", include_messages=true)
```

Activity metrics (same definitions as daily, just with a 7-day window).

Flow metrics (derive from current vs previous baseline):
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

Activity today:
- Chats opened: 3
- Contacts messaged: 17
- Back-and-forth conversations: 9 (47 messages)

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

Activity this week:
- Chats opened: 14
- Contacts messaged: 78
- Back-and-forth conversations: 31 (210 messages)

[Per-stage table with Δ]

Flow this week:
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

Activity this week:
- Chats opened: 14 · Contacts messaged: 78 · Back-and-forth: 31 (210 messages)
- Calls booked: 3 · Closed: W1/L3

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

Pick a cadence — daily / weekly / summary. Each cadence is one scheduled job with its own prompt file and baseline file. The skill body is identical; the schedule changes.

Cron expressions:

| Cadence | Cron | When it fires |
|---------|------|---------------|
| Daily | `0 8 * * *` | 8am every day |
| Weekly | `0 8 * * 1` | 8am every Monday |
| Summary | `0 9 * * 1` | 9am every Monday (after weekly) |

### Shared: prompt file

Each cadence reads the same shape of prompt. Save as `~/.claude/routines/pipeline-<cadence>.prompt.md`:

```
Run the /pipeline-snapshot skill in routine mode for cadence "<daily|weekly|summary>".

Steps:
1. get_context()
2. get_stats()
3. Read ~/.linkninja/state/pipeline-snapshot-<cadence>.json (previous baseline). If missing, first run.
4. Compute per-stage deltas.
5. search_conversations(my_turn=true, compact=true) — bucket the my-turn backlog by age.
6. export_conversations(since="<window>", include_messages=true) — compute chats opened, contacts messaged, back-and-forth.
   Window: 24h for daily, 7 days for weekly and summary.
7. Summary only: compute conversion rates vs Sell By Chat benchmarks + touch count distribution.
8. Write the new snapshot to ~/.linkninja/state/pipeline-snapshot-<cadence>.json.
9. Output ONLY the brief — no preamble, no commentary.

Read-only. Do not change stages, write drafts, or archive.
```

### Option A — macOS launchd (local, verified)

`~/Library/LaunchAgents/com.linkninja.pipeline-daily.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.linkninja.pipeline-daily</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/env</string>
    <string>bash</string>
    <string>-c</string>
    <string>claude -p "$(cat ~/.claude/routines/pipeline-daily.prompt.md)" >> /tmp/pipeline-daily.log 2>&amp;1</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>8</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>StandardOutPath</key><string>/tmp/pipeline-daily.log</string>
  <key>StandardErrorPath</key><string>/tmp/pipeline-daily.err</string>
</dict>
</plist>
```

Load: `launchctl load ~/Library/LaunchAgents/com.linkninja.pipeline-daily.plist`

For weekly / summary, copy the plist with the right label, prompt-file name, and add `<key>Weekday</key><integer>1</integer>` to `StartCalendarInterval` for Monday-only firing.

### Option B — Linux cron (local, verified)

`crontab -e`:

```cron
0 8 * * *   /usr/bin/env bash -c 'claude -p "$(cat ~/.claude/routines/pipeline-daily.prompt.md)" >> /tmp/pipeline-daily.log 2>&1'
0 8 * * 1   /usr/bin/env bash -c 'claude -p "$(cat ~/.claude/routines/pipeline-weekly.prompt.md)" >> /tmp/pipeline-weekly.log 2>&1'
0 9 * * 1   /usr/bin/env bash -c 'claude -p "$(cat ~/.claude/routines/pipeline-summary.prompt.md)" >> /tmp/pipeline-summary.log 2>&1'
```

### Option C — Claude Code's `/schedule` skill

If you're on a Claude plan that includes scheduled routines, the `/schedule` skill registers them inside Claude itself (no OS-level cron needed). Invoke `/schedule` and follow its interview — point it at the prompt file from the shared step above. Check current Claude Code docs for what surface (Claude Desktop, web, etc.) the routine output shows up in for your plan.

## Delivery Options

By default a scheduled routine writes its output to a log file — it does not push to you. Pick a delivery channel and add one line to the routine prompt's final step.

### Notification recipes

Each recipe adds a single shell line to the routine prompt's last step. The skill body stays the same.

**ntfy.sh** — lowest friction, no account, free. Subscribe to a topic in the ntfy iOS/Android app (or web) and the routine pushes to it:

```
curl -d "$(cat /tmp/pipeline-<cadence>.log | tail -n 50)" ntfy.sh/<your-topic>
```

Pick any topic string that's hard to guess (it's the URL — anyone with the topic can read it). Verify the exact current syntax at https://ntfy.sh.

**macOS native notification** (local-only — routine runs via launchd):

```
osascript -e 'display notification "Pipeline brief ready — tail /tmp/pipeline-daily.log" with title "LinkNinja"'
```

Tap the notification to focus Terminal. Note: newer macOS may require granting notification permission to the parent process (Terminal / iTerm / Claude Code) before notifications show.

**Slack incoming webhook** — create the webhook in Slack first (App settings → Incoming Webhooks):

```
curl -X POST -H 'Content-type: application/json' \
  --data "$(jq -Rs '{text: .}' < /tmp/pipeline-<cadence>.log)" \
  <your-webhook-url>
```

**Discord webhook** — same pattern, get the URL from server settings → Integrations → Webhooks:

```
curl -X POST -H 'Content-type: application/json' \
  --data "$(jq -Rs '{content: .}' < /tmp/pipeline-<cadence>.log)" \
  <your-webhook-url>
```

### Passive options (no push, you go look)

| Option | How | When to choose |
|--------|-----|----------------|
| Tail the log | `tail -f /tmp/pipeline-<cadence>.log` | Spot-check from terminal |
| Read the baseline | `cat ~/.linkninja/state/pipeline-snapshot-<cadence>.json` | Latest snapshot on demand without firing the skill |

### Note on Claude Desktop / `/schedule`

If you register the routine via Claude Code's `/schedule` instead of OS-native cron/launchd, whether you get a push notification (badge, OS notification, Claude Desktop banner) depends on your Claude plan and current app behavior. Check current Claude Code docs — don't assume notification just because the routine fires. Adding one of the curl recipes above to the prompt guarantees delivery regardless of where the routine runs.

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
- Activity metrics (chats opened, contacts messaged, back-and-forth) come from real message data via `export_conversations(include_messages=true)`. Exact, not approximated.
- Flow metrics in weekly mode (calls booked, deals closed) are derived from delta math against the previous baseline — directional signal, not exact event counts.
- Daily mode runs `export_conversations` with a 24h window — usually one page, cheap. Weekly uses a 7-day window — may need pagination. Summary uses 7 days + transcript inspection for touch counts.
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
