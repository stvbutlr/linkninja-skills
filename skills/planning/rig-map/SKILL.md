---
name: rig-map
description: >
  Map the user's dream sell-by-chat work into two artifacts: (A) a rig-ready
  Campaign / Routine / Monitor brief that drops directly into Session 2's
  architect skills, and (B) immediate Claude Code wins they can ship today
  without the rig (CLAUDE.md additions, slash commands to build with
  /skill-creator, hooks, plan-mode patterns, file structure). Use when the user
  says "map my rig", "plan my campaign for the rig", "design my sell-by-chat",
  "rig map", "homework before session 2", "what should I optimise in claude
  code today", or "translate my workflow to claude code". Pulls LinkNinja MCP
  context, runs a comprehensive interview about the user's dream campaign +
  routines + monitors, then writes the full plan to .claude/plans/rig-map.md.
metadata:
  version: "1.0"
  author: linkninja
---

# Rig Map

Two outputs from one interview.

**Section A ... Rig-ready brief.** Maps the user's dream sell-by-chat into Campaign / Routine / Monitor briefs that match `brief-template.md` exactly. Drops straight into `/campaign-architect`, `/routine-architect`, `/monitor-architect` in Session 2.

**Section B ... Immediate wins.** Recommends CLAUDE.md additions, slash commands to ship with `/skill-creator`, hooks to set up, plan-mode patterns, and file structure the user can implement today without the rig.

## Before Starting

1. Run `get_context()` to load voice profile, ICP, positioning, personal story.
2. Run `list_stages()`, `list_templates()`, `list_tags()` to load the existing rig.
3. Check critical context completeness:

| Field | Required | If Empty |
|-------|----------|----------|
| Voice profile | Required | Stop. "I need your voice profile loaded. Set it at app.linkninja.co/ai-settings before we map." |
| ICP / additional_context | Required | Stop. "I need your ICP. Set at app.linkninja.co/ai-settings." |
| Positioning | Required | Stop. "I need your positioning. Set at app.linkninja.co/ai-settings." |
| Pipeline stages | Recommended | Proceed. Flag the gap in Section B. |
| Templates | Recommended | Proceed. Recommend missing ones in Section B. |
| Tags | Recommended | Proceed. Recommend additions in Section B. |

If LinkNinja MCP is not connected: ask the user to describe voice, ICP, positioning, pipeline, and existing templates in 4 to 6 short sentences. Move on with whatever they give you. Note the gap in Section B.

Echo what you loaded back to the user before starting Phase 1.

## Phase 1 ... Dream Campaign Interview

Ask ONE question at a time. WAIT for each answer. Don't move on until the user has answered. If their answer is short, follow up with one targeted clarifier ("which audience exactly?", "what would the opener actually say?").

### Q1 ... Campaign name + intent

"What's the campaign you want to map? Give it a name and one sentence on what it's for. And tell me which mode it is: **evergreen** (always running), **time-limited** (workshop, launch, limited offer with start and end dates), **A/B test** (two variants you want to compare), or **split test** (sub-cohorts with different sequences)."

### Q2 ... Audience

"Who's IN this campaign? Be specific. Pipeline stages, tags, headline keywords, enrichment fields (title, company, location), prior conversation history, recency. And who's OUT ... anyone explicitly excluded (do-not-contact, already in another campaign, wrong fit)?"

### Q3 ... The full sequence (start to finish)

"Walk me through the full sell-by-chat sequence. For each touchpoint:

- **What's the milestone?** Pick the closest motion: opening / value drop / case study / discovery question / objection handle / nurture / booking ask / closing ask. Multiple per step is fine.
- **What does the actual message look like?** Paste a sample. Or describe the angle, the hook, the ask.
- **How does the AI bridge personalise it?** What context from the previous turn or the prospect's profile does the next message need to reference?
- **When does it fire?** Day offset (e.g. day 3 after enrollment), or fit-based (only fires when the previous reply quality crosses a bar), or schedule-based (specific cron).
- **What advances them?** What tag or pipeline stage changes when this fires?
- **What happens if no reply?** Follow-up template, AI bridge with re-personalisation, or exit?

Take all the time you need. I'll echo each step back before we move on."

