<!--
Title: conventional commit, plain language. e.g. `<fix(scope): what the user sees now>`
One problem per PR. Cleanups, refactors and second fixes go in their own PRs.
-->

## Problem

<!-- One or two sentences. What was wrong, and for whom? Link the issue if there is one. -->

## Fix

<!-- How you fixed it. Mention any surface (client, platform, entry point) it deliberately does not cover. -->

## Verification

<!--
How you checked it and what you saw. "Tests pass" is not evidence.
- UI change: before/after screenshots (drag them into the PR, don't commit them).
- Motion or timing: a short video or GIF.
- Performance: before/after numbers from a realistic run (setup, runs, results).
- Logic or data bug: the test that failed before the fix and passes after.
- Server-only change: a short runtime transcript (request → response, logs).

For UI changes, paste this table:

| Before | After |
| ------ | ----- |
|        |       |
-->

---

Written with: <!-- model + harness, e.g. "Claude Opus 5.5 (high) via Claude Code", or "human" -->
