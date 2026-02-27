# Follow-Up Cadence & Patterns

Timing rules and message patterns for every follow-up situation during and after a campaign. Every follow-up deposits value -- never extracts attention.

## Core Timing Rules

| Trigger | Timing | Action Type |
|---------|--------|-------------|
| They replied | Same day (within hours) | Respond with a question about their world |
| No reply to opener | Day 3 (48-72 hours) | Value-add follow-up |
| No reply to first follow-up | Day 5-6 | Different angle or door-open |
| No reply after 2 follow-ups | STOP | Set 30-day reminder for monthly nurture |
| "Sounds interesting, let me think" | 24 hours | Send a relevant example or case study |
| Said yes, then went quiet | 24 hours before event | Gentle check-in |
| Attended event | Within 2 hours | Personal reference to session |
| Attended event | 24-48 hours | Bridge to paid offer |
| No-showed | Same day | Warm, no guilt, share takeaway |
| "Not right now" | Set monthly reminder | Nurture check-in tied to their world |

## The 2-Touch Rule

After 2 follow-ups with no reply, stop. Period.

- Do not send a third message.
- Do not "just check in."
- They know how to find you.
- Move to monthly nurture cadence or archive.
- Persistence is good. Pestering destroys trust permanently.

## Follow-Up Message Patterns

### Follow-Up #1: Value Add (Day 3)

Purpose: Give them something useful. Not a reminder that you exist.

**Pattern:** Share an insight, resource, or question tied to their situation.

Good examples:
> "Hey [name] -- thought you might find this relevant. [Insight about their industry or role]. Curious if you're seeing the same thing?"

> "Hey [name] -- just saw [relevant trend/article/data point] and thought of you. [Brief connection to their situation]."

Bad examples:
> "Just following up on my last message."
> "Did you see my previous message?"
> "Bumping this to the top of your inbox."

**Tool pattern:**
```
update_conversation(
  id="<id>",
  draft_message: "[value-add follow-up]",
  ai_notes: "Follow-up #1 (Day 3). No reply to opener. Value add: [what's being shared].",
  reminder: "<Day 5-6 for follow-up #2>"
)
```

### Follow-Up #2: Different Angle or Door Open (Day 5-6)

Purpose: Try a completely different approach, or gracefully leave the door open.

**Different angle pattern:**
> "Hey [name] -- different question. [Question about a different aspect of their work that connects to your offer]. No agenda, just curious."

**Door open pattern:**
> "Hey [name] -- no worries if the timing's off. I run these [monthly/quarterly]. Door's always open if things change."

> "Hey [name] -- totally understand if this isn't a priority right now. If it ever becomes one, you know where to find me."

**Tool pattern:**
```
update_conversation(
  id="<id>",
  draft_message: "[different angle or door open]",
  ai_notes: "Follow-up #2 (final). If no reply, move to monthly nurture. Do not send another follow-up.",
  reminder: "<30 days for nurture check-in>"
)
```

### Reply to "Sounds Interesting, Let Me Think" (24 hours)

Purpose: Reduce risk. Give them proof it works.

**Pattern:**
> "Totally -- here's what happened for [someone in their situation]. [Brief case or example]. Happy to answer any questions."

Do NOT say: "So are you in?" or "Have you decided?"

### Reply to Objection (Same day)

Purpose: Acknowledge the real concern. Address it directly. Include an easy out.

**Pattern:**
> "Totally get it -- [restate their concern in your own words]. [Direct response to the concern]. No pressure either way."

Do NOT over-explain, push harder, or ignore the concern.

### Confirmation Check-In (24 hours before event)

**Pattern:**
> "Hey [name] -- looking forward to tomorrow at [time]. [Quick reminder of what they'll get]. Any questions?"

Keep it short. Do not re-pitch.

### Post-Event: Attendee (Within 2 hours)

**Pattern:**
> "Really enjoyed our conversation about [specific topic they raised]. That [moment/insight] -- that's exactly what I see with [their niche] who are ready to [outcome]."

Must reference something specific from the session. Not a template.

### Post-Event: Bridge to Offer (24-48 hours)

**Pattern:**
> "Been thinking about what you shared about [their situation]. I put together something that shows what working together looks like -- based on people in exactly your position. Want me to send it over?"

Permission-based. Build on what they shared. Not a generic pitch.

### Post-Event: No-Show (Same day)

**Pattern:**
> "Hey [name] -- missed you today! No worries at all. I [covered/built/showed X] -- happy to share the key takeaway. Or if timing was just off, I run these monthly."

Warm. No guilt. No passive aggression.

### Monthly Nurture (Ongoing)

**Pattern:**
> "Hey [name] -- saw [relevant industry trend/news/insight] and thought of our conversation about [thing they mentioned]. Hope things are going well with [their situation]."

Rules:
- Tied to THEIR world, not your offer
- No more than monthly
- No pitch unless they re-engage
- Always reference something specific from past conversation

**Tool pattern:**
```
update_conversation(
  id="<id>",
  reminder: "<next month>",
  ai_notes: "Monthly nurture. Last contact: [date]. Topic: [what was discussed]. Next angle: [planned topic]."
)
```

## Campaign-Specific Cadence Summary

| Day | Who Gets Contacted | Message Type |
|-----|-------------------|--------------|
| Day 1 | Full prospect list (20-30) | Personalized opener |
| Day 2 | New replies + 15-20 more prospects | Responses + openers |
| Day 3 | Day 1 non-replies + new replies | Follow-up #1 (value-add) + responses |
| Day 4 | Day 2 non-replies + qualified prospects | Follow-up #1 + invitations |
| Day 5 | Day 1 second non-replies + all engaged | Follow-up #2 (door-open) + confirmations |
| Post-campaign | 2-follow-up non-replies | Set 30-day nurture reminder. Stop messaging. |

## Anti-Patterns (Never Do These)

| Anti-Pattern | Why It Fails |
|-------------|-------------|
| "Just checking in" | Adds no value. Signals neediness. |
| "Did you see my last message?" | Passive aggressive. They saw it. |
| "Bumping this up" | You are not their priority. Accept it. |
| "I know you're busy, but..." | Starts with an apology. Weak framing. |
| Third follow-up after silence | Crosses the line from persistent to pest. |
| Same message, slightly reworded | They know it is the same ask. |
| "Last chance" (false urgency) | Manufactured pressure destroys trust. |
| Following up within 24 hours | Signals desperation. Wait 48-72 hours minimum. |
