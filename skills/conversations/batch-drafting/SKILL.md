---
name: batch-drafting
description: >
  Draft personalised messages for many conversations at once using the server-orchestrated
  chunked drafting flow (start_batch_draft). The AI does the drafting per chunk; the
  server tracks state and saves the saved payload at the end. Use when the user says
  "draft messages for", "batch draft", "draft follow-ups for everyone", "process my
  pipeline", "draft for all my qualified leads", "write messages for my cold
  conversations", or "draft campaign follow-ups". Falls back to individual
  get_draft_prompt + update_conversation for ≤5 conversations. Related: dm-writing for
  individual message guidance per situation, full-morning-triage for complete pipeline
  processing, cold-rescue for targeted re-engagement, campaign-launch for outreach
  campaign setup, sequence-runner for templated multi-touch sequences.
metadata:
  version: "2.0"
  author: linkninja
---

# Batch Drafting

Draft personalised messages for 5, 20, or 1000 conversations in one session using the server-orchestrated `start_batch_draft` flow. The AI does the actual drafting work in chunks (the server doesn't write drafts itself — see the controller's verbatim guidance: *"Does NOT write drafts by itself — creates items for your AI to draft"*). The user reviews everything in their dashboard and sends.

## Before Starting

1. Run `get_context()` to load the user's sales context and the live `ai_execution` rules
2. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | "I need your ICP to draft relevant messages. Want to set that up?" Run **icp-definition** |
| Voice Profile (`voice_profile`) | Recommended | Voice is also enforced server-side via the `shared_bundle` returned by `get_job_chunk`. A richer profile makes drafts land harder. |
| Positioning (`positioning_context`) | **Required (hard stop)** | If empty, **stop** and ask: *"What are you offering them? I need this to frame value props — without it the drafts are generic."* Don't proceed until set. |
| Personal Story (`personal_story`) | Optional | Use for credibility references when relevant |

3. Determine what the user wants drafted. If they don't specify, ask: "Which conversations should I draft for? Options: all pending replies, a specific stage, cold conversations, or a campaign tag."

## When to Use Which Pattern

| Batch size | Pattern |
|-----------|---------|
| 1 conversation | `get_draft_prompt(id)` → AI drafts → `update_conversation(id, draft_message, ai_notes)` (see **dm-writing**) |
| 2–5 | Optional individual flow per conversation, OR start_batch_draft for consistency |
| 5+ | **`start_batch_draft` chunked flow** — recommended |
| 100+ | `start_batch_draft` (max 1000 per job) |

## The Canonical Flow (`start_batch_draft`)

From the live `ai_execution.job_protocols.draft_reply` block in `get_context`:

```
start_batch_draft → continue_active_job → submit_job_results(claim_next=true) loop → get_job_results
```

### Operational Rules (Verbatim From Live Protocol)

- **Don't stop after start.** Keep calling tools in the same turn.
- **No user-facing progress message** until `submit_job_results` has succeeded — and `get_job_results` is fetched.
- **No user response between chunks.** Process all chunks in a single turn.
- **If the user says "continue" / "resume":** call `continue_active_job` first.
- **Don't start a new job if one is active** — check first.
- **Recommended polling: 2 seconds.**
- **For draft jobs:** drafts can only be `applied` or `failed` — **skipped is NOT allowed**. Every claimed item must be drafted. `reply_mode` (`reply` or `follow_up`) is required on every applied item.

> **Agent-only documentation below.** The chunk loop, `chunk_token`, `job_id`, and submit/claim mechanics are protocol-level details for the AI agent's tool calls. **Never surface them in user-facing reports.** Describe progress to the user in plain terms ("drafting in batches…", "X of Y drafts ready", "wrapping up"). The `confidentiality` block from `get_context` is authoritative — internal job mechanics aren't discussed with users.

### Step 1: Start the Job

Choose **filter mode** (filter object) or **list mode** (`conversation_ids` array). Add optional `template_id` + `draft_mode` + `reply_intent`:

```
start_batch_draft(
  filter={stage: "qualified", my_turn: true},
  reply_intent: "qualify",
  limit: 100
)
```

Returns `job_id` and `recommended_poll_seconds`.

### Step 2: Poll, Then Loop Chunks

```
get_job_status(job_id="<job_id>")
```

When ready, claim the first chunk:

```
get_job_chunk(job_id="<job_id>", limit=10)
```

Returns:

- `chunk_token` — required for submit
- `shared_bundle` — voice_profile, personal_story, positioning_context, additional_context, stages, tags
- `items[]` — each with id, contact, transcript, `effective_stage`, `active_stage_definition`, `my_turn`, and an embedded `draft_prompt` per item
- `remaining_after_this_chunk`

### Step 3: Draft Every Item, Then Submit

