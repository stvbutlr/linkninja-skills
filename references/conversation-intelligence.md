# Conversation Intelligence Fields

Each classified conversation carries a set of AI-derived intelligence fields returned by `get_conversation` and embedded in `search_conversations` / `export_conversations` results. Skills should read these directly instead of re-inferring from raw transcripts.

## The 8 Verified Fields

| Field | Type | Values |
|-------|------|--------|
| `warmth_level` | string | `hot`, `warm`, `neutral`, `cold` |
| `warmth_score` | integer | 0–100 (raw score; `warmth_level` is the discretised bucket) |
| `sentiment` | string | typically `positive`, `neutral`, `negative` (derived from message tone) |
| `conversation_health` | string | `healthy`, `at_risk`, `dead` |
| `engagement_signals` | array | observed engagement indicators (e.g., questions back, multi-message replies) |
| `interest_signals` | array | observed interest indicators (e.g., asked about pricing, requested info) |
| `objection_signals` | array | observed objection indicators (e.g., "too expensive", "not the right time") |
| `momentum_signals` | array | observed momentum indicators (e.g., proposal accepted, time slot agreed) |

## How Skills Should Use Each Field

### `warmth_level` and `warmth_score`

Slice conversations by readiness:

| Level | Action |
|-------|--------|
| `hot` | Top priority. Respond same day. Likely a buying signal. |
| `warm` | Engaged. Move toward qualifying or call booking. |
| `neutral` | Building rapport. Use the question sequence. |
| `cold` | Re-engagement candidate. Apply Day 1 / 3 / 7 / extending cadence. |

### `conversation_health`

Diagnostic for `pipeline-health-check` and `cold-rescue`:

| Health | Diagnosis | Action |
|--------|-----------|--------|
| `healthy` | Active and progressing | No intervention needed |
| `at_risk` | Slowing or stalled | Value-add follow-up; re-engage with new angle |
| `dead` | Effectively over | Final touch then archive, or archive directly |

### `sentiment`

Reads message tone. Combine with `conversation_health`:

- `positive` + `healthy` = green light, advance to next step
- `negative` + `at_risk` = surface the underlying concern with Acknowledge → Ask Context → Reframe
- `neutral` across multiple touches = build more trust before asking

### Signals arrays

Each is a list of specific observations. Use them in `ai_notes` to explain reasoning and in `smart-tagging` to apply tags backed by evidence.

| Signal array | Used for |
|--------------|----------|
| `engagement_signals` | Detecting `going_cold` (drop in engagement) and conversation depth |
| `interest_signals` | Mapping to `qualified` stage (interest → buying signal) |
| `objection_signals` | Routing to `objection-handling`; mapping to objection-themed tags |
| `momentum_signals` | Confirming readiness to advance stage (e.g., to `discovery` or `closing`) |

## Worked Examples

**Conversation with `warmth_level: hot`, `conversation_health: healthy`, `momentum_signals: ["agreed to call slot"]`:**
→ Move to `discovery`, no further qualifying needed, draft a confirmation message.

**Conversation with `warmth_level: cold`, `conversation_health: at_risk`, `objection_signals: ["price not right"]`:**
→ `objection-handling` with the price-reframe pattern, set Day 7 reminder.

**Conversation with `warmth_level: cold`, `conversation_health: dead`, no recent signals:**
→ Final value-add touch, then archive as `ghosted`. Beyond the 5-touch persistence cadence.

## Cross-References

- `smart-tagging` uses these fields as evidence for tag application.
- `pipeline-health-check` uses `conversation_health` distribution as a leading indicator.
- `cold-rescue` filters on `conversation_health: at_risk` + `warmth_level: cold` to find rescue candidates.
- `dm-writing` and its situation children read these to inform draft tone and intent.
