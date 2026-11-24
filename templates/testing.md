# Testing

Tests exist to catch regressions. Proof that a change works comes from the
real outcome, not from a test that re-checks a mock.

## What to test

- Test behavior that can break: core logic and state machines, protocol and
  format translation, auth and permission guards, persistence and migrations,
  parsing of external input, race fixes, and whatever logic a bug fix changed.
- Don't test what types already guarantee, trivial logic, copy text, smoke
  runs, mock-call mirrors ("expect fn toHaveBeenCalledWith…" with nothing
  else), callback wiring, or props rendered to static markup.
- Extend before you add. If an existing test or table covers the behavior,
  add a row or an assertion there.
- Test at one layer: the lowest one that fails on `main`. Don't repeat the
  case in wrappers, at each call site, or in per-platform copies.
- Prefer real dependencies (a real DB in a temp dir, a real local server, a
  recorded fixture) to mocks. Mock only what is slow, paid or
  nondeterministic, at the boundary.

## Proof depends on the bug

| Change | Proof |
| --- | --- |
| Logic, data, state or protocol bug | A test that fails on `main` for that reason, then the fix |
| Purely visual (spacing, color, alignment, layout shift) | Before/after captures and **no** test |
| Motion or timing | A short video |
| Performance | Before/after numbers from a realistic, seeded run (alternate base and head runs) |
| Server-only, nothing visible | The test plus a short runtime transcript |
| New feature | A walkthrough in the real app (captures or video), plus tests for the logic that can break |

"Tests pass" is not evidence. The PR says how you checked it and what you saw.

## Waiting and flakiness

- Never wait with sleeps, polling loops or wall-clock deltas. Await the event,
  promise, queue or persisted record that marks the milestone.
- No per-test timeouts and no retries. Fix flaky tests instead of retrying
  them.
- A skipped test needs a tracking issue on the line above it.

## In review

Ask for a missing test only when it would catch a real regression. Flag new
tests that break these rules, and name the fix: fold it into an existing case,
delete it, keep one layer, or replace it with a capture.
