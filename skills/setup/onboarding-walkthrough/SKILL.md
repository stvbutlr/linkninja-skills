---
name: onboarding-walkthrough
description: >
  First-time onboarding flow for new LinkNinja users. Wraps ninja_setup to walk
  through ICP, positioning, voice profile, and pipeline-stage configuration in
  one guided session. Use when the user says "set me up", "onboard me", "I'm new
  to LinkNinja", "first time setup", "help me get started", "let's get started",
  "I just signed up", or "where do I begin". Frames the work in playbook terms
  — building the foundation for serving, not selling. Related: icp-definition
  for deep ICP work after, voice-profile-setup for richer voice, stage-configuration
  for tailoring the pipeline, prospect-scan once setup is done.
metadata:
  version: "1.0"
  author: linkninja
---

# Onboarding Walkthrough

Walk a brand-new LinkNinja user through the foundational setup in one guided session, so every other skill they later run has the context it needs. Sets ICP, positioning, voice profile, and pipeline-stage criteria. Framed in the playbook's language: *Stop selling. Start serving.* — what we're building together is the foundation for serving prospects well.

The setup is a starting point, not a finished product. Capture what's true today; refine as the user learns what their real customers actually respond to. Subsequent runs of `icp-definition`, `voice-profile-setup`, and `stage-configuration` are how the foundation gets sharper over time.

## Before Starting

1. Run `get_context()` to see how much is already configured.
2. Decide the path:

| Current state | Path |
|---------------|------|
| All 4 profile fields empty (`additional_context`, `positioning_context`, `voice_profile`, `personal_story`) | First-time onboarding — proceed below |
| Some fields populated, others empty | Targeted top-up — point to the relevant individual skill (**icp-definition**, **voice-profile-setup**, **stage-configuration**) |
| All fields populated, stages customised | Already onboarded — confirm with the user, suggest **prospect-scan** to start working the pipeline |

3. Check whether the user has any conversations yet (`get_stats`). If not, that's fine — they can configure ahead of importing DMs.

## Step 0 — What Kind of Business Are You? (Archetype Detection)

Before walking through the foundation, ask the user what kind of business they run. Different archetypes have different ICP shapes, voice patterns, and pipeline shapes — using a known archetype as a starting point makes the rest of setup sharper and faster, not generic.

**Ask:**

> Quick one before we dive in — which best describes what you do?
>
> 1. **Consultant** (recruitment, IT, business strategy, ops, marketing, sustainability)
> 2. **Coach** (executive, career, leadership, sales, business, performance, health)
> 3. **Financial advisor or wealth manager**
> 4. **Agency owner** (SEO, creative, content, paid media, web)
> 5. **Niche service seller** (specialist accountant, fractional CFO/CMO, copywriter, course creator, therapist, etc.)
> 6. **Something else** — I'll describe it

Once they answer, branch the rest of this walkthrough using the archetype as a starting point. **Always confirm before saving** — the archetype gives sensible defaults, the user fine-tunes from there.

### Archetype Shaping (How Each Archetype Bends the Rest of Setup)

| Archetype | ICP shape | Voice tendency to flag | Pipeline shape |
|-----------|-----------|------------------------|----------------|
| Consultant | SMB-to-mid-market buyers; specific functions inside firms | Over-jargon — encourage plain language | Discovery → scope → engagement |
| Coach | Individual buyers (1:1) or cohort participants | Over-affirm — encourage candour | Discovery → enrolment, or cohort intake |
| Financial advisor | AUM-qualified individuals; compliance-aware | Over-formal — encourage warmth, watch compliance | Fact-find → plan → engagement (often 2-meeting) |
| Agency owner | SMB-to-mid-market clients | Founder voice vs agency-marketing voice — keep founder | Discovery → audit/proposal → scope |
| Niche service seller | Highly varied; depends on niche | Depends — surface their distinctive voice | Depends — often 1-2 meeting close |

For deeper archetype-specific ICP starting points, point the user to **icp-definition**'s Archetype Templates section after Step 4 below.

## The Onboarding Arc

This is one session, four moves. Each move ties to a playbook framework so the user understands *why* we're configuring this, not just what.

| Move | What | Why (playbook framing) |
|------|------|------------------------|
| 1. ICP | Who you serve | You can't serve specifically without knowing who. Specificity beats generic every time. |
| 2. Positioning | What you offer | The thing you serve them with. Frames every value-add and answer. |
| 3. Voice | How you sound | "Talking to a mate, not writing a post." Authenticity is the moat. |
| 4. Stages | Your pipeline shape | Trust progression. Defines what "served well" looks like at each step. |

## Workflow

### Step 1: Use `ninja_setup` for the Guided Flow

