#!/usr/bin/env bash
# slop-proof audit: read-only inventory of a repo's agent-readiness.
# Usage: bash audit.sh [repo-dir]   (default: .)
# Prints a markdown report. Writes nothing.
set -u
ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "No such dir: $ROOT" >&2; exit 1; }

have() { [ -e "$1" ]; }
mark() { if have "$1"; then echo "- ✅ \`$1\`"; else echo "- ❌ \`$1\`"; fi; }
section() { printf '\n## %s\n\n' "$1"; }
# Find files, skipping heavy dirs. $1 = max depth, rest = -name patterns joined by -o
ff() { local d="$1"; shift; find . -maxdepth "$d" \( -name node_modules -o -name .git -o -name vendor -o -name dist -o -name build -o -name .venv -o -name target -o -name .next \) -prune -o \( "$@" \) -print 2>/dev/null | sed 's|^\./||' | sort | head -40; }

echo "# slop-proof audit: $(basename "$(pwd)")"

section "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  remote=$(git remote get-url origin 2>/dev/null || echo "(no origin)")
  case "$remote" in
    *github.com*) forge=github;; *gitlab*) forge=gitlab;; *bitbucket*) forge=bitbucket;; "(no origin)") forge=none;; *) forge=other;;
  esac
  echo "- origin: \`$remote\` → forge: **$forge**"
  echo "- default branch: \`$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||' || echo unknown)\`"
  total=$(git log --format=%s -n 50 2>/dev/null | wc -l | tr -d ' ')
  conv=$(git log --format=%s -n 50 2>/dev/null | grep -cE '^(feat|fix|chore|docs|refactor|perf|test|build|ci|style|revert)(\([^)]+\))?!?: ' || true)
  echo "- conventional commits in last $total: **$conv**"
  echo "- recent subjects:"; git log --format='  - %s' -n 5 2>/dev/null
else
  echo "- ❌ not a git repository"
fi

section "Agent instructions"
for f in AGENTS.md CLAUDE.md .claude/CLAUDE.md CLAUDE.local.md GEMINI.md .cursorrules .github/copilot-instructions.md .windsurfrules; do mark "$f"; done
have .cursor/rules && echo "- ✅ \`.cursor/rules/\` ($(ls .cursor/rules | wc -l | tr -d ' ') files)"
if have CLAUDE.md; then grep -q '@AGENTS.md' CLAUDE.md && echo "- CLAUDE.md imports AGENTS.md ✅" || echo "- CLAUDE.md does not import AGENTS.md"; fi
for f in AGENTS.md CLAUDE.md; do
  if have "$f"; then
    echo "- \`$f\`: $(wc -l < "$f" | tr -d ' ') lines; sections:"
    grep -E '^#{1,3} ' "$f" | head -25 | sed 's/^/  - /'
    hits=""
    grep -qiE 'pull request|## PR|PRs' "$f" && hits="$hits PR-rules"
    grep -qiE 'before/after|screenshot|video' "$f" && hits="$hits evidence"
    grep -qiE 'conventional commit|fix\(|feat\(' "$f" && hits="$hits conventional-titles"
    grep -qiE 'model and harness|model \+ harness|which model' "$f" && hits="$hits model-attribution"
    grep -qiE 'one (request|problem).*one PR|one PR' "$f" && hits="$hits one-PR"
    grep -qiE 'babysit|watch_pull_request|bots are green' "$f" && hits="$hits babysit"
    grep -qiE 'every surface|surfaces' "$f" && hits="$hits surfaces"
    grep -qiE 'never .*(kill|delete|prod|live)|hurt yourself' "$f" && hits="$hits traps"
    echo "  - slop-proof signals:${hits:- none}"
  fi
done

section "Agent skills"
for d in .claude/skills .agents/skills .codex/skills; do
  if have "$d"; then echo "- \`$d/\`: $(ls "$d" 2>/dev/null | tr '\n' ' ')"; else echo "- ❌ \`$d/\`"; fi
done
have .claude/settings.json && echo "- ✅ \`.claude/settings.json\`"
have .mcp.json && echo "- ✅ \`.mcp.json\`"

section "PR / contribution hygiene"
found_tpl=$(ff 3 -iname 'pull_request_template*' -o -iname 'merge_request_templates')
[ -n "$found_tpl" ] && echo "$found_tpl" | sed 's/^/- ✅ /' || echo "- ❌ PR template"
for f in CONTRIBUTING.md .github/CODEOWNERS SECURITY.md; do mark "$f"; done

