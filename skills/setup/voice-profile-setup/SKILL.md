---
name: voice-profile-setup
description: >
  Build a voice profile from the user's real LinkedIn messages so every AI draft
  sounds like them, not a bot. Use when the user says "set up my voice", "how do
  I sound", "match my writing style", "voice profile", "make drafts sound like me",
  "my messages sound generic", or "drafts don't sound like me". Analyzes 12
  dimensions of communication style and saves the profile for all future drafting.
  Related: dm-writing for individual messages, batch-drafting for bulk message
  generation, icp-definition for sales context setup.
metadata:
  version: "1.0"
  author: linkninja
---

# Voice Profile Setup

Analyze the user's real LinkedIn messages and build a voice profile so every AI-drafted DM sounds like them. The profile is saved via `update_context` and used by all skills that draft messages. Server-side, `get_draft_prompt` and the `shared_bundle` returned by `get_job_chunk` enforce voice — a richer profile makes that enforcement land harder.

If the user has no `voice_profile` yet, the fallback baseline is the playbook's **Ten Core Voice Rules** (in `references/sell-by-chat-methodology.md`): Be Human Not Robotic, Make Them Feel Seen, Prioritize Empathy, Keep Messages Short, One Question at a Time, Match Their Pace, Give Before You Ask, Follow Up With Purpose, Personalize Every Message, Own the Outcome. Encourage the user to author their own profile at the level of detail those rules imply.

## Before Starting

1. Run `get_context()` to load the user's current sales context
2. Check for existing voice profile:

| Situation | Action |
|-----------|--------|
| `voice_profile` already exists | Show it. Ask: "Want to refine this or rebuild from scratch?" |
| `voice_profile` is empty | Proceed with full setup |
| User has fewer than 5 conversations | STOP. "I need at least 5 conversations with messages you've sent to analyze your voice. Send a few more DMs and come back." |

3. No ICP needed for this skill. Voice setup works independently.

## Workflow

## Voice Tendencies by Archetype

Different archetypes have characteristic voice tendencies and anti-patterns. Use these as starting points to flag during voice analysis — they're tendencies, not rules. Your job is to surface what's specifically true for *this* user, not impose the archetype default.

| Archetype | Common voice tendency | Anti-pattern to flag |
|-----------|----------------------|----------------------|
| Solo Consultant | Direct, fact-heavy, can over-jargon | "Strategic alignment", "value proposition", "stakeholder buy-in" — corporate-speak that signals they've been institutionalised |
| Coach | Warm, empathetic, can over-affirm | "I see you", "honour", "you're already enough" — endless validation without substance |
| Financial Advisor | Polished, formal, compliance-driven | "Reach out", "circle back", "set up an appointment" — stiff and bureaucratic; signals corporate brand voice rather than the person |
| Agency Owner | Casual founder voice OR agency-marketing voice | "We help brands unlock their full potential" — agency-website voice. Their REAL voice (founder energy) is distinct from how the agency talks externally. |
| Niche Service Seller | Highly distinctive, often quirky | Defaulting to mass-market service-business framing instead of their genuine niche language |

**Practical check:** read the user's last 10 sent messages. If they sound like an institutional press release more than a person, the archetype tendency has overcorrected. The voice profile should pull them back toward their natural register — direct, warm, specific.

### Step 1: Collect Messages

Pull conversations with full message transcripts:

```
export_conversations(include_messages=true, limit=50)
```

Focus only on messages the **user sent** -- ignore prospect messages entirely. You need at least 10-15 sent messages to spot reliable patterns. More is better.

If the first page has too few user-sent messages, paginate:

```
export_conversations(include_messages=true, limit=50, page=2)
```

If specific conversations look promising (longer threads, varied contexts), pull them individually:

```
get_conversation(id="<conversation_id>")
```

Aim for messages across different conversation types -- cold opens, follow-ups, replies to questions, casual chats. A profile built from only cold opens will miss how the user sounds in natural conversation.

### Step 2: Analyze Across 12 Dimensions

Read through every user-sent message and extract patterns. Look for recurring habits, not one-off variations.

| Dimension | What to Extract | Example Spectrum |
|-----------|----------------|-----------------|
| **Message length** | Average word count per message | Short (10-20 words) to Detailed (50-100 words) |
| **Greeting style** | How they start messages | "Hey" / "Hi" / "Hello" / No greeting |
| **Sign-off style** | How they end messages | "Cheers" / "Talk soon" / None (just stops) |
| **Formality level** | Casual to professional spectrum | "gonna" vs "going to" / "awesome" vs "excellent" |
| **Question ratio** | Questions vs statements | Mostly questions (consultative) vs Mostly statements (advisory) |
| **Emoji usage** | Frequency and types | None / Occasional / Frequent / Specific favorites |
| **Humor style** | If and how they joke | Dry / Self-deprecating / None / Industry in-jokes |
| **Industry jargon** | Technical terms vs plain language | "pipeline velocity" vs "how fast deals close" |
| **Sentence structure** | Short punchy vs flowing | "Love that." vs "I really appreciate you sharing that." |
| **Contractions** | Do they use them? | "I'm" vs "I am" / "don't" vs "do not" |
| **Filler words** | Verbal habits in text | "honestly" / "actually" / "look" / "so" |
| **Punctuation** | Distinctive patterns | Exclamation marks / Ellipses / Dashes / Period-only |

### Step 3: Build the Profile

Distill the analysis into a structured profile. Present it to the user for confirmation before saving.

Format:

```
VOICE PROFILE
- Length: [typical word count and sentence count]
- Greeting: [their standard opening]
- Sign-off: [how they end messages]
- Formality: [casual/professional/hybrid with examples]
- Questions: [frequency and style]
- Emoji: [usage pattern]
- Humor: [style or none]
- Jargon: [terms they use naturally]
- Sentence structure: [pattern]
- Contractions: [always/never/mixed]
- Fillers: [habitual words/phrases]
- Punctuation: [distinctive patterns]

WORDS THEY USE: [list of characteristic phrases]
WORDS THEY NEVER USE: [list of words to avoid]
```

### Step 4: Confirm with the User

Present the profile and ask:
- "Does this capture how you sound? Anything feel off?"
- "Any phrases you love using that I missed?"
- "Any words or phrases that make you cringe when you see them in drafts?"

Adjust based on feedback.

### Step 5: Save the Profile

```
update_context(voice_profile="[the confirmed profile]")
```

Also update `summary_instructions` so AI-generated summaries match the user's style:

```
update_context(summary_instructions="Write in a [formality level] tone. [Key voice rules]. Avoid: [words they never use].")
```

### Step 6: Test with a Sample Draft

Pick a conversation that needs a reply:

```
search_conversations(my_turn=true, limit=5)
```

Fetch one:

```
get_conversation(id="<conversation_id>")
```

Draft a reply using the new voice profile. Save as draft with notes:

```
update_conversation(
  id="<id>",
  draft_message="[message matching their voice]",
  ai_notes="Voice profile test draft. Matched: greeting style, message length, formality level. Ask user if this sounds like them."
)
```

Ask: "I drafted a reply for [name]. Does it sound like you wrote it?"

## Example: Full Voice Analysis

### Messages collected:

> "Hey Tom… saw your post about discovery calls not converting. Are you still hitting that wall with the higher-ticket prospects?"

> "Hey Lisa… curious about something. You mentioned your second cohort is filling slowly. Is that a positioning thing or a lead-flow thing?"

> "Makes sense. Honestly the biggest thing I see with practices your size is the discovery-to-engagement conversion is what eats your time before the lead quality does."

> "Hey… no rush on this. Just thought you'd find it useful."

> "Ha — not exactly rocket science but somehow everyone overcomplicates it. Want me to send the framework?"

### Profile built:

```
VOICE PROFILE
- Length: Short. 1-2 sentences typical. Never more than 3.
- Greeting: "Hey [name]" or "Hey" -- always. Never "Hi there" or "Hello."
- Sign-off: None. Messages just end.
- Formality: Casual-professional. Contractions always. No corporate language.
- Questions: Frequent. One per message. Direct and specific, not open-ended.
- Emoji: Never.
- Humor: Occasional dry humor. Self-aware, not try-hard.
- Jargon: Uses industry terms naturally ("discovery → engagement conversion", "cohort fill", "feast or famine") but avoids marketing-speak.
- Sentence structure: Short, punchy. Uses dashes instead of commas.
- Contractions: Always. "don't", "I'm", "can't".
- Fillers: "honestly", "curious about", "makes sense".
- Punctuation: Dashes over commas. Light on exclamation marks. Occasional double-dash for asides.

WORDS THEY USE: "discovery → engagement conversion", "cohort fill", "feast or famine", "makes sense", "honestly", "curious about", "no rush"
WORDS THEY NEVER USE: "synergy", "leverage", "circle back", "touch base", "I hope this finds you well", "I'd love to", "excited to"
```

## Advanced: Batch Voice Matching

If drafts already exist in the pipeline that were created before the voice profile was set up, re-read and adjust them.

### Step 1: Find conversations with existing drafts

```
search_conversations(my_turn=true, limit=50)
```

Fetch each and check for `draft_message`:

```
get_conversation(id="<conversation_id>")
```

### Step 2: Re-draft in the user's voice

For each conversation with an existing draft that does not match the voice profile, rewrite it:

```
update_conversation(
  id="<id>",
  draft_message="[rewritten draft matching voice profile]",
  ai_notes="Re-drafted to match voice profile. Changed: [what was adjusted]."
)
```

### Step 3: Save re-drafted messages

Draft messages require `update_conversation` -- one call per conversation:

```
update_conversation(
  id="abc",
  draft_message="[re-voiced draft]",
  ai_notes="Re-drafted to match voice profile. Changed: [what was adjusted]."
)
```

Repeat for each conversation. `bulk_update` does not support `draft_message`.

## Guidelines

- Analyze patterns, not individual messages. One sarcastic message does not mean they are always sarcastic.
- Collect from varied contexts -- cold opens, follow-ups, casual replies, negotiations.
- Never over-polish. If the user writes "that's cool" do not upgrade it to "that's a compelling insight."
- Watch for AI tells to explicitly exclude: "I'd be happy to," "absolutely," "I wanted to reach out," "hope this message finds you well."
- The voice profile is the baseline. Skills that draft messages should also mirror the prospect's style slightly (see mirroring rules in `references/voice-profile-template.md`).
- One draft per conversation. A new draft overwrites the previous one.

## Related Skills

- **onboarding-walkthrough** — The setup arc starts here. Archetype detection (Step 0) flags voice tendencies upfront.
- **icp-definition** — Complementary setup. ICP defines who to target, voice defines how to sound. Use the archetype templates there to inform voice tendencies here.
- **stage-configuration** — Next step in the setup arc after voice. Stages tie the voice work to actual pipeline shape.
- **dm-writing** — Consumes the voice profile when drafting individual messages
- **batch-drafting** — Uses the voice profile (via `shared_bundle`) for bulk message generation
