---
name: cold-rescue
description: >
  Find and re-engage cold, ghosted, and archived conversations worth reviving.
  Applies decision rules to each conversation: re-engage with a draft, archive with
  reason, or set a long reminder. Use when the user says "rescue cold conversations",
  "re-engage", "ghost recovery", "re-engagement sprint", "revive dead leads",
  "follow up on cold", "clean up my ghost pile", or "what about people who stopped
  replying". Includes re-engagement sprint for bulk revival of archived conversations.
  Related: full-morning-triage for daily cold handling, batch-drafting for bulk
  messages, dm-writing for individual messages, pipeline-cleanup for broader cleanup.
metadata:
  version: "1.0"
  author: linkninja
---

# Cold Rescue

Systematically work through cold and ghosted conversations, decide which are worth re-engaging, draft re-engagement messages, and archive the rest with proper reasons. Turns a stale pipeline into actionable next steps.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check context:

| Field | Required | If Empty |
|-------|----------|----------|
| `additional_context` (ICP) | Recommended (not blocking) | Can proceed, but ICP helps decide which cold conversations are worth rescuing. Mention: "Your ICP would help me prioritize which conversations to rescue. Want to set it up?" |
| `voice_profile` | Recommended | Re-engagement messages need to sound like the user. Point to **voice-profile-setup**. |
| `positioning_context` | Helpful | Knowing the offer helps craft value-add re-engagement messages. |

3. Run `get_stats()` to see the scope of the problem: how many cold, ghosted, and stale conversations exist.

## Workflow

### Step 1: Find Cold Conversations

Pull conversations in different cold states:

**Cold conversations where it's your turn:**
```
search_conversations(freshness="cold", my_turn=true, limit=50)
```

**Conversations where they ghosted after qualification:**
```
search_conversations(freshness="they_ghosted", stage="qualified", limit=50)
```

**Stale conversations (oldest, least active):**
```
search_conversations(freshness="stale", limit=50)
```

**Cold conversations where you ghosted them:**
```
search_conversations(freshness="you_ghosted", limit=50)
```

Handle `has_more` -- if there are more results, paginate:
```
search_conversations(freshness="cold", my_turn=true, limit=50, page=2)
```

### Step 2: Triage Each Conversation

For each conversation, fetch the full transcript:

```
get_conversation(id="<conversation_id>")
```

Apply the decision rules:

| Situation | Signal | Action |
|-----------|--------|--------|
| Had real engagement + stated need | They mentioned a problem, budget, or timeline before going quiet | **Re-engage** -- draft + 7-day reminder |
| Qualified but ghosted | Was in qualified/discovery, then silence | **High-priority re-engage** -- more effort, reference specific discussion |
| Said "not right now" | Explicit timing objection | **Archive as `later`** + 30-60 day reminder |
| No buying signals + long silence | Only chatted casually, 14+ days ago | **Archive as `ghosted`** |
| Not ICP on closer look | Their role/industry doesn't match after reading the thread | **Archive as `not_a_fit`** |
| They were selling to you | Pitched their own product/service | **Archive as `not_a_fit`** |
| Valuable relationship but not a buyer | Networking, referral source, industry peer | **Archive as `networking`** |

### Step 3: Draft Re-engagement Messages

For conversations worth re-engaging, draft messages that follow these rules:

**Every re-engagement message must:**
1. Reference something specific from the previous conversation
2. Add new value (an insight, update, resource, or question)
3. Be short (2-3 sentences max)
4. Include an easy out ("no worries if things have moved on")
5. NOT mention the gap or guilt-trip about silence

**Re-engagement patterns by situation:**

**Had real engagement + stated need:**
> "Hey [name] -- was thinking about what you said about [specific problem they mentioned]. [New insight, data point, or question about their situation]. Curious if that's still on your radar?"

**Qualified but ghosted (high priority):**
> "Hey [name] -- something came across my desk that reminded me of our conversation about [specific topic]. [Relevant insight or update]. No pressure -- just thought of you."

**You ghosted them (your fault):**
> "Hey [name] -- I owe you an apology, your message slipped through the cracks. [Pick up the thread where it left off]. Still relevant?"

**Seasonal or event-based re-open:**
> "Hey [name] -- [seasonal trigger: new quarter, budget cycle, industry event] got me thinking about [their situation]. How did things shake out with [thing they were working on]?"

### Step 4: Batch Process

Once you have triaged and drafted for a batch, apply updates in bulk:

**Re-engage batch** (drafts saved individually, then reminders batched):
```
// Save drafts one at a time (bulk_classify does not support draft_message)
update_conversation(id="abc", draft_message="Hey Sarah… was thinking about what you said about discovery calls not converting…", ai_notes="Cold rescue. Last active 3 weeks ago. Had real engagement: she mentioned discovery → engagement conversion was costing her. Re-engaging with new insight.")
update_conversation(id="def", draft_message="Hey James… something reminded me of our cohort-launch conversation…", ai_notes="Cold rescue. Qualified but ghosted 2 weeks ago. Was discussing scaling his coaching program past first cohort. High-priority re-engage.")

// Batch reminders
bulk_update(updates=[
  {id: "abc", reminder: "7 days from now"},
  {id: "def", reminder: "7 days from now"}
])
```

