# Voice Profile Template

Use this framework to analyze a user's messages and build a voice profile. The profile is saved via `update_context(voice_profile="...")` and used by all skills that draft messages.

## 12 Dimensions to Analyze

| Dimension | What to Extract | Example Spectrum |
|-----------|----------------|-----------------|
| **Message length** | Average word count per message | Short (10-20 words) ↔ Detailed (50-100 words) |
| **Greeting style** | How they start messages | "Hey" / "Hi" / "Hello" / No greeting |
| **Sign-off style** | How they end messages | "Cheers" / "Talk soon" / None (just stops) |
| **Formality level** | Casual to professional spectrum | "gonna" ↔ "going to" / "awesome" ↔ "excellent" |
| **Question ratio** | Questions vs statements | Mostly questions (consultative) ↔ Mostly statements (advisory) |
| **Emoji usage** | Frequency and types | None / Occasional / Frequent / Specific favorites |
| **Humor style** | If and how they joke | Dry / Self-deprecating / None / Industry in-jokes |
| **Industry jargon** | Technical terms vs plain language | "pipeline velocity" ↔ "how fast deals close" |
| **Sentence structure** | Short punchy vs flowing | "Love that." ↔ "I really appreciate you sharing that." |
| **Contractions** | Do they use them? | "I'm" vs "I am" / "don't" vs "do not" |
| **Filler words** | Verbal habits in text | "honestly" / "actually" / "look" / "so" |
| **Punctuation** | Distinctive patterns | Exclamation marks / Ellipses / Dashes / Period-only |

## How to Build a Profile

### Step 1: Collect messages

```
export_conversations(include_messages=true, limit=50)
```

Focus on messages the **user sent** — ignore prospect messages. Need at least 10-15 sent messages.

### Step 2: Read and extract patterns

Look at each dimension. Note recurring patterns, not one-off variations.

### Step 3: Document the profile

Use this format:

```
VOICE PROFILE
- Length: [typical word count and sentence count]
- Greeting: [their standard opening]
- Sign-off: [how they end messages]
- Formality: [casual/professional/hybrid]
- Questions: [frequency and style]
- Emoji: [usage pattern]
- Humor: [style or none]
- Jargon: [terms they use naturally]
- Punctuation: [distinctive patterns]
- Fillers: [habitual words/phrases]

WORDS THEY USE: [list of characteristic phrases]
WORDS THEY NEVER USE: [list of words to avoid]
```

### Step 4: Save

```
update_context(voice_profile="[the profile above]")
```

## Mirroring Rules

When drafting messages, the user's voice is the baseline. Adjust slightly for the prospect:

| Prospect Signal | Adjustment |
|----------------|------------|
| Writes formally | Shift slightly more formal, but keep user's natural style |
| Writes casually | Lean into user's casual side |
| Uses specific jargon | Use their words back to them |
| Writes short messages | Keep replies short |
| Writes detailed messages | Safe to be more thorough |
| High energy | Match their enthusiasm |
| Measured and careful | Be measured and careful |

## What NOT to Do

- Don't import language from a different industry
- Don't over-polish natural phrasing ("that's interesting" → not "that's a fascinating insight")
- Don't invent slang the user doesn't use
- Don't let AI tells leak through: "I'd be happy to," "absolutely," "I wanted to reach out," "I hope this message finds you well"
