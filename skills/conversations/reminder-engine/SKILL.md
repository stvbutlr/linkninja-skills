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
2. Run `get_stats()` to get the current pipeline snapshot
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

## The Playbook Cadence

A single flat cadence applies across all active stages (from `references/sell-by-chat-methodology.md`). 80% of sales close *after* the 5th touchpoint — most operators quit before then. Persistence with new value at each touch is the edge.

| Touch # | Timing | What Each Touch Must Add |
|---------|--------|--------------------------|
| 1 | Day 1 — original outreach | The opener (per cold-outreach Three Opening Rules) |
| 2 | Day 3 | New value: insight, observation, or question tied to their world |
| 3 | Day 7 | A different angle — new insight or new question |
| 4 | Day 14 | A door-open, "no worries if timing's off" — but with substance |
| 5 | Day 30 | Fresh hook — new industry development, recent post, mutual signal |
| 6+ | Day 60, 90, extending | Long-tail nurture; only when genuinely new value to share |

### Stage-Aware Adjustments

The base cadence applies everywhere, but two stages benefit from a tighter feedback loop:

| Stage | Adjustment |
|-------|-----------|
| `discovery` (call already booked) | Tighten last-mile: 24h before call confirm, 24h after call recap |
| `closing` (proposal out) | Tighten: Day 1 acknowledgment, Day 3 check, Day 7 nudge — they're already deep |
| `won` | No reminders needed |
| `lost` | 30–90 day "check-back" reminder for the `archive: {reason: "later"}` pattern |

If you have nothing new to add at a scheduled touch, **skip it and extend the interval** — empty pings destroy trust faster than silence.

## Reminder Format

`bulk_update` accepts `reminder` as a string. Valid formats:

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
search_conversations(stage="qualified", my_turn=true, compact=true)
```

If `has_more` is true, paginate:

```
search_conversations(stage="qualified", my_turn=true, compact=true, page=2)
```

**Step 2:** Set reminders in batch using the recommended cadence:

```
bulk_update(updates=[
  {"id": "abc", "reminder": "in 3 days", "ai_notes": "Reminder engine: qualified stage default cadence (3 days)."},
  {"id": "def", "reminder": "in 3 days", "ai_notes": "Reminder engine: qualified stage default cadence (3 days)."},
  ...
])
```

Max 100 per `bulk_update` call. Split if needed.

**Step 3:** If the user wants cadences across multiple stages, repeat for each stage with the appropriate interval from the cadence table.

### Pattern 2: Overdue Audit

"What's overdue?" or "Who am I late following up with?"

**Step 1:** Find conversations where it's the user's turn:

```
search_conversations(my_turn=true, compact=true)
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
get_conversation(id="<conversation_id>")
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
bulk_update(updates=[
  {"id": "abc", "reminder": "tomorrow", "ai_notes": "Overdue audit: qualified lead, 8 days since last message. Critical priority."},
  {"id": "def", "reminder": "in 2 days", "ai_notes": "Overdue audit: discovery stage, 5 days silent. High priority."},
  ...
])
```

### Pattern 3: Playbook Cadence (Day 1/3/7/14/30/extending)

"Set the playbook follow-up sequence" or "escalating reminders based on attempt count."

**Step 1:** Find target conversations:

```
search_conversations(stage="qualified", my_turn=true, compact=true)
```

**Step 2:** For each conversation, fetch to check `ai_notes` for follow-up attempt history:

```
get_conversation(id="<conversation_id>")
```

**Step 3:** Determine the follow-up number from `ai_notes` or message pattern, then set the appropriate interval:

| Follow-Up # | Interval | ai_notes |
|-------------|----------|----------|
| 1st attempt | 3 days | "Touch #2 — Day 3 value-add scheduled. Need insight or observation tied to their world." |
| 2nd attempt | 7 days | "Touch #3 — Day 7 different angle. New question or industry observation." |
| 3rd attempt | 14 days | "Touch #4 — Day 14 door-open with substance. No 'just checking in'." |
| 4th attempt | 30 days | "Touch #5 — Day 30 fresh hook. Pull recent posts via get_enrichment for new material (Sales Navigator required; otherwise reuse headline-level cues)." |
| 5th+ | Extend (60d, 90d) | "Long-tail nurture. Only contact when genuinely new value to share." |

**Step 4:** Batch set reminders:

```
bulk_update(updates=[
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
search_conversations(include_archived=true, compact=true)
```

**Step 2:** Also find conversations where reminders no longer make sense:

```
search_conversations(freshness="stale", compact=true)
```

**Step 3:** Clear reminders in batch:

```
bulk_update(updates=[
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
search_conversations(tags=["campaign-q1"], my_turn=true, compact=true)
```

**Step 2:** Set reminders with campaign context in `ai_notes`:

```
bulk_update(updates=[
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
2. get_stats()                           --> See stage counts
3. For each stage with my_turn conversations:
   search_conversations(stage="<stage>", my_turn=true, compact=true)
4. Apply cadence table defaults:
   bulk_update(updates=[...])               --> Batch per stage
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
- `bulk_update` supports the `reminder` field (max 100 per call). Split larger batches.
- `bulk_update` does NOT support `draft_message`. That requires individual `update_conversation` calls.
- To find overdue conversations, use `search_conversations(my_turn=true)` and analyze `last_message_at` dates. There is no direct "overdue reminders" filter.
- Always include `ai_notes` explaining why a reminder was set or cleared.
- Use `compact=true` on `search_conversations` when only collecting IDs for batch operations.
- Handle `has_more` pagination on all `search_conversations` results.
- Do not set reminders on won deals or conversations where it is their turn to reply.
- When clearing, preserve reminders on `later`-archived conversations with intentional check-back dates.
- Default to the stage cadence table. Adjust if the user specifies custom intervals.
- Process stages in priority order: closing > discovery > qualified > chatting > opening.

## Power-Ups (Optional)

See [POWER-UPS.md](../../../POWER-UPS.md) for full setup.

- **Cron:** `/schedule daily 6pm reminder-engine "what's overdue"` — end-of-day audit catches conversations slipping through.
- **Programmatic:** SDK script can run the overdue audit on cron from a server you control if you want it independent of your local Claude Code session.

## Related Skills

- **batch-drafting** -- Draft messages at scale for conversations with reminders set
- **dm-writing** -- Individual message guidance for specific DM situations
- **full-morning-triage** -- Sets reminders as part of daily pipeline processing
- **cold-rescue** -- Re-engagement with drafts and reminders for cold conversations
- **pipeline-cleanup** -- Archive stale conversations and clear associated reminders
- **pipeline-health-check** -- Diagnose follow-up gaps and pipeline bottlenecks
