---
name: lead-research
description: >
  Deep research on a single contact or a tagged cohort — enrich via Sales Nav,
  then surface specific personalization hooks per contact (recent posts, pivotal
  experience, mutual signals). The output is a research brief ready to feed
  cold-outreach or batch-drafting for Precision Flattery openers. Use when the
  user says "research this lead", "deep dive on [name]", "build me a brief on
  these prospects", "find me hooks for [cohort]", "what should I open with for
  [name]", "give me angles for the campaign", or "lead research". Requires an
  active Sales Navigator connection. Related: connection-enrichment for the
  raw enrichment mechanics, prospect-scan for finding the cohort first,
  cold-outreach to consume the brief in a Precision Flattery opener,
  batch-drafting / sequence-runner for using the brief at scale.
metadata:
  version: "1.0"
  author: linkninja
---

# Lead Research

Turn a contact (or list of contacts) into a research brief — the specific hooks each one should be opened with. Pulls Sales Navigator data, finds one credible angle per contact, summarises it in 1–2 lines so the next skill (cold-outreach, batch-drafting, sequence-runner) can use it for **Precision Flattery** without re-doing the lookup.

> **Requires an active Sales Navigator connection.** This skill leans on the LinkNinja enrichment pipeline. If the user doesn't have Sales Nav, fall back to **prospect-scan** + headline-only personalization.

## Before Starting

1. Run `get_context()` to load the user's sales context.
2. Confirm the input shape:

| Input | Pattern |
|-------|---------|
| Single contact by name | "Research [name]" — find via `search_conversations(query="<name>")` or `list_connections(query="<name>")` |
| List of contacts | "Research these conversations: [ids]" — pass `conversation_ids` directly |
| Tagged cohort | "Research my Q1 campaign cohort" — `filter: {tags: ["campaign-q1"]}` |
| ICP-matched cohort | "Research my ICP matches" — `filter: {tags: ["icp-match"]}` |

3. **Check Sales Nav availability.** Try a small enrichment preview first:

```
enrich_connections(filter={...}, preview_only: true, limit: 1)
```

If the response indicates no Sales Nav access, stop and tell the user:

> *"This skill needs Sales Navigator. Without it, you'll only get headline-level hooks — happy to do that with prospect-scan instead."*

4. Check daily quota (200/day default) — if low, prioritise the highest-value contacts.

## Workflow

### Step 1: Confirm the Cohort

Before burning quota, preview the scope:

```
enrich_connections(
  filter={tags: ["campaign-q1"], is_enriched: false},
  preview_only: true,
  limit: 50
)
```

Show the count + sample to the user. Confirm they want to proceed.

### Step 2: Enrich (If Not Already)

Skip already-enriched contacts (default behaviour). For stale data (>30 days), pair `force=true` with `re_enrich_after_days=30`:

```
enrich_connections(
  filter={tags: ["campaign-q1"], is_enriched: false},
  re_enrich_after_days: 30,
  limit: 50
)
```

Returns a `job_id`. ~6 sec per connection — cohorts >50 should hand back the `job_id` and ETA, not block the conversation. See `references/enrichment-sections.md`.

### Step 3: Pull the Research Sections

Once the job completes (poll `get_job_status`), pull the sections that matter for personalization:

```
get_enrichment(
  ids: [<conv/conn_ids>],
  sections: ["identity", "experience", "recent_posts", "education", "groups", "interests"]
)
```

Section choice by goal:

| Goal | Sections |
|------|----------|
| Cold opener (Precision Flattery) | `identity`, `recent_posts`, `experience` |
| Mutual-signal opener (shared school / group / interest) | `education`, `groups`, `interests`, `causes` |
| Authority assessment | `identity`, `experience`, `network` |
| Volunteer / values angle | `volunteer`, `causes` |
| Contact details for follow-up | `contact` |

### Step 4: Build the Brief

For each contact, distill into a **1–2 line research brief**. The format:

```
[Name] — [identity headline]
Hook: [the single most specific, credible angle to open with]
Source: [which section + which item]
```

Examples:

```
Sarah Liu — Founder, boutique executive coaching practice
Hook: Recent post (Apr 22) on opening her second cohort and finding the right-fit candidates is harder than expected — concrete pain, fresh.
Source: recent_posts[0]
```

```
Tom Chen — Independent fractional CFO (services 6-figure agency owners)
Hook: Co-authored a piece on cash-flow forecasting for boutique service firms in March; aligns directly with what your positioning addresses.
Source: recent_posts[2] + experience.previous (former practice CFO)
```

```
James Walker — Independent financial advisor, 5 years post-corporate
Hook: Same school as you (Sydney Uni, finance). Can lead with the shared anchor before any pitch.
Source: education[0] (mutual)
```

### Quality Bar (DO / DON'T)

| DO | DON'T |
|----|-------|
| Pick ONE specific item per contact | Combine 4 weak signals into a vague angle |
| Quote the actual data ("Apr 22 post on…") | Generalise ("recent post") |
| Match the angle to the user's positioning | Pick a hook that has nothing to do with what we sell |
| Note when there's no good hook | Force a hook from thin material |

If the data genuinely doesn't yield a specific hook (no recent posts, no mutual signals, generic experience), say so:

```
James Park — Independent IT consultant
Hook: NONE — last post was 2023, no mutual signals, generic experience. Skip or fallback to headline.
```

That's a useful brief too. Honest signal saves the user from forcing a fake personalization.

### Step 5: Output the Brief

Save the brief in two places:

1. **As `ai_notes`** on each conversation/connection (so the brief travels with the contact through the pipeline):

```
bulk_update(updates=[
  {id: "conv_xxx", ai_notes: "Lead research brief: Founder, boutique exec coaching practice. Hook: Apr 22 post on opening second cohort + finding right-fit candidates. Source: recent_posts[0]."},
  {id: "conv_yyy", ai_notes: "Lead research brief: Fractional CFO for service firms. Hook: March cash-flow piece + practice CFO background. Source: recent_posts[2] + experience.previous."}
])
```

2. **As a summary report to the user**, ranked by hook quality:

> **Lead Research Brief — Q1 campaign (47 contacts)**
>
> **Tier 1 — strong hooks (12):** [list with one-line briefs]
>
> **Tier 2 — workable hooks (28):** [list, brief]
>
> **Tier 3 — no clear hook (7):** [names; recommend skip or headline-only]
>
> **Next step:** run `cold-outreach` or `batch-drafting` over the Tier 1+2 cohort. The briefs are saved to `ai_notes` so drafts can reference them.

## Patterns

### Pattern A: Single Contact Deep Dive

> "Research [name] before I message them."

```
search_conversations(query="<name>", compact: true)  # or list_connections(query="<name>")
get_enrichment(ids: ["<id>"], sections: ["identity", "experience", "education", "skills", "recent_posts", "network", "flags"])
```

If not enriched, run `enrich_connections(connection_ids=[<id>], limit=1)` first (1 quota unit, 6 sec).

Output: a 4–5 line brief covering background, current role, recent activity, mutual signals, and the recommended opening angle.

### Pattern B: Pre-Campaign Cohort Research

> "Research everyone in my Q1 campaign before I draft openers."

Standard workflow above. Cohort sizes:

| Cohort | Strategy |
|--------|----------|
| ≤20 | Single enrichment job, full section pull, individual briefs |
| 20–100 | Single job, focused sections (`recent_posts`, `experience`, `identity`), tier-ranked report |
| 100+ | Run in batches; prioritise enriched contacts first; tier-rank aggressively |

### Pattern C: Mid-Sequence Hook Refresh

> "Day 7 of the GR sequence is coming up. Pull fresh recent_posts so my Day 7 angle isn't stale."

```
enrich_connections(
  filter={tags: ["gr3"]},
  force: true,
  re_enrich_after_days: 7,
  limit: 50
)
```

