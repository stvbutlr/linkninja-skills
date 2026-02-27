# LinkNinja Skills

## What This Is

A collection of AI agent skills for LinkNinja MCP users. Each skill in `skills/` provides expert-level guidance for a specific LinkedIn sales pipeline workflow. Skills are activated by natural language triggers and chain LinkNinja's 17 MCP tools into compound workflows.

## Structure

- `skills/` — 23 skills organized into 4 categories
  - `setup/` — ICP, voice profile, stage configuration
  - `connections/` — Prospect scanning, campaigns, smart tagging
  - `conversations/` — Triage, DM writing, batch drafting, cleanup, reminders
  - `analysis/` — Pipeline health, conversion rates, won/lost deal patterns
- `references/` — Shared reference docs loaded on demand by any skill

## Rules

- Every SKILL.md must be under 500 lines. Move verbose content to `references/`
- Tool calls must be inline with workflow steps, not in a separate section
- Every skill starts with `get_context()` to load the user's sales context
- If required context is empty (ICP, positioning, etc.), stop and help the user configure it first
- Never send messages — always save as drafts via `draft_message` parameter
- Always include `ai_notes` with drafts and classifications to explain reasoning
- Skills reference each other via "Related Skills" sections for clear scope boundaries
- Validate with `./validate-skills.sh` before committing

## LinkNinja MCP Tools (17)

| Tool | Purpose |
|------|---------|
| `get_context` | Load user's full sales context (ICP, voice_profile, positioning_context, personal_story, stages, tags, stats) |
| `update_context` | Update ICP, voice_profile, positioning_context, personal_story, summary_instructions, stage criteria |
| `pipeline_stats` | Pipeline counts by stage, freshness breakdown, turn status |
| `stages` | Stage definitions with entrance/exit criteria |
| `tags` | Tag definitions |
| `prompt` | Classification prompt |
| `search` | Search conversations (filters: stage, my_turn, freshness, since, tags, compact) |
| `fetch` | Get full conversation with message transcript |
| `export` | Bulk export conversations with transcripts (paginated, max 500/page) |
| `classify` | Update classification for a conversation (deprecated — use update_conversation) |
| `update_conversation` | Update stage, tags, notes, draft_message, reminder, archive |
| `bulk_classify` | Bulk update conversations — stage, tags, summary, ai_notes, reminder, archive (max 100, NO draft_message) |
| `connections` | List LinkedIn connections (query, detailed, message_status) |
| `scan_connections` | Server-side headline keyword scan across all connections (up to 30k) |
| `tag_connections` | Add/remove tags on connections |
| `start_batch_classify` | Start server-side batch classification job (max 500) |
| `job_status` | Check batch job progress |

## User Context Fields

Skills should reference all 4 profile context fields returned by `get_context()`:

| Field | What it stores |
|-------|---------------|
| `additional_context` | ICP / Customer Avatar — who the user sells to |
| `positioning_context` | Positioning & Offer — what the user sells |
| `voice_profile` | How the user communicates — tone, style, patterns |
| `personal_story` | Personal story & background — credibility, experience |

## Validation

```bash
./validate-skills.sh
```

Checks: frontmatter format, name matches directory, description length, SKILL.md under 500 lines, required sections present.
