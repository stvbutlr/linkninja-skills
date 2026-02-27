---
name: stage-conversion-analysis
description: >
  Deep stage-by-stage conversion analysis that identifies where conversations stall,
  which stages leak the most deals, and what patterns separate conversations that
  convert from those that don't. Use when the user says "stage conversion analysis",
  "where am I losing deals", "stage-by-stage breakdown", "conversion funnel",
  "pipeline funnel", "which stage is my bottleneck", "where do conversations stall",
  "pipeline conversion rates", "leaky stages", or "stage dropout analysis". This is
  analysis only — no stage changes, no drafts. Related: pipeline-health-check for
  overall pipeline snapshot, won-deal-analysis for deep pattern detection in closed
  deals, stage-review for reclassification accuracy, dm-writing for improving
  messages at weak stages, pipeline-cleanup for acting on stall findings.
metadata:
  version: "1.0"
  author: linkninja
---

# Stage Conversion Analysis

Find the leaky stages. For each pipeline stage, measure how many conversations enter, how many move forward, how many stall, and what patterns exist in conversations that convert vs those that don't. Delivers a bottleneck diagnosis with actionable next steps.

**This skill does NOT:**
- Change stages or classifications (that is **stage-review**)
- Draft messages (that is **batch-drafting** or **dm-writing**)
- Archive conversations (that is **pipeline-cleanup**)

**This skill DOES:**
- Calculate stage-by-stage conversion rates
- Deep-dive into each stage's conversations to find stall patterns
- Compare converted vs stalled conversations within each stage
- Identify the biggest bottleneck with a specific diagnosis
- Analyze where lost deals dropped out of the funnel
- Recommend specific skills to fix each problem

## Before Starting

1. Run `get_context()` to load the user's sales context (ICP, stages, positioning)
2. Run `stages()` to load stage definitions with entrance/exit criteria
3. Run `pipeline_stats()` to get stage counts, freshness, and turn status
4. Check prerequisites:

| Check | How | If Not Met |
|-------|-----|------------|
| At least 15 classified conversations | Sum all stage counts from `pipeline_stats()` | "You need at least 15 classified conversations for a meaningful conversion analysis. Want me to classify your pipeline first?" Suggest **full-morning-triage** or `start_batch_classify()` |
| At least 2 stages with conversations | Count stages with > 0 | "All your conversations are in one stage. Classify more before running conversion analysis." |
| Some won or lost deals | Check won + lost counts | Analysis still works for active pipeline, but note: "No closed deals yet. Conversion rates are based on current stage distribution. Come back after some deals close for a complete funnel." |

5. If prerequisites met, proceed to the full analysis.

## Workflow

### Step 1: Conversion Funnel

Calculate from `pipeline_stats()` data. Present the funnel:

| Transition | From | To | Rate | Benchmark | Status |
|------------|------|----|------|-----------|--------|
| Reply rate | opening | chatting | —% | 15-30% | OK / Low / Critical |
| Qualification rate | chatting | qualified | —% | 20-40% | OK / Low / Critical |
| Discovery rate | qualified | discovery | —% | 30-50% | OK / Low / Critical |
| Proposal rate | discovery | closing | —% | 40-60% | OK / Low / Critical |
| Close rate | closing | won | —% | 10-25% | OK / Low / Critical |
| Overall win rate | opening | won | —% | 1-5% | OK / Low / Critical |

**Status rules:**
- OK: at or above benchmark range
- Low: below benchmark range but within 50% of lower bound
- Critical: less than 50% of the benchmark lower bound

Identify the **single worst transition** — this is the primary bottleneck.

### Step 2: Stage-by-Stage Deep Dive

This is the core value. For each active stage (opening through closing), export conversations and analyze patterns.

**For each stage, run:**

```
export(stage="<stage>", include_messages=true)
```

Paginate if `has_more` is true:

```
export(stage="<stage>", include_messages=true, page=2)
```

Continue until all pages are loaded.

**For each stage, analyze and present:**

