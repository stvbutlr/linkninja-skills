# Signal-to-Stage and Signal-to-Tag Mapping

Use these tables when classifying conversations. Look for specific phrases and behaviors, not gut feeling.

## Signal-to-Stage Tables

### Opening Signals

| Signal | Example |
|--------|---------|
| No reply at all | Sent message, no response |
| Connection accepted, silence | They accepted but never messaged |
| Auto-reply only | "Thanks for connecting!" (LinkedIn auto-message) |

### Chatting Signals

| Signal | Example |
|--------|---------|
| Casual acknowledgment | "Thanks!", "Interesting!", thumbs-up |
| General conversation | "Yeah, we deal with that too" |
| Questions about you | "What do you do exactly?" |
| Sharing general info | "We're a team of 30 in fintech" |
| Polite engagement | "That's a good point" |
| Vague interest | "Sounds cool", "I'd be open to hearing more" |

### Qualified Signals (Buying Signals)

| Signal | Example |
|--------|---------|
| **Need** | "We're struggling with X", "Our current solution doesn't do Y" |
| **Budget** | "What does it cost?", "We have budget for this quarter" |
| **Authority** | "I make that decision", "I'd need to loop in my CTO" |
| **Timeline** | "We need this by Q2", "This is becoming urgent" |
| Solution shopping | "We're looking at a few options" |
| Specific pain | "We lost 3 deals last month because of X" |
| Pricing request | "Can you send me your pricing?" |

### Discovery Signals

| Signal | Example |
|--------|---------|
| Call scheduled | "Let's hop on a call Thursday at 2" |
| Deep requirements | "Here's what we need specifically: 1) 2) 3)" |
| Stakeholder intro | "Let me loop in our CTO" |
| Proposal request | "Can you put together a proposal?" |

### Closing Signals

| Signal | Example |
|--------|---------|
| Proposal acknowledged | "Got the proposal, reviewing it now" |
| Negotiating | "Can you do it for $X?" |
| Internal approval | "Running it by the board this week" |
| Near-commitment | "This looks good, just need to finalize" |

### Won / Lost / Not-a-Fit

| Stage | Signal | Example |
|-------|--------|---------|
| Won | Explicit yes | "Let's do it", "Send over the contract" |
| Lost | Explicit no | "We've decided to go another direction" |
| Lost | Competitor chosen | "We went with [competitor]" |
| Lost | Ghosted after engagement | 2+ follow-ups after proposal, no response |
| Not-a-fit | Selling to you | "I help companies with..." as their first message |
| Not-a-fit | Wrong ICP | Role/industry clearly outside target |

## Edge Cases

| Situation | Classification | Reasoning |
|-----------|---------------|-----------|
| "Thanks" or one-word reply | chatting | They acknowledged you, but no buying signal |
| Pricing question alone (no other context) | chatting (note it) | Curiosity, not qualification |
| Pricing question + stated need | qualified + `budget_confirmed` | Real buying signal |
| Signals from multiple stages | Use the highest stage | Discovery > qualified > chatting |
| Old conversation reactivated | Reassess from current signal | Trust decays — don't assume prior stage still holds |
| They replied but clearly not a fit | not_a_fit | Skip chatting, archive directly |
| "Let me think about it" after proposal | closing + `going_cold` tag | Not lost yet, set follow-up reminder |
| Routed to colleague | chatting + `referral` tag | New conversation with colleague starts at opening |

## Tag Application Guide

Apply tags based on **evidence**, not assumption.

| Tag | Apply When | Do NOT Apply When |
|-----|-----------|-------------------|
| `decision_maker` | They confirm authority: "I make that call", "It's my budget", C-suite/VP/Director title | Just because they're senior — they may not own this decision |
| `budget_confirmed` | Explicit money mention: "What does it cost?", "We have $X allocated" | General questions about services |
| `urgent` | Time pressure: "Need this by [date]", "This is critical" | General interest without deadline |
| `competitor_mentioned` | Named competitor or evaluating alternatives | General industry awareness |
| `referral` | Conversation originated from introduction | They just mention knowing someone |
| `going_cold` | Replies getting shorter/slower, 2+ unanswered follow-ups | Just because 3 days passed |
| `champion` | They advocate internally: "I pitched this to my team" | General enthusiasm |
| `technical_buyer` | Evaluating on technical merit: "Does it integrate with X?" | General feature questions |
