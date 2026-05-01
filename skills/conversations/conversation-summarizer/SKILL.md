---
name: conversation-summarizer
description: >
  Generate or refresh AI summaries and AI notes across conversations in batch.
  The pipeline documentation expert — pure documentation, no stage changes or drafts.
  Use when the user says "summarize my conversations", "update summaries", "generate
  notes", "my summaries are outdated", "refresh AI notes", "add notes to my pipeline",
  "document my conversations", "summarize my pipeline", or "update my conversation notes".
  Handles three modes: fill gaps (no summary yet), refresh a stage (re-summarize one
  stage), and refresh all (re-summarize entire pipeline). Related: full-morning-triage
  for daily processing with drafts and classification, pipeline-cleanup for archiving
  and hygiene, batch-drafting for writing messages at scale, pipeline-health-check
  for analytics.
metadata:
  version: "1.0"
  author: linkninja
---

# Conversation Summarizer

Generate or refresh AI summaries and AI notes across the pipeline in batch. Pure documentation — does not change stages, tags, or create drafts. Reads every thread, writes a structured summary and evidence-based notes, saves via `bulk_update`.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Recommended | Summaries will be less targeted without ICP context. Note this, but proceed. |
| Summary Instructions (`summary_instructions`) | Recommended | Use default format (see Summary Format below). Mention: "You can configure custom summary instructions with **icp-definition**." |
| Positioning (`positioning_context`) | Optional | Helps identify relevance signals in conversations |
| Voice Profile (`voice_profile`) | Not needed | This skill does not draft messages |

3. Determine the operating mode based on user request:

| User Says | Mode | Description |
|-----------|------|-------------|
| "summarize my conversations", "add notes", "fill in summaries" | Fill gaps | Only conversations with no summary |
| "refresh summaries for qualified", "re-summarize discovery" | Refresh stage | Re-summarize one specific stage |
| "refresh all summaries", "my ICP changed, update everything" | Refresh all | Re-summarize entire pipeline |
| Ambiguous | Ask | "Want me to fill in missing summaries, refresh a specific stage, or re-summarize everything?" |

## Summary Format

If `summary_instructions` exist in context, follow those. Otherwise use this default:

**Summary** — One sentence capturing three things:
1. Where the conversation stands (stage-relevant status)
2. What the prospect needs (their problem or situation)
3. What happens next (pending action)

| Quality | Example |
|---------|---------|
| Good | "Solo executive coach, year 3. Needs steady DM lead flow before Q1 cohort launch. Waiting for proposal after positive discovery call." |
| Good | "Marketing director, 50-person agency. Exploring onboarding solutions. Asked about pricing, awaiting reply." |
| Bad | "We talked about their business needs and they seemed interested." |
| Bad | "Good conversation. Follow up soon." |

**AI Notes** — Evidence-based reasoning in structured format:
1. What signals were detected (buying signals, objections, ICP fit indicators)
2. Why the current stage makes sense
3. What the next logical action should be

| Quality | Example |
|---------|---------|
| Good | "Buying signals: confirmed budget ($50K range), timeline (Q1), authority (CTO). Stage: qualified -> discovery. Next: schedule demo." |
| Good | "No buying signals yet. General rapport about their industry. Stage: chatting. Next: ask about their current challenges." |
| Bad | "Seems like a good prospect." |
| Bad | "Interesting conversation." |

## Mode 1: Fill Gaps

Find conversations that have no summary. Best for first-time setup or after a bulk import.

**Step 1:** Get all conversations with transcripts:

```
export_conversations(include_messages=true)
```

If `has_more` is true, paginate:

```
export_conversations(include_messages=true, page=2)
```

**Step 2:** Filter to conversations where `summary` is empty or missing.

**Step 3:** For each conversation without a summary, read the message transcript and write a summary + AI notes following the format above.

**Step 4:** Save in batch:

```
bulk_update(updates=[
  {"id": "abc", "summary": "Founder of a 12-person creative agency. Needs steadier inbound pipeline before Q1 hiring push. Waiting for proposal after discovery call.", "ai_notes": "Buying signals: budget confirmed ($25K), timeline (Q1 hiring push), authority (sole founder). Stage: discovery. Next: send proposal."},
  {"id": "def", "summary": "Marketing manager at mid-size agency. Early rapport about content strategy.", "ai_notes": "No buying signals. General industry conversation. Stage: chatting. Next: ask about their current pain points."},
  {"id": "ghi", "summary": "Founder, 10-person startup. Asked about pricing after seeing a case study.", "ai_notes": "Interest signal: initiated pricing question. ICP fit: small startup, decision maker. Stage: qualified. Next: answer pricing and qualify budget."},
  ...
])
```

**Step 5:** If more than 100 conversations need summaries, split into multiple `bulk_update` calls (max 100 per call).

**Step 6:** Continue paginating until all pages are processed.

### Large Backlog Shortcut

If `export_conversations` shows 200+ conversations without summaries, consider a two-pass approach:

1. **Pass 1 — Batch classify server-side** for stage/tag assignment:
   ```
   start_batch_classify(unclassified_only=true, limit=500)
   ```
   Wait for completion via `get_job_status(job_id="<job_id>")`.

2. **Pass 2 — Manual summary pass** stage by stage, starting with highest value:
   ```
   export_conversations(stage="qualified", include_messages=true)
   export_conversations(stage="discovery", include_messages=true)
   export_conversations(stage="closing", include_messages=true)
   ```
   Summarize and save each batch. Work down the pipeline.

## Mode 2: Refresh Stage

Re-summarize all conversations in a specific stage. Use after stage criteria change, periodic quality check, or when a segment's summaries feel stale.

**Step 1:** Export the target stage:

```
export_conversations(stage="<stage>", include_messages=true)
```

Paginate if `has_more` is true.

**Step 2:** For each conversation, read the full transcript and write a fresh summary + AI notes. Ignore the existing summary — write from scratch based on the current thread.

**Step 3:** Save in batch:

```
bulk_update(updates=[
  {"id": "abc", "summary": "<new summary>", "ai_notes": "<new notes>"},
  {"id": "def", "summary": "<new summary>", "ai_notes": "<new notes>"},
  ...
])
```

Split into multiple calls if the stage has more than 100 conversations.

### Stage Priority Order

When the user asks to refresh "a few stages" without specifying which, start with the highest-value stages:

| Priority | Stage | Why |
|----------|-------|-----|
| 1 | Qualified | Active buying signals — summaries must be accurate |
| 2 | Discovery | Deep conversations — summaries capture deal details |
| 3 | Closing | Decision-critical — summaries track blockers and next steps |
| 4 | Chatting | High volume — summaries help prioritize who to advance |
| 5 | Opening | Low context — summaries are brief by nature |

## Mode 3: Refresh All

Re-summarize the entire active pipeline. Use after ICP change, major context update, or when summaries have drifted from actual conversation state.

**Step 1:** Get a pipeline snapshot:

```
get_stats()
```

Report the scope to the user:

> "Your pipeline has [X] active conversations. I'll re-summarize all of them. This will take a few minutes for large pipelines."

**Step 2:** Export all conversations with transcripts, working stage by stage in priority order:

```
export_conversations(stage="qualified", include_messages=true)
export_conversations(stage="discovery", include_messages=true)
export_conversations(stage="closing", include_messages=true)
export_conversations(stage="chatting", include_messages=true)
export_conversations(stage="opening", include_messages=true)
```

Paginate each stage if `has_more` is true.

**Step 3:** For each conversation, read the full transcript and write a fresh summary + AI notes using the current context (ICP, summary_instructions).

**Step 4:** Save in batches of up to 100:

```
bulk_update(updates=[
  {"id": "abc", "summary": "<new summary>", "ai_notes": "<new notes>"},
  ...up to 100 per call
])
```

**Step 5:** Continue through all stages until the entire pipeline is documented.

## Handling Pagination

Every `export_conversations` call may return `has_more: true`. Always check and fetch subsequent pages:

