---
name: won-deal-analysis
description: >
  Analyze won and lost deals to find winning patterns and refine ICP from real
  results. Use when the user says "analyze won deals", "what do my wins have in
  common", "pattern analysis", "why am I winning", "what's working", "win/loss
  analysis", "what patterns do you see in my deals", or "refine my ICP from
  data". Exports won and lost conversations, compares across multiple dimensions,
  and feeds insights back into context. Related: pipeline-health-check for
  overall pipeline diagnosis, icp-definition for setting up ICP from scratch,
  campaign-launch for acting on refined targeting.
metadata:
  version: "1.0"
  author: linkninja
---

# Won Deal Analysis

Find what your winning conversations have in common, how they differ from losses, and feed those patterns back into your sales context so targeting and classification get smarter over time.

For each won deal, frame the analysis using the playbook's **A–B Method**: at the moment of conversion, what was their Point A (current state, pain) and their Point B (desired state, what they wanted)? The pattern of A→B gaps that converted is the most valuable input for refining ICP and positioning.

## Before Starting

1. Run `get_context()` to load the user's current sales context
2. Check data availability:

| Check | How | If Insufficient |
|-------|-----|-----------------|
| Won deals count | Look at pipeline stats or `export_conversations(stage="won", include_messages=false)` | Need at least 3 won deals. Tell the user: "You need some won deals to analyze patterns. Keep working your pipeline and come back when you've closed a few." |
| Lost deals count | `export_conversations(stage="lost", include_messages=false)` | Won-only analysis still works. Note that comparison will be limited. |
| ICP defined | Check `additional_context` from `get_context()` | Analysis still works but refinement step will create an ICP from scratch rather than refine. |

3. If fewer than 3 won deals: stop and explain. Do not fabricate patterns from 1-2 data points.
4. If sufficient data: proceed to the full analysis.

## Workflow

### Step 1: Export Won Deals

Pull all won conversations with full message transcripts:

```
export_conversations(stage="won", include_messages=true)
```

If `has_more` is true, fetch the next page immediately:

```
export_conversations(stage="won", include_messages=true, page=2)
```

Continue until all pages are loaded.

### Step 2: Analyze Won Deals Across 7 Dimensions

Read every won conversation and extract patterns across these dimensions:

| Dimension | What to Look For | Example Finding |
|-----------|-----------------|-----------------|
| Opening message style | Personalized? Referenced something specific? Length? Tone? | "Won deals opened with a specific reference to their content or role, not a generic pitch" |
| Message count | How many exchanges before buying signals appeared? | "Average 6 messages before qualification. Range: 3-12" |
| Qualifying questions | Which questions surfaced real needs? Which fell flat? | "Asking about current tools always led somewhere. Asking about budget directly never worked." |
| Time to close | Days from first message to won stage | "Average 23 days. Fastest: 8 days. Slowest: 67 days" |
| Common tags | Which tags appear most often across won deals? | "decision_maker on 80% of wins. urgent on 40%." |
| Prospect profile | Industries, roles, company sizes that converted | "VP/Director level at 50-200 person SaaS companies" |
| Who initiated next step | Did you suggest the call, or did they? | "They asked for a call in 6/10 wins. You asked in 4/10." |

Present findings in a summary table:

```
## Won Deal Patterns (N deals analyzed)

| Dimension | Pattern |
|-----------|---------|
| Opening style | [finding] |
| Messages to qualify | [finding] |
| Best qualifying questions | [finding] |
| Avg time to close | [finding] |
| Top tags | [finding] |
| Prospect profile | [finding] |
| Who initiates next step | [finding] |
```

### Step 3: Export and Analyze Lost Deals

```
export_conversations(stage="lost", include_messages=true)
```

Paginate if `has_more` is true.

Compare lost deals against the won deal patterns:

| Comparison | Won Deals | Lost Deals | Insight |
|------------|-----------|------------|---------|
| Where they stalled | — | Which stage transition failed? | Identifies the breakpoint |
| Prospect type | Roles, industries, sizes | Different from wins? | Reveals who not to target |
| Message tone/length | Observed pattern | Different? | Messaging adjustments |
| Tags present | Common tags on wins | Missing tags? | e.g., no `decision_maker` tag on losses |
| Time before dying | — | How long did they sit before going lost? | Timing threshold for intervention |
| Who went quiet | — | Did you ghost or did they? | Process gap vs interest gap |

