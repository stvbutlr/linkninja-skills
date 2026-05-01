# LinkNinja Skills

## What This Is

A collection of AI agent skills for LinkNinja MCP users. Each skill in `skills/` provides expert-level guidance for a specific LinkedIn sales pipeline workflow. Skills are activated by natural language triggers and chain LinkNinja's 30 MCP tools into compound workflows.

## Methodology

Every DM skill embeds the [Sell By Chat Playbook](https://library.sevenfigurecreators.com/3/the-sell-by-chat-playbook) by Steve Butler.

> **Stop selling. Start serving.** Relationship-first, transaction-second.

Named frameworks the skills use directly: **Three Opening Rules**, **Precision Flattery**, **Pattern Interrupt**, **Preloaded Value**, **A–B Method**, **Question Sequence**, **Acknowledge → Ask Context → Reframe**, **Micro-commitments**, **Day 1 / 3 / 7 / extending follow-up cadence** (80% of sales close after the 5th touchpoint), **Ten Core Voice Rules**. Full doctrine in `references/sell-by-chat-methodology.md`.

## Structure

- `skills/` — 28 skills organized into 4 categories
  - `setup/` — ICP, voice profile, stage configuration, onboarding
  - `connections/` — Prospect scanning, enrichment, lead research, campaigns, smart tagging
  - `conversations/` — Triage, DM writing, batch drafting, templates, sequences, cleanup, reminders
  - `analysis/` — Pipeline health, conversion rates, won/lost deal patterns
- `references/` — Shared reference docs loaded on demand by any skill
- `.claude/skills/steve-voice/` — Voice rules for Steve-authored user-facing copy in this repo
- `POWER-UPS.md` — Optional Claude Code config (cron, hooks, SDK, subagents, MCPs, model selection) per skill

**Sales Navigator note:** `connection-enrichment`, `lead-research`, and the enrichment branches inside several other skills require an active Sales Navigator connection. Without Sales Nav, those skills fall back to headline-only personalisation.

## Rules

- Every SKILL.md must be under 500 lines. Move verbose content to `references/`
- Tool calls must be inline with workflow steps, not in a separate section
- Every skill starts with `get_context()` to load the user's sales context
- If required context is empty (ICP, positioning, etc.), stop and help the user configure it first
- Never send messages — always save as drafts via `draft_message` parameter
- Always include `ai_notes` with drafts and classifications to explain reasoning
- For single drafts, call `get_draft_prompt(id)` first; for batch drafts use `start_batch_draft`
- Skills reference each other via "Related Skills" sections for clear scope boundaries
- Validate with `./validate-skills.sh` before committing

## LinkNinja MCP Tools (30)

### Context & Setup (7)

| Tool | Purpose |
|------|---------|
| `get_context` | Load user's full sales context (ICP, voice_profile, positioning_context, personal_story, stages, tags, stats, AI execution rules) |
| `update_context` | Update ICP, voice_profile, positioning_context, personal_story, summary_instructions, stage criteria |
| `list_stages` | Stage definitions with entrance/exit criteria |
| `list_tags` | Tag definitions and tags currently in use |
| `get_prompt` | AI classification prompt rendered from current context |
| `get_draft_prompt` | Server-rendered drafting prompt for one conversation (voice + intelligence) |
| `ninja_setup` | Guided onboarding for first-time users |

### Search & Read (7)

| Tool | Purpose |
|------|---------|
| `search_conversations` | Search conversations (filters: stage, tags, my_turn, freshness, since, before, company, location, title, compact) |
| `get_conversation` | Full conversation + message transcript + intelligence fields |
| `export_conversations` | Bulk export with transcripts (JSON/CSV, paginated) |
| `get_stats` | Pipeline counts by stage, freshness breakdown, turn status |
| `list_connections` | List LinkedIn connections with rich filters |
| `scan_connections` | Server-side ICP scan across the connection graph (up to 30k, returns 500) |
| `get_enrichment` | Read Sales Nav data for 1–100 contacts (sectionable) |

### Conversation Updates (3)

| Tool | Purpose |
|------|---------|
| `update_conversation` | Update one conversation — stage, tags, notes, draft, reminder, archive |
| `bulk_update` | Bulk update — filter mode (apply uniformly) or updates mode (per-conv) |
| `tag_connections` | Tag connections — filter mode or `connection_ids` |

### Templates (4)

| Tool | Purpose |
|------|---------|
| `list_templates` | Browse templates by tag, category, stage, query |
| `create_template` | Create reusable message skeleton with `{{placeholders}}` and advancement rules |
| `update_template` | Edit a template |
| `delete_template` | Remove a template |

### Enrichment (1)

| Tool | Purpose |
|------|---------|
| `enrich_connections` | Async Sales Nav enrichment job (~6s/connection, 200/day quota) |

### Async Jobs (8)

| Tool | Purpose |
|------|---------|
| `start_batch_classify` | Start AI classification job (max 500/job) |
| `start_batch_draft` | Start agent-driven draft job (max 1000/job) |
| `get_job_status` | Poll job progress |
| `get_job_results` | Read completed job's saved per-item payload |
| `get_job_chunk` | Claim next batch of items in classify/draft jobs |
| `submit_job_results` | Submit AI's per-item decisions for a claimed chunk |
| `continue_active_job` | Resume an in-flight job |
| `cancel_job` | Terminate a job |

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
