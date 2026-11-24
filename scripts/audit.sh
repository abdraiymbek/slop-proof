#!/usr/bin/env bash
# slop-proof audit: read-only inventory of a repo's agent-readiness.
# Usage: bash audit.sh [repo-dir]   (default: .)
# Prints a markdown report. Writes nothing. Needs bash and git; python3 or node
# to list package.json scripts. Works with macOS (BSD) and GNU tools.
set -u
ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "No such dir: $ROOT" >&2; exit 1; }

have() { [ -e "$1" ]; }
mark() { if have "$1"; then echo "- ✅ \`$1\`"; else echo "- ❌ \`$1\`"; fi; }
section() { printf '\n## %s\n\n' "$1"; }
# Heavy, generated or vendored dirs (and macOS AppleDouble files) are skipped everywhere.
SKIP=( \( -name node_modules -o -name .git -o -name vendor -o -name dist -o -name build -o -name .venv -o -name venv -o -name target -o -name .next -o -name '._*' \) -prune -o )
# ff <max depth> <find tests...>: matching paths, capped at 40 with a note when truncated.
ff() {
  local d="$1"; shift; local out n
  out=$(find . -maxdepth "$d" "${SKIP[@]}" \( "$@" \) -print 2>/dev/null | sed 's|^\./||' | sort)
  [ -z "$out" ] && return 0
  n=$(printf '%s\n' "$out" | wc -l | tr -d ' ')
  printf '%s\n' "$out" | head -40
  [ "$n" -gt 40 ] && echo "(… $((n - 40)) more not shown)"
  return 0
}
count() { find . "${SKIP[@]}" -type f \( "$@" \) -print 2>/dev/null | wc -l | tr -d ' '; }
# Markdown headings outside code fences.
headings() { awk '/^(```|~~~)/{c=!c} !c && /^(#|##|###) /' "$1" | head -25 | sed 's/^/  - /'; }
# File contents with fenced code blocks removed.
unfenced() { awk '/^(```|~~~)/{c=!c; next} !c' "$1"; }
# grep_files <ERE> <find name tests...>: number of matching files, skipping the same dirs as ff.
grep_files() { local re="$1"; shift; find . "${SKIP[@]}" -type f \( "$@" \) -exec grep -lE "$re" {} + 2>/dev/null | wc -l | tr -d ' '; }

echo "# slop-proof audit: $(basename "$(pwd)")"

