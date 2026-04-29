---
name: lost-deal-analysis
description: >
  Analyze lost deals to understand why deals are being lost — drop-off stage,
  common objections, conversation patterns, and ICP fit of lost prospects. Use
  when the user says "analyze lost deals", "why am I losing", "lost deal
  analysis", "what went wrong", "deal loss patterns", "why did I lose", "lost
  deal review", or "understand my losses". Exports lost and won conversations,
  compares across dimensions, and surfaces actionable loss reasons. Related:
  won-deal-analysis for winning pattern detection, pipeline-health-check for
  overall pipeline diagnosis, cold-rescue for re-engaging stalled conversations.
metadata:
  version: "1.0"
  author: linkninja
---

# Lost Deal Analysis

Understand why deals are being lost, where in the pipeline they drop off, what patterns appear in the losses, and how lost deals differ from won deals. Feed insights back into context to prevent future losses.

For each lost deal, frame the analysis using the playbook's **A–B Method**: at the moment of loss, what was their Point A (current state) and Point B (desired state) — and where did the gap between them break? Lost deals usually fail because A wasn't surfaced clearly, B wasn't tied to your offer, or the path between them felt risky. Patterns in those failure modes are the most valuable signal.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check data availability:

| Check | How | If Insufficient |
|-------|-----|-----------------|
| Lost deals count | `export_conversations(stage="lost", include_messages=false)` | Need at least 3 lost deals. Tell the user: "You need some lost deals to analyze patterns. This is actually good news — it may mean you're not losing deals yet." |
| Won deals count | `export_conversations(stage="won", include_messages=false)` | Lost-only analysis still works. Note that comparison will be limited. |
| ICP defined | Check `additional_context` from `get_context()` | Analysis still works but ICP fit assessment will be skipped. Suggest **icp-definition**. |

3. If fewer than 3 lost deals: stop and explain. Do not fabricate patterns from 1-2 data points.
4. If sufficient data: proceed to the full analysis.

## Workflow

### Step 1: Export Lost Deals

Pull all lost conversations with full message transcripts:

```
export_conversations(stage="lost", include_messages=true)
```

If `has_more` is true, fetch the next page immediately:

```
export_conversations(stage="lost", include_messages=true, page=2)
```

Continue until all pages are loaded. Do not skip pages.

### Step 2: Check Archived Conversations

Archived conversations may represent additional losses under different labels:

```
search_conversations(include_archived=true, compact=true)
```

Look for archived conversations with reasons like `not_a_fit`, `ghosted`, `competitor`. These are functional losses even if not staged as "lost." Include them in the analysis if relevant.

### Step 3: Loss Inventory

Build the baseline picture of all lost deals:

| Metric | Value |
|--------|-------|
| Total lost deals | X |
| Total archived-as-lost | Y |
| Combined losses | X + Y |
| Earliest loss | [date] |
| Most recent loss | [date] |

**ICP Fit Check** (if ICP is configured):

Review each lost deal's headline, role, company against the user's ICP:

| ICP Fit | Count | % of Losses | Implication |
|---------|-------|-------------|-------------|
| Strong fit | X | Y% | Lost a good prospect — process problem |
| Partial fit | X | Y% | Borderline — may need tighter ICP |
| Poor fit | X | Y% | Should not have been targeted — tighten ICP |

If more than 40% of losses are poor ICP fit, the primary problem is targeting, not sales execution.

### Step 4: Drop-Off Stage Analysis

Where in the pipeline did conversations go to lost? This is the most diagnostic section.

For each lost deal, determine the last active stage before it was moved to lost (look at the conversation history and classification).

| Lost From Stage | Count | % of Losses | Diagnosis |
|-----------------|-------|-------------|-----------|
| Opening (never replied) | X | Y% | Messaging or targeting problem |
| Chatting | X | Y% | Failed to qualify — not surfacing needs |
| Qualified | X | Y% | Failed to advance — follow-through problem |
| Discovery | X | Y% | Proposal or value articulation problem |
| Closing | X | Y% | Objection handling or pricing problem |

**Interpretation guide:**

