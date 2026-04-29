---
name: reply-rate-analysis
description: >
  Analyze opening-to-reply conversion rates across the pipeline. Exports opening,
  chatting, and qualified conversations with full transcripts to find patterns in
  successful openers vs ignored ones. Use when the user says "analyze my reply rate",
  "which openers worked", "opening conversion", "reply rate analysis", "what messages
  get replies", "why aren't people replying", "opener analysis", or "message
  performance". This is a read-only analysis skill — no stage changes, drafts, or
  archives. Related: won-deal-analysis for closed deal patterns, pipeline-health-check
  for overall pipeline diagnosis, campaign-launch for acting on messaging insights,
  dm-writing for applying findings to future messages.
metadata:
  version: "1.0"
  author: linkninja
---

# Reply Rate Analysis

Find which opening messages got replies and which got ignored. Compare message patterns across replied vs unreplied conversations to surface what works, what doesn't, and why. Feed insights back into outreach strategy.

## Before Starting

1. Run `get_context()` to load the user's ICP, positioning, and voice profile
2. Check data availability:

| Check | How | If Not Met |
|-------|-----|------------|
| Opening conversations exist | `get_stats()` — check opening stage count | Need at least 5 total conversations (opening + chatting + qualified+) to analyze. "Not enough data yet. Keep working your pipeline and come back when you've sent at least 5 openers." |
| Conversations past opening exist | pipeline_stats — chatting + qualified + discovery + closing + won + lost counts | If zero conversations past opening: "Nobody has replied yet. Too early to analyze patterns. Focus on sending more openers first." |
| Minimum for pattern analysis | At least 3 replied + 3 unreplied | Partial analysis is fine, but flag: "Small sample — patterns may be noise. Revisit when you have more data." |

3. If the data is sufficient, proceed to the full analysis.

## Workflow

### Step 1: Gather Pipeline Numbers

```
get_stats()
```

Record the stage counts for the reply rate calculation:

| Stage | Count | Category |
|-------|-------|----------|
| Opening | — | No reply yet |
| Chatting | — | Got a reply |
| Qualified | — | Got a reply (with buying signals) |
| Discovery | — | Got a reply (advanced) |
| Closing | — | Got a reply (advanced) |
| Won | — | Got a reply (converted) |
| Lost | — | Got a reply (did not convert) |

### Step 2: Calculate Reply Rate

| Metric | Formula | Value |
|--------|---------|-------|
| Total openers sent | opening + chatting + qualified + discovery + closing + won + lost | — |
| No reply (still in opening) | opening count | — |
| Got a reply | chatting + qualified + discovery + closing + won + lost | — |
| **Reply rate** | (Got a reply / Total openers sent) x 100 | —% |

**Benchmark context:**

| Reply Rate | Assessment |
|------------|-----------|
| Below 10% | Poor — messaging or targeting problem |
| 10-20% | Below average — room for improvement |
| 20-35% | Solid — typical for personalized outreach |
| 35-50% | Strong — messaging resonates well |
| Above 50% | Exceptional — warm audience or very strong targeting |

### Step 3: Export Unreplied Conversations (Opening Stage)

```
export_conversations(stage="opening", include_messages=true)
```

If `has_more` is true, paginate immediately:

```
export_conversations(stage="opening", include_messages=true, page=2)
```

Continue until all pages are loaded. These are the openers that did not get a reply.

### Step 4: Export Replied Conversations

Pull conversations that made it past opening:

```
export_conversations(stage="chatting", include_messages=true)
```

```
export_conversations(stage="qualified", include_messages=true)
```

Handle `has_more` pagination on each. For advanced stages, full transcripts are less critical — the opening message is the key data point. If the pipeline is large (100+), prioritize chatting and qualified exports over discovery/closing/won.

For won deals specifically (best-performing openers):

```
export_conversations(stage="won", include_messages=true)
```

### Step 5: Analyze Opening Message Patterns

Read the first outbound message from every exported conversation. Classify each opener across 6 dimensions:

| Dimension | What to Measure | Values |
|-----------|----------------|--------|
| Length | Word count of the opening message | Short (1-25), Medium (26-60), Long (61+) |
| Structure | Question vs statement vs hybrid | Question-led, Statement-led, Hybrid |
| Personalization | Referenced their name, headline, company, post, or content | Personalized, Semi-personalized, Generic |
| Value orientation | Shared insight/resource vs asked for time/meeting | Value-led, Ask-led, Neutral |
| Tone | Casual conversational vs professional formal | Casual, Professional, Formal |
| Hook type | What the opening line does | Compliment, Observation, Question, Shared experience, Direct pitch |

**Build the pattern comparison table:**

