---
name: slop-proof
description: Set up a repository so AI coding agents open focused, verified, reviewable PRs instead of AI slop. Audits the repo, interviews the maintainer, then writes or merges AGENTS.md (and CLAUDE.md), a PR template, a repo-specific verify-the-app skill and a testing policy. Use when the user wants a repo made agent-ready, wants rules for agent PRs or AI contributions, complains that agents' PRs are sloppy, oversized or unverified, asks to audit an existing agent setup, or asks how to get better PRs out of coding agents. Not for writing, reviewing or shipping a single PR.
---

# slop-proof

Make a repository a place where an agent's PR can be trusted after a skim: one
focused change, a plain-language title, a body that says what was wrong and how
it was fixed, proof it works (images, video, numbers), and the model that did
the work.

Based on Matt Feroz's talk *"I Maintain T3 Code. Please Stop Shipping AI
Slop."* (November 2026, https://youtu.be/QgnZksrabIs) and on the agent setup in
`pingdotgg/t3code`. Concept notes with sources are in
[references/principles.md](references/principles.md). Read them only when you
need to explain the ideas, not to run the setup.

## Pick the mode

- **Explain.** The user asks about the ideas or how to get better PRs from
  agents. Answer from the six lines below and `references/principles.md`.
  Don't run the audit or write files.
- **Audit.** The user wants their setup reviewed. See "Auditing an existing
  setup". Read-only.
- **Set up.** The user wants the repo made agent-ready. Run every phase.
- **One piece.** The user asked for one part (only a PR template, only
  AGENTS.md). Run Phase 0, ask only the questions that piece needs, write that
  piece, then offer the rest in one line.

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
seen what's already there, and follows "Rules for you" at the end.

### Phase 0: Audit (no writes)

The audit script is `scripts/audit.sh` in this skill's folder (the folder
that holds this SKILL.md, wherever it was installed). Run it by absolute path
from the repo root:

```bash
bash "<this skill's folder>/scripts/audit.sh" .
```

It reports the stack, package manager, runnable scripts, CI, existing agent
files (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, `.github/copilot-instructions.md`,
`.claude/skills`, `.agents/skills`), the PR template, CONTRIBUTING, test layout,
UI surfaces, the git forge, and how many recent commits already use
conventional commits. Then read the existing agent files, the README, the CI
workflows and the main entry points yourself. The script finds files. It does
not understand them. A ❌ is something to ask about, not a task: don't create
files just to clear it. If it warns you're not at the repo root, re-run it from
the root unless the user wants only that subtree.

From the audit, work out:
- **Surfaces**: web, desktop, mobile, CLI, API, library, docs site. Each is a
  place a change can be "done" in one spot and missing in another.
- **How to run it**: the exact dev command, ports, seed data, env vars and auth.
- **How to check it**: the fastest *scoped* check (lint, typecheck or tests for
  changed files), and which checks CI owns.
- **Dangerous ground**: live databases, prod credentials, shared dev servers,
  generated files, vendored code, anything an agent could break while working.
  Read `.env.example` (or list only the key names in `.env*` files) and the dev
  and seed scripts to see what they point at. Never read or print secret
  values.

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
   no comments") The template also has a short "how we build" note (simple
   systems, fight scope creep): keep, edit or drop it?
5. **Evidence bar.** Does a UI change need before/after captures, and do perf
   changes need numbers? (the default is yes to both)
6. **Agents and models.** Which coding agents does the team use (Claude Code,
   Codex, Cursor, others)? Should PRs name the model and harness? (the default
   is yes) Are any models disallowed?
7. **Testing policy.** Is there one already? If not, may the agent adopt the
   default in `templates/testing.md`? (one-line summary: prove by real
   outcome, one test layer, no retries, visual changes proven by captures)
8. **Safe dev state.** Does the default dev config touch anything live (a
   shared database, real payments, email or SMS)? Ask only if Phase 0 didn't
   make it obvious.

If the session can't ask (it's non-interactive), fill what the repo makes
obvious and leave the rest as `<!-- TODO(human): ... -->` markers. Tell the
user exactly which markers need them. A vague placeholder is better than an
invented value.

### Phase 2: Write the agent instructions

Create or merge `AGENTS.md` at the repo root from
[templates/AGENTS.template.md](templates/AGENTS.template.md). It's the file
Codex, Cursor and most other agents read. For Claude Code, `CLAUDE.md` must
contain the line `@AGENTS.md` (plus any Claude-only notes), or be a symlink to
`AGENTS.md`.

- If the repo has only a `CLAUDE.md`, ask whether to move the shared content
  into `AGENTS.md` so other agents can read it too. If the user says no, merge
  into `CLAUDE.md` instead.
- Leave other tools' files (`.cursor/rules`, `copilot-instructions.md`,
  `GEMINI.md`) alone. List any rule in them that conflicts with the new file.
- Check for nested `AGENTS.md`/`CLAUDE.md` files (the audit lists them) and
  don't contradict them.

Whichever file you end up writing to is "the instructions file". Where later
phases say AGENTS.md, they mean that file.

Fill the sections that apply, from the audit and the interview:
- **What this is, what we never compromise on, and what's out of scope**,
  taken from the interview.
- **Ways to hurt yourself**: the concrete traps from the Phase 0 "dangerous
  ground" list, each with the safe alternative. Only real ones. If there are
  none, delete the section.
- **Hit every surface**: the checklist of places a change must reach (entry
  points, clients, platforms, API contracts, i18n, docs, reverse states).
- **Verifying**: exact commands. Give the scoped check to run before pushing
  and say "don't run the repo-wide suite, CI owns it" if CI really does. Name
  the verify skill from Phase 3.
