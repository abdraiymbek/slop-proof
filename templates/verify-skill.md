---
name: verify-app
description: Run <Project> against isolated dev state and prove a change works by driving the real app and capturing evidence (screenshots, short video, terminal transcript, before/after numbers). Use before handing back any user-visible or behavior change, when asked to test, screenshot or demo a change, or to gather PR evidence.
---

# Verify <Project>

Prove the outcome in the real app, not just that the tests pass. Follow the
recovery steps below before you declare a tool unavailable.

## Start the app

<!-- Exact, tested commands. Reuse a healthy server if one is already running for this task. -->
1. Install if needed: `<cmd>`.
2. Start: `<dev cmd>` from your own shell and keep the session. Read the
   actual ports and URLs from its output.
3. State: use `<isolated state dir / test DB / env file>`. Never use
   `<live data path>`.
4. Auth in dev: `<how to log in or get a token without the user's real credentials>`.

## Seed realistic data

<!-- Command or fixture. Realistic is the point: empty states hide bugs. -->
`<seed cmd>`. Stop the server before writing fixtures directly.

## Drive paid dependencies cheaply

<!-- LLMs, payments, email, third-party APIs. -->
- Use `<fake / replay / sandbox provider>` when the flow doesn't depend on
  real behavior.
- When it does, use the cheapest real option (`<cheapest model / test-mode key>`).

## Drive the flow

<!-- Pick what fits the surface and delete the rest. -->
- **Web**: open `<url>` with the harness's browser tool. If no tab exists, open
  one. Opening a tab needs no user action.
- **CLI**: run `<cmd> <args>` and keep the full transcript.
- **API**: run `curl -sS <url>` with realistic payloads, and record the request
  and response.
- **Mobile**: `<simulator/emulator command>`.

## Capture evidence

- UI: take a before screenshot on the base branch and an after screenshot on
  yours, at the same viewport and with the same data.
- Motion or timing: record a short video or GIF.
- Performance: alternate base and head runs (at least two each) on the same
  seeded data, and report the absolute numbers and the percentage change.
- Upload the evidence to the PR with `<upload method, e.g. drag into GitHub or gh CLI>`. Never commit it.
- Keep credentials and personal data out of captures.

## Look at it like a user

Actually look at the result. Check layout, visual hierarchy, alignment, empty
and error states, the way back out, and the end-to-end flow. Iterate on
anything that feels awkward or unfinished before you hand back.

## Clean up

Stop only the processes you started, using their captured PIDs or the
harness's own stop. Leave the server running if the user is still inspecting.
