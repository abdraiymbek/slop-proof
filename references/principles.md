# The anti-slop principles, in full

Source: Matt Feroz, *"I Maintain T3 Code. Please Stop Shipping AI Slop."*
(YouTube, November 2026, 20 min), and the T3 Code repo (`pingdotgg/t3code`):
`AGENTS.md`, `CONTRIBUTING.md`, `docs/internals/15_testing.md` and
`.agents/skills/test-t3-app`.

His thesis is that most AI slop isn't the model's fault. People don't set up
their development environment so agents *can* produce valuable PRs. A
maintainer who reviews at scale can tell the difference right away.

---

## 1. Frontier models are required for code that ships

- If code is going to millions of users, use the frontier model (he uses
  Opus 5.5 on high). A PR from a previous-generation or weaker open model
  should at least get a review from a different, stronger model.
- Frontier access is heavily subsidised. A $20 to $200 plan buys compute
  worth far more than that, and free-credit programs exist.
- A frontier model is not a cure. Frontier models still produce slop, just
  *less of it at scale*.

**In a repo:** the PR body ends with the model and harness that did the work.
That's a record you can use later to see which models do well in *this*
codebase. CONTRIBUTING can name models the project won't accept.

## 2. Know what you want before you make a PR

- Software has endless branching paths (stack, UI, structure). You don't
  need the whole map, but you do need a direction, and you need to be
  decisive.
- Don't be wishy-washy and leave half-changes behind. A PR should be focused
  and you should know exactly what it changes.
- Focused PRs make the history navigable. You can revert, go forward or pick
  one piece without blowing up a whole branch.
- That intuition comes from shipping a lot and thinking hard about what the
  software should become.

