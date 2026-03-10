# Phase 1: Installer Foundation - Research

**Researched:** 2026-03-10
**Domain:** Bash shell scripting, macOS/Linux toolchain bootstrapping, Claude Code CLI installation, JSON config merging
**Confidence:** HIGH (core patterns), MEDIUM (edge cases and platform quirks)

---

## Summary

Phase 1 builds a shell-script installer that bootstraps a macOS/Linux development environment (Node.js, Git, pnpm, Claude Code CLI) and safely merges workshop configuration into the student's existing `~/.claude/` directory. The dominant risk is the `~/.claude/` merge: overwriting that directory destroys existing hooks, MCP server registrations, and API keys. Backup-before-touch and a correct jq merge strategy are the two non-negotiable requirements.

The Claude Code CLI now ships as a **native binary installer** (`curl -fsSL https://claude.ai/install.sh | bash`) — the former `npm install -g @anthropic-ai/claude-code` path is officially deprecated as of early 2025. This changes the dependency graph: the installer no longer needs Node.js present _before_ installing Claude Code, but Node.js is still required for pnpm and the starter project. Use nvm to install Node.js so students can manage versions later; do not rely on system Node.js or Homebrew-managed Node.js.

Windows is explicitly deferred. Recommend WSL2 in README documentation; do not ship a `.ps1` in Phase 1. The native Claude Code installer supports WSL natively (`curl -fsSL https://claude.ai/install.sh | bash` works inside WSL), so WSL students can follow the Linux path verbatim.

**Primary recommendation:** Write `install.sh` as a sequence of guard-check-then-install functions with a single backup call at the top. Never branch on OS to install different tools — branch only where the install _command_ differs (macOS: Homebrew, Linux: apt/curl fallback). Use `command -v` for all idempotency checks. Use jq with a recursive-merge-with-array-concatenation filter for `settings.json`.

---

## Standard Stack

### Core — what the installer installs

| Tool | Minimum Version | Install Method | Why This Path |
|------|----------------|----------------|---------------|
| Homebrew | latest | `curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \| bash` | Standard macOS package manager; Git can come via Xcode CLT but Homebrew gives version control |
| Git | 2.x (any recent) | `brew install git` (macOS) / `apt-get install git` (Ubuntu/Debian) | Required by Homebrew, Claude Code, and the starter kit clone |
| nvm | latest | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh \| bash` | POSIX-compatible; installs per-user; avoids sudo; required for correct Node.js path on macOS |
| Node.js | 18 LTS or 20 LTS | `nvm install --lts && nvm use --lts` | Claude Code npm path requires ≥18; LTS is stable for course duration |
| pnpm | latest-10 | `curl -fsSL https://get.pnpm.io/install.sh \| sh -` | Official standalone installer; no Node.js required pre-install; idempotent re-run behavior documented |
| Claude Code CLI | latest (native) | `curl -fsSL https://claude.ai/install.sh \| bash` | Native installer recommended by Anthropic; auto-updates; no Node.js dependency |
| jq | latest | `brew install jq` (macOS) / `apt-get install jq` (Linux) | Required for JSON merge of `~/.claude/settings.json` |

### Supporting — what the installer produces

| Artifact | Location | Purpose |
|----------|----------|---------|
| `~/.claude/backup-YYYYMMDD-HHMMSS/` | Student home | Timestamped backup before any `~/.claude/` mutation |
| `~/.claude/settings.json` (merged) | Student home | Workshop settings merged into existing config |
| `~/Documents/claude-mastery-starter/` | Student home | Cloned starter kit |
| `.env.example` | Project root | Documents all required env vars |
| `.gitignore` | Project root | Excludes `.env`, `node_modules`, `.DS_Store`, Claude Code logs |

### Alternatives Considered

| Instead of | Could Use | Why We Don't |
|------------|-----------|--------------|
| nvm | Homebrew Node, system Node, Volta | nvm is POSIX-compatible and student-familiar; Homebrew Node causes PATH conflicts with nvm; Volta requires Rust toolchain |
| pnpm standalone installer | `npm install -g pnpm` | Standalone installer works even before Node is fully on PATH; avoids chicken-and-egg in fresh env |
| Claude Code native installer | `npm install -g @anthropic-ai/claude-code` | npm path is officially deprecated as of 2025; native installer auto-updates, no Node dependency |
| jq for JSON merge | Python/Node one-liner | jq is already installed as a dep; keeps installer in pure shell |