For each item, **follow the embedded `draft_prompt` exactly**. Pull voice and context from the `shared_bundle`. Determine `reply_mode`:

- `reply` — direct response to a recent message
- `follow_up` — re-engaging after silence

Submit results and claim the next chunk inline (reduces round trips):

```
submit_job_results(
  job_id="<job_id>",
  chunk_token="<chunk_token>",
  items: [
    {id: "conv_xxx", status: "applied", draft_message: "...", reply_mode: "reply"},
    {id: "conv_yyy", status: "applied", draft_message: "...", reply_mode: "follow_up"},
    {id: "conv_zzz", status: "failed",  error: "transcript missing context to draft confidently"}
  ],
  claim_next: true
)
```

The response includes the next chunk inline (when `claim_next: true`). Repeat the draft → submit loop until no more chunks remain.

### Step 4: Fetch and Share Results

```
get_job_results(job_id="<job_id>", limit=50)
```

Returns the saved per-conversation payload (contact name, draft_message, reply_mode). Share with the user in their terms — never expose job IDs or chunk tokens.

## Common Patterns

### Pattern A: Drafts for a Stage

> "Draft follow-ups for all my qualified leads where it's my turn."

```
start_batch_draft(
  filter={stage: "qualified", my_turn: true},
  reply_intent: "qualify"
)
```

Loop chunks → submit → results. Apply **A–B Method** + **Question Sequence** in each draft (see `references/sell-by-chat-methodology.md` and **reply-handling**).

### Pattern B: Cold Re-engagement Cohort

> "Draft re-engagement messages for everyone going cold."

```
start_batch_draft(
  filter={freshness: "cold", my_turn: true},
  reply_intent: "nurture"
)
```

Per-item, set `reply_mode: "follow_up"`. After the job completes, batch the reminders for the cohort using filter mode:

```
bulk_update(
  filter={freshness: "cold", my_turn: true},
  reminder: "in 7 days"
)
```

### Pattern C: Campaign Cohort with a Template

> "Draft the Day 7 follow-up for my Q1 campaign using the GR3 template."

First, find the template:

```
list_templates(tag="gr3")
```

Then:

```
start_batch_draft(
  filter={tags: ["campaign-q1"], my_turn: true},
  template_id: <id>,
  draft_mode: "guided",
  reply_intent: "advance"
)
```

| draft_mode | Behaviour |
|------------|-----------|
| `locked` | Server renders `{{variables}}` only. No AI personalisation. Use for known-working sequences. |
| `guided` (default) | AI personalises opening / closing within the template structure. Best balance. |
| `flexible` | Template is a loose reference. AI writes freely. Use for varied audiences. |

See `references/template-modes.md` for the full spec.

### Pattern D: Mixed Pipeline by Priority

> "Draft for everyone waiting on me."

Process by priority — run multiple `start_batch_draft` jobs sequentially, one per priority bucket. Don't blast everyone at once:

| Priority | Filter | reply_intent |
|----------|--------|--------------|
| 1 | `stage: "qualified"`, `my_turn: true`, `freshness: "fresh"` | `qualify` |
| 2 | `stage: "discovery"`, `my_turn: true` | `advance` |
| 3 | `stage: "closing"`, `my_turn: true` | `advance` |
| 4 | `freshness: "cold"`, `my_turn: true` | `nurture` |

### Pattern E: Single / Small Batch (Fallback)

For ≤5 conversations, the individual flow is faster than the chunked job:

```
get_draft_prompt(id="<id>", reply_intent="qualify")  → AI drafts following the prompt → update_conversation(id, draft_message="...", ai_notes="...")
```

This is also the right path when one specific draft needs heavy customisation. See `references/tools-registry.md` for `get_draft_prompt` parameters.

## Drafting Rules

For every draft, follow these rules:

| Rule | Detail |
|------|--------|
| Never send | Drafts only. User reviews and sends from dashboard. |
| Always include `ai_notes` | Explain: signal responded to, draft purpose, expected next step (used by classify jobs only — for draft jobs, use `context_used` if relevant) |
| Match voice | Voice is enforced via the `shared_bundle` and the per-item `draft_prompt`. Follow them exactly. |
| One thing per message | Don't pitch + qualify + close in one DM |
| Reference something real | Mention something specific from the thread, never a generic opener |
| Keep it short | 2–4 sentences for most messages |
| Add value on follow-ups | Never "just checking in" — add an insight, result, or question (per playbook follow-up cadence) |
| Set reminders for re-engagement | Use `bulk_update` filter mode after the draft job to batch reminders |

## Handling Scale

