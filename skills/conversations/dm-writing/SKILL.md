---
name: dm-writing
description: >
  Router skill for DM writing. Identifies the conversation situation and dispatches
  to the right specialist skill. Use when the user says "help me write a DM", "draft
  a message", "what should I say", "reply to this conversation", or any general DM
  request. Routes to: cold-outreach (opening, value_add), reply-handling (follow_up),
  objection-handling (objection), call-booking (closing), cold-rescue (re-engagement).
  For batch processing, use batch-drafting directly.
metadata:
  version: "2.0"
  author: linkninja
  template_categories:
    - opening
    - follow_up
    - closing
    - nurture
    - objection
    - value_add
---

# DM Writing

Identify the right DM situation and route to the specialist skill. This skill is a decision tree, not a drafting skill — each situation has its own dedicated skill with deep expertise.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. If the user specifies a conversation, fetch it:

```
get_conversation(id="<conversation_id>")
```

3. If the user says "help with my replies" without specifying:

```
search_conversations(my_turn=true, freshness="fresh", compact=true)
```

## Situation Decision Tree

Read the conversation (or lack of one) and determine which skill to use:

```
Is there an existing conversation thread?
  NO → cold-outreach
       (opening, value_add)

  YES ↓
Did they raise an objection or concern?
  YES → objection-handling
        (objection)

  NO ↓
Did they go quiet (no reply for days)?
  YES → cold-rescue
        (nurture, value_add)

  NO ↓
Did they just reply?
  YES ↓

  Have they shown buying signals (need, budget, authority, timeline)?
    NO  → reply-handling — Phase 1: They Replied
          (follow_up)

    YES ↓
  Are they qualified and ready for a call?
    NO  → reply-handling — Phase 2: Qualifying
          (follow_up)

    YES → call-booking
          (closing)

Was there a recent event (webinar, workshop, session)?
  YES → cold-outreach — Post-Event Follow-Up
        (opening, value_add)
```

## Quick Reference

| Situation | Skill | App Template Category | Playbook Frameworks Embedded |
|-----------|-------|----------------------|------------------------------|
| First message, no conversation | **cold-outreach** | opening, value_add | Three Opening Rules, Precision Flattery, Pattern Interrupt, Preloaded Value |
| Post-event follow-up | **cold-outreach** | opening, value_add | Three Opening Rules, Precision Flattery |
| They replied, building rapport | **reply-handling** | follow_up | Trust Progression |
| Qualifying, finding the gap | **reply-handling** | follow_up | A–B Method, Question Sequence |
| They objected or hesitated | **objection-handling** | objection | Acknowledge → Ask Context → Reframe |
| They went quiet | **cold-rescue** | nurture, value_add | Day 1/3/7/extending cadence |
| Qualified, booking a call | **call-booking** | closing | Micro-commitments, 3-element invite |
| Multiple conversations at once | **batch-drafting** | all categories | All of the above (per-conversation) |

## The 8 Ground Rules

These apply to every DM, every situation. Full doctrine in `references/sell-by-chat-methodology.md`:

1. **One thing per message.** Don't pitch, qualify, AND close in one DM.
2. **Sound like you have a full calendar.** Inviting energy, not chasing energy.
3. **Ask before you tell.** 2-3 questions before suggesting anything.
4. **Use their words.** Mirror their vocabulary, not marketing jargon.
5. **Every follow-up adds value.** Never "just checking in."
6. **Always include an easy out.** "No pressure." "Totally fine if timing's off."
7. **Match the prospect's energy.** Short for short. Formal for formal.
8. **Persist with purpose.** Day 1 → Day 3 → Day 7 → extending intervals. 80% of sales close *after* the 5th touchpoint. Each follow-up must add new value — if you have nothing new to say, wait until you do.

## Guidelines

- This is a router skill. Identify the situation, then hand off to the appropriate specialist skill.
- Always save drafts via `draft_message`. Never pretend to send messages.
- Always include `ai_notes` explaining reasoning with every draft and classification.
- If the situation is ambiguous, ask the user for clarification before routing.

## Related Skills

- **cold-outreach** — First messages, cold DMs, post-event openers
- **reply-handling** — Handling replies, building rapport, qualifying
- **objection-handling** — Price, timing, trust, and fit objections
- **call-booking** — Booking discovery calls with qualified prospects
- **cold-rescue** — Re-engaging cold and ghosted conversations
- **batch-drafting** — Draft personalized messages for multiple conversations at once
- **voice-profile-setup** — Configure voice matching for natural-sounding drafts
