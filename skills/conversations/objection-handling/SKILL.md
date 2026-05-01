---
name: objection-handling
description: >
  Handle objections and concerns in DM conversations — Acknowledge → Ask Context
  → Reframe, plus the "never use 'but'" rule. Use when the user says "handle this
  objection", "they said too expensive", "they're hesitating", "how to respond
  to pushback", "they're thinking about it", "draft a reply to this objection",
  or when a prospect raises price, timing, trust, or fit concerns. Covers 6
  objection types with the playbook pattern + easy-out close. Related:
  reply-handling for non-objection replies, call-booking once the objection is
  resolved, cold-rescue if they go silent after the objection.
metadata:
  version: "1.0"
  author: linkninja
  template_categories:
    - objection
---

# Objection Handling

Handle objections and concerns in LinkedIn DM conversations. An objection is not a rejection — it's a signal that something feels unsafe. Your job: find what's behind it and make them feel more safe, not less.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Fetch the conversation:

```
get_conversation(id="<conversation_id>")
```

3. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | Needed to reframe value in their terms. Run **icp-definition** if empty. |
| Positioning (`positioning_context`) | **Required (hard stop)** | If empty, **stop** and ask: *"What are you offering? I need this to reframe price / fit / timing objections — without it the response is generic acknowledgment with no real reframe."* |
| Voice Profile (`voice_profile`) | Recommended | Objections require maintaining safety. Wrong tone kills trust. |
| Personal Story (`personal_story`) | Useful | Addresses "tried before" — real examples of what you did differently. |

4. Read the full thread — objection context matters. What stage is the conversation in? What has been discussed? What prompted the objection?

## Using Your Context

| Context Field | How It Shapes the Response |
|--------------|---------------------------|
| **ICP** (`additional_context`) | Reframes value in their specific terms. "For teams like yours at [company stage], the cost of [their problem] is usually [X]." If they're outside ICP, the objection might be valid — flag it. |
| **Positioning** (`positioning_context`) | Addresses "too expensive" by connecting price to what they get. "The framework we use specifically targets [their problem] — here's how it worked for [similar company]." Never pitch — reframe. |
| **Voice Profile** (`voice_profile`) | Critical for objections. Maintain safety through consistent tone. If the user is casual, stay casual. Don't escalate formality when they push back — it feels like pressure. |
| **Personal Story** (`personal_story`) | Best weapon for "tried before." "I worked with a [similar role] at a [similar company] who had the same experience. The difference was [specific thing]." Real > theoretical. |

## The Pattern: Acknowledge → Ask Context → Reframe

The playbook's 3-step pattern for every objection (from `references/sell-by-chat-methodology.md`):

1. **Acknowledge.** Validate the concern fully, don't dismiss it. *"That makes sense — timing is tricky."*
2. **Ask Context.** What's behind the stated objection? *"What would need to change for this to feel right?"* The stated objection is rarely the real one.
3. **Reframe.** Position your solution against the underlying concern, with specifics from their world.

Plus two non-negotiables:

- **Never use "but."** "But" negates everything before it. They'll hear the negation, not the acknowledgment. Use "and" or a paragraph break.
- **Always give an easy out.** They should feel *more* safe after your reply, not pressured. Make it easy to say no.

## Objection Library

### "I'll Think About It"

**What's behind it:** Risk outweighs perceived value. They don't feel safe enough yet.

**Do:** Reduce risk. Offer a smaller next step, share a relevant result, or ask what specifically they'd want to think about.

**Don't:** Push for urgency. Create false scarcity. Ask "what's holding you back?"

**Good:**

> Totally fair -- no rush at all. If it helps, the thing most people in your position want to know is whether this actually works for [their specific situation]. I can send you a quick breakdown of what we did for [similar company] -- takes 2 minutes to read. Would that help while you're thinking it over?

**Bad:**

> Sure! But honestly the spots are filling up fast and I'd hate for you to miss out. Can we just book a quick call to discuss?

### "Too Expensive" / "What Does It Cost?"

**What's behind it:** Value isn't clear yet. They need to see the outcome before the price makes sense.

**Do:** Reframe around the cost of the problem, not the cost of the solution. Use their own data.

**Don't:** Lead with the number. Offer discounts immediately. Get defensive.

**Good:**

> I get it -- it's an investment. Just curious though, you mentioned you're losing 30% of new hires in the first 3 months. At your scale, what does that cost in recruiting and training fees alone? Most teams we work with find the numbers are pretty eye-opening when they add it up.

**Bad:**

> Actually, we're one of the most affordable options in the market! I can offer you a 15% discount if you sign up this week.

### "Bad Timing" / "I'm Busy"

**What's behind it:** They don't feel the cost of waiting. Inaction feels safer than action.

**Do:** Make the cost of doing nothing tangible. Use their own numbers and timeline.

**Don't:** Say "when would be a better time?" Push for urgency. Minimize their schedule.

