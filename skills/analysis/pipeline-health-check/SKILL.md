---
name: pipeline-health-check
description: >
  Analyze pipeline performance with conversion funnels, warning sign detection,
  bottleneck identification, and actionable recommendations. Use when the user says
  "how is my pipeline", "pipeline health", "where am I losing deals", "conversion
  rates", "pipeline analysis", "what's wrong with my pipeline", "why am I not closing",
  or "show me my funnel". Requires at least 10 classified conversations for meaningful
  analysis. Related: won-deal-analysis for deep pattern detection in closed deals,
  pipeline-cleanup for acting on cleanup recommendations, full-morning-triage for
  daily pipeline processing, campaign-launch for addressing volume problems.
metadata:
  version: "1.0"
  author: linkninja
---

# Pipeline Health Check

Turn pipeline data into decisions. Snapshot the current state, calculate conversion rates, detect warning signs, and deliver specific recommendations for where to focus.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check pipeline readiness:

| Check | How | If Not Met |
|-------|-----|------------|
| At least 10 classified conversations | `get_stats()` — sum all stage counts | "You need at least 10 classified conversations for a meaningful analysis. Want me to classify your pipeline first?" Suggest **full-morning-triage** or `start_batch_classify()` |
| ICP configured | `additional_context` in context | Optional for health check, but note: "Your ICP isn't configured yet. Analysis will be more useful with an ICP set up." |

3. If the pipeline has enough data, proceed to the analysis.

## Workflow

### Section 1: Pipeline Snapshot

```
get_stats()
```

Present the current state:

**Stage Distribution Table:**

| Stage | Count | My Turn | Their Turn |
|-------|-------|---------|------------|
| Opening | — | — | — |
| Chatting | — | — | — |
| Qualified | — | — | — |
| Discovery | — | — | — |
| Closing | — | — | — |
| Won | — | — | — |
| Lost | — | — | — |

**Freshness Breakdown:**

| Freshness | Count | % of Active |
|-----------|-------|-------------|
| Fresh | — | — |
| Cold | — | — |
| You Ghosted | — | — |
| They Ghosted | — | — |
| Stale | — | — |

**Pipeline Shape Assessment:**

| Shape | What It Looks Like | Diagnosis |
|-------|-------------------|-----------|
| Healthy funnel | Wide at opening, narrows through each stage | Pipeline is progressing normally |
| Top-heavy | Most conversations in opening/chatting | Not converting enough to qualified |
| Bottleneck | Pile-up at one stage | That stage has a conversion problem |
| Bottom-heavy | Many in qualified+ but few in won | Closing problem or pipeline stalling |
| Empty | Fewer than 10 active conversations | Volume problem — need more outreach |

### Section 2: Conversion Funnel Analysis

Calculate conversion rates from `get_stats()` data. Benchmarks reflect the playbook's chat-to-contract chain (see `references/sell-by-chat-methodology.md` — ~30% reply / ~50% engagement / ~20% call-book / ~80% show / ~50% close → ~1% overall):

| Transition | Formula | Rate | Playbook Benchmark |
|------------|---------|------|--------------------|
| Opening to Chatting (reply rate) | chatting / opening | —% | ~30% (15–30% acceptable, below 15% = critical) |
| Chatting to Qualified | qualified / chatting | —% | ~50% (20–40% typical for less aligned ICP) |
| Qualified to Discovery (call-book) | discovery / qualified | —% | ~20% (30–50% if you call early) |
| Discovery to Closing (show + advance) | closing / discovery | —% | ~80% show × your conversion |
| Closing to Won (close rate) | won / (won + lost) | —% | ~50% (10–25% in less consultative funnels) |
| **Overall (chats → contracts)** | won / opening | —% | **~1%** |

The playbook's "80% of sales close after the 5th touchpoint" means losses concentrated in early stages are usually a *cadence* problem (people quitting follow-up before touch 5), not a *messaging* problem. Check `cold-rescue` health before blaming openers.

