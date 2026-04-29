---
name: pipeline-cleanup
description: >
  Batch cleanup of stale, ghosted, and unclassified conversations to keep the
  active pipeline focused on real opportunities. Use when the user says "clean up
  my pipeline", "archive stale conversations", "pipeline hygiene", "batch
  classify", "clean my pipeline", "purge dead conversations", "pipeline is
  cluttered", or "too many conversations". Finds stale and ghosted conversations,
  applies archive/re-engage decisions, classifies unclassified threads, and
  reports results. Related: full-morning-triage for daily pipeline processing,
  batch-drafting for writing messages at scale, cold-rescue for reviving
  specific cold conversations, pipeline-health-check for diagnosing pipeline
  problems.
metadata:
  version: "1.0"
  author: linkninja
---

# Pipeline Cleanup

Purge stale conversations, archive dead threads, classify unprocessed conversations, and draft re-engagement messages for the ones worth saving. One session, clean pipeline.

## Before Starting

1. Run `get_context()` to load the user's current sales context
2. Run `get_stats()` to get the current state
3. Check prerequisites:

| Check | How | If Insufficient |
|-------|-----|-----------------|
| Total conversations | Pipeline stats total count | Need at least 10 conversations. If fewer: "Your pipeline is small enough to manage manually. Come back when it grows." |
| ICP defined | Check `additional_context` from `get_context()` | Cleanup still works. Archive decisions will be less precise without ICP. Note borderline cases for manual review. |
| Stale/ghosted count | Freshness breakdown from `get_stats()` | If zero stale/ghosted: "Your pipeline looks healthy. No stale conversations to clean up." Check for unclassified instead. |

4. Summarize the pipeline state to the user before starting:

> "Your pipeline has [X] conversations. [Y] are stale, [Z] are ghosted. [W] are unclassified. Here's what I'll do: review stale conversations for archive/re-engage decisions, clean up ghosted threads in opening stage, classify unprocessed conversations, and give you a full report."

## Workflow

### Phase 1: Stale Conversations

Find all stale conversations:

```
search_conversations(freshness="stale", compact=true)
```

If `has_more` is true, paginate:

```
search_conversations(freshness="stale", compact=true, page=2)
```

For each stale conversation, fetch the full thread to make an informed decision:

```
get_conversation(id="<id>")
```

Apply the decision rules:

| Situation | Signals | Action | Archive Reason |
|-----------|---------|--------|---------------|
| Had real engagement + stated need | Buying signals in thread, they shared a problem | Re-engage: draft + reminder | -- |
| No buying signals + 14+ days silence | Only small talk, no mention of need/budget/timeline | Archive | `ghosted` |
| Clearly not ICP | Wrong role, industry, company size, or selling to you | Archive | `not_a_fit` |
| Said "not right now" | Explicit timing objection: "maybe next quarter", "not yet" | Archive + long reminder (30-90 days) | `later` |
| Valuable connection, not a buyer | Industry peer, good rapport, but no purchase intent | Archive | `networking` |
| Became a client through other channels | Already paying, conversation was pre-sale | Archive | `client` |
| Personal relationship | Friend, family, non-business connection | Archive | `personal` |

For borderline cases: when unsure between archive and re-engage, check these tiebreakers:

| Tiebreaker | Re-engage | Archive |
|------------|-----------|---------|
| Last message had substance | Yes, they shared something real | No, it was "thanks" or a thumbs-up |
| They match ICP | Yes | No or unclear |
| You have something new to offer | Yes, a new angle or resource | No, you'd just be "checking in" |
| Message count before going quiet | 4+ exchanges | 1-2 exchanges |

For re-engagement candidates, draft a personalized message. Reference something specific from the conversation thread. Never "just checking in."

Save re-engagement drafts individually, then batch archives and reminders:

```
// Save drafts one at a time (bulk_classify does not support draft_message)
update_conversation(id="abc", draft_message="Hey Sarah, been thinking about what you said about onboarding speed...", ai_notes="Re-engagement. Had buying signals (budget mentioned) before going quiet 3 weeks ago.")
// ...repeat for each re-engagement draft

// Batch archives, reminders, and other non-draft updates
bulk_update(updates=[
  {"id": "abc", "reminder": "in 7 days"},
  {"id": "def", "archive": {"archived": true, "reason": "ghosted"}, "ai_notes": "No reply after 3 follow-ups over 5 weeks. No buying signals in thread."},
  {"id": "ghi", "archive": {"archived": true, "reason": "not_a_fit"}, "ai_notes": "Recruiter pitching staffing services. Not a prospect."},
  {"id": "jkl", "archive": {"archived": true, "reason": "later"}, "reminder": "in 60 days", "ai_notes": "Said 'maybe Q3.' Setting 60-day reminder to re-engage."},
  {"id": "mno", "archive": {"archived": true, "reason": "networking"}, "ai_notes": "Industry peer. Great connection, shares content, not a buyer."}
])
```

If more than 100 updates, split into multiple `bulk_update` calls (max 100 per call).

### Phase 2: Ghosted Openers

Find conversations stuck in opening where they never replied:

```
search_conversations(stage="opening", freshness="they_ghosted", compact=true)
```

These are the lowest-value stale conversations. Most should be archived unless the prospect is clearly ICP.

For each, a quick check is sufficient. If you already loaded context from Phase 1 `get_context()`, use ICP to filter:

- **Matches ICP:** One final re-engagement attempt with a completely different angle, then archive if no reply.
- **Doesn't match ICP:** Archive as `not_a_fit`.
- **Can't tell:** Archive as `ghosted`.

```
// Save re-engagement drafts one at a time
update_conversation(id="pqr", draft_message="Hey Alex, came across this [resource] and thought of you given your work in [their field]...", ai_notes="Final re-engagement attempt. Matches ICP but never replied to opener. New angle with value-add.")

// Batch archives and reminders
bulk_update(updates=[
  {"id": "pqr", "reminder": "in 5 days"},
  {"id": "stu", "archive": {"archived": true, "reason": "not_a_fit"}, "ai_notes": "Student account. Not ICP."},
  {"id": "vwx", "archive": {"archived": true, "reason": "ghosted"}, "ai_notes": "No reply to opener after 3 weeks. Generic headline, can't determine ICP fit."}
])
```

### Phase 3: Unclassified Conversations

Find and classify conversations that haven't been processed yet.

**For manageable volumes (under 100):**

```
export_conversations(unclassified_only=true, include_messages=true)
```

Paginate if `has_more` is true.

Read each conversation. Determine stage, tags, and summary using the stage classification decision tree:

```
Did they reply at all?
  NO  -> opening
  YES -> Is their reply a buying signal?
    NO  -> chatting
    YES -> Has a call been scheduled?
      NO  -> qualified
      YES -> Has a proposal been sent?
        NO  -> discovery
        YES -> Have they confirmed?
          YES, confirmed -> won
          YES, declined  -> lost
          NO             -> closing
At any point: clearly not ICP? -> not_a_fit (archive)
```

Submit all classifications:

```
bulk_update(updates=[
  {"id": "abc", "stage": "chatting", "tags": [], "summary": "Early rapport. Asked about his work.", "ai_notes": "No buying signals. General industry conversation."},
  {"id": "def", "stage": "qualified", "tags": ["decision_maker", "urgent"], "summary": "CTO needs analytics tool by end of Q1.", "ai_notes": "Explicit timeline and authority confirmed."},
  {"id": "ghi", "archive": {"archived": true, "reason": "not_a_fit"}, "ai_notes": "Selling SEO services. Not a prospect."}
])
```

**For large backlogs (100+):**

Use server-side batch classification:

```
start_batch_classify(unclassified_only=true, limit=500)
```

Check progress:

```
get_job_status(job_id="<job_id>")
```

Repeat `get_job_status` until status is "completed."

**Hybrid approach (recommended for 100+ conversations):**

1. Run server-side batch for the bulk: `start_batch_classify(unclassified_only=true, limit=500)`
2. While waiting, manually review the first page of exports for edge cases
3. After server-side completes, spot-check results: `search_conversations(stage="qualified", compact=true)` -- do these look right?
4. Override any misclassifications with `bulk_update`

### Phase 4: Report

After all phases, summarize results:

```
## Pipeline Cleanup Complete

**Processed:** [X] conversations total

### Stale Conversations: [Y] processed
- [A] re-engagement drafts saved (review in dashboard)
- [B] archived as ghosted
- [C] archived as not_a_fit
- [D] archived as later (reminders set)
- [E] archived as networking
- [F] archived as other reasons

### Ghosted Openers: [Z] processed
- [G] final re-engagement attempts drafted
- [H] archived

### Unclassified: [W] processed
- [I] classified and staged
- [J] archived as not_a_fit

### Reminders Set: [total reminder count]
- Re-engagement follow-ups: [count] (3-7 day reminders)
- Long-term check-backs: [count] (30-90 day reminders)

### Next Steps
- Review [A + G] draft messages in your dashboard and send the ones you approve
- [Any specific recommendations based on what was found]
```

## Guidelines

- Always fetch full threads before making archive decisions on stale conversations. Don't archive based on metadata alone.
- For ghosted openers (Phase 2), a quick metadata check is sufficient if the volume is high. Full thread review is only needed for ICP matches.
- Use `compact=true` on `search_conversations` when you only need IDs. Saves bandwidth.
- Stay under batch limits: `bulk_update` accepts max 100 per call. Split larger batches.
- Always include `ai_notes` on every update. Explain the archive reason or re-engagement rationale.
- Never send messages. Save drafts via `draft_message`. The user reviews and sends.
- Paginate every `search_conversations` and `export_conversations` call. If `has_more` is true, get the next page.
- For re-engagement drafts, reference something specific from the conversation. Never "just checking in."
- If `get_stats` shows zero stale/ghosted, skip to Phase 3 (unclassified) or tell the user the pipeline is clean.
- If ICP is not defined, be conservative on borderline archive decisions. Flag uncertain cases for the user.
- `bulk_update` supports stage, tags, summary, ai_notes, reminder, and archive. Draft messages must be saved individually via `update_conversation`.
- For the hybrid approach (Phase 3), let the server-side job run while you manually review edge cases. Don't wait idle.

## Related Skills

- **full-morning-triage** — Daily pipeline processing (hot leads, cold follow-ups, new threads)
- **batch-drafting** — Write messages at scale for a specific stage or segment
- **cold-rescue** — Focused re-engagement for cold conversations worth saving
- **pipeline-health-check** — Diagnose pipeline bottlenecks and conversion issues
- **won-deal-analysis** — Analyze patterns in closed deals to refine targeting
