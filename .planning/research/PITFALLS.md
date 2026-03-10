# Pitfalls Research

**Domain:** Developer education starter kit / Claude Code course companion
**Researched:** 2026-03-10
**Confidence:** HIGH (Claude Code docs verified via official source; installer patterns verified via official npm/bash sources; CLAUDE.md guidance verified via official Claude Code best-practices page)

---

## Critical Pitfalls

### Pitfall 1: Destructive Global Config Installation

**What goes wrong:**
The installer copies a new `~/.claude/CLAUDE.md` or `~/.claude/settings.json` on top of whatever the student already has. A student who purchased this course mid-way through their Claude Code career — one who already has custom hooks, MCP server configs, and personal CLAUDE.md rules — loses all of it silently.

**Why it happens:**
Installers default to "write the file" because that's the success path. Checking for existence and merging requires defensive logic that's easy to skip.

**How to avoid:**
- Before writing any file under `~/.claude/`, check for existence: `[ -f ~/.claude/CLAUDE.md ] && ...`
- If the file exists, back it up with a timestamp: `cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak.$(date +%Y%m%d_%H%M%S)`
- Append course content as a clearly-delimited section rather than replacing the file:
  ```bash
  # --- BEGIN CLAUDE MASTERY COURSE ---
  # ... course content ...
  # --- END CLAUDE MASTERY COURSE ---
  ```
- For `settings.json`: use `jq` to deep-merge, never overwrite. Array fields (like `permissions.allow`) MERGE across scopes per the Claude Code config system — installers should replicate this behavior.
- Print a clear message: "Found existing ~/.claude/CLAUDE.md — backed up to X, appending course config."

**Warning signs:**
- Installer uses `>` (overwrite) instead of `>>` (append) or merge
- No backup logic anywhere in the install script
- Student reports "all my settings disappeared after install"

**Phase to address:** Installer phase (Phase 1 / setup). Must be verified before any other phase ships.

---

### Pitfall 2: Hooks That Block Students Cold

**What goes wrong:**
A `PreToolUse` hook that enforces `cn()` usage or bans `export default` exits with code 2 (blocking), which causes Claude Code to halt the tool call entirely. A beginner who doesn't understand the error message abandons the course. The hook was meant to teach — instead it creates a wall.

**Why it happens:**
Hook authors conflate "education" with "enforcement." They write blocking hooks (exit 2 / `permissionDecision: "deny"`) when they intend advisory warnings. The Claude Code hook system has two distinct behaviors: exit 0 (allow + optional feedback), exit 2 (block). Many developers don't read the distinction carefully.

**How to avoid:**
- Course hooks MUST use advisory mode by default: exit 0 with a `stdout` message explaining the pattern. Reserve blocking (exit 2) only for genuinely dangerous operations (e.g., writing `.env` secrets to public files).
- Design a "teaching mode" vs "enforcement mode" toggle — perhaps a file flag like `.claude/hooks/.enforce` that students can opt into after completing the relevant module.
- Every hook output should include a "why this matters" sentence and a "how to fix it" sentence. Not just `ERROR: use cn()`. Instead: `STYLE TIP: Use cn() from @/lib/utils instead of template literals — it prevents Tailwind class conflicts. Replace the className with: cn("base-class", condition && "conditional-class")`
- Test every hook in non-blocking mode first. Add blocking only after verifying the message is clear enough that a beginner can self-rescue.

**Warning signs:**
- Hooks use `exit 2` for style violations
- Hook error messages contain no fix guidance, just the rule name
- Students in support channels say "my hook keeps blocking me"
- Hook logic uses grep/regex that produces false positives on legitimate beginner patterns

**Phase to address:** Hooks design phase. Every hook must go through a "beginner readability" review before shipping.

---

### Pitfall 3: CLAUDE.md Cognitive Overload (the 15KB Problem)

**What goes wrong:**
The existing CLAUDE.md is 15.5KB. Official Claude Code best-practices documentation explicitly states: "Bloated CLAUDE.md files cause Claude to ignore your actual instructions." The model context window already contains ~50 built-in system instructions. At ~200 instruction capacity, a 15KB file likely causes selective attention failure — Claude follows some rules and silently drops others, which is worse than no rules (at least then the student knows to check).

**Why it happens:**
Authors who know the domain deeply want to encode everything. Each rule feels important in isolation. The cumulative effect on model attention is invisible to the author. The "everything in one place" instinct is strong.

