---
name: reminder-engine
description: >
  Bulk reminder management — create follow-up cadences, audit overdue reminders,
  clear stale reminders, and build stage-specific reminder schedules. The follow-up
  system. Use when the user says "set reminders", "reminder audit", "what's overdue",
  "set follow-up cadences", "bulk reminders", "clear old reminders", "when should I
  follow up", "reminder cleanup", "set 3-day reminders for qualified", or "reminder
  engine". Pure reminder management — does not draft messages. Related: batch-drafting
  for writing messages at scale, dm-writing for individual message guidance,
  full-morning-triage for complete pipeline processing, cold-rescue for re-engagement
  with drafts.
metadata:
  version: "1.0"
  author: linkninja
---

# Reminder Engine

Manage the follow-up system across the entire pipeline. Set stage-based cadences, audit overdue conversations, clear stale reminders, and build escalating follow-up schedules. This skill sets reminders only -- it does not draft messages.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Run `pipeline_stats()` to get the current pipeline snapshot
3. Check what the user needs:

| User Says | Pattern |
|-----------|---------|
| "Set reminders for qualified" / "3-day reminders for [stage]" | Stage-based cadence |
| "What's overdue?" / "Who am I late on?" | Overdue audit |
| "Set escalating follow-ups" / "3-7-14 cadence" | Escalating cadence |
| "Clear old reminders" / "Reminder cleanup" | Bulk clear |
| "Set reminders for campaign X" | Campaign reminders |
| "Set up my follow-up system" / "Reminder cadences for everything" | Full pipeline cadence (all stages) |

4. If the user doesn't specify, ask: "What would you like to do? I can set reminders for a stage, audit what's overdue, clear stale reminders, or build cadences for your whole pipeline."

## Stage-Specific Recommended Cadences

Use this table as the default when the user asks for stage-based reminders. Adjust based on their context and preferences.

| Stage | Default Follow-Up | Escalation | After 3 Attempts |
|-------|-------------------|------------|-------------------|
| opening | 3 days | 5 days, 10 days | Archive or stop |
| chatting | 5 days | 7 days, 14 days | Review if ICP match |
| qualified | 3 days | 5 days, 7 days | Escalate effort (higher value) |
| discovery | 2 days | 3 days, 5 days | Direct follow-up |
| closing | 1-2 days | 3 days, 5 days | Check for blockers |
| won | N/A | N/A | N/A |
| lost | 30-90 days (check back) | N/A | N/A |

## Reminder Format

`bulk_classify` accepts `reminder` as a string. Valid formats:

| Format | Example |
|--------|---------|
| ISO datetime | `"2026-03-05T09:00:00Z"` |
| Date only | `"2026-03-05"` |
| Natural language | `"in 3 days"`, `"next Monday"`, `"in 2 weeks"` |
| Clear | `"clear"` |

## Patterns

### Pattern 1: Stage-Based Cadence

"Set reminders for all my qualified leads" or "3-day follow-ups for chatting."

**Step 1:** Find conversations in the target stage:

```
search(stage="qualified", my_turn=true, compact=true)
```

If `has_more` is true, paginate:

```
search(stage="qualified", my_turn=true, compact=true, page=2)
```

**Step 2:** Set reminders in batch using the recommended cadence:

```
bulk_classify(updates=[
  {"id": "abc", "reminder": "in 3 days", "ai_notes": "Reminder engine: qualified stage default cadence (3 days)."},
  {"id": "def", "reminder": "in 3 days", "ai_notes": "Reminder engine: qualified stage default cadence (3 days)."},
  ...
])
```

Max 100 per `bulk_classify` call. Split if needed.

**Step 3:** If the user wants cadences across multiple stages, repeat for each stage with the appropriate interval from the cadence table.

### Pattern 2: Overdue Audit

"What's overdue?" or "Who am I late following up with?"

**Step 1:** Find conversations where it's the user's turn:

```
search(my_turn=true, compact=true)
```

Paginate if `has_more` is true.

**Step 2:** For each conversation, check `last_message_at`. Compare against the recommended cadence for the conversation's stage:

| Stage | Overdue If Silent For |
|-------|----------------------|
| opening | > 5 days |
| chatting | > 7 days |
| qualified | > 5 days |
| discovery | > 3 days |
| closing | > 3 days |

**Step 3:** For conversations that look significantly overdue, fetch to understand context:

```
fetch(id="<conversation_id>")
```

Read the thread to determine: is this actually overdue, or was the conversation naturally paused?

**Step 4:** Build the overdue report (see Report Template below). Group by severity:

| Severity | Definition |
|----------|------------|
| Critical | Discovery/closing overdue by 2x+ the recommended cadence |
| High | Qualified overdue by 2x+ |
| Medium | Any stage overdue by 1-2x |
| Low | Opening/chatting slightly past window |

**Step 5:** Optionally set reminders for overdue conversations:

```
bulk_classify(updates=[
  {"id": "abc", "reminder": "tomorrow", "ai_notes": "Overdue audit: qualified lead, 8 days since last message. Critical priority."},
  {"id": "def", "reminder": "in 2 days", "ai_notes": "Overdue audit: discovery stage, 5 days silent. High priority."},
  ...
])
```

### Pattern 3: Escalating Cadence

"Set 3-7-14 day follow-up sequence" or "escalating reminders based on attempt count."

**Step 1:** Find target conversations:

```
search(stage="qualified", my_turn=true, compact=true)
```

