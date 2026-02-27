# Pipeline Benchmarks & Metric Reference

Healthy conversion ranges, warning sign thresholds, metric formulas, and diagnostic patterns. These are directional guides — the user's own trend over time matters more than hitting a specific number.

## Conversion Benchmarks

### Stage Transition Rates

| Transition | Healthy Range | Below Range Means | Above Range Means |
|------------|--------------|-------------------|-------------------|
| Opening to Chatting (reply rate) | 15-30% | Message or targeting problem | Strong ICP fit or warm intros |
| Chatting to Qualified | 20-40% | Not surfacing needs fast enough | Well-targeted outreach, asking good questions |
| Qualified to Discovery | 30-50% | Not bridging to calls effectively | Strong value proposition |
| Discovery to Closing | 40-60% | Proposals not compelling | Good discovery, clear outcomes |
| Closing to Won (close rate) | 10-25% | Qualification too loose or closing weak | Strong qualification, good proposals |
| Overall (Opening to Won) | 1-5% | Normal for LinkedIn outbound | Higher with referrals or warm intros |

### Factors That Shift Benchmarks

| Factor | Effect on Benchmarks |
|--------|---------------------|
| Warm intros / referrals | All rates 1.5-2x higher |
| Cold outbound only | Rates at the low end of ranges |
| High-ticket / enterprise | Lower close rate, higher per-deal value |
| Low-ticket / SMB | Higher close rate, lower per-deal value |
| Niche ICP (highly targeted) | Higher reply and qualification rates |
| Broad ICP | Lower reply rate, more volume needed |

## Metric Formulas

### Core Metrics

| Metric | Formula | Data Source |
|--------|---------|-------------|
| Reply rate | chatting_count / opening_count | `pipeline_stats()` |
| Qualification rate | qualified_count / chatting_count | `pipeline_stats()` |
| Discovery rate | discovery_count / qualified_count | `pipeline_stats()` |
| Proposal rate | closing_count / discovery_count | `pipeline_stats()` |
| Close rate | won_count / (won_count + lost_count) | `pipeline_stats()` |
| Overall conversion | won_count / opening_count | `pipeline_stats()` |

### Health Metrics

