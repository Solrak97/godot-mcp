---
name: project-startup
description: Runs a project kickoff flow when the user opens the project or starts a new conversation without a clear task. Asks what to build, how to build it, tech preferences, scope, and constraints. Use on project open, first message of the day, or when the user says "start", "what should we build", or similar.
---

# Project Startup / Kickoff

## When to run

Apply this skill when:
- The user opens the project and has not yet stated a specific task
- The user sends a vague or opening message (e.g. "let's go", "what's next", "start", "help me build")
- The user asks what to build or how to get started
- No project brief or clear goal is evident from context

Do **not** run when the user has already given a concrete task (e.g. "add a login form", "fix the bug in X").

## Kickoff flow

Run the following as a short, conversational question flow. Ask one or two questions at a time; wait for answers before continuing. Do not dump all questions at once.

### 1. What to build

- **What are we building?** (product, feature, or goal in one sentence)
- **Who is it for?** (users, audience, or "just me")
- **What problem does it solve?** (optional; if not obvious)

### 2. How to build it

- **Tech stack or constraints?** (e.g. "React + Node", "Python only", "must run on Raspberry Pi", "use what's already in the repo")
- **Any must-use or must-avoid?** (libraries, frameworks, hosting, APIs)
- **Rough scope for this session?** (e.g. "MVP only", "full feature", "spike/prototype")

### 3. Optional

- **Reference or inspiration?** (existing app, design, doc, or link)
- **Success criteria for today?** (how we know we're done for this session)

## After the flow

1. **Summarize** the answers in 2–4 sentences (the "brief").
2. **If AutoTask is available**: Create a project container in AutoTask and use it in the project definition:
   - Call `create_task` with `kind: "epic"`, title = the project name (what we're building), description = the one-sentence brief (or 2–4 sentence summary). This epic represents the project.
   - Store the returned task ID in the brief (see template below) as **AutoTask epic ID** so future work can be associated with this project.
3. **Offer to save** the brief to a file (e.g. `PROJECT_BRIEF.md` or `docs/kickoff.md`) so future conversations can use it. Include the AutoTask epic ID if you created one.
4. **Propose next step**: one concrete first task (e.g. "Set up the app shell", "Add the data model", "Create the main screen") and ask if they want to do that now.

## Tone

- Brief and friendly; avoid long paragraphs.
- Ask only what's needed to unblock building.
- If the user wants to skip questions, skip them and move on.

## Optional: PROJECT_BRIEF.md template

If the user agrees to save a brief, create or update a file with:

```markdown
# Project brief

**What we're building:** [one sentence]
**For whom:** [audience]
**Tech / constraints:** [stack, must-use, must-avoid]
**Scope this session:** [MVP / full feature / spike]
**Success for today:** [optional]
**AutoTask epic ID:** [uuid if AutoTask was used; use for linking stories to this project]

---
*Last updated: [date]. From project-startup skill.*
```

Keep the brief short so it can be reused in later chats.
