---
name: full-morning-triage
description: >
  Complete compound workflow that processes the entire LinkedIn pipeline in one
  session — hot replies, cold rescue, ghost recovery, classification, and archiving.
  Use when the user says "run my morning", "triage my pipeline", "what should I do
  today", "morning triage", "process my pipeline", or "daily routine". Produces draft
  messages, sets reminders, classifies conversations, and delivers a summary report.
  Related: dm-writing for individual message crafting, batch-drafting for focused
  draft sessions, pipeline-cleanup for dedicated archive passes, cold-rescue for
  targeted re-engagement.
metadata:
  version: "1.0"
  author: linkninja
---

# Full Morning Triage

Process the entire LinkedIn DM pipeline in a single compound workflow. Hot leads first, then cold rescue, ghost recovery, classification, and archiving. The user's only job after: open their dashboard, review drafts, and hit send.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | Stop. "I need your ICP configured before I can triage effectively. Want to set that up now?" Run **icp-definition** |
| Positioning (`positioning_context`) | Recommended | "What do you sell? Knowing this helps me draft better messages." |
| Voice Profile (`voice_profile`) | Recommended | Draft in a neutral professional tone. Suggest **voice-profile-setup** after. |
| Personal Story (`personal_story`) | Optional | Proceed without — use for credibility references when available |

3. If all required context exists, proceed to the workflow.

## Priority Order

Always work in this exact order. Higher priority = higher conversion impact and faster trust decay.

| Priority | Segment | Why First |
|----------|---------|-----------|
| 1 | Qualified leads waiting for reply | Highest conversion potential, fastest trust decay |
| 2 | Fresh replies (any stage) | Engaged right now — momentum matters |
| 3 | Discovery conversations going cold | High-value rescue — already deep in pipeline |
| 4 | Cold chatting conversations | Lower value but saveable with the right follow-up |
| 5 | Ghost recovery (they ghosted, qualified+) | Worth re-engagement because buying signals existed |
| 6 | Ghost recovery (they ghosted, chatting) | Lower priority but still worth a value-add attempt |
| 7 | Unclassified conversations | Pipeline hygiene — need sorting |

## Workflow

### Phase 1: Pipeline Snapshot

```
get_stats()
```

Capture and note:
- `my_turn` counts by stage — people waiting on the user
- Cold and ghosted counts — conversations slipping away
- Stage distribution — is the pipeline balanced or top-heavy?
- Total active count — enough volume?

**Quick diagnosis:**

| Signal | Meaning | Action |
|--------|---------|--------|
| High `my_turn` in qualified/discovery | Hot leads are waiting | Phase 2 is critical today |
| High cold count | Conversations aging out | Phase 3 is critical today |
| Growing `you_ghosted` | User is the bottleneck | Flag this in the report |
| Everything in opening, nothing in qualified | Pipeline not progressing | Note in report, suggest reviewing qualifying approach |
| Low total conversations | Not enough volume | Suggest outreach after triage |

### Phase 2: Hot Leads — Draft Responses

Find fresh conversations where it's the user's turn, starting with highest-value stages:

```
search_conversations(my_turn=true, freshness="fresh", stage="qualified")
```

```
search_conversations(my_turn=true, freshness="fresh", stage="discovery")
```

```
search_conversations(my_turn=true, freshness="fresh", stage="closing")
```

```
search_conversations(my_turn=true, freshness="fresh")
```

For each conversation returned:

```
get_conversation(id="<conversation_id>")
```

Read the full thread. Identify the situation and apply the right DM skill: **reply-handling** for active replies and qualifying, **objection-handling** for pushback, **call-booking** for qualified prospects ready for a call, **cold-outreach** for first messages. Draft a personalized response following the playbook (`references/sell-by-chat-methodology.md`):
- One thing per message
- Match the prospect's energy and vocabulary
- Ask before telling
- Reference something real from the conversation
- Keep it short (2-4 sentences)

Save each draft individually (`bulk_update` does not support `draft_message`):

```
update_conversation(id="<id1>", draft_message="Hey Sarah, ...", ai_notes="Replied to her pricing question. Reframed around ROI. Next: wait for budget confirmation.")
update_conversation(id="<id2>", draft_message="Hey James, ...", ai_notes="Acknowledged interest, asked qualifying question about timeline.")
// ...repeat for each conversation
```

Track count: **N hot lead drafts saved.**

### Phase 3: Cold Rescue — Value-Add Follow-Ups

```
search_conversations(freshness="cold", my_turn=true, compact=true)
```

For each, `get_conversation(id)` and read the thread. Draft a value-add follow-up — never "just checking in." Options:
- A relevant insight or result from a similar situation
- An article or resource connected to something they mentioned
- A specific question about something they told the user earlier

Save each draft individually, then batch the reminders:

```
// Save drafts one at a time
update_conversation(id="<id1>", draft_message="Hey [name], ...", ai_notes="Re-engagement: shared insight about [topic they mentioned]. This is follow-up attempt #[N].")
// ...repeat for each

// Batch reminders
bulk_update(updates=[
  {id: "<id1>", reminder: "in 3 days"},
  ...
])
```

