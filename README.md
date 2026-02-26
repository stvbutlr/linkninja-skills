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

## Skills Catalog (12 Skills)

### Daily Operations

| Skill | Description | Triggers |
|-------|-------------|----------|
| [full-morning-triage](skills/full-morning-triage/) | Automated daily pipeline review — drafts replies, rescues cold leads, classifies new conversations | "run my morning", "triage my pipeline", "what should I do today" |
| [dm-writing](skills/dm-writing/) | Situation-specific DM crafting for any conversation stage | "help me write a DM", "draft a message", "what should I say" |
| [batch-drafting](skills/batch-drafting/) | Draft personalized messages for multiple conversations at once | "batch draft", "draft follow-ups for everyone" |
| [pipeline-health-check](skills/pipeline-health-check/) | Diagnose pipeline bottlenecks, conversion rates, and warning signs | "how is my pipeline", "where am I losing deals" |

### Setup & Configuration

| Skill | Description | Triggers |
|-------|-------------|----------|
| [icp-definition](skills/icp-definition/) | Interview-style ICP setup with network validation | "set up my ICP", "define my ideal client" |
| [voice-profile-setup](skills/voice-profile-setup/) | Analyze your messages and build a voice profile for AI drafts | "set up my voice", "match my writing style" |
| [stage-configuration](skills/stage-configuration/) | Customize pipeline stage criteria for your sales process | "customize my stages", "fix my classification" |

### Growth & Outreach

| Skill | Description | Triggers |
|-------|-------------|----------|
| [prospect-scan](skills/prospect-scan/) | Find ICP matches in your connections — supports subsegment campaigns | "find prospects", "scan my connections" |
| [campaign-launch](skills/campaign-launch/) | Plan and execute structured outreach campaigns with scoring | "launch a campaign", "run an outreach campaign" |
| [cold-rescue](skills/cold-rescue/) | Revive cold and ghosted conversations with value-add re-engagement | "rescue cold conversations", "re-engage" |

### Analysis & Optimization

| Skill | Description | Triggers |
|-------|-------------|----------|
| [won-deal-analysis](skills/won-deal-analysis/) | Find patterns in won deals, compare with losses, refine ICP from data | "analyze won deals", "why am I winning" |
| [pipeline-cleanup](skills/pipeline-cleanup/) | Archive stale conversations, classify backlogs, clean the pipeline | "clean up my pipeline", "pipeline hygiene" |

## How Skills Work Together

```
                    ┌─────────────────┐
                    │  icp-definition  │ ← Foundation: set up first
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
    ┌─────────▼──────┐ ┌────▼─────┐ ┌──────▼──────────┐
    │ prospect-scan  │ │voice-    │ │stage-           │
    │                │ │profile-  │ │configuration    │
    └────────┬───────┘ │setup     │ └─────────────────┘
             │         └────┬─────┘
    ┌────────▼───────┐      │
    │campaign-launch │      │
    └────────┬───────┘      │
             │              │
    ┌────────▼──────────────▼───────────────────┐
    │           Daily Operations                 │
    │  ┌──────────────────┐  ┌───────────────┐  │
    │  │full-morning-     │  │ dm-writing    │  │
    │  │triage            │  │               │  │
    │  └────────┬─────────┘  └───────┬───────┘  │
    │           │                    │           │
    │  ┌────────▼─────────┐  ┌──────▼────────┐  │
    │  │ cold-rescue      │  │batch-drafting │  │
    │  └──────────────────┘  └───────────────┘  │
    └───────────────────────────────────────────┘
             │
    ┌────────▼──────────────────────────────────┐
    │           Analysis                         │
    │  ┌──────────────────┐  ┌───────────────┐  │
    │  │pipeline-health-  │  │won-deal-      │  │
    │  │check             │  │analysis       │──┼─→ Feeds back
    │  └──────────────────┘  └───────────────┘  │   to ICP
    │  ┌──────────────────┐                     │
    │  │pipeline-cleanup  │                     │
    │  └──────────────────┘                     │
    └───────────────────────────────────────────┘
```

**Typical user journey:**
1. `icp-definition` → configure your targeting
2. `voice-profile-setup` → so AI drafts sound like you
3. `prospect-scan` → find people to message
4. `campaign-launch` → structured outreach push
5. `full-morning-triage` → daily pipeline management
6. `won-deal-analysis` → learn from results → refine ICP

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

Apache 2.0 — see [LICENSE](LICENSE).