### Conversation Intelligence Slicing

Combine `get_stats` (stage counts) with `get_conversation` (intelligence fields) for a richer view. Pull `warmth_level` and `conversation_health` distributions across stages — the patterns flag specific issues:

| Pattern | Likely Cause | Action |
|---------|--------------|--------|
| Many `qualified` with `conversation_health: at_risk` | Qualifying without next-step traction | **call-booking** push needed |
| Many `chatting` with `warmth_level: cold` | Conversations stalling, not progressing | **cold-rescue** sweep |
| `discovery` with `conversation_health: dead` | Stuck post-call without follow-through | Manual review — re-engage or archive |
| High `objection_signals` not yet in `qualified` | Objections raised early, not addressed | **objection-handling** sweep |

**Find the leaky stage** — the transition with the biggest drop-off below benchmark:

| Leaky Stage | Likely Problem | Recommended Fix |
|-------------|---------------|-----------------|
| Opening to Chatting | Messages not landing | Improve specificity, check ICP targeting, reference real details |
| Chatting to Qualified | Not surfacing needs | Ask deeper questions earlier, focus on their challenges |
| Qualified to Discovery | Not bridging to call/meeting | Make next step clear, low-friction: "15 min to see if there's a fit" |
| Discovery to Closing | Offer not compelling | Strengthen outcome clarity, address objections from discovery |
| Closing to Won | Stalling at decision | Reduce perceived risk, address specific blockers, simplify next step |

For detailed benchmarks, see `references/benchmarks.md`.

### Section 3: Warning Signs Detection

Check each warning sign against the data:

| Warning Sign | Detection | Severity | Action |
|-------------|-----------|----------|--------|
| High `my_turn` across stages | Total my_turn > 50% of active | Critical | "You are the bottleneck. [N] people are waiting on you." |
| Growing `you_ghosted` | you_ghosted > 10% of active | Critical | "You're dropping conversations. Set up daily triage." |
| High cold count | cold > 25% of active | High | "Conversations are dying from neglect. Prioritize cold rescue." |
| Many in opening, few chatting | Reply rate < 15% | High | "Your outreach isn't getting replies. Review messaging or ICP." |
| Pile-up in chatting | chatting > 2x qualified | Medium | "Conversations are stalling. You need to qualify faster." |
| High their_turn in qualified+ | their_turn in qualified/discovery/closing > 50% | Medium | "Prospects are going quiet after showing interest. Follow up faster." |
| Many closing, few won | close rate < 10% | Medium | "Deals are stalling at the finish. Reduce friction in the ask." |
| Empty pipeline | Total active < 10 | High | "Not enough volume. Increase outreach." |
| High ghost rate | (cold + ghosted) / total > 40% | High | "Pipeline is decaying. Too many conversations going stale." |

### Section 4: Attention Items

Find conversations that need immediate attention:

**Qualified leads waiting on the user:**

```
search_conversations(my_turn=true, stage="qualified", compact=true)
```

**Discovery/closing conversations going cold:**

```
search_conversations(freshness="cold", stage="discovery", compact=true)
```

```
search_conversations(freshness="cold", stage="closing", compact=true)
```

**Conversations the user ghosted:**

```
search_conversations(freshness="you_ghosted", compact=true)
```

List these in the report as specific action items.

### Section 5: Recommendations

Based on the analysis, provide 3-5 specific, prioritized recommendations:

**Recommendation format:**
1. **What to do** — specific action
2. **Why** — tied to a specific finding from the analysis
3. **How** — which skill or tool to use

**Example recommendations by problem:**

