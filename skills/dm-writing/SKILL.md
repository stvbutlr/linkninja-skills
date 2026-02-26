---
name: dm-writing
description: >
  Craft the right LinkedIn DM for any conversation situation — cold outreach, replies,
  qualifying, objections, silence, booking calls, and post-event follow-up. Use when the
  user says "help me write a DM", "draft a message", "what should I say to", "reply to
  this conversation", "write a follow-up", "handle this objection", or "how do I respond".
  Identifies the situation from conversation context and drafts accordingly. Related:
  batch-drafting for processing multiple conversations at once, voice-profile-setup for
  configuring tone matching, full-morning-triage for daily pipeline processing,
  cold-rescue for targeted re-engagement of ghosted conversations.
metadata:
  version: "1.0"
  author: linkninja
---

# DM Writing

Craft the right message for any situation in a LinkedIn sales pipeline. Identify the situation, follow the principles, draft the message, save it for user review.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | "I need your ICP to draft relevant messages. Want to set that up?" Run **icp-definition** |
| Voice Profile (`voice_profile`) | Recommended | Draft in neutral professional tone. Suggest **voice-profile-setup** after. |
| Positioning (`positioning_context`) | Recommended | "What do you sell? It helps me position the message correctly." |
| Personal Story (`personal_story`) | Optional | Proceed without — use for credibility when available |

3. If the user specifies a conversation, fetch it:

```
fetch(id="<conversation_id>")
```

4. If the user says "help with my replies" without specifying, find what needs attention:

```
search(my_turn=true, freshness="fresh")
```

## Situation Decision Tree

Read the conversation and determine which situation applies:

```
Is there an existing conversation thread?
  NO → Situation 1: Cold Outreach

  YES ↓
Did they raise an objection or concern?
  YES → Situation 4: Handling Objections

  NO ↓
Did they go quiet (no reply for days)?
  YES → Situation 5: Going Quiet

  NO ↓
Did they just reply?
  YES ↓

  Have they shown buying signals (need, budget, authority, timeline)?
    NO  → Situation 2: They Replied (build rapport)
    YES ↓

  Are they ready for a call or next step?
    NO  → Situation 3: Qualifying
    YES → Situation 6: Ready for Call

Was there a recent event (webinar, workshop, session)?
  YES → Situation 7: Post-Event Follow-Up
```

## The 8 Ground Rules

These apply to every DM, every situation:

1. **One thing per message.** Don't pitch, qualify, AND close in one DM.
2. **Sound like you have a full calendar.** Inviting energy, not chasing energy.
3. **Ask before you tell.** 2-3 questions before suggesting anything.
4. **Use their words.** Mirror their vocabulary, not marketing jargon.
5. **Every follow-up adds value.** Never "just checking in."
6. **Always include an easy out.** "No pressure." "Totally fine if timing's off."
7. **Replace "but" with "and."** Keeps the door open instead of negating.
8. **Keep it short.** 2-4 sentences for most messages.

## Situation 1: Cold Outreach

**When:** Opening stage. First message. No reply yet.

**Goal:** Get a reply. Not a sale. Not a call. A reply.

**Find prospects:**

```
scan_connections(headline_keywords=["<target_role>"], has_conversation=false)
```

**Draft structure:**
- Be specific to their world (headline, company, recent event)
- Offer something immediately useful (insight, framework, relevant question)
- Ask permission, don't assume interest

**Save draft:**

```
update_conversation(id="<id>", draft_message="<the message>", ai_notes="Cold outreach. Referenced [specific detail]. Offered [value]. Goal: get a reply.", reminder="in 3 days")
```

See `references/situations.md` for full examples.

## Situation 2: They Replied

**When:** Chatting stage. They responded. Conversation is live.

**Goal:** Build rapport and understand their world. Do not pitch.

**Three steps:**
1. Acknowledge what they said — show you read it
2. Ask a specific question about their world — not generic "tell me more"
3. Don't pitch yet — the conversation needs to breathe

**Save draft:**

```
update_conversation(id="<id>", draft_message="<the message>", ai_notes="Acknowledged their reply about [topic]. Asked deepening question about [specific thing]. Stage: chatting.")
```

See `references/situations.md` for full examples.

## Situation 3: Qualifying

**When:** Chatting, moving toward qualified. Had a few exchanges. Need to determine fit.

**Goal:** Find the gap between where they are now and where they want to be.

**Question sequence:**
1. **Start easy** — broad questions that let them share without overthinking
2. **Go deeper** — specifics about their challenges
3. **Surface the gap** — help them see the distance between current state and desired state
4. **Check commitment** — "Is fixing this something you're actively working on?"

If they confirm a real need + timeline or urgency = qualified.

**Save draft:**

```
update_conversation(id="<id>", draft_message="<the message>", ai_notes="Qualification status: [qualified/not yet]. Key gap: [current state] vs [desired state]. Next: [what to do next].")
```

If they qualify:

```
update_conversation(id="<id>", stage="qualified", draft_message="<the message>", ai_notes="Qualified. [Need] + [timeline/urgency]. Next: [offer framework/call].")
```

See `references/situations.md` for full examples.

## Situation 4: Handling Objections

**When:** Any stage. They pushed back, hesitated, or raised a concern.

