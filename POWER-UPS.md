# Power-Ups

Optional Claude Code config that turns these skills from interactive helpers into a fully automated sales operations layer. Pick what serves you. Don't try to set up everything at once — each layer's value depends on the layers above it actually working.

> **Rule of thumb.** Pick one power-up that solves an actual problem you have today. Run it for a week. Then add the next one.

---

## Run Skills on a Schedule

Claude Code's `/schedule` and `/loop` slash commands fire skills automatically. Use them when a routine should happen whether or not you remember to run it.

### Daily

| When | What | Why |
|------|------|-----|
| 7am local | `/schedule daily 7am /full-morning-triage` | Drafts and triage queued before you sit down. You walk into reviewable drafts, not a backlog. |
| 6pm local | `/schedule daily 6pm reminder-engine "what's overdue"` | End-of-day audit catches conversations slipping through. |

### Weekly

| When | What | Why |
|------|------|-----|
| Monday 9am | `/schedule weekly Monday 9am pipeline-cleanup` | Hygiene pass on the week-prior debris. |
| Wednesday 2pm | `/schedule weekly Wednesday 2pm conversation-summarizer "refresh stale summaries"` | Keeps notes current; mid-week so analysis at week's end has fresh data. |
| Friday 4pm | `/schedule weekly Friday 4pm cold-rescue` | Friday afternoon re-engagement push — DMs feel less salesy heading into the weekend. |
| Sunday 8am | `/schedule weekly Sunday 8am pipeline-health-check` | Week-in-review snapshot before Monday plans. |

### Monthly

| When | What | Why |
|------|------|-----|
| First Monday | `/schedule monthly first-Monday won-deal-analysis` | Refine ICP from real wins; feed back into context. |
| First Tuesday | `/schedule monthly first-Tuesday lost-deal-analysis` | Find systemic loss patterns before they become habits. |

### Sequenced (multi-touch outreach over time)

After kicking off a `sequence-runner` cohort tagged `gr1`, schedule the touches:

```
/schedule once "in 2 days at 10am" sequence-runner "GR2 touch for gr1 cohort"
/schedule once "in 6 days at 10am" sequence-runner "GR3 touch for gr2 cohort"
/schedule once "in 13 days at 10am" sequence-runner "GR4 touch for gr3 cohort"
```

Each touch advances the cohort tag (`gr1` → `gr2` → `gr3` → `gr4`) so subsequent runs find the right contacts automatically.

### `/loop` for poll-and-act patterns

```
/loop 30m sequence-runner "check for any active jobs and resume"
```

Runs every 30 minutes, picks up jobs that paused mid-flight (e.g., long-running enrichment).

---

## Hooks for Workflow Automation

Claude Code hooks (configured in `.claude/settings.json` or `~/.claude/settings.json`) fire on agent events. Use them to enforce policy, validate output, or notify on completion.

### Voice-validation pre-tool hook

Before drafts go to `update_conversation`, intercept and validate against your `voice_profile`'s anti-vocabulary. Reject if a banned phrase slips in.

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "match": { "tool_name": "mcp__claude_ai_LinkNinja__update_conversation" },
        "command": "scripts/voice-check.sh"
      },
      {
        "match": { "tool_name": "mcp__claude_ai_LinkNinja__submit_job_results" },
        "command": "scripts/voice-check.sh"
      }
    ]
  }
}
```

`scripts/voice-check.sh` reads the tool args, scans `draft_message` for `crushing it` / `game-changer` / `unlock` / `scale` / `hop on a quick call` / `I'd love to connect`, and exits non-zero if any are found. Claude sees the rejection and re-drafts.

### Stop hook: notify when a batch completes

Ping yourself when `start_batch_draft` finishes a cohort — useful when you've kicked off a 100-contact draft job and want to know when to review.

```jsonc
{
  "hooks": {
    "Stop": [
      { "command": "scripts/notify-batch-done.sh" }
    ]
  }
}
```

Implement `notify-batch-done.sh` to post to Slack / send a macOS notification / email — your choice.

### Quality gate: every classification has reasoning

Before stage-changing `bulk_update` calls go through, validate the AI's reasoning is captured in `ai_notes`. Catches lazy classifications.

### Per-stop summary post

Combine with the **Slack MCP** (below) to post a daily summary of your morning triage to a `#linkedin-pipeline` channel.

---

## Run Claude Code Programmatically (SDK)

The Claude Agent SDK lets you fire skills from code — CI/CD, scheduled jobs, Lambda, Workers. Common patterns:

### GitHub Action: scheduled morning triage

```yaml
# .github/workflows/morning-triage.yml
name: Morning Triage
on:
  schedule:
    - cron: '0 21 * * *'  # 7am AEST = 9pm UTC the day before
  workflow_dispatch:
jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npx @anthropic-ai/claude-agent-sdk run --skill full-morning-triage
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          LINKNINJA_API_KEY: ${{ secrets.LINKNINJA_API_KEY }}
```

### Cloudflare Worker: hourly sequence advancement

