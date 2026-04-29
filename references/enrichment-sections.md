# Connection Enrichment (Sales Navigator)

LinkNinja can enrich connections with Sales Navigator profile data. Enrichment captures rich context that powers personalised drafts — recent posts, work history, interests — turning generic outreach into Precision Flattery.

## How It Works

Two tools, one async pattern:

1. **`enrich_connections`** — kicks off an async job. Returns a `job_id`, not the data.
2. **`get_enrichment`** — reads the captured data after the job completes. Synchronous, batched (1–100 ids per call).

## The 16 Sections

`get_enrichment` returns these sections. Pass `sections: [...]` to filter — omit for the full payload.

| Section | Contents | Best for |
|---------|----------|----------|
| `identity` | Name, headline, current company / title / location, summary, profile picture, member URN, `enriched_at` | Quick contact resolution |
| `experience` | Full work history | ICP fit assessment, "you went from X to Y" hooks |
| `education` | Full education history | Mutual-school openers, credibility signals |
| `skills` | Skills with endorsement counts | Technical-buyer detection |
| `certifications` | Credentials | Credibility, niche detection |
| `projects` | Public projects | Substance-based openers |
| `languages` | Spoken languages | Geographic / cultural context |
| `recent_posts` | Up to 5 most recent posts (text, parsed_datetime, reaction/comment/repost counters, share_url, is_repost) | **Precision Flattery** — primary input |
| `volunteer` | Volunteer experience (~30% of contacts have it) | Connection beyond business |
| `interests` | People / companies / schools they follow | Conversation hooks |
| `groups` | LinkedIn groups | Niche detection, shared community |
| `causes` | Causes supported | Values alignment hooks |
| `contact` | Normalised `{emails, phones, websites, twitter, socials}` | Direct outreach (when allowed) |
| `network` | `connections_count`, `followers_count`, `shared_connections_count`, `network_distance`, `can_send_inmail` | Influence and reach assessment |
| `flags` | `premium`, `open_profile`, `verified`, `is_creator`, `is_hiring`, `is_open_to_work` | Filtering, intent signals |
| `throttled_sections` | Sections LinkedIn returned partial data for | Trust-but-verify |

## Patterns

### Drafting personalised replies

Pull the sections relevant to drafting:

```
get_enrichment(ids: [conv_xxx], sections: ["recent_posts", "experience"])
```

Use `recent_posts` to reference one specific post by name. Use `experience` to anchor "I see you went from A to B" hooks. **Match to Precision Flattery rules** — specific, niche, credible.

### Bulk hook-mining

For a tagged campaign cohort, batch-fetch posts for all targets:

```
get_enrichment(ids: [conv_a, conv_b, ..., conv_z], sections: ["recent_posts"])
```

One batch call → loop drafts personalised against each contact's most recent post.

### ICP filter then drill in

For pure ICP filtering (company / location / title), use `scan_connections` first — much smaller per-result payload — then call `get_enrichment` only on the matches you actually want to drill into:

```
scan_connections(headline_keywords=[...], company="Stripe")
→ filter by `is_enriched: true` mentally
→ get_enrichment(ids: [matched_ids], sections: ["recent_posts"])
```

### Contact details only

For just normalised contact info:

```
get_enrichment(ids: [...], sections: ["contact"])
```

Tiny, fast payload.

## Enrichment Job Mechanics

### Throughput

LinkedIn rate-limits to ~6 seconds per connection. Plan accordingly:

| Batch size | Estimated duration |
|------------|--------------------|
| 10 | ~1 minute |
| 50 | ~5 minutes |
| 100 | ~10 minutes |
| 200 | ~20 minutes |
| 500 (max) | ~50 minutes |

For batches >50, return the `job_id` to the user with an ETA — don't block the conversation. Poll `get_job_status` every 30s for small batches, every 60s for larger ones.

### Daily Quota

Default **200 enrichments/day**, shared with lead-list enrichment. Track via the `quota` object on every response.

### Default Behaviour

- Already-enriched connections are **skipped** by default — no quota cost on duplicates.
- `force=true` re-enriches even already-enriched contacts. **Always pair with `re_enrich_after_days`** (defaults to 30 with `force=true`).
- Use `re_enrich_after_days=N` to refresh ONLY connections enriched more than N days ago. Skipped contacts are reported in `skipped_too_fresh` / `skipped_too_fresh_details`.
- Before forcing re-enrichment, check `enriched_at` via `list_connections` — if data is recent (< 7 days), skip the call entirely.

### Per-contact errors don't fail the batch

If a contact isn't enriched yet, its result entry has `enriched=false` with a reason. If an id isn't found, `error="not_found"`. Other contacts in the batch still return their data.

## When Enrichment Is the Right Move

| Situation | Enrich? |
|-----------|---------|
| About to draft personalised cold outreach to a tagged cohort | Yes — feeds Precision Flattery |
| Researching ICP fit on a specific contact | Yes — pull `experience`, `education`, `skills`, `network` |
| Just need a quick contact look-up | No — `list_connections` or `search_conversations` is enough |
| Pulling contact details for export | Yes — `sections: ["contact"]` is fast and tiny |
| About to send the same template to 200 connections (`draft_mode: locked`) | No — locked sequences don't need enrichment |
| Re-engaging cold conversations | Yes if data is older than 30 days — fresh `recent_posts` give new hooks |

## Cross-References

- `connection-enrichment` skill (the dedicated wrapper for this)
- `campaign-launch` (enrich the cohort before drafting)
- `cold-outreach`, `reply-handling` (consume enrichment for Precision Flattery)
- `references/sell-by-chat-methodology.md` (Precision Flattery is the playbook anchor)
- `references/tools-registry.md` (enrich_connections, get_enrichment API details)
