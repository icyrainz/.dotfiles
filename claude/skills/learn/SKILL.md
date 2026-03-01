---
name: learn
description: "Analyze the current conversation to learn human preferences, improve CLAUDE.md and custom SKILL.md files, and persist insights for future sessions. Use this skill when the user says /learn, asks to 'learn from this session', 'remember my preferences', 'improve yourself from this conversation', or wants Claude to extract lessons from the current interaction. Also use when the user says 'what did you learn' or 'update your instructions based on this session'."
---

# Session Learning

Analyze the current conversation to extract preferences, patterns, and lessons. Persist them to improve future sessions by updating CLAUDE.md, relevant custom SKILL.md files, and auto-memory.

## Philosophy

Store *reasoning and patterns*, not raw transcripts. Think: "the user prefers X because Y" rather than "at message 14 the user said Z." But if a piece of knowledge is highly specific and would be lost without detail (e.g., a particular API quirk, a non-obvious config path, a naming convention), store the details.

## Step 1: Conversation Analysis

Review the full conversation history and extract:

### Preferences
- **Communication style**: Does the user prefer terse or detailed responses? Do they want explanations or just results? Do they use casual language?
- **Workflow patterns**: Do they prefer planning before coding? Do they want commits at certain points? Do they like parallel agent usage or sequential?
- **Tool preferences**: Specific tools, libraries, or approaches they favor or reject.
- **Correction patterns**: Where did the user correct you? What does that reveal about their expectations?

### Knowledge Gained
- **Domain insights**: Technical facts learned during the session that would help in future similar work.
- **Debugging patterns**: Root causes discovered, non-obvious solutions found.
- **Infrastructure/config details**: Specific paths, credentials locations, service configurations.
- **Gotchas and pitfalls**: Things that went wrong and why, so they can be avoided next time.

### Skill Usage
- **Which custom skills were used?** (Only skills the user owns — under `~/.claude/skills/` or `~/Github/.dotfiles/claude/skills-personal/`)
- **Did any skill instructions lead to mistakes or inefficiencies?**
- **Are there missing instructions that would have helped?**
- **Did the user have to repeatedly correct behavior that a skill should have prevented?**

## Step 2: Categorize and Draft Updates

Organize findings into three buckets:

### Bucket 1: CLAUDE.md Updates
For preferences and conventions that apply broadly across sessions in this project. Examples:
- "Always use fish shell syntax when writing shell examples"
- "Prefer concise responses; skip preamble"
- "Never auto-commit without asking"

Determine which CLAUDE.md to update:
- **Project CLAUDE.md** (`./CLAUDE.md` in the repo root): Project-specific conventions
- **User CLAUDE.md** (`~/.claude/CLAUDE.md`): Cross-project personal preferences

### Bucket 2: SKILL.md Updates
For improvements to specific custom skills used during the session. Examples:
- Adding a missing step to a workflow
- Correcting an outdated command or path
- Adding a gotcha/pitfall section based on what went wrong
- Improving instructions that led to mistakes

Only propose changes to custom skills the user can modify:
- `~/.claude/skills/<name>/SKILL.md`
- `~/Github/.dotfiles/claude/skills-personal/<name>/SKILL.md`

Never modify plugin-managed or marketplace skills.

### Bucket 3: Auto-Memory Updates
For session-specific knowledge that doesn't belong in CLAUDE.md or SKILL.md but should persist. Store in the project's auto-memory directory. Examples:
- Debugging insights for this specific codebase
- Architectural decisions made during the session
- Key file paths and their purposes discovered during exploration

Memory directory: find it via the auto-memory system prompt (typically `~/.claude/projects/<encoded-path>/memory/`).

## Step 3: Present to User for Approval

Present each proposed change clearly. Group by target file.

Format:

```
## Proposed Changes

### CLAUDE.md (project: <repo-name>)
**Why:** <reasoning for this change>
**Add:**
> <the line(s) to add>

### SKILL.md: <skill-name>
**Why:** <reasoning>
**Change:** <what to modify and why>

### Memory: <topic>.md
**Why:** <reasoning>
**Content:** <summary of what will be stored>
```

For each group, ask: "Should I apply these changes?"

## Step 4: Apply Approved Changes

- Use `Edit` for CLAUDE.md and SKILL.md modifications (append new conventions, don't reorganize existing content unless asked)
- Use `Write` or `Edit` for memory files
- Show a summary of what was applied after each change

## Guidelines

- **Be selective.** Not every session has learnable insights. If the conversation was straightforward with no corrections or new patterns, say so. Don't force updates.
- **Avoid duplication.** Read the target files first. Don't add what's already there.
- **Keep CLAUDE.md lean.** Each entry should be one line or a short block. Don't bloat it with paragraphs.
- **Prefer patterns over instances.** "User prefers snake_case for shell scripts" beats "user renamed setup-personal.sh variables to snake_case."
- **Respect the hierarchy.** CLAUDE.md is for instructions to Claude. Memory is for context and knowledge. SKILL.md is for skill-specific workflows. Don't mix them.
- **Never store secrets.** Don't persist API keys, passwords, or tokens. Reference their location instead (e.g., "API key is in fish extra").
