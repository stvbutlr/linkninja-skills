---
name: connection-enrichment
description: >
  Enrich connections with Sales Navigator data (recent posts, work history,
  skills, contact details) so subsequent drafts can reference one specific item
  credibly — the foundation for Precision Flattery. Wraps enrich_connections
  (async job) and get_enrichment (read). Use when the user says "enrich my
  connections", "pull Sales Nav data", "research these prospects", "get Sales
  Nav details", "deep dive on this person", "enrich for the campaign", or
  "before we draft, get me their recent posts". Handles quota tracking, the
  >50-batch async pattern, and re-enrich semantics. Related: campaign-launch
  for the campaign cohort enrichment pattern, cold-outreach for using
  enrichment data in Precision Flattery, prospect-scan for finding the
  cohort to enrich.
metadata:
  version: "1.0"
  author: linkninja
---

# Connection Enrichment

Pull Sales Navigator profile data so subsequent drafts can reference one specific item — a recent post, a project, a shared school — credibly. **This is the input pipeline for Precision Flattery** (specific niche praise, not generic). Without it, openers fall back to headline-only references and feel automated.

## Before Starting

1. Run `get_context()` to load the user's sales context.
2. Identify the cohort to enrich. Either:

| Source | How |
|--------|-----|
| Specific connections | `connection_ids: [<int>, <int>, ...]` |
| Tagged segment | `filter: {tags: ["icp-match", "campaign-q1"]}` |
| Headline keywords | `filter: {headline_keywords: ["VP Sales", "Founder"]}` |
| Recently connected | `filter: {connected_after: "<ISO date>"}` |
| Filter by enrichment status | `filter: {is_enriched: false}` |

3. **Check daily quota.** Default 200 enrichments/day, shared with lead-list enrichment. The `quota` object on every response shows usage.

## The Enrichment Job Flow

This is an **async job**. The tool returns a `job_id` immediately, **not** the data. Read the data via `get_enrichment(ids: [...])` after the job completes.

### Step 1: Preview Scope (Strongly Recommended)

Before burning quota, preview the scope:

```
enrich_connections(
  filter={tags: ["campaign-q1"], is_enriched: false},
  preview_only: true,
  limit: 100
)
```

Returns a count and sample. Confirm with the user before proceeding.

### Step 2: Start the Enrichment Job

```
enrich_connections(
  filter={tags: ["campaign-q1"], is_enriched: false},
  re_enrich_after_days: 30,
  limit: 100
)
```

Returns: `job_id`, `estimated_duration_seconds`, `quota` summary.

**Timing:** ~6 seconds per connection. Plan accordingly:

| Batch size | ETA |
|------------|-----|
| 10 | ~1 minute |
| 50 | ~5 minutes |
| 100 | ~10 minutes |
| 200 | ~20 minutes |
| 500 (max) | ~50 minutes |

For batches **>50**: tell the user the ETA and that you'll continue when the job completes. Don't block the conversation.

### Step 3: Poll Job Status

```
get_job_status(job_id="<job_id>")
```

Recommended interval: 30s for small batches, 60s for larger ones. Don't spam.

### Step 4: Read Enriched Data

When the job completes, fetch the data via `get_enrichment`. Choose sections based on what the user needs to do next:

```
get_enrichment(
  ids: [<conv_id_1>, <conv_id_2>, ..., up to 100],
  sections: ["recent_posts", "experience"]
)
```

Per-contact errors don't fail the batch — each result has `enriched=true/false` with a reason.

## Section Selection by Use Case

| User goal | Sections to pull |
|-----------|------------------|
| Drafting cold outreach with Precision Flattery | `["recent_posts", "experience"]` |
| Researching ICP fit on a single contact | `["identity", "experience", "education", "skills", "network"]` |
| Pulling contact details for export / outbound | `["contact"]` (tiny payload) |
| Finding mutual signals (shared schools, groups, causes) | `["education", "groups", "interests", "causes"]` |
| Detecting intent indicators | `["flags"]` (premium, open_profile, is_open_to_work, is_hiring) |
| Bulk hook-mining for a campaign | `["recent_posts"]` (most efficient) |

Full section list (omit `sections` for full payload): `identity`, `experience`, `education`, `skills`, `certifications`, `projects`, `languages`, `recent_posts`, `volunteer`, `interests`, `groups`, `causes`, `contact`, `network`, `flags`, `throttled_sections`. See `references/enrichment-sections.md` for the full spec.

