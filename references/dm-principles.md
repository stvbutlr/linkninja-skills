# DM Writing Principles

8 universal rules that apply to every LinkedIn DM, regardless of situation.

## The Rules

### 1. One thing per message

Don't pitch, qualify, AND close in the same DM. Each message does one job: build connection, ask a question, reduce risk, or make an invitation. Trying to do three things means none of them land.

### 2. Sound like you have a full calendar

The energy of "I'm inviting you to something valuable" gets replies. The energy of "I need this" gets ignored. This is not faking — it is remembering that you are offering something worthwhile, not chasing.

### 3. Ask before you tell

Questions before pitches. Always. At least two or three questions that show you understand their world before suggesting anything.

### 4. Every follow-up deposits value

No "just checking in." No "did you see my last message?" Every follow-up adds something: an insight, a relevant resource, a question tied to their situation. If you have nothing to add, wait until you do.

### 5. Match the prospect's energy

If they write short, write short. If they're formal, be formal. If they're enthusiastic, match it. Mirror their communication style — it builds subconscious rapport.

### 6. Reduce perceived risk

The bigger the ask, the more risk they feel. Reduce it: "no pressure," "happy to share a quick example," "just 15 minutes." Make it easy to say yes and safe to say no.

### 7. Reference something real

Generic messages get generic responses (or none). Reference their headline, a post they wrote, a mutual connection, their company's recent news. Something that proves you're not copy-pasting.

### 8. Know when to stop

After 2 follow-ups with no reply, stop. Do not chase. They know how to find you. Move to monthly nurture cadence or archive. Persistence is good; pestering destroys trust permanently.

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| "Just checking in" | Share an insight relevant to their situation |
| "I hope this message finds you well" | Start with something specific about them |
| Wall of text on first message | 2-3 sentences max, one question |
| Pitch in the first message | Ask a question about their world |
| "Let me know if you're interested" | Make a specific, low-risk invitation |
| Follow up 3+ times with no reply | Stop after 2. Archive or monthly nurture. |
| Use words they'd never use | Mirror their vocabulary and jargon |
| Send the same template to everyone | Reference something unique about each person |

## Draft Rules for AI

- **Never pretend to send messages.** Always save as drafts via `draft_message`. The user reviews and sends from their dashboard.
- **Always include `ai_notes`.** Explain: what signal you responded to, what the draft is trying to accomplish, what the expected next step is.
- **Match the user's voice.** Read their voice profile from `get_context()`. Use their greeting style, formality level, vocabulary, and sentence length.
- **One draft per conversation.** A new draft overwrites the previous one.
