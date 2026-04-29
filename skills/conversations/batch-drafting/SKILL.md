---
name: batch-drafting
description: >
  Draft personalized messages for multiple conversations in a single session —
  follow-ups for a stage, re-engagement for cold leads, campaign follow-ups, or all
  pending replies. Use when the user says "draft messages for", "batch draft",
  "draft follow-ups for everyone", "process my pipeline", "draft for all my qualified
  leads", "write messages for my cold conversations", or "draft campaign follow-ups".
  Reads each conversation, crafts a personalized response, saves each draft via
  update_conversation. Related: dm-writing for individual message guidance per situation,
  full-morning-triage for complete pipeline processing, cold-rescue for targeted
  re-engagement, campaign-launch for outreach campaign setup.
metadata:
  version: "1.0"
  author: linkninja
---

# Batch Drafting

Draft personalized messages for 5, 20, or 100 conversations in one session. Read each thread, craft a response matched to the situation, save each draft via `update_conversation`. The user reviews and sends from their dashboard.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | "I need your ICP to draft relevant messages. Want to set that up?" Run **icp-definition** |
| Voice Profile (`voice_profile`) | Recommended | Draft in neutral professional tone. Mention: "Your drafts will be better with a voice profile set up." |
| Positioning (`positioning_context`) | Recommended | Proceed — but positioning context helps with value props in messages |
| Personal Story (`personal_story`) | Optional | Proceed without — use for credibility references when available |

3. Determine what the user wants drafted. If they don't specify, ask: "Which conversations should I draft for? Options: all pending replies, a specific stage, cold conversations, or a campaign tag."

## Batch Patterns

### Pattern 1: Draft for a Stage

"Draft follow-ups for all my qualified leads where it's my turn."

**Step 1:** Find conversations:

```
search_conversations(stage="qualified", my_turn=true, compact=true)
```

If `has_more` is true, fetch the next page:

```
search_conversations(stage="qualified", my_turn=true, compact=true, page=2)
```

**Step 2:** For each conversation:

```
get_conversation(id="<conversation_id>")
```

Read the full thread. Determine the DM situation and apply the right skill: **cold-outreach** for first messages, **reply-handling** for replies and qualifying, **objection-handling** for pushback, **call-booking** for qualified prospects. Draft a personalized response.

**Step 3:** Save each draft individually (draft messages must be saved one at a time via `update_conversation`):

```
update_conversation(id="<id1>", draft_message="Hey Sarah, ...", ai_notes="Replied to pricing question. Reframed around ROI. Next: wait for budget confirmation.")
update_conversation(id="<id2>", draft_message="Hey James, ...", ai_notes="Acknowledged timeline concern. Proposed 30-min call. Next: confirm time.")
// ...repeat for each conversation
```

### Pattern 2: Draft Re-Engagement for Cold

"Draft follow-ups for everyone going cold."

**Step 1:**

```
search_conversations(freshness="cold", my_turn=true, compact=true)
```

**Step 2:** For each, `get_conversation(id)` and read the thread.

**Step 3:** Draft value-add follow-ups — never "just checking in." Use the escalation cadence:

| Follow-Up # | Approach | Reminder |
|-------------|----------|----------|
| 1st | Insight or result tied to something they mentioned | `in 3 days` |
| 2nd | Different angle — new question or industry observation | `in 7 days` |
| 3rd | Door-open: "No worries if timing's off..." | `in 30 days` |

**Step 4:** Save each draft individually, then batch the reminders:

```
// Save drafts one at a time
update_conversation(id="<id1>", draft_message="Hey Sarah, ...", ai_notes="Re-engagement #1. Shared insight about [topic]. Last discussed: [what].")
update_conversation(id="<id2>", draft_message="Hey James, ...", ai_notes="Re-engagement #2. New angle: [what]. Previous follow-up was [date].")
// ...repeat for each

// Batch reminders
bulk_update(updates=[
  {id: "<id1>", reminder: "in 3 days"},
  {id: "<id2>", reminder: "in 7 days"},
  ...
])
```

### Pattern 3: Draft Campaign Follow-Ups

"Draft follow-ups for my Q1 campaign."

**Step 1:**

```
search_conversations(tags=["campaign-q1"], my_turn=true, compact=true)
```

**Step 2:** For each, `get_conversation(id)` and read the thread.

**Step 3:** Draft responses that reference the campaign context while staying personalized to each conversation.

**Step 4:** Save each draft individually:

```
update_conversation(id="<id1>", draft_message="...", ai_notes="Campaign Q1 follow-up. Referenced [their specific situation]. Stage: [current].")
// ...repeat for each conversation
```

### Pattern 4: Draft for All Pending

"Draft messages for everyone waiting on me."

**Step 1:**

```
search_conversations(my_turn=true, compact=true)
```

**Step 2:** Process in priority order:

| Priority | Filter | Why |
|----------|--------|-----|
| 1 | `stage="qualified"` or `stage="discovery"` or `stage="closing"` | Highest conversion, fastest decay |
| 2 | `freshness="fresh"` | Engaged right now |
| 3 | `freshness="cold"` | Slipping away |
| 4 | Remaining `my_turn=true` | Everything else |

For each, `get_conversation(id)` and draft based on the DM situation.

**Step 3:** Save each draft individually:

```
update_conversation(id="<id1>", draft_message="...", ai_notes="...")
update_conversation(id="<id2>", draft_message="...", ai_notes="...")
// ...repeat for each conversation
```

### Pattern 5: Draft by Freshness + Stage Combination

"Draft re-engagement for qualified leads who ghosted."

```
search_conversations(freshness="they_ghosted", stage="qualified", compact=true)
```

"Draft responses for fresh conversations in chatting stage."

```
search_conversations(freshness="fresh", stage="chatting", my_turn=true, compact=true)
```

Apply the appropriate DM skill for each: **reply-handling** for active conversations, **objection-handling** for pushback, **call-booking** for qualified prospects.

## Drafting Rules

For every draft, follow these rules:

| Rule | Detail |
|------|--------|
| Never send | Save as `draft_message`. User reviews and sends from dashboard. |
| Always include `ai_notes` | Explain: signal responded to, draft purpose, expected next step |
| Match voice | Use `voice_profile` from context. If none, neutral professional. |
| One thing per message | Don't pitch + qualify + close in one DM |
| Reference something real | Mention something specific from the thread, not a generic opener |
| Keep it short | 2-4 sentences for most messages |
| Add value on follow-ups | Never "just checking in" — add an insight, result, or question |
| Set reminders | For cold rescue and ghost re-engagement, always set a follow-up reminder |

## Handling Scale

Draft messages must be saved individually via `update_conversation` because `bulk_update` does not support `draft_message`. Non-draft updates (stage, tags, reminders, archive) can still be batched.

| Conversations | Drafts | Non-Draft Updates |
|--------------|--------|-------------------|
| 1-5 | `update_conversation` per draft | `update_conversation` or `bulk_update` |
| 6-100 | `update_conversation` per draft | `bulk_update` (one call) |
| 101-200 | `update_conversation` per draft | Split into two `bulk_update` calls |
| 200+ | Filter to highest-priority segment first | Split into `bulk_update` calls of max 100 |

**Pagination:** If `search_conversations` returns `has_more: true`, fetch the next page before starting drafts:

```
search_conversations(stage="qualified", my_turn=true, compact=true, page=2)
```

**Batch limits:** `bulk_update` accepts max 100 updates per call (for non-draft fields). Drafts are always one at a time via `update_conversation`.

## Workflow Summary

```
1. get_context()                              → Load ICP + voice
2. search_conversations(filter, compact=true)               → Find conversations
   └─ Handle has_more pagination
3. get_conversation(id) for each                         → Read full threads
4. Draft personalized message per situation   → Apply dm-writing rules
5. update_conversation(id, draft_message,     → Save each draft individually
   ai_notes) for each conversation
6. bulk_update(updates=[...])               → Batch non-draft updates (reminders, tags, stage)
   └─ Split if > 100
7. Report to user                             → Count of drafts saved
```

## Report Template

After batch drafting is complete, deliver a summary:

> **Batch drafting complete.**
>
> - **N drafts** saved and ready to review in your dashboard
> - **Stages covered:** [list of stages processed]
> - **Reminders set:** M follow-up reminders for cold/ghost conversations
>
> **Hottest draft:** [name] in [stage] — [why this one matters most]
>
> **Next step:** Open your LinkNinja dashboard, review the AI drafts, edit if needed, and hit send.

## Guidelines

- Always process higher-value stages first (qualified > chatting > opening).
- Use `compact=true` on `search_conversations` to save bandwidth when only IDs are needed.
- Always include `ai_notes` with every draft. Explain reasoning so the user can evaluate.
- Never pretend to send messages. Save drafts only.
- Match the user's voice profile. Neutral professional if none exists.
- For cold/ghost conversations, always attach a reminder with the draft.
- If a conversation is ambiguous or needs user judgment, flag it in the report instead of drafting.
- One draft per conversation. A new draft overwrites the previous one.

## Related Skills

- **dm-writing** — Router that identifies the right DM skill per situation
- **cold-outreach** — First messages, cold DMs, post-event openers
- **reply-handling** — Handling replies, building rapport, qualifying
- **objection-handling** — Price, timing, trust, and fit objections
- **call-booking** — Booking discovery calls with qualified prospects
- **full-morning-triage** — Complete daily pipeline processing with auto-drafting
- **cold-rescue** — Targeted re-engagement for ghosted conversations
- **campaign-launch** — Set up and launch a targeted outreach campaign
- **voice-profile-setup** — Configure voice matching for better draft quality