```
export_conversations(stage="qualified", include_messages=true)          → page 1
export_conversations(stage="qualified", include_messages=true, page=2)  → page 2
export_conversations(stage="qualified", include_messages=true, page=3)  → page 3 (if has_more)
```

Process and save summaries for each page before moving to the next. This keeps memory manageable for large pipelines.

## Workflow Summary

```
1. get_context()                               → Load ICP + summary_instructions
2. Determine mode (fill gaps / refresh stage / refresh all)
3. export_conversations(include_messages=true, ...)           → Get conversations with transcripts
   +-- Paginate: check has_more, fetch next pages
4. Read each transcript                        → Write summary + ai_notes
5. bulk_update(updates=[{id, summary,        → Save in batches of 100
   ai_notes}, ...])
   +-- Split if > 100 conversations
6. Report to user                              → Counts and sample summaries
```

## Report Template

After summarization is complete, deliver a summary:

> **Summarization complete.**
>
> **Mode:** [Fill gaps / Refresh stage: {stage} / Refresh all]
>
> **Conversations summarized:** [N] total
> - [breakdown by stage if applicable]
>
> **Sample summaries:**
> - **[Name]** ([stage]): "[summary excerpt]"
> - **[Name]** ([stage]): "[summary excerpt]"
> - **[Name]** ([stage]): "[summary excerpt]"
>
> **Notes:**
> - [Any observations — e.g., "12 conversations had minimal content (1-2 messages), summaries are brief."]
> - [Any ICP-related observations — e.g., "Found 5 conversations that may not match your current ICP."]
>
> **Next step:** Review summaries in your LinkNinja dashboard. Run **pipeline-health-check** to see how your pipeline looks with fresh documentation.

## Job Lifecycle (Cancel & Resume)

For the bulk classify shortcut path:

- **Cancel mid-flight:** `cancel_job(job_id="<job_id>")` if a classify batch is processing the wrong cohort.
- **Resume:** if the user says *"continue"*, *"resume"*, *"keep going"* — call `continue_active_job()` first. Don't start a new job while one is active.

## Guidelines

- This skill is pure documentation. Never change stages, tags, or create draft messages.
- Always use `summary_instructions` from `get_context()` when available. Fall back to the default format.
- Always include both `summary` and `ai_notes` in every update. They serve different purposes: summary is the quick-glance view, ai_notes is the reasoning.
- Use `bulk_update` for all saves. It supports `summary` and `ai_notes` fields. Max 100 per call.
- Handle `has_more` pagination on every `export_conversations` call. Do not assume a single page covers everything.
- Process and save page by page to avoid accumulating too many unsaved summaries.
- For conversations with minimal content (1-2 messages), keep summaries brief: "Connected via [method]. No conversation yet." or "Exchanged introductions. No business context."
- When `summary_instructions` include specific fields or formats, match them exactly.
- If a conversation is clearly not ICP, note it in `ai_notes` but do not archive — that is **pipeline-cleanup**'s job.
- For "refresh" modes, write from scratch. Do not carry over language from the old summary.
- If the pipeline has 500+ conversations, suggest working stage by stage rather than all at once.

## Power-Ups (Optional)

See [POWER-UPS.md](../../../POWER-UPS.md) for full setup.

- **Cron:** `/schedule weekly Wednesday 2pm conversation-summarizer "refresh stale summaries"` — mid-week refresh so weekend analysis (pipeline-health-check, won/lost analysis) has fresh notes.
- **Context MCP:** wire into your KB (Obsidian / Notion / Reflect / wherever you keep prospect notes) — sync summaries into your own knowledge base so you can read them back from there in any other context, not just inside LinkNinja's UI.

## Related Skills

- **full-morning-triage** — Daily pipeline processing (classifies, drafts, and summarizes as part of a larger workflow)
- **pipeline-cleanup** — Archiving and hygiene (acts on what summarizer documents)
- **batch-drafting** — Writing messages at scale (complements summarizer — one documents, the other responds)
- **pipeline-health-check** — Analytics and diagnostics (benefits from accurate summaries)
- **icp-definition** — Configure ICP and summary_instructions that this skill uses
