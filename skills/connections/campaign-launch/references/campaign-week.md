# Campaign Week: Day-by-Day Execution Plan

A structured 5-day campaign with daily actions, tool calls, and checkpoints. Adjust timing to the user's schedule, but keep the sequence intact.

## Day 1 (Monday): Launch

**Goal:** Get 20-30 opening DMs into the world.

### Morning

1. Final review of campaign design (5-element check in SKILL.md)
2. Pull the tagged prospect list:

```
scan_connections(tags=["campaign-<tag>"], has_conversation=false, limit=30)
```

3. For prospects with existing conversations, fetch context:

```
get_conversation(id="<conversation_id>")
```

4. Draft personalized opening messages (one per conversation):

```
update_conversation(
  id="<id>",
  draft_message="[personalized opener]",
  stage="opening",
  tags=["campaign-<tag>"],
  ai_notes="Campaign opener. Referenced: [what was personalized]. Offer: [campaign offer]."
)
```

Repeat for each prospect. `draft_message` requires `update_conversation` -- `bulk_update` does not support it.

### Afternoon

5. User reviews and sends drafts from the dashboard
6. Send in batches of 5-10 over 2-3 hours (not all at once -- LinkedIn may flag)
7. End-of-day check:

```
search_conversations(tags=["campaign-<tag>"])
```

```
get_stats()
```

**Day 1 target:** 20-30 messages sent, all tagged with campaign tag.

---

## Day 2 (Tuesday): First Replies + More Openers

**Goal:** Respond to early replies. Send another 15-20 openers.

### Morning

1. Check for replies:

```
search_conversations(my_turn=true, freshness="fresh", tags=["campaign-<tag>"])
```

2. Read each reply in full:

```
get_conversation(id="<conversation_id>")
```

3. Draft personalized responses (one per conversation):

```
update_conversation(
  id="<id>",
  draft_message="[response to their reply]",
  ai_notes="Replied to opener. They asked about [X]. Responding with [approach]."
)
```

Repeat for each reply. `draft_message` requires `update_conversation`.

### Afternoon

4. Draft and send 15-20 more opening messages (same process as Day 1)
5. End-of-day pipeline check

**Day 2 target:** All replies answered. 15-20 more openers sent. Running total: 35-50 messages out.

---

## Day 3 (Wednesday): Follow-Ups + Qualification

**Goal:** Follow up on Day 1 non-replies. Start qualifying engaged prospects.

### Morning

1. Check for new replies:

```
search_conversations(my_turn=true, freshness="fresh")
```

2. Follow up on Day 1 non-replies (value-add, not "checking in"):

Find Day 1 conversations still in opening with no reply:

```
search_conversations(stage="opening", tags=["campaign-<tag>"], my_turn=false)
```

Draft follow-ups that add value -- an insight, a relevant resource, a question tied to their situation:

```
update_conversation(
  id="<id>",
  draft_message="[value-add follow-up]",
  ai_notes="Follow-up #1. No reply to opener. Adding value: [what]."
)
```

Repeat for each non-reply. `draft_message` requires `update_conversation`.

### Afternoon

3. For prospects who have engaged in 2+ exchanges, assess for qualification signals:
   - Budget, authority, need, or timeline mentioned?
   - If yes:

```
update_conversation(
  id="<id>",
  stage="qualified",
  ai_notes: "Campaign qualification. Signal: [what they said]. Next: invite to [event/call]."
)
```

4. End-of-day stats

**Day 3 target:** Follow-ups sent to Day 1 non-replies. First prospects moving to qualified.

---

## Day 4 (Thursday): Qualify + Invite

**Goal:** Move qualified prospects toward the event/call/offer.

### Morning

1. Check all replies:

```
search_conversations(my_turn=true, freshness="fresh")
```

2. For qualified prospects, draft invitation messages:

```
update_conversation(
  id="<id>",
  draft_message="[specific invitation to event/call/offer]",
  stage="qualified",
  ai_notes="Campaign invite. Qualified signal: [X]. Inviting to [event] on [date]."
)
```

Repeat for each qualified prospect. `draft_message` requires `update_conversation`.

### Afternoon

3. Follow up on Day 2 non-replies (value-add, different angle from Day 3 follow-up)
4. Confirm attendees with details:

```
update_conversation(
  id="<id>",
  stage="discovery",
  ai_notes="Confirmed for [event]. Key interest: [topic]. Sent confirmation details.",
  reminder="<day before event>"
)
```

5. End-of-day stats

**Day 4 target:** Qualified prospects invited. Confirmations tracked. Follow-ups on Day 2 non-replies.

---

## Day 5 (Friday): Final Push

**Goal:** Close out the campaign week. Final follow-ups. Confirm all attendees.

### Morning

1. Final reply check:

```
search_conversations(my_turn=true, freshness="fresh")
```

2. Send "door open" messages to anyone who engaged but has not committed:

> "No worries if the timing's off -- I run these [monthly/quarterly]. Door's always open."

3. Final confirmation to all attendees:

> "Looking forward to [tomorrow/Thursday]. [Reminder of what they'll get]. Any questions before then?"

### Afternoon

4. For non-replies through the playbook cadence (Day 1 / 3 / 7), keep extending intervals (14, 30, 60 days) with new value each time — 80% close after the 5th touchpoint:

```
bulk_update(updates=[
  {
    id: "abc",
    reminder: "<14 days from now>",
    ai_notes: "Campaign: cadence active. Touch 4 due in 14 days. Will need fresh value to share — check enrichment for new posts/news."
  },
  ...
])
```

5. Campaign checkpoint:

```
get_stats()
```

```
search_conversations(tags=["campaign-<tag>"])
```

Count by stage. Calculate preliminary metrics.

**Day 5 target:** All follow-ups complete. Attendees confirmed. Non-responders set to nurture.

---

## Post-Campaign (Weekend / Following Monday)

### If an event occurred:

| Outcome | Timing | Action |
|---------|--------|--------|
| Attended | Within 2 hours of event | Personal message referencing specific session moment |
| Attended | 24-48 hours after event | Bridge to paid offer, permission-based |
| No-showed | Same day as event | Warm, no guilt. Share key takeaway. Mention next one. |
| Said "not right now" | Set 30-day reminder | Monthly nurture check-in |

### Campaign scoring:

```
export_conversations(tags=["campaign-<tag>"], include_messages=true)
```

Calculate: reply rate, qualification rate, conversion rate, show rate. See SKILL.md Step 7 for full scoring instructions.