**How to avoid:**
- Target the project CLAUDE.md at under 80 lines / under 3KB for beginner modules
- Use the `@path/to/file` import syntax to load supplementary rule files on demand rather than inline everything
- Structure as a progressive disclosure tree: CLAUDE.md holds the 10 most critical rules; deeper rules live in `.claude/skills/` files that Claude loads when working in relevant areas
- Ruthless pruning test: remove a rule, observe behavior. If Claude still does the right thing without the rule, it was redundant — delete it or move it to a supplementary file
- Create module-specific CLAUDE.md files in subdirectories (e.g., `module-03/CLAUDE.md`) that add rules progressively as students advance, rather than dumping all rules upfront

**Warning signs:**
- CLAUDE.md exceeds 100 lines or 4KB
- Students report Claude "not following the rules"
- Rules lower in the file are violated more often than rules near the top
- Duplicate or near-duplicate rules exist (sign of organic growth without pruning)

**Phase to address:** Content design phase. Define the CLAUDE.md architecture (layered, import-based) before writing any content.

---

### Pitfall 4: Installer Assumes Shell Environment Exists

**What goes wrong:**
The bash installer uses `source ~/.zshrc` or `export PATH=...` and assumes the change takes effect immediately. On a fresh macOS install, the student may be using bash (pre-Catalina default), fish, or a non-login shell. Node.js gets installed via nvm but the PATH update doesn't propagate to the current shell session. The student types `node -v` and gets "command not found" — and blames the installer.

**Why it happens:**
Developers who write installers live in well-configured shells. They forget that `nvm` installs into `~/.nvm` and requires a shell reload. They forget that `~/.zshrc` sourcing in a non-interactive subshell does nothing. They forget that Windows uses PowerShell where `export` is not valid syntax.

**How to avoid:**
- After installing any tool that modifies PATH, explicitly test with a subshell: `bash -c "source ~/.bashrc && node -v"` — if this fails, the PATH setup is broken
- End the installer with an explicit, impossible-to-miss instruction: "RESTART YOUR TERMINAL (close and reopen) before continuing. Do not use the same window."
- Never rely on `source` within the installer to activate a just-installed tool for subsequent steps. Check each tool with its full path (`/usr/local/bin/node`) or re-exec the installer step in a fresh subshell
- For PowerShell: use `[Environment]::SetEnvironmentVariable()` for persistent PATH changes; `$env:PATH` changes only last the session
- Detect the active shell explicitly: `$SHELL` variable, then source the correct rc file

**Warning signs:**
- Installer uses `nvm install` then immediately `node -v` in the same script without re-sourcing
- No "restart your terminal" prompt at the end
- No shell detection (`bash`/`zsh`/`fish`/`PowerShell`) — uses hardcoded `~/.bashrc`

**Phase to address:** Installer phase. Test on a fresh user account with default shell before shipping.

---

### Pitfall 5: Non-Idempotent Installer (Double-Run Damage)

**What goes wrong:**
A student runs the installer, hits an error halfway through, fixes the issue, and runs it again. The second run duplicates PATH entries in `~/.zshrc`, installs a second copy of Claude Code, or creates a second backup of a file that was already backed up once. In worst cases, duplicate entries in `settings.json` cause parse errors that break Claude Code entirely.

**Why it happens:**
Installers are written for the happy path (first run, clean machine). Idempotency requires checking state before every write operation — tedious but essential.

**How to avoid:**
- Use `grep -q "PATTERN" ~/.zshrc || echo "line to add" >> ~/.zshrc` pattern for all rc file modifications
- Before `npm install -g @anthropic/claude-code`, check: `claude --version 2>/dev/null` — if it exists and is the right version, skip
- For directory creation: `mkdir -p` is idempotent by nature — always use it
- For JSON files: check if the key already exists before inserting; `jq 'if .key then . else .key = value end'`
- Test the installer twice in a row on the same machine. The second run should produce zero changes and exit cleanly

**Warning signs:**
- Installer uses unconditional `echo "..." >> ~/.zshrc` without checking for existing entry
- No version checks before installing tools
- Student reports duplicate entries in their shell config after reinstalling

**Phase to address:** Installer phase. Add an explicit double-run test to the QA checklist.

---

### Pitfall 6: EACCES Errors Killing npm Global Installs

