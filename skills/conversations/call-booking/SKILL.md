---
name: call-booking
description: >
  Book discovery calls and move qualified prospects to the next step — Micro-commitments,
  the 3-element invite, "why now" framing, post-confirmation follow-up. Use when the
  user says "book a call", "move to discovery", "schedule a meeting", "how to invite
  them to a call", "draft a call invite", "they're ready to chat — what now", or
  when a prospect's qualifying signals indicate readiness. Covers readiness
  assessment, low-friction time slots, day-before confirmations. Related:
  reply-handling for conversations still qualifying, objection-handling when they
  hesitate at the ask, cold-rescue if they go quiet after the invite.
metadata:
  version: "1.0"
  author: linkninja
  template_categories:
    - closing
---

# Call Booking

Book discovery calls and next steps with qualified prospects. The transition from DM to call should feel natural — a logical next step, not a sales pitch.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Fetch the conversation:

```
get_conversation(id="<conversation_id>")
```

3. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | Needed to confirm qualification. Must know what "qualified" looks like. |
| Positioning (`positioning_context`) | **Required (hard stop)** | If empty, **stop** and ask: *"What's the call going to deliver for them? I need this to frame the invite — without it the ask is just 'let's chat'."* Defines what the call delivers. |
| Voice Profile (`voice_profile`) | Recommended | The invite must sound like the user, not an AI. |
| Personal Story (`personal_story`) | Useful | Adds credibility to the invite. "I've helped teams like yours..." |

4. Review the conversation thread — confirm they're actually qualified before suggesting a call.

## Using Your Context

| Context Field | How It Shapes the Invite |
|--------------|-------------------------|
| **ICP** (`additional_context`) | Confirms qualification. The invite should reference their specific ICP pain: "Based on what you've shared about [ICP-specific challenge]..." |
| **Positioning** (`positioning_context`) | Defines what the call delivers. Not "a chat" — a specific thing: "I'll walk through the [framework/approach] that [result] for [similar company]." Frame using positioning language. |
| **Voice Profile** (`voice_profile`) | Controls tone of the invite. Casual users don't say "I'd like to propose a meeting." They say "Want to hop on a quick call?" Match natural style. |
| **Personal Story** (`personal_story`) | Adds weight to the invite. "I helped a [similar role] at a [similar company] with exactly this. 30 minutes — I'll show you the approach." Real credibility, not claims. |

## Readiness Signals

Before suggesting a call, confirm these signals are present in the conversation:

| Signal Category | What to Look For | Example |
|----------------|-----------------|---------|
| **Stated need** | They've named a specific problem | "We're losing 30% of new hires in the first 3 months" |
| **Cost awareness** | They understand what the problem costs them | "That's probably costing us six figures a year" |
| **Prior effort** | They've tried to fix it themselves | "We've been working on this internally but haven't cracked it" |
| **Timeline** | There's urgency or a deadline | "We need this sorted before Q3 hiring push" |
| **Buying signals** | Questions about how you work | "How does your process work?" "What would that look like?" |

### Not Ready Yet

If signals are missing, don't force the call. Go back to **reply-handling** for more qualifying:

| Missing Signal | What to Do |
|---------------|-----------|
| No stated need | Keep qualifying — ask what their biggest challenge is |
| No cost awareness | Help them see the gap between current and desired state |
| No timeline | Ask what would need to change for this to become a priority |
| General curiosity only | Build more trust — they're at an early checkpoint |

## The 3-Element Invite

The call invite is a **Micro-commitment** — a small step that builds emotional investment toward the larger ask. Frame it as low-effort. Three elements (from `references/sell-by-chat-methodology.md`):

### 1. Specific Next Step

Not "let's chat" — state exactly what happens on the call:

- "I'll walk through the framework that solved this for [similar company]"
- "30 minutes — I'll break down the approach and you can see if it fits"
- "Quick conversation to map out what this would look like for your team"

### 2. Reduce Friction

Make saying yes easy:

- Short time commitment: "30 minutes" or "20 minutes"
- Clear format: "a Zoom call" or "a phone call"
- Low stakes: "No pitch, just the approach" or "See if it makes sense"
- Skip calendar links — they add friction. Propose specific times instead.

### 3. Propose Specific Times

