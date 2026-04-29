---
name: sequence-runner
description: >
  Drive a multi-touch outbound sequence on a filtered cohort using start_batch_draft
  with a chosen template per touch. Default cadence follows the playbook's Day 1 / 3 /
  7 / extending intervals (paired with bulk_update reminders). Use when the user says
  "run a sequence", "start a sequence for [cohort]", "drip sequence", "multi-touch
  outreach", "execute the GR sequence", "Day 3 of my sequence", "advance everyone in
  [tag]", or names a numbered touch like "send the Day 7 follow-up". Composes
  template-library + batch-drafting + bulk_update reminders. Related: template-library
  for managing the template chain, batch-drafting for the underlying chunked flow,
  campaign-launch for one-time campaigns, reminder-engine for cadence specifics.
metadata:
  version: "1.0"
  author: linkninja
---

# Sequence Runner

Run a sequenced multi-touch outreach program over time. Each touch uses a different template (e.g., GR1 → GR2 → GR3) drafted via `start_batch_draft`, with reminders set for the next touch. Default cadence follows the playbook: Day 1 / 3 / 7 / extending — *80% of sales close after the 5th touchpoint*.

## Before Starting

1. Run `get_context()` to load the user's sales context and `ai_execution.job_protocols`.
2. Confirm three things with the user before kicking off:

| Element | Question |
|---------|----------|
| Cohort | Which contacts? (filter by tag, stage, freshness, headline keywords) |
| Sequence | Which template chain? (e.g., GR1 → GR2 → GR3) |
| Touch | Which touch is *this*? (Day 1 / 3 / 7 / 14 / 30) |

3. Check `list_templates()` to verify the template chain exists and the linkages (`tag_key` + `advance_tag_to`) are configured. If templates aren't set up, hand off to **template-library**.

4. Check `enrich_connections` quota if the cohort is unenriched and you intend to use Precision Flattery — see **connection-enrichment**. *Sales Navigator required for enrichment*; without it, sequences run on headline-only personalisation.

## The Sequence Cadence

The playbook flat cadence (from `references/sell-by-chat-methodology.md`):

| Touch # | Day | Reply intent | Template Category Hint |
|---------|-----|--------------|------------------------|
| 1 | Day 1 | `nurture` | `opening` (Three Opening Rules + Precision Flattery) |
| 2 | Day 3 | `nurture` | `follow_up` or `value_add` (insight, observation, question) |
| 3 | Day 7 | `qualify` | `follow_up` (different angle — A–B Method) |
| 4 | Day 14 | `qualify` | `value_add` (Preloaded Value) |
| 5 | Day 30 | `advance` | `closing` (Micro-commitments — call invite) |
| 6+ | Day 60, 90 | `nurture` | Long-tail nurture, only when new value to share |

Each touch must add new value. If you have nothing new to say, **skip and extend** — empty pings destroy trust faster than silence.

## Workflow Per Touch

### Step 1: Identify the Cohort For This Touch

Different cohort logic per touch:

- **Touch 1 (kick-off):** the full target list. Tag them with the start tag (e.g., `gr1`) before drafting.
- **Touches 2+:** contacts at the previous touch's tag (e.g., `gr2` for the Day 3 touch). The previous send advanced them via `advance_tag_to`.

```
search_conversations(tags: ["gr2"], my_turn: false, compact: true)
```

`my_turn: false` because we're following up (we sent last; they haven't replied yet).

### Step 2: Optional — Enrich the Cohort

For touches that benefit from fresh context (especially Day 7+ where you need a new angle), enrich first:

```
enrich_connections(
  filter: {tags: ["gr2"], is_enriched: false},
  re_enrich_after_days: 30,
  limit: 100
)
```

Wait for completion. See **connection-enrichment**.

### Step 3: Find the Template

```
list_templates(tag: "gr2")
```

Confirm with the user which template ID to use, draft mode, and reply intent.

### Step 4: Run the Draft Job

```
start_batch_draft(
  filter: {tags: ["gr2"], my_turn: false},
  template_id: <id_of_GR2_template>,
  draft_mode: "guided",
  reply_intent: "nurture"
)
```

Then loop the chunked flow per **batch-drafting**:

```
get_job_status → get_job_chunk → AI drafts each item → submit_job_results(claim_next: true) → repeat → get_job_results
```

Operational rules from the live `ai_execution.job_protocols.draft_reply` block:

- Don't stop after start. Continue calling tools in the same turn.
- No user response between chunks.
- `reply_mode` per item is required (`reply` or `follow_up` — for outbound sequences, almost always `follow_up`).

### Step 5: Set Reminders for the Next Touch