section "CI & review bots"
wf=$(ls .github/workflows/*.y*ml 2>/dev/null)
if [ -n "$wf" ]; then echo "$wf" | sed 's/^/- /'; else echo "- ❌ no .github/workflows"; fi
for f in .gitlab-ci.yml .circleci/config.yml .coderabbit.yaml .coderabbit.yml .greptile.yaml; do have "$f" && echo "- ✅ \`$f\`"; done
[ -n "$wf" ] && grep -liE 'coderabbit|greptile|claude-code-action|copilot|cubic|ellipsis' $wf 2>/dev/null | sed 's/^/- review bot referenced in /'

section "Stack"
have package.json && {
  pm=npm; have pnpm-lock.yaml && pm=pnpm; have yarn.lock && pm=yarn; { have bun.lockb || have bun.lock; } && pm=bun
  echo "- Node/JS (package manager: **$pm**)"
  have pnpm-workspace.yaml && echo "- monorepo: pnpm workspaces"; have turbo.json && echo "- monorepo: turbo"; have nx.json && echo "- monorepo: nx"
  pkgs=$(ff 3 -name package.json)
  deps=$(echo "$pkgs" | while read -r p; do [ -n "$p" ] && grep -oE '"(react|next|vue|nuxt|svelte|@sveltejs/kit|astro|solid-js|electron|react-native|expo|vite|express|fastify|hono|@nestjs/core|@playwright/test|playwright|vitest|jest|cypress|storybook|tailwindcss|effect)": *"' "$p"; done | cut -d'"' -f2 | sort -u | tr '\n' ' ')
  echo "- package.json files (depth ≤3): $(echo "$pkgs" | grep -c .)"
  echo "- notable deps: ${deps:-none}"
}
have pyproject.toml && echo "- Python (pyproject)"; have requirements.txt && echo "- Python (requirements.txt)"
have go.mod && echo "- Go"; have Cargo.toml && echo "- Rust"; have Gemfile && echo "- Ruby"
{ have pom.xml || have build.gradle || have build.gradle.kts; } && echo "- JVM"
have Package.swift && echo "- Swift"; have pubspec.yaml && echo "- Dart/Flutter"
ls *.csproj *.sln >/dev/null 2>&1 && echo "- .NET"
{ have Dockerfile || have docker-compose.yml || have compose.yaml; } && echo "- Docker present"
manifest=0; for m in package.json pyproject.toml requirements.txt go.mod Cargo.toml Gemfile pom.xml build.gradle build.gradle.kts Package.swift pubspec.yaml *.csproj *.sln; do have "$m" && manifest=1; done
[ "$manifest" = 0 ] && echo "- (no recognised manifest at root; inspect manually)"

section "Surfaces (heuristic)"
s=$(ff 3 -type d \( -name web -o -name desktop -o -name mobile -o -name ios -o -name android -o -name cli -o -name api -o -name server -o -name docs -o -name marketing -o -name extension \))
[ -n "$s" ] && echo "$s" | sed 's/^/- /' || echo "- (single surface or non-standard layout)"
i18n=$(ff 5 -type d \( -name i18n -o -name locales -o -name translations \))
[ -n "$i18n" ] && echo "$i18n" | sed 's/^/- i18n: /'

section "Runnable scripts"
if have package.json && command -v python3 >/dev/null; then
  python3 -I -c 'import json,sys
try:
  s=json.load(open("package.json")).get("scripts",{})
  [print(f"- `{k}`: `{v[:90]}`") for k,v in s.items()]
except Exception as e: print("- (could not parse package.json)",e)'
fi
have Makefile && { echo "- Makefile targets:"; grep -E '^[A-Za-z0-9_.-]+:' Makefile | cut -d: -f1 | head -20 | sed 's/^/  - /'; }
have justfile && echo "- ✅ justfile"; have Taskfile.yml && echo "- ✅ Taskfile.yml"
have pyproject.toml && grep -A15 -E '^\[(tool\.poetry\.scripts|project\.scripts|tool\.pdm\.scripts|tool\.hatch\.envs.*scripts)\]' pyproject.toml | head -16 | sed 's/^/  /'

section "Tests"
t=$(ff 4 -type d \( -name test -o -name tests -o -name __tests__ -o -name e2e -o -name spec -o -name scenarios \))
[ -n "$t" ] && echo "$t" | sed 's/^/- /' || echo "- ❌ no test dirs found"
count() { find . \( -name node_modules -o -name .git -o -name vendor -o -name .venv \) -prune -o -type f \( "$@" \) -print 2>/dev/null | wc -l | tr -d ' '; }
echo "- unit-ish test files: $(count -name '*.test.*' -o -name '*_test.*' -o -name 'test_*.py' -o -name '*.spec.*')"
echo "- e2e/browser test files: $(count -name '*.e2e.*' -o -name '*.browser.test.*' -o -path '*/e2e/*' -name '*.ts')"
mocks=$(grep -rlE 'vi\.mock\(|jest\.mock\(|unittest\.mock|MagicMock|gomock' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' --include='*.go' . 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
echo "- files using mocks: $mocks"
sleeps=$(grep -rlE 'setTimeout\(.*resolve|sleep\(|time\.sleep|waitForTimeout' --include='*.test.*' --include='*.spec.*' --include='test_*.py' . 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
echo "- test files with sleep-style waits: $sleeps"

section "Docs & danger signals"
for f in README.md docs; do mark "$f"; done
envs=$(ls -a | grep -E '^\.env' | tr '\n' ' '); [ -n "$envs" ] && echo "- env files at root: $envs (keep out of captures and commits)"
gi=$(grep -E '^\.?env|\.sqlite|\.db$|userdata' .gitignore 2>/dev/null | tr '\n' ' '); [ -n "$gi" ] && echo "- gitignored data/secrets patterns: $gi"
ff 3 -name '*.sqlite' -o -name '*.db' -o -name 'seed*' -o -name 'fixtures' | sed 's/^/- data\/seed: /'
have .repos && echo "- vendored read-only: \`.repos/\`"; have third_party && echo "- vendored read-only: \`third_party/\`"

printf '\n---\nNext: read the agent files, README, CI and entry points yourself; then interview the human (Phase 1).\n'