| Metric | How to Calculate | What It Reveals |
|--------|-----------------|-----------------|
| Count | Total conversations in stage | Volume at this point in funnel |
| Avg days in stage | Time since conversation entered this stage | Are they moving or sitting? |
| My-turn ratio | my_turn / total in stage | Is the user the bottleneck? |
| Freshness breakdown | Count by fresh/cold/you_ghosted/they_ghosted/stale | How healthy is this stage? |
| Stall rate | (cold + stale + ghosted) / total in stage | What % is stuck? |
| Common tags | Most frequent tags in this stage | Patterns in who gets here |

**Stage Deep Dive Table (one per stage):**

```
## [Stage Name] — [count] conversations

| Metric | Value |
|--------|-------|
| Conversations | [N] |
| Avg days in stage | [X] days |
| My turn | [N] ([X]%) |
| Their turn | [N] ([X]%) |
| Fresh | [N] |
| Cold | [N] |
| You ghosted | [N] |
| They ghosted | [N] |
| Stale | [N] |
| Stall rate | [X]% |
| Top tags | [tag1], [tag2], [tag3] |

**Stall patterns:** [What the stuck conversations have in common]
**Conversion patterns:** [What conversations that moved forward had in common]
**User bottleneck?** [Yes/No — based on my_turn ratio]
```

**What to look for in message transcripts:**

| Signal | Indicates |
|--------|-----------|
| Long gaps between user replies | User is the bottleneck — slow follow-up |
| Short, generic user messages | Low effort — messages not personalized enough |
| Prospect asks a question, user doesn't answer it | Missed engagement opportunity |
| Multiple follow-ups with no reply | Prospect is not interested or wrong ICP |
| Prospect mentions need/budget/timeline but conversation stays in chatting | Missed buying signal — should have been qualified |
| Conversation dies after user pitches | Pitching too early |

### Step 3: Bottleneck Identification

Synthesize findings into the bottleneck table:

| Stage | In Stage | Moved Forward | Stalled | Conversion | My-Turn % | Diagnosis |
|-------|----------|---------------|---------|------------|-----------|-----------|
| opening | — | — | — | —% | —% | — |
| chatting | — | — | — | —% | —% | — |
| qualified | — | — | — | —% | —% | — |
| discovery | — | — | — | —% | —% | — |
| closing | — | — | — | —% | —% | — |

**Diagnosis logic per stage:**

| Conversion Rate | My-Turn % | Diagnosis |
|----------------|-----------|-----------|
| Low | High (>50%) | User bottleneck — not replying fast enough |
| Low | Low (<30%) | Prospects disengaging — messaging or targeting problem |
| Low | Balanced | Mixed — review message quality and ICP fit |
| OK | High (>50%) | Conversion is fine but user is slow — speed up replies |
| OK | Low | Healthy — prospects are engaged and moving |

Highlight the **primary bottleneck** (lowest conversion rate) and **secondary bottleneck** (second lowest).

### Step 4: Lost Deal Analysis

```
export(stage="lost", include_messages=true)
```

Paginate if `has_more` is true.

Analyze where lost deals dropped out:

| Last Active Stage Before Lost | Count | % of Lost | Insight |
|------------------------------|-------|-----------|---------|
| opening (never replied) | — | —% | Targeting or messaging problem |
| chatting (replied but no signal) | — | —% | Not qualifying — conversations going nowhere |
| qualified (signal but no meeting) | — | —% | Not bridging to next step |
| discovery (meeting but no proposal) | — | —% | Discovery not compelling enough |
| closing (proposal but no close) | — | —% | Closing friction — price, timing, trust |

**Lost deal patterns to extract:**
- How many messages before the conversation died?
- Who sent the last message (user or prospect)?
- Common tags on lost deals vs won deals
- Time from first message to lost — did they stall quickly or slowly?

### Step 5: Won Deal Comparison (If Data Exists)

If won deals exist, pull them for comparison:

```
export(stage="won", include_messages=true)
```

Compare won vs lost on key metrics:

| Metric | Won Deals | Lost Deals | Gap |
|--------|-----------|------------|-----|
| Avg messages exchanged | — | — | — |
| Avg days to outcome | — | — | — |
| Who sent last message | — | — | — |
| Most common tags | — | — | — |
| Avg reply speed (user) | — | — | — |
| Stage where most time spent | — | — | — |