| Conversations | Recommended approach |
|--------------|----------------------|
| 1–5 | Individual `get_draft_prompt` + `update_conversation` |
| 5–100 | One `start_batch_draft` job |
| 100–500 | One `start_batch_draft` job (single job handles up to 1000) |
| 500+ | Filter to highest-priority segment first; run sequential jobs by priority |

**Pagination:** `search_conversations` results are not needed before `start_batch_draft` — the filter is server-side. Use `search_conversations` only when the user explicitly asks to review the full list before drafting.

**Job limits:** `start_batch_draft` accepts up to 1000 conversations per job. `get_job_chunk` returns up to 25 items per claim (default 10).

## Confidentiality

Don't surface job IDs, chunk tokens, lease mechanics, or protocol internals in user-facing text. Translate progress to user terms:

- "Drafting in batches…"
- "X of Y drafts ready."
- "Wrapping up the batch — last few coming through."
- "All drafts saved. Open your dashboard to review."

## Workflow Summary

```
1. get_context()                         → Load ICP + voice + ai_execution rules
2. start_batch_draft(filter | ids,       → Kick off the job (server side)
   template_id?, draft_mode?,
   reply_intent?)
3. get_job_status(job_id)                → Poll every 2s until ready
4. Loop:                                 → Until no more chunks
   ├─ get_job_chunk(job_id)              → Claim next chunk + shared bundle
   ├─ AI drafts every item using each    → status: applied or failed
   │  embedded draft_prompt              → reply_mode: reply or follow_up (required)
   └─ submit_job_results(job_id,         → Submit + claim next inline
        chunk_token, items,
        claim_next=true)
5. get_job_results(job_id)               → Pull saved payload
6. Report to user                        → Count, hottest, next step
```

## Report Template

After the job completes:

> **Batch drafting complete.**
>
> - **N drafts** saved and ready to review in your dashboard
> - **Stages covered:** [list of stages processed]
> - **Reply modes:** A drafts as direct replies, B as re-engagement follow-ups
> - **Reminders set:** M follow-up reminders (where applicable)
>
> **Hottest draft:** [name] in [stage] — [why this one matters most]
>
> **Next step:** Open your LinkNinja dashboard, review the AI drafts, edit if needed, and hit send.

## Guidelines

- Always run inside the same turn — don't pause for user input mid-loop. The protocol explicitly disallows it.
- Use filter mode whenever the action applies uniformly. Don't paginate `search_conversations` first.
- Use `compact=true` only on `search_conversations` calls used for inspection — `start_batch_draft` doesn't need pre-paginated IDs.
- Always include `ai_notes` (or `context_used`) so the user understands the reasoning per draft.
- Match the user's `voice_profile` (enforced via `shared_bundle`). If the user has none, fall back to the **Ten Core Voice Rules** in `references/sell-by-chat-methodology.md`.
- For cold/ghost conversations, follow the playbook cadence — Day 1 / 3 / 7 / extending — and pair with `bulk_update` reminder batching after the draft job.
- If a conversation is genuinely ambiguous and you can't draft confidently, mark the item as `failed` with an `error` reason — don't fabricate a draft.
- One draft per conversation. A new draft overwrites the previous one.
- Never expose job IDs, chunk tokens, or protocol mechanics in user-facing reports.

## Power-Ups (Optional)

See [POWER-UPS.md](../../../POWER-UPS.md) for full setup. Batch-drafting is the highest-leverage place to invest in automation.

- **Hook:** `PreToolUse` voice-check on every `submit_job_results` call — catches voice slips before they save.
- **Hook:** `Stop` hook notifies on Slack when a 100-contact batch finishes (so you know when to review).
- **Subagent:** Drafter + reviewer pair per chunk item — drafter generates, reviewer checks against `voice_profile` + framework + `positioning_context` fit before submission. Two-pass quality at the cost of an extra subagent call.
- **MCP:** Slack (batch-complete notifications).
- **Model:** Sonnet 4.6+ (best balance of quality + speed for prose generation at scale).

## Related Skills

- **dm-writing** — Router that identifies the right DM situation per conversation
- **cold-outreach** — First messages, cold DMs, post-event openers (for solo drafts in the `opening` category)
- **reply-handling** — Building rapport and qualifying through A–B Method
- **objection-handling** — Acknowledge → Ask Context → Reframe pattern
- **call-booking** — Booking calls with Micro-commitments
- **cold-rescue** — Targeted re-engagement following the playbook cadence
- **full-morning-triage** — Daily compound workflow that uses batch-drafting under the hood
- **campaign-launch** — Set up an outreach campaign cohort, then call batch-drafting
- **sequence-runner** — Multi-touch sequences with templates over time (uses `start_batch_draft` per touch)
- **voice-profile-setup** — Configure voice matching for natural-sounding drafts
- **template-library** — Manage templates referenced by `start_batch_draft(template_id)`
