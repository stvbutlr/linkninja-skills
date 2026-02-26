#!/bin/bash
# Validates all SKILL.md files in the skills/ directory
# Checks: frontmatter, naming, line count, description length, references

set -e

ERRORS=0
WARNINGS=0
SKILLS_DIR="skills"

echo "Validating LinkNinja skills..."
echo "==============================="

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    echo "ERROR: $skill_name/ missing SKILL.md"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  echo ""
  echo "Checking: $skill_name"

  # Check name format (lowercase, hyphens, numbers only)
  if ! echo "$skill_name" | grep -qE '^[a-z][a-z0-9-]{0,63}$'; then
    echo "  ERROR: Directory name '$skill_name' must be lowercase a-z, numbers, hyphens (1-64 chars)"
    ERRORS=$((ERRORS + 1))
  fi

  # Check no leading/trailing/consecutive hyphens
  if echo "$skill_name" | grep -qE '(^-|-$|--)'; then
    echo "  ERROR: Directory name '$skill_name' has leading, trailing, or consecutive hyphens"
    ERRORS=$((ERRORS + 1))
  fi

  # Check YAML frontmatter exists
  first_line=$(head -1 "$skill_file")
  if [ "$first_line" != "---" ]; then
    echo "  ERROR: SKILL.md missing YAML frontmatter (must start with ---)"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Extract frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

  # Check name field exists and matches directory
  fm_name=$(echo "$frontmatter" | grep -E '^name:' | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")
  if [ -z "$fm_name" ]; then
    echo "  ERROR: Missing 'name' field in frontmatter"
    ERRORS=$((ERRORS + 1))
  elif [ "$fm_name" != "$skill_name" ]; then
    echo "  ERROR: name '$fm_name' does not match directory '$skill_name'"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: name matches directory"
  fi

  # Check description field exists
  has_description=$(echo "$frontmatter" | grep -cE '^description:' || true)
  if [ "$has_description" -eq 0 ]; then
    echo "  ERROR: Missing 'description' field in frontmatter"
    ERRORS=$((ERRORS + 1))
  else
    # Extract full description (may be multiline with >)
    desc_line=$(echo "$frontmatter" | grep -A 20 '^description:' | head -20)
    desc_length=$(echo "$desc_line" | wc -c | tr -d ' ')
    if [ "$desc_length" -lt 10 ]; then
      echo "  WARNING: Description seems too short ($desc_length chars)"
      WARNINGS=$((WARNINGS + 1))
    fi
    echo "  OK: description present"
  fi

  # Check line count
  line_count=$(wc -l < "$skill_file" | tr -d ' ')
  if [ "$line_count" -gt 500 ]; then
    echo "  ERROR: SKILL.md is $line_count lines (max 500). Move content to references/"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: $line_count lines"
  fi

  # Check for required sections
  if ! grep -q "## Before Starting" "$skill_file"; then
    echo "  WARNING: Missing '## Before Starting' section"
    WARNINGS=$((WARNINGS + 1))
  fi

  if ! grep -q "## Guidelines" "$skill_file"; then
    echo "  WARNING: Missing '## Guidelines' section"
    WARNINGS=$((WARNINGS + 1))
  fi

  if ! grep -q "## Related Skills" "$skill_file"; then
    echo "  WARNING: Missing '## Related Skills' section"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check for get_context() call
  if ! grep -q "get_context" "$skill_file"; then
    echo "  WARNING: No get_context() call found. Skills should check user context."
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check references exist
  if [ -d "$skill_dir/references" ]; then
    for ref_file in "$skill_dir"/references/*.md; do
      if [ -f "$ref_file" ]; then
        ref_name=$(basename "$ref_file")
        echo "  OK: reference $ref_name exists"
      fi
    done
  fi

done

echo ""
echo "==============================="
echo "Results: $ERRORS errors, $WARNINGS warnings"

if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED: Fix errors before committing."
  exit 1
else
  echo "PASSED"
  exit 0
fi
