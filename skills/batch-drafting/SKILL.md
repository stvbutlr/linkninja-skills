---
name: batch-drafting
description: >
  Draft personalized messages for multiple conversations in a single session —
  follow-ups for a stage, re-engagement for cold leads, campaign follow-ups, or all
  pending replies. Use when the user says "draft messages for", "batch draft",
  "draft follow-ups for everyone", "process my pipeline", "draft for all my qualified
  leads", "write messages for my cold conversations", or "draft campaign follow-ups".
  Reads each conversation, crafts a personalized response, saves all drafts in one
  bulk call. Related: dm-writing for individual message guidance per situation,
  full-morning-triage for complete pipeline processing, cold-rescue for targeted
  re-engagement, campaign-launch for outreach campaign setup.
metadata:
  version: "1.0"
  author: linkninja
---

# Batch Drafting

Draft personalized messages for 5, 20, or 100 conversations in one session. Read each thread, craft a response matched to the situation, save all drafts in a single bulk call. The user reviews and sends from their dashboard.

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
search(stage="qualified", my_turn=true, compact=true)
```

If `has_more` is true, fetch the next page:

```
search(stage="qualified", my_turn=true, compact=true, page=2)
```

**Step 2:** For each conversation:

```
fetch(id="<conversation_id>")
```

Read the full thread. Determine the DM situation (see **dm-writing**). Draft a personalized response.

**Step 3:** Save all drafts:

```
bulk_classify(updates=[
  {id: "<id1>", draft_message: "Hey Sarah, ...", ai_notes: "Replied to pricing question. Reframed around ROI. Next: wait for budget confirmation."},
  {id: "<id2>", draft_message: "Hey James, ...", ai_notes: "Acknowledged timeline concern. Proposed 30-min call. Next: confirm time."},
  ...
])
```

### Pattern 2: Draft Re-Engagement for Cold

"Draft follow-ups for everyone going cold."

**Step 1:**

```
search(freshness="cold", my_turn=true, compact=true)
```

**Step 2:** For each, `fetch(id)` and read the thread.

**Step 3:** Draft value-add follow-ups — never "just checking in." Use the escalation cadence:

| Follow-Up # | Approach | Reminder |
|-------------|----------|----------|
| 1st | Insight or result tied to something they mentioned | `in 3 days` |
| 2nd | Different angle — new question or industry observation | `in 7 days` |
| 3rd | Door-open: "No worries if timing's off..." | `in 30 days` |

**Step 4:**

```
bulk_classify(updates=[
  {id: "<id1>", draft_message: "Hey Sarah, ...", reminder: "in 3 days", ai_notes: "Re-engagement #1. Shared insight about [topic]. Last discussed: [what]."},
  {id: "<id2>", draft_message: "Hey James, ...", reminder: "in 7 days", ai_notes: "Re-engagement #2. New angle: [what]. Previous follow-up was [date]."},
  ...
])
```

### Pattern 3: Draft Campaign Follow-Ups

"Draft follow-ups for my Q1 campaign."

**Step 1:**

```
search(tags=["campaign-q1"], my_turn=true, compact=true)
```

**Step 2:** For each, `fetch(id)` and read the thread.

**Step 3:** Draft responses that reference the campaign context while staying personalized to each conversation.

**Step 4:**

```
bulk_classify(updates=[
  {id: "<id1>", draft_message: "...", ai_notes: "Campaign Q1 follow-up. Referenced [their specific situation]. Stage: [current]."},
  ...
])
```

### Pattern 4: Draft for All Pending

"Draft messages for everyone waiting on me."

**Step 1:**

```
search(my_turn=true, compact=true)
```

**Step 2:** Process in priority order:

| Priority | Filter | Why |
|----------|--------|-----|
| 1 | `stage="qualified"` or `stage="discovery"` or `stage="closing"` | Highest conversion, fastest decay |
| 2 | `freshness="fresh"` | Engaged right now |
| 3 | `freshness="cold"` | Slipping away |
| 4 | Remaining `my_turn=true` | Everything else |

For each, `fetch(id)` and draft based on the DM situation.

**Step 3:** Save all at once:

```
bulk_classify(updates=[...all drafts...])
```

### Pattern 5: Draft by Freshness + Stage Combination

"Draft re-engagement for qualified leads who ghosted."

```
search(freshness="they_ghosted", stage="qualified", compact=true)
```

"Draft responses for fresh conversations in chatting stage."

```
search(freshness="fresh", stage="chatting", my_turn=true, compact=true)
```

Apply the appropriate DM situation from **dm-writing** for each.

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

| Conversations | Approach |
|--------------|----------|
| 1-5 | Process individually with `update_conversation` |
| 6-100 | Batch with `bulk_classify` (one call) |
| 101-200 | Split into two `bulk_classify` calls |
| 200+ | Consider filtering to highest-priority segment first |

**Pagination:** If `search` returns `has_more: true`, fetch the next page before starting drafts:

```
search(stage="qualified", my_turn=true, compact=true, page=2)
```

**Batch limits:** `bulk_classify` accepts max 100 updates per call. If you have 150 conversations, split into two calls of 75 each.

## Workflow Summary

```
1. get_context()                              → Load ICP + voice
2. search(filter, compact=true)               → Find conversations
   └─ Handle has_more pagination
3. fetch(id) for each                         → Read full threads
4. Draft personalized message per situation   → Apply dm-writing rules
5. bulk_classify(updates=[...])               → Save all drafts + ai_notes
   └─ Split if > 100
6. Report to user                             → Count of drafts saved
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
- Use `compact=true` on `search` to save bandwidth when only IDs are needed.
- Always include `ai_notes` with every draft. Explain reasoning so the user can evaluate.
- Never pretend to send messages. Save drafts only.
- Match the user's voice profile. Neutral professional if none exists.
- For cold/ghost conversations, always attach a reminder with the draft.
- If a conversation is ambiguous or needs user judgment, flag it in the report instead of drafting.
- One draft per conversation. A new draft overwrites the previous one.

## Related Skills

- **dm-writing** — Detailed guidance for each of the 7 DM situations
- **full-morning-triage** — Complete daily pipeline processing with auto-drafting
- **cold-rescue** — Targeted re-engagement for ghosted conversations
- **campaign-launch** — Set up and launch a targeted outreach campaign
- **voice-profile-setup** — Configure voice matching for better draft quality
