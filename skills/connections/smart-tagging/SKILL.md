---
name: smart-tagging
description: >
  Systematically review and tag conversations and connections based on conversation
  content analysis — reading threads to detect buying signals, decision-maker
  authority, urgency, competitor mentions, referrals, and going-cold patterns. Use
  when the user says "tag my conversations", "apply tags", "who are my decision
  makers", "tag based on ICP", "find budget-confirmed conversations", "tag cleanup",
  "which conversations have buying signals", "identify decision makers in my
  pipeline", "tag audit", or "find urgent conversations". Different from prospect-scan
  which tags connections by headline keywords (surface-level); smart-tagging reads
  conversation threads for deep signal detection. Related: prospect-scan for
  headline-based connection tagging, pipeline-cleanup for archive decisions,
  full-morning-triage for daily pipeline processing, icp-definition for ICP setup.
metadata:
  version: "1.0"
  author: linkninja
---

# Smart Tagging

Read conversation threads to detect buying signals, authority, urgency, and behavioral patterns. Apply tags based on evidence found in the actual messages — not headlines or metadata. This is deep-level tagging that requires reading what people said.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Run `list_tags()` to load the current tag definitions

Check context:

| Field | Required | If Empty |
|-------|----------|----------|
| ICP (`additional_context`) | Recommended | Tagging still works. ICP helps identify `decision_maker` and `technical_buyer` signals more accurately. |
| Tags defined | Yes | If no tags are configured, help the user set them up first via `update_context`. Suggest the signal-to-tag table below as a starting point. |
| Stages defined | Recommended | Stage context helps prioritize which conversations to tag first. |

3. Determine the mode of operation (ask the user if unclear):

| User Says | Mode | Description |
|-----------|------|-------------|
| "Tag my conversations" / "tag audit" | Full pipeline tag audit | Review all active conversations |
| "Tag my qualified leads" / "tag [stage]" | Stage-specific tagging | Review one stage at a time |
| "Who are my decision makers?" / "find urgent" | Tag question | Answer a specific tag query |
| "Tag cleanup" / "fix my tags" | Tag cleanup | Find stale/incorrect tags, report distribution |

## Server-Side Intelligence Fields

The server now classifies conversations with rich intelligence fields you can read directly via `get_conversation` instead of inferring from raw transcripts. Use these as your first pass — full thread reading is the second pass for evidence-gathering. See `references/conversation-intelligence.md` for the full spec.

| Field | Values | Use For |
|-------|--------|---------|
| `warmth_level` | `hot` / `warm` / `neutral` / `cold` | Top priority slicing |
| `warmth_score` | 0–100 | Granular ranking within a level |
| `sentiment` | `positive` / `neutral` / `negative` | Tone of recent exchanges |
| `conversation_health` | `healthy` / `at_risk` / `dead` | Diagnostic — at_risk + cold = rescue candidate |
| `engagement_signals` | array | Pre-extracted engagement evidence |
| `interest_signals` | array | Pre-extracted interest evidence (maps to `qualified` stage signals) |
| `objection_signals` | array | Pre-extracted objections (route to **objection-handling**) |
| `momentum_signals` | array | Pre-extracted readiness-to-advance evidence |

When applying tags, cite the relevant intelligence field in `ai_notes` as evidence (e.g., "Tagged `urgent` based on `momentum_signals`: 'wants to start by Q1' and 'asked about earliest start date'").

## Signal-to-Tag Mapping

When reading a conversation thread, look for these signals and apply the corresponding tag:

| Signal in Thread | Tag | Evidence Required | Example |
|-----------------|-----|-------------------|---------|
| Confirms authority or holds C-suite/VP/Director title | `decision_maker` | They say "I make the call" or "I'll sign off" or hold senior title confirmed in conversation | "Yeah, this would be my decision to make." |
| Mentions budget, money, or pricing concretely | `budget_confirmed` | Explicit money mention — not just "what does it cost?" but confirmed availability | "We've set aside 10k for this quarter." |
| Time pressure stated | `urgent` | Specific deadline or urgency language | "Need this sorted by end of quarter." |
| Named a competitor or evaluating alternatives | `competitor_mentioned` | Named a specific competitor or said "we're comparing options" | "We're also looking at [Competitor]." |
| Replies getting shorter/slower, 2+ unanswered follow-ups | `going_cold` | Pattern visible in the thread — decreasing engagement | Last 3 messages from user, no reply. |
| Explicitly recommends to someone else | `referral` | Named a specific person or offered an introduction | "You should talk to [name], she handles this." |
| Internal champion, not the decision maker but pushing internally | `champion` | Volunteering to advocate internally | "I'll bring this to my boss next week." |
| Technical evaluator, asks detailed implementation questions | `technical_buyer` | Deep questions about how it works, integrations, specs | "How does your API handle rate limiting?" |

