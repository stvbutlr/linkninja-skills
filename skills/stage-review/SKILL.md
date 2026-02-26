---
name: stage-review
description: >
  Systematic stage-by-stage reclassification audit that reviews already-classified
  conversations for accuracy. Use when the user says "review my stages", "are my
  conversations in the right stage", "reclassify my pipeline", "audit my
  classifications", "review qualified conversations", "check my chatting
  conversations", "stage audit", or "classification accuracy". Reads threads and
  re-evaluates whether each conversation belongs in its current stage. Does not
  archive stale conversations (see pipeline-cleanup) or classify new ones (see
  full-morning-triage) or change stage definitions (see stage-configuration).
  Related: pipeline-cleanup for archiving stale/ghosted, full-morning-triage for
  classifying unclassified conversations, stage-configuration for changing stage
  definitions, pipeline-health-check for diagnosing conversion problems.
metadata:
  version: "1.0"
  author: linkninja
---

# Stage Review

Review already-classified conversations to check whether they belong in their current stage. Find missed buying signals, premature promotions, and stale classifications. The classification quality-check.

**This skill does NOT:**
- Archive stale conversations (that is **pipeline-cleanup**)
- Classify unclassified conversations (that is **full-morning-triage**)
- Change stage definitions (that is **stage-configuration**)

**This skill DOES:**
- Re-read classified conversation threads
- Compare current stage against the classification decision tree
- Reclassify conversations that are in the wrong stage
- Report misclassification patterns

## Before Starting

1. Run `get_context()` to load the user's sales context (ICP, positioning, stage criteria)
2. Run `stages()` to load stage definitions with entrance/exit criteria
3. Run `pipeline_stats()` to get the current pipeline snapshot

4. Check prerequisites:

| Check | How | If Not Met |
|-------|-----|------------|
| Classified conversations exist | Stage counts from `pipeline_stats()` | "You don't have classified conversations to review yet. Want to classify your pipeline first?" Suggest **full-morning-triage** |
| At least 5 in target stage | Count for the stage the user wants to review | "Only [N] conversations in [stage]. Review them individually with `fetch`." |
| ICP defined | `additional_context` from `get_context()` | Review still works, but not_a_fit detection will be less precise. Note this. |

5. Ask the user: **full pipeline review or specific stage?**

> "Your pipeline has [X] in chatting, [Y] in qualified, [Z] in discovery, [W] in closing. Want me to review the full pipeline, or focus on a specific stage?"

## Operating Modes

| Mode | Method | Best For | Capacity |
|------|--------|----------|----------|
| Manual review | AI reads every thread, re-evaluates stage | Accuracy. Nuanced decisions. | Up to ~50 conversations per session |
| Server-side review | `start_batch_classify` with custom instructions | Speed. Hundreds of conversations. | Up to 500 per job |
| Hybrid | Server-side bulk, then manual spot-check | Best of both. Recommended for 100+ conversations. | Unlimited |

Choose mode based on volume in the target stage(s).

## Classification Decision Tree

Apply this to every conversation during review:

```
Did they reply at all?
  NO  -> opening
  YES |
      v
Is their reply a buying signal (need, budget, authority, timeline)?
  NO  -> chatting
  YES |
      v
Has a call/meeting been scheduled or deep needs analysis started?
  NO  -> qualified
  YES |
      v
Has a proposal/quote been sent?
  NO  -> discovery
  YES |
      v
Have they confirmed yes or declined?
  YES, confirmed -> won
  YES, declined  -> lost
  NO             -> closing

At any point: clearly not ICP? -> not_a_fit (archive)
```

See `references/signal-mapping.md` for specific signal examples per stage.

## Common Misclassification Patterns

Watch for these during review:

| Pattern | Common Error | Correct Stage | Why |
|---------|-------------|---------------|-----|
| They asked "what does it cost?" | Left in chatting | qualified | Pricing question = buying signal (budget) |
| Call scheduled but no proposal yet | Put in closing | discovery | No proposal sent = not closing yet |
| Said "sounds great" but no commitment | Put in closing | qualified or discovery | Enthusiasm is not a decision |
| Went cold after qualifying | Left in qualified | Still qualified, but add `going_cold` tag | Stage is correct; freshness is the issue |
| Sent a pitch, they said "interesting" | Put in qualified | chatting | Polite interest is not a buying signal |
| They asked about your work | Put in qualified | chatting | Curiosity about you is not a stated need |
| Deep requirements shared, no call yet | Left in chatting | qualified | Specific needs = buying signal |
| Proposal sent, waiting for answer | Put in discovery | closing | Proposal out = closing stage |
| They said "not right now" | Left in qualified | lost or archive as `later` | Explicit timing objection = deal stalled |

## Workflow

### Manual Review: Specific Stage

User chose a specific stage to review. Process one stage at a time for full context.

**Step 1: Export the stage**

```
export(stage="<stage>", include_messages=true)
```

Paginate if `has_more` is true:

```
export(stage="<stage>", include_messages=true, page=2)
```

**Step 2: Review each conversation**

For each conversation, read the full thread and answer:

1. Walk the decision tree top to bottom
2. What stage does the decision tree produce?
3. Does it match the current stage?
4. If not: what is the correct stage?
5. Are tags still accurate? Any missing signals?
6. Is the summary still accurate?

Track results in three buckets:

| Bucket | Conversations |
|--------|--------------|
| Correct | Stage matches decision tree output |
| Reclassify | Stage does not match; needs update |
| Borderline | Could go either way; flag for user |

**Step 3: Present findings before acting**

Show the user what you found before making changes:

> "Reviewed [N] conversations in [stage]. Found [M] misclassifications:
> - [Name]: currently [stage], should be [correct stage] because [reason]
> - [Name]: currently [stage], should be [correct stage] because [reason]
> - ...
> [B] borderline cases for your judgment:
> - [Name]: could be [stage A] or [stage B] because [reason]
> Want me to apply these changes?"

**Step 4: Apply reclassifications**

After user confirms:

```
bulk_classify(updates=[
  {"id": "abc", "stage": "qualified", "tags": ["budget_confirmed"], "summary": "Asked about pricing and team size. Buying signal missed.", "ai_notes": "Stage review: reclassified from chatting to qualified. Pricing question is a buying signal."},
  {"id": "def", "stage": "discovery", "tags": ["decision_maker"], "summary": "Call scheduled for Thursday. Deep needs discussed.", "ai_notes": "Stage review: reclassified from closing to discovery. No proposal sent yet."},
  {"id": "ghi", "stage": "chatting", "summary": "General conversation about industry trends.", "ai_notes": "Stage review: reclassified from qualified to chatting. 'Interesting' is polite interest, not a buying signal."}
])
```

Stay under 100 per `bulk_classify` call. Split larger batches.

Always include `ai_notes` starting with "Stage review:" to distinguish reclassification from original classification.

### Manual Review: Full Pipeline

Review stages in this order (highest-impact misclassifications first):

| Order | Stage | Why This Order |
|-------|-------|---------------|
| 1 | qualified | Most impactful misclassification: false positives waste effort, false negatives miss deals |
| 2 | chatting | Largest stage; most likely to contain missed buying signals |
| 3 | discovery | Fewer conversations, but wrong stage here means wrong actions |
| 4 | closing | Critical stage; wrong classification delays decisions |
| 5 | opening | Usually accurate; check for conversations where they replied but stage was not updated |

For each stage, follow the same Steps 1-4 from the specific stage workflow above.

Skip `won`, `lost`, and `not_a_fit` unless the user specifically requests them -- terminal stages rarely need reclassification.

### Server-Side Review

For large volumes (100+ in a stage), use server-side batch classification with review-specific instructions:

```
start_batch_classify(stage="<stage>", instructions="Re-evaluate every conversation in this stage. Apply the classification decision tree strictly: opening (no reply), chatting (no buying signals), qualified (buying signal confirmed), discovery (call scheduled or deep needs), closing (proposal sent), won/lost (confirmed outcome). Reclassify any conversation that does not match its current stage. Pay special attention to: pricing questions left in chatting (should be qualified), polite interest marked as qualified (should be chatting), scheduled calls marked as closing (should be discovery).")
```