**Step 2:** For each conversation, fetch to check `ai_notes` for follow-up attempt history:

```
fetch(id="<conversation_id>")
```

**Step 3:** Determine the follow-up number from `ai_notes` or message pattern, then set the appropriate interval:

| Follow-Up # | Interval | ai_notes |
|-------------|----------|----------|
| 1st attempt | 3 days | "Follow-up #1 scheduled" |
| 2nd attempt | 7 days | "Follow-up #2 scheduled (escalated)" |
| 3rd attempt | 14 days | "Follow-up #3 scheduled (final before review)" |
| 4th+ | Stop or archive | "3 attempts exhausted. Needs manual review or archive." |

**Step 4:** Batch set reminders:

```
bulk_classify(updates=[
  {"id": "abc", "reminder": "in 3 days", "ai_notes": "Escalating cadence: follow-up #1 scheduled."},
  {"id": "def", "reminder": "in 7 days", "ai_notes": "Escalating cadence: follow-up #2 scheduled (escalated from 3-day)."},
  {"id": "ghi", "reminder": "in 14 days", "ai_notes": "Escalating cadence: follow-up #3 scheduled (final attempt)."},
  ...
])
```

### Pattern 4: Bulk Clear

"Clear old reminders" or "clean up stale reminders."

**Step 1:** Find archived conversations that may still have reminders:

```
search(include_archived=true, compact=true)
```

**Step 2:** Also find conversations where reminders no longer make sense:

```
search(freshness="stale", compact=true)
```

**Step 3:** Clear reminders in batch:

```
bulk_classify(updates=[
  {"id": "abc", "reminder": "clear", "ai_notes": "Reminder cleared: conversation archived."},
  {"id": "def", "reminder": "clear", "ai_notes": "Reminder cleared: stale conversation, no engagement in 30+ days."},
  ...
])
```

**Decision rules for clearing:**

| Situation | Clear? |
|-----------|--------|
| Conversation archived (any reason) | Yes, unless archived as `later` with intentional check-back |
| Won deals | Yes -- no follow-up needed |
| Stale + no buying signals | Yes |
| Stale + had buying signals | No -- set a new reminder instead |
| Active conversation, their turn | Yes -- wait for their reply, no reminder needed |

### Pattern 5: Campaign Reminders

"Set follow-up cadence for my Q1 campaign" or "reminders for campaign-tagged conversations."

**Step 1:** Find campaign conversations:

```
search(tags=["campaign-q1"], my_turn=true, compact=true)
```

**Step 2:** Set reminders with campaign context in `ai_notes`:

```
bulk_classify(updates=[
  {"id": "abc", "reminder": "in 3 days", "ai_notes": "Campaign Q1: follow-up reminder. Stage: qualified."},
  {"id": "def", "reminder": "in 5 days", "ai_notes": "Campaign Q1: follow-up reminder. Stage: chatting."},
  ...
])
```

Adjust intervals based on the conversation's stage using the cadence table.

## Full Pipeline Cadence Setup

When the user says "set up my follow-up system" or "reminders for everything," process all active stages:

```
1. get_context()                              --> Load context
2. pipeline_stats()                           --> See stage counts
3. For each stage with my_turn conversations:
   search(stage="<stage>", my_turn=true, compact=true)
4. Apply cadence table defaults:
   bulk_classify(updates=[...])               --> Batch per stage
5. Report results                             --> Summary with breakdown
```

Process stages in priority order: closing, discovery, qualified, chatting, opening.

## Report Template

After any reminder operation, deliver a summary:

> **Reminder engine complete.**
>
> - **Reminders set:** N total
> - **By stage:** closing: X, discovery: Y, qualified: Z, chatting: W, opening: V
> - **Overdue conversations:** M found
>   - [Name] -- [stage] -- [days overdue] -- [severity]
>   - [Name] -- [stage] -- [days overdue] -- [severity]
>   - [up to 5 listed]
> - **Reminders cleared:** X (stale/archived)
> - **Next actions:** Earliest reminders fire on [date]
>
> **Need messages drafted?** Run **batch-drafting** or **dm-writing** for the conversations with reminders set.

## Guidelines

- This skill sets reminders only. It does not draft messages. Suggest **batch-drafting** or **dm-writing** when the user needs message content.
- `bulk_classify` supports the `reminder` field (max 100 per call). Split larger batches.
- `bulk_classify` does NOT support `draft_message`. That requires individual `update_conversation` calls.
- To find overdue conversations, use `search(my_turn=true)` and analyze `last_message_at` dates. There is no direct "overdue reminders" filter.
- Always include `ai_notes` explaining why a reminder was set or cleared.
- Use `compact=true` on `search` when only collecting IDs for batch operations.
- Handle `has_more` pagination on all `search` results.
- Do not set reminders on won deals or conversations where it is their turn to reply.
- When clearing, preserve reminders on `later`-archived conversations with intentional check-back dates.
- Default to the stage cadence table. Adjust if the user specifies custom intervals.
- Process stages in priority order: closing > discovery > qualified > chatting > opening.

## Related Skills

- **batch-drafting** -- Draft messages at scale for conversations with reminders set
- **dm-writing** -- Individual message guidance for specific DM situations
- **full-morning-triage** -- Sets reminders as part of daily pipeline processing
- **cold-rescue** -- Re-engagement with drafts and reminders for cold conversations
- **pipeline-cleanup** -- Archive stale conversations and clear associated reminders
- **pipeline-health-check** -- Diagnose follow-up gaps and pipeline bottlenecks
