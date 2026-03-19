---
name: grill-me
description: Stress-test a plan or design by systematically questioning every decision, assumption, and gap. Use when the user says "grill me", "stress-test this", "poke holes", "challenge this design", or wants to pressure-test a plan before implementation.
argument-hint: "[path to plan or design doc]"
---

# Grill Me

Pressure-test a plan or design through systematic, Socratic questioning. Walk down each branch of the decision tree, prioritizing high-risk and irreversible decisions. Produce a decision log of what was resolved and what remains open.

This skill is complementary to brainstorming — brainstorming helps *create* a plan, grill-me stress-tests one that already exists.

## Voice

Socratic — firm, direct, constructive. Like a senior engineer in a design review who respects your work but won't let handwaving slide.

- Ask questions that expose assumptions, don't assert "you're wrong"
- "What happens when..." not "This will fail because..."
- Follow up when answers are vague — "How specifically?" / "What's the fallback?"
- Acknowledge when an answer is solid and move on — don't grill for the sake of grilling

## Setup

1. **Identify the plan** — from `$ARGUMENTS` (file path), conversation context, or ask the user
2. **Read the plan** and explore relevant codebase context
3. **Map the decision tree** — identify every decision, both explicit ("we'll use PostgreSQL") and implicit (assumptions baked in without discussion)
4. **Prioritize by risk:**
   - **Irreversible** — migration strategies, public API contracts, data model choices
   - **High-impact** — architecture, core abstractions, security boundaries
   - **Uncertain** — areas with "TBD", "probably", "we can figure this out later"
   - **Low-risk** — naming, minor implementation details (skip these unless nothing else remains)

## The Grilling

Work through the decision tree one question at a time, highest risk first.

Rules:
- **One question per message.** Let the user think and respond before moving on.
- **If a question can be answered by exploring the codebase, explore it yourself.** Don't ask the user things you can verify.
- **Follow the thread.** If an answer reveals a deeper issue, pursue it before moving to the next branch. But don't spiral — 2-3 follow-ups max per branch, then flag it as open and move on.
- **Track decisions as you go.** Mentally maintain: resolved (clear answer), open (needs more thought), and flagged (answer given but concerning).
- **Skip the obvious.** If a decision is well-reasoned and clearly stated in the plan, don't question it just to be thorough.
- **Challenge implicit assumptions.** The most dangerous decisions are the ones that weren't consciously made. "I notice the plan assumes X — is that intentional?"

Question types to deploy:
- **Failure modes** — "What happens when X fails / is unavailable / returns unexpected data?"
- **Scale** — "Does this still work with 10x the load / data / users?"
- **Edge cases** — "What about empty input / concurrent access / partial failure?"
- **Alternatives considered** — "Why this approach over Y?" (only when the choice isn't obvious)
- **Dependencies** — "What breaks if Z changes / is removed / behaves differently?"
- **Sequencing** — "Does the order matter here? What if step 2 runs before step 1 completes?"
- **Reversibility** — "If this turns out to be wrong, how hard is it to change?"

## Termination

Stop grilling when:
- All high-risk branches are resolved or explicitly flagged as open
- Answers are consistently solid and you're reaching into low-risk territory
- You're going in circles

Then produce the decision log.

## Output: Decision Log

```
## Grill Report — [plan/design name]

### Resolved
- **[Decision]**: [What was decided and why]
- **[Decision]**: [What was decided and why]

### Open Questions
- **[Question]**: [Why it matters, what needs to happen to resolve it]

### Flagged Concerns
- **[Concern]**: [What was said, why it's concerning, suggested next step]

### Confidence: [High | Medium | Low]
[One sentence: how solid is this plan after grilling?]
```

After presenting the log, ask: "Want to update the plan/spec with these decisions, or are there open questions you want to work through first?"