Track count: **M cold rescue drafts saved, M reminders set.**

### Phase 4: Ghost Recovery

**High-value ghosts first** — qualified/discovery conversations where they stopped replying:

```
search_conversations(freshness="they_ghosted", stage="qualified", compact=true)
```

```
search_conversations(freshness="they_ghosted", stage="discovery", compact=true)
```

For each, `get_conversation(id)` and read the thread. These are worth more effort because buying signals existed. Draft a re-engagement message with new value.

**Then chatting-stage ghosts:**

```
search_conversations(freshness="they_ghosted", stage="chatting", compact=true)
```

**Decision rules for ghosts:**

| Condition | Action |
|-----------|--------|
| Qualified+ ghost, < 14 days silent | Draft re-engagement with new value angle |
| Qualified+ ghost, 14+ days silent | Draft door-open message + reminder for 30 days |
| Chatting ghost, < 14 days silent | Draft value-add follow-up |
| Opening ghost, 14+ days, 2+ follow-ups | Archive as `ghosted` |
| Any stage, clearly not ICP | Archive as `not_a_fit` |

Save drafts individually, then batch archives and reminders:

```
// Save re-engagement drafts one at a time
update_conversation(id="<id1>", draft_message="...", ai_notes="Re-engagement attempt #2. Shared different angle.")
// ...repeat for each draft

// Batch archives and reminders (no draft_message)
bulk_update(updates=[
  {id: "<id1>", reminder: "in 7 days"},
  {id: "<id2>", archive: {archived: true, reason: "ghosted"}, ai_notes: "No reply after 3 follow-ups over 4 weeks. Archiving."},
  ...
])
```

Track counts: **P re-engagement drafts, Q archives.**

### Phase 5: Classify New Conversations

```
export_conversations(unclassified_only=true, include_messages=true)
```

If `has_more` is true, fetch the next page:

```
export_conversations(unclassified_only=true, include_messages=true, page=2)
```

For each unclassified conversation, read the thread and determine:
- **Stage** — use the stage classification decision tree (see pipeline-stages reference)
- **Tags** — apply based on evidence, not assumption (see signal-mapping reference)
- **Summary** — one sentence capturing where the conversation stands

Archive obvious not-a-fits immediately.

```
bulk_update(updates=[
  {id: "<id>", stage: "chatting", tags: [], summary: "Early rapport. They asked about your work.", ai_notes: "No buying signals. General conversation."},
  {id: "<id>", stage: "qualified", tags: ["decision_maker"], summary: "VP Sales, explicit need for onboarding tool.", ai_notes: "Stated problem and timeline."},
  {id: "<id>", archive: {archived: true, reason: "not_a_fit"}, ai_notes: "Selling SEO services. Not a prospect."},
  ...
])
```

Track counts: **R classified, S archived as not-a-fit.**

### Phase 6: Report

Deliver a summary to the user:

> **Morning triage complete.**
>
> **Pipeline snapshot:** X opening, Y chatting, Z qualified, W discovery, V closing
>
> **Actions taken:**
> - **N draft responses** ready to review (hot leads)
> - **M cold rescue drafts** with follow-up reminders
> - **P re-engagement drafts** for ghosted conversations
> - **R conversations classified** (S archived as not-a-fit)
> - **Q conversations archived** (ghosted/stale)
>
> **Hottest lead:** [name] in [stage] — [why they're hot]
>
> **Attention needed:** [any conversations requiring special handling]
>
> **Next step:** Open your LinkNinja dashboard, review the AI drafts, and hit send.

For the full 12-step workflow with all tool calls, see `references/triage-workflow-detail.md`.

## Guidelines

- Always process in priority order. Do not skip to classification before handling hot leads.
- Use `compact=true` on `search_conversations` when only collecting IDs for batch operations.
- Stay under `bulk_update` limits: max 100 updates per call. Split larger batches.
- Handle `has_more` pagination on `search_conversations` and `export_conversations` results.
- Always include `ai_notes` with every draft and classification.
- Never pretend to send messages. All drafts are saved for user review.
- Match the user's voice profile when drafting. If no voice profile exists, use a neutral professional tone.
- If the pipeline has 50+ unclassified conversations, consider `start_batch_classify()` instead of manual classification.
- Flag any conversations that need the user's judgment (ambiguous stage, unusual situation) in the report.

## Related Skills

- **dm-writing** — Router that identifies the right DM skill per situation
- **cold-outreach** — First messages and post-event openers
- **reply-handling** — Handling replies, building rapport, qualifying
- **objection-handling** — Price, timing, trust, and fit objections
- **call-booking** — Booking discovery calls with qualified prospects
- **batch-drafting** — Focused batch draft sessions for a specific segment
- **pipeline-cleanup** — Dedicated archiving and hygiene pass
- **cold-rescue** — Targeted re-engagement workflow
- **pipeline-health-check** — Deep pipeline analysis with conversion metrics