**Goal:** Make them feel more safe, not less. Find what's behind the stated objection.

**The pattern:**
1. **Acknowledge** — validate their concern
2. **Ask what's behind it** — the stated objection is rarely the real one
3. **Address the real concern** — with specifics, not generalities
4. **Give an easy out** — they should feel MORE safe after your reply

| What They Say | What's Behind It | What to Do |
|---------------|-----------------|------------|
| "I'll think about it" | Risk > perceived value | Reduce risk: smaller next step, relevant result, ask what they'd think about |
| "Too expensive" | Value isn't clear | Reframe: cost of the problem vs. cost of the solution |
| "Bad timing" / "I'm busy" | Don't feel cost of waiting | Make inaction tangible: "What happens if X is the same in 6 months?" |
| "Tried this before" | Got burned, low trust | Validate, then differentiate with specifics |
| "Not sure it's for me" | Can't see themselves in it | Share example from their exact situation |
| "Send me more info" | Interested, not committed | Send ONE specific relevant thing, follow up on it |

**Save draft:**

```
update_conversation(id="<id>", draft_message="<the message>", ai_notes="Objection type: [price/timing/trust/fit]. Underlying concern: [what's really going on]. Addressed with: [approach].")
```

See `references/objection-handling.md` for detailed examples and the full objection library.

## Situation 5: Going Quiet

**When:** Any stage. They stopped replying.

**Goal:** Re-engage with value. Not chase.

**Timing cadence:**

| Days Silent | What to Send | Reminder |
|-------------|-------------|----------|
| ~3 days | Value-add tied to something they mentioned | `in 3 days` |
| ~7 days | Different angle — new question or industry observation | `in 7 days` |
| ~14 days | Door-open: "No worries if timing's off. Thought of you when..." | `in 30 days` |
| 14+ days, 2+ attempts | Archive as `ghosted` or set monthly reminder | — |

**Never send:** "Just checking in," "bumping this," "did you see my last message?"

**Save draft:**

```
update_conversation(id="<id>", draft_message="<the message>", reminder="in 3 days", ai_notes: "Re-engagement attempt [1st/2nd/3rd]. Value added: [what you sent].")
```

See `references/situations.md` for full examples.

## Situation 6: Ready for Call

**When:** Qualified stage, moving to discovery. Real interest confirmed.

**Goal:** Book a specific next step that feels natural, not salesy.

**Three things to get right:**
1. **Specific next step** — exact format, time commitment, what they'll get
2. **Reduce friction** — short, easy, low-pressure
3. **Propose a specific time** — don't ask for "availability," offer 2-3 times

**Pro tips:**
- Propose times within 3 business days (interest fades)
- Skip calendar links (adds friction)
- After they confirm: send a "looking forward to tomorrow" message the day before

**Save draft:**

```
update_conversation(id="<id>", stage="discovery", draft_message="<the message>", ai_notes="Moving to discovery. Call invite for [format/duration]. Key topic: [what they care about].", reminder="<day before call>")
```

See `references/situations.md` for full examples.

## Situation 7: Post-Event Follow-Up

**When:** After a webinar, workshop, session, or event they attended.

**Goal:** Convert event attendance into a conversation.

**Draft structure:**
- Reference the specific event and something that stood out
- Connect it to their situation
- Ask a question — don't pitch

**Save draft:**

```
update_conversation(id="<id>", draft_message="<the message>", ai_notes="Post-event follow-up. Event: [name]. Referenced [specific moment]. Goal: start a conversation.", reminder="in 3 days")
```

See `references/situations.md` for full examples.

## Voice Matching

When drafting, always check the user's `voice_profile` from `get_context()`. Match:
- **Greeting style** — "Hey" vs "Hi" vs first name only
- **Formality level** — casual vs professional vs somewhere between
- **Sentence length** — short and punchy vs longer and conversational
- **Vocabulary** — technical terms they use, industry jargon they prefer
- **Sign-off style** — how they typically end messages

If no voice profile exists, draft in a neutral professional tone and suggest running **voice-profile-setup**.

## Batch Mode

When drafting for multiple conversations at once, use the batch pattern:

1. `search(filter, compact=true)` — find conversations
2. `fetch(id)` each — read threads
3. Draft personalized responses per situation
4. `bulk_classify(updates=[...])` — save all drafts in one call (max 100)

See **batch-drafting** for the full batch workflow.

## Guidelines

- Always save drafts via `draft_message`. Never pretend to send messages.
- Always include `ai_notes` explaining: what signal you responded to, what the draft accomplishes, expected next step.
- One draft per conversation. A new draft overwrites the previous one.
- Match the user's voice profile. If none exists, use neutral professional tone.
- Keep messages to 2-4 short sentences for most situations.
- Reference something real from the conversation — generic messages get ignored.
- After 2 follow-ups with no reply, stop. Monthly nurture or archive.

## Related Skills

- **batch-drafting** — Process multiple conversations in one session
- **voice-profile-setup** — Configure voice matching for better drafts
- **full-morning-triage** — Daily pipeline processing with auto-drafting
- **cold-rescue** — Targeted re-engagement for ghosted conversations
- **icp-definition** — Set up targeting context for relevant messaging
