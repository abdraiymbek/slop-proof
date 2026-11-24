---
name: verify-app
description: Run <Project> against isolated dev state and prove a change works by driving the real app and capturing evidence (screenshots, short video, terminal transcript, before/after numbers). Use before handing back any user-visible or behavior change, when asked to test, screenshot or demo a change, or to gather PR evidence.
---

<!--
slop-proof template, adapted from pingdotgg/t3code's test-t3-app skill
(MIT, © 2026 T3 Tools Inc.). Replace every <placeholder>, delete the sections
that don't apply, and delete these comments. If you couldn't run the steps,
replace this comment with a TODO(human) comment that says why it's untested.
-->

# Verify <Project>

Prove the outcome in the real app, not just that the tests pass.

## Safe state first

Confirm every target is disposable before you install, start or seed anything.

- State: `<isolated state dir / test DB / env file>`. Never `<live data path or prod env>`.
- External services: `<which are local, sandboxed or faked>`. If a command
  would touch a shared database, real payments, or real email or SMS, stop and
  ask.
- Data: synthetic or approved, sanitized fixtures only. Don't copy real user data.

## Start the app

<!-- Exact, tested commands. -->
1. Install if needed: `<cmd>`.
2. Start: `<dev cmd>` from your own shell and keep the session. Read the
   actual ports and URLs from its output. Reuse a server that's already
   running only after confirming it uses the isolated state above.
3. Auth in dev: `<how to log in or get a token without the user's real credentials>`.

## Seed realistic data

<!-- Command or fixture. Realistic is the point: empty states hide bugs. -->
`<seed cmd>`. <!-- For file-based stores such as SQLite: stop the server before writing fixtures directly. -->

## Drive paid dependencies cheaply

<!-- LLMs, payments, email, third-party APIs. -->
- Use `<fake / replay / sandbox provider>` when the flow doesn't depend on
  real behavior.
- When it does, use the cheapest real option (`<cheapest model / test-mode key>`).
  Never a live payment or messaging key.

## Drive the flow

<!-- Pick what fits the surface and delete the rest. -->
- **Web**: open `<url>` with the harness's browser tool if it has one.
  Otherwise use the repo's Playwright or Cypress setup, or
  `npx playwright screenshot <url> <file>.png`.
- **CLI**: run `<cmd> <args>` and keep the full transcript.
- **API**: run `curl -sS <url>` with realistic payloads, and record the request
  and response.
- **Mobile**: `<simulator/emulator command>`.

## Capture evidence

- UI: capture "before" before you edit, or from a separate checkout of the
  base branch (`git worktree add --detach <tmp dir> <base branch>`), and "after" on your
  branch, at the same viewport with the same data. Don't switch the user's
  working tree to another branch.
- Motion or timing: record a short video or GIF.
- Performance: alternate base and head runs (at least two each) on the same
  seeded data, and report the absolute numbers and the percentage change.
- Save captures outside the repo (`<e.g. /tmp/pr-evidence/>`) and attach them
  to the PR with `<the team's uploader, or hand the paths to the developer to drag in>`.
  Never commit them, and never put private captures on public image hosts.
- Keep credentials, tokens and personal data out of captures and transcripts.

## Look at it like a user

Actually look at the result. Check layout, visual hierarchy, alignment, empty
and error states, the way back out, and the end-to-end flow. Iterate on
anything that feels awkward or unfinished before you hand back.

## Clean up

Stop only the processes you started, using their captured PIDs or the
harness's own stop. Leave the server running if the user is still inspecting.
Remove any temporary worktree you created (`git worktree remove <tmp dir>`).
