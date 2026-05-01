---
name: reply-handling
description: >
  Handle replies and qualify prospects through conversation. Maps to app template
  category: follow_up. Use when the user says "they replied", "how should I respond",
  "what should I say back", "qualifying", "they asked about", or when drafting a
  follow-up message. Covers first replies through qualification with trust progression
  and pain depth assessment. Related: cold-outreach for first messages,
  objection-handling when they push back, call-booking when they're ready.
metadata:
  version: "1.0"
  author: linkninja
  template_categories:
    - follow_up
---

# Reply Handling

Handle replies and advance conversations from first response through qualification. Each message moves the prospect one step closer to a real conversation — never try to jump three steps at once.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Fetch the conversation:

```
get_conversation(id="<conversation_id>")
```

3. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | "I need your ICP to know what qualifies them. Want to set that up?" Run **icp-definition** |
| Positioning (`positioning_context`) | Yes | "What do you sell? Helps me frame questions and value correctly." |
| Voice Profile (`voice_profile`) | Recommended | Match their energy level. Suggest **voice-profile-setup** after. |
| Personal Story (`personal_story`) | Useful | Adds credibility when sharing relevant experience. "I helped a team like yours..." |

4. If the user says "help with my replies" without specifying, find what needs attention:

```
search_conversations(my_turn=true, freshness="fresh", compact=true)
```

## Using Your Context

| Context Field | How It Shapes the Reply |
|--------------|------------------------|
| **ICP** (`additional_context`) | Defines your qualification criteria. What pain points to probe for. What "qualified" looks like. If they don't match ICP, flag before investing. |
| **Positioning** (`positioning_context`) | Shapes the questions you ask. Probe toward gaps your positioning solves. When offering an insight, frame it through your positioning. |
| **Voice Profile** (`voice_profile`) | Match their energy. If they write short, write short. If they're formal, be formal. Use your greeting style, vocabulary, sentence length from voice profile. |
| **Personal Story** (`personal_story`) | Use after they share a challenge. "I worked with a team in a similar situation..." Adds credibility. Use sparingly — max once per conversation thread. |

## Phase 1: They Replied

**When:** Chatting stage. They responded. Conversation is live.

**Goal:** Build rapport and understand their world. Do not pitch.

**Three steps — in this order:**

1. **Acknowledge what they said** — show you read it, not just replied
2. **Ask a specific question about their world** — not generic "tell me more"
3. **Don't pitch yet** — the conversation needs to breathe

### Common Reply Types

| What They Did | How to Respond |
|--------------|---------------|
| **Shared a challenge** | Validate the frustration. Ask what they've tried or what specifically makes it hard. |
| **Asked about you** | Answer briefly (1-2 sentences), then redirect: "Curious what made you ask — are you dealing with something in that space?" |
| **Gave a short reply** | Match their brevity. Ask one focused question. Don't escalate energy. |
| **Asked a question** | Answer directly, then ask a related question that deepens the conversation. |
| **Showed enthusiasm** | Match their energy. Go slightly deeper. "What specifically about X resonated?" |

### Trust Progression

Each reply either builds trust or stalls the conversation. After a cold DM gets a reply, the prospect moves through these checkpoints:

| What They're Evaluating | Your Job | Signal It's Working |
|------------------------|----------|-------------------|
| "Is this real?" | Reply naturally. Match their energy. | They replied at all |
| "Is this for me?" | Ask questions specific to their world | They share details |
| "Do you get my world?" | Demonstrate insider knowledge | They say "exactly" or "that's our issue" |
| "Is it safe?" | Give value before asking for anything | They ask you a question back |

**Movement rules:**
- One step per interaction. Don't rush from "Is this real?" to "Is it safe?" in one message.
- Earn the next question — each question you ask must be justified by something they shared.
- Give before you take — offer an insight, resource, or perspective before asking for anything.

### Stall Signals