After the user sends the drafts (the contact's tag will advance per `advance_tag_to`), set reminders for the next touch:

```
bulk_update(
  filter: {tags: ["gr3"]},
  reminder: "in 4 days"
)
```

The interval (`in 4 days`) is whatever brings the next touch to the right Day relative to the current touch.

### Step 6: Report

> **Sequence touch complete.**
>
> - **Touch:** Day 3 (template: GR2 — Day 3 Value-Add)
> - **Cohort size:** 47 contacts at tag `gr2`
> - **Drafts ready:** 47 (1 marked failed — insufficient context)
> - **Next touch:** Day 7 (GR3) — reminders set for 4 days from now
>
> **Hottest draft:** [name] — [why]
>
> **Next step:** Open your dashboard, review the GR2 drafts, hit send. The Day 7 sequence will surface in your reminders.

## Sequence Setup Patterns

### Pattern A: Outbound Sequence on Untouched Connections

The classic 4-touch sequence on a fresh cohort:

1. **Pre-step:** scan + tag the cohort
   ```
   scan_connections(headline_keywords: [...], has_conversation: false)
   tag_connections(filter: {...}, add_tags: ["gr1", "campaign-q1"])
   ```
2. **Touch 1 (Day 1):** GR1 opening template (`reply_intent: nurture`)
3. **Touch 2 (Day 3):** GR2 value-add template
4. **Touch 3 (Day 7):** GR3 different-angle template
5. **Touch 4 (Day 14):** GR4 door-open template

Each touch uses **sequence-runner** with the appropriate template. Reminders chain forward.

### Pattern B: Re-Engagement Sequence on a Stalled Cohort

For conversations that went cold mid-pipeline:

```
search_conversations(freshness: "cold", my_turn: true, stage: "qualified")
→ tag with re-engagement sequence start tag
start_batch_draft(filter: {tags: ["reengage_1"]}, template_id: <re-engagement template>, reply_intent: "nurture")
```

Then continue with sequence touches paced by Day 1/3/7/14.

### Pattern C: Sequence Pause

User: "Pause the GR sequence — don't run touches this week."

```
bulk_update(
  filter: {tags: ["gr1", "gr2", "gr3", "gr4"]},
  reminder: "clear"
)
```

Reminders cleared. Restart later by manually re-tagging or re-running the next touch.

## Reading the Sequence State

To see where contacts are in the sequence:

```
search_conversations(tags: ["gr1"], compact: true)
search_conversations(tags: ["gr2"], compact: true)
search_conversations(tags: ["gr3"], compact: true)
search_conversations(tags: ["gr4"], compact: true)
search_conversations(tags: ["gr_dormant"], compact: true)
```

Or read `list_tags()` for the full counts.

| Tag distribution | Diagnosis |
|------------------|-----------|
| Most contacts at `gr1` | Sequence not progressing — kick off Day 3 |
| Stuck at `gr3` | Day 7 angle isn't landing — review the GR3 template's `agent_guidance` |
| Long tail at `gr_dormant` | Cadence exhausted with no engagement — hand to **cold-rescue** for re-engagement attempts with new value |

## Job Lifecycle (Cancel & Resume)

Sequence touches use `start_batch_draft` jobs — same recovery primitives as **batch-drafting**:

- **Cancel mid-flight:** `cancel_job(job_id="<job_id>")` — useful if the wrong template was attached to a batch and you spotted it before submission completes.
- **Resume:** if the user says *"continue"*, *"resume"*, *"keep going"* (typical mid-touch interruption) — call `continue_active_job()` first. Never start a fresh `start_batch_draft` while a job is active for this user.

## Guidelines

- **Never run two touches on the same contact in the same day** — the template chain is sequential.
- **Each touch must add new value.** If the GR3 template doesn't say something genuinely new vs. GR2, the cadence loses its edge.
- **Pair sequence kick-off with `enrich_connections`** when Precision Flattery matters — without enrichment, openers fall back to headline-only.
- **Don't accelerate the cadence** to "catch up" if a touch is delayed. The Day intervals are doing real psychological work.
- **The user sends the drafts** — sequence-runner saves drafts only. Until the user actually sends, the sequence hasn't progressed for that contact.
- **80% of sales close after touch 5.** Don't quit at 4. The Day 30 (`closing` category) touch is where most operators give up — and where the playbook's edge actually shows up.
- **Set the reply intent to match the touch:** nurture for early relationship-building, qualify for mid-funnel A–B Method work, advance for the call-booking close.
- **Templates are captured at job creation.** If you edit a template mid-job, the active job uses the *original* template content. New jobs use the updated version.

## Related Skills

- **template-library** — Manage the template chain (CRUD operations)
- **batch-drafting** — The underlying chunked drafting flow
- **campaign-launch** — One-time outbound campaign (a sequence-runner is more durable, ongoing)
- **cold-rescue** — Re-engage contacts that exhausted the sequence with no engagement
- **reminder-engine** — Detailed reminder cadence patterns
- **connection-enrichment** — Pull fresh `recent_posts` before each touch for new hooks
- **prospect-scan** — Build the initial cohort before kicking off the sequence
- **dm-writing** — Per-conversation drafting when a contact replies mid-sequence (sequence-runner is for the sends; dm-writing is for the responses)