Then `get_enrichment(ids: [...], sections: ["recent_posts"])` for fresh hooks. See **sequence-runner** for the full sequence cadence.

### Pattern D: Cold Conversation Re-Engagement Hook

> "Find me a fresh angle for [cold conversation]."

```
get_enrichment(ids: ["<conv_id>"], sections: ["recent_posts"])
```

Look at posts since last contact (compare `parsed_datetime` to `last_message_at` from the conversation). The newest post relevant to the conversation topic is the re-engagement hook. Hand back to **cold-rescue** for the actual draft.

## Confidentiality

The enrichment data is rich — recent posts (often public, but sometimes filtered), contact info, network metrics. Don't dump full payloads to the user. Surface only the hook + source per contact. Use the data to inform briefs; the user doesn't need to see the raw enrichment unless they ask.

## Workflow Summary

```
1. get_context()                       → Load user context
2. Confirm cohort (single | list | tagged | ICP-matched)
3. enrich_connections(preview_only)    → Verify scope, no quota cost
4. enrich_connections(filter, ...)     → Run async job (Sales Nav)
5. get_job_status [poll]               → Wait for completion
6. get_enrichment(ids, sections)       → Pull per goal
7. Distill 1–2 line brief per contact  → Single hook, source-backed
8. Save briefs as ai_notes (bulk_update)  +  report to user
9. Hand off to cold-outreach / batch-drafting / sequence-runner / cold-rescue
```

## Job Lifecycle (Cancel & Resume)

- **Cancel mid-flight:** `cancel_job(job_id="<job_id>")` if you discover the cohort is wrong after kicking off enrichment. Quota consumed up to that point isn't refunded.
- **Resume:** if the user says *"continue"* / *"resume"* / *"check on it"* — call `continue_active_job(type="enrich")` first. Don't fire a new enrichment job while one is in flight.

## Guidelines

- **Sales Navigator gate:** every workflow above assumes Sales Nav. If not available, say so and hand off to **prospect-scan** for headline-only research.
- **One specific hook per contact** beats four vague ones. Better to flag "no clear hook" than to force a fake personalization.
- **Save briefs as `ai_notes`** so the next skill in the chain (drafting) doesn't have to re-do the research.
- **Daily quota = 200.** For 200+ contacts, prioritise: highest-value tier first, then what's left tomorrow.
- **`re_enrich_after_days` is your friend.** Default to 30. For mid-sequence hook refresh, drop to 7. Don't burn quota refreshing data that's still fresh.
- Don't surface job IDs, chunk tokens, or quota mechanics in user-facing reports. Translate to user terms ("enriching ~50 contacts, ~5 min").
- This skill is research, not drafting. Hand off after the brief is built.

## Power-Ups (Optional)

See [POWER-UPS.md](../../../POWER-UPS.md) for full setup.

- **Subagent:** Parallel research agents — for cohorts of 100+, spawn 5 subagents (20 contacts each). Cuts wall-clock time ~5× and lets you run cohort research while you do something else.
- **MCP:** GitHub — if your ICP includes technical buyers, pull their open-source activity to deepen Precision Flattery beyond what Sales Nav surfaces.
- **MCP:** Notion — save each research brief to your knowledge base so you can re-use insights without re-running enrichment.
- **Model:** Sonnet 4.6+ (good balance of quality and cost; brief generation isn't reasoning-heavy).

## Related Skills

- **connection-enrichment** — The raw enrichment mechanics (preview, force, re-enrich); lead-research is the user-facing wrapper that adds the brief layer
- **prospect-scan** — Find the cohort first; lead-research deepens it
- **cold-outreach** — Consume the brief for Precision Flattery openers
- **batch-drafting** — Use briefs (saved as `ai_notes`) when drafting at scale
- **sequence-runner** — Refresh hooks per sequence touch
- **cold-rescue** — Use briefs to find re-engagement angles
- **smart-tagging** — Combine enrichment data with conversation intelligence for evidence-based tagging