Don't ask for "availability" — offer 2-3 concrete options:

- "Does Thursday at 2pm or Friday at 10am work?"
- "I have time Tuesday afternoon or Wednesday morning — either work?"
- Propose times within 3 business days — interest fades quickly.

## "Why Now" Framing

When the prospect is qualified but hasn't moved toward a call yet, help them see why acting now matters. Use their own data — never manufacture urgency.

### Use Their Numbers

If they've shared data during qualifying, reference it:

- "You mentioned 70% of your discovery calls don't convert into engagements. At your current call volume, that's roughly [X] hours/month going into calls that don't pay back."
- "You said pipeline velocity dropped 40% this quarter. Every week that continues is [Y] in lost deals."

### Use Their Timeline

If they've mentioned a deadline or goal:

- "You need this sorted before the Q3 hiring push — that's 8 weeks out."
- "If the team restructure is happening in April, the framework needs to be in place 4-6 weeks before."

### Don't Manufacture Urgency

| Do | Don't |
|----|-------|
| Use their numbers and timeline | "Spots are filling up fast" |
| Reference their stated goals | "Price goes up next week" |
| Show compounding cost of waiting | "You'll regret not doing this" |
| Acknowledge if timing is genuinely bad | "Everyone else is doing this" |

## After They Confirm

Two things to do when they agree to a call:

### 1. Day-Before Message

Send a brief confirmation the day before:

> Looking forward to tomorrow -- I pulled some things specific to your situation at [company].

This does three things: reduces no-shows, builds anticipation, shows preparation.

### 2. Set Reminder

```
update_conversation(
  id="<id>",
  reminder="<day before call at 9am>"
)
```

## Good Example

> Based on what you've shared, I think a quick conversation would be worth it. 30 minutes -- I'll walk through the framework that solved this for [similar company], and you can see if it fits your situation.
>
> No pitch, just the actual approach. Does Thursday at 2pm work?

**Why it works:** Ties to their specific problem. States exactly what they get. Clear format (30 min, framework review). Low pressure ("see if it fits"). Specific time proposed.

## Bad Examples

> Great! Let me send you my Calendly link and you can pick a time that works!

**Why it fails:** Calendar links add friction. No context about what the call covers. No connection to their problem.

> I'd love to hop on a quick call to tell you more about how we can help!

**Why it fails:** Self-focused ("I'd love"). Vague ("tell you more"). No specific value. No proposed time.

## Draft Template

```
update_conversation(
  id="<id>",
  stage="discovery",
  draft_message="Based on what you've shared about [their specific challenge], [specific value of the call]. [Format + time commitment]. [What they'll get -- tied to positioning]. Does [specific day and time] work?",
  ai_notes="Moving to discovery. Readiness signals: [need, cost, effort, timeline]. Call: [format/duration]. Key topic: [their problem]. Proposed: [date/time]. Context used: [positioning for call value, personal story for credibility].",
  reminder="<day before call at 9am>"
)
```

Day-before confirmation:

```
update_conversation(
  id="<id>",
  draft_message="Looking forward to tomorrow -- I pulled some things specific to your situation at [company].",
  ai_notes="Day-before call confirmation. Call: [time]. Reduces no-show risk."
)
```

## Guidelines

- Before drafting, call `get_draft_prompt(id, reply_intent="advance")` first — it returns server-rendered voice-enforced context tuned for advancing toward a call. Save via `update_conversation`.
- Always save drafts via `draft_message`. Never pretend to send messages.
- Always include `ai_notes` explaining: readiness signals present, what the call covers, how positioning/personal story shaped the invite.
- One draft per conversation. A new draft overwrites the previous one.
- Match the user's voice profile for the invite tone.
- Never suggest a call before qualification is confirmed. If signals are missing, go back to **reply-handling**.
- Propose specific times within 3 business days.
- Skip calendar links — they add friction.
- If they hesitate at the call invite, transition to **objection-handling**.

## Related Skills

- **reply-handling** — When they need more qualifying before a call
- **objection-handling** — When they hesitate or push back on the call invite
- **batch-drafting** — Draft call invites for multiple qualified prospects
- **full-morning-triage** — Identifies qualified conversations ready for call booking
- **voice-profile-setup** — Natural-sounding invites that match the user's style
