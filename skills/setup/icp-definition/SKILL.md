---
name: icp-definition
description: >
  Interview-style ICP and sales context setup that configures LinkNinja for targeted
  prospecting and accurate classification. Use when the user says "set up my ICP",
  "define my ideal client", "who should I target", "update my ICP", "configure my
  targeting", "set up my profile", or "onboard me". Covers ICP, positioning, and
  summary instructions. Validates against real connections. Related: prospect-scan
  for finding matches after ICP is set, voice-profile-setup for voice configuration,
  stage-configuration for customizing pipeline stages.
metadata:
  version: "1.0"
  author: linkninja
---

# ICP Definition

Configure LinkNinja's sales context so every AI tool — classification, scanning, drafting, analysis — operates with precision instead of guessing. The ICP is the foundation. Everything else builds on it.

Treat the templates and example archetypes here as starting points. Refine your ICP from real customer language — phrases your best clients actually use, frustrations they describe in their own words, the specific moment they decided to seek help. Polished marketing-speak is forgettable; their actual phrasing is what makes drafts land.

## Before Starting

1. Run `get_context()` to load the user's current sales context
2. Check context completeness:

| Field | Status | If Empty |
|-------|--------|----------|
| ICP (`additional_context`) | This is what we're setting up | Start the interview below |
| Positioning (`positioning_context`) | Recommended | "What do you sell or offer? Knowing this helps me craft better messages." |
| Voice Profile (`voice_profile`) | Optional here | Suggest running **voice-profile-setup** after |
| Personal Story (`personal_story`) | Optional here | "Any background or credibility signals I should know about?" |

3. If ICP already exists: summarize it and ask "Want to refine this or start fresh?"
4. If ICP is empty: start the interview

## Workflow

### Step 1: Interview — 6 Dimensions

Walk through these questions. Don't dump them all at once — ask 1-2 per turn and build on their answers.

**Role & Industry**
- "What job titles do your best clients typically have?"
- "What industry or sector are they in?"
- "What company size — employees or revenue range?"
- "What does their LinkedIn headline usually look like?"

**Life Stage & Transitions**
- "What moment or transition are they going through right now?"
- "Are they scaling, struggling, just got promoted, just lost a key hire?"
- "What is the trigger that makes them start looking for help?"

**Daily Frustrations** (prioritize frequency — daily pain > annual pain)
- "What problem does your ideal client deal with every day or every week?"
- "What's the moment in their day where they feel the pain most?"
- "What do they complain about in DMs or on calls — not publicly?"

| Pain Frequency | Responsiveness | Example |
|---------------|---------------|---------|
| Daily | Very high | "Opens Slack at 7am and nothing moves unless they move it" |
| Weekly | High | "Sunday night dread about Monday pipeline review" |
| Monthly | Moderate | "Monthly board report shows churn climbing" |
| Annual | Low | "Annual planning feels overwhelming" |

**Aspirations**
- "What are they trying to become or achieve in the next 6-12 months?"
- "What would their life look like if this problem was solved?"

**Language & Jargon**
- "What acronyms or technical terms do insiders in this space use?"
- "What tools or platforms do they use daily?"
- "How do they describe this problem in their own words — not marketing words?"

Collect real phrases, not polished copy. If the user says "my clients always complain about herding cats," that exact phrase belongs in the ICP.

**Cultural Context**
- "Where are most of your clients located?"
- "Are they formal or casual in how they communicate?"
- "What does credibility look like in their industry?"

### Step 2: Structure the ICP

Assemble answers into a clear paragraph:

```
[Role/title patterns] in [industry/sector] at [company size/stage].
They are currently [life stage / transition / trigger].
Their daily frustration is [specific daily/weekly pain — in their words].
They talk about [jargon, acronyms, tools they use].
They are trying to [aspiration / desired outcome].
Most are based in [geography]. They value [communication norms] and [credibility signals].
```

### Step 3: Save Context

Save the ICP and any other context gathered during the interview:

```
update_context(
  additional_context="[the structured ICP paragraph]",
  positioning_context="[what the user sells/offers, if discussed]",
  summary_instructions="[how to summarize conversations, if discussed]"
)
```

### Step 4: Validate Against Real Connections

Extract headline keywords from the ICP and test against the user's actual network:

```
scan_connections(
  headline_keywords=["<title1>", "<title2>", "<title3>"],
  headline_exclude=["Student", "Intern", "Looking for", "Retired"],
  has_conversation=false
)
```

**Interpret results:**

| Result | What It Means | Action |
|--------|--------------|--------|
| 50+ matches | ICP maps to real people in their network | Good — proceed |
| 10-49 matches | Narrow but viable | Consider broadening keywords |
| < 10 matches | ICP too narrow or wrong network | Broaden keywords or adjust ICP |
| 200+ matches, mostly wrong | Keywords too broad | Tighten include/exclude |

Share results with the user and refine if needed.

### Step 5: Test Classification (Optional)

If the user has existing conversations, test the new ICP against them:

```
start_batch_classify(unclassified_only=true, limit=20)
```

Check results:

```
get_job_status(job_id="<id>")
```

Review: are conversations being classified accurately with the new context? If not, refine the ICP or stage criteria.

## Subsegment Campaigns

After the main ICP is set, users can run niche campaigns for subsegments. Help them identify subsegments:

| Broad ICP | Subsegment | Scan Keywords |
|-----------|-----------|---------------|
| Consultants | Recruitment consultants | `["Recruitment", "Talent", "Staffing"]` |
| Financial advisors | Independent advisors / fiduciaries | `["Financial Advisor", "Independent", "Fiduciary"]` |
| Coaches | Executive coaches for tech | `["Executive Coach", "CTO Coach"]` |
| Agency owners | SEO agencies | `["SEO Agency", "Search Marketing"]` |

The ICP stays broad. Subsegments are targeted via `scan_connections` keywords and campaign-specific tags. See **prospect-scan** and **campaign-launch** for execution.

## Guidelines

- Ask questions one or two at a time. Don't dump the full interview at once.
- Capture real language — exact phrases clients use, not polished marketing copy.
- Prioritize daily/weekly pain over annual pain. Frequency = responsiveness.
- Always validate the ICP against real connections before finishing.
- If the user can't answer a question, skip it and come back later.
- Tell users they can also edit their ICP anytime in the dashboard at Settings → AI Profile.

## Related Skills

- **prospect-scan** — Use after ICP is defined to find matching connections
- **voice-profile-setup** — Set up voice matching after ICP is configured
- **stage-configuration** — Customize pipeline stages for the user's sales process
- **campaign-launch** — Launch a targeted outreach campaign using the ICP
- **won-deal-analysis** — Refine ICP based on actual win/loss data