---

## Architecture Patterns

### Recommended installer structure

```
install.sh              # Entry point — orchestrates all steps in order
lib/
├── detect.sh           # OS detection helpers (macOS vs Linux)
├── log.sh              # Print helpers: info, warn, error, success
├── check.sh            # command_exists() and version_ok() functions
├── backup.sh           # Backup ~/.claude/ before touching
└── merge.sh            # jq-based settings.json merge logic
```

For a course installer, a single-file `install.sh` is also acceptable — the above split is only needed if the file exceeds ~300 lines. Either way, the logical sections must exist.

### Pattern 1: Guard-Check-Install function

Every tool install is wrapped in a function that checks before acting:

```bash
#!/bin/bash
# Source: idempotent bash best practices (arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts)

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_git() {
  if command_exists git; then
    echo "[skip] git already installed: $(git --version)"
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      brew install git
      ;;
    Linux)
      sudo apt-get install -y git 2>/dev/null || \
        sudo yum install -y git 2>/dev/null || {
          echo "[error] Could not install git. Please install manually."
          exit 1
        }
      ;;
    *)
      echo "[error] Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}
```

### Pattern 2: Timestamped backup before mutation

```bash
# Source: bash backup patterns; verified against date(1) man page
backup_claude_config() {
  local timestamp
  timestamp=$(date +%Y%m%d-%H%M%S)
  local backup_dir="$HOME/.claude/backup-${timestamp}"

  if [ -d "$HOME/.claude" ]; then
    cp -r "$HOME/.claude/" "$backup_dir/"
    echo "[backup] ~/.claude/ -> ${backup_dir}"
  else
    echo "[skip] No ~/.claude/ directory to back up"
  fi
}
```

Call this ONCE at the top of the installer, before any `~/.claude/` writes.

### Pattern 3: jq settings.json merge (preserve existing keys, concatenate arrays)

The `*` operator in jq overwrites arrays. Because `hooks` in `settings.json` is an object whose values are arrays, a plain `*` merge would silently delete existing hooks. Use a recursive merge that concatenates arrays:

```bash
# Source: codegenes.net/blog/jq-recursively-merge-objects-and-concatenate-arrays
# + verified against jqlang.org/manual/ (jq 1.8)

merge_settings() {
  local existing="$HOME/.claude/settings.json"
  local incoming="./config/workshop-settings.json"
  local tmp

  if [ ! -f "$incoming" ]; then
    echo "[skip] No workshop settings to merge"
    return 0
  fi

  if [ ! -f "$existing" ]; then
    mkdir -p "$HOME/.claude"
    cp "$incoming" "$existing"
    echo "[write] Created ~/.claude/settings.json"
    return 0
  fi

  tmp=$(mktemp)
  jq -s '
    def deep_merge(a; b):
      if (a|type) == "object" and (b|type) == "object" then
        reduce ((a|keys) + (b|keys) | unique)[] as $k ({};
          .[$k] = deep_merge(a[$k]; b[$k])
        )
      elif (a|type) == "array" and (b|type) == "array" then
        (a + b | unique)
      elif b == null then a
      else b
      end;
    deep_merge(.[0]; .[1])
  ' "$existing" "$incoming" > "$tmp" && mv "$tmp" "$existing"
  echo "[merge] ~/.claude/settings.json updated"
}
```

IMPORTANT: Use `unique` on the concatenated array to prevent duplicate hook entries if the installer runs twice. This is the idempotency guard for the JSON merge.

### Pattern 4: nvm sourcing inside a non-interactive script

nvm is a shell function, not a binary. It will not be available to child processes unless explicitly sourced:

```bash
# Source: github.com/nvm-sh/nvm README
load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

install_node() {
  if ! command_exists nvm; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    load_nvm
  else
    load_nvm
  fi

  nvm install --lts
  nvm use --lts
  nvm alias default "lts/*"
}
```