For users in moving time zones — running `sequence-runner` from a worker keeps the cadence true regardless of your local time.

### Self-hosted cron

Plain old `cron` on a server you control:

```
# Crontab
0 7 * * *   /usr/local/bin/claude-agent run --skill full-morning-triage
0 9 * * 1   /usr/local/bin/claude-agent run --skill pipeline-cleanup
0 8 * * 0   /usr/local/bin/claude-agent run --skill pipeline-health-check
```

The settings.json + skills tree on the server determines what's available.

---

## Subagents, Agents & Teams

For batch operations, spawn subagents to parallelise. For complex per-conversation logic, use specialist subagents. For review workflows, layer agents.

### Drafter + Reviewer pattern

Ideal for `batch-drafting` when each draft needs human-quality review. **Drafter subagent** generates the draft; **reviewer subagent** checks against voice + framework + ICP fit before saving. Catches more issues than a single-pass draft.

```
Main thread:
  start_batch_draft(filter, ...) → for each chunk:
    Spawn 2 subagents:
      drafter:  reads chunk item, generates draft following draft_prompt
      reviewer: receives drafter's output, validates against voice_profile
                + framework labels + positioning_context fit; returns approved or rejected
    On approved → submit_job_results(applied)
    On rejected → re-draft with reviewer's feedback (max 2 retries)
```

### Parallel research agents

For `lead-research` on a 100-contact cohort, spawn 5 research subagents in parallel — each handles 20 contacts. Cuts wall-clock time ~5×. Each agent's brief saves to `ai_notes`; main thread aggregates the report.

### Specialist subagents per situation

Train (or just brief) specialist subagents for repeated complex situations:

- **objection-resolver** — fed past objection-resolution exchanges that worked specifically for your prospects. Better at handling YOUR objections than a generalist.
- **qualifier** — runs A–B Method analysis on every reply, surfaces the gap before you draft.
- **archetype-classifier** — reads new connections and classifies them against your archetypes before they enter the pipeline.

### Team patterns

Stack the patterns: a "morning operator" team that runs at 7am — a triage agent finds the work, a drafter handles drafts, a reviewer validates, a notifier reports back. End-to-end automation with checkpoints.

---

## Additional MCPs That Complement LinkNinja

Layer these in for a more complete sales-ops stack:

| MCP | Skills it amplifies | Use case |
|-----|---------------------|----------|
| Google Calendar / Cal.com | `call-booking`, `sequence-runner` | When prospect agrees to a call, auto-create the event with their thread context preloaded into the description. |
| Gmail / Outlook | `cold-rescue`, `conversation-summarizer` | Cross-channel follow-up when LinkedIn has gone silent — same context, different inbox. |
| Slack / Discord | `full-morning-triage`, `sequence-runner`, `pipeline-health-check` | End-of-day digest of pipeline state pings to a channel; team visibility. |
| Notion / Obsidian | `won-deal-analysis`, `lost-deal-analysis`, `pipeline-health-check` | Capture insights from analysis runs into your knowledge base; surface patterns across runs over time. |
| GitHub | `smart-tagging`, `lead-research` | If your ICP includes technical buyers (founders, CTOs, dev-tools), pull their open-source activity to deepen Precision Flattery. |
| Linear / Asana / Jira | `reminder-engine`, `sequence-runner` | Sync reminders from LinkNinja into your task system; close the loop on follow-up commitments. |
| Stripe / billing MCP | `won-deal-analysis` | Tie won deals to actual revenue, not just stage flips. |
| Browser automation (Playwright / Puppeteer MCP) | Any | If you want to trigger LinkedIn UI actions LinkNinja doesn't expose, layer browser automation. |

Setup pattern: install the MCP, give Claude Code permission, then in the skill's workflow you can chain LinkNinja MCP calls with the new MCP's calls.

---

## Model Config Per Skill

Different skills benefit from different models. Set in `.claude/settings.json` (project) or `~/.claude/settings.json` (user) — or override per-skill programmatically via the SDK.

| Skill category | Recommended model | Reason |
|----------------|-------------------|--------|
| Drafting (cold-outreach, reply-handling, objection-handling, call-booking, batch-drafting, sequence-runner, cold-rescue) | **Sonnet 4.6+** | Best balance of quality + speed for prose. Voice nuance matters; speed matters at scale. |
| Classification at scale (`start_batch_classify` jobs in pipeline-cleanup, full-morning-triage Phase 5, stage-review server-side mode) | **Haiku 4.5** | High volume, structured output, lower quality bar than drafting. Cost matters. |
| Analysis / pattern detection (won-deal-analysis, lost-deal-analysis, pipeline-health-check, stage-conversion-analysis, reply-rate-analysis) | **Opus 4.7** | Pattern detection across many conversations benefits from frontier reasoning. Worth the cost on a monthly cadence. |
| Setup / one-time deep work (icp-definition, voice-profile-setup, stage-configuration, onboarding-walkthrough) | **Opus 4.7** | One-shot work; quality matters more than speed; the foundations cascade into everything else. |
| Routing / dispatch (dm-writing) | **Haiku 4.5** | Fast classify-and-dispatch; the actual draft work happens downstream where Sonnet kicks in. |
| Triage compound (full-morning-triage, pipeline-cleanup) | **Sonnet 4.6+** | Mixed work — routing + drafting + decisions; Sonnet handles the variety best. |

