# DM Situations — Full Examples

Detailed good/bad examples for all 7 DM situations. Reference this when drafting messages.

## Situation 1: Cold Outreach

**Goal:** Get a reply. Not a sale.

### Good Example

> Hey Sarah -- noticed you're scaling the SDR team at Acme post-Series B. Most teams at that stage lose 3-4 months per new rep just on ramp time.
>
> I helped another B2B SaaS team cut that from 9 months to 3. Happy to share the structure if useful -- no pitch, just the framework. Would that be helpful?

**Why it works:** Names her specific situation (SDR team, Series B). Concrete result from a similar company. Offers something useful. Asks permission. Includes an easy out ("if useful").

### Bad Example

> Hi Sarah! I help companies with sales enablement. We have a proven methodology that's helped 200+ companies improve their results. Would love to hop on a quick call to show you how we can help!

**Why it fails:** Generic (works for anyone). Self-focused (I, we, our). Jumps to a call. No specific insight. No permission. No easy out.

### More Examples by Context

**Referencing their headline:**

> Hey Tom -- your headline says "Building demand gen engines for B2B SaaS." Curious how you're handling the attribution side. Most teams I talk to say it's the hardest part of the stack to get right.

**Referencing a recent event:**

> Hey Rachel -- saw Acme just announced the Series B. Congrats. That usually means the pressure on pipeline doubles overnight. Curious how you're handling that.

**Referencing a mutual connection:**

> Hey David -- [mutual connection] mentioned you're rethinking your outbound strategy. I work in that space and had a thought. Mind if I share a quick framework?

### Draft Template

```
update_conversation(
  id="<id>",
  draft_message="Hey [name] -- [specific reference to their world]. [Concrete insight or result]. [Low-friction offer or question]. [Easy out].",
  ai_notes="Cold outreach. Referenced [what]. Offered [what]. Goal: get a reply.",
  reminder="in 3 days"
)
```

---

## Situation 2: They Replied

**Goal:** Build rapport. Understand their world. Don't pitch.

### Good Example

> **Them:** "Yeah, we're hiring 5 more SDRs this quarter. It's been a challenge finding good ones."
>
> **You:** That's a real bottleneck -- especially in this market. Are you finding the issue is more about sourcing quality candidates, or about getting them productive once they start?

**Why it works:** Validates their frustration. Shows understanding. Asks a focused question that deepens the conversation. One question, not three.

### Bad Example

> **Them:** "Yeah, we're hiring 5 more SDRs this quarter."
>
> **You:** That's great! We actually have a solution that helps SDR teams ramp faster. I'd love to tell you more about it. Can we book 15 minutes?

**Why it fails:** Ignores what they shared. Jumps to pitch. Asks for a call before trust is built.

### More Examples

**They shared a challenge:**

> **Them:** "Our close rate has dropped from 25% to 15% this quarter."
>
> **You:** That's a significant shift. Has anything changed in the last few months -- new reps, different lead sources, or a shift in who you're targeting?

**They asked about you:**

> **Them:** "What do you do exactly?"
>
> **You:** Short version: I help [type of team] solve [specific problem]. But I'm curious what made you ask -- are you dealing with something in that space?

### Draft Template

```
update_conversation(
  id="<id>",
  draft_message="[Acknowledge what they said]. [Ask a specific question that deepens the conversation].",
  ai_notes="Acknowledged their reply about [topic]. Asked deepening question about [specific]. Stage: chatting."
)
```

---

## Situation 3: Qualifying

**Goal:** Find the gap between where they are and where they want to be.

### Good Example (Full Sequence)

> **You:** When you mentioned losing reps during probation -- is that mostly in the first 3 months or later?
>
> **Them:** First 3 months. We're losing about 30% before they're even ramped.
>
> **You:** That's expensive. At your scale that's probably 6 figures per year just in failed hires. If you could cut that to under 10% attrition in probation, what would that change for you?
>
> **Them:** It would be huge. We've been trying to fix it internally but haven't cracked it.

This person is qualified: clear problem, real cost, tried to fix it themselves.

### Bad Example

> So do you have budget for this? Who's the decision-maker? What's your timeline? What other solutions have you looked at?

**Why it fails:** Feels like a form. Four questions at once. No acknowledgment. No value given.

### Question Sequence Guide

| Phase | Example Question | Purpose |
|-------|-----------------|---------|
| Easy open | "What's been your biggest focus this quarter?" | Let them share freely |
| Go deeper | "When you mentioned X -- is that more of a Y issue or a Z issue?" | Specifics about their challenge |
| Surface the gap | "So right now it's [current state]. Where would you need that to be?" | Help them feel the distance |
| Check commitment | "Is fixing this something you're actively working on?" | Test readiness to act |

### Qualification Signals