**Good:**

> Totally understand. Just curious -- you mentioned the ramp-time issue was costing you about 6 figures a year. If nothing changes in the next 6 months, what does that look like for your Q3 hiring plan? No pressure either way -- just want to make sure the timing decision is an informed one.

**Bad:**

> No worries! When would be better? I can follow up next month. Or maybe we could just do a quick 10-minute call to keep the ball rolling?

### "I've Tried This Before"

**What's behind it:** They got burned. Trust is low because of past experience. Hardest objection — it's based on evidence.

**Do:** Validate their experience fully. Don't dismiss it. Then differentiate with specifics about how your approach differs on the exact dimension where they got burned.

**Don't:** Say "we're different." Trash the competitor. Minimize their past experience.

**Good:**

> That's frustrating, and honestly pretty common. Do you mind sharing what specifically didn't work? I ask because there's a specific failure mode I see a lot in this space, and knowing where it broke down would help me tell you honestly whether what we do would be any different.

**Bad:**

> Oh yeah, those other solutions are nothing like what we do. Our approach is completely different and way more effective!

### "Not Sure It's For Me"

**What's behind it:** They can't see themselves in what you're describing. The identity match is weak.

**Do:** Get more specific about who you help. Share an example of someone in their exact situation.

**Don't:** Make it more generic. List features. Say "it works for everyone."

**Good:**

> That's fair. Just for context -- the person I worked with most recently who was in almost your exact spot was a [their role] at a [their company type], about [their size]. Their main issue was [their problem]. Does that sound at all familiar, or is your situation different?

### "Send Me More Info"

**What's behind it:** Interested but not ready to commit to a conversation. Needs one more reason to engage.

**Do:** Send ONE specific, relevant thing. Then follow up with a question about that specific thing.

**Don't:** Send a PDF deck. Send three links. Send your full website.

**Good:**

> Sure -- rather than sending the whole overview, here's the one piece that's most relevant to what you mentioned about [their situation]: [specific link or 2-sentence summary]. Curious if that resonates with what you're seeing on your end.

**Bad:**

> Absolutely! Here's our website: [link]. And here's our case study deck: [link]. And our pricing page: [link]. Let me know what you think!

## Quick Reference

| Objection | Real Concern | Response Strategy | Follow-Up Reminder |
|-----------|-------------|-------------------|-------------------|
| "I'll think about it" | Risk > value | Smaller next step + relevant proof | 3-5 days |
| "Too expensive" | Value unclear | Reframe: cost of problem vs solution | 5-7 days |
| "Bad timing" | Cost of waiting unclear | Make inaction tangible with their data | 7-14 days |
| "Tried before" | Past burn, low trust | Validate, ask what broke, differentiate | 5-7 days |
| "Not for me" | Identity mismatch | Specific example of someone like them | 3-5 days |
| "Send info" | Commitment threshold too high | ONE specific thing + follow-up question | 3 days |

## When to Persist vs Let Go

Not every objection should be addressed. Some signal a genuine mismatch:

| Signal | What It Means | What to Do |
|--------|-------------|-----------|
| Same objection raised 3+ times | Real blocker, not a surface concern | Acknowledge and step back gracefully |
| Tone shifts to cold or irritated | You've pushed past their comfort | Immediate easy out. Archive if needed. |
| They delegate ("talk to my assistant") | You're not talking to the decision-maker | Ask who would be the right person |
| Complete silence after your response | They've checked out | Set 14-day reminder, then archive |

## Draft Template

```
update_conversation(
  id="<id>",
  draft_message="<the message>",
  ai_notes="Objection type: [type]. Underlying concern: [real issue]. Addressed with: [strategy]. Context used: [which context fields shaped the response]. Next: [expected response or follow-up plan].",
  reminder="in [3-7] days"
)
```

## Guidelines

- Before drafting, call `get_draft_prompt(id)` first — it returns server-rendered voice-enforced context. Maintaining safe tone is critical for objections; the prompt enforces voice consistency. Save via `update_conversation`.
- Always save drafts via `draft_message`. Never pretend to send messages.
- Always include `ai_notes` explaining: objection type, underlying concern, strategy used, which context fields shaped the response.
- One draft per conversation. A new draft overwrites the previous one.
- Match the user's voice profile. Objections require consistent, safe tone.
- Never manufacture urgency. Use their own data and timeline to reframe.
- Never discount or devalue the offer to overcome an objection.
- After the objection is addressed and conversation continues, transition to **reply-handling** or **call-booking** as appropriate.
- See `references/objection-psychology.md` for the risk framework and timing objection psychology.

## Related Skills

- **reply-handling** — For non-objection replies and qualifying
- **call-booking** — When the objection is resolved and they're ready
- **cold-rescue** — When they go silent after an objection
- **batch-drafting** — Process multiple objection responses at once
- **voice-profile-setup** — Critical for maintaining safe tone during pushback
