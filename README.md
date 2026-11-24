# slop-proof

An agent skill that sets up any repository so AI coding agents ship focused,
verified, reviewable PRs instead of slop.

It's based on Matt Feroz's talk
[*I Maintain T3 Code. Please Stop Shipping AI Slop.*](https://youtu.be/QgnZksrabIs)
and on the real agent setup in [pingdotgg/t3code](https://github.com/pingdotgg/t3code)
(its `AGENTS.md`, `CONTRIBUTING.md` and testing docs).

## The idea

1. **Use frontier models for code that ships.** Get a second pass from a stronger model if a weaker one wrote it.
2. **Know what you want before you open a PR.** One request is one PR.
3. **Talk to stakeholders, not agents.** Agents are sycophantic and have no product taste, so humans own the direction.
4. **Give agents structure.** Write down the non-negotiables, the traps, the surfaces a change must reach, the PR rules and taste.
5. **The PR is the product.** Use a conventional title, then problem → fix → verification, and name the model and harness. Add before/after images for UI, video for motion, and numbers for performance.
6. **Verify outcomes, not mocks.** Prove it in the real app with real data, and keep tests where they catch regressions.

## What it does to a repo

1. **Audit** (read-only, `scripts/audit.sh`): stack, scripts, CI, existing agent files, PR template, tests, surfaces, danger zones.
2. **Interview** the human about product intent, non-negotiables, out-of-scope work and taste. It never invents them. Anything it can't learn becomes a `TODO(human)` marker.
3. **Write `AGENTS.md`** (and `CLAUDE.md` → `@AGENTS.md`), merging into any existing files.
4. **Write a `verify-app` skill** for the repo: run the real app on isolated state, seed data, drive it and capture evidence.
5. **Add a PR template and a testing policy.**
6. **Add a babysitting loop** for CI and review bots.
7. **Prove the setup** and report what's left.

It never commits or opens PRs unless asked. It can also just **audit** an existing setup against [`references/checklist.md`](references/checklist.md).

## Install

Claude Code (user-level, available in every repo):

```bash
git clone https://github.com/abdraiymbek/slop-proof ~/.claude/skills/slop-proof
```

Or per-project: clone it into `.claude/skills/slop-proof` (or `.agents/skills/slop-proof`) inside the repo.

Then, in any repo, run `/slop-proof` or ask "make this repo agent-ready" or "audit our AGENTS.md".

The audit script works on its own too:

```bash
bash ~/.claude/skills/slop-proof/scripts/audit.sh /path/to/repo
```

## Layout

```
SKILL.md                         # the procedure the agent follows
references/principles.md         # the concepts in depth, with T3 Code examples
references/checklist.md          # audit scorecard
templates/AGENTS.md              # agent instructions skeleton
templates/pull_request_template.md
templates/verify-skill.md        # repo-specific "prove it works" skill
templates/testing.md             # testing policy: proof by bug type
scripts/audit.sh                 # read-only repo inventory
```

## License

MIT. The quoted excerpts from T3 Code belong to their authors and are used for commentary with attribution.