```
ninja_setup()
```

`ninja_setup` returns a structured walkthrough that surfaces the right questions in order. Read its output and present each question to the user one at a time — don't dump them all at once. As they answer, capture concrete details (their actual words, real client examples) rather than polished marketing copy.

### Step 2: Save the ICP

After the ICP-focused questions, save:

```
update_context(
  additional_context="[Structured ICP paragraph — role + industry + company stage + life stage + daily frustration + jargon they use + aspiration + cultural context]"
)
```

For deeper ICP work (a 6-dimension interview, network validation), hand off to **icp-definition**.

### Step 3: Save Positioning

After the offer-focused questions, save:

```
update_context(
  positioning_context="[What they sell + what makes it different + pricing + how the sales process flows — multiple entry points, single entry point, etc.]"
)
```

### Step 4: Capture (Or Plan) the Voice Profile

The richest voice profiles are built from real messages. Two paths depending on whether the user has any sent DMs yet:

- **Has 5+ sent messages already:** point them to **voice-profile-setup** for a 12-dimension analysis from real samples.
- **Brand-new account, no messages yet:** capture a starter profile inline using the playbook's Ten Core Voice Rules as the baseline. They can refine later via **voice-profile-setup** once they've sent some DMs.

```
update_context(
  voice_profile="[Tone + formality + greeting + sign-off + emoji + humour + rhythm + pitching rules + anti-vocabulary]"
)
```

If their voice has distinctive quirks (regional idiom, specific punctuation preference), capture those verbatim — those quirks are the difference between sounds-like-them and sounds-like-AI.

### Step 5: Save Personal Story (Optional but Useful)

```
update_context(
  personal_story="[Background + credibility signals + relevant experience]"
)
```

Used for credibility references in **reply-handling** and **objection-handling**. Not used in cold-outreach (would feel like leading with your CV).

### Step 6: Tailor the Pipeline Stages

The 7 default stages (opening, chatting, qualified, discovery, closing, won, lost) work for most users, but the entrance/exit criteria and AI context should be customised to their sales process. For deep stage work, hand off to **stage-configuration**. For a quick first pass, set entrance criteria for the two highest-leverage stages:

```
update_context(
  stages: [
    {key: "qualified", entrance_criteria: "[What must be true for them to consider this a real opportunity?]", ai_context: "[Their qualification standard]"},
    {key: "discovery", entrance_criteria: "[Call booked / demo done / deep needs analysis underway?]", ai_context: "[How discovery works in their model]"}
  ]
)
```

### Step 7: Confirm and Hand Off

Show the user the full configured context (read it back from `get_context` post-save):

> Setup complete. Here's what we've configured for [archetype]:
>
> - **ICP**: [first sentence of additional_context]
> - **Positioning**: [first sentence of positioning_context]
> - **Voice**: [tone summary, including any archetype-specific flags from Step 0]
> - **Personal story**: [one-line summary]
> - **Pipeline**: 7 stages, [N] customised
>
> Next step:
>
> - **Sharpen the foundation**: run **icp-definition** for a deeper interview tied to your archetype's templates, then **voice-profile-setup** once you have 5+ sent DMs to analyse, then **stage-configuration** if your pipeline shape needs more nuance than the defaults.
> - **Start working the pipeline**: if you have existing DMs, run **full-morning-triage**; if you're starting fresh, run **prospect-scan** then **campaign-launch**.

The setup is sharper after a few weeks of real conversations — the AI's classifications and your own observations will surface what to refine.

## Guidelines

- One or two questions at a time. Don't dump the whole onboarding interview.
- Capture real language — exact phrases, real client quotes, distinctive vocabulary. Polished copy is forgettable.
- Always save what's been confirmed before moving on — incremental saves protect against losing work.
- Frame each step in playbook terms. Users who understand *why* configure better than users who just answer questions.
- Voice profile gets richer over time. A starter profile is fine for day 1; **voice-profile-setup** gets called later for the deep version.
- Pipeline stages don't need to be perfect on day 1 — you can refine via **stage-configuration** after the user sees how the AI classifies their first batch.
- Tell users they can edit anything via the dashboard at Settings → AI Profile if they prefer a UI to a conversation.

## Related Skills

The setup arc continues from here:

- **icp-definition** — Deep ICP work. Includes archetype templates aligned with Step 0's branches.
- **voice-profile-setup** — 12-dimension voice analysis. Includes archetype-specific tendency tables.
- **stage-configuration** — Tailored stage criteria with archetype-specific examples.

Once setup is done:

- **prospect-scan** — Find ICP matches in the network using the saved keywords
- **campaign-launch** — Run the first targeted outreach push
- **full-morning-triage** — Daily compound workflow once DMs are flowing
