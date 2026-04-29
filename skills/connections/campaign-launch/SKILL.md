---
name: campaign-launch
description: >
  Plan and execute a structured LinkedIn outreach campaign with prospect list building,
  batch drafting, day-by-day execution, follow-up patterns, and campaign scoring. Use
  when the user says "launch a campaign", "run an outreach campaign", "start a campaign",
  "campaign blast", "run a campaign for [segment]", "outreach push", or "I want to
  message a bunch of people about [offer]". Validates campaign design before sending.
  Related: prospect-scan for finding targets, batch-drafting for message generation,
  dm-writing for individual messages, pipeline-health-check for post-campaign review.
metadata:
  version: "1.0"
  author: linkninja
---

# Campaign Launch

Plan, execute, and score a time-compressed outreach campaign built around a specific offer, segment, or event. Concentrates effort into a defined window with measurable conversion at every stage.

## Before Starting

1. Run `get_context()` to load the user's sales context
2. Check required context:

| Field | Required | If Empty |
|-------|----------|----------|
| `additional_context` (ICP) | **HARD STOP** | "I need your ICP defined before we can target a campaign. Want to set that up now?" Point to **icp-definition**. |
| `positioning_context` | Strongly recommended | "What's the campaign offer? Knowing what you sell helps me craft better messages." |
| `voice_profile` | Recommended | "Want to set up your voice profile so drafts sound like you?" Point to **voice-profile-setup**. |
| `personal_story` | Nice-to-have | Can weave credibility into messages if available. |

3. Run `get_stats()` to see current pipeline state before adding campaign volume.

## Workflow

### Step 1: Campaign Design Validation

Before sending a single message, validate 5 elements. If any is vague, help the user sharpen it.

**1. Who is this for?**
Specific enough that the right person knows in under 3 seconds. Stack 2-3 identity layers:

| Layer | Example |
|-------|---------|
| Role + industry | "B2B SaaS founders doing $1-5M ARR" |
| Life stage | "Just hired their first 2-5 SDRs" |
| Emotional reality | "Watching less experienced competitors close deals they should be winning" |

**2. What do they get?**
Tangible outcome, not vague learning. The test: can they picture what they hold in their hands when it is over?

| Weak | Strong |
|------|--------|
| "Learn about LinkedIn strategy" | "Leave with a rebuilt headline and 3-message outreach sequence" |
| "Get tips on ads" | "Watch me pull apart your competitor's ad strategy live" |

**3. When does it happen?**
Specific date and time with a justified reason.

**4. How many spots?**
Genuine capacity limit based on format:

| Format | Spots | Why |
|--------|-------|-----|
| 1-on-1 deep sessions | 3-4 | Maximum personal attention |
| Small curated group | 5-6 | Intimate but with group energy |
| Workshop or event | 8-12 | Demonstration energy, still exclusive |

**5. Self-check score**
Score each element 1-5:

| Element | 1 (Weak) | 3 (Medium) | 5 (Strong) |
|---------|----------|------------|------------|
| Target specificity | "Business owners" | "Career coaches" | "IT leaders in Australia at $180K who feel invisible" |
| Outcome tangibility | "Learn about X" | "Get tips on X" | "Leave with a rebuilt X and a written Y" |
| Deadline specificity | No date | "This week" | "Thursday 7pm AEST -- Q1 planning starts next month" |
| Capacity constraint | No limit stated | "Limited spots" | "5 seats. Application only." |
| Experience design | Passive (watch me) | Interactive (Q&A) | Constructive (we build something together) |

**Total 20-25:** Launch-ready. **15-19:** Tighten 1-2 elements. **Below 15:** Rethink before sending.

### Step 2: Build the Prospect List

**Scan for new prospects:**

```
scan_connections(
  headline_keywords=["<keyword1>", "<keyword2>"],
  headline_exclude=["Student", "Intern", "Looking for"],
  has_conversation=false
)
```

**Find recent connections** (warmer than long-dormant ones):

```
scan_connections(connected_after="<30-60 days ago ISO date>")
```

**Check warm pipeline:**

```
search_conversations(stage="chatting", my_turn=true)
```

**Tag the full campaign list:**

```
tag_connections(
  connection_ids=[<id1>, <id2>, <id3>, ...],
  add_tags=["campaign-<name>-<month>"]
)
```

Present the list to the user with counts: "Found 42 new prospects and 8 warm conversations. Ready to draft opening messages?"

### Step 2.5: Enrich the Cohort (Recommended Before Drafting)

For personalised openers that use **Precision Flattery**, enrich the cohort first. This pulls Sales Nav data (recent posts, experience, projects, education) so each opener can reference one specific item credibly:

```
enrich_connections(
  filter={tags: ["campaign-<name>-<month>"], is_enriched: false},
  re_enrich_after_days=30,
  limit=100
)
```

Returns a `job_id`. ~6 sec per connection — for cohorts >50, return the `job_id` to the user with an ETA and continue when the job completes. Daily quota: 200 enrichments/day. See `references/enrichment-sections.md`.

After the job completes, pull the sections you need for drafting:

```
get_enrichment(
  ids=[conv_a, conv_b, ...up to 100...],
  sections=["recent_posts", "experience"]
)
```

This is the foundation for Precision Flattery — without it, openers fall back to headline-only references.

### Step 3: Batch Draft Opening Messages

For each prospect, craft a personalized opener. Fetch context where available:

```
get_conversation(id="<conversation_id>")
```

Save each draft individually, then batch the stage/tag updates:

```
// Save drafts one at a time (bulk_classify does not support draft_message)
update_conversation(id="abc", draft_message="Hey Sarah -- noticed you're scaling your SDR team...", ai_notes="Cold open. Referenced headline: 'VP Sales scaling SDR team'. Campaign: Mar 2026 workshop.")
update_conversation(id="def", draft_message="Hey James -- saw your post about outbound challenges...", ai_notes="Cold open. Referenced recent post about outbound. Campaign: Mar 2026 workshop.")
// ...repeat for each prospect

// Batch stage and tag updates
bulk_update(updates=[
  {id: "abc", stage: "opening", tags: ["campaign-mar-2026"]},
  {id: "def", stage: "opening", tags: ["campaign-mar-2026"]},
  ...
])
```

Max 100 per `bulk_update` call. If the list is larger, batch in groups.

The user reviews all drafts in their LinkNinja dashboard and sends them manually.

### Step 4: Execute Campaign Week

Follow the day-by-day plan in `references/campaign-week.md`. Summary:

| Day | Primary Actions | Key Tool Calls |
|-----|----------------|---------------|
| Day 1 | Send 20-30 opening DMs (from drafts) | `update_conversation` per draft, `bulk_update` for stage/tags |
| Days 2-3 | Reply to responses, follow up non-replies, send 15-20 more opens | `search_conversations(my_turn=true)`, `get_conversation`, `update_conversation` per draft |
| Days 3-4 | Qualify engaged prospects, invite to event/call | `update_conversation(stage="qualified")` |
| Day 5 | Final follow-ups, confirm attendees, door-open messages | `search_conversations(tags=["campaign-..."])` |

### Step 5: Daily Tracking

Run at end of each day:

```
get_stats()
```

```
search_conversations(tags=["campaign-<tag>"])
```

Count conversations by stage to track campaign flow.

### Step 6: Follow-Up Management

See `references/follow-up-cadence.md` for detailed timing. Core rules:

| Situation | Timing | Action |
|-----------|--------|--------|
| They replied | Same day | Respond with a relevant question |
| No reply after 2 days | Day 3 | Value-add follow-up (insight, resource, question) |
| No reply after 5 days | Day 5-6 | Different angle or door-open message |
| After playbook cadence exhausted (Day 1/3/7/extending) | Hand off to **cold-rescue** | Re-engagement track with new value, or extend reminders 30-90 days |

Set reminders for follow-ups:

```
update_conversation(
  id="<id>",
  reminder="<follow-up date>",
  ai_notes="Campaign follow-up #1 due. No reply to opener."
)
```

### Step 7: Campaign Scoring

After the campaign week, measure results:

**Pull all campaign data:**

```
search_conversations(tags=["campaign-<tag>"], compact=true)
```

```
export_conversations(tags=["campaign-<tag>"], include_messages=true)
```

**Key metrics:**

| Metric | Formula | Benchmark |
|--------|---------|-----------|
| Reply rate | Replies / Messages sent | 15-30% is good for cold |
| Qualification rate | Qualified / Replies | 30-50% means targeting is right |
| Conversion rate | Confirmed attendees / Qualified | Depends on offer strength |
| Show rate | Attended / Confirmed | 70%+ means confirmation is working |

**Pattern analysis:**
- Which prospect types responded best? Tighten ICP for next campaign.
- Where did conversations stall? That stage's messaging needs work.
- Which opening messages got replies? Save the language that worked.
- Common objections? Build responses for next campaign.

**CSV export for offline analysis:**

```
export_conversations(tags=["campaign-<tag>"], format="csv")
```

**Feed learnings back:**

```
update_context(
  additional_context="Campaign insight: [segment] responded best. [Opening approach] got highest reply rate. [Segment] did not respond -- consider excluding."
)
```

## Post-Event Follow-Up

If the campaign leads to an event or session:

| Outcome | Timing | Action |
|---------|--------|--------|
| Attended | Within 2 hours | Personal message referencing something specific from session |
| Attended | 24-48 hours | Bridge to paid offer (permission-based) |
| No-showed | Same day | Warm, no guilt. Share key takeaway. Mention next session. |
| "Not right now" | Set monthly reminder | Check-in tied to their world, not a pitch |

```
update_conversation(
  id="<id>",
  stage="discovery",
  ai_notes="Attended March workshop. Key interest: [topic]. Engaged on [specific moment]. Follow up with bridge offer.",
  reminder="<24-48 hours later>"
)
```

## Guidelines

- Validate all 5 campaign design elements before drafting any messages. A campaign without a clear offer underperforms.
- Never send messages directly. Always save as drafts via `draft_message`. The user reviews and sends.
- Always include `ai_notes` explaining: what signal the message responds to, what the draft tries to accomplish, campaign tag.
- Personalize every opener. Reference their headline, a post, mutual connection, or specific situation. Never template-blast.
- Follow the playbook cadence (Day 1 / 3 / 7 / extending). Each touch must add new value. Hand to **cold-rescue** if a conversation goes cold mid-campaign — 80% of sales close after the 5th touchpoint.
- Tag every campaign conversation for tracking and post-campaign analysis.
- Run `get_stats()` daily during the campaign to track flow.
- Max 100 per `bulk_update` call. Batch larger lists into multiple calls.

## Related Skills

- **prospect-scan** -- Build the prospect list before launching
- **batch-drafting** -- For high-volume message drafting during the campaign
- **dm-writing** -- For crafting individual high-value messages
- **pipeline-health-check** -- Post-campaign pipeline review
- **cold-rescue** -- Re-engage campaign conversations that went cold
- **icp-definition** -- Refine ICP based on campaign results