Present as a comparison table with actionable insights.

### Step 4: Feed Insights Back Into Context

This is the critical step. Take the patterns and update the user's sales context so the system gets smarter.

**Update ICP with refined targeting:**

```
update_context(
  additional_context="Refined ICP based on won deal analysis (N deals): Best-converting prospects are [role] at [company type/size] in [industry]. Most effective openings reference [specific pattern]. Average time to close: [X] days. Key signals: [tags/signals that predict wins]. Avoid: [profile patterns from lost deals]. Conversations that stall in chatting for more than [Y] days rarely convert."
)
```

**Update tag rules if new signals emerged:**

If a specific signal appeared in won deals but not lost deals:

```
update_context(
  stages=[{
    "key": "qualified",
    "ai_context": "[Insight from analysis, e.g., 'Conversations where they mention team size and a deadline close at 3x the rate. Prioritize these.']"
  }]
)
```

Always confirm the updates with the user before saving. Summarize what you plan to change and ask for approval.

### Step 5: Campaign Comparison (If Tags Exist)

If the user tags conversations by campaign, compare results across campaigns.

**Quick comparison:**

```
search_conversations(tags=["campaign-jan"], compact=true)
```

```
search_conversations(tags=["campaign-feb"], compact=true)
```

Count results and note stage distribution for each.

**Deep comparison (if warranted):**

```
export_conversations(tags=["campaign-jan"], include_messages=true)
```

```
export_conversations(tags=["campaign-feb"], include_messages=true)
```

| Metric | Campaign A | Campaign B | Winner |
|--------|-----------|-----------|--------|
| Reply rate | Conversations past opening / total | Same | Higher reply rate |
| Qualification rate | Qualified+ / total replies | Same | Better-fit prospects |
| Won rate | Won / total in campaign | Same | Revenue producer |
| Avg messages to qualify | Count | Count | Faster engagement |
| Time to first reply | Days | Days | Messaging resonance |

**Act on results:**
- Higher reply rate campaign: study its opening messages, replicate the approach
- Higher qualification rate: its targeting was better, note the ICP segment
- Neither producing won deals: problem is downstream (follow-up, proposals), not outreach

If no campaign tags exist, mention this to the user: "If you tag future campaigns (e.g., `campaign-mar-2026`), I can compare their performance over time."

## Report Template

Present the full analysis as a structured report:

```
## Won Deal Analysis Report

**Data:** [X] won deals, [Y] lost deals analyzed

### Winning Patterns
[Summary table from Step 2]

### Won vs Lost Comparison
[Comparison table from Step 3]

### Key Insights
1. [Most important finding]
2. [Second finding]
3. [Third finding]

### Recommended Context Updates
- ICP refinement: [what to change]
- Stage criteria: [what to adjust]
- Tags: [new signals to watch for]

### Campaign Comparison (if applicable)
[Campaign table from Step 5]

### What to Do Next
- [Specific action based on findings]
- [Specific action based on findings]
```

## Guidelines

- Do not analyze with fewer than 3 won deals. Patterns from 1-2 deals are noise.
- Always compare won against lost. Won-only analysis misses half the picture.
- Present findings as tables and specific numbers, not vague observations.
- Quote actual message excerpts (anonymized if needed) to illustrate patterns.
- Confirm context updates with the user before saving. These affect all future AI operations.
- If the user has 20+ won deals, focus on the most recent 10-15 for relevance. Older deals may reflect a different approach.
- Handle pagination on every export. Missing pages means missing patterns.
- If lost deals are empty, note the gap but proceed with won-only analysis. Lost deal comparison is valuable but not required.

## Related Skills

- **pipeline-health-check** — Overall pipeline diagnosis (conversion funnels, bottlenecks)
- **icp-definition** — Set up ICP from scratch if one doesn't exist
- **campaign-launch** — Launch targeted outreach using refined ICP insights
- **stage-configuration** — Adjust stage criteria based on analysis findings