| Dimension | Replied (N) | Unreplied (N) | Finding |
|-----------|-------------|---------------|---------|
| Avg length | — words | — words | Which length performs better |
| Structure | X% question-led | X% question-led | Questions vs statements |
| Personalization | X% personalized | X% personalized | Impact of personalization |
| Value orientation | X% value-led | X% value-led | Value vs ask |
| Tone | X% casual | X% casual | Tone preference |
| Top hook type | [most common] | [most common] | What hooks work |

### Step 6: Identify Top and Bottom Performers

**Top performers:** Quote 2-3 opening messages that got replies (especially those that reached qualified or won). Identify what they have in common.

**Bottom performers:** Quote 2-3 opening messages that got no reply. Identify what they have in common.

Present as a side-by-side:

| | Got Reply | No Reply |
|--|----------|----------|
| Example 1 | "[opener text]" | "[opener text]" |
| Example 2 | "[opener text]" | "[opener text]" |
| What they share | [common traits] | [common traits] |

### Step 7: Campaign Comparison (If Tags Exist)

If the user has campaign tags, compare reply rates by campaign:

```
search_conversations(tags=["campaign-X"], compact=true)
```

Count how many are still in opening vs past opening for each campaign tag.

For deeper analysis:

```
export_conversations(tags=["campaign-X"], include_messages=true)
```

| Campaign | Total | In Opening | Past Opening | Reply Rate | Top Pattern |
|----------|-------|-----------|-------------|------------|-------------|
| campaign-A | — | — | — | —% | [dominant opener style] |
| campaign-B | — | — | — | —% | [dominant opener style] |

If no campaign tags exist, mention: "Tag future campaigns (e.g., `campaign-apr-2026`) and I can compare reply rates across campaigns over time."

### Step 8: Time-Based Comparison (Optional)

If the user wants to compare periods:

```
export_conversations(stage="opening", include_messages=true, since="2026-01-01", before="2026-02-01")
```

```
export_conversations(stage="chatting", include_messages=true, since="2026-01-01", before="2026-02-01")
```

Repeat for the second period. Compare reply rates and patterns between time windows.

## Report Template

Present the full analysis:

```
Reply Rate Analysis

Overall: X% reply rate (Y replies out of Z openers sent)
Benchmark: [assessment based on rate]

Pattern Breakdown (replied vs unreplied):

| Dimension | Replied | Unreplied | Takeaway |
|-----------|---------|-----------|----------|
| Length | — | — | — |
| Structure | — | — | — |
| Personalization | — | — | — |
| Value orientation | — | — | — |
| Tone | — | — | — |
| Hook type | — | — | — |

Top Performing Openers:
1. "[opener]" — [why it worked]
2. "[opener]" — [why it worked]

Underperforming Openers:
1. "[opener]" — [why it likely failed]
2. "[opener]" — [why it likely failed]

Campaign Comparison (if applicable):
| Campaign | Reply Rate | Best Pattern |
|----------|-----------|-------------|
| campaign-A | X% | [pattern] |
| campaign-B | Y% | [pattern] |

Recommendations:
1. [Specific messaging change based on pattern data]
2. [Specific targeting change if personalization gap exists]
3. [Specific structural change if question/statement split matters]
```

**CSV export for offline analysis:**

```
export_conversations(format="csv", include_messages=true)
```

## Guidelines

- This is a read-only analysis skill. Do not change stages, create drafts, or archive anything.
- Present data first, then interpretation, then recommendations. Tables over prose.
- Always compare replied vs unreplied. One-sided analysis misses the contrast.
- Quote actual opener messages to illustrate patterns. Anonymize prospect names if the user prefers.
- Do not draw conclusions from fewer than 3 data points per group. Flag small samples.
- Handle `has_more` pagination on every `export_conversations` call. Missing pages means missing patterns.
- For large pipelines (200+ conversations), prioritize opening and chatting exports. Sample rather than export every advanced stage.
- Do not recommend context updates from this skill. Present findings and let the user decide. Point to **icp-definition** or **dm-writing** for acting on insights.
- If reply rate is above 35%, say so. Not every analysis reveals a problem.
- If reply rate is below 10%, check whether the issue is messaging or targeting. Low personalization suggests messaging. High personalization but low replies suggests wrong audience.

## Related Skills

- **won-deal-analysis** — Deep pattern analysis on closed deals (goes beyond reply rate)
- **pipeline-health-check** — Full pipeline diagnosis including conversion at every stage
- **dm-writing** — Apply reply rate findings to craft better opening messages
- **campaign-launch** — Launch campaigns informed by opener insights
- **icp-definition** — Refine targeting if analysis shows audience mismatch
- **batch-drafting** — Draft improved openers at scale using discovered patterns
