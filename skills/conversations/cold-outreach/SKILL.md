---
name: cold-outreach
description: >
  Craft cold DMs and post-event openers that earn replies. Maps to app template
  categories: opening, value_add. Use when the user says "write a cold DM", "first
  message to", "reach out to", "post-event follow-up", or when drafting an opening
  or value-add message. Uses specificity-personalization framework, insider vocabulary
  signals, and permission-based closing. Related: reply-handling for when they respond,
  campaign-launch for structured outreach at scale, voice-profile-setup for tone matching.
metadata:
  version: "1.0"
  author: linkninja
  template_categories:
    - opening
    - value_add
---

# Cold Outreach

Craft first messages that earn replies — cold DMs, connection openers, and post-event follow-ups. A cold DM works when it reads like it could not possibly have been written for anyone else.

## The Three Opening Rules

Every cold DM and post-event opener obeys all three (from `references/sell-by-chat-methodology.md`):

1. **Make it about them.** Not your offer, your company, or your method.
2. **Keep it short.** 2–4 sentences. Weight per word goes up as length goes down.
3. **Serve, don't take.** Lead with an observation, question, or helpful comment — not an ask.

Three techniques the rules enable:

- **Precision Flattery** — specific niche praise that proves you understand their world. *"Your approach to [specific topic] is sharp because [specific reason]."* Pull `recent_posts` and `experience` from `get_enrichment` to make praise specific and credible — *requires an active Sales Navigator connection* (without it, fall back to headline + post-level signals). Generic praise ("love your content") signals automation.
- **Pattern Interrupt** — unexpected but relevant observation that shows you've stepped into their world before opening your mouth.
- **Preloaded Value** — if you offer something, it must be: specific to their situation, ungated (no opt-in), actionable (a checklist or framework they can use today), and tied to the next conversation.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Yes | "I need your ICP to target the right people and frame messages correctly. Want to set that up?" Run **icp-definition** |
| Positioning (`positioning_context`) | **Required (hard stop)** | If empty, **stop** and ask: *"What are you offering them? I need this to frame the value-add — without it the cold DM has nothing real to anchor to."* Configure in dashboard or inline. |
| Voice Profile (`voice_profile`) | Recommended | Draft in neutral professional tone. Suggest **voice-profile-setup** after. |
| Personal Story (`personal_story`) | Optional | Proceed without — do NOT use in first cold message anyway. |

3. If the user names a specific person, find or create their conversation:

```
search_conversations(query="<name>", compact=true)
```

4. If the user wants to find prospects:

```
scan_connections(headline_keywords=["<target_role>"], has_conversation=false)
```

## Using Your Context

Each context field shapes a specific part of the cold DM:

| Context Field | How It Shapes the Draft |
|--------------|------------------------|
| **ICP** (`additional_context`) | Determines relevance framing. Reference their industry, role, company stage. Match pain points from ICP to what you see in their profile. If they're outside ICP, flag it before drafting. |
| **Positioning** (`positioning_context`) | Shapes the value you offer. The insight, framework, or result you reference. Never pitch directly — use to frame the value-add. "I helped another [ICP match] [result from positioning]." |
| **Voice Profile** (`voice_profile`) | Controls greeting ("Hey" vs "Hi" vs name only), formality, sentence length, vocabulary, sign-off. The draft must sound like the user wrote it, not an AI. |
| **Personal Story** (`personal_story`) | **Do not use in the first cold message.** Save for reply-handling once they engage. Exception: a shared experience creates a direct connection (same school, same company, same event). |

Draft structure maps context to message parts:

```
"[greeting from voice_profile] [name] -- [reference to their world, framed by ICP].
[insight shaped by positioning_context, aimed at pain from ICP].
[low-friction offer or question in voice_profile style]. [easy out]."
```

## Reading the Prospect

Before drafting, extract signals from their LinkedIn profile:

| Profile Element | What to Look For | How to Use It |
|----------------|-----------------|---------------|
| **Headline** | Role, company stage, industry terms | Frame relevance: "You're [headline signal]..." |
| **Company** | Size, funding stage, industry | Match to ICP. Reference specific constraints. |
| **Recent activity** | Posts, comments, job changes | Hook: "Saw your post about..." or "Congrats on the new role." |
| **Mutual connections** | Shared network | Social proof: "[Name] and I connected over..." |
| **Location/culture** | Geography, industry norms | Use insider vocabulary and references. |

Use the vocabulary and framing they use in their headline and posts. If they say "discovery call," don't say "intro session." If they say "cohort," don't say "class." If they say "AUM," don't say "assets." Language mirroring builds subconscious trust. See `references/cold-dm-framework.md` for the full language mirroring rules.

## The Cold DM Checklist

Every cold DM must pass 5 checks. If any fail, rewrite before saving:

| Check | Test | Example |
|-------|------|---------|
| **Specific to them** | Could this message only go to this person? | "Noticed you've been opening up to a second cohort for your sales coaching program" (pass) vs "I help businesses grow" (fail) |
| **Personalized** | Does it reference something real from their world? | Their headline, a post, their company news, a mutual connection |
| **Insider vocabulary** | Does it use words from their world, not yours? | "discovery call → engagement conversion" for consultants, "AUM threshold" for advisors, "scope creep" for agency owners |
| **Permission close** | Does it ask before offering? | "Would that be useful?" "Happy to share if relevant." |
| **Easy out** | Can they say no without friction? | "No pressure." "Totally fine if timing's off." |