**In a repo** (abridged from T3's AGENTS.md): "One request is one PR. Split only when asked." "Fix one
problem. Include every change that fix needs (contracts, server, clients,
tests, docs). Cleanup, refactors and a second fix go in their own PRs."

## 3. Talk to stakeholders, not agents

- Agents are sycophantic. "That's the greatest idea ever." You agree, and you
  end up making decisions that aren't really yours.
- An agent only knows how things were done before. It has no foresight about
  what *your* product should be. No agent would have proposed T3 Code's
  multi-harness, multi-machine design. It would more likely propose a
  500k-line PR for a feature nobody wanted.
- Agents have no human taste. A designer's point: a bad UI doesn't mean a bad
  product. Something simple and intuitive that "feels right for a human"
  beats something theoretically optimal.
- Get feedback from people. Show the work to real users. Say "no" more often,
  and don't accept the agent's first idea.
- "Stop giving your agents agency over your own thoughts. Use your agent as
  an astral projection of yourself."

**In a repo:** write the product's non-negotiables and the maintainers' taste
into AGENTS.md, so the agent defends *your* intent rather than the average of
its training data. For example, T3's "A note from Theo": *ambitious ideas,
simple systems, software that feels obvious. Don't preserve complexity just
because it exists. Don't introduce machinery because it looks impressive.
"Measure twice, cut once" and "yagni". Fight scope creep.* Also add a release
valve: *"If a rule here fights the task in front of you, say so loudly and get
a human sign-off before breaking it."*

## 4. Give your agents structure

- Skip the debates over harnesses and formatting preferences. Agents need to
  understand *why* they're doing the task, plus the tools that make that
  specific task as easy as possible.
- Structure should come from points 2 and 3: what you want, and what your
  stakeholders need.
- The single most valuable piece is the **pull request block** in T3's
  AGENTS.md. He says it alone prevents "95% of your agents producing slop".
  Abridged, with the harness-specific watch tool generalized:

  > - Never make a PR unless the developer explicitly asks you to do so.
  > - Conventional commit titles, plain language: `fix(web): new threads no longer spike CPU`.
  > - Body: the problem in a sentence or two, then how you fixed it. End with the model and harness that did the work.
  > - UI changes need before/after images; motion or timing needs a short video. Upload PR evidence to GitHub; never commit PR-only screenshots or assets.
  > - One request is one PR. Split only when asked.
  > - When babysitting: watch the pull request and end your turn. Do not poll or sleep. Verify each bot finding against the source, fix real ones, dismiss false positives with a written reason. Stay quiet when nothing is new; stop when bots are green on the latest commit.

- The rest of T3's AGENTS.md shows other kinds of structure worth copying:
  - **What makes the product special**: the non-negotiables (open, performant,
    remote-ready, multi-surface).
  - **The three ways to hurt yourself**: concrete traps (killing processes by
    pattern, writing to the live install, baking in origins), each with the
    safe alternative.
  - **Hit every surface**: "The most common defect in this repo is a change
    that works on the path you tested and is missing everywhere else." A
    checklist of entry points, clients, providers, contracts, reverse states,
    connection modes, languages and docs.
  - **Verifying**: the scoped pre-push check. Don't run repo-wide checks
    because CI owns the full suite.
  - **Read-first table**: "Read the matching doc before changing code in that
    area; code review enforces them."
  - **Documentation discipline**: don't document what the code already shows.
    Anything that can drift will drift.
  - **Taste**: short, specific, enforced by lint where possible.

## 5. The currency of software engineering changed: the PR is the product

- "It's not so much about the code anymore. It's about the idea of what
  you're pushing and how you're moving the software forward."
- A maintainer can't read every line, but they can read the PR body.
- **UI changes need before/after images. Motion needs video.** Without them,
  a reviewer has to pull the branch down, run it and figure it out. With
  them, they understand the change at a glance. Agents can spin up the dev
  environment, reproduce the experience and capture it, so it's "not that big
  of an ask".
- Good merged PRs he points to: `fix(web): settings description uses the
  full row and stays in two lines`, and `fix(server): wait for automatic
  follow-ups before settling threads`. Each has a small diff, a clear title
  and a trusted author. There's also a voice-settings PR with before/after
  pairs for every changed screen plus a walkthrough video.

## 6. Verify your work, and that doesn't mean unit tests

- "The era of the unit test is kind of over" in the sense that a unit test
  over *mocked* data proves that the code passes data between two functions.
  It doesn't prove the outcome. Agents lean on unit tests because they're the
  easiest way to make "correct" visible.
- Verify the *outcome*: real APIs, a live dev server, real latency numbers,
  real processes. "You need valid data, and that comes from real
  evaluations."
- His example is a perf PR, "server cache PR lookups no longer start git
  processes". Its body ran a benchmark on a dev server seeded from a real
  install (Windows, 10 minutes, 60 threads, two alternating runs each of main
  and PR) and reported 59% less CPU, 67% fewer processes, and so on. The
  reviewer understands the improvement from the numbers alone. The tests it
  did add were integration-style, not mock-based unit tests.
- His nuance: tests exist to **catch regressions**. Keep the ones that would
  catch a real one, and skip the hundreds that re-verify mocks.
- Tokens: "If you can solve a problem by spending more tokens, spend those
  tokens," as long as the outcome is reachable and valuable. Verification is
  where extra tokens pay off.

**T3's written testing policy** (`docs/internals/15_testing.md`) makes this
precise:
- Test behavior that can break (orchestration, protocol translation, auth
  guards, persistence and migrations, parsing, race fixes, the logic a bug fix
  changed). Leave out tests for what types already guarantee, trivial logic,
  copy text, smoke runs, mock-call mirrors and props rendered to static markup.
- Extend an existing test or table before adding a new one. Test at one
  layer: the lowest one that fails on `main`.
- **The proof depends on the bug.** Logic, data, state and protocol bugs get a
  failing test first, then the fix. Purely visual bugs get before/after
  captures and *no* test. A server-only fix with no visible surface gets the
  test plus a short runtime transcript.
- No sleeps, polling or timeouts in tests. Await the actual event. Fix flaky
  tests; don't retry them.
- Real-app "scenarios" exist that pass only if the test **fails on base and
  passes on head**, with base/head screenshots paired automatically.
- CONTRIBUTING (abridged): *"Say how you found the bug, how you checked it, and what you
  saw. 'Tests pass' is not evidence."*

## The verify skill pattern (from `test-t3-app`)

- Reuse a healthy dev server, or start one from your own shell and keep it.
  Always use **isolated** state, never the user's real database.
- Seed meaningful data, and drive paid dependencies for free (T3 has a
  `Replay (dev)` provider that replays recorded agent turns). Otherwise use
  the cheapest real model.
- Use the harness's browser panel and follow the recovery steps before
  declaring it unavailable.
- "Actually look at the rendered result and think as a user using the
  feature. Check layout, visual hierarchy, alignment and the end-to-end flow,
  and iterate on anything that feels awkward until you're satisfied before
  handing back."
- Stop only the processes you started. Keep credentials out of screenshots.
