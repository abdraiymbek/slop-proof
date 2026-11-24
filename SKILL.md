---
name: slop-proof
description: Set up any repository so AI coding agents ship focused, verified, reviewable work instead of "AI slop". Explains the anti-slop philosophy (human-owned intent, no sycophancy, agent structure, PR evidence, outcome verification over mock-based unit tests) and installs it into a repo as an AGENTS.md/CLAUDE.md, a PR template, a repo-specific "verify the app" skill, a PR babysitting loop and a testing policy. Use when the user asks to make a repo AI-ready, agent-ready or ship-ready, stop agents shipping slop, set up AGENTS.md or CLAUDE.md, write agent PR rules, or asks how to get better PRs out of coding agents. Also use to audit an existing agent setup against these principles.
---

# slop-proof

Make a repository a place where an agent's PR can be trusted after a skim: one
focused change, a plain-language title, a body that says what was wrong and how
it was fixed, proof it works (images, video, numbers), and the model that did
the work.

Based on Matt Feroz (T3 Code maintainer), *"I Maintain T3 Code. Please Stop
Shipping AI Slop."* (2026-11), and the real `AGENTS.md`, `CONTRIBUTING.md` and
testing docs from `pingdotgg/t3code`. The full concept notes are in
[references/principles.md](references/principles.md). If a local
`references/transcript.md` exists, it holds the raw video transcript. It's not
distributed with the skill, so watch https://youtu.be/QgnZksrabIs instead. Read them once if you need
to explain the ideas to the user, not to run the setup.

## The idea in six lines

1. **Use a frontier model on code that ships.** Weaker models make more slop at
   scale. If a weaker model wrote it, get a second pass from a stronger one.
2. **Know what you want before you open a PR.** Be decisive. One request is one
   PR, so any piece can be reverted without blowing up a branch.
3. **Talk to stakeholders, not agents.** Agents are sycophantic and have no
   product taste. Product direction comes from humans and users. The agent
   carries out *your* intent ("an astral projection of yourself").
4. **Give agents structure.** Write down *why* the work matters and *how* to do
   it well: product non-negotiables, taste, traps, PR rules, and tools that make
   the task easy. Don't spend it on response formatting.
5. **The PR is the product now.** Reviewers read the title, the body and the
   evidence, not every line. Conventional title, problem → fix, model + harness,
   before/after captures, video for motion, real numbers for performance.
6. **Verify outcomes, not mocks.** Unit tests on mocked data prove little. Prove
   the result against the real app, real APIs and real data, then keep a test
   only where it would catch a regression. If spending more tokens on
   verification gets a result you trust, spend them.

## Setting up a repo

Work through the phases in order. Each phase writes files only after you've
seen what's already there. Never overwrite a user's existing agent
instructions: merge into them and show the diff.

### Phase 0: Audit (no writes)

Run the bundled audit from the repo root:

```bash
bash ~/.claude/skills/slop-proof/scripts/audit.sh .
```

It reports the stack, package manager, runnable scripts, CI, existing agent
files (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, `.github/copilot-instructions.md`,
`.claude/skills`, `.agents/skills`), the PR template, CONTRIBUTING, test layout,
UI surfaces, the git forge, and how many recent commits already use
conventional commits. Then read the existing agent files, the README, the CI
workflows and the main entry points yourself. The script finds files. It does
not understand them.

From the audit, work out:
- **Surfaces**: web, desktop, mobile, CLI, API, library, docs site. Each is a
  place a change can be "done" in one spot and missing in another.
- **How to run it**: the exact dev command, ports, seed data, env vars and auth.
- **How to check it**: the fastest *scoped* check (lint, typecheck or tests for
  changed files), and which checks CI owns.
- **Dangerous ground**: live databases, prod credentials, shared dev servers,
  generated files, vendored code, anything an agent could break while working.

### Phase 1: Interview the human (intent is not yours to invent)

The whole point of the philosophy is that product direction comes from people.
Don't make up a product vision, non-negotiables or taste. Ask the user, in one
batch and briefly, for anything the repo doesn't already answer:

1. **What is this, and for whom?** (one or two sentences)
2. **Non-negotiables.** What must every change protect? (for example
   performance, offline support, accessibility, privacy, backwards-compatible
   API, "works on all three clients")
3. **Out of scope.** What PRs should agents never open? (for example UI
   overhauls, new dependencies without asking, new providers)
4. **Taste.** Two to five opinions about how code here should look. (for
   example "no `any`", "complexity at the edges, core stays pure", "default to
   no comments")
5. **Evidence bar.** Does a UI change need before/after captures, and do perf
   changes need numbers? (the default is yes to both)
6. **Model policy.** Should PRs name the model and harness? (the default is
   yes) Are any models disallowed?

If the session can't ask (it's non-interactive), fill what the repo makes
obvious and leave the rest as `<!-- TODO(human): ... -->` markers. Tell the
user exactly which markers need them. A vague placeholder is better than an
invented value.