Check progress:

```
job_status(job_id="<job_id>")
```

### Hybrid Review (Recommended for 100+)

1. Run server-side for the bulk:

```
start_batch_classify(stage="qualified", instructions="Re-evaluate all qualified conversations. Verify each has a real buying signal: stated need, budget mention, authority confirmation, or timeline. Reclassify to chatting if only polite interest. Reclassify to discovery if a call is already scheduled.")
```

2. While the job runs, manually review a sample:

```
export(stage="qualified", include_messages=true, limit=20)
```

Read 15-20 threads manually. Note any patterns the server-side job might miss.

3. After the job completes, spot-check results:

```
search(stage="chatting", since="1h", compact=true)
```

Were the reclassifications reasonable? Fetch a few to verify:

```
fetch(id="<id>")
```

4. Override any incorrect server-side decisions:

```
bulk_classify(updates=[
  {"id": "abc", "stage": "qualified", "ai_notes": "Stage review override: server reclassified to chatting, but prospect explicitly asked about pricing and team integration. Real buying signal."}
])
```

## Report

After completing the review, deliver:

```
## Stage Review Complete

**Scope:** [full pipeline / specific stage]
**Conversations reviewed:** [N]
**Misclassifications found:** [M] ([X]%)

### Stage Changes

| Conversation | From | To | Reason |
|-------------|------|-----|--------|
| [Name] | chatting | qualified | Pricing question missed |
| [Name] | closing | discovery | No proposal sent yet |
| [Name] | qualified | chatting | Polite interest, not buying signal |
| ... | ... | ... | ... |

### Misclassification Patterns

| Pattern | Count | Direction |
|---------|-------|-----------|
| [e.g., Pricing questions left in chatting] | [N] | chatting -> qualified |
| [e.g., Polite interest over-promoted] | [N] | qualified -> chatting |
| ... | ... | ... |

### Accuracy by Stage

| Stage | Reviewed | Correct | Misclassified | Accuracy |
|-------|----------|---------|---------------|----------|
| qualified | — | — | — | —% |
| chatting | — | — | — | —% |
| discovery | — | — | — | —% |
| closing | — | — | — | —% |

### Recommendations
- [If a pattern is systemic, suggest updating stage criteria via **stage-configuration**]
- [If ICP is causing not_a_fit misses, suggest refining via **icp-definition**]
- [If accuracy is high (>90%), note the pipeline is well-classified]
- [Schedule next review: suggest monthly or after major campaign]
```

## Guidelines

- Always present findings before applying changes. The user confirms reclassifications.
- Process one stage at a time during manual review. Do not mix stages -- the LLM needs full context for each conversation.
- Include `ai_notes` starting with "Stage review:" on every reclassification.
- `bulk_classify` supports stage, tags, summary, ai_notes, reminder, and archive (max 100 per call). It does NOT support `draft_message` -- this skill rarely drafts anyway.
- For server-side review, write specific instructions that target the common misclassification patterns for that stage.
- Skip `won`, `lost`, and `not_a_fit` unless explicitly requested. Terminal stages rarely need review.
- If misclassification rate exceeds 30%, recommend updating stage criteria with **stage-configuration** -- the problem is systemic.
- If most errors are not_a_fit conversations sitting in chatting, recommend refining ICP with **icp-definition**.
- Paginate every `export` call. If `has_more` is true, get the next page.
- For hybrid mode, start the server-side job first, then manually review while it runs. Do not wait idle.
- This skill reclassifies. It does not draft messages or archive. If stale conversations are found, note them for **pipeline-cleanup**.

## Related Skills

- **pipeline-cleanup** -- Archive stale/ghosted conversations (different goal: cleanup, not accuracy)
- **full-morning-triage** -- Classify unclassified conversations (different goal: new classification, not re-review)
- **stage-configuration** -- Change stage definitions if systemic misclassification patterns emerge
- **pipeline-health-check** -- Diagnose pipeline conversion problems that may point to staging issues
- **won-deal-analysis** -- Analyze closed deals for patterns (complements stage review findings)
