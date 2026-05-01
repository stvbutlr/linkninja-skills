# Contributing to LinkNinja Skills

These skills are conceptual tools, not rigid scripts. They're built around the [Sell By Chat Playbook](https://library.sevenfigurecreators.com/3/the-sell-by-chat-playbook) and the LinkNinja MCP, but they're meant to be tweaked and edited to suit your actual customers, your actual offer, and your actual voice.

If you've adapted a skill in a way that worked well — share it back. That's how this collection gets better.

## What Makes a Good Contribution

Things that genuinely help the community:

- **A new skill** for a workflow that's not yet covered (e.g., a niche industry's outreach pattern, an analysis the existing skills don't run).
- **A meaningful improvement** to an existing skill — sharper context handling, a better example, a missed edge case.
- **A new archetype template** in `setup/icp-definition` for a customer profile not yet covered.
- **Documentation fixes** — broken cross-references, outdated tool parameters, voice slips.

Things we generally won't merge:

- Generic wordsmithing without functional change.
- "Just checking in" style fluff in DM examples.
- Personal forks of skills that only make sense for your business.
- Anything that strips playbook attribution or removes the sell-by-chat methodology anchoring.

## How to Contribute

1. **Fork** the repo at <https://github.com/stvbutlr/linkninja-skills>.
2. **Branch** from `main` with a short, specific name (`niche/financial-advisor-icp`, `fix/cold-rescue-cadence-typo`).
3. **Make your change.** Keep skills under 500 lines — overflow goes in `references/` (top-level for shared, per-skill for skill-specific).
4. **Validate.** Run `./validate-skills.sh` before pushing. PRs that fail the validator won't be reviewed.
5. **Submit a PR** with a short description of the problem you ran into and how your change fixes it. Concrete examples help.

## Voice and Style

User-facing copy in this repo (README, examples, sample DMs) should sound like Steve, not generic AI marketing copy. The voice rules live in `.claude/skills/steve-voice/SKILL.md` and the playbook reference at `references/sell-by-chat-methodology.md`.

Some specifics that come up often:

- Talking-to-a-mate tone. Direct, warm, genuinely curious. **No pitch energy.**
- Casual-professional. Contractions always.
- Short by default. A few sentences max.
- Ellipsis (…) for pauses, **never em dashes**.
- No "crushing it", "game-changer", "unlock", "scale", "I'd love to connect", "Let's jump on a quick call" — bin them on sight.
- Australian-isms or Canadianisms ("yeah, nah", "mint") land naturally; don't force them.

The instructional text inside SKILL.md (workflow steps, parameter tables, validator notes) stays direct and instructional per the AGENTS.md writing standards. The voice rules apply to the human-facing prose around it.

## Skill Format Requirements

The validator (`./validate-skills.sh`) enforces:

- YAML frontmatter starting with `---` and including `name` (lowercase a-z, numbers, hyphens, 1-64 chars) and `description` (1-1024 chars).
- The frontmatter `name` must match the directory name.
- SKILL.md under 500 lines. Move overflow to `references/`.
- Required sections: `## Before Starting`, `## Guidelines`, `## Related Skills`.
- A `get_context()` call somewhere in the workflow.

## Branch Naming

- `niche/<thing>` — new ICP archetype, niche-specific skill, archetype template
- `fix/<thing>` — bug fix, typo, broken cross-ref
- `feat/<thing>` — new skill or substantive new section
- `docs/<thing>` — README / CONTRIBUTING / reference doc updates only

## Commit Conventions

- Prefix commits with `feat:`, `fix:`, `docs:`, `refactor:` as relevant.
- Keep messages tight and focused on *why*.
- **Do not include `Co-Authored-By: Claude` trailers** or "🤖 Generated with Claude Code" footers. PRs are authored by humans (or by humans with AI help, but the attribution stays human).

## What "Conceptual Tools" Means

These skills are starting points anchored in real frameworks (Three Opening Rules, A–B Method, Acknowledge → Ask Context → Reframe, Micro-commitments, Day 1/3/7 cadence). They're wired up to real LinkNinja flows. But they're written to be adapted — tweak the examples to your industry, swap the archetypes for your real customer profiles, refine the cadence to your sales cycle, edit the voice patterns to match how you actually write.

If your tweak makes a skill more useful for someone like you, that's exactly the contribution we want back. Open a PR.

## License

By contributing, you agree to the terms in [LICENSE](LICENSE). In short: you grant LinkNinja and Steve Butler a perpetual, worldwide, royalty-free, non-exclusive, sublicensable license to use your contribution within this project. You retain copyright in your original work.
