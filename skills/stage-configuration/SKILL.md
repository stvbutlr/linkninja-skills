---
name: stage-configuration
description: >
  Customize pipeline stage definitions, entrance/exit criteria, and AI classification
  context to match the user's actual sales process. Use when the user says "customize
  my stages", "update stage criteria", "change pipeline stages", "configure stages",
  "fix my classification", "conversations are in the wrong stage", "set up my pipeline",
  or "classification is off". Reviews the 8 default stages and helps tailor criteria.
  Related: icp-definition for setting up the ICP first, pipeline-cleanup for fixing
  misclassified conversations, pipeline-health-check for diagnosing stage issues.
metadata:
  version: "1.0"
  author: linkninja
---

# Stage Configuration

Customize LinkNinja's 8 pipeline stages so the AI classifier matches the user's actual sales process. Default stages work for most users, but the entrance criteria, exit criteria, and AI context should be tailored.

## Before Starting

1. Run `get_context()` to load the user's current sales context
2. Run `stages()` to see current stage definitions with any existing customization
3. Check context:

| Field | Status | Action |
|-------|--------|--------|
| ICP (`additional_context`) | Nice-to-have | If empty, mention: "Setting up your ICP first will make classification more accurate. Want to do that now?" Point to **icp-definition**. |
| Positioning (`positioning_context`) | Helpful | Knowing what the user sells helps tailor stage criteria. Ask if empty. |
| Current stages | Always loaded | Review for existing customization before changing anything. |

4. If the user's complaint is "classification is wrong" -- dig into specific examples before changing stages. The issue may be the ICP, not the stage criteria.

## The 8 Default Stages

| Stage | Trust Level | Entrance Signal | Exit Signal |
|-------|-------------|----------------|-------------|
| `opening` | Stranger | First message sent, no reply | Any reply from prospect |
| `chatting` | Acknowledged | Back-and-forth messages, no buying signals | Budget, authority, need, or timeline mentioned |
| `qualified` | Shared need | Concrete buying signal confirmed | Call/meeting scheduled or proposal requested |
| `discovery` | Credible option | Call booked or deep needs discussion | Proposal or quote sent |
| `closing` | Serious consideration | Proposal sent, negotiating | Confirmed yes or decline |
| `won` | Client | Deal closed, payment/contract confirmed | -- |
| `lost` | Variable | Explicit no or ghosted after engagement | -- |
| `not_a_fit` | N/A | Wrong ICP, spam, selling to user | -- |

These stages represent a trust progression, not an admin checklist. The AI classifier uses the entrance/exit criteria plus the `ai_context` field to decide where a conversation belongs.

## Workflow

### Step 1: Understand the User's Sales Process

Ask these questions to identify how their process differs from the defaults:

**Sales cycle shape:**
- "What does your typical sales process look like, from first message to closed deal?"
- "How long does your average deal take from first contact to close?"
- "Do you sell through calls, proposals, demos, trials, or something else?"

**Stage-specific questions:**

| Stage | Key Question |
|-------|-------------|
| `opening` | "How many follow-ups do you typically send before giving up?" |
| `chatting` | "What signals tell you someone is more than just being polite?" |
| `qualified` | "What must be true before you consider someone a real opportunity?" |
| `discovery` | "What does your discovery process look like -- call, demo, audit, something else?" |
| `closing` | "What happens between proposal and decision? How long does it take?" |
| `won` | "What defines 'won' -- payment, signed contract, verbal yes?" |
| `lost` | "When do you consider a deal truly lost vs just stalled?" |

**Common variations by business type:**

| Business Type | Typical Customization |
|---------------|----------------------|
| High-ticket consulting ($10k+) | Stricter `qualified` criteria: budget confirmation, authority check |
| SaaS / product | `discovery` = demo scheduled. `closing` = trial started or pricing sent. |
| Coaching / services | `qualified` = expressed personal pain + willingness to invest. Less formal. |
| Agency | `discovery` = audit or strategy session. `closing` = proposal with scope. |
| Recruiting | `qualified` = confirmed open role + budget range. `closing` = terms being negotiated. |
| Events / workshops | `qualified` = said yes to attending. `discovery` may not apply. |

### Step 2: Customize Stage Criteria

For each stage the user wants to change, build the update. Only modify what needs changing -- everything else stays as default.

Each stage has 3 customizable fields:

| Field | Purpose | Example |
|-------|---------|---------|
| `entrance_criteria` | What must be true for a conversation to enter this stage | "Prospect confirmed budget over $10k and has decision-making authority" |
| `exit_criteria` | What must happen for a conversation to leave this stage | "Discovery call completed and proposal requested" |
| `ai_context` | Additional instructions for the AI classifier | "Our minimum engagement is $10k/month. Do not qualify conversations below this budget level." |

### Step 3: Save Customized Stages

Save all changes in a single call. Only include stages being modified:

```
update_context(stages=[
  {
    "key": "qualified",
    "entrance_criteria": "[custom criteria]",
    "exit_criteria": "[custom criteria]",
    "ai_context": "[custom instructions]"
  },
  {
    "key": "discovery",
    "entrance_criteria": "[custom criteria]",
    "exit_criteria": "[custom criteria]",
    "ai_context": "[custom instructions]"
  }
])
```