### Phase 2: Write the agent instructions

Create or merge `AGENTS.md` at the repo root from
[templates/AGENTS.md](templates/AGENTS.md). It's the one source of truth that
Codex, Cursor, Claude Code and others read. For Claude Code, make sure
`CLAUDE.md` exists and contains the line `@AGENTS.md` (plus any Claude-only
notes). If the repo already has a long `CLAUDE.md` and no `AGENTS.md`, keep
`CLAUDE.md` as the source of truth and merge the sections into it instead.

Fill every section from the audit and the interview:
- **What this is and what we never compromise on**, taken from the interview.
- **Ways to hurt yourself**: the concrete traps from the Phase 0 "dangerous
  ground" list, each with the safe alternative. Only real ones. If there are
  none, delete the section.
- **Hit every surface**: the checklist of places a change must reach (entry
  points, clients, platforms, API contracts, i18n, docs, reverse states).
- **Verifying**: exact commands. Give the scoped check to run before pushing
  and say "don't run the repo-wide suite, CI owns it" if CI really does. Name
  the verify skill from Phase 3.
- **Pull requests**: the PR block. Keep it nearly verbatim from the template.
  It's the highest-value text in the setup.
- **Taste**: the user's opinions, and nothing generic.

Keep it short. Every line should change what an agent does. Cut anything an
agent could learn by reading the code. Prefer "do X, not Y, because Z" over
adjectives.

### Phase 3: Give the agent a way to see its work

Slop survives when the agent never looks at the result. Write a repo-specific
verify skill from [templates/verify-skill.md](templates/verify-skill.md) into
`.claude/skills/verify-app/SKILL.md`. Use `.agents/skills/verify-app/` instead
if the repo already uses that folder. Fill in:
- how to start the app against **isolated** state (never the user's live data)
- how to seed realistic data, and how to get past auth in dev
- how to drive it: a browser automation tool, a CLI invocation, `curl` against
  the API, or a simulator for mobile
- how to capture evidence (screenshot, short video or GIF, a terminal
  transcript, before/after numbers) and where to upload it (the PR, never a
  commit)
- how to drive any paid external dependency (LLM, payments, email) cheaply:
  a replay or fake provider, the cheapest model, or a sandbox account

Run the steps yourself once before writing them down. A verify skill that
doesn't work teaches the agent to skip verification.

### Phase 4: PR template and testing policy

- Write `.github/pull_request_template.md` from
  [templates/pull_request_template.md](templates/pull_request_template.md).
  Use the forge's own path for GitLab or Gitea. Merge it into any existing
  template rather than replacing it.
- Add the testing policy from [templates/testing.md](templates/testing.md) as
  `docs/testing.md`, or as a section of AGENTS.md if the repo has no docs
  folder. Adapt the examples to the repo's test framework.
- If the repo takes outside contributions, offer to add the "Show that it
  works" and "One problem per PR" rules to `CONTRIBUTING.md`, which is
  user-facing. Ask before changing contributor policy.

### Phase 5: Babysitting loop (only if there are review bots or CI)

If CI or review bots (CodeRabbit, Greptile, Copilot review, Claude review) run
on PRs, add the babysitting rules to AGENTS.md (they're already in the PR
block of the template). The loop is: open the PR, wait on checks and reviews
using the harness's PR-watch tool if it has one, otherwise one blocking
`gh pr checks <n> --watch`, and never sleep-poll. Check every bot finding
against the source. Fix the real ones and dismiss false positives with a
written reason. Stay quiet when nothing is new. Stop when the bots are green
on the latest commit.

### Phase 6: Prove the setup

1. Re-run the audit and confirm every gap it flagged is closed or deliberately
   left open.
2. Run the verify skill's start-and-capture steps for real, once.
3. Show the user a one-screen summary: files created or merged, open
   `TODO(human)` markers, and the commands an agent will now use.
4. Don't commit or open a PR unless the user asks. If they do, the setup PR
   itself follows the rules: `chore: add agent guidelines (AGENTS.md, PR
   template, verify skill)`, with the body ending in the model and harness.

## Auditing an existing setup

When the user only wants a review, run Phase 0 and score the repo against the
checklist in [references/checklist.md](references/checklist.md). Report it as
a short table (item, status, the one-line fix) with the three highest-impact
fixes first. Don't write files unless asked.

## Rules for you while running this skill

- Merge into existing files and never clobber them. Show diffs for edits to
  files you didn't create.
- Don't invent product facts, commands or ports. Run or read them, or mark a
  TODO.
- Write instructions that are specific to the repo. A generic line like "write
  clean, maintainable code" is slop in its own right, so delete it.
- Keep AGENTS.md under about 200 lines. Push area-specific depth into linked
  docs ("read X before changing Y") instead of growing the root file.
- Don't commit plans, research notes or scratch files to the repo.
