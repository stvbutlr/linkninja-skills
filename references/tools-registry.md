# LinkNinja MCP Tools Registry

All 30 tools available through the LinkNinja MCP (server v3.5+). Each tool is called by name with the parameters listed below.

Categories:

- [Context & Setup](#context--setup) — 7 tools
- [Search & Read](#search--read) — 7 tools
- [Conversation Updates](#conversation-updates) — 3 tools
- [Templates](#templates) — 4 tools
- [Enrichment](#enrichment) — 1 tool
- [Async Jobs](#async-jobs) — 8 tools

IDs use two prefixes: `conv_xxx` for conversations (from `search_conversations`) and `conn_xxx` for connections (from `list_connections` / `scan_connections`). Most write tools accept either.

---

## Context & Setup

### `get_context`

Load the user's full sales context. **Always call this first.**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | — |

**Returns:** `additional_context` (ICP), `positioning_context`, `voice_profile`, `personal_story`, `summary_instructions`, stage definitions with criteria, tag definitions, freshness thresholds (`ghost_after_days`, `cold_after_days`), pipeline stats snapshot, classification prompt, AI execution rules (`ai_execution.job_protocols`).

### `update_context`

Update the user's sales context. Merge update — only specified fields change.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `additional_context` | string | No | ICP / Customer Avatar |
| `positioning_context` | string | No | Positioning & Offer |
| `voice_profile` | string | No | How the user communicates |
| `personal_story` | string | No | Personal story & background |
| `summary_instructions` | string | No | How AI summarizes conversations |
| `stages` | array | No | Stage criteria updates (merge by `key`) |

Each stage in `stages` array: `{key, entrance_criteria, exit_criteria, ai_context}`.

### `list_stages`

Get current stage definitions.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | — |

**Returns:** Array of stages with `key`, `name`, `description`, `entrance_criteria`, `exit_criteria`, `ai_context`, `color`. The 7 default stages are `opening`, `chatting`, `qualified`, `discovery`, `closing`, `won`, `lost`.

> Tip: `get_context` already includes stages — only call this for the standalone definition.

### `list_tags`

Get current tag definitions and tags currently in use.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | — |

**Returns:** `tag_definitions` (all defined tags) and `tags_in_use` (tags assigned to ≥1 conversation/connection).

> Tip: included in `get_context`.

### `get_prompt`

Get the AI classification prompt rendered from current ICP, positioning, stage criteria, and tag definitions.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | — |

### `get_draft_prompt`

Get a server-rendered draft prompt for a single conversation. **Call this before drafting individually.** Includes voice-profile enforcement, conversation intelligence signals, and all relevant context.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | `conv_xxx` or `conn_xxx` |
| `instructions` | string | No | Optional additional instructions for this draft |
| `reply_intent` | enum | No | `nurture` / `qualify` / `advance` |

For batch drafting, the equivalent prompt is embedded in each `get_job_chunk` item — don't loop `get_draft_prompt`.

### `ninja_setup`

Guided onboarding flow for first-time users. Walks through ICP, positioning, voice profile, and stage configuration.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | — |

---

## Search & Read

### `search_conversations`

Search conversations with rich filters. Returns metadata only (no transcripts) — paginated.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Text search across names, summaries |
| `stage` | string | No | Filter by stage key |
| `tags` | array | No | Filter by tag keys |
| `my_turn` | boolean | No | Filter by whose turn it is |
| `freshness` | string | No | `fresh`, `cold`, `you_ghosted`, `they_ghosted`, `stale` |
| `since` | string | No | ISO date — conversations active since |
| `before` | string | No | ISO date — conversations active before |
| `company` | string | No | Filter by current company (requires enrichment) |
| `location` | string | No | Filter by location (requires enrichment) |
| `title` | string | No | Filter by current job title (requires enrichment) |
| `compact` | boolean | No | Return IDs only (use for batch prep) |
| `include_archived` | boolean | No | Include archived conversations |
| `limit` | integer | No | Max results (default 50) |
| `page` | integer | No | Page number for pagination |

**Returns:** Array of conversations. If `has_more` is `true`, fetch next page.

### `get_conversation`

Get a single conversation with full message transcript and conversation intelligence fields.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | `conv_xxx` or `conn_xxx` |

**Returns:** Full conversation including messages, stage, tags, summary, ai_notes, draft_message, reminder, archive status, last_message_at, plus intelligence fields (`warmth_level`, `warmth_score`, `sentiment`, `conversation_health`, `engagement_signals`, `interest_signals`, `objection_signals`, `momentum_signals`).

### `export_conversations`

Bulk export conversations with optional transcripts. Paginated, supports CSV.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stage` | string | No | Filter by stage |
| `tags` | array | No | Filter by tags |
| `since` | string | No | ISO date |
| `before` | string | No | ISO date |
| `my_turn` | boolean | No | Filter by turn |
| `freshness` | string | No | Filter by freshness state |
| `include_messages` | boolean | No | Include full transcripts (default true) |
| `unclassified_only` | boolean | No | Only unclassified conversations |
| `format` | string | No | `json` (default) or `csv` (returns download URL valid 1 hour) |
| `limit` | integer | No | Max per page (default 200) |
| `page` | integer | No | Page number |

### `get_stats`

Pipeline overview with counts by stage, turn status, and freshness.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | — |

**Returns:** Conversation counts per stage, `my_turn` vs `their_turn` per stage, freshness breakdown, opening_breakdown.

### `list_connections`

List LinkedIn connections with optional filters. Paginated.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Search by name or headline |
| `company` | string | No | Filter by company (requires enrichment) |
| `location` | string | No | Filter by location (requires enrichment) |
| `title` | string | No | Filter by job title (requires enrichment) |
| `tags` | array | No | Filter by tags |
| `message_status` | enum | No | `all` / `no_messages` / `has_messages` |
| `detailed` | boolean | No | Include LinkedIn URLs |
| `limit` | integer | No | Max results (default 200) |
| `page` | integer | No | Page number |

### `scan_connections`

Server-side ICP scan across the connection graph (up to 30k connections). Returns up to 500 matches.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `headline_keywords` | array | No | Keywords to match in headline (OR logic) |
| `headline_exclude` | array | No | Keywords to exclude from headline |
| `company` | string | No | Filter by current company (requires enrichment) |
| `location` | string | No | Filter by location (requires enrichment) |
| `title` | string | No | Filter by current job title (requires enrichment) |
| `tags` | array | No | Filter by existing tags |
| `connected_after` | string | No | ISO date — only connections added after |
| `has_conversation` | boolean | No | `true` = only messaged, `false` = only un-messaged |
| `limit` | integer | No | Max results (max 500) |

### `get_enrichment`

Read enriched profile data for one or many contacts (Sales Navigator). Batch — accepts 1–100 ids per call. Optional section filtering.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ids` | array | Yes | `conv_xxx` or `conn_xxx`, 1–100 |
| `sections` | array | No | Whitelist sections to return |

**Sections:** `identity`, `experience`, `education`, `skills`, `certifications`, `projects`, `languages`, `recent_posts`, `volunteer`, `interests`, `groups`, `causes`, `contact`, `network`, `flags`, `throttled_sections`. Omit `sections` for full payload.

**Per-contact errors don't fail the batch.** Each result entry has `enriched=true/false` with reason.

---

## Conversation Updates

### `update_conversation`

Update a single conversation or connection. Stage, tags, notes, reminder, draft, archive.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | `conv_xxx` or `conn_xxx` |
| `stage` | string | No | Pipeline stage key (one of the 7 stages) |
| `tags` | array | No | Set tags (replaces ALL existing) |
| `add_tags` | array | No | Tags to add (merge) |
| `remove_tags` | array | No | Tags to remove |
| `notes` | string | No | User notes |
| `ai_notes` | string | No | AI analysis notes — always include |
| `summary` | string | No | AI summary |
| `draft_message` | string | No | Saved draft for user review |
| `reminder` | string | No | ISO datetime, date, natural language, or `"clear"` |
| `archive` | object | No | `{archived: true/false, reason: "..."}` |

**Archive reasons:** `not_a_fit`, `ghosted`, `later`, `client`, `competitor`, `networking`, `personal`. **`not_a_fit` is an archive reason, NOT a stage.**

**Drafting:** Call `get_draft_prompt(id)` first and follow its instructions. Don't draft without it.

### `bulk_update`

Bulk update conversations. Two modes:

- **Filter mode** — provide `filter` + an action; the server applies the action to ALL matches in one call.
- **Updates mode** — provide `updates` array with per-conversation changes.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `preview_only` | boolean | No | With filter: returns count + sample, no changes |
| `filter` | object | No | Filter criteria (same shape as `search_conversations`) |
| `add_tags` | array | No | (filter mode action) tags to add |
| `remove_tags` | array | No | (filter mode action) tags to remove |
| `stage` | string | No | (filter mode action) set stage |
| `archive` | object | No | (filter mode action) archive/unarchive |
| `reminder` | string | No | (filter mode action) set reminder |
| `notes` | string | No | (filter mode action) set user notes |
| `ai_notes` | string | No | (filter mode action) set AI notes |
| `summary` | string | No | (filter mode action) set summary |
| `updates` | array | No | (updates mode) per-conversation `{id, stage, tags, add_tags, remove_tags, notes, ai_notes, summary, reminder, archive, draft_message}` |

**Filter mode does NOT support `draft_message`** — drafts vary per-conversation, use updates mode for those.

**Don't paginate `search_conversations` first if you intend to apply uniformly** — call `bulk_update` directly with the same filter (controller's own guidance). Use `preview_only: true` to verify scope before mutating.

### `tag_connections`

Add or remove tags on connections. Two modes (filter or `connection_ids`).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `preview_only` | boolean | No | With filter: returns count + sample |
| `connection_ids` | array | No | Specific connection integer IDs |
| `filter` | object | No | Filter criteria (`headline_keywords`, `headline_exclude`, `has_conversation`, `connected_after`, `list_tags`, `query`, `company`, `location`, `title`) |
| `add_tags` | array | No | Tags to add |
| `remove_tags` | array | No | Tags to remove |

---

## Templates

Templates are reusable message skeletons with `{{variable}}` placeholders. Available placeholders: `first_name`, `last_name`, `full_name`, `headline`. Six categories: `opening`, `follow_up`, `closing`, `nurture`, `objection`, `value_add`.

Two distinct guidance fields:
- `agent_guidance` — suggestive ("Open with a Pattern Interrupt"). AI can flex.
- `guardrails` — hard constraints ("Must include the deck URL. No meeting asks."). Non-negotiable.

Optional advancement rules:
- `advance_tag_to` — after send, advance contact to this tag
- `advance_stage_to` — after send, advance conversation to this stage

Templates are *captured at job creation* — deleting doesn't affect in-flight jobs.

### `list_templates`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tag` | string | No | Filter by linked tag key |
| `category` | enum | No | Filter by category |
| `stage` | string | No | Filter by pipeline stage |
| `query` | string | No | Search name or content |

### `create_template`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Template name |
| `content` | string | Yes | Message content with `{{variable}}` placeholders |
| `category` | enum | Yes | `opening`/`follow_up`/`closing`/`nurture`/`objection`/`value_add` |
| `stage` | string | No | Pipeline stage (null = all stages) |
| `tag_key` | string | No | Link to a tag for outbound sequences |
| `agent_guidance` | string | No | Personalisation guidance (suggestive) |
| `guardrails` | string | No | Hard constraints (non-negotiable) |
| `advance_tag_to` | string | No | Tag to advance to after send |
| `advance_stage_to` | string | No | Stage to advance to after send |

### `update_template`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Template ID |
| `name`, `content`, `category`, `stage`, `tag_key`, `agent_guidance`, `guardrails`, `advance_tag_to`, `advance_stage_to` | various | No | Set `""` to clear a string field |

### `delete_template`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Template ID. Cannot be undone. |

---

## Enrichment

### `enrich_connections`

Async Sales Navigator enrichment job. Captures: company, title, location, summary, work experience, education, skills, certifications, projects, languages, contact info, recent posts (5), volunteer, interests, groups, causes, network counts, account flags.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `connection_ids` | array | No | Specific integer IDs |
| `filter` | object | No | Filter criteria (`headline_keywords`, `headline_exclude`, `has_conversation`, `connected_after`, `list_tags`, `is_enriched`, `company`, `location`, `title`) |
| `preview_only` | boolean | No | Return count + sample, no enrichment |
| `force` | boolean | No | Re-enrich already-enriched (always pair with `re_enrich_after_days`) |
| `re_enrich_after_days` | integer | No | Only re-enrich connections older than N days. Defaults 30 with `force=true`. |
| `limit` | integer | No | Max to enrich (default 100, max 500, capped by daily quota) |

**Async.** Returns `job_id` immediately, not the data. Read enriched data via `get_enrichment(ids: [...])` after the job completes.

**Timing.** ~6 sec/connection. 100 connections = ~10 min, 200 = ~20 min. For >50, return `job_id` to the user with an ETA — don't block.

**Daily quota.** 200 enrichments/day shared with lead-list enrichment. Check `quota` in every response.

**Default skips already-enriched** — no quota cost on duplicates.

---

## Async Jobs

> **Agent-only documentation.** The parameters in this section — `job_id`, `chunk_token`, `lease_token`, polling intervals, claim/submit mechanics — are for agent-to-server protocol calls. **Never surface these in user-facing reports or skill output.** Translate progress to user terms ("drafting in batches…", "X of Y ready", "wrapping up the batch"). The `confidentiality` block returned by `get_context` is authoritative: do not discuss internal job mechanics with users.

LinkNinja's async jobs follow this pattern (`ai_execution.job_protocols` in `get_context` is authoritative):

- `start_*` returns a `job_id` immediately. Do NOT consider the job done at this point.
- Poll `get_job_status(job_id)` until status is ready (recommended 2-second interval).
- For draft and classify jobs, loop `get_job_chunk → submit_job_results(claim_next=true)` until completion.
- After the job completes, call `get_job_results` to fetch and share the saved payload.
- "Do not tell the user the job is done until `submit_job_results` has succeeded."
- "If the user says continue/resume/keep going, call `continue_active_job` first."
- "Do not start a new batch job if an active one already exists."

### `start_batch_classify`

Start a server-side AI classification job. Up to 500 conversations per job.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `conversation_ids` | array | No | Specific IDs (mutually exclusive with `filter`) |
| `filter` | object | No | Filter criteria |
| `unclassified_only` | boolean | No | Only process unclassified |
| `limit` | integer | No | Max conversations (max 500) |
| `instructions` | string | No | Custom classifier instructions |
| `eager_first_chunk` | boolean | No | Inline first chunk if job is small |

### `start_batch_draft`

Start a draft-reply job. **Does NOT write drafts by itself** — creates items for the AI to draft. Drafted in chunks via `get_job_chunk` / `submit_job_results`.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `conversation_ids` | array | No | Specific IDs (mutually exclusive with `filter`) |
| `filter` | object | No | Filter criteria |
| `outputs` | array | No | What to generate. Default: `["draft_message"]` (only supported value) |
| `template_id` | integer | No | Template to use as drafting skeleton |
| `draft_mode` | enum | No | `locked` (server renders variables only, no AI) / `guided` (default — AI personalises within structure) / `flexible` (template as loose reference) |
| `reply_intent` | enum | No | `nurture` / `qualify` / `advance` |
| `instructions` | string | No | Additional drafting instructions |
| `limit` | integer | No | Max conversations (default 500, max 1000) |
| `eager_first_chunk` | boolean | No | Inline first chunk if job is small |

**Constraints (verbatim from controller):**
- "Drafts can only be `applied` or `failed` (skipped not allowed)."
- "Every item must be drafted."
- "`reply_mode` is required" — `reply` (direct response) or `follow_up` (re-engaging silence).

### `get_job_status`

Check progress of any background job.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | Yes | From `start_batch_*`, `bulk_update`, `tag_connections`, or `enrich_connections` |

**Returns:** status, progress counts (`matched`, `processed`, `applied`, `failed`, `low_confidence`), `recommended_poll_seconds`, `next_tool` hint.

### `get_job_results`

View per-conversation results from a completed AI job. For draft jobs, returns saved drafts ready to share with the user. Paginated.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | Yes | The job ID |
| `page` | integer | No | Page number (default 1) |
| `limit` | integer | No | Per page (default 50, max 200) |
| `status` | string | No | Filter by `applied`, `skipped`, `failed` |

### `get_job_chunk`

Claim the next batch of items from an in-progress job. Returns transcripts plus an instruction bundle. For draft jobs, each item includes a `draft_prompt` with saved AI context.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | Yes | Job ID |
| `limit` | integer | No | Items per chunk (default 10, max 25) |

**Returns:** `chunk_token` (required for submit), `shared_bundle` (voice_profile, personal_story, positioning_context, additional_context, stages, tags), `items[]`, `remaining_after_this_chunk`.

> Return every claimed item via `submit_job_results` before claiming more.

### `submit_job_results`

Submit processed results for a claimed chunk. Every claimed item must be returned with a decision.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | Yes | Job ID |
| `chunk_token` | string | Yes | From `get_job_chunk` response |
| `items` | array | Yes | Per-item results |
| `claim_next` | boolean | No | Claim next chunk inline (reduces round trips) |
| `next_chunk_limit` | integer | No | Chunk size for auto-claimed next chunk |
| `include_shared_bundle` | boolean | No | Include shared bundle in auto-claimed chunk (default true; required for classify) |

Each item: `{id, status, ...}` where status is one of:

- `applied` — completed successfully
  - For classify: `stage`, `confidence` (`high`/`medium`/`low`), `reasoning`, `summary`, `ai_notes`, `list_tags`
  - For draft: `draft_message`, `reply_mode` (`reply`/`follow_up`), optional `context_used`
- `skipped` — only allowed for classify; provide `reason`
- `failed` — provide `error`

### `continue_active_job`

Resume or check the active job. Use this when the user says "continue", "resume", or "keep going" — and to check whether a job is already in flight before starting a new one.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | No | Specific job; omit to use the most recent active |
| `type` | enum | No | `draft_reply` / `classify` |
| `max_items` | integer | No | Cap items processed in this resumption |
| `resume_key` | string | No | Resume from a specific point |
| `amend_instructions` | string | No | Adjust instructions on resume |
| `include_shared_bundle` | boolean | No | Include shared bundle |

### `cancel_job`

Terminate a background job.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | Yes | Job ID |

---

## Quick Reference: Common Patterns

| Goal | Pattern |
|------|---------|
| Find conversations | `search_conversations(filter)` — paginate via `has_more` |
| Read one conversation | `get_conversation(id)` |
| Draft one reply | `get_draft_prompt(id)` → `update_conversation(id, draft_message, ai_notes)` |
| Draft many replies | `start_batch_draft(filter, template_id?, draft_mode?, reply_intent?)` → `continue_active_job` → `submit_job_results(claim_next=true)` loop → `get_job_results` |
| Classify many | `start_batch_classify(filter)` → loop chunks → `get_job_results` |
| Tag many connections | `tag_connections(filter, add_tags, preview_only=true)` then re-call without preview |
| Update many conversations uniformly | `bulk_update(filter, action, preview_only=true)` then re-call without preview |
| Enrich a segment for personalisation | `enrich_connections(filter)` → poll → `get_enrichment(ids, sections=["recent_posts","experience"])` |
| Build a sequence | `create_template` → `start_batch_draft(template_id)` |

## Confidentiality

Don't surface job IDs, chunk tokens, lease mechanics, or protocol internals to users. Describe progress in user terms ("drafting in batches…", "X of Y drafts ready"). Internal architecture is out of scope per the `confidentiality` block in `get_context`.