**What goes wrong:**
On macOS/Linux, if Node.js was installed without nvm (e.g., via the official `.pkg` installer or Homebrew with system ownership), `npm install -g` writes to a directory owned by root. The student gets `EACCES: permission denied` and the documented fix ("use sudo") causes its own cascade of permission problems.

**Why it happens:**
This is the single most documented npm beginner pain point. Official npm docs, community forums, and dozens of blog posts all cover it — because it happens constantly. Starter kits that don't proactively handle this force students to debug a system-level issue before they've learned anything about the course.

**How to avoid:**
- The installer should detect whether the global npm prefix is user-owned:
  ```bash
  npm_prefix=$(npm config get prefix)
  if [ ! -w "$npm_prefix" ]; then
    # Offer to fix or switch to nvm
  fi
  ```
- Prefer nvm installation before Claude Code CLI installation — nvm-managed Node keeps the prefix in `~/.nvm` (user-owned, no permission issues)
- If nvm is not present and the prefix is not writable, offer two paths: (a) install nvm and reinstall Node, or (b) set a user-local npm prefix (`mkdir ~/.npm-global && npm config set prefix ~/.npm-global`)
- Never suggest `sudo npm install -g` — document this explicitly as something the installer avoids
- On Windows: installer must be run as Administrator or use `winget`/`choco` which handle elevation properly

**Warning signs:**
- Installer has no npm prefix writability check
- Error handling shows users a raw EACCES stack trace without guidance
- Students in support say "it asked for my password and then broke"

**Phase to address:** Installer phase. Pre-flight checks section must include npm prefix validation.

---

### Pitfall 7: Module Workspace Structure That Confuses Navigation

**What goes wrong:**
Module workspaces are too deeply nested (e.g., `modules/03-typescript/exercises/advanced/01-strict-mode/`) and beginners spend 10 minutes trying to find where to put their work. Or the opposite: all modules are flat in one directory with no clear progression, so students don't know what to tackle next. In both cases, students disengage before writing any code.

**Why it happens:**
Course creators optimize for logical completeness ("each module is fully self-contained") without testing with actual beginners who don't have the mental model of the course structure yet.

**How to avoid:**
- Maximum 2 levels of nesting from the root: `modules/01-setup/` — not deeper
- Each module directory has exactly one `README.md` that answers: what you'll build, what commands to run, what done looks like
- Use numeric prefixes on directories (01-, 02-) so filesystem sorting matches course progression — beginners can use `ls` and know what comes next
- Include a `CURRENT_MODULE` symlink or a `.course-progress` file that the installer/hooks update — students always have a "where am I?" anchor
- Test the structure with someone who has never seen it: give them 60 seconds to find where to write their first file

**Warning signs:**
- Module paths are longer than 60 characters
- No README.md at each module root
- Students ask "where do I put my code?" in support channels
- Directory names are semantic but not numbered (e.g., `typescript-basics/` not `03-typescript-basics/`)

**Phase to address:** Content structure phase. Lock the navigation structure before building any module content.

---

### Pitfall 8: PowerShell Execution Policy Blocking the Installer

**What goes wrong:**
Windows students download the installer `.ps1` script and double-click it. PowerShell's default execution policy (`Restricted` on Windows client) blocks all scripts. The student sees `cannot be loaded because running scripts is disabled on this system` and has no idea what this means or how to fix it.

**Why it happens:**
Developers who live on macOS/Linux write `install.sh` and then wrap it in a `.ps1` as an afterthought without testing on a fresh Windows machine. They don't account for the fact that the default Windows PowerShell policy explicitly blocks remote scripts.

**How to avoid:**
- The installer documentation must show exactly one Windows setup command — copy-pasteable, not explained in prose:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- The installer itself should begin with an execution policy check and self-fix:
  ```powershell
  if ((Get-ExecutionPolicy -Scope CurrentUser) -eq "Restricted") {
      Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
      Write-Host "Execution policy updated. You may need to re-run this script."
  }
  ```
- Alternatively: distribute as a `.cmd` file that invokes PowerShell with `-ExecutionPolicy Bypass` for the installer session only (scoped, not permanent)
- Document WSL 2 as the preferred path for Windows students — WSL gives them a proper bash environment and sidesteps most Windows-specific friction

**Warning signs:**
- Windows setup docs say "run the .ps1 script" without mentioning execution policy
- Installer has no PowerShell version detection (PowerShell 5.x vs 7.x behave differently)
- No WSL alternative documented for Windows students