Per-skill override pattern in `.claude/settings.json`:

```jsonc
{
  "skills": {
    "won-deal-analysis":  { "model": "claude-opus-4-7" },
    "lost-deal-analysis": { "model": "claude-opus-4-7" },
    "pipeline-cleanup":   { "model": "claude-haiku-4-5" }
  }
}
```

---

## Operational Routines (Combine Everything)

Stack scheduling + hooks + skills + MCPs into full routines.

### "Daily sales operator" routine

- **7am cron**: `/full-morning-triage` runs unattended.
- **Pre-tool hook**: each `update_conversation` draft passes through voice-check.sh before saving.
- **Stop hook**: when triage finishes, post a Slack summary to `#linkedin-pipeline` with `N drafts ready for review`.
- **You**: open your dashboard at 7:30am, review the drafts, hit send.

### "Weekly pipeline health" routine

- **Sunday 8am cron**: `/pipeline-health-check` runs.
- **Stop hook**: results pushed to a Notion database with comparison vs. last week's snapshot.
- **You**: Sunday afternoon, glance at the dashboard, decide what to focus on Monday.

### "Sequence engine" routine

- Tag a cohort with `gr1`.
- Cron schedules touches at Day 1, 3, 7, 14.
- Pre-tool hook validates each draft against voice profile.
- Calendar MCP creates events for any contacts who book a call.
- Sunday review surfaces which touches are converting.

### "Quarterly ICP refinement" routine

- **First Monday of quarter**: `won-deal-analysis` runs (cron, Opus model).
- **First Tuesday of quarter**: `lost-deal-analysis` runs.
- Both push insights to Notion via the Notion MCP.
- You manually review insights and decide which ICP refinements to apply via `update_context()`.

---

## Per-Skill Power-Up Cheatsheet

| Skill | Cron | Hook | Subagent | MCP | Model |
|-------|:---:|:---:|:---:|:---:|:---:|
| onboarding-walkthrough | — | — | — | — | Opus |
| icp-definition | — | — | archetype-classifier | — | Opus |
| voice-profile-setup | — | — | — | — | Opus |
| stage-configuration | — | — | — | — | Opus |
| prospect-scan | — | — | — | GitHub (technical buyers) | Sonnet |
| connection-enrichment | weekly re-enrich | — | parallel enrich | — | Sonnet |
| lead-research | — | — | parallel research | GitHub | Sonnet |
| campaign-launch | — | voice-check | drafter+reviewer | Calendar | Sonnet |
| smart-tagging | — | — | — | GitHub | Haiku |
| dm-writing (router) | — | — | — | — | Haiku |
| cold-outreach | — | voice-check | — | Calendar (post-event) | Sonnet |
| reply-handling | — | voice-check | qualifier | — | Sonnet |
| objection-handling | — | voice-check | objection-resolver | — | Sonnet |
| call-booking | — | voice-check | — | Calendar | Sonnet |
| batch-drafting | — | voice-check, Stop notify | drafter+reviewer | Slack | Sonnet |
| sequence-runner | scheduled touches | voice-check | drafter+reviewer | Calendar, Linear | Sonnet |
| cold-rescue | weekly | voice-check | — | Gmail | Sonnet |
| template-library | — | — | — | — | Sonnet |
| full-morning-triage | daily 7am | voice-check, Stop notify | mixed | Slack | Sonnet |
| pipeline-cleanup | weekly Mon | — | — | — | Haiku |
| stage-review | — | — | — | — | Sonnet |
| conversation-summarizer | weekly Wed | — | — | Notion | Sonnet |
| reminder-engine | daily overdue | — | — | Linear / Calendar | Sonnet |
| pipeline-health-check | weekly Sun | Stop → Notion | — | Notion, Slack | Opus |
| reply-rate-analysis | — | — | — | Notion | Opus |
| stage-conversion-analysis | — | — | — | Notion | Opus |
| won-deal-analysis | monthly first-Mon | Stop → Notion | — | Notion, Stripe | Opus |
| lost-deal-analysis | monthly first-Tue | Stop → Notion | — | Notion | Opus |

---

## Getting Started Path

1. **Pick one routine that solves an actual problem you have.** Most operators start with the daily sales operator.
2. **Get one piece of it working.** Just the cron, nothing else. Run it for 3 days and see what breaks.
3. **Add the hooks once the cron is stable.** Voice-check first; it prevents the most common quality issue.
4. **Add MCPs as integration needs become real.** Don't pre-emptively wire up Notion if you're not actually using it.
5. **Tune model config last.** Default Sonnet is fine for everything; only optimise once you have actual cost/quality data.

The trap to avoid: setting up all of this on day 1, having nothing actually work, and concluding "the skills don't work." The skills work. The automation layer is what compounds them. Build it slowly.
