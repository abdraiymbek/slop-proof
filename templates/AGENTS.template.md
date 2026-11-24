<!--
slop-proof template for a repo's AGENTS.md. Fill it from the audit and the
interview, then delete every comment. Replace each <placeholder> and "e.g."
with something true for this repo, or delete the line. Delete any section with
nothing repo-specific in it.
Parts of this text are adapted from pingdotgg/t3code's AGENTS.md
(MIT, © 2026 T3 Tools Inc.).
-->
# <Project name>

<!-- One or two sentences from the human: what this is and who uses it. -->
<Project> is <what it is> for <who>.

## What we never compromise on

<!-- TODO(human): 2–5 non-negotiables. Each is a short heading and a sentence on what it means for a change. -->
### 1. <e.g. Performance>
<e.g. "Check startup time and list rendering for regressions on every change.">

### 2. <e.g. Works on every surface>
<e.g. "Web, desktop and mobile all ship every feature where reasonable.">

## Out of scope

<!-- TODO(human): work agents should never open a PR for without asking first. -->
- <e.g. UI overhauls, new dependencies, new providers or integrations>

## How we build

<!-- Optional maintainer voice. Ask the human: keep, edit or drop the first paragraph? Always keep the second one (the release valve). -->
Prefer simple systems and software that feels obvious. Don't preserve
complexity just because it exists, and don't add machinery because it looks
impressive. Understand the real constraint, then build the smallest model that
makes the correct behavior unsurprising. Fight scope creep and honor the
developer's intent minimally and realistically.

These are good defaults, not hard rules, and the developer's preferences
override them. If a rule here fights the task in front of you, say so loudly
and get a human sign-off before breaking it.

## Ways to hurt yourself

<!-- Only real traps found in the audit, each with the safe alternative. Delete the section if there are none. The shape: -->
1. **<e.g. Writing to live data>.** <e.g. "`~/.app/data.db` is the developer's real data, in use while you work. Never point a dev server at it or clean it up. Run with `APP_HOME=$(mktemp -d)` instead.">
2. **<e.g. Killing processes by pattern>.** <e.g. "Other sessions run the same binary. Kill only a PID you captured when you spawned it.">

## Hit every surface

The most common defect is a change that works on the path you tested and is
missing everywhere else. Before you call the work done, walk this list and say
which entries applied:

<!-- Keep only the lines that fit this repo. -->
- **Entry points.** <e.g. main view, settings, command palette, keyboard shortcuts, CLI flags>
- **Clients/platforms.** <e.g. web, desktop, mobile, and where shared logic lives>
- **Contracts.** <e.g. "API and wire changes go in `packages/contracts` so every consumer follows.">
- **Reverse states.** Every way in needs a way out and a way to see it. A one-way door is a bug.
- **Languages.** <e.g. i18n files and the command that regenerates or checks them>
- **Docs.** Check whether the change makes existing guidance inaccurate.

## Running it

- Install: `<cmd>`
- Dev: `<cmd>` (ports: <ports>, read them from the output rather than assuming)
- Seed or test data: `<cmd or path>`, against `<isolated state dir / test DB>`. Never live data.
- Start dev servers from your own shell so they exit with your session. Don't detach them unless asked.

## Verifying

- Before you push, run `<scoped check, e.g. lint + typecheck + tests for changed files>`.
  <!-- Keep the next sentence only if CI runs the full suite on PRs and it is slow. -->
  Don't run repo-wide suites (`<cmd>`) unless asked, because CI owns the full suite.
- Iterate with `<single-test command>` and `<typecheck command>`.
- Follow [docs/testing.md](docs/testing.md) for what to test and what counts as proof. <!-- Point at the real policy, or delete. -->
- Give user-visible changes one integrated pass in the real app with
  `<path to the verify skill, e.g. .agents/skills/verify-app/SKILL.md>`. Look at
  the rendered result as a user would (layout, hierarchy, flow) and fix
  anything rough before handing back.
  <!-- For a library or CLI with no app: name the one real-outcome check instead. -->
- "Tests pass" is not evidence. Say how you checked it and what you saw.

## Pull requests

<!-- Keep this block close to verbatim: it is the highest-value text here. Adapt the forge CLI, the example title, the upload method and the babysitting bullet. -->
- Never make a PR unless the developer explicitly asks you to.
- Use `<gh / glab / tea>` for forge commands. Don't print remote URLs; they can contain tokens.
- Use conventional commit titles in plain language: `<e.g. fix(web): new threads no longer spike CPU>`.
- Body: the problem in a sentence or two, then how you fixed it, then how you verified it. End with the model and harness that did the work. <!-- Add disallowed models here, if any. -->
- UI changes need before/after images, and motion or timing changes need a short video. Performance changes need before/after numbers from a realistic run. Attach evidence to the PR with `<the team's uploader, or by handing the local paths to the developer to drag in>`. Never commit PR-only screenshots or assets.
- One request is one PR. Split only when asked. Cleanups, refactors and a second fix go in their own PRs.
<!-- Keep the next bullet only if CI or review bots run on PRs. -->
- When babysitting, wait on the PR with `<the harness's PR-watch tool, or one blocking CI watch such as "gh pr checks N --watch">`. Don't poll or sleep. CI finishing doesn't mean reviews are in: `<bots expected on every PR>` must each have posted on the latest commit. Check each finding against the source. Fix the real ones and reply to false positives with a written reason. Stay quiet when nothing is new. Stop when checks are green, every expected bot has posted on the latest commit and no finding is open. If you can't tell whether a bot has run, report it as pending.

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

<!-- Only for monorepos or unusual layouts; delete for small repos. 4–8 lines: top-level dirs, what belongs in each, and what is read-only or generated. -->
- `<dir>`: <what lives here>
- `<vendored or generated dir>`: read-only. Never edit it.

<!-- Optional: | Area | Read first | table linking area docs that code review enforces. -->

## Taste

<!-- TODO(human): 3–8 specific, checkable opinions from the maintainers. Prefer ones lint can enforce. Never fill this with generic advice. -->
- <e.g. "Complexity belongs at the adapter boundary. Core logic stays pure and UI stays dumb.">
- <e.g. "Prefer inferred types over annotations. `any` is the enemy.">
- <e.g. "Default to no comment. Write one only for a constraint or invariant the code can't show.">
