---
name: template-library
description: >
  Build and manage a library of reusable message templates with placeholders,
  agent guidance, hard guardrails, and advancement rules. Templates power
  start_batch_draft sequences and outbound multi-touch campaigns. Use when the
  user says "create a template", "manage my templates", "edit template",
  "delete template", "browse templates", "save this as a template", "build
  my outreach library", "set up my Day 3 follow-up template", or names a
  template by its tag like "GR3 template". Maps each template to a playbook
  framework via agent_guidance. Related: sequence-runner for using templates
  with start_batch_draft, batch-drafting for ad-hoc drafting, campaign-launch
  for sequenced outreach setup.
metadata:
  version: "1.0"
  author: linkninja
---

# Template Library

Templates are reusable message skeletons stored on the LinkNinja server. They turn one-off message ideas into repeatable sequences, encode playbook frameworks via `agent_guidance`, and lock down non-negotiables via `guardrails`. Used with `start_batch_draft(template_id)` to drive sequenced outreach at scale.

## Before Starting

1. Run `get_context()` to load the user's sales context.
2. Determine the action:

| User says | Mode |
|-----------|------|
| "Browse my templates" / "what templates do I have" | List + summarise |
| "Create a template for [purpose]" / "save this as a template" | Create |
| "Update / edit [template name]" / "fix the [tag] template" | Update |
| "Delete [template name]" | Delete (confirm first) |
| "What template should I use for [situation]?" | List filtered + recommend |

## Template Anatomy

Every template has these fields (full spec in `references/template-modes.md`):

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Display name (e.g., "GR3. Online Opinion Article") |
| `content` | Yes | Message body with `{{placeholder}}` variables |
| `category` | Yes | `opening` / `follow_up` / `closing` / `nurture` / `objection` / `value_add` |
| `stage` | No | Pipeline stage this fits (null = all stages) |
| `tag_key` | No | Link to a tag for outbound sequences (e.g., `gr3`) |
| `agent_guidance` | No | Suggestive guidance — AI can flex |
| `guardrails` | No | Hard constraints — non-negotiable |
| `advance_tag_to` | No | Tag the contact gets after send |
| `advance_stage_to` | No | Stage the conversation moves to after send |

**Placeholders supported (only these four):** `{{first_name}}`, `{{last_name}}`, `{{full_name}}`, `{{headline}}`. Anything else is left literal.

### `agent_guidance` vs `guardrails`

Two different fields. Don't conflate:

- **`agent_guidance`** is suggestive — the AI can flex if context calls for it. Use this to embed playbook frameworks ("Open with a Pattern Interrupt referencing their most recent post"; "Use the A–B Method — surface their A, point at their B").
- **`guardrails`** is non-negotiable. Use this for legal/brand/process rules ("Must include the deck URL"; "No meeting ask"; "Maximum 3 sentences"; "Do not mention pricing").

## Workflow

### Mode 1: List + Summarise

```
list_templates()
```

Or filtered by category, stage, or tag:

```
list_templates(category="follow_up", tag="gr3")
```

Present results as a table with name, category, tag, advancement. Note which templates have `agent_guidance` / `guardrails` set vs not.

### Mode 2: Create

Walk the user through the fields one at a time:

1. **Purpose / category.** "What's this template for? Opening? Follow-up? Objection response? Closing?"
2. **Name.** Suggest a tag-prefixed name if it's part of a sequence (e.g., "GR3. Day 7 Value Drop").
3. **Content.** Help the user write the message body. Reference the playbook frameworks for the category:
   - `opening` → Three Opening Rules + Precision Flattery + Pattern Interrupt
   - `follow_up` → Day 1/3/7/extending value-add
   - `closing` → Micro-commitments + 3-element invite
   - `objection` → Acknowledge → Ask Context → Reframe
   - `nurture` → Long-tail value, no ask
   - `value_add` → Preloaded Value (specific / ungated / actionable / tied to next conversation)
