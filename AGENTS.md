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

## Shared References

`references/` at repo root contains cross-cutting documentation:

- `tools-registry.md` — All 17 LinkNinja MCP tools with full parameter docs
- `pipeline-stages.md` — 8 pipeline stages with signals, trust levels, criteria
- `signal-mapping.md` — Signal-to-stage and signal-to-tag classification tables
- `dm-principles.md` — Universal DM writing rules
- `voice-profile-template.md` — 12-dimension voice analysis template

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
- **Batch-first.** Use `bulk_classify` for multiple updates (stage, tags, summary, ai_notes, reminder, archive). Note: `bulk_classify` does NOT support `draft_message` — use `update_conversation` individually for drafts.
- **Respect limits.** `bulk_classify` max 100 per call. `start_batch_classify` max 500 per job.
- **Handle pagination.** If `has_more` is true on `search` or `export`, fetch the next page.
- **Use compact mode.** Pass `compact=true` on `search` when you only need IDs.

## Cross-Referencing

Skills reference each other in "Related Skills" sections. When a user's request crosses skill boundaries, suggest the appropriate related skill rather than attempting both.

## Development

- Branch naming: `feature/skill-name` or `fix/skill-name-description`
- Validate before committing: `./validate-skills.sh`
- Keep SKILL.md under 500 lines — move detailed content to `references/`
