# LinkNinja MCP Tools Registry

All 17 tools available through the LinkNinja MCP. Each tool is called by name with the parameters listed below.

## Context & Configuration

### `get_context`

Load the user's full sales context. Always call this first.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | Returns full context |

**Returns:** `additional_context` (ICP), `positioning_context`, `voice_profile`, `personal_story`, `summary_instructions`, stage definitions with criteria, tag definitions, freshness thresholds (`ghost_after_days`, `cold_after_days`), pipeline stats snapshot.

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

Each stage in `stages` array: `{key, entrance_criteria, exit_criteria, ai_context}`

### `stages`

Get current stage definitions.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | Returns all stage definitions |

**Returns:** Array of stages with `stage_key`, `display_name`, `description`, `entrance_criteria`, `exit_criteria`, `ai_context`, `color`, `sort_order`, `is_active`.

### `tags`

Get current tag definitions.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | Returns all tag definitions |

### `prompt`

Get the classification prompt currently in use.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | Returns rendered classification prompt |

---

## Pipeline & Search

### `pipeline_stats`

Pipeline overview with counts by stage, turn status, and freshness.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| *(none)* | — | — | Returns pipeline snapshot |

**Returns:** Conversation counts per stage, `my_turn` vs `their_turn` per stage, freshness breakdown (fresh, cold, you_ghosted, they_ghosted, stale).

### `search`

Search conversations with filters.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Text search across names, summaries |
| `stage` | string | No | Filter by stage key |
| `my_turn` | boolean | No | Filter by whose turn it is |
| `freshness` | string | No | `fresh`, `cold`, `you_ghosted`, `they_ghosted`, `stale` |
| `since` | string | No | ISO date — conversations active since |
| `tags` | array | No | Filter by tag keys |
| `compact` | boolean | No | Return IDs only (use for batch prep) |
| `include_archived` | boolean | No | Include archived conversations |
| `limit` | integer | No | Max results (default 50, max 200) |
| `page` | integer | No | Page number for pagination |

**Returns:** Array of conversations. If `has_more` is true, fetch next page.

### `fetch`

Get full conversation with message transcript.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Conversation ID (conv_* prefix) |

**Returns:** Full conversation with all messages, stage, tags, summary, ai_notes, draft_message, reminder, archive status, last_message_at, classification details.

### `export`

Bulk export conversations with optional transcripts. Paginated.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stage` | string | No | Filter by stage |
| `tags` | array | No | Filter by tags |
| `since` | string | No | ISO date |
| `before` | string | No | ISO date |
| `include_messages` | boolean | No | Include full message transcripts |
| `unclassified_only` | boolean | No | Only unclassified conversations |
| `include_archived` | boolean | No | Include archived |
| `format` | string | No | `json` (default) or `csv` (returns download URL) |
| `limit` | integer | No | Max per page (default 50, max 500) |
| `page` | integer | No | Page number |

**Returns:** Array of conversations. If `has_more` is true, fetch next page. CSV format returns a download URL valid for 1 hour.

---

## Conversation Updates

### `update_conversation`

Update a single conversation. All parameters optional except `id`.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Conversation ID |
| `stage` | string | No | Pipeline stage key |
| `tags` | array | No | Tag keys to set |
| `summary` | string | No | Conversation summary |
| `ai_notes` | string | No | AI reasoning notes (always include) |
| `draft_message` | string | No | Draft DM for user to review and send |
| `reminder` | string | No | ISO date, natural language, or `"clear"` |
| `archive` | object | No | `{archived: true/false, reason: "..."}` |

Archive reasons: `not_a_fit`, `ghosted`, `later`, `client`, `competitor`, `networking`, `personal`.

### `bulk_classify`

Bulk update multiple conversations in one call. Max 100 per call.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `updates` | array | Yes | Array of update objects (same fields as `update_conversation`) |

Each update object: `{id, stage, tags, summary, ai_notes, draft_message, reminder, archive}`. All fields optional except `id`.

### `classify` *(deprecated)*

Use `update_conversation` instead. Legacy tool for single classification updates.

---

## Connections

### `connections`

List LinkedIn connections with optional filters.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Search by name or headline |
| `detailed` | boolean | No | Include LinkedIn URLs |
| `message_status` | string | No | `has_messages`, `no_messages` |
| `tag` | string | No | Filter by connection tag |
| `limit` | integer | No | Max results |

### `scan_connections`

Server-side headline keyword scan across all connections (up to 30k).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `headline_keywords` | array | No | Include keywords (at least one must match) |
| `headline_exclude` | array | No | Exclude keywords (none can match) |
| `has_conversation` | boolean | No | Filter: has/hasn't been messaged |
| `tags` | array | No | Filter by connection tags |
| `connected_after` | string | No | ISO date — only recent connections |
| `limit` | integer | No | Max results (default 200, max 500) |

### `tag_connections`

Add or remove tags on connections.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `connection_ids` | array | Yes | Array of connection IDs |
| `add_tags` | array | No | Tags to add |
| `remove_tags` | array | No | Tags to remove |

---

## Batch Jobs

### `start_batch_classify`

Start server-side AI classification job. Max 500 conversations per job.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `unclassified_only` | boolean | No | Only process unclassified conversations |
| `stage` | string | No | Only process conversations in this stage |
| `limit` | integer | No | Max conversations to process (max 500) |
| `instructions` | string | No | Custom instructions for the classifier |

**Returns:** Job ID. Check progress with `job_status`.

### `job_status`

Check progress of a batch classification job.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | string | Yes | Job ID from `start_batch_classify` |

**Returns:** Status (`pending`, `processing`, `completed`, `failed`), progress percentage, results summary.

---

## Tool Usage by Skill

| Skill | Primary Tools | Secondary Tools |
|-------|--------------|-----------------|
| full-morning-triage | `pipeline_stats`, `search`, `fetch`, `bulk_classify` | `export`, `start_batch_classify` |
| dm-writing | `fetch`, `get_context`, `update_conversation` | — |
| batch-drafting | `search`, `fetch`, `bulk_classify` | `export` |
| pipeline-health-check | `pipeline_stats`, `export`, `search` | `get_context` |
| icp-definition | `get_context`, `update_context`, `scan_connections` | `start_batch_classify`, `job_status` |
| voice-profile-setup | `export`, `fetch`, `get_context`, `update_context` | — |
| stage-configuration | `stages`, `get_context`, `update_context` | — |
| prospect-scan | `get_context`, `scan_connections`, `tag_connections` | `connections` |
| campaign-launch | `scan_connections`, `tag_connections`, `bulk_classify` | `search`, `get_context`, `pipeline_stats` |
| cold-rescue | `search`, `fetch`, `bulk_classify` | — |
| won-deal-analysis | `export`, `pipeline_stats`, `get_context`, `update_context` | — |
| pipeline-cleanup | `search`, `export`, `bulk_classify` | `fetch`, `start_batch_classify`, `job_status` |