**Phase to address:** Installer phase, Windows support sub-track.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Single monolithic CLAUDE.md | Easy to write and maintain as one file | Model ignores bottom half; students see inconsistent behavior | Never — use layered imports from day one |
| Hooks that block all violations | Strong quality signal | Students abandon course when blocked by false positives | Never for beginner modules; opt-in enforcement only |
| Installer that requires manual cleanup on failure | Simpler script | Students get stuck mid-install with no recovery path | Never — add cleanup/rollback to every destructive step |
| Hard-coding bash shebang with no shell detection | Works on developer's Mac | Breaks on zsh, fish, Windows Git Bash | Never — always detect or use `#!/usr/bin/env bash` |
| Same CLAUDE.md for all modules | Less to maintain | Beginners are overwhelmed; advanced students hit friction for basics | Acceptable only if module CLAUDE.md files layer on top |
| npm install without version pinning | Gets "latest" tools | Breaking changes in Claude Code CLI break all student setups silently | Acceptable in dev; pin versions before shipping |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Claude Code CLI global install | `npm install -g` without checking npm prefix ownership | Check `npm config get prefix` writability first; prefer nvm |
| `~/.claude/settings.json` merge | Overwrite the file with course settings | Deep-merge using jq; array fields (permissions.allow) concatenate, not replace |
| `~/.claude/CLAUDE.md` install | Write the file unconditionally | Check existence, backup with timestamp, append with delimiters |
| nvm PATH activation | Call `nvm use` then immediately use `node` in same shell | Re-source nvm init script or verify with full path |
| Hooks in `~/.claude/settings.json` | Add hooks that run globally on all student projects | Put course hooks in `.claude/settings.json` at the module level only |
| PowerShell + Windows PATH | Use Unix-style `export PATH=...` | Use `[Environment]::SetEnvironmentVariable()` for persistence |

---

## Performance Traps

For a course companion these are UX performance issues — specifically, things that make the learning experience feel slow or broken.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Too many hooks running on every file save | Claude Code feels sluggish; hooks fire 5+ times per operation | Scope hooks with specific matchers (e.g., `"matcher": "Write"` + file glob) rather than wildcard | Any module with 3+ hooks all matching `*` |
| CLAUDE.md > 3KB in a beginner module | Claude ignores rules at the bottom; inconsistent behavior | Keep under 80 lines; use `@import` for supplementary rules | First load of any session with a bloated CLAUDE.md |
| Installer downloads large tools without progress indication | Student thinks installer is frozen; kills process mid-install | Add progress output (`echo "Installing Node.js via nvm..."`) before every slow step | Any network download >5 seconds without feedback |
| Global hooks interfering with non-course projects | Student's personal projects start getting course-specific errors | Never install hooks to `~/.claude/settings.json`; put them in module-level `.claude/` | As soon as the student opens a non-course project |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Hook error message with no fix guidance | Student reads "VIOLATION: no export default" and has no path forward | Every hook output ends with "Fix: [exact code change needed]" |
| Installer with no progress output | Student stares at blank terminal for 2 minutes, thinks it crashed | `echo` before every major step; show spinner or dots for long operations |
| Module README that assumes terminal knowledge | Beginner can't complete first exercise | First module README must include "open your terminal" with OS-specific instructions and a screenshot |
| CLAUDE.md rules written for Claude, not for humans | Students reading CLAUDE.md to understand the project can't parse the terse style | Write rules as short sentences a human can read; avoid cryptic shorthand |
| "Existing config found" with no explanation of what changed | Student doesn't know if their setup is safe | Print a diff summary: "Added 3 rules to CLAUDE.md. Your original file is at X. Changes: [list]" |
| Numbered modules with gaps (01, 02, 05) | Students wonder if they missed modules 03 and 04 | Use sequential numbers with no gaps; if a module is removed, renumber |

---

## "Looks Done But Isn't" Checklist

