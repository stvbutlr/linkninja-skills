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

## Context MCPs (Make Skills Smarter)

Skills are pipelines that orchestrate the LinkNinja MCP — read pipeline, draft, run jobs. Context MCPs layered alongside make those pipelines smarter by injecting the right context at the right step in the right process.

The mental model:

- **LinkNinja MCP** = the live pipeline state (who's where, what they said, what stage they're in)
- **Your knowledge base** = your specific customer history, framework refinements, "what worked" learnings
- **Seven Figure Creators MCP** (optional, if you're an SFC member) = the playbook with patterns and case studies that worked across many practitioners
- **Fresh external context** (optional) = web search for prospect news, GitHub for technical buyers, email for cross-channel signal

Each layer adds a kind of context the others can't. Three or four layers chained together is much sharper than any one alone. The wrong frame is "where does the data go" (Slack notifications, Linear tasks, Stripe sync). Those are effectors, not context. The right frame is "what context makes the skill smarter than running cold."

### Your own knowledge base (the highest-leverage layer for most operators)

Whatever you already use to capture customer insights, framework refinements, and "what worked" learnings. Operators store this in different places — and most have a community MCP that lets Claude read the content:

| Where you store context | Notes |
|-------------------------|-------|
| Obsidian | Markdown files in a vault. Several community MCPs exist. |
| Notion | Structured databases. Official MCP available. |
| mem.ai | AI-native notes. |
| Reflect / Roam / Logseq | Networked notes — good for surfacing past similar conversations. |
| Google Drive / Google Docs | Loose docs. Useful via Google MCPs. |
| Apple Notes | Lighter capture. Often via browser automation. |
| Custom CRM-like setup | Whatever you've built — operators with a structured store get the most lift. |

**Skill-specific context wins:**

- `cold-outreach` reading your "past similar prospects" notes → opener that references what's worked before
- `objection-handling` reading your "objections that came up" notes → response shaped by what actually resolved them last time
- `won-deal-analysis` reading past analysis run notes → patterns surface across runs, not just within one
- `icp-definition` reading your existing customer notes → archetype templates refined from real client language

### Seven Figure Creators MCP (if you're an SFC member)

SFC ships an MCP server with the full Sell By Chat playbook plus accumulated DM patterns and case studies queryable as context. Layer it alongside the LinkNinja MCP and your own KB — drafts get the operational live state from LinkNinja, your specific learnings from your KB, and the broader playbook patterns from SFC, all in one chain.

Best for the DM situation skills (`cold-outreach`, `reply-handling`, `objection-handling`, `call-booking`, `cold-rescue`), `batch-drafting`, `sequence-runner`, and the setup arc (`icp-definition` templates, `voice-profile-setup` tendencies). Less directly useful for analysis skills, where your own KB carries more specific signal.

If you're not an SFC member, skip this layer. The other context layers still provide most of the lift.

### Fresh external context

| MCP | Skills it amplifies | What it adds |
|-----|---------------------|--------------|
| Web search (Brave / Perplexity-style) | `cold-outreach`, `lead-research`, `cold-rescue` | Fresh prospect signals — company news, recent press, podcast appearances, conference talks. Beyond what Sales Nav captures. |
| Browser automation (Playwright / Puppeteer MCP) | `lead-research`, `cold-outreach` | Read the prospect's website, blog, or LinkedIn profile UI directly when the API data is sparse or stale. |
| GitHub | `smart-tagging`, `lead-research`, `prospect-scan` | Open-source activity, commits, repos. Especially for technical buyers (founders, CTOs, devtool buyers) — Precision Flattery beyond what Sales Nav surfaces. |
| Crunchbase / Apollo / Clearbit (if/when MCPs available) | `prospect-scan`, `lead-research` | Funding history, hiring signals, tech stack. Augments LinkedIn data. |
| Email (Gmail / Outlook MCP) | `cold-rescue`, `conversation-summarizer` | If a prospect went silent on LinkedIn but you've emailed before, the inbox is context — read past threads to find a re-engagement angle. |

### Narrow effector MCPs (where they genuinely help one specific skill's flow)

Most "integrate with my task system" requests aren't context — they're plumbing. Skip those unless they directly serve a skill's workflow:

| MCP | Skill | When |
|-----|-------|------|
| Calendar (Google / Cal.com) | `call-booking` | When the prospect says yes — pull your availability so the invite proposes specific times. Otherwise generic invites land worse. |

Setup pattern for any of the above: install the MCP, give Claude Code permission, then in the skill's workflow you can chain LinkNinja MCP calls with reads from your context store. The skill's quality goes up in proportion to the quality of context it can read.

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
- **Context read**: skill reads your KB (Obsidian / Notion / wherever) for past-customer notes — drafts reference what's worked before for similar prospects.
- **Pre-tool hook**: each `update_conversation` draft passes through voice-check.sh before saving.
- **You**: open your dashboard at 7:30am, review the drafts, hit send.

### "Weekly pipeline health" routine

- **Sunday 8am cron**: `/pipeline-health-check` runs.
- **Context read**: skill reads your past health-check notes from your KB → comparison surfaces vs. prior weeks naturally, not just one snapshot in isolation.
- **You**: Sunday afternoon, glance at the dashboard, capture the new week's findings back into your KB so next week's run has them, decide what to focus on Monday.

### "Sequence engine" routine

- Tag a cohort with `gr1`.
- Cron schedules touches at Day 1, 3, 7, 14.
- Pre-tool hook validates each draft against voice profile.
- Each touch reads your context store (Obsidian / Notion / wherever) for past similar conversations and what's worked.
- Calendar MCP fills in availability when a touch lands at a call-booking step.
- Sunday review surfaces which touches are converting.

### "Quarterly ICP refinement" routine

- **First Monday of quarter**: `won-deal-analysis` runs (cron, Opus model).
- **First Tuesday of quarter**: `lost-deal-analysis` runs.
- Both READ your context store for past analysis run notes — patterns surface across runs, not just within one.
- You review, decide which ICP refinements to apply via `update_context()`, capture the decision back into your context store for next quarter's run.

---

## Per-Skill Power-Up Cheatsheet

The **Context** column reads as a chain — the LinkNinja MCP is always running underneath; these are the additional context layers worth adding alongside.

- **your KB** = wire this skill into wherever you store your own customer / framework / playbook notes (Obsidian / Notion / mem.ai / Reflect / Roam / Logseq / Google Drive / Apple Notes / your CRM-like setup — pick the one with a community MCP for your system).
- **SFC MCP** = optional layer for SFC members (Sell By Chat playbook patterns + case studies as queryable context). Skip if you're not a member.
- Other entries are specific external context that helps that skill type.

| Skill | Cron | Hook | Subagent | Context | Model |
|-------|:---:|:---:|:---:|:---|:---:|
| onboarding-walkthrough | — | — | — | your KB (existing customer notes), SFC MCP | Opus |
| icp-definition | — | — | archetype-classifier | your KB (past customer language), SFC MCP (archetype examples) | Opus |
| voice-profile-setup | — | — | — | your sent-message archive, SFC MCP (voice patterns) | Opus |
| stage-configuration | — | — | — | SFC MCP (stage criteria patterns) | Opus |
| prospect-scan | — | — | — | GitHub (technical), Crunchbase / Apollo (firmographic), Web search | Sonnet |
| connection-enrichment | weekly re-enrich | — | parallel enrich | — | Sonnet |
| lead-research | — | — | parallel research | your KB, GitHub, Web search | Sonnet |
| campaign-launch | — | voice-check | drafter+reviewer | your KB (past campaigns), SFC MCP (campaign patterns) | Sonnet |
| smart-tagging | — | — | — | your KB, GitHub | Haiku |
| dm-writing (router) | — | — | — | — | Haiku |
| cold-outreach | — | voice-check | — | your KB (past similar prospects), SFC MCP (opener patterns), Web search (fresh signals) | Sonnet |
| reply-handling | — | voice-check | qualifier | your KB, SFC MCP (qualifying patterns) | Sonnet |
| objection-handling | — | voice-check | objection-resolver | your KB (past resolved objections), SFC MCP (objection responses) | Sonnet |
| call-booking | — | voice-check | — | SFC MCP (call-booking patterns), Calendar | Sonnet |
| batch-drafting | — | voice-check, Stop notify | drafter+reviewer | your KB, SFC MCP | Sonnet |
| sequence-runner | scheduled touches | voice-check | drafter+reviewer | your KB, SFC MCP (sequence patterns), Calendar (call-booking touches) | Sonnet |
| cold-rescue | weekly | voice-check | — | your KB, SFC MCP (re-engagement patterns), Email (cross-channel) | Sonnet |
| template-library | — | — | — | your KB, SFC MCP (template library examples) | Sonnet |
| full-morning-triage | daily 7am | voice-check, Stop notify | mixed | your KB, SFC MCP | Sonnet |
| pipeline-cleanup | weekly Mon | — | — | — | Haiku |
| stage-review | — | — | — | — | Sonnet |
| conversation-summarizer | weekly Wed | — | — | your KB (sync summaries to your notes) | Sonnet |
| reminder-engine | daily overdue | — | — | — | Sonnet |
| pipeline-health-check | weekly Sun | — | — | your KB (compare past health snapshots) | Opus |
| reply-rate-analysis | — | — | — | your KB | Opus |
| stage-conversion-analysis | — | — | — | your KB | Opus |
| won-deal-analysis | monthly first-Mon | — | — | your KB (insight database) | Opus |
| lost-deal-analysis | monthly first-Tue | — | — | your KB (loss-pattern database) | Opus |

---

## Getting Started Path

1. **Pick one routine that solves an actual problem you have.** Most operators start with the daily sales operator.
2. **Get one piece of it working.** Just the cron, nothing else. Run it for 3 days and see what breaks.
3. **Add the hooks once the cron is stable.** Voice-check first; it prevents the most common quality issue.
4. **Wire in your context store before any other MCP.** The biggest single quality lift comes from skills being able to read your existing customer notes / framework refinements / "what worked" learnings. Notification MCPs can wait.
5. **Tune model config last.** Default Sonnet is fine for everything; only optimise once you have actual cost/quality data.

The trap to avoid: setting up all of this on day 1, having nothing actually work, and concluding "the skills don't work." The skills work. The automation layer is what compounds them. Build it slowly.