section "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  prefix=$(git rev-parse --show-prefix 2>/dev/null)
  [ -n "$prefix" ] && echo "- ⚠️ not the repo root (this is \`${prefix%/}\`). Root files such as CI, the PR template and AGENTS.md may be missing below. Re-run from \`$(git rev-parse --show-toplevel)\` unless you mean to audit only this subtree."
  # Print only the host: remote URLs can carry credentials in userinfo, query or path.
  url=$(git remote get-url origin 2>/dev/null || true)
  case "$url" in
    "") host="";;
    *://*) host=$(printf '%s' "$url" | sed -E 's|^[A-Za-z][A-Za-z0-9+.-]*://||; s|[/?#].*$||; s|^.*@||; s|:[0-9]*$||');;
    /*|./*|../*|~*) host="";;
    *:*) host=$(printf '%s' "$url" | sed -E 's|:.*$||; s|^.*@||');;
    *) host="";;
  esac
  host=$(printf '%s' "$host" | tr 'A-Z' 'a-z')
  hostre='^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$'
  [[ $host =~ $hostre ]] || { [ -n "$host" ] && host="(unparsed)"; }
  case "$host" in
    "") if [ -z "$url" ]; then forge=none; else forge=local; fi;;
    "(unparsed)") forge=unknown;;
    *github*) forge=github;; *gitlab*) forge=gitlab;; *bitbucket*) forge=bitbucket;;
    codeberg.org|*gitea*|*forgejo*) forge=gitea;; *) forge=unknown;;
  esac
  echo "- origin host: \`${host:-(none)}\` → forge: **$forge**"
  db=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true); db=${db#origin/}
  echo "- default branch: \`${db:-unknown (no origin/HEAD)}\`"
  total=$(git --no-pager log --no-show-signature --no-merges --format=%s -n 50 2>/dev/null | wc -l | tr -d ' ')
  conv=$(git --no-pager log --no-show-signature --no-merges --format=%s -n 50 2>/dev/null | grep -cE '^(feat|fix|chore|docs|refactor|perf|test|build|ci|style|revert)(\([^)]+\))?!?: ' || true)
  echo "- conventional commits in last $total (no merges): **$conv**"
  echo "- recent subjects:"; git --no-pager log --no-show-signature --no-merges --format='  - %s' -n 5 2>/dev/null
else
  echo "- ❌ not a git repository"
fi

section "Agent instructions"
for f in AGENTS.md CLAUDE.md; do
  if [ -L "$f" ]; then
    if have "$f"; then echo "- ✅ \`$f\` is a symlink to \`$(readlink "$f")\`"; else echo "- ⚠️ \`$f\` is a broken symlink to \`$(readlink "$f")\`"; fi
  else mark "$f"; fi
done
same=0; have AGENTS.md && have CLAUDE.md && [ AGENTS.md -ef CLAUDE.md ] && same=1
# Other tools' files: listed only when present. Keep them consistent; their absence is not a gap.
for f in .claude/CLAUDE.md CLAUDE.local.md GEMINI.md .cursorrules .github/copilot-instructions.md .windsurfrules; do
  have "$f" && echo "- ✅ \`$f\`"
done
have .cursor/rules && echo "- ✅ \`.cursor/rules/\` ($(ls .cursor/rules | grep -vc '^\._') files)"
if have CLAUDE.md && [ "$same" = 0 ]; then
  if unfenced CLAUDE.md | grep -qE '^[[:space:]]*@AGENTS\.md([[:space:]]|$)'; then echo "- CLAUDE.md imports AGENTS.md on its own line ✅"
  else echo "- CLAUDE.md has no standalone \`@AGENTS.md\` line (an inline import also works; check by eye)"; fi
fi
nested=$(ff 4 -name AGENTS.md -o -name CLAUDE.md | grep / || true)
[ -n "$nested" ] && { echo "- nested instruction files:"; echo "$nested" | sed 's/^/  - /'; }
for f in AGENTS.md CLAUDE.md; do
  have "$f" || continue
  [ "$f" = CLAUDE.md ] && [ "$same" = 1 ] && continue
  echo "- \`$f\`: $(wc -l < "$f" | tr -d ' ') lines; sections:"
  headings "$f"
  hits=""
  grep -qwE 'PRs?|[Pp]ull [Rr]equests?' "$f" && hits="$hits PR-rules"
  grep -qiE 'before/after|screenshot|video' "$f" && hits="$hits evidence"
  grep -qiE 'conventional commit|`(fix|feat)(\(|:)' "$f" && hits="$hits conventional-titles"
  grep -qiE 'model and harness|model \+ harness|which model' "$f" && hits="$hits model-attribution"
  grep -qwE '[Oo]ne PR' "$f" && hits="$hits one-PR"
  grep -qiE 'babysit|watch_pull_request|bots are green' "$f" && hits="$hits babysit"
  grep -qiE 'every surface' "$f" && hits="$hits surfaces"
  grep -qiwE 'never .*(kill|delete|prod|production|live)|hurt yourself' "$f" && hits="$hits traps"
  grep -qiE 'out of scope' "$f" && hits="$hits out-of-scope"
  echo "  - slop-proof signals:${hits:- none}"
done

section "Agent skills"
skills=0
for d in .claude/skills .agents/skills .codex/skills; do
  have "$d" && { skills=1; echo "- \`$d/\`: $(ls "$d" 2>/dev/null | grep -v '^\._' | tr '\n' ' ')"; }
done
[ "$skills" = 0 ] && echo "- no project skills folder (\`.agents/skills/\` or \`.claude/skills/\`)"
have .claude/settings.json && echo "- ✅ \`.claude/settings.json\`"
have .mcp.json && echo "- ✅ \`.mcp.json\`"

section "PR / contribution hygiene"
tpl=$( { find . .github docs .gitea .bitbucket -maxdepth 1 -iname 'pull_request_template*' ! -name '._*' 2>/dev/null; have .gitlab/merge_request_templates && echo .gitlab/merge_request_templates; } | sed 's|^\./||' | sort -u)
if [ -n "$tpl" ]; then echo "$tpl" | sed 's/^/- ✅ PR template: /'; else echo "- ❌ PR template"; fi
mark CONTRIBUTING.md
for f in .github/CODEOWNERS CODEOWNERS SECURITY.md; do have "$f" && echo "- ✅ \`$f\`"; done

section "CI & review bots"
ci=0
for w in .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -f "$w" ] || continue
  case "$(basename "$w")" in ._*) continue;; esac
  ci=1; echo "- \`$w\`"
  grep -qiE 'coderabbit|greptile|claude-code-action|copilot|cubic|ellipsis' "$w" && echo "  - references a review bot"
done
for f in .gitlab-ci.yml bitbucket-pipelines.yml .circleci/config.yml .buildkite/pipeline.yml azure-pipelines.yml Jenkinsfile .woodpecker.yml .gitea/workflows .forgejo/workflows; do
  have "$f" && { ci=1; echo "- ✅ \`$f\`"; }
done
[ "$ci" = 0 ] && echo "- ❌ no CI config found"
for f in .coderabbit.yaml .coderabbit.yml greptile.json .greptile.yaml; do have "$f" && echo "- review bot config: \`$f\`"; done
echo "- note: review bots installed as forge apps leave no file here; check a recent PR for bot comments."

section "Stack"
manifests=$(ff 3 -name package.json -o -name pyproject.toml -o -name requirements.txt -o -name go.mod -o -name Cargo.toml -o -name Gemfile -o -name pom.xml -o -name 'build.gradle*' -o -name Package.swift -o -name pubspec.yaml -o -name '*.csproj' -o -name '*.sln')
if [ -n "$manifests" ]; then echo "- manifests (depth ≤3):"; echo "$manifests" | sed 's/^/  - /'; else echo "- (no recognised manifest within depth 3; inspect manually)"; fi
if have package.json; then
  pm=npm; have pnpm-lock.yaml && pm=pnpm; have yarn.lock && pm=yarn; { have bun.lockb || have bun.lock; } && pm=bun
  pmf=$(grep -oE '"packageManager"[[:space:]]*:[[:space:]]*"[^"@]+' package.json | sed 's/.*"//')
  [ -n "$pmf" ] && pm="$pmf (from packageManager)"
  echo "- Node/JS at root (package manager: **$pm**)"
  locks=$(ls package-lock.json pnpm-lock.yaml yarn.lock bun.lockb bun.lock 2>/dev/null | tr '\n' ' ')
  [ "$(echo "$locks" | wc -w | tr -d ' ')" -gt 1 ] && echo "- ⚠️ several lockfiles: $locks"
  grep -q '"workspaces"' package.json && echo "- monorepo: package.json workspaces"
fi
have pnpm-workspace.yaml && echo "- monorepo: pnpm workspaces"; have turbo.json && echo "- monorepo: turbo"; have nx.json && echo "- monorepo: nx"
pkgs=$(ff 3 -name package.json | grep -v '^(…' || true)
if [ -n "$pkgs" ]; then
  deps=$(echo "$pkgs" | while read -r p; do grep -oE '"(react|next|vue|nuxt|svelte|@sveltejs/kit|astro|solid-js|electron|react-native|expo|vite|express|fastify|hono|@nestjs/core|@playwright/test|playwright|vitest|jest|cypress|storybook|tailwindcss|effect)": *"' "$p"; done | cut -d'"' -f2 | sort -u | tr '\n' ' ')
  echo "- notable JS deps: ${deps:-none}"
fi
have pyproject.toml && echo "- Python (pyproject)"; have requirements.txt && echo "- Python (requirements.txt)"
have go.mod && echo "- Go"; have Cargo.toml && echo "- Rust"; have Gemfile && echo "- Ruby"
{ have pom.xml || have build.gradle || have build.gradle.kts; } && echo "- JVM"
have Package.swift && echo "- Swift"; have pubspec.yaml && echo "- Dart/Flutter"
{ ls ./*.csproj >/dev/null 2>&1 || ls ./*.sln >/dev/null 2>&1; } && echo "- .NET"
{ have Dockerfile || have docker-compose.yml || have compose.yaml; } && echo "- Docker present"

section "Surfaces (heuristic)"
s=$(ff 3 -type d \( -name web -o -name desktop -o -name mobile -o -name ios -o -name android -o -name cli -o -name api -o -name server -o -name docs -o -name marketing -o -name extension \))
if [ -n "$s" ]; then echo "$s" | sed 's/^/- /'; else echo "- (single surface or non-standard layout)"; fi
i18n=$(ff 5 -type d \( -name i18n -o -name locales -o -name translations \))
[ -n "$i18n" ] && echo "$i18n" | sed 's/^/- i18n: /'

section "Runnable scripts"
if have package.json; then
  if command -v python3 >/dev/null; then
    python3 -I -c 'import json
try:
  s=json.load(open("package.json",encoding="utf-8")).get("scripts") or {}
  for k,v in s.items(): print(f"- `{k}`: `{str(v)[:90]}`")
except Exception as e: print("- (could not parse package.json)",e)'
  elif command -v node >/dev/null; then
    node -e 'try{const s=JSON.parse(require("fs").readFileSync("package.json","utf8")).scripts||{};for(const[k,v]of Object.entries(s))console.log("- `"+k+"`: `"+String(v).slice(0,90)+"`")}catch(e){console.log("- (could not parse package.json)")}'
  else
    echo "- (install python3 or node to list package.json scripts)"
  fi
fi
have Makefile && { echo "- Makefile targets:"; grep -E '^[A-Za-z0-9_-][A-Za-z0-9_.-]*:([^=]|$)' Makefile | cut -d: -f1 | head -20 | sed 's/^/  - /'; }
have justfile && echo "- ✅ justfile"; have Taskfile.yml && echo "- ✅ Taskfile.yml"
have pyproject.toml && grep -A15 -E '^\[(tool\.poetry\.scripts|project\.scripts|tool\.pdm\.scripts|tool\.hatch\.envs.*scripts)\]' pyproject.toml | head -16 | sed 's/^/  /'

section "Tests"
t=$(ff 4 -type d \( -name test -o -name tests -o -name __tests__ -o -name e2e -o -name spec -o -name scenarios \))
if [ -n "$t" ]; then echo "$t" | sed 's/^/- /'; else echo "- ❌ no test dirs found"; fi
echo "- unit-ish test files: $(count -name '*.test.*' -o -name '*_test.*' -o -name 'test_*.py' -o -name '*.spec.*' -o -name '*_spec.rb' -o -name '*Test.java' -o -name '*Test.kt')"
echo "- e2e/browser test files: $(count -name '*.e2e.*' -o -name '*.browser.test.*' -o -path '*/e2e/*' -name '*.ts')"
mocks=$(grep_files 'vi\.mock\(|jest\.mock\(|unittest\.mock|MagicMock|gomock' -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.go')
echo "- files using mocks: $mocks"
sleeps=$(grep_files 'setTimeout\(.*resolve|sleep\(|time\.Sleep\(|waitForTimeout' -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' -o -name '*_test.go')
echo "- test files with sleep-style waits: $sleeps"

section "Docs & danger signals"
for f in README.md docs; do mark "$f"; done
envs=$(ls -a | grep -E '^\.env' | tr '\n' ' '); [ -n "$envs" ] && echo "- env files at root: $envs (ask the human, or read \`.env.example\` or the key names only, to learn what they point at before running anything. Never read or print their values)"
gi=$(grep -E '^\.?env|\.sqlite|\.db$|userdata' .gitignore 2>/dev/null | tr '\n' ' '); [ -n "$gi" ] && echo "- gitignored data/secrets patterns: $gi"
ff 3 -name '*.sqlite' -o -name '*.db' -o -name 'seed*' -o -name 'fixtures' | sed 's/^/- data\/seed: /'
have .repos && echo "- vendored read-only: \`.repos/\`"; have third_party && echo "- vendored read-only: \`third_party/\`"

printf '\n---\n❌ marks something to ask about, not a task. Next: read the agent files, README, CI and entry points yourself, then, when setting up, interview the human (Phase 1).\n'