### What Makes Cold DMs Fail

| Pattern | Why It Fails |
|---------|-------------|
| Generic opener ("I help companies...") | Could go to anyone — signals automation |
| Self-focused ("We have a proven methodology") | They don't care about you yet |
| Jumping to a call | Skips trust entirely — they don't know you |
| Long pitch on first message | No one asked for this |
| No easy out | Creates pressure, kills trust |
| Marketing vocabulary instead of their vocabulary | Signals you're an outsider |

## Cold DM Examples

### Good: Headline-Referenced

> Hey Sarah… saw you've opened a second cohort for your executive coaching program. Most coaches at that stage tell me lead-flow goes feast or famine right around the 6-month mark.
>
> I helped another solo coach (similar offer, similar size) move from launch-then-pray to a steady stream of qualified DMs. Happy to share the structure if useful — no pitch, just the framework. Useful?

**Why it works:** Names her situation (second cohort, exec coaching). Concrete result from a similar operator. Offers something useful. Permission close. Easy out.

### Good: Activity-Referenced

> Hey Tom… your headline says "Helping fractional CFOs land $5K+/month retainers." Curious how you're handling the discovery-to-engagement conversion. Most fractional folks I talk to say that step is where deals quietly die.

**Why it works:** Uses his exact words. Asks about a known pain in his space. Short. No pitch.

### Good: Mutual Connection

> Hey David -- [mutual connection] mentioned you're rethinking your outbound strategy. I work in that space and had a thought. Mind if I share a quick framework?

### Bad: Generic Pitch

> Hi Sarah! I help companies with sales enablement. We have a proven methodology that's helped 200+ companies improve their results. Would love to hop on a quick call to show you how we can help!

**Why it fails:** Generic. Self-focused. Jumps to call. No specific insight. No permission. No easy out.

## Post-Event Follow-Up

Same checklist, but the event becomes your hook. Reference something specific that happened — not just "thanks for attending."

| Event Type | What to Reference | Example |
|-----------|------------------|---------|
| Webinar | Their question or comment | "Your question about X really stood out..." |
| Workshop | Something they worked on | "Noticed you were focused on Y during the workshop..." |
| Conference | Something discussed in person | "Great meeting you at Z. You mentioned..." |
| Content engagement | Post they liked/commented on | "Saw your comment on [post]. Curious about..." |

### Good Post-Event

> Hey Sarah… really enjoyed your question during the workshop about getting your discovery calls to convert higher. That's exactly the wall I see most consultants hit around year 2. Curious — have you tried anything that's actually moved the needle on it?

### Bad Post-Event

> Hi Sarah! Thanks for attending the webinar! I noticed you were there and wanted to reach out. Would love to chat about how I can help you!

**Why it fails:** Generic. Could go to every attendee. Self-focused. No specific reference.

## Draft Template

```
update_conversation(
  id="<id>",
  draft_message="[greeting] [name] -- [specific reference to their world]. [Insight/result framed by positioning, aimed at ICP pain]. [Permission close or question in voice style]. [Easy out].",
  ai_notes="Cold outreach. Referenced [what from profile]. ICP fit: [match details]. Offered [what value]. Specificity: [pass/fail on each check]. Goal: get a reply.",
  reminder="in 3 days"
)
```

For post-event:

```
update_conversation(
  id="<id>",
  draft_message="[greeting] [name] -- [reference specific event moment]. [Connect to their situation using ICP context]. [Question in voice style].",
  ai_notes="Post-event follow-up. Event: [name]. Referenced [what]. ICP fit: [details]. Goal: start a conversation.",
  reminder="in 3 days"
)
```

## Guidelines

- Before drafting, call `get_draft_prompt(id)` first — it returns server-rendered voice-enforced drafting context. Follow the returned prompt exactly, then save via `update_conversation(id, draft_message, ai_notes)`.
- Always save drafts via `draft_message`. Never pretend to send messages.
- Always include `ai_notes` explaining: what signal you responded to, ICP fit assessment, what the draft accomplishes, expected next step.
- One draft per conversation. A new draft overwrites the previous one.
- Match the user's voice profile. If none exists, use neutral professional tone.
- Keep cold DMs to 2-4 sentences. Post-event can go to 3-5.
- If the prospect is outside the user's ICP, flag it: "This person doesn't match your ICP because [reason]. Want to draft anyway?"
- After sending with no reply, transition to **cold-rescue** for re-engagement.
- See `references/cold-dm-framework.md` for the specificity-personalization grid, language mirroring rules, and permission close structure.

## Related Skills

- **reply-handling** — When they respond to your cold DM
- **campaign-launch** — Cold outreach at scale with structured cadences
- **batch-drafting** — Draft cold DMs for multiple prospects at once
- **voice-profile-setup** — Configure voice matching for natural-sounding drafts
- **icp-definition** — Set up targeting context for relevant messaging
- **cold-rescue** — Re-engage prospects who went quiet after cold outreach