- **Pull requests**: the PR block. Keep it nearly verbatim from the template.
  It's the highest-value text in the setup. Adapt the forge CLI, the example
  title and the evidence upload method to this repo.
- **Babysitting**: keep that bullet only if CI or review bots run on PRs. Use
  the harness's PR-watch tool if it has one, otherwise one blocking CI watch
  from the forge's CLI (`gh pr checks <n> --watch` on GitHub). CI finishing
  doesn't mean reviews are in: name the bots expected on each PR, and treat
  one as done only when it has posted on the latest commit. If you can't see
  that, report the review as pending, not passed.
- **Taste**: the user's opinions, and nothing generic.

Keep it short. Every line should change what an agent does. Cut anything an
agent could learn by reading the code. Prefer "do X, not Y, because Z" over
adjectives. Delete any section with nothing repo-specific in it. A small
library may need 30 lines.

### Phase 3: Give the agent a way to see its work

Slop survives when the agent never looks at the result. Write a repo-specific
verify skill from [templates/verify-skill.md](templates/verify-skill.md).

**Safety first.** Before you install, start or seed anything, confirm that the
database and storage it touches are disposable (local isn't enough: a local
SQLite file can be someone's real data), that credentials are test ones, and
that external services are sandboxed or faked. If anything might be live, or
you're unsure, ask the user. If nobody confirms, don't run it: write the skill
untested (below). Never run seed, migrate or reset commands against a target
nobody has confirmed is disposable.

**Where it goes.** Use the skills folder the repo already has. Otherwise use
`.agents/skills/verify-app/SKILL.md` (Codex and most other harnesses) or
`.claude/skills/verify-app/SKILL.md` (Claude Code), depending on what the team
uses. If the team uses both kinds, write it once and link it from AGENTS.md by
path, so every agent can find it.

**Scale it to the repo.** A library or small CLI with no running app doesn't
need a skill. Put its one real-outcome check (run the CLI on a sample input,
import the package from a scratch script) in AGENTS.md's Verifying section
instead.

Fill in:
- how to start the app against **isolated** state (never the user's live data)
- how to seed realistic data, and how to get past auth in dev
- how to drive it: a browser automation tool, a CLI invocation, `curl` against
  the API, or a simulator for mobile
- how to capture evidence (screenshot, short video or GIF, a terminal
  transcript, before/after numbers) and how it reaches the PR: the team's
  uploader, or save it outside the repo and hand the paths to the human to
  attach. Never commit it, and never put private captures on public image
  hosts. (`gh` can't upload PR images.)
- how to drive any paid external dependency (LLM, payments, email) cheaply:
  a replay or fake provider, the cheapest model, or a sandbox account

Run the steps yourself once before writing them down. A verify skill that
doesn't work teaches the agent to skip verification. If you can't run them
(missing secrets, no browser tool, non-interactive session, or nobody has
confirmed the state is safe), write the skill anyway with
`<!-- TODO(human): untested because … -->` at the top and say so in the
summary. Don't present untested commands as tested.

### Phase 4: PR template and testing policy

- If the repo uses PRs on a forge, write the PR template from
  [templates/pull_request_template.md](templates/pull_request_template.md):
  `.github/pull_request_template.md` (GitHub),
  `.gitlab/merge_request_templates/Default.md` (GitLab) or
  `.gitea/pull_request_template.md` (Gitea, Forgejo), or the forge's
  documented location for others such as Bitbucket. Merge it into any
  existing template rather than replacing it.
- Add the testing policy from [templates/testing.md](templates/testing.md)
  only if the user said yes in Phase 1. An existing policy wins: add only what
  it lacks. Put it in `docs/testing.md`, or condense it to about ten lines in
  AGENTS.md if the repo has no docs folder. Adapt the examples to the repo's
  test framework. It governs new tests. Don't rewrite existing ones.
- If the repo takes outside contributions, offer to add the "Show that it
  works" and "One problem per PR" rules to `CONTRIBUTING.md`, which is
  user-facing. Ask before changing contributor policy.

### Phase 5: Prove the setup

1. Re-run the audit and confirm the gaps you meant to close are closed. A ❌
   on something the user chose not to add is fine.
2. Run the verify skill end to end once, from the written instructions. Skip
   this if you already ran the exact final commands in Phase 3, or if the
   skill is marked untested.
3. Show the user a one-screen summary: files created or merged, open
   `TODO(human)` markers, and the commands an agent will now use.
4. Don't commit or open a PR unless the user asks. If they do, the setup PR
   itself follows the rules: `chore: add agent guidelines (AGENTS.md, PR
   template, verify skill)`, with the body ending in the model and harness.

## Auditing an existing setup

When the user only wants a review, run Phase 0 and score the repo against the
checklist in [references/checklist.md](references/checklist.md). Mark items
that don't fit the repo as N/A, and items you couldn't check as unverified.
Report it as a short table (item, status, the one-line fix) with the three
highest-impact fixes first. Don't write files unless asked.

## Rules for you while running this skill

- In a file you didn't create, add the missing sections. Don't reword or
  delete what's there, and show the diff. If the file is untracked or has
  uncommitted changes, git can't undo your edit, so show the proposed change
  and get a yes first.
- The templates are starting points, not content. Replace every `<…>` and
  "e.g." with something true for this repo, or delete it.
- Don't invent product facts, commands or ports. Run or read them, or mark a
  TODO.
- Write instructions that are specific to the repo. A generic line like "write
  clean, maintainable code" is slop in its own right, so delete it.
- Keep what you add to AGENTS.md under about 200 lines. Push area-specific
  depth into linked docs ("read X before changing Y") instead of growing the
  root file. If the existing file is already longer, suggest cuts, don't make
  them.
- Don't commit plans, research notes or scratch files to the repo.
