---
name: prospect-scan
description: >
  Scan LinkedIn connections by headline keywords to find ICP matches, build tagged
  prospect lists, and prioritize who to message first. Use when the user says "find
  prospects", "scan my connections", "who should I message", "find leads", "who
  matches my ICP", "search my network", "find people to reach out to", or names a
  specific segment like "find recruitment consultants" or "find executive coaches"
  or "find financial advisors with $100M+ AUM". Supports subsegment
  campaigns for niche targeting within a broader ICP. Related: icp-definition for
  setting up ICP first, campaign-launch for running a campaign after scanning,
  dm-writing for crafting messages to scan results.
metadata:
  version: "1.0"
  author: linkninja
---

# Prospect Scan

Find ICP-matching connections in the user's LinkedIn network, organize them into tagged lists, and prioritize outreach order. Works for broad ICP scans and niche subsegment campaigns.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check for ICP:

| Situation | Action |
|-----------|--------|
| `additional_context` (ICP) exists | Extract headline keywords from it (see Step 1) |
| `additional_context` is empty AND user provides ad-hoc keywords | Use their keywords directly. Skip ICP extraction. |
| `additional_context` is empty AND no keywords given | **HARD STOP.** "I need to know who you're looking for. Want to set up your ICP first?" Point to **icp-definition**. |

3. Check `positioning_context` -- knowing the user's offer helps prioritize results.

## Workflow

### Step 1: Extract Keywords from ICP

Translate the ICP into headline search terms. See `references/keyword-extraction.md` for the full translation table.

Break down each ICP element:

| ICP Element | What to Look For in Headlines | Keyword Examples |
|-------------|------------------------------|-----------------|
| Service offering | What they sell or help with | "Coach", "Consultant", "Advisor", "Strategist" |
| Niche / vertical | Their specific area | "Recruitment", "Wealth Management", "Leadership", "SEO", "Career" |
| Business model | How they operate | "Founder", "Owner", "Solo", "Boutique", "Independent" |
| Industry / sector (if needed) | Broader context | "Financial Services", "Healthcare", "Professional Services", "Creative" |
| Seniority | Level markers | "Director", "Chief", "SVP", "Partner" |
| Function | Department signals | "Revenue", "Marketing", "Engineering" |

Build both include and exclude lists:

**Include:** Terms that signal a match (at least one must appear in headline)
**Exclude:** Terms that signal a definite non-match (none can appear)

Common excludes: `["Student", "Intern", "Looking for", "Seeking", "Open to work", "Retired"]`

### Step 2: Scan for New Prospects (Never Messaged)

```
scan_connections(
  headline_keywords=["<keyword1>", "<keyword2>", "<keyword3>"],
  headline_exclude=["Student", "Intern", "Looking for", "Retired"],
  has_conversation=false
)
```

**Interpret results:**

| Result Count | Meaning | Action |
|-------------|---------|--------|
| 50+ matches | Strong network alignment | Proceed with tagging and prioritization |
| 10-49 | Narrow but viable | Consider broadening keywords (see Step 2b) |
| < 10 | Too narrow or wrong network | Broaden significantly or adjust ICP |
| 200+ | May need tightening | Review results for quality. Add excludes if needed. |

### Step 2b: Broaden if Needed

If results are thin, try adjacent terms:

| Original | Adjacent Terms to Try |
|----------|-----------------------|
| "Founder" | "Co-Founder", "Managing Director", "Principal", "Owner" |
| "Coach" | "Mentor", "Facilitator", "Trainer", "Guide" |
| "Consultant" | "Advisor", "Strategist", "Specialist", "Practitioner" |
| "Financial Advisor" | "Wealth Manager", "Financial Planner", "Investment Advisor", "Fiduciary" |
| "Consultant" | "Advisor", "Strategist", "Specialist" |

### Step 3: Scan for Re-engagement Opportunities (Already Messaged)

```
scan_connections(
  headline_keywords=["<keyword1>", "<keyword2>", "<keyword3>"],
  headline_exclude=["Student", "Intern", "Looking for", "Retired"],
  has_conversation=true
)
```

These are warmer -- an existing conversation thread means lower friction. Re-engagement almost always converts better than cold outreach.

### Step 4: Tag the Results

Tag all matching connections with a descriptive tag:

```
tag_connections(
  connection_ids=[<id1>, <id2>, <id3>, ...],
  add_tags=["icp-match"]
)
```

For campaign-specific targeting, add a campaign tag too:

```
tag_connections(
  connection_ids=[<id1>, <id2>, <id3>, ...],
  add_tags=["icp-match", "campaign-mar-2026"]
)
```

### Step 4.5: Enrich the Cohort (Recommended Before Outreach)

> **Requires an active Sales Navigator connection.** If the user doesn't have Sales Nav, skip this step — they'll fall back to headline-only personalisation.

Tagged connections are great input for **Precision Flattery**, but you need real data — recent posts, current role, projects — to make praise specific. Run enrichment now while the cohort is still focused:

```
enrich_connections(
  filter={tags: ["icp-match"], is_enriched: false},
  re_enrich_after_days: 30,
  limit: 100
)
```