The `nvm alias default` call ensures the LTS version is active in future shell sessions.

### Pattern 5: Starter kit clone with skip guard

```bash
clone_starter_kit() {
  local dest="$HOME/Documents/claude-mastery-starter"
  local repo_url="https://github.com/YOUR_ORG/claude-mastery-starter.git"

  if [ -d "$dest/.git" ]; then
    echo "[skip] Starter kit already cloned at $dest"
    return 0
  fi

  git clone "$repo_url" "$dest"
  echo "[done] Starter kit cloned to $dest"
}
```

### Pattern 6: Shell profile sourcing — PATH propagation

After installing Homebrew, pnpm, and nvm, PATH changes don't take effect in the current shell without explicit sourcing. The installer must source updated profiles or export paths manually:

```bash
# After Homebrew install on Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"

# After nvm install:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# After pnpm install:
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
```

### Anti-Patterns to Avoid

- **Overwriting `~/.claude/settings.json` directly:** Destroys existing hooks, API key helper scripts, and MCP registrations. Always merge.
- **Using `declare -A` (associative arrays):** Not available in bash 3.2 (macOS default). Use positional parameters or sequential logic.
- **Running installer steps without idempotency guards:** Tool installs that run unconditionally on re-run waste time and can produce errors (e.g., Homebrew warns if formula already installed).
- **`sudo npm install -g`:** Causes permission issues. Anthropic explicitly documents this as wrong. Use nvm instead.
- **Assuming `~/.zshrc` exists on Linux:** Use `~/.bashrc` on Linux, `~/.zshrc` on macOS (Catalina+). Detect with `$SHELL`.
- **Piping curl to bash without integrity check:** Acceptable for course installers targeting students, but document the risk. For production tools, verify checksums.
- **Using the deprecated npm Claude Code path:** `npm install -g @anthropic-ai/claude-code` still works but is officially deprecated. The native installer is the correct path.
- **Scripting Claude Code authentication:** The official docs confirm auth requires interactive browser flow. The installer must explicitly inform students to run `claude` and authenticate manually as a post-install step.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Node.js version management | Custom `$NODE_PATH` logic | nvm | nvm handles `.nvmrc`, PATH shims, `default` alias — all edge cases |
| JSON config merging | `sed`/`awk` string manipulation of JSON | `jq` | JSON structure is not line-oriented; string manipulation breaks on nested objects |
| Package manager detection | `which npm && which pnpm` chains | pnpm standalone installer's own detection | The installer at `get.pnpm.io/install.sh` handles all PATH cases |
| Claude Code update management | Manual version pinning | Native installer's auto-update | Auto-updates are a native feature; fighting them adds complexity |
| Backup rotation / cleanup | Custom `find -mtime` scripts | Simple `cp -r` with timestamp | Rotation is out of scope; one backup per run is sufficient |

**Key insight:** Shell installers fail at JSON manipulation. Any time the task touches structured data (settings.json), reach for jq immediately — do not attempt to construct JSON with `echo` or `cat` heredocs.

---

## Common Pitfalls

### Pitfall 1: Homebrew PATH not available after install

**What goes wrong:** The installer runs `brew install git` but the next command can't find `git` because `/usr/local/bin` (Intel) or `/opt/homebrew/bin` (Apple Silicon) isn't in PATH for that shell session.

**Why it happens:** Homebrew's install script appends to `~/.zshrc`/`~/.bash_profile` but the current shell doesn't re-source those files.

**How to avoid:** Immediately after Homebrew installs, run `eval "$(/opt/homebrew/bin/brew shellenv)"` (Apple Silicon) or `eval "$(/usr/local/bin/brew shellenv)"` (Intel). Detect architecture with `uname -m`.

**Warning signs:** `brew: command not found` on the line immediately after installing Homebrew.

---

### Pitfall 2: nvm is a shell function, not a binary

**What goes wrong:** The installer runs `curl ... | bash` to install nvm, then calls `nvm install --lts` — which fails with `nvm: command not found`.

**Why it happens:** nvm's install script adds source lines to `~/.bashrc`/`~/.zshrc`, but those only apply to new shells. The current script's environment doesn't have the function.

