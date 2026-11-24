# Slop-proof checklist

Score each item ✅ present and specific, 🟡 present but generic or stale, or ❌ missing.

## Intent (human-owned)
- [ ] Agent instructions say what the product is and who it's for.
- [ ] Non-negotiables are written down (performance, surfaces, privacy, and so on).
- [ ] Out-of-scope work is named (what agents should never open a PR for).
- [ ] There's a release valve: "If a rule fights the task, say so and get human sign-off."

## Structure
- [ ] `AGENTS.md` exists. `CLAUDE.md` imports it (`@AGENTS.md`) or is the single source of truth.
- [ ] Real traps ("ways to hurt yourself") are listed, each with the safe alternative.
- [ ] A "hit every surface" checklist matches the repo's real surfaces.
- [ ] Exact run, seed and dev-auth commands are given, with isolated state.
- [ ] A read-first table points to area docs (for larger repos).
- [ ] Taste lines are specific and checkable, and lint enforces them where possible.
- [ ] There's no generic filler ("write clean code", "follow best practices").
- [ ] The root file is roughly 200 lines or less.

## PRs
- [ ] "Never open a PR unless asked."
- [ ] Conventional commit titles in plain language.
- [ ] The body has problem → fix → verification, and ends with the model and harness.
- [ ] UI changes need before/after images, motion needs video, and performance needs numbers.
- [ ] Evidence is uploaded to the PR, never committed.
- [ ] One request is one PR.
- [ ] A PR template enforces the above.
- [ ] Babysitting rules are present if CI or review bots exist (watch without polling, verify findings, dismiss with reasons, stop on green).

## Verification
- [ ] A scoped pre-push check is named, and it says CI owns the full suite.
- [ ] A verify skill exists that starts the real app on isolated state, seeds data, drives it and captures evidence.
- [ ] Paid dependencies can be driven cheaply (a fake or replay provider, the cheapest model, a sandbox).
- [ ] The testing policy covers what to test, proof by bug type, no sleeps or retries, and "tests pass is not evidence".
- [ ] CI runs on PRs.

## Hygiene
- [ ] Docs policy: document decisions, constraints and traps, not narration that drifts.
- [ ] No plans or scratch files are committed.
- [ ] CONTRIBUTING (if the repo takes outside PRs) has "show that it works" and "one problem per PR".