- [ ] **Installer idempotency:** Run the installer twice on the same machine. Second run should produce zero changes and no errors.
- [ ] **Existing config preservation:** Install on a machine that has an existing `~/.claude/` setup. Verify originals are backed up and not overwritten.
- [ ] **Windows execution policy:** Test the `.ps1` installer on a fresh Windows machine with default PowerShell settings. Verify it either fixes the policy automatically or gives a clear, actionable error.
- [ ] **Hook advisory mode:** Trigger every hook intentionally with a violation. Verify the output message includes a concrete fix, not just a rule name.
- [ ] **CLAUDE.md rule coverage:** Remove the CLAUDE.md and ask Claude to write a component. Then re-add it. Verify behavior actually changes — if it doesn't, the rules are redundant.
- [ ] **Shell environment after install:** Open a fresh terminal window (not the install window) and verify `claude --version` works without manual PATH setup.
- [ ] **Module navigation:** Ask someone who hasn't seen the kit to find module 3 and run its first exercise. Time them. If it takes more than 2 minutes, the structure needs work.
- [ ] **nvm + PATH propagation:** Install Node via nvm in the installer, close the script, open a new terminal. Verify `node -v` works without re-sourcing manually.

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Installer destroyed existing `~/.claude/` config | MEDIUM | Restore from the timestamped backup the installer created. If no backup exists, student must reconstruct from memory — HIGH cost becomes critical. |
| Student running old Node.js version causing silent failures | LOW | Add a Node version check at module start: `node -v | grep -E "^v(18|20|22|23)"` |
| CLAUDE.md is too long and Claude is ignoring rules | LOW | Prune to under 80 lines, move the rest to `@imported` skill files. No data loss. |
| Blocking hook preventing all progress | LOW | Student can comment out the hook matcher in `.claude/settings.json` temporarily. Must be documented as an escape hatch. |
| Duplicate PATH entries from re-running installer | LOW | Run `sort -u ~/.zshrc > /tmp/zshrc_clean && mv /tmp/zshrc_clean ~/.zshrc` — but only safe if the user knows what they're doing. Better: installer should have prevented this. |
| PowerShell execution policy block | LOW | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` — one command, documented in the error output itself. |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Destructive global config install | Phase 1: Installer | Run installer on machine with existing `~/.claude/`; verify backup created |
| Blocking hooks frustrating beginners | Phase 2: Hooks design | Trigger every hook violation; verify message includes fix guidance; verify exit 0 not exit 2 |
| CLAUDE.md cognitive overload | Phase 2: Content architecture | Load CLAUDE.md; ask Claude to violate a rule near the bottom; verify it is caught |
| Shell environment not propagating | Phase 1: Installer | Open fresh terminal after install; verify `claude --version` works |
| Non-idempotent installer | Phase 1: Installer | Run installer twice; verify second run produces no changes |
| EACCES npm global install | Phase 1: Installer | Test on machine with system-owned npm prefix (non-nvm Node install) |
| Module workspace navigation confusion | Phase 3: Content structure | User test: 60 seconds to find first exercise |
| PowerShell execution policy | Phase 1: Installer (Windows) | Test on fresh Windows machine with default PowerShell policy |

---

## Sources

- [Claude Code Settings — official docs](https://code.claude.com/docs/en/settings) — config hierarchy, array merge behavior, `~/.claude/` structure (HIGH confidence)
- [Claude Code Best Practices — official docs](https://code.claude.com/docs/en/best-practices) — CLAUDE.md length guidance, hook vs CLAUDE.md tradeoffs, pruning discipline (HIGH confidence)
- [Claude Code Hooks Reference — official docs](https://code.claude.com/docs/en/hooks) — exit code semantics, blocking vs advisory behavior, hook event types (HIGH confidence)
- [npm EACCES permissions — official npm docs](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally/) — root cause and official solutions (HIGH confidence)
- [Writing a good CLAUDE.md — HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — 150-200 instruction ceiling, under 300 lines guidance, progressive disclosure pattern (MEDIUM confidence)
- [PowerShell Execution Policies — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) — default Restricted policy, RemoteSigned recommendation (HIGH confidence)
- [How to write idempotent Bash scripts — arslan.io](https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/) — conditional check patterns for rc files and directory creation (MEDIUM confidence)
- [fnm — Fast Node Manager](https://github.com/Schniz/fnm) — cross-platform alternative to nvm, Windows-native (HIGH confidence via GitHub)
- [set -e pitfalls — Xygeni](https://xygeni.io/blog/set-e-in-bash-why-your-script-fails-without-warning/) — silent failure modes in bash error handling (MEDIUM confidence)
- [Developer onboarding — why developers never finish — daily.dev](https://business.daily.dev/resources/why-developers-never-finish-your-onboarding-and-how-to-fix-it/) — 81% information overwhelm statistic, cognitive load research (MEDIUM confidence)

---
*Pitfalls research for: Claude Code course companion / developer education starter kit*
*Researched: 2026-03-10*