| Metric | Formula | Healthy Range |
|--------|---------|---------------|
| Response burden | total_my_turn / total_active | < 50% (above = you're the bottleneck) |
| Ghost rate | (cold + they_ghosted) / total_active | < 25% (above = pipeline decaying) |
| Neglect rate | you_ghosted / total_active | < 10% (above = you're dropping conversations) |
| Freshness ratio | fresh / total_active | > 40% (below = pipeline going stale) |
| Pipeline coverage | active_qualified+ / monthly_target_wins | 3-5x (below = not enough pipeline) |

### Velocity Metrics (Require Time-Based Data)

| Metric | How to Estimate | What It Tells You |
|--------|----------------|-------------------|
| Time to first reply | Days between opener and first response | How fast your outreach resonates |
| Time in stage | Days a conversation sits in a stage before moving | Where conversations stall |
| Cycle time | Days from opening to won | How long your typical sale takes |

To measure these precisely, export conversations and check timestamps:

```
export(stage="won", include_messages=true)
```

Compare `created_at` and `last_message_at` across messages.

## Warning Sign Thresholds

### Critical (Act Today)

| Warning Sign | Threshold | Detection |
|-------------|-----------|-----------|
| You are the bottleneck | my_turn > 50% of active pipeline | `pipeline_stats()` — sum my_turn across stages |
| You're dropping conversations | you_ghosted > 10% of active | `pipeline_stats()` — freshness breakdown |
| Qualified leads decaying | my_turn in qualified > 0, freshness not fresh | `search(my_turn=true, stage="qualified", freshness="cold")` |

### High (Act This Week)

| Warning Sign | Threshold | Detection |
|-------------|-----------|-----------|
| Pipeline decaying | ghost_rate > 25% | `pipeline_stats()` — (cold + ghosted) / total |
| Outreach not working | reply rate < 15% | Opening count vs chatting count |
| Empty pipeline | Total active < 10 | `pipeline_stats()` — sum active counts |
| No fresh conversations | fresh < 20% of active | `pipeline_stats()` — freshness breakdown |

### Medium (Address This Month)

| Warning Sign | Threshold | Detection |
|-------------|-----------|-----------|
| Chatting bottleneck | chatting > 2x qualified | `pipeline_stats()` — stage counts |
| Prospect interest fading | their_turn in qualified+ > 50% | `pipeline_stats()` — turn status per stage |
| Closing problem | close rate < 10% | Won vs (won + lost) |
| Single-stage pipeline | One stage has > 60% of conversations | `pipeline_stats()` — stage distribution |

## Diagnostic Patterns

### Pattern: "Pipeline Looks Full But Nothing Closes"

**Symptoms:** Many conversations in chatting/qualified, few in won.

**Diagnosis checklist:**
1. Check qualification criteria — are "qualified" conversations truly qualified? Do they have buying signals?
2. Check follow-up speed — how fast are you responding to qualified leads?
3. Check transition to call — are you successfully bridging to meetings?
4. Check closing approach — are proposals clear and risk-reduced?

**Tool calls for investigation:**

```
export(stage="qualified", include_messages=true)
```

Read the qualified conversations. Are they genuinely qualified (need + budget/authority/timeline), or are they just people being polite?

### Pattern: "Getting Replies But No Deals"

**Symptoms:** Good reply rate, but low qualification rate.

**Diagnosis checklist:**
1. Check ICP alignment — are you reaching the right people?
2. Check qualifying questions — are you asking about need, budget, authority, timeline?
3. Check message content — are you building rapport before qualifying?

**Investigation:**

```
export(stage="chatting", include_messages=true, limit=20)
```

Read 20 chatting conversations. What's the pattern? Are prospects engaging but not the right fit? Are they interested but you're not surfacing the need?

### Pattern: "Nobody Replies"

**Symptoms:** High opening count, low chatting count.

**Diagnosis checklist:**
1. Check message quality — are openers personalized or templated?
2. Check ICP targeting — are you reaching people who have the problem you solve?
3. Check headline keywords — do your scan keywords match actual ICP profiles?

**Investigation:**

```
export(stage="opening", include_messages=true, limit=20)
```

Read 20 opening messages. Are they specific to each person? Do they offer value? Do they reference something real?

### Pattern: "Deals Keep Stalling After Calls"

**Symptoms:** Good discovery count, low closing/won count.

**Diagnosis checklist:**
1. Check discovery quality — are you capturing detailed needs on calls?
2. Check proposal clarity — is the outcome crystal clear?
3. Check follow-up after call — are you sending a summary and next step?

**Investigation:**

```
export(stage="discovery", include_messages=true)
```

Look at post-call messages. Is there a clear next step after each call?

## Monthly Tracking Template

Track these monthly to spot trends:

| Metric | Month 1 | Month 2 | Month 3 | Trend |
|--------|---------|---------|---------|-------|
| Total active | — | — | — | — |
| Reply rate | — | — | — | — |
| Qualification rate | — | — | — | — |
| Close rate | — | — | — | — |
| Ghost rate | — | — | — | — |
| Neglect rate | — | — | — | — |
| Won count | — | — | — | — |

Export monthly snapshots for comparison:

```
export(format="csv", include_messages=false)
```

## Quick Reference: What to Measure When

| User Question | Metric | Tool Call |
|--------------|--------|-----------|
| "How's my pipeline doing?" | Stage counts + freshness | `pipeline_stats()` |
| "Where am I losing deals?" | Conversion rates per transition | `pipeline_stats()` + calculate |
| "Is my outreach working?" | Reply rate | Opening vs chatting counts |
| "Am I qualifying well?" | Qualification rate | Chatting vs qualified counts |
| "Which campaign works better?" | Rates per campaign tag | `search(tags=["campaign-x"], compact=true)` per campaign |
| "How fast am I closing?" | Cycle time | `export(stage="won", include_messages=true)` — check timestamps |
| "Am I responding fast enough?" | My-turn count, neglect rate | `pipeline_stats()` — my_turn and you_ghosted |
