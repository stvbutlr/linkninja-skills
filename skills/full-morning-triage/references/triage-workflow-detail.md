# Full Morning Triage — 12-Step Workflow Detail

The complete compound workflow with every tool call, decision rule, and edge case. This is the reference for executing the full triage as described in the SKILL.md.

## Step 1: Load Context

```
get_context()
```

Check that `additional_context` (ICP) is populated. If empty, stop and run **icp-definition** first. Note the `voice_profile` for draft tone matching. Note `ghost_after_days` and `cold_after_days` freshness thresholds.

## Step 2: Pipeline Snapshot

```
pipeline_stats()
```

Record these numbers for the report:

| Metric | Where to Find It |
|--------|-----------------|
| Stage counts | `stages` array — count per stage |
| My-turn counts | `my_turn` per stage — these are urgent |
| Freshness breakdown | `fresh`, `cold`, `you_ghosted`, `they_ghosted`, `stale` counts |
| Total active | Sum of all non-archived conversations |

## Step 3: Find Hot Leads (Qualified+, Fresh, My Turn)

```
search(my_turn=true, freshness="fresh", stage="qualified")
```

```
search(my_turn=true, freshness="fresh", stage="discovery")
```

```
search(my_turn=true, freshness="fresh", stage="closing")
```

These are the highest-priority conversations. People with confirmed buying signals waiting for a reply.

## Step 4: Find Remaining Fresh Replies

```
search(my_turn=true, freshness="fresh")
```

This catches chatting and opening stage conversations that also have fresh replies. Deduplicate against Step 3 results.

## Step 5: Draft Responses for All Hot Leads

For each conversation from Steps 3-4:

```
fetch(id="<conversation_id>")
```

Read the full thread. Determine the DM situation:

| Stage | Likely Situation | Draft Approach |
|-------|-----------------|----------------|
| qualified | They showed a buying signal | Confirm the signal, ask deepening question, guide toward next step |
| discovery | Call booked or deep analysis | Prepare for call, share relevant prep |
| closing | Proposal sent, negotiating | Address specific blockers, reduce risk |
| chatting | They just replied | Acknowledge, ask a question, don't pitch |
| opening | First reply received | Celebrate internally, build rapport |

Draft each message following dm-principles:
- One thing per message
- Match their energy and vocabulary
- Reference something specific from the thread
- 2-4 sentences max
- Include an easy out where appropriate

## Step 6: Save Hot Lead Drafts (Batch)

```
bulk_classify(updates=[
  {
    id: "conv_abc",
    draft_message: "Hey Sarah, great question on pricing. For a team your size, most clients see ROI within the first quarter. Want me to walk you through the numbers for a 50-person org?",
    ai_notes: "Replied to pricing question. Reframed around ROI. She's VP Sales at mid-market SaaS. Next: wait for budget confirmation."
  },
  {
    id: "conv_def",
    draft_message: "Hey Marcus, that's a good point about the timeline. Most teams in your situation start seeing results in 60-90 days. Is Q2 still your target?",
    ai_notes: "Acknowledged timeline concern. Confirmed realistic timeline. He mentioned Q2 deadline. Next: if Q2 confirmed, propose call."
  },
  {
    id: "conv_ghi",
    draft_message: "That's a real bottleneck. Are you finding the issue is more about sourcing quality candidates, or about getting them productive once they start?",
    ai_notes: "They mentioned hiring 5 SDRs. Asked deepening question to surface specific pain. Stage: chatting. Next: qualify based on answer."
  }
])
```

Record: **N hot lead drafts saved.**

## Step 7: Find and Process Cold Conversations

```
search(freshness="cold", my_turn=true, compact=true)
```

For each:

```
fetch(id="<id>")
```

Read the thread. Draft a value-add follow-up. Options by conversation context:

| Last Topic | Follow-Up Approach |
|------------|-------------------|
| They mentioned a specific problem | Share an insight or result related to that problem |
| They asked about your work | Share a relevant case study or example |
| General rapport conversation | Ask a specific question about something they mentioned |
| They shared industry news | Build on it with your perspective |

Never send:
- "Just checking in"
- "Bumping this"
- "Did you see my last message?"

## Step 8: Save Cold Rescue Drafts (Batch)

```
bulk_classify(updates=[
  {
    id: "conv_jkl",
    draft_message: "Hey James, was working with another team this week who had the same ramp-time problem you mentioned. They found that restructuring the first 30 days made the biggest difference. Thought you'd find that interesting.",
    reminder: "in 3 days",
    ai_notes: "Re-engagement attempt #1. Shared relevant insight about SDR ramp time. Last topic was onboarding challenges."
  },
  {
    id: "conv_mno",
    draft_message: "Hey Lisa, saw this piece on Q1 demand gen trends and thought of our conversation about scaling your pipeline. Worth a look if you have 2 minutes.",
    reminder: "in 3 days",
    ai_notes: "Re-engagement attempt #1. Shared relevant resource tied to her pipeline scaling comment."
  }
])
```

Record: **M cold rescue drafts saved, M reminders set.**

## Step 9: Find and Process Ghosts

**High-value ghosts (qualified/discovery):**

```
search(freshness="they_ghosted", stage="qualified", compact=true)
```

```
search(freshness="they_ghosted", stage="discovery", compact=true)
```

**Chatting-stage ghosts:**

```
search(freshness="they_ghosted", stage="chatting", compact=true)
```

**Opening-stage ghosts (for archiving):**

```
search(freshness="they_ghosted", stage="opening", compact=true)
```

For each, `fetch(id)` and apply the decision table:

| Stage | Days Silent | Follow-up Count | Action |
|-------|------------|-----------------|--------|
| qualified/discovery | < 7 days | 0-1 | Draft value-add follow-up, reminder in 3 days |
| qualified/discovery | 7-14 days | 1-2 | Draft different angle, reminder in 7 days |
| qualified/discovery | 14+ days | 2+ | Draft door-open message, reminder in 30 days |
| chatting | < 7 days | 0-1 | Draft value-add follow-up, reminder in 3 days |
| chatting | 7-14 days | 1-2 | Draft different angle, reminder in 7 days |
| chatting | 14+ days | 2+ | Archive as `ghosted` |
| opening | 14+ days | 2+ | Archive as `ghosted` |
| opening | < 14 days | 0-1 | Draft one more follow-up |
| Any stage | Any | Any — clearly not ICP | Archive as `not_a_fit` |

## Step 10: Save Ghost Updates (Batch)

```
bulk_classify(updates=[
  {
    id: "conv_pqr",
    draft_message: "Hey Sarah, I remember you mentioned the SDR ramp issue was becoming urgent. Was working on something related this week and thought of you. No rush — just wanted to share if useful.",
    reminder: "in 7 days",
    ai_notes: "Re-engagement attempt #2 for qualified ghost. She had budget signals. Shared new angle. If no reply after this, send door-open in 7 days."
  },
  {
    id: "conv_stu",
    draft_message: "No worries if the timing's off on this, Marcus. Thought of you when a client in fintech mentioned a similar challenge. Happy to pick this up whenever makes sense.",
    reminder: "in 30 days",
    ai_notes: "Door-open message. 3rd attempt. Qualified ghost, 16 days silent. If no reply, archive at 30-day reminder."
  },
  {
    id: "conv_vwx",
    archive: {archived: true, reason: "ghosted"},
    ai_notes: "No reply after 3 follow-ups over 4 weeks. Opening stage. Archiving."
  },
  {
    id: "conv_yza",
    archive: {archived: true, reason: "not_a_fit"},
    ai_notes: "Recruiter pitching staffing services. Not a prospect."
  }
])
```

Record: **P re-engagement drafts, Q archives.**

## Step 11: Classify New Conversations

```
export(unclassified_only=true, include_messages=true)
```

If `has_more` is true:

```
export(unclassified_only=true, include_messages=true, page=2)
```

For each unclassified conversation, read the thread and classify:

**Stage classification decision tree:**

```
Did they reply at all?
  NO  → opening
  YES ↓

Is their reply a buying signal (need, budget, authority, timeline)?
  NO  → chatting
  YES ↓

Has a call/meeting been scheduled or deep needs analysis started?
  NO  → qualified
  YES ↓

Has a proposal/quote been sent?
  NO  → discovery
  YES ↓

Have they confirmed yes or declined?
  YES, confirmed → won
  YES, declined  → lost
  NO             → closing

At any point: Are they clearly not your ICP, selling to you, or spam?
  YES → not_a_fit (archive)
```

**Tag application — evidence only:**

| Tag | Apply When |
|-----|-----------|
| `decision_maker` | They confirm authority or hold C-suite/VP/Director title |
| `budget_confirmed` | Explicit money mention |
| `urgent` | Time pressure stated |
| `competitor_mentioned` | Named competitor or evaluating alternatives |
| `going_cold` | Replies getting shorter/slower, 2+ unanswered follow-ups |

## Step 12: Save Classifications (Batch)

```
bulk_classify(updates=[
  {
    id: "conv_class1",
    stage: "chatting",
    tags: [],
    summary: "Early rapport. They asked about your work.",
    ai_notes: "No buying signals. General industry conversation."
  },
  {
    id: "conv_class2",
    stage: "qualified",
    tags: ["decision_maker", "budget_confirmed"],
    summary: "CTO at Series B SaaS. Needs analytics tool by end of Q1.",
    ai_notes: "Explicit timeline, authority confirmed, asked about pricing."
  },
  {
    id: "conv_class3",
    stage: "not_a_fit",
    archive: {archived: true, reason: "not_a_fit"},
    ai_notes: "Selling SEO services. Not a prospect."
  }
])
```

Record: **R classified, S archived as not-a-fit.**

## Report Template

Deliver this to the user after all phases complete:

```
Morning triage complete.

Pipeline snapshot: [X] opening, [Y] chatting, [Z] qualified, [W] discovery, [V] closing

Actions taken:
- [N] draft responses ready to review (hot leads)
- [M] cold rescue drafts with follow-up reminders
- [P] re-engagement drafts for ghosted conversations
- [R] conversations classified ([S] archived as not-a-fit)
- [Q] conversations archived (ghosted/stale)

Hottest lead: [name] in [stage] — [1-sentence reason why they're hot]

Attention needed:
- [Any conversations requiring user judgment]
- [Any ambiguous classifications]
- [Any high-value ghosts with unusual situations]

Next step: Open your LinkNinja dashboard, review the AI drafts, and hit send.
```

## Edge Cases

| Situation | How to Handle |
|-----------|--------------|
| Pipeline has 50+ unclassified conversations | Use `start_batch_classify()` instead of manual classification. Check with `job_status()`. |
| More than 100 updates in a single phase | Split into multiple `bulk_classify` calls (max 100 each) |
| `search` returns `has_more: true` | Fetch the next page immediately before proceeding |
| Voice profile is empty | Draft in neutral professional tone. Note in report: "Consider setting up your voice profile for better draft quality." |
| Very small pipeline (< 10 conversations) | Skip batch operations. Process individually. Suggest outreach to grow the pipeline. |
| User has `you_ghosted` conversations | Flag prominently in report: "You owe [N] people a reply. These are decaying fast." |
| Conversation is ambiguous (unclear stage) | Flag in report for user decision. Don't force a classification. |