| Heaviest Drop-off | What It Means | Where to Focus |
|-------------------|---------------|----------------|
| Opening | Messages not landing or wrong audience | ICP, opening message quality |
| Chatting | Conversations don't progress past small talk | Qualifying questions, need discovery |
| Qualified | Interest exists but no next step happens | Clear CTAs, meeting proposals |
| Discovery | Prospect understands but doesn't commit | Value proposition, case studies, risk reduction |
| Closing | Deal falls apart at the finish line | Objection handling, pricing, urgency |

### Step 5: Common Loss Reasons

Read every lost conversation transcript and categorize the reason:

| Pattern | Count | % | Example Quote | Implication |
|---------|-------|---|---------------|-------------|
| Timing ("not right now") | X | Y% | "Looking at this next quarter" | Archive as `timing`, set reminder 60-90 days |
| Budget objection | X | Y% | "Can't justify the spend" | Reframe around ROI, smaller entry point |
| Went with competitor | X | Y% | "We went with [competitor]" | Competitive positioning gap — update positioning_context |
| Ghosted after qualifying | X | Y% | No reply after strong interest | Follow-up cadence too slow or too aggressive |
| Not ICP on reflection | X | Y% | Role/company didn't match | Tighten ICP criteria |
| Authority gap | X | Y% | "Need to check with my boss" | Target decision makers, multi-thread |
| No perceived need | X | Y% | "We're happy with what we have" | Pain discovery questions not landing |
| Scope/fit mismatch | X | Y% | "That's not quite what we need" | Qualifying questions missed the mark |

If more than 3 deals share a pattern, it is a systemic issue worth addressing.

**Timing losses deserve special treatment.** These are not true losses — they are deferred pipeline. If timing is the top reason:

```
update_conversation(
  id="<id>",
  archive={archived: true, reason: "later"},
  reminder="in 90 days",
  ai_notes="Lost deal analysis: timing objection. Re-engage in 90 days."
)
```

### Step 6: Export Won Deals for Comparison

```
export_conversations(stage="won", include_messages=true)
```

Paginate if `has_more` is true.

### Step 7: Won vs Lost Comparison

Compare the two populations across these dimensions:

| Dimension | Won Deals | Lost Deals | Gap |
|-----------|-----------|------------|-----|
| Average message count | X | Y | +/- Z |
| ICP match | High/Med/Low distribution | High/Med/Low distribution | Where the split is |
| Time to qualification | X days avg | Y days avg | Faster or slower? |
| Most common exit stage | Won from closing | Lost from [stage] | Where losses diverge |
| Question ratio (user asks vs prospect asks) | X% | Y% | Who drives the conversation? |
| Response time (user's avg reply delay) | X hours/days | Y hours/days | Slower on losses? |
| Opening message style | Pattern | Different pattern? | Messaging difference |
| Tags present | Common tags | Missing tags? | Signal gap |

**Key comparisons to highlight:**

- If lost deals have significantly more messages: conversations dragged without advancing
- If lost deals have fewer messages: dropped too early, insufficient nurturing
- If won deals qualify faster: speed to qualification matters
- If lost deals lack a specific tag present on wins: that tag is a buying signal
- If the user replies slower on lost deals: attention allocation problem

### Step 8: Pipeline Context

```
get_stats()
```

Place the loss analysis in context:

| Metric | Value |
|--------|-------|
| Total active pipeline | X |
| Win rate (won / (won + lost)) | X% |
| Loss rate | X% |
| Active-to-closed ratio | X:Y |

If win rate is below 15%, losses are the dominant outcome and the recommendations carry more urgency.

### Step 9: Recommendations

Based on the analysis, provide 3-5 prioritized recommendations. Each must be specific and actionable.

**Recommendation format:**
1. **What to do** — specific action
2. **Why** — tied to a specific finding
3. **How** — which skill or tool to use

**Recommendations by finding:**

| Finding | Recommendation |
|---------|---------------|
| Most losses are poor ICP fit | "Tighten your ICP. X% of losses were wrong-fit prospects. Run **icp-definition** to refine targeting." |
| Ghosted after qualifying is top reason | "Your follow-up cadence has a gap. Use **reminder-engine** to set 3-day follow-ups on all qualified conversations." |
| Losses pile up from chatting stage | "You're not qualifying fast enough. See **dm-writing** for qualifying question patterns." |
| Timing is the top loss reason | "These aren't true losses. Archive with reminders and re-engage later. Use **cold-rescue** when reminders fire." |
| Competitor losses are high | "Update your positioning to differentiate. Run **voice-profile-setup** to sharpen how you articulate your value." |
| Won deals have a tag that lost deals lack | "The tag `[tag]` appears on X% of wins but only Y% of losses. Use **smart-tagging** to ensure this signal is captured early." |
| User replies slower on lost deals | "Attention predicts outcomes. Respond within 24 hours to qualified+ conversations. **full-morning-triage** daily prevents this." |

**Feed insights into context (with user approval):**

If patterns warrant ICP or positioning refinements:

```
update_context(
  additional_context="Lost deal analysis insights: [X]% of losses were poor ICP fit — [describe pattern]. Top loss reason: [reason] ([Y]% of losses). Won deals qualify [Z] days faster than lost deals. Avoid targeting [profile pattern from losses]. Key buying signal: [tag/pattern from wins not present in losses]."
)
```

Always confirm updates with the user before saving. Summarize what you plan to change and ask for approval.

## Report Template

Present the full analysis as a structured report:

```
## Lost Deal Analysis Report

**Data:** [X] lost deals, [Y] won deals analyzed, [Z] archived losses included

### Loss Inventory
- Total losses: [X]
- Date range: [earliest] to [most recent]
- ICP fit: [X]% strong, [Y]% partial, [Z]% poor

### Where Deals Were Lost
| Stage | Count | % |
|-------|-------|---|
| Opening | X | Y% |
| Chatting | X | Y% |
| Qualified | X | Y% |
| Discovery | X | Y% |
| Closing | X | Y% |

Primary drop-off point: [stage] — [brief diagnosis]

### Top Loss Reasons
1. [reason]: [X] deals ([Y]%) — [what to change]
2. [reason]: [X] deals ([Y]%) — [what to change]
3. [reason]: [X] deals ([Y]%) — [what to change]

### Won vs Lost Comparison
[comparison table]

Key difference: [the single most telling gap between won and lost]

### Pipeline Context
- Win rate: [X]%
- Loss rate: [Y]%
- Active pipeline: [Z] conversations

### Recommendations
1. [highest priority — tied to biggest loss pattern]
2. [second priority]
3. [third priority]

### Optional: Export to CSV
```
export_conversations(stage="lost", format="csv", include_messages=true)
```
```

## Guidelines

- Do not analyze with fewer than 3 lost deals. Patterns from 1-2 deals are noise.
- Always compare lost against won. Lost-only analysis misses half the picture.
- Present findings as tables and specific numbers, not vague observations.
- Quote actual message excerpts to illustrate patterns — these make the analysis concrete.
- This skill is analysis only. Do not change stages or draft messages. The only write operation is optionally updating context via `update_context()` with user approval.
- `bulk_update` does NOT support `draft_message`. Do not attempt batch drafts through bulk_classify.
- Timing losses are not true losses. Flag them separately and recommend archiving with reminders.
- Handle `has_more` pagination on every export. Missing pages means incomplete analysis.
- If the user has 20+ lost deals, still analyze all of them. Lost deal patterns need the full picture — unlike won deals, you cannot assume recent losses represent the same patterns as older ones.
- Cross-reference findings with **won-deal-analysis** if the user has run it. Shared insights compound.
- Offer CSV export for users who want offline analysis.
- Confirm all context updates with the user before saving. These affect all future AI operations.

## Related Skills

- **won-deal-analysis** — Complementary: find winning patterns (run both for the full picture)
- **pipeline-health-check** — Overall pipeline diagnosis with conversion funnels
- **cold-rescue** — Re-engage conversations that went cold before being lost
- **icp-definition** — Refine targeting if analysis reveals ICP fit problems
- **reminder-engine** — Set follow-up reminders to prevent ghost-related losses
- **stage-configuration** — Adjust stage criteria based on drop-off findings
- **voice-profile-setup** — Sharpen positioning if competitor losses are high
