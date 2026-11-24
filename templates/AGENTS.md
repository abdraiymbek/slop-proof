# <Project name>

<!-- One or two sentences: what this is and who uses it. From the human, not invented. -->
<Project> is <what it is> for <who>. <The one thing users love about it>.

## What we never compromise on

<!-- TODO(human): 2–5 non-negotiables. Each one is a short heading and a sentence on what it means for a change. Examples: -->
### 1. <Non-negotiable, e.g. "Performance">
<What every change must respect, e.g. "We audit for regressions caused by X, Y, Z. Consider performance impact in every change.">

### 2. <e.g. "Works on every surface">
<e.g. "Web, desktop and mobile all ship every feature where reasonable.">

## How we build

<!-- TODO(human): the maintainers' voice, 3–6 lines. Keep the scope-creep lines unless the human objects. -->
Prefer simple systems and software that feels obvious. Don't preserve
complexity just because it exists, and don't add machinery because it looks
impressive. Understand the real constraint, then build the smallest model that
makes the correct behavior unsurprising. Fight scope creep and honor the
developer's intent minimally and realistically.

These are good defaults, not hard rules, and the developer's preferences
override them. If a rule here fights the task in front of you, say so loudly
and get a human sign-off before breaking it.

## Ways to hurt yourself

<!-- Only real traps found in the audit, each with the safe alternative. Delete the section if there are none. -->
1. **<Trap>.** Never <dangerous action>. <Why>. Instead, <safe alternative>.
2. **Writing to live data.** `<path or DB>` is the developer's real data, in use while you work. Reading or copying from it is fine. Never point a dev server at it or clean it up.
3. **Killing processes by pattern.** Kill only a PID you captured when you spawned it.

## Hit every surface

The most common defect is a change that works on the path you tested and is
missing everywhere else. Before you call the work done, walk this list and say
which entries applied:

- **Entry points.** <e.g. main view, settings, command palette, keyboard shortcuts, CLI flags>
- **Clients/platforms.** <e.g. web, desktop, mobile, and where shared logic lives>
- **Contracts.** <e.g. "API and wire changes go in `packages/contracts` so every consumer follows.">
- **Reverse states.** Every way in needs a way out and a way to see it. A one-way door is a bug.
- **Languages.** <e.g. i18n files and the command that regenerates or checks them, or delete this line>
- **Docs.** Check whether the change makes existing guidance inaccurate.

## Running it

- Install: `<cmd>`
- Dev: `<cmd>` (ports: <ports>, read them from the output rather than assuming)
- Seed or test data: `<cmd or path>`. Use isolated state, never live data.
- Start dev servers from your own shell so they exit with your session. Don't detach them unless asked.

## Verifying

- Before you push, run `<scoped check, e.g. lint + typecheck + tests for changed files>`.
  Don't run repo-wide suites (`<cmd>`) unless asked, because CI owns the full suite.
- Iterate with `<single-test command>` and `<typecheck command>`.
- Follow [docs/testing.md](docs/testing.md) for what to test and what counts as proof.
- Give user-visible changes one integrated pass in the real app with the
  `verify-app` skill. Look at the rendered result as a user would (layout,
  hierarchy, flow) and fix anything rough before handing back.
- "Tests pass" is not evidence. Say how you checked it and what you saw.

## Pull requests

- Never make a PR unless the developer explicitly asks you to.
- Check `git remote get-url origin` before your first forge command, and use that forge's CLI.
- Use conventional commit titles in plain language: `fix(web): new threads no longer spike CPU`.
- Body: the problem in a sentence or two, then how you fixed it, then how you verified it. End with the model and harness that did the work.
- UI changes need before/after images, and motion or timing changes need a short video. Performance changes need before/after numbers from a realistic run. Upload evidence to the PR and never commit PR-only screenshots or assets.
- One request is one PR. Split only when asked. Cleanups, refactors and a second fix go in their own PRs.
- When babysitting, use the harness's PR-watch tool (or one blocking `gh pr checks <n> --watch`) and don't poll or sleep. Check each bot finding against the source. Fix the real ones and dismiss false positives with a written reason. Stay quiet when nothing is new, and stop when the bots are green on the latest commit.

## Documentation

Most code changes need no doc change, because agents can read the code.
Document decisions and their reasons, constraints that span components, and
traps that are hard to discover from the source. Don't list fields, narrate
control flow or append PR summaries. Anything that can drift will drift. When
a documented decision changes, rewrite or remove the old text rather than
appending to it.

Don't commit implementation plans, research notes or agent scratch files.
A merged PR is the implementation record.

## Where code lives

<!-- 4–8 lines: top-level dirs, what belongs in each, and what is read-only or generated. -->
- `<dir>`: <what lives here>
- `<vendored or generated dir>`: read-only. Never edit it.

<!-- Optional: | Area | Read first | table linking area docs that code review enforces. -->

## Taste

<!-- TODO(human): 3–8 specific, checkable opinions. Prefer ones that lint can enforce. Delete any that are generic. -->
- <e.g. "Complexity belongs at the adapter boundary. Core logic stays pure and UI stays dumb.">
- <e.g. "Prefer inferred types over annotations. `any` is the enemy.">
- <e.g. "Default to no comment. Write one only for a constraint or invariant the code can't show.">