After each step the user describes, summarise it in one sentence ("Step 1: opener referencing their last post, no pitch, advances tag to `campaign:slug:step-1-drafted`. If no reply in 4 days, an AI bridge fires.") and ask "right?" before moving to the next step.

### Q4 ... Reply handling

"When someone replies, how should the rig handle each type? Tell me what you'd say (template name, sample message, or angle) for each:

- **Clarifying** ... they ask you a question
- **Qualifying** ... buying signals (asking about price, timeline, fit)
- **Deflecting** ... soft pushback ("not sure, tell me more")
- **Deferring** ... "not now / Q2 / later"
- **Objecting** ... hard objection (price / timing / fit / authority)
- **Not interested** ... explicit no
- **Booking signal** ... they accepted the CTA, asked for time
- **Off-topic** ... banter, tangent, no buying signal

You can say 'use my existing template X' or 'AI bridge with this angle'."

### Q5 ... The win

"What event marks the campaign as won for this contact? A booked call, a sale, a tag added, a pipeline stage transition? What's the goal tag the rig should write when it fires?"

### Q6 ... Lifecycle + delivery

"Start and end dates if time-limited (else evergreen). Where do notifications land ... Telegram, dashboard, email, all of them? Throughput cap (max enrollments per day, max touches per day per contact)?"

## Phase 2 ... Routines Interview

"Outside the campaign itself, what tasks do you do RECURRING ... every day, every weekday morning, every Monday, every Friday close-of-week? List them."

For each routine the user names, capture:

- **Schedule** ... cron pattern (or describe in plain English; you'll convert)
- **Steps** ... what the daemon does each fire, in plain English
- **Allowed tools** ... read-only routine? draft routine? full pipeline-update routine?
- **Output target** ... drafts to LinkNinja queue, summary to Telegram, file write, etc.
- **Caps** ... max drafts per run, max runs per day

Common routine candidates to prompt for if the user goes blank:
- Morning pipeline brief
- Weekly self-improvement routine (review what worked / didn't)
- End-of-week archival of cold conversations
- Daily enrichment of newly-tagged leads

## Phase 3 ... Monitors Interview

"What events would you want the rig to react to in real time, the moment they happen?"

For each monitor, capture:

- **Trigger event** ... reply lands, comment on a post, tag added, new lead from a webhook, stage change, goal tag hit
- **Condition that matters** ... sender is in a specific pipeline stage, message contains a keyword, sender is on a watch-list
- **Action** ... notify only / draft a reply / tag and route / classify and enroll into another campaign
- **Cooldown** ... max one fire per contact per hour / day
- **Delivery channel** ... Telegram, dashboard, email

Common monitor candidates to prompt for if the user goes blank:
- "Inbound priority responder" ... when a hot lead replies, ping immediately
- "Goal monitor" ... when the campaign goal tag fires, log + notify
- "Re-engagement watcher" ... when a contact crosses days_since_last_touch > 30, surface them

## Phase 4 ... Map to Rig Brief (Section A output)

Take everything from Phases 1 to 3. Map to the canonical rig grammar. **DO NOT invent categories or intents.** If the user described a motion that's not in the canonical 6 categories or 8 intents, express it via `agent_guidance` + branch conditions + bridges. The rig is neutral infrastructure ... the user owns the domain via their voice profile and brief.

### Canonical primitives reference

**6 categories** (the only allowed values for `template_pool.category`):

| Slug | Universal intent | Notes |
|---|---|---|
| `opening` | initiate | First DM |
| `value_add` | teach | Free, useful, no ask. Carries social_proof variant via agent_guidance. |
| `objection` | handle_resistance | Price / timing / fit / authority via variant_hint |
| `follow_up` | acknowledge / reopen | Carries reengage as branch (days_since_last_touch > 30) |
| `nurture` | teach | Long-cycle, low-pressure |
| `closing` | convert | Final asks, AND booking ask (with booking-specific agent_guidance) |

**8 universal intents** (every step MUST declare one):
`initiate / acknowledge / discover / teach / handle_resistance / convert / reopen / close_out`

**10 condition primitives**:
- Deterministic (8): `has_replied_since_tag`, `is_first_message_in_arc`, `days_since_arc_started`, `days_since_last_touch`, `turns_in_current_arc`, `pipeline_stage`, `has_tag` / `not_has_tag`, `tagged_do_not_contact`
- AI-judged (1): `reply_intent_class` (8 labels: clarifying / qualifying / deflecting / deferring / objecting / not_interested / interested_in_booking / off_topic)
- Hybrid (1): `discovery_sufficient`

**6 action primitives**:
`draft_template { category, agent_guidance }` ... `draft_bridge { intent, agent_guidance }` ... `wait` ... `exit_with_outcome` ... `tag_apply` / `tag_remove` ... `escalate_to_user`

### Sell-by-chat motions expressed in grammar (NOT new categories)

| Motion | Express as |
|---|---|
| social_proof / case study | `category: value_add` + `agent_guidance: "lead with [matching-situation customer] story, specific result, no pitch"` |
| reengage / win-back | `category: follow_up` + branch on `days_since_last_touch > 30` + `agent_guidance: "fresh-angle reopener, acknowledge gap"` |
| qualification / discovery | `draft_bridge { intent: discover }` OR `category: value_add` + `agent_guidance: "A→B method, one open question"` |
| booking / CTA | `category: closing` + `agent_guidance: "propose two specific times this week, Calendly fallback"` |
| disqualify_exit | `draft_bridge { intent: close_out, agent_guidance: "graceful no-fit, door open, no pitch"}` |

### Output format

Render Section A as three blocks per `brief-template.md`:

#### A1 ... Campaign brief (YAML)

Render every load-bearing field with a one-sentence `# Why:` rationale so the user can sanity-check. Use the user's actual answers, not invented defaults. Reference the existing canonical primitives. Match the structure shown in `brief-template.md` Campaign section.

#### A2 ... Routine briefs (one per identified routine, YAML)

Match `brief-template.md` Routine section. Validate `allowed_tools[]` against `ROUTINE_TOOL_DENY_LIST` (no `routine.create`, `routine.update`, `routine.list`, `routine.get`). Use safe defaults for caps if the user didn't specify (max_drafts_per_run: 15, max_runs_per_day: 3).

#### A3 ... Monitor briefs (one per identified monitor, YAML)

Match `brief-template.md` Monitor section. Each monitor's `action_spec.kind` must match `action_type`. Verify any template / tag / stage references against the loaded MCP context.

For each brief, prefix with: "**Paste this into plan mode in Session 2, then invoke `/campaign-architect` (or routine / monitor).**"

## Phase 5 ... Generate Immediate Wins (Section B output)

Based on Phases 1 to 3, recommend specific actions the user can take in their CURRENT Claude Code setup TODAY. These are wins they get this week, before the rig.

### B1 ... CLAUDE.md additions

Write the EXACT block they should append to their project CLAUDE.md (or `~/.claude/CLAUDE.md` if global makes sense). Pull from the loaded context:

- **Voice rules** (3 to 5 lines pulled from their voice profile)
- **ICP context** (one paragraph naming who they sell to, derived from `additional_context`)
- **Positioning** (one paragraph naming what they offer, derived from `positioning_context`)
- **Hard nevers** (e.g. "never use 'we' in copy if positioning is solo", "never push for a call before X turns of discovery", "never reply to a deferring lead with a pitch")
- **Reply tone** (matched to existing reply patterns from their templates)

Format it as a copy-pasteable markdown block.

### B2 ... Skills to ship via /skill-creator

Recommend 3 to 5 specific slash commands the user should build TODAY using Anthropic's `skill-creator` plugin. These should cover the routines from Phase 2 ... but as MANUAL slash commands they can run today, not autonomous routines (which need the rig).

For each:

- **Skill name** (e.g. `/draft-reply`, `/triage-inbox`, `/research-prospect`)
- **One-paragraph SKILL.md description** they can paste into `/skill-creator` (the description IS the trigger ... be specific about WHEN to fire)
- **LinkNinja MCP tools** the skill will call
- **Expected output**

Reference: <https://github.com/anthropics/skills/tree/main/skills/skill-creator> for the official skill-creator workflow.

### B3 ... Hooks to set up

Recommend 1 to 3 specific Claude Code hooks based on what you saw:

- **PreToolUse hook for safety** ... block dangerous Bash patterns (`rm -rf`, force-push), require confirmation on bulk MCP writes (e.g. `bulk_update`, `tag_connections` over N contacts).
- **PostToolUse hook for audit** ... log every MCP write to `~/.claude/audit.log` with timestamp and tool input.
- **Stop hook for notifications** ... Telegram ping when a long-running task (multi-step routine) completes.

Provide the exact `settings.json` snippets they paste in.

### B4 ... Plan mode usage

Recommend WHEN to use plan mode (`Shift+Tab`) for their workflow:

- Designing campaigns or re-architecting their sequences (read-only thinking, no writes)
- Bulk pipeline operations (re-tagging, re-classifying contacts ... think first, write second)
- Debugging "why did the rig do X" (read tags, history, transcript ... no actions)
- Anything that would touch many contacts at once

### B5 ... File structure

Recommend a `.claude/` folder layout for their LinkNinja workspace:

```
.claude/
  CLAUDE.md               # The block from B1
  commands/               # The slash commands from B2
    draft-reply.md
    triage-inbox.md
    research-prospect.md
  plans/                  # Where rig-map output lands
    rig-map.md            # This file
  context/                # Reference docs Claude can pull when drafting
    objections.md         # Common objections and the user's preferred handles
    case-studies.md       # Customer stories with matching situations
    sell-by-chat.md       # The sell-by-chat playbook reference
  audit.log               # PostToolUse hook output (B3)
```

### B6 ... LinkNinja MCP workflow patterns

Surface 2 to 3 specific MCP tool chains that will save the user time today, derived from their actual workflow:

- For triage: `search_conversations` (filter by stage) → `get_context` → `get_draft_prompt` → save as draft
- For enrichment: `list_connections` (filter by recency) → `enrich_connections` → `tag_connections`
- For self-review: `search_conversations` (last 7 days, won outcomes) → analyse what won → write voice_learning memory chunks via `memory.write`

Tailor to what the user actually described, not these generic examples.

## Phase 6 ... Save the output

Write Section A + Section B to:

```
.claude/plans/rig-map.md
```

Format:

```markdown
# Rig Map ... <campaign name>

Created: <today's date>

---

## Section A: Rig-ready brief (paste into Session 2)

### A1 - Campaign brief
<YAML block>

### A2 - Routine briefs
<YAML blocks>

### A3 - Monitor briefs
<YAML blocks>

---

## Section B: Immediate wins (implement today)

### B1 - CLAUDE.md additions
<markdown block>

### B2 - Skills to build
<list with skill-creator descriptions>

### B3 - Hooks
<settings.json snippets>

### B4 - Plan mode usage
<list>

### B5 - File structure
<tree>

### B6 - MCP workflow patterns
<list>
```

Don't ask permission to write the file. When done, tell the user:

"Saved at `.claude/plans/rig-map.md`. **Section A** is your Session 2 brief ... paste into plan mode and invoke the architect skills. **Section B** is your immediate-action plan ... implement now for wins this week."

## Guidelines

- **Don't invent categories or intents.** Map every milestone to one of the 6 existing categories and one of the 8 intents. If the user describes a motion that doesn't fit, express it via `agent_guidance` + branch conditions + bridges.
- **Don't inject opinions.** No "industry best practice is X." No "you should send Y per day." No "the standard cooldown is Z hours." The rig is neutral infrastructure ... echo the user's strategy back, don't editorialise.
- **Use the user's voice in agent_guidance.** Pull from their voice profile when writing each step's `agent_guidance`. Don't invent rules they didn't endorse.
- **Echo + confirm.** After each phase, summarise what you heard before moving on. Catch misunderstandings early, not at the end.
- **Don't skip Section B.** That's the immediate value the user gets THIS week. Without it, the skill is just homework prep. With it, they get wins before Session 2.
- **Voice-lint the output.** No em-dashes (use ellipsis). No banned phrases (`crushing it`, `game-changer`, `circle back`, `touch base`, `Hope this finds you well`, `I'd love to connect`, `unlock`, `leverage` as noun, `synergy`).

## Related Skills

- `dm-writing` ... for individual message crafting (use after Section B is implemented)
- `full-morning-triage` ... compound morning workflow (likely becomes a routine in Section A)
- `template-library` ... for managing template inventory (Phase 1 Q3 references this)
- `pipeline-cleanup` ... for archiving (likely becomes a routine candidate)
- `cold-rescue` ... for re-engagement (often surfaces as a monitor candidate in Phase 3)