**How to avoid:** After nvm installs, explicitly source it:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
```

**Warning signs:** Any `nvm: command not found` error after a successful nvm installation.

---

### Pitfall 3: `jq` merge silently deletes existing hooks

**What goes wrong:** Using `jq -s '.[0] * .[1]'` (the `*` operator) to merge `settings.json` replaces any arrays in the left document with arrays from the right. Existing `PreToolUse` hooks in the student's config disappear.

**Why it happens:** In jq, `object * object` does a recursive merge where arrays are replaced, not concatenated. This is correct for most scalar keys but wrong for `hooks` arrays.

**How to avoid:** Use the `deep_merge` function shown in Pattern 3 above, which concatenates arrays and uses `unique` to prevent duplicate entries on re-run.

**Warning signs:** Student reports that Claude Code hooks they had before the workshop no longer work.

---

### Pitfall 4: Claude Code native installer has a known lock file bug

**What goes wrong:** Re-running `curl -fsSL https://claude.ai/install.sh | bash` on a system where Claude Code is already installed can fail with "another process is currently installing" — even when no process is running.

**Why it happens:** The native installer creates a lock file that isn't always cleaned up. This is a known bug in the Anthropic installer (GitHub issue #13599).

**How to avoid:** Guard the Claude Code install with `command -v claude`. Only run the installer if `claude` is not found. Do not run the installer unconditionally:

```bash
install_claude_code() {
  if command_exists claude; then
    echo "[skip] Claude Code already installed: $(claude --version 2>/dev/null)"
    return 0
  fi
  curl -fsSL https://claude.ai/install.sh | bash
}
```

**Warning signs:** `Error: another process is currently installing` when no other process is running.

---

### Pitfall 5: macOS bash 3.2 — no associative arrays

**What goes wrong:** Using `declare -A mymap` causes `declare: -A: invalid option` on stock macOS (which ships bash 3.2 due to GPLv3 licensing).

**Why it happens:** Associative arrays (`declare -A`) require bash 4.0+. macOS ships bash 3.2.57 and will not update it.

**How to avoid:** Never use `declare -A` in `install.sh`. Use sequential variable names or pass data through positional parameters and loops. Test with the system bash (`/bin/bash`), not a Homebrew-installed one.

**Warning signs:** Any `declare: -A: invalid option` error on a fresh macOS machine.

---

### Pitfall 6: Multiple git installations on macOS

**What goes wrong:** After `brew install git`, `which git` may still return `/usr/bin/git` (Xcode CLT git) instead of the Homebrew version, because `/usr/bin` comes first in PATH.

**Why it happens:** Homebrew installs to `/usr/local/bin` (Intel) or `/opt/homebrew/bin` (Apple Silicon), which must come before `/usr/bin` in PATH.

**How to avoid:** After running `eval "$(...brew shellenv)"`, the brew prefix bin directory is prepended to PATH. Verify with `which git` after sourcing shellenv.

**Warning signs:** `git --version` shows a version lower than 2.30 after Homebrew install.

---

### Pitfall 7: Claude Code requires interactive auth — installer cannot script it

**What goes wrong:** Installer tries to automate `claude` login, hangs waiting for user input, or exits with a confusing error.

**Why it happens:** The official Anthropic docs explicitly state authentication requires browser interaction. There is no `--non-interactive` flag or API key env var that bypasses this for initial login.

**How to avoid:** Do not attempt to authenticate in the script. Instead, at the end of the installer, print clear instructions:
```
NEXT STEP: Run 'claude' and follow the browser prompts to authenticate.
```

**Warning signs:** The installer stalling on a step that calls `claude` with no arguments.

---

## Code Examples

Verified patterns from official sources:

### Full idempotency guard template

```bash
#!/bin/bash
# POSIX-compatible: works on bash 3.2 (macOS default)
# Source: arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts

set -e  # Exit on any error
set -u  # Treat unset variables as errors

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

log_info()    { echo "[info]    $*"; }
log_skip()    { echo "[skip]    $*"; }
log_done()    { echo "[done]    $*"; }
log_error()   { echo "[error]   $*" >&2; }

# Guard pattern — used for every tool:
# if command_exists <tool>; then log_skip; else install; fi
```

