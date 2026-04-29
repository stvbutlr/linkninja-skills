# Pipeline Stages

Seven user-visible pipeline stages representing a trust progression from stranger to client. Each stage has its own signals, exit conditions, and recommended actions. Plus the `archive` operation as an off-ramp for non-stages (wrong ICP, spam, networking, etc.).

## Stage Summary

| Stage | Trust Level | Key Signal | Action | Exit Condition |
|-------|-------------|------------|--------|----------------|
| `opening` | Stranger | No reply yet | Follow up with value (not "checking in") | Any reply |
| `chatting` | Acknowledged | Back-and-forth conversation | Ask questions that surface pain points | Budget, authority, need, or timeline mentioned |
| `qualified` | Shared need | Buying signal confirmed | Confirm the signal; guide toward call | Call scheduled or proposal next step |
| `discovery` | Credible option | Call booked or deep needs analysis | Capture details; prepare proposal | Proposal/quote sent |
| `closing` | Serious consideration | Proposal sent, negotiating | Follow up with value; address blockers | Confirmed yes or decline |
| `won` | Client | Contract/payment confirmed | Deliver; nurture for referrals | — |
| `lost` | Variable | Explicit no or ghosted after engagement | Record why; revisit later | — |

`not_a_fit` is **not** a stage — it's an archive reason. Same for `ghosted`, `later`, `client`, `competitor`, `networking`, `personal`. Use `archive: {archived: true, reason: "..."}` on `update_conversation` or `bulk_update`.

## Trust Decay

Trust decays over time. A prospect who was warm two weeks ago may have cooled back to indifference. Every day without a value-adding touchpoint erodes the trust you built. This is why:

- **Hot leads first.** Always respond to fresh replies before anything else.
- **Cold rescue matters.** Conversations going cold can be saved with the right follow-up — and 80% of sales close after the 5th touchpoint.
- **Speed wins.** The faster you reply, the less trust decay occurs.

## Freshness States

| Freshness | What It Means | Action |
|-----------|--------------|--------|
| `fresh` | Active conversation, recent messages | Respond promptly |
| `cold` | No messages for several days | Value-add follow-up, never "just checking in" |
| `you_ghosted` | You owe a reply and haven't sent one | Reply immediately — you're the bottleneck |
| `they_ghosted` | They stopped replying after engagement | Re-engagement attempt with new value |
| `stale` | No activity for extended period | Final attempt with new angle, then archive |

## Archive Reasons

Set via `archive: {archived: true, reason: "..."}`. Don't confuse with stages.

| Reason | When to Use |
|--------|-------------|
| `not_a_fit` | Wrong ICP, selling to you, spam |
| `ghosted` | They stopped replying (after the playbook's 5-touch persistence cadence) |
| `later` | Real prospect, timing is wrong — set a reminder |
| `client` | They became a paying client through another path |
| `competitor` | They chose a competitor |
| `networking` | Valuable connection, not a sales prospect |
| `personal` | Personal relationship, not business |

## Stage Classification Decision Tree

```
Is this a real prospect (right ICP, not selling to you, not spam)?
  NO → archive with reason: not_a_fit

  YES ↓
Did they reply at all?
  NO  → opening
  YES ↓

Is their reply a buying signal (need, budget, authority, timeline)?
  NO  → chatting
  YES ↓

Has a call/meeting been scheduled or deep needs analysis started?
  NO  → qualified
  YES ↓

Has a proposal/quote been sent?
  NO  → discovery
  YES ↓

Have they confirmed yes or declined?
  YES, confirmed → won
  YES, declined  → lost
  NO             → closing
```