This comparison reveals what winning conversations do differently.

### Step 6: Recommendations

Deliver 3-5 prioritized recommendations tied to specific findings and skills.

**Recommendation mapping:**

| Finding | Recommendation | Skill |
|---------|---------------|-------|
| Low opening-to-chatting | Review opening messages. Test different approaches. Check ICP targeting. | **dm-writing** (Situation 1), **icp-definition** |
| Low chatting-to-qualified | Ask deeper questions earlier. Look for buying signals. | **dm-writing** (Situation 2), **stage-review** |
| Low qualified-to-discovery | Bridge to calls faster. Make next step low-friction. | **dm-writing** (Situation 3) |
| Low discovery-to-closing | Strengthen proposals. Address objections from discovery. | **dm-writing** (Situation 4) |
| Low closing-to-won | Reduce friction. Address specific blockers. Create urgency. | **dm-writing** (Situation 6) |
| High my-turn across stages | Reply faster. Set up daily triage habit. | **full-morning-triage**, **batch-drafting** |
| High stall rate in a stage | Clean up stalled conversations. Re-engage or archive. | **pipeline-cleanup**, **cold-rescue** |
| Lost deals cluster at one stage | That stage's approach needs rework. | **stage-configuration**, **dm-writing** |
| Won deals have specific tags | Prioritize prospects with those tags. Refine ICP. | **icp-definition**, **smart-tagging** |

## Report Template

```
## Stage Conversion Analysis

**Pipeline:** [total] active conversations across [N] stages
**Data:** [X] won, [Y] lost deals included in analysis

### Conversion Funnel

[Funnel table from Step 1]

**Primary bottleneck:** [stage transition] at [X]% (benchmark: [Y]%)
**Secondary bottleneck:** [stage transition] at [X]%

### Stage Deep Dives

[Deep dive table for each stage from Step 2]

### Bottleneck Summary

[Bottleneck table from Step 3]

### Lost Deal Dropout

[Lost deal analysis table from Step 4]

### Won vs Lost Comparison

[Comparison table from Step 5, if data exists]

### Recommendations (prioritized)

1. **[Action]** — [Why, tied to finding] — Use **[skill]**
2. **[Action]** — [Why, tied to finding] — Use **[skill]**
3. **[Action]** — [Why, tied to finding] — Use **[skill]**

### Optional: Export for Offline Analysis

Export full pipeline with transcripts to CSV:

export(format="csv", include_messages=true)
```

## Guidelines

- This is read-only analysis. Do not change stages, draft messages, or archive anything.
- Present data first, then interpretation, then recommendations.
- Use tables for all quantitative data. Tables over prose.
- Always paginate `export` calls. If `has_more` is true, get the next page before analyzing.
- For large pipelines (200+ in a stage), summarize patterns from a sample rather than reading every transcript. Export first 2 pages (up to 1000 conversations) and note the sample size.
- Do not fabricate patterns from small samples. If a stage has fewer than 3 conversations, note the sample is too small for reliable patterns.
- Benchmark ranges are directional, not absolute. The user's own trends matter more than generic benchmarks.
- Always tie recommendations to specific skills. Never give vague advice.
- `bulk_classify` does NOT support `draft_message`. This skill does not draft anyway.
- Offer CSV export at the end for users who want spreadsheet analysis.
- If the user asks to act on a recommendation, hand off to the appropriate skill.
- Maximum 5 recommendations, ordered by expected impact.

## Related Skills

- **pipeline-health-check** -- Overall pipeline snapshot with warning signs (broader, less deep per stage)
- **won-deal-analysis** -- Deep pattern detection in closed deals (complements this analysis)
- **stage-review** -- Reclassify conversations that are in the wrong stage
- **dm-writing** -- Improve messages at the weak stages identified by this analysis
- **pipeline-cleanup** -- Archive stalled conversations found during analysis
- **cold-rescue** -- Re-engage cold conversations identified in the deep dive
- **icp-definition** -- Refine targeting based on conversion patterns
- **batch-drafting** -- Draft messages at scale for high my-turn stages