| Problem Found | Recommendation |
|--------------|---------------|
| High my_turn count | "Reply to your [N] pending conversations today. Run **full-morning-triage** to process them all." |
| Low reply rate | "Review your opening messages. Consider updating your ICP with **icp-definition** to improve targeting." |
| Chatting pile-up | "Focus on qualifying: ask about needs, budget, timeline. See **dm-writing** Situation 3." |
| High cold count | "Run cold rescue for your [N] cold conversations. Use **cold-rescue** or **batch-drafting** with cold filter." |
| Stalling at closing | "Follow up on your [N] closing conversations with risk reduction. See **dm-writing** Situation 4 and 6." |
| Low volume | "Increase outreach. Run **prospect-scan** to find new matches, then **campaign-launch**." |
| Growing ghost rate | "Set up daily triage as a habit. Run **full-morning-triage** every morning to prevent decay." |

### Section 6: Report

Deliver the full analysis:

> **Pipeline Health Check**
>
> **Snapshot:** [total] active conversations across [N] stages
> [Stage distribution table]
>
> **Conversion Funnel:**
> [Conversion rates table with benchmarks]
> Leaky stage: [stage] — [brief explanation]
>
> **Warning Signs:** [list detected warning signs]
>
> **Immediate Attention:**
> - [N] qualified leads waiting on you
> - [M] conversations you ghosted
> - [P] high-value conversations going cold
>
> **Recommendations:**
> 1. [First priority recommendation]
> 2. [Second priority recommendation]
> 3. [Third priority recommendation]
>
> **Optional:** Export to CSV for offline analysis:
> `export_conversations(format="csv", include_messages=true)`

## Deep Dive: Stage-Level Analysis

If the user wants to dig deeper into a specific stage:

```
export_conversations(stage="<problem_stage>", include_messages=true)
```

Look for patterns in:
- Message tone and length
- Time between messages
- Type of questions being asked
- Common objections or stall points
- Tags that appear frequently

Feed findings back into context:

```
update_context(additional_context="Pipeline analysis finding: [what you learned]. Adjusting approach for [stage].")
```

## Campaign Comparison (If Applicable)

If the user has campaign tags, compare performance:

```
search_conversations(tags=["campaign-jan"], compact=true)
```

```
search_conversations(tags=["campaign-feb"], compact=true)
```

| Metric | Campaign A | Campaign B |
|--------|-----------|-----------|
| Total conversations | — | — |
| Past opening (reply rate) | — | — |
| Qualified+ (qualification rate) | — | — |
| Won (win rate) | — | — |

See `references/benchmarks.md` for healthy ranges by metric.

## Guidelines

- Present data first, then interpretation, then recommendations.
- Use tables for all quantitative data. Tables over prose.
- Benchmark ranges are directional, not absolute. The user's trend matters more.
- Always tie recommendations to specific skills or tools.
- Don't overwhelm: 3-5 recommendations max, prioritized by impact.
- If the pipeline has fewer than 10 conversations, say so and suggest building volume first.
- For large pipelines (200+), use `get_stats()` for the snapshot and targeted `search_conversations` queries for specifics. Avoid exporting everything.
- Offer CSV export for users who want offline/spreadsheet analysis.

## Power-Ups (Optional)

See [POWER-UPS.md](../../../POWER-UPS.md) for full setup.

- **Cron:** `/schedule weekly Sunday 8am pipeline-health-check` — week-in-review snapshot before Monday plans.
- **Hook:** `Stop` hook pushes results to Notion with comparison vs. last week's snapshot.
- **MCP:** Notion (snapshot logging), Slack (post the Sunday summary to a #pipeline channel).
- **Model:** Opus 4.7 (pattern detection across many conversations benefits from frontier reasoning; weekly cadence makes the cost reasonable).

## Related Skills

- **won-deal-analysis** — Deep pattern detection in closed deals
- **pipeline-cleanup** — Act on cleanup recommendations from the health check
- **full-morning-triage** — Daily pipeline processing to prevent decay
- **campaign-launch** — Address volume problems with targeted outreach
- **icp-definition** — Refine targeting based on health check findings
