# Pipeline Stages

8 stages representing a trust progression from stranger to client. Each stage has specific signals, actions, and exit conditions.

## Stage Summary

| Stage | Trust Level | Key Signal | Action | Exit Condition |
|-------|-------------|------------|--------|----------------|
| `opening` | Stranger | No reply yet | Follow up with value (not "checking in") | Any reply |
| `chatting` | Acknowledged | Back-and-forth conversation | Ask questions that surface pain points | Budget, authority, need, or timeline mentioned |
| `qualified` | Shared need | Buying signal confirmed | Confirm signal; guide toward call | Call scheduled or proposal next step |
| `discovery` | Credible option | Call booked or deep needs analysis | Capture details; prepare proposal | Proposal/quote sent |
| `closing` | Serious consideration | Proposal sent, negotiating | Follow up with value; address blockers | Confirmed yes or decline |
| `won` | Client | Contract/payment confirmed | Deliver; nurture for referrals | — |
| `lost` | Variable | Explicit no or ghosted after engagement | Record why; revisit later | — |
| `not_a_fit` | N/A | Wrong ICP, spam, selling to you | Archive with reason | — |

## Trust Decay

Trust decays over time. A prospect who was warm two weeks ago may have cooled back to indifference. Every day without a value-adding touchpoint erodes the trust you built. This is why:

- **Hot leads first.** Always respond to fresh replies before anything else.
- **Cold rescue matters.** Conversations going cold can be saved with the right follow-up.
- **Speed wins.** The faster you reply, the less trust decay occurs.

## Freshness States

| Freshness | What It Means | Action |
|-----------|--------------|--------|
| `fresh` | Active conversation, recent messages | Respond promptly |
| `cold` | No messages for several days | Value-add follow-up, not "just checking in" |
| `you_ghosted` | You owe a reply and haven't sent one | Reply immediately — you're the bottleneck |
| `they_ghosted` | They stopped replying after engagement | Re-engagement attempt with new value |
| `stale` | No activity for extended period | Archive or one final re-engagement attempt |

## Archive Reasons

| Reason | When to Use |
|--------|-------------|
| `not_a_fit` | Wrong ICP, selling to you, spam |
| `ghosted` | They stopped replying (14+ days, 2+ follow-ups) |
| `later` | Real prospect, timing is wrong — set a reminder |
| `client` | They became a paying client |
| `competitor` | They chose a competitor |
| `networking` | Valuable connection, not a sales prospect |
| `personal` | Personal relationship, not business |

## Stage Classification Decision Tree

```
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

At any point: Are they clearly not your ICP, selling to you, or spam?
  YES → not_a_fit (archive)
```