## Re-enrichment Semantics

**Don't burn quota on duplicates.** By default, already-enriched contacts are skipped — no quota cost.

| Goal | Pattern |
|------|---------|
| Enrich only new contacts | Default behaviour — `enrich_connections(filter={is_enriched: false})` |
| Refresh data older than N days | `force=true, re_enrich_after_days=30` (default 30 with force) |
| Force a complete refresh | `force=true` (omit `re_enrich_after_days` — burns quota; use sparingly, only when user explicitly asks) |
| Skip already-fresh contacts | `re_enrich_after_days=7` — only refresh older than 7 days |

Before forcing a re-enrich on the whole cohort, check `enriched_at` via `list_connections` — if data is recent (<7 days), skip the call entirely.

## Patterns

### Pattern A: Pre-Campaign Enrichment

> "Before I send the Q1 campaign, enrich the cohort so I can reference recent posts."

```
enrich_connections(
  filter={tags: ["campaign-q1"], is_enriched: false},
  limit: 100
)
```

Wait for completion, then pull `recent_posts` and `experience` for use in **cold-outreach**'s Precision Flattery.

### Pattern B: Single Contact Deep Dive

> "Give me everything you can find on [name]."

```
get_enrichment(
  ids: ["<conn_id>"],
  sections: ["identity", "experience", "education", "skills", "recent_posts", "network", "flags"]
)
```

If the contact isn't enriched yet, run `enrich_connections(connection_ids=[<id>], limit=1)` first.

### Pattern C: Bulk Hook-Mining

> "I need a fresh angle for everyone in my qualified pipeline."

```
search_conversations(stage="qualified", compact=true)
→ extract conv_xxx ids
get_enrichment(ids=[<extracted>], sections=["recent_posts"])
```

Loop over results, drafting one personalised follow-up per contact referencing their most recent post.

### Pattern D: Re-Enrich Stale Cohort

> "My ICP-matched connections were enriched 2 months ago. Refresh them."

```
enrich_connections(
  filter={tags: ["icp-match"]},
  force: true,
  re_enrich_after_days: 60,
  limit: 100
)
```

Only contacts with enrichment older than 60 days will burn quota; recent ones are skipped via `skipped_too_fresh`.

## Daily Quota Management

- **200 enrichments/day** default (configurable). Shared with lead-list enrichment.
- Quota tracked via the `quota` object in every response.
- If quota is low, prioritise the cohort that will be drafted *today*. Defer the rest.
- Quota resets daily. For >200 contacts, run the second batch tomorrow.

## Confidentiality

The Sales Navigator data is rich — including contact info (emails, phones, twitter). Don't share enrichment payloads outside of LinkNinja's surfaces. Use the data to inform drafts; don't paste it into the user's view unless they specifically asked for that contact's profile.

## Workflow Summary

```
1. get_context()                          → Load user context
2. enrich_connections(filter, preview_only) → Verify scope, no quota cost
3. enrich_connections(filter, ...)        → Start the async job
4. get_job_status(job_id) [poll]          → Wait for completion
5. get_enrichment(ids, sections)          → Read the saved data
6. Use data for downstream skill          → cold-outreach, batch-drafting, sequence-runner
```

## Guidelines

- **Always preview first** for batches >20. Quota is finite.
- For >50 contacts, return the `job_id` and ETA to the user — don't block.
- Use `re_enrich_after_days` whenever paired with `force=true` to avoid wasting quota.
- Pull only the `sections` you need. Smaller payloads = faster downstream loops.
- Per-contact errors are normal (LinkedIn rate-limits, profile privacy). Continue with the rest.
- Don't surface job IDs in user-facing reports — translate to user terms ("enriching ~50 contacts, ~5 min").
- Pair enrichment with **cold-outreach** or **batch-drafting** in the same session — the data is freshest right after enrichment.

## Related Skills

- **campaign-launch** — Inserts an enrichment step before drafting the campaign cohort
- **cold-outreach** — Consumes `recent_posts` + `experience` for Precision Flattery openers
- **batch-drafting** — Uses enrichment data per item via the `shared_bundle` and per-item drafting
- **prospect-scan** — Finds the cohort that this skill enriches
- **smart-tagging** — Combines enrichment data with conversation intelligence for evidence-based tagging
- **sequence-runner** — Multi-touch sequences benefit from fresh `recent_posts` at each touch