**Important:** A single conversation can have multiple tags. A `champion` might also be `urgent`. A `decision_maker` might also have `budget_confirmed`.

## Mode 1: Full Pipeline Tag Audit

Review all active conversations systematically. Recommended approach: work stage by stage to keep LLM context quality high.

**Step 1:** Get the pipeline overview:

```
get_stats()
```

**Step 2:** Process each stage in priority order:

| Priority | Stage | Why |
|----------|-------|-----|
| 1 | qualified | Highest value — tags directly inform next actions |
| 2 | discovery | Deep in pipeline — tag accuracy matters most here |
| 3 | closing | Near the finish — confirm decision_maker, budget_confirmed |
| 4 | chatting | Volume stage — look for signals to promote |
| 5 | opening | Lowest priority — limited signal data in short threads |

**Step 3:** For each stage, search and process:

```
search_conversations(stage="qualified", compact=true)
```

If `has_more` is true, paginate:

```
search_conversations(stage="qualified", compact=true, page=2)
```

**Step 4:** For each conversation, fetch the full thread:

```
get_conversation(id="<conversation_id>")
```

Read the entire message history. Check each message against the signal-to-tag mapping table. Note the specific evidence found.

**Step 5:** Apply tags in batch (per stage or when you have a batch ready):

```
bulk_update(updates=[
  {"id": "abc", "tags": ["decision_maker", "budget_confirmed"], "ai_notes": "VP Sales confirmed budget of 15k. Said 'I make this call.'"},
  {"id": "def", "tags": ["champion", "urgent"], "ai_notes": "Mid-level manager pushing internally. Said 'need this before Q2 planning.'"},
  {"id": "ghi", "tags": ["going_cold"], "ai_notes": "Last 3 messages unanswered over 2 weeks. Replies were getting shorter before silence."},
  {"id": "jkl", "tags": ["competitor_mentioned"], "ai_notes": "Mentioned evaluating [Competitor] alongside us."}
])
```

**Critical: tags in `bulk_update` REPLACE existing tags.** Always include the conversation's existing tags plus any new ones. If a conversation already has `["icp-match"]` and you want to add `decision_maker`, send `tags: ["icp-match", "decision_maker"]`.

**Step 6:** After processing all stages, deliver the tag audit report (see Report Template below).

## Mode 2: Stage-Specific Tagging

Same as Mode 1 but limited to one stage. The user says which stage to tag.

```
search_conversations(stage="<user-specified-stage>", compact=true)
```

Then fetch, read, and tag as in Mode 1 Steps 4-5.

This mode is better for large pipelines. Processing one stage at a time keeps the analysis focused and avoids LLM context window pressure.

## Mode 3: Tag Question

The user asks a specific question like "who are my decision makers?" or "which conversations have urgency?"

**Option A — Tags already applied:** Search by tag:

```
search_conversations(tags=["decision_maker"], compact=true)
```

Present the results. If the user asks for detail on any, `get_conversation(id)` to show the thread.

**Option B — Tags not yet applied:** Run a targeted scan. Search relevant stages and read threads looking for the specific signal:

```
search_conversations(stage="qualified", compact=true)
search_conversations(stage="discovery", compact=true)
search_conversations(stage="closing", compact=true)
```

For each conversation, `get_conversation(id)` and check for the specific signal the user asked about. Apply tags as you find them using `bulk_update`.

Present a summary: "Found 7 decision makers across your pipeline: [list with stage and key evidence]."

## Mode 4: Tag Cleanup

Find and fix tagging problems. Three sub-tasks:

### 4a: Tag Distribution Report

```
get_stats()
```

Cross-reference with tag searches to build a distribution picture:

```
search_conversations(tags=["decision_maker"], compact=true)
search_conversations(tags=["budget_confirmed"], compact=true)
search_conversations(tags=["urgent"], compact=true)
search_conversations(tags=["going_cold"], compact=true)
search_conversations(tags=["champion"], compact=true)
search_conversations(tags=["competitor_mentioned"], compact=true)
search_conversations(tags=["referral"], compact=true)
search_conversations(tags=["technical_buyer"], compact=true)
```

Present the distribution:

| Tag | Count | Notes |
|-----|-------|-------|
| `decision_maker` | N | Expected: roughly matches qualified+ count |
| `budget_confirmed` | N | Low count = pipeline risk |
| `urgent` | N | High count = capacity risk |
| `going_cold` | N | High count = follow-up needed |
| ... | ... | ... |