4. **Placeholders.** Confirm which of `{{first_name}} / {{last_name}} / {{full_name}} / {{headline}}` are needed.
5. **Stage / tag link.** Link to a stage if the template only applies in one stage; link to a tag if it's part of an outbound sequence (e.g., `tag_key: "gr3"`).
6. **`agent_guidance`.** Encode the playbook framework as suggestive guidance.
7. **`guardrails`.** Capture non-negotiables — what must always be in the message, what must never be.
8. **Advancement rules.** If this is part of a sequence, set `advance_tag_to` (next step's tag) and/or `advance_stage_to`.

Then save:

```
create_template(
  name: "GR3. Day 7 Value Drop",
  content: "Hey {{first_name}} — saw [specific recent post topic] and it lined up with what we were chatting about last week. Quick framework I sketched — happy to share if useful.",
  category: "follow_up",
  tag_key: "gr3",
  agent_guidance: "Open with a Pattern Interrupt referencing their most recent post (pull from get_enrichment). Tie the value to what they shared in the chatting stage. Apply Preloaded Value rules — specific, ungated, actionable, tied to next conversation.",
  guardrails: "Maximum 3 sentences. Do not ask for a meeting. Do not mention pricing. Must offer something specific and ungated.",
  advance_tag_to: "gr4",
  advance_stage_to: "qualified"
)
```

Confirm the created template back to the user.

### Mode 3: Update

Show the current template, ask what to change, then call `update_template(id, ...)` with only the fields being changed. To clear a string field, set it to `""`.

```
update_template(
  id: 14,
  agent_guidance: "Updated guidance: open with a one-line acknowledgement of their stated A, then offer the framework as a step toward their B."
)
```

### Mode 4: Delete

Confirm twice — deletion is permanent. Note that **active draft jobs that reference this template are not affected** — template content is captured at job creation. Editing/deleting a template only affects future jobs.

```
delete_template(id: 14)
```

## Sequence Patterns

The most powerful use of templates is sequenced outbound. Build a chain of templates linked via `tag_key` + `advance_tag_to`:

| Step | Name | tag_key | advance_tag_to | Day | reply_intent |
|------|------|---------|-----------------|-----|--------------|
| 1 | "GR1. Initial Outreach" | `gr1` | `gr2` | 1 | nurture |
| 2 | "GR2. Day 3 Value-Add" | `gr2` | `gr3` | 3 | nurture |
| 3 | "GR3. Day 7 Different Angle" | `gr3` | `gr4` | 7 | qualify |
| 4 | "GR4. Day 14 Door-Open" | `gr4` | `gr_dormant` | 14 | nurture |

Each template's `agent_guidance` can encode a different framework. Pair with **sequence-runner** to actually execute the sequence over time.

## Tag-Linked Templates: Workflow

When templates are linked to tags (`tag_key: "gr3"`), the natural pattern for the user's sequence is:

1. Tag the cohort with the starting tag (e.g., `gr1`) via `tag_connections` or `bulk_update`.
2. Run **sequence-runner** with the appropriate template per touch.
3. After each send, the contact's tag advances per `advance_tag_to`.
4. The next batch finds contacts at the new tag and applies the next template.

## Guidelines

- One template per concept. Don't make 5 variants of the same opener — pick one and use `draft_mode: "guided"` to let AI personalise.
- Encode frameworks in `agent_guidance`, not in `content`. The content is the spine; guidance shapes the personalisation.
- Use `guardrails` sparingly — only for genuinely non-negotiable constraints. Over-constraining defeats personalisation.
- For sequences, name templates with a step prefix (`GR1.`, `GR2.`, `GR3.`) so the order is obvious in `list_templates` results.
- Use `advance_tag_to` chains, not `advance_stage_to`, for outbound sequences — the conversation stage is set by the prospect's reply, not by your follow-up.
- When deleting, remember that in-flight `start_batch_draft` jobs aren't affected. Don't expect immediate cleanup.
- Help users start small — one opener template + one follow-up template, then iterate based on what works.

## Related Skills

- **sequence-runner** — Executes a multi-touch sequence using these templates with `start_batch_draft`
- **batch-drafting** — Ad-hoc drafting (no template required); pair with templates for sequenced outreach
- **campaign-launch** — Sequenced campaign that uses the template chain
- **cold-outreach** — Frameworks templates should encode for openers (Three Opening Rules, Precision Flattery)
- **reply-handling** — Frameworks for follow-up category templates (A–B Method, Question Sequence)
- **objection-handling** — Frameworks for objection category templates (Acknowledge → Ask Context → Reframe)
- **call-booking** — Frameworks for closing category templates (Micro-commitments)