| Signal | Qualified? |
|--------|-----------|
| Named a specific problem + timeline | Yes |
| Named a problem + tried to fix it | Yes |
| Asked about pricing + has a stated need | Yes |
| General curiosity, no stated need | Not yet |
| "Sounds interesting, tell me more" | Not yet — keep qualifying |

### Draft Template

```
update_conversation(
  id="<id>",
  stage="qualified",
  draft_message="[Acknowledge what they shared]. [Surface the gap or check commitment].",
  ai_notes="Qualified. [Need: X]. [Cost: Y]. [Timeline: Z]. Next: [offer framework/call]."
)
```

---

## Situation 4: Handling Objections

See `objection-handling.md` for the complete objection library with examples.

---

## Situation 5: Going Quiet

**Goal:** Re-engage with value. Never chase.

### Good Example (3-day follow-up)

> Hey Sarah -- saw this case study about SDR onboarding at a company your size and thought of you. Want me to send it over?

### Good Example (7-day follow-up)

> Hey James -- was working with another recruiter this week who had the same ramp-time problem you mentioned. They found that restructuring the first 30 days made the biggest difference. No rush on our conversation -- just thought you'd find that interesting.

### Good Example (14-day door-open)

> No worries if timing's off on this, Marcus. Thought of you when a client in fintech mentioned a similar challenge. Happy to pick this up whenever makes sense.

### Bad Examples

> "Just wanted to circle back on my last message." -- No value.
>
> "Haven't heard from you in a while!" -- Guilt, not value.
>
> "Bumping this to the top of your inbox." -- Pressure, not value.

### Follow-Up Escalation

| Attempt | Timing | Draft Approach | Reminder |
|---------|--------|---------------|----------|
| 1st | 3 days | Value-add tied to their situation | `in 3 days` |
| 2nd | 7 days | Different angle, new question | `in 7 days` |
| 3rd | 14 days | Door-open, no pressure | `in 30 days` |
| After 3rd | — | Archive or monthly nurture | — |

### Draft Template

```
update_conversation(
  id="<id>",
  draft_message="[Value-add or new angle]. [No pressure]. [Easy out].",
  reminder="in [3/7/14] days",
  ai_notes="Re-engagement attempt [1st/2nd/3rd]. Value added: [what]. Last topic: [what they discussed]."
)
```

---

## Situation 6: Ready for Call

**Goal:** Book a specific next step. Make it feel natural.

### Good Example

> Based on what you've shared, I think a quick conversation would be worth it. 30 minutes -- I'll walk through the framework that solved this for [similar company], and you can see if it fits your situation.
>
> No pitch, just the actual approach. Does Thursday at 2pm work?

**Why it works:** Ties to their specific problem. States exactly what they get. Clear format (30 min, framework review). Low pressure ("see if it fits"). Specific time proposed.

### Bad Example

> Great! Let me send you my Calendly link and you can pick a time that works!

**Why it fails:** Calendar links add friction. No context about what the call covers.

### After They Confirm

Send a confirmation the day before:

> Looking forward to tomorrow -- I pulled some things specific to your situation at [company].

### Draft Template

```
update_conversation(
  id="<id>",
  stage="discovery",
  draft_message="Based on what you've shared, [specific value of the call]. [Format + time commitment]. [What they'll get]. Does [specific day and time] work?",
  ai_notes="Moving to discovery. Call for [format/duration]. Key topic: [their problem]. Proposed: [date/time].",
  reminder="<day before call at 9am>"
)
```

---

## Situation 7: Post-Event Follow-Up

**Goal:** Convert event attendance into a conversation.

### Good Example

> Hey Sarah -- really enjoyed your question during the webinar about scaling outbound at speed. That's exactly the problem I see most teams run into after Series A. Curious -- have you found anything that works at your current scale?

### Bad Example

> Hi Sarah! Thanks for attending the webinar! I noticed you were there and wanted to reach out. Would love to chat about how I can help you!

**Why it fails:** Generic. Could go to every attendee. Self-focused. No specific reference.

### Event Types and Angles

| Event Type | Reference | Follow-Up Angle |
|-----------|-----------|-----------------|
| Webinar they attended | Their question or comment during it | "Your question about X really stood out..." |
| Workshop participant | Something they worked on | "Noticed you were focused on Y during the workshop..." |
| Conference meeting | Something discussed in person | "Great meeting you at Z. You mentioned..." |
| Content engagement | Post they liked or commented on | "Saw your comment on [post]. Curious about..." |

### Draft Template

```
update_conversation(
  id="<id>",
  draft_message="Hey [name] -- [reference specific event moment]. [Connect to their situation]. [Ask a question].",
  ai_notes="Post-event follow-up. Event: [name]. Referenced [what]. Goal: start a conversation.",
  reminder="in 3 days"
)
```
