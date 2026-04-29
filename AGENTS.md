# Agent Instructions

You are working in a repository of Agent Skills for the LinkNinja MCP — a LinkedIn sales pipeline management tool that lets users manage DM conversations, scan connections, run campaigns, and analyze pipeline performance through AI.

## Repository Purpose

These skills give AI agents expert-level guidance when users are managing their LinkedIn DM pipeline through LinkNinja tools. Each skill is a structured workflow that chains multiple MCP tool calls together.

## Skill Format

Skills are organized into 4 categories under `skills/`: `setup/`, `connections/`, `conversations/`, `analysis/`. Each skill follows the Agent Skills Standard:

- YAML frontmatter: `name` (matches directory), `description` (1-1024 chars)
- SKILL.md under 500 lines
- Verbose content in `references/` subdirectory
- `name` field: lowercase a-z, numbers, hyphens, 1-64 chars, must match directory name

## Methodology

Every DM skill embeds the [Sell By Chat Playbook](https://library.sevenfigurecreators.com/3/the-sell-by-chat-playbook) by Steve Butler.

> **Stop selling. Start serving.** Relationship-first, transaction-second.

Skill prompts use these named frameworks directly: Three Opening Rules, Precision Flattery, Pattern Interrupt, Preloaded Value, A–B Method, Question Sequence, Acknowledge → Ask Context → Reframe, Micro-commitments, Day 1 / 3 / 7 / extending follow-up cadence (80% of sales close after the 5th touchpoint), Ten Core Voice Rules. Full doctrine in `references/sell-by-chat-methodology.md`.

## Shared References

`references/` at repo root contains cross-cutting documentation:

- `sell-by-chat-methodology.md` — The Sell By Chat playbook frameworks every DM skill embeds
- `tools-registry.md` — All 30 LinkNinja MCP tools with full parameter docs
- `pipeline-stages.md` — 7 pipeline stages with signals, trust levels, criteria
- `signal-mapping.md` — Signal-to-stage and signal-to-tag classification tables
- `voice-profile-template.md` — 12-dimension voice analysis template
- `conversation-intelligence.md` — `warmth_level`, `conversation_health`, `sentiment`, signal arrays
- `template-modes.md` — `locked` / `guided` / `flexible` draft modes; placeholders; advancement rules
- `enrichment-sections.md` — Sales Nav enrichment sections, quota, re-enrich semantics

Skills should reference these rather than duplicating the content.

## Context Prerequisites

Every skill starts with `get_context()`. If required context fields are empty, the skill must stop and help the user configure first — either inline or by directing them to the dashboard settings.

Users can configure context two ways:
1. **Through the AI agent:** "Tell me about your ideal client" → `update_context()`
2. **Through the dashboard:** Settings → AI Profile at `/pipeline-ai`

## Writing Standards

- Direct, instructional tone. Second person ("Run `pipeline_stats()`").
- Tables over prose. Decision rules over vague advice.
- Every workflow step names the specific tool + parameters.
- Concrete DM examples (good and bad) where applicable.
- No branded formulas, acronyms, or motivational fluff.
- Short paragraphs (2-4 sentences max).

## Behavioral Rules

- **Draft-only.** Never pretend to send messages. Always save as drafts via `draft_message`.
- **Always explain reasoning.** Include `ai_notes` with every draft and classification.
- **Single drafts**: call `get_draft_prompt(id)` first, then `update_conversation(id, draft_message, ai_notes)`. Follow the returned prompt exactly.
- **Batch drafts**: use `start_batch_draft` (the agent-driven flow) — `start_batch_draft → continue_active_job → submit_job_results(claim_next=true) loop → get_job_results`. Don't loop `update_conversation` for many drafts.
- **Bulk updates**: `bulk_update` filter mode applies a uniform action to all matches in one call (don't paginate `search_conversations` first). `bulk_update` updates mode handles per-conversation actions including `draft_message`.
- **Respect limits.** `start_batch_classify` max 500 per job. `start_batch_draft` max 1000 per job. `get_enrichment` max 100 ids per call.
- **Handle pagination.** If `has_more` is true on `search_conversations`, `export_conversations`, or `list_connections`, fetch the next page.
- **Use compact mode.** Pass `compact=true` on `search_conversations` when you only need IDs.
- **Don't surface protocol mechanics** (job IDs, chunk tokens, lease internals) in user-facing reports. Describe progress in user terms.

## Cross-Referencing

Skills reference each other in "Related Skills" sections. When a user's request crosses skill boundaries, suggest the appropriate related skill rather than attempting both.

## Development

- Branch naming: `feature/skill-name` or `fix/skill-name-description`
- Validate before committing: `./validate-skills.sh`
- Keep SKILL.md under 500 lines — move detailed content to `references/`