~6 sec/connection — for cohorts >50, return the `job_id` and ETA, don't block. Daily quota is 200/day. After completion, hand off to **connection-enrichment** or **lead-research** to surface specific hooks per contact, or directly to **cold-outreach** / **batch-drafting** which will pull `recent_posts` + `experience` from `get_enrichment` during drafting.

### Step 5: Prioritize Outreach Order

Not all prospects are equal. Work through these tiers in order:

| Priority | Who | How to Find | Why First |
|----------|-----|-------------|-----------|
| 1 | People who already replied and are waiting for you | `search_conversations(my_turn=true)` | Already engaged. Highest conversion. |
| 2 | ICP matches who engaged with your content | Ask the user. Tag as `warm-lead`. | Social proof of interest. |
| 3 | Mutual connections / shared context | `list_connections(detailed=true)` + user reviews profiles | Natural conversation opener. |
| 4 | Cold ICP matches, never messaged | `scan_connections(has_conversation=false)` | Volume play. Lowest conversion. |

Present the prioritized list to the user with recommended actions for each tier.

### Step 6: Check for Duplicates

Before any outreach, verify no existing conversations exist:

```
search_conversations(query="<prospect name>")
```

Sending a "cold" opener to someone with an existing thread is a trust-damaging mistake.

## Subsegment Campaigns

Users can run targeted scans for niches within their broader ICP. The main ICP stays unchanged -- subsegments are targeted via specific keywords and campaign tags.

### How It Works

1. User identifies a niche: "I want to find recruitment consultants specifically"
2. Build niche-specific keywords (narrower than the broad ICP)
3. Scan, tag with a subsegment tag, then hand off to **campaign-launch**

### Common Subsegment Examples

| Broad ICP | Subsegment | Scan Keywords |
|-----------|-----------|---------------|
| Consultants | Recruitment consultants | `["Recruitment", "Talent", "Staffing", "Executive Search"]` |
| Consultants | IT consultants | `["IT Consulting", "Technology Advisor", "Digital Transformation"]` |
| Financial advisors | Wealth managers / fiduciaries | `["Wealth", "Independent Advisor", "Fiduciary", "Family Office"]` |
| Fractional executives | Fractional CFO / CMO / COO | `["Fractional", "Interim", "Outsourced CFO", "On-Demand"]` |
| Coaches | Executive coaches for tech | `["Executive Coach", "Leadership Coach", "CTO Coach"]` |
| Coaches | Career coaches | `["Career Coach", "Career Transition", "Career Strategy"]` |
| Agency owners | SEO agencies | `["SEO Agency", "Search Marketing", "Organic Growth"]` |
| Agency owners | Creative agencies | `["Creative Director", "Brand Agency", "Design Agency"]` |

### Subsegment Scan Pattern

```
scan_connections(
  headline_keywords=["Recruitment", "Talent", "Staffing", "Executive Search"],
  headline_exclude=["Student", "Intern", "Looking for"],
  has_conversation=false
)
```

Tag with both the broad and subsegment tags:

```
tag_connections(
  connection_ids=[<ids>],
  add_tags=["icp-match", "recruitment-consultants"]
)
```

## Handling Large Result Sets

`scan_connections` processes up to 30k connections server-side but returns max 500 per call.

If results are capped:
- Review the first batch for quality before expanding
- Tighten keywords or add excludes to focus results
- Often the first page surfaces the strongest matches

For detailed profile information on specific connections:

```
list_connections(query="<name>", detailed=true, limit=50)
```

The `detailed=true` flag includes LinkedIn URLs so the user can review profiles.

## After the Scan

| Next Step | When | Skill |
|-----------|------|-------|
| Launch a campaign to this list | User has an offer ready | **campaign-launch** |
| Write individual DMs | Small list, personalized approach | **dm-writing** |
| Batch draft messages | Large list, need volume | **batch-drafting** |
| Refine the ICP based on results | Scan shows unexpected patterns | **icp-definition** |

## Guidelines

- Always extract keywords from the ICP -- do not guess. If the ICP is vague, help refine it first.
- Include keywords are OR-matched (at least one must appear). Exclude keywords are AND-matched (none can appear).
- Tag everything. Untagged scan results are lost the moment the conversation ends.
- Check for existing conversations before recommending cold outreach to any connection.
- If scan returns mostly wrong matches, the keywords are too broad. Tighten before proceeding.
- Recent connections (`connected_after`) tend to be warmer. Mention this option to the user.
- Present results with context: "Found 47 connections matching your ICP. 12 already have conversations, 35 are new prospects."
- Playbook targeting baseline: ~200 personalised connection requests per week to ICP. Once momentum builds, prioritise **warm signals** (profile views, post engagement, connection requests received) over fresh cold outreach — they convert dramatically better.

## Related Skills

- **icp-definition** -- Must be set before scanning. The ICP drives keyword extraction.
- **campaign-launch** -- The natural next step after building a tagged prospect list.
- **dm-writing** -- For crafting individual messages to high-priority prospects.
- **batch-drafting** -- For drafting messages at scale to large scan results.
- **cold-rescue** -- For re-engaging existing conversations found during the scan.