### Detecting macOS vs Linux + Apple Silicon vs Intel

```bash
# Source: uname(1) man page; verified on macOS 13+ and Ubuntu 20.04+
detect_os() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin)
      if [ "$ARCH" = "arm64" ]; then
        BREW_PREFIX="/opt/homebrew"
      else
        BREW_PREFIX="/usr/local"
      fi
      ;;
    Linux)
      BREW_PREFIX=""
      ;;
    *)
      log_error "Unsupported OS: $OS"
      exit 1
      ;;
  esac
}
```

### Claude Code native install (with idempotency guard)

```bash
# Source: code.claude.com/docs/en/setup (official Anthropic docs, verified 2026-03-10)
install_claude_code() {
  if command_exists claude; then
    log_skip "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
    return 0
  fi

  log_info "Installing Claude Code CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
  log_done "Claude Code installed"
  log_info "NEXT: Run 'claude' to authenticate via browser"
}
```

### pnpm standalone install (with idempotency guard)

```bash
# Source: pnpm.io/installation (official pnpm docs, verified 2026-03-10)
install_pnpm() {
  if command_exists pnpm; then
    log_skip "pnpm already installed ($(pnpm --version))"
    return 0
  fi

  log_info "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -

  # pnpm install.sh adds to profile; source it for current session
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
  log_done "pnpm installed"
}
```

### .env.example template for Claude Code course project

```bash
# Source: SCAF-03 requirement; standard Next.js + Convex + Clerk stack
cat > .env.example << 'EOF'
# Claude / Anthropic
ANTHROPIC_API_KEY=your_api_key_here

# Convex
CONVEX_DEPLOYMENT=dev:your-deployment-name
NEXT_PUBLIC_CONVEX_URL=https://your-deployment.convex.cloud

# Clerk Auth
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up

# Stripe (optional for Phase 1)
STRIPE_SECRET_KEY=sk_test_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
EOF
```

### .gitignore covering SCAF-04 requirements

```gitignore
# Source: SCAF-04 requirement + standard Next.js template
# Dependencies
node_modules/
.pnp
.pnp.js

# Environment
.env
.env.local
.env.*.local

# Build output
.next/
out/
dist/
build/

# OS
.DS_Store
Thumbs.db

# Claude Code logs and state
.claude/settings.local.json
~/.claude/

# Editor
.vscode/
.idea/
*.swp
*.swo

# pnpm
.pnpm-store/
pnpm-lock.yaml.bak
```

### Claude Code settings.json — known structure (for the workshop settings template)

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": [],
    "SessionStart": [],
    "Stop": []
  },
  "permissions": {
    "allow": [],
    "deny": []
  },
  "env": {}
}
```

Source: code.claude.com/docs/en/settings (verified 2026-03-10). The `hooks` key is an object where each event name maps to an array of hook handler objects. The merge strategy must concatenate these arrays, not replace them.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|---|---|---|---|
| `npm install -g @anthropic-ai/claude-code` | `curl -fsSL https://claude.ai/install.sh \| bash` | Early 2025 | npm path officially deprecated; native installer is faster, no Node dep, auto-updates |
| Homebrew Node.js | nvm Node.js | Long-standing best practice | Homebrew Node causes PATH conflicts; nvm supports `.nvmrc`, per-project versions |
| `declare -A` for config maps | Sequential variables + `case` statements | bash 3.2 (macOS) limitation always existed | Must target bash 3.2 on macOS; no workaround, just avoid associative arrays |
| `claude --dangerously-skip-permissions` for hooks | Hook exit codes (0=allow, permissionDecision JSON=block) | Claude Code matured | Hooks use structured JSON output for block decisions, not exit codes |

**Deprecated/outdated:**
- `npm install -g @anthropic-ai/claude-code`: Still functional but officially deprecated. Do not teach this path.
- Xcode CLT git as the only git: Xcode CLT git is old. Homebrew git is preferred for a dev environment.

---

## Open Questions

