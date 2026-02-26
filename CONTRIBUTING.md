# Contributing

## Adding a New Skill

1. Create a directory: `skills/your-skill-name/`
2. Create `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Add reference files in `skills/your-skill-name/references/` if needed
4. Run `./validate-skills.sh` before committing

## Skill Requirements

- `name` field must match directory name (lowercase a-z, numbers, hyphens, 1-64 chars)
- `description` must include: what it does, trigger phrases, related skills (1-1024 chars)
- SKILL.md must be under 500 lines — move verbose content to `references/`
- Must include sections: "Before Starting", "Guidelines", "Related Skills"
- Must start with `get_context()` to check user context
- Tool calls inline with workflow steps, not in a separate section
- No branded formulas, acronyms, or motivational fluff

## Branch Naming

- `feature/skill-name` — new skill
- `fix/skill-name-description` — fix to existing skill

## Validation

```bash
./validate-skills.sh
```

Must pass with 0 errors before merging.