| Signal | What It Means | What to Do |
|--------|-------------|-----------|
| Short replies getting shorter | Trust isn't building | Give value. Ask about something they care about. |
| They keep redirecting | Not sure it's for them | Get more specific about their situation. |
| "Interesting" with no follow-up | Polite but unconvinced | Ask what specifically resonated (or didn't). |
| They go quiet | Friction too high or timing off | Wait 3 days, value-add follow-up. See **cold-rescue**. |

### Good Example

> **Them:** "Yeah, we're opening a second cohort this quarter. Finding the right fit students has been a challenge."
>
> **You:** That's a real bottleneck -- especially in this market. Are you finding the issue is more about sourcing quality candidates, or about getting them productive once they start?

**Why it works:** Validates frustration. Shows understanding. One focused question.

### Bad Example

> **Them:** "Yeah, we're opening a second cohort this quarter."
>
> **You:** That's great! We actually have a solution that helps coaches fill their cohorts faster. I'd love to tell you more about it. Can we book 15 minutes?

**Why it fails:** Ignores what they shared. Jumps to pitch. Asks for a call before trust is built.

### Draft Template

```
update_conversation(
  id="<id>",
  draft_message="[Acknowledge what they said -- specific, not generic]. [One question that deepens the conversation].",
  ai_notes="Acknowledged their reply about [topic]. Asked deepening question about [specific]. Trust level: [which checkpoint]. Stage: chatting."
)
```

## Phase 2: Qualifying

**When:** Chatting → qualified. Had a few exchanges. Need to determine fit.

**Goal:** Find the gap between where they are now and where they want to be.

### A–B Method + Question Sequence

The playbook anchors qualifying on the **A–B Method**: find Point A (current state, current pain) and Point B (desired state, what they want). The gap between them is your opportunity. Every question surfaces A or B more clearly — never to set up a pitch.

> **Pull enrichment for sharper questions (Sales Navigator only).** When qualifying, recent activity gives you a specific anchor — *"saw your post on X, how does that connect to..."*. Pull the contact's recent posts and experience:
>
> ```
> get_enrichment(ids: ["<conv_id>"], sections: ["recent_posts", "experience"])
> ```
>
> If the contact isn't enriched yet, run `enrich_connections(connection_ids=[<id>], limit=1)` first. Skip if no Sales Nav — fall back to thread context. See **connection-enrichment** for the full pattern.

The four-stage question sequence walks the A–B gap:

| Phase | Example Question | Purpose |
|-------|-----------------|---------|
| **Easy open** | "What's been your biggest focus this quarter?" | Let them share freely (no commitment) |
| **Go deeper** | "When you mentioned X -- is that more of a Y issue or a Z issue?" | Surface specifics about Point A |
| **Surface the gap** | "So right now it's [current state]. Where would you need that to be?" | Make them feel the A→B distance |
| **Check commitment** | "Is fixing this something you're actively working on?" | Micro-commitment test — readiness to act |

### Pain Depth Check

How often the prospect experiences the pain determines urgency and approach:

| Pain Frequency | Examples | Urgency | How to Reference |
|---------------|---------|---------|-----------------|
| **Daily** | Opening inbox with dread, checking dashboards anxiously, constant firefighting | High — they'll act fast if solution feels safe | "That moment when you [daily trigger]..." |
| **Weekly** | Monday morning dread, weekly reporting stress, recurring missed targets | Medium — needs a push to prioritize | "Every [day] when you have to [weekly task]..." |
| **Monthly** | Monthly KPI reviews, budget meetings, churn reports | Low-medium — they tolerate it | "When you look at [monthly metric]..." |
| **Annual** | Annual reviews, planning cycles, yearly audits | Low — easy to postpone indefinitely | Usually not enough urgency for DM pipeline |

When pain is daily, anchor your questions to the specific moment they feel it. "That moment when you [open/check/see/realize] [the specific trigger]..." — this is recognition, not persuasion. When you name their moment accurately, they feel understood.

| Pain Frequency | Approach in DMs |
|---------------|----------------|
| Daily | Move quickly toward qualifying. They want a solution. |
| Weekly | Build evidence of compounding cost. Help them see the pattern. |
| Monthly | Qualify carefully. They may not be ready to act yet. |
| Annual | Long nurture. Don't push. Check back quarterly. |

### Qualification Signals

| Signal | Qualified? | Next Step |
|--------|-----------|-----------|
| Specific problem + timeline + tried to fix it | Yes | Move to **call-booking** |
| Specific problem + timeline, no prior attempts | Probably | One more question about commitment |
| Specific problem, no timeline | Not yet | Ask about urgency or cost of waiting |
| General interest, no stated problem | No | Keep building rapport |
| Asked about pricing + stated need | Yes | Frame value before sharing price |
| "Sounds interesting, tell me more" | Not yet | Ask what specifically resonated |

### Good Qualifying Example

> **You:** When you mentioned discovery calls not converting — is that mostly in the first call or after the second one?
>
> **Them:** First one. About 70% of my discovery calls go nowhere after the call ends.
>
> **You:** That's a lot of energy going into calls that don't convert. If you could move that to under 30% drop-off — so 7 of every 10 discovery calls turn into a real conversation about working together — what would that mean for your year?

**Why it works:** Uses their data. Surfaces the cost. Helps them feel the gap.

### Bad Qualifying Example

> So do you have budget for this? Who's the decision-maker? What's your timeline? What other solutions have you looked at?

**Why it fails:** Feels like a form. Four questions at once. No acknowledgment.

### Stage Transition

When they qualify, update the stage:

```
update_conversation(
  id="<id>",
  stage="qualified",
  draft_message="[Acknowledge what they shared]. [Surface the gap or check commitment].",
  ai_notes="Qualified. Need: [X]. Cost: [Y]. Timeline: [Z]. Next: move to call-booking."
)
```

If they don't qualify yet:

```
update_conversation(
  id="<id>",
  draft_message="[Question that goes one level deeper].",
  ai_notes="Not yet qualified. Missing: [need/timeline/commitment]. Asked about [what]. Stage: chatting."
)
```

## Guidelines

- Before drafting, call `get_draft_prompt(id, reply_intent="qualify")` first — it returns server-rendered voice-enforced context tuned for qualifying. Follow the returned prompt exactly, then save via `update_conversation`.
- Always save drafts via `draft_message`. Never pretend to send messages.
- Always include `ai_notes` explaining: what signal you responded to, trust level, qualification status, expected next step.
- One draft per conversation. A new draft overwrites the previous one.
- Match the user's voice profile. If none exists, match the prospect's energy level.
- Keep replies to 2-3 sentences. One question per message.
- If a conversation goes cold mid-qualifying, hand off to **cold-rescue** for the playbook cadence (Day 1 / 3 / 7 / extending) — 80% of sales close after the 5th touchpoint.
- See `references/conversation-progression.md` for the full trust progression model and pain depth assessment.

## Related Skills

- **cold-outreach** — When the first message hasn't been sent yet
- **objection-handling** — When they push back or raise concerns
- **call-booking** — When they're qualified and ready for a next step
- **batch-drafting** — Process multiple reply conversations at once
- **cold-rescue** — When they go quiet after initial engagement
- **voice-profile-setup** — Configure voice matching for natural-sounding replies