1. **nvm version to pin**
   - What we know: nvm v0.40.3 is current as of 2026-03-10 based on the official GitHub README URL pattern
   - What's unclear: Whether to hard-pin the version in the curl URL or use a latest-redirect
   - Recommendation: Pin to a specific version (e.g., `v0.40.3`) in the installer for reproducibility; students can upgrade manually. Hard-coded URLs are more predictable than latest-redirects in educational material.

2. **pnpm installer idempotency on re-run**
   - What we know: Official docs do not document whether `get.pnpm.io/install.sh` is idempotent
   - What's unclear: Whether a second run upgrades, errors, or silently succeeds
   - Recommendation: Guard with `command_exists pnpm` before calling the pnpm installer. This avoids the question entirely.

3. **Deep merge uniqueness for hooks arrays**
   - What we know: The `unique` call in the deep_merge jq filter prevents duplicate hooks on re-run
   - What's unclear: Whether `unique` on hook objects (which are JSON objects) works correctly in all jq versions
   - Recommendation: Test the jq filter against a real `~/.claude/settings.json` with existing hooks before shipping. jq 1.6+ handles `unique` on arrays of objects.

4. **Claude Code install.sh idempotency when already installed**
   - What we know: A known GitHub issue (#13599) shows the native installer can error with a lock file message on re-run even when Claude Code is already installed
   - What's unclear: Whether this bug is fixed in the current release
   - Recommendation: The `command_exists claude` guard in Pattern 4 above sidesteps this entirely. Never call the installer when `claude` is already present.

5. **Windows path for v1**
   - What we know: WSL2 + `curl -fsSL https://claude.ai/install.sh | bash` is the supported Windows path per official docs; no `.ps1` needed for WSL students
   - What's unclear: What fraction of course students will be on Windows without WSL2
   - Recommendation: README documents WSL2 setup link; `install.sh` exits gracefully with a clear message on non-macOS/non-Linux OS (`uname -s` check).

---

## Sources

### Primary (HIGH confidence)

- **code.claude.com/docs/en/setup** — Claude Code system requirements, installation commands, native vs npm deprecation, macOS/Linux/Windows paths. Verified 2026-03-10.
- **code.claude.com/docs/en/settings** — Full `settings.json` schema, all supported keys, permissions structure, hooks configuration format, scope/precedence. Verified 2026-03-10.
- **code.claude.com/docs/en/hooks** — Hook events table, exit code semantics, PreToolUse/PostToolUse/SessionStart schemas, matcher patterns. Verified 2026-03-10.
- **pnpm.io/installation** — Official standalone installer command, corepack alternative, Homebrew alternative. Verified 2026-03-10.

### Secondary (MEDIUM confidence)

- **github.com/nvm-sh/nvm** — nvm install script URL pattern, POSIX compatibility claim, `.nvmrc` usage. Confirmed by multiple secondary sources.
- **arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts** — `command -v`, `mkdir -p`, `grep -qF` idempotency patterns. Widely cited; patterns are consistent with official bash docs.
- **codegenes.net/blog/jq-recursively-merge-objects-and-concatenate-arrays** — Recursive jq merge function with array concatenation. Verified filter syntax against jqlang.org/manual/.
- **jqlang.org/manual/** — jq 1.8 manual, `*` operator behavior, `unique` on arrays of objects.

### Tertiary (LOW confidence — validate before relying on)

- **github.com/anthropics/claude-code/issues/13599** — Lock file bug in native installer on re-run. Single source; bug may be fixed in current release. Use the `command_exists` guard to avoid regardless.
- **github.com/anthropics/claude-code/issues/7734** — npm vs native install conflict. Referenced to confirm deprecation story.

---

## Metadata

**Confidence breakdown:**
- Standard stack (tools and versions): HIGH — verified against official docs for all major tools
- Architecture (idempotency patterns): HIGH — cross-verified against multiple sources; patterns are standard bash practice
- JSON merge strategy: MEDIUM — jq filter verified syntactically; array `unique` behavior on objects needs a runtime test
- Claude Code native installer lock bug: LOW — single GitHub issue; the `command_exists` guard makes this moot

**Research date:** 2026-03-10
**Valid until:** 2026-06-10 (Claude Code releases fast; re-verify install URL before shipping course)