**Archive batch:**
```
bulk_update(updates=[
  {
    id: "ghi",
    archive: {archived: true, reason: "ghosted"},
    ai_notes: "Cold rescue triage. No buying signals. Casual chat only. 3+ weeks silent."
  },
  {
    id: "jkl",
    archive: {archived: true, reason: "not_a_fit"},
    ai_notes: "Cold rescue triage. On review, they're a recruiter pitching staffing services."
  },
  {
    id: "mno",
    archive: {archived: true, reason: "later"},
    reminder: "60 days from now",
    ai_notes: "Cold rescue triage. Said 'not right now' on Feb 5. Real prospect. Check back in April."
  }
])
```

Max 100 per `bulk_update` call.

### Step 5: Set Follow-Up Cadence for Re-engaged

After the user sends the re-engagement drafts, track responses:

| Re-engagement Response | Next Step |
|-----------------------|-----------|
| They replied | Move back to appropriate stage. Draft a response. |
| No reply after 7 days | Send one more value-add follow-up (different angle). |
| No reply after 14 days | Archive as `ghosted`. Set 60-day reminder if they were high-value. |
| "Not right now" | Archive as `later`. Set 30-60 day reminder. |
| "Not interested" | Archive as `ghosted`. No reminder. Respect the no. |

## Re-engagement Sprint (Advanced)

A concentrated push to revive archived conversations that may have become relevant again. Run quarterly or when the pipeline feels thin.

### Step 1: Find archived conversations worth reviving

Search archived conversations. Filter results by archive reason — `later` and `lost` are the best candidates for revival:

```
search_conversations(include_archived=true, limit=50)
```

From the results, focus on conversations archived with reason `later` (timing-deferred prospects) and conversations in `lost` stage:

```
search_conversations(include_archived=true, stage="lost", limit=50)
```

### Step 2: Fetch and evaluate each

```
get_conversation(id="<conversation_id>")
```

**Re-engage if:**
- Original archive reason was `later` and the reminder window has passed
- They were `lost` to timing (not fit or competitor)
- Their situation may have changed (new role, new quarter, industry shift)
- They were a strong ICP match

**Leave archived if:**
- Archive reason was `not_a_fit` -- still not a fit
- They explicitly said "never contact me again"
- They went to a competitor and are likely still with them
- Original conversation had no substance

### Step 3: Unarchive and draft

For conversations worth reviving, unarchive in batch, then save drafts individually:

```
// Batch unarchive + stage updates
bulk_update(updates=[
  {id: "abc", archive: {archived: false}, stage: "chatting", reminder: "7 days", ai_notes: "Re-engagement sprint. Originally archived as 'later' on [date]. Reason: [reason]. Re-engaging because [justification]."},
  ...
])

// Save drafts one at a time (bulk_classify does not support draft_message)
update_conversation(id="abc", draft_message="Hey [name] -- it's been a while. [Seasonal hook or new development]. How did things go with [thing from original conversation]?")
// ...repeat for each conversation
```

### Step 4: Track sprint results

After the sprint:

```
get_stats()
```

Count: how many re-engaged, how many replied, how many re-archived. Feed patterns back to future rescue efforts.

## Decision Quick Reference

```
For each cold conversation, ask in order:

1. Are they ICP?
   NO → archive as not_a_fit

2. Did they express a real need?
   YES → re-engage (draft + 7-day reminder)
   NO → continue to #3

3. Were they qualified or further?
   YES → high-priority re-engage (more effort)
   NO → continue to #4

4. Did they say "not right now"?
   YES → archive as later + 30-60 day reminder
   NO → continue to #5

5. Has it been 14+ days with no signal?
   YES → archive as ghosted
   NO → send one value-add follow-up first
```

## Guidelines

- Always `get_conversation` the full conversation before deciding. Summaries miss nuance.
- Never guilt-trip about silence. "I noticed you haven't replied" kills trust.
- Before drafting re-engagement messages, call `get_draft_prompt(id, reply_intent="nurture")` first — it returns server-rendered voice-enforced context tuned for nurture/re-engagement. Save via `update_conversation`.
- Never send messages directly. Save as drafts via `draft_message`.
- Always include `ai_notes` explaining the rescue decision and reasoning.
- Reference something specific from the previous conversation. Generic re-opens get generic silence.
- Follow the playbook cadence: Day 1 / 3 / 7 / extending intervals. Each touch must add new value (insight, observation, question — never "just checking in"). 80% of sales close after the 5th touchpoint, so don't archive prematurely. Archive only after the cadence is exhausted with no engagement.
- When you ghosted them, own it. A brief "slipped through the cracks" builds more trust than pretending it didn't happen.
- Batch processing is the key to throughput. Triage first, save drafts individually via `update_conversation`, then batch non-draft updates (reminders, archives, tags) via `bulk_update`.
- Do not re-engage more than 20-30 conversations at once. The user needs to handle replies.

## Related Skills

- **full-morning-triage** -- Handles daily cold conversation triage as part of morning routine
- **batch-drafting** -- For high-volume re-engagement message drafting
- **dm-writing** -- Router for identifying the right DM skill per situation
- **reply-handling** -- For crafting replies when cold prospects re-engage
- **pipeline-cleanup** -- Broader cleanup that includes archiving, not just cold rescue
- **pipeline-health-check** -- Diagnose why conversations are going cold in the first place
