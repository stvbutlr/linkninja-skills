# LinkNinja Skills

Expert sales pipeline skills for the [LinkNinja MCP](https://linkninja.com). Give your AI agent situational expertise for managing LinkedIn DM conversations, prospecting, campaigns, and pipeline analytics.

Works with **any MCP-compatible agent**: Claude Code, Claude.ai, OpenAI Codex, ChatGPT, Gemini, Groq, Manus, and others.

## What Are Skills?

Skills are structured markdown files that teach AI agents how to handle specific workflows. Instead of figuring out which tools to call and in what order, the agent follows expert-level guidance for each situation — from morning pipeline triage to launching a targeted outreach campaign.

Each skill defines:
- **When to activate** (trigger phrases)
- **What context to check first** (ICP, voice profile, etc.)
- **Exact tool chains** with parameters
- **Decision rules** for different scenarios
- **When to hand off** to related skills

## Prerequisites

- LinkNinja account with MCP API key or OAuth credentials
- An MCP-compatible AI agent (see Installation below)
- LinkNinja MCP connected to your agent

## Installation

### Claude Code (Plugin)

```bash
# Add from marketplace
/plugin marketplace add stvbutlr/linkninja-skills
```

### Claude Code (Manual)

```bash
# Clone into your project
git clone https://github.com/stvbutlr/linkninja-skills.git .skills/linkninja
```

Add to your project's `CLAUDE.md`:
```
Skills are in .skills/linkninja/skills/ — load the relevant SKILL.md when the user's request matches a skill's trigger phrases.
```

### OpenAI Codex

```bash
# Clone the repo
git clone https://github.com/stvbutlr/linkninja-skills.git

# Add AGENTS.md to your Codex configuration
# Skills in skills/ are automatically discovered via AGENTS.md
```

### Any Other Agent

The skills are plain markdown files. Clone the repo and point your agent at the `skills/` directory and `AGENTS.md` for instructions. Any agent that can read files and call MCP tools will work.

```bash
git clone https://github.com/stvbutlr/linkninja-skills.git
```

## Skills Catalog (19 Skills)

### Setup (`skills/setup/`)

| Skill | Description | Triggers |
|-------|-------------|----------|
| [icp-definition](skills/setup/icp-definition/) | Interview-style ICP setup with network validation | "set up my ICP", "define my ideal client" |
| [voice-profile-setup](skills/setup/voice-profile-setup/) | Analyze your messages and build a voice profile for AI drafts | "set up my voice", "match my writing style" |
| [stage-configuration](skills/setup/stage-configuration/) | Customize pipeline stage criteria for your sales process | "customize my stages", "fix my classification" |

### Connections (`skills/connections/`)

| Skill | Description | Triggers |
|-------|-------------|----------|
| [prospect-scan](skills/connections/prospect-scan/) | Find ICP matches in your connections — supports subsegment campaigns | "find prospects", "scan my connections" |
| [campaign-launch](skills/connections/campaign-launch/) | Plan and execute structured outreach campaigns with scoring | "launch a campaign", "run an outreach campaign" |
| [smart-tagging](skills/connections/smart-tagging/) | Tag conversations and connections by ICP fit, buying signals, and situational patterns | "tag my conversations", "who are my decision makers" |

### Conversations (`skills/conversations/`)

| Skill | Description | Triggers |
|-------|-------------|----------|
| [full-morning-triage](skills/conversations/full-morning-triage/) | Automated daily pipeline review — drafts replies, rescues cold leads, classifies new conversations | "run my morning", "triage my pipeline", "what should I do today" |
| [dm-writing](skills/conversations/dm-writing/) | Situation-specific DM crafting for any conversation stage | "help me write a DM", "draft a message", "what should I say" |
| [batch-drafting](skills/conversations/batch-drafting/) | Draft personalized messages for multiple conversations at once | "batch draft", "draft follow-ups for everyone" |
| [cold-rescue](skills/conversations/cold-rescue/) | Revive cold and ghosted conversations with value-add re-engagement | "rescue cold conversations", "re-engage" |
| [pipeline-cleanup](skills/conversations/pipeline-cleanup/) | Archive stale conversations, classify backlogs, clean the pipeline | "clean up my pipeline", "pipeline hygiene" |
| [stage-review](skills/conversations/stage-review/) | Audit stage accuracy — reclassify conversations that are in the wrong stage | "review my stages", "audit my classifications" |
| [conversation-summarizer](skills/conversations/conversation-summarizer/) | Generate or refresh AI summaries and notes across conversations in batch | "summarize my conversations", "update summaries" |
| [reminder-engine](skills/conversations/reminder-engine/) | Bulk reminder management — follow-up cadences, overdue audits, reminder cleanup | "set reminders", "what's overdue", "bulk reminders" |

### Analysis (`skills/analysis/`)

| Skill | Description | Triggers |
|-------|-------------|----------|
| [pipeline-health-check](skills/analysis/pipeline-health-check/) | Diagnose pipeline bottlenecks, conversion rates, and warning signs | "how is my pipeline", "pipeline health" |
| [reply-rate-analysis](skills/analysis/reply-rate-analysis/) | Analyze opening-to-reply conversion rates and message patterns | "analyze my reply rate", "which openers worked" |
| [stage-conversion-analysis](skills/analysis/stage-conversion-analysis/) | Stage-by-stage conversion funnel — find where deals stall and why | "stage conversion analysis", "where am I losing deals" |
| [won-deal-analysis](skills/analysis/won-deal-analysis/) | Find patterns in won deals, refine ICP from success data | "analyze won deals", "why am I winning" |
| [lost-deal-analysis](skills/analysis/lost-deal-analysis/) | Analyze loss patterns, drop-off stages, and common objections | "analyze lost deals", "why am I losing" |

## How Skills Work Together

```
┌─── Setup ─────────────────────────────────────────────────────┐
│                                                                │
│   icp-definition  ← foundation: set up first                  │
│       ├── voice-profile-setup                                  │
│       └── stage-configuration                                  │
│                                                                │
└───────────────────────────┬────────────────────────────────────┘
                            │
┌─── Connections ───────────▼────────────────────────────────────┐
│                                                                │
│   prospect-scan ──→ smart-tagging ──→ campaign-launch          │
│                                                                │
└───────────────────────────┬────────────────────────────────────┘
                            │
┌─── Conversations ─────────▼────────────────────────────────────┐
│                                                                │
│   full-morning-triage     dm-writing        pipeline-cleanup   │
│   cold-rescue             batch-drafting    stage-review       │
│   conversation-summarizer                   reminder-engine    │
│                                                                │
└───────────────────────────┬────────────────────────────────────┘
                            │
┌─── Analysis ──────────────▼────────────────────────────────────┐
│                                                                │
│   pipeline-health-check        reply-rate-analysis             │
│   stage-conversion-analysis                                    │
│   won-deal-analysis ──→ Feeds back to ICP                      │
│   lost-deal-analysis                                           │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

**Typical user journey:**
1. `icp-definition` → configure your targeting
2. `voice-profile-setup` → so AI drafts sound like you
3. `prospect-scan` → find people to message
4. `smart-tagging` → tag by ICP fit and buying signals
5. `campaign-launch` → structured outreach push
6. `full-morning-triage` → daily pipeline management
7. `stage-review` → audit classification accuracy
8. `reply-rate-analysis` → learn what messages work
9. `won-deal-analysis` + `lost-deal-analysis` → learn from results → refine ICP

## Context Prerequisites

Skills check for required context before running. If your ICP or other settings are empty, the skill will help you configure them first — either through the conversation or by directing you to the LinkNinja dashboard settings.

| Context Field | What It Stores | Required By |
|--------------|---------------|-------------|
| ICP (`additional_context`) | Who you sell to | Most skills |
| Positioning (`positioning_context`) | What you sell/offer | campaign-launch |
| Voice Profile (`voice_profile`) | How you communicate | dm-writing, batch-drafting (recommended) |
| Personal Story (`personal_story`) | Your background | Enhances personalization |

## Shared References

The `references/` directory contains documentation shared across skills:

| File | Content |
|------|---------|
| [tools-registry.md](references/tools-registry.md) | All 17 LinkNinja MCP tools with full parameter docs |
| [pipeline-stages.md](references/pipeline-stages.md) | 8 pipeline stages with signals and trust levels |
| [signal-mapping.md](references/signal-mapping.md) | Signal-to-stage and signal-to-tag classification tables |
| [dm-principles.md](references/dm-principles.md) | 8 universal DM writing rules |
| [voice-profile-template.md](references/voice-profile-template.md) | 12-dimension voice analysis framework |

## Validation

```bash
./validate-skills.sh
```

Checks frontmatter format, naming conventions, line counts, and required sections.

## License

FSL-1.1-MIT — Free to use with LinkNinja MCP. Converts to MIT after 2 years. See [LICENSE](LICENSE).
