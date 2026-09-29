---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
metadata:
  origin: mattpocock/skills (MIT)
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round, then wait for the user's answers before the next round.

Ask each round **interactively with the `AskUserQuestion` tool**, so the user ticks answers instead of typing them:

- One `AskUserQuestion` question per decision. The tool takes 1-4 questions per call: if the frontier is larger, send several calls back to back without waiting for answers in between, and only then wait.
- `header`: a short title (max 12 characters). `question`: the full question, ending with `?`, with any context the user needs to decide.
- `options`: 2-4 distinct, concrete choices, each with a short `label` and a `description` explaining the trade-off. Put your **recommended answer first** and append ` (Recommended)` to its label. Use `multiSelect: true` when the choices are not mutually exclusive.
- Never add an "Other" option: the tool adds one automatically, and it opens a free-text field the user validates when done writing.
- For a truly open question with no obvious choices, don't invent fake options. Offer two honest ones, e.g. "Je réponds en texte libre" and "Pas de préférence, propose-moi quelque chose", so the user can pick "Other" to write a free answer or take a shortcut.
- If `AskUserQuestion` is unavailable, fall back to numbered text questions, each followed by your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
