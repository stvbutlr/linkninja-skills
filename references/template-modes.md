# Template Modes & Anatomy

Templates are reusable message skeletons stored on the LinkNinja server. Used with `start_batch_draft(template_id, draft_mode)` to drive sequenced or repeatable outreach.

## Anatomy of a Template

Every template has these fields:

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Display name (e.g., "GR3. Online Opinion Article") |
| `content` | Yes | Message body with `{{placeholder}}` variables |
| `category` | Yes | One of: `opening`, `follow_up`, `closing`, `nurture`, `objection`, `value_add` |
| `stage` | No | Pipeline stage this template fits (null = all stages) |
| `tag_key` | No | Link to a tag for outbound sequences |
| `agent_guidance` | No | Suggestive guidance — AI can flex |
| `guardrails` | No | Hard constraints — non-negotiable |
| `advance_tag_to` | No | Tag the contact gets after send |
| `advance_stage_to` | No | Stage the conversation moves to after send |

## Placeholders

Only four placeholders are supported. Anything else is left as-is in the rendered message.

| Placeholder | Source |
|-------------|--------|
| `{{first_name}}` | Contact's first name |
| `{{last_name}}` | Contact's last name |
| `{{full_name}}` | Contact's full name |
| `{{headline}}` | LinkedIn headline |

## Categories

The six categories map roughly to the playbook funnel:

| Category | Use For | Example Skills |
|----------|---------|---------------|
| `opening` | First message — Three Opening Rules apply | cold-outreach |
| `follow_up` | Reply or re-engagement — A–B Method, Question Sequence | reply-handling, cold-rescue |
| `closing` | Booking calls, sending offers — Micro-commitments | call-booking |
| `nurture` | Long-term relationship building, no ask | cold-rescue, reminder-engine |
| `objection` | Acknowledge → Ask Context → Reframe | objection-handling |
| `value_add` | Preloaded Value drops between touches | cold-rescue, campaign-launch |

## Draft Modes

Set via `start_batch_draft(draft_mode)`. Default: `guided`.

### `locked`
- Server renders `{{variables}}` only.
- No AI personalisation.
- 100% match to template content.
- Use for: known-working sequences, compliance-sensitive outreach, very large batches.

### `guided` (default)
- AI personalises opening / closing within the template structure.
- Template body remains the spine.
- Best balance of personalisation and consistency.
- Use for: most sequences.

### `flexible`
- Template is a loose reference.
- AI writes freely, drawing on the template's intent and `agent_guidance`.
- Use for: highly varied audiences where rigid structure feels off.

## `agent_guidance` vs `guardrails`

Two distinct fields, two distinct purposes.

### `agent_guidance` (suggestive)
The AI can flex if the conversation context calls for it.

> "Open with a Pattern Interrupt referencing their most recent post."
> "Tie the value statement to their stated industry."
> "Match Australian-isms if the user's voice profile uses them."

### `guardrails` (hard constraints)
The AI MUST follow these. Non-negotiable.

> "Must include the deck URL."
> "Do not ask for a meeting in this message."
> "Do not mention pricing."
> "Maximum 3 sentences."

If a guardrail conflicts with naturalness, the guardrail wins.

## Advancement Rules

`advance_tag_to` and `advance_stage_to` define what happens to the contact *after the user sends the drafted message* (handled by the user's send flow, not by drafting itself).

Common pattern — outbound sequences:

| Step | Template | `tag_key` | `advance_tag_to` |
|------|----------|-----------|------------------|
| 1 | "GR1. Initial outreach" | `gr1` | `gr2` |
| 2 | "GR2. Day 3 follow-up" | `gr2` | `gr3` |
| 3 | "GR3. Day 7 value drop" | `gr3` | `gr4` |
| 4 | "GR4. Final door-open" | `gr4` | `gr_dormant` |

Combined with the playbook's Day 1 / 3 / 7 / extending cadence, this gives a fully sequenced outbound program.

## Quick Reference Patterns

| Goal | Pattern |
|------|---------|
| Build a new template | `create_template(name, content, category, agent_guidance, guardrails)` |
| Tweak an existing template | `update_template(id, ...)` — set string fields to `""` to clear |
| Find templates for a step | `list_templates(tag="gr3")` or `list_templates(category="opening")` |
| Run a sequenced batch | `start_batch_draft(filter, template_id, draft_mode="guided")` |
| Send template-locked at scale | `start_batch_draft(filter, template_id, draft_mode="locked")` |

## Caveat: Templates Captured at Job Creation

When `start_batch_draft` is called with a `template_id`, the template content + guardrails + guidance are captured into the job at creation. **Deleting the template afterwards does not affect in-flight jobs.** Edit with caution while jobs are live.

## Cross-References

- `template-library` skill (template CRUD operations)
- `sequence-runner` skill (uses templates with batch drafts)
- `campaign-launch` (templates power campaign opener cohorts)
- `references/sell-by-chat-methodology.md` (the frameworks `agent_guidance` should embed)
- `references/tools-registry.md` (template tool API details)