This is a merge update -- only the stages and fields you specify change. All other stages and fields remain at their defaults.

### Step 4: Test Classification (Optional but Recommended)

If the user has existing conversations, run a small batch classification to see if the new criteria produce better results:

```
start_batch_classify(limit=20)
```

Check progress:

```
job_status(job_id="<id>")
```

Then review a few results:

```
search(limit=10)
```

```
fetch(id="<conversation_id>")
```

Ask the user: "Here's how conversations are being classified with the new criteria. Does [conversation X] belong in [stage Y]?"

If results are off, adjust:

```
update_context(stages=[
  {"key": "<stage>", "ai_context": "[refined instructions]"}
])
```

## Customization Examples

### High-Ticket Consulting

```
update_context(stages=[
  {
    "key": "qualified",
    "entrance_criteria": "Prospect confirmed at least 2 of: budget over $10k, decision-making authority, active project with deadline, team size over 20",
    "exit_criteria": "Discovery call completed and proposal requested",
    "ai_context": "Our minimum engagement is $10k/month. Do not qualify conversations where the prospect is clearly below this budget level. Polite interest is not qualification -- look for concrete signals."
  },
  {
    "key": "chatting",
    "ai_context": "If a conversation has been in chatting for more than 14 days with no buying signals, flag as going cold. We want to either qualify or move on within two weeks."
  }
])
```

### SaaS with Demo Flow

```
update_context(stages=[
  {
    "key": "discovery",
    "entrance_criteria": "Demo scheduled or completed. Prospect has seen the product.",
    "exit_criteria": "Trial started or proposal sent with pricing.",
    "ai_context": "We always do a live demo before sending pricing. If pricing was discussed without a demo, keep in qualified."
  },
  {
    "key": "closing",
    "entrance_criteria": "Trial active or proposal sent with specific pricing.",
    "exit_criteria": "Signed up for paid plan or declined.",
    "ai_context": "Trial length is 14 days. If trial expires with no conversion, move to lost unless they asked for an extension."
  }
])
```

### Coaching / Services

```
update_context(stages=[
  {
    "key": "qualified",
    "entrance_criteria": "Prospect expressed a specific personal or professional pain point AND indicated willingness to invest in solving it.",
    "exit_criteria": "Discovery call or strategy session scheduled.",
    "ai_context": "Qualification is less formal here. Look for emotional investment in solving the problem, not just corporate budget language. Phrases like 'I need to figure this out' or 'I can't keep doing this' count as buying signals."
  }
])
```

### Event / Workshop Flow

```
update_context(stages=[
  {
    "key": "qualified",
    "entrance_criteria": "Confirmed they will attend the event or session.",
    "exit_criteria": "Event attended.",
    "ai_context": "For event-based sales, qualified means they said yes to attending. Discovery happens during the event itself."
  },
  {
    "key": "discovery",
    "entrance_criteria": "Attended the event and engaged during the session.",
    "exit_criteria": "Bridge offer made -- proposal or next step presented.",
    "ai_context": "Post-event follow-up is the discovery phase. Reference specific things from the session."
  }
])
```

## Handling Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| Too many conversations stuck in `chatting` | Entrance criteria for `qualified` too strict | Loosen qualified criteria or add time-based flag in chatting `ai_context` |
| Conversations jump from `opening` to `qualified` | Missing nuance in chatting criteria | Add chatting `ai_context`: "A single reply does not mean qualified. Look for 2+ exchanges and buying signals." |
| `qualified` full of people who are just being polite | Entrance criteria too loose | Tighten: require concrete signals (budget, timeline, authority), not just interest |
| Everything lands in `not_a_fit` | ICP too narrow or classifier too aggressive | Check ICP with `get_context()`. Broaden if needed. Add `ai_context`: "Err on the side of keeping in pipeline if unclear." |
| Classification was fine, now it's wrong | ICP or stage criteria changed recently | Review recent changes. Run a test batch and compare. |

## Guidelines

- Always review current stages before making changes. Run `stages()` first.
- Make one round of changes, then test. Do not change all 8 stages at once without verifying.
- The `ai_context` field is the most powerful lever -- it gives the classifier nuanced instructions.
- Entrance/exit criteria should be observable signals, not assumptions about intent.
- If the user says "classification is off," ask for 3-5 specific examples before adjusting anything.
- Stage customization is a merge -- you only send the fields you want to change.
- Tell users they can also edit stages in the dashboard at Settings -> Pipeline Stages.

## Related Skills

- **icp-definition** -- ICP should be set before customizing stages. Classification depends on both.
- **pipeline-cleanup** -- After changing stage criteria, run a cleanup to reclassify existing conversations
- **pipeline-health-check** -- Diagnose pipeline issues that may point to stage misconfiguration
- **full-morning-triage** -- Uses stage definitions to prioritize daily actions
- **cold-rescue** -- Depends on accurate staging to identify rescue-worthy conversations