### 4b: Stale Tag Detection

Tags that no longer match reality. Find conversations where the tag may be outdated:

- `going_cold` on conversations that have since had fresh replies
- `urgent` on conversations older than 30 days (urgency expired)
- `budget_confirmed` on archived conversations

```
search_conversations(tags=["urgent"], freshness="stale", compact=true)
search_conversations(tags=["going_cold"], freshness="fresh", compact=true)
```

For each hit, `get_conversation(id)` and verify whether the tag still applies. Remove stale tags:

```
bulk_update(updates=[
  {"id": "abc", "tags": ["decision_maker"], "ai_notes": "Removed 'urgent' — original deadline passed 3 weeks ago. No new timeline stated."},
  {"id": "def", "tags": ["champion"], "ai_notes": "Removed 'going_cold' — they replied yesterday with engagement."}
])
```

### 4c: Missing Tag Detection

Scan high-value stages for conversations that should have tags but don't:

```
search_conversations(stage="qualified", compact=true)
```

Filter results for conversations with empty or minimal tag arrays. Fetch those threads and apply tags as in Mode 1.

## ICP-Based Connection Tagging

When the user wants to tag connections (not conversations) based on deeper analysis than headline keywords:

1. Start with a prospect scan to find headline matches:

```
scan_connections(headline_keywords=["<from ICP>"], has_conversation=true)
```

2. For connections that have conversations, `get_conversation` their threads to look for ICP confirmation signals beyond the headline.

3. Tag connections with verified ICP status:

```
tag_connections(
  connection_ids=[<ids>],
  add_tags=["icp-verified"]
)
```

This is the bridge between surface-level prospect-scan (headline match) and deep verification (conversation evidence). Use `icp-verified` to distinguish from `icp-match` (headline only).

## Report Template

After any tagging operation, deliver a summary:

```
## Tagging Complete

**Scope:** [Full audit / Stage: qualified / Tag question: decision_maker / Cleanup]
**Conversations reviewed:** [N]
**Tags applied:** [M] new tags across [P] conversations

### Tag Changes
| Tag | Added | Removed | Total |
|-----|-------|---------|-------|
| decision_maker | X | - | Y |
| budget_confirmed | X | - | Y |
| urgent | X | Z | Y |
| going_cold | X | Z | Y |
| champion | X | - | Y |
| competitor_mentioned | X | - | Y |
| referral | X | - | Y |
| technical_buyer | X | - | Y |

### Key Findings
- [Notable patterns — e.g., "3 qualified leads have both decision_maker and budget_confirmed — these are your hottest opportunities"]
- [Any gaps — e.g., "No budget_confirmed tags in your pipeline — consider asking about budget in your next messages"]
- [Stale tags removed — e.g., "Removed urgent from 2 conversations where the deadline passed"]

### Next Steps
- [Specific actions based on findings]
```

## Guidelines

- Always `get_conversation` the full thread before applying tags. Never tag based on metadata alone.
- Tags in `bulk_update` REPLACE existing tags. Always merge: include existing tags plus new ones.
- `bulk_update` max 100 per call. Split larger batches.
- `bulk_update` does NOT support `draft_message`. This skill is tags-only — no drafting.
- `bulk_update` supports: id, stage, tags, notes, ai_notes, summary, reminder, archive.
- Always include `ai_notes` explaining the evidence for each tag applied or removed.
- One signal can map to multiple tags. Apply all that fit.
- Use `compact=true` on `search_conversations` when collecting IDs for batch processing.
- Process stage by stage for large pipelines. Keeps analysis quality high.
- For tag questions (Mode 3), check if tags are already applied before re-scanning entire stages.
- Stale tag cleanup is as important as new tag application. A wrong tag is worse than no tag.
- If no tag definitions exist in the user's context, propose the signal-to-tag mapping table and offer to configure via `update_context`.
- Handle `has_more` pagination on all `search_conversations` calls.

## Related Skills

- **prospect-scan** — Surface-level connection tagging by headline keywords. Smart-tagging goes deeper by reading conversation content.
- **pipeline-cleanup** — Uses tags for archive/re-engage decisions. Run smart-tagging first for better cleanup accuracy.
- **full-morning-triage** — Applies some tags during classification. Smart-tagging is a dedicated, thorough pass.
- **icp-definition** — Defines the ICP that informs which signals matter most for tagging.
- **pipeline-health-check** — Tag distribution data feeds into pipeline health diagnosis.
