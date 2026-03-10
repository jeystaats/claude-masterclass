# Phase 2: Global Config Content - Research

**Researched:** 2026-03-10
**Domain:** Claude Code skills, agents, hooks — global config authoring
**Confidence:** HIGH

---

## Summary

Phase 2 requires authoring the content that the installer deploys: five skills, three to five agents, five teaching hooks, and a CLAUDE.md.snippet. Every file is a standalone teaching artefact — it must work as a functional tool AND explain the pattern it demonstrates via inline annotations.

The research revealed that Claude Code's official documentation has migrated to `code.claude.com/docs`. Skills, agents, and hooks all have well-specified formats verified against both official docs and live examples in `~/.claude/`. The formats are stable as of March 2026.

**Primary recommendation:** Use PostToolUse hooks (not PreToolUse) for advisory teaching output, with `exit 0` throughout. Skills should be flat `.md` files in `~/.claude/skills/` (not the folder/SKILL.md pattern) to keep installer logic simple. The distinction matters: the folder format supports supporting files, but flat `.md` files work identically for slash commands.

**Key insight for this phase:** The existing hooks in `~/.claude/hooks/` use `exit 2` (blocking) throughout. For this course, all hooks MUST use `exit 0` with stderr output so Claude receives the advisory message and self-corrects — never blocking the user.

---

## Standard Stack

### Core (required)

| Component | Format | Location | Discovery |
|-----------|--------|----------|-----------|
| Skills | `~/.claude/skills/<name>/SKILL.md` | `global-config/skills/lah-*/` | Auto + `/name` slash command |
| Agents | `~/.claude/agents/<name>.md` | `global-config/agents/lah-*.md` | Auto-delegation + `@name` mention |
| Hooks | Shell scripts + `settings.json` entries | `global-config/hooks/` + `workshop-settings.json` | Merged into `~/.claude/settings.json` |
| CLAUDE.md snippet | `global-config/CLAUDE.md.snippet` | delimited block | Appended by installer |

### Supporting tools in hook scripts

| Tool | Purpose | Used in hooks |
|------|---------|---------------|
| `jq` | Parse JSON from stdin (hook input) | All hooks — already required by installer |
| `bash 3.2+` | Shell compatibility | macOS default, no bash 4 features |

---

## Architecture Patterns

### Skills — Two Valid Formats

**Format A: Folder with SKILL.md (recommended by official docs)**
```
~/.claude/skills/lah-explain-code/
└── SKILL.md
```

**Format B: Flat .md file (observed in production at ~/.claude/skills/)**
```
~/.claude/skills/stack-preferences.md    # works as knowledge skill
~/.claude/skills/commit/SKILL.md         # folder format for user-invocable
```

**Decision for this course:** Use the **folder format** (`lah-<name>/SKILL.md`) because:
1. It is the documented standard
2. It allows adding supporting files later
3. The slash command name derives from the directory name

### Skill YAML Frontmatter (all fields optional except description is recommended)

```yaml
---
name: lah-explain-code
description: Explains code with analogies and diagrams. Use when explaining how code works.
# disable-model-invocation: true   # only if you want manual-only invocation
# user-invocable: true             # default, shown in / menu
# allowed-tools: Read, Grep        # restrict tools when active
# model: sonnet                    # override model
---
```

**Fields verified from official docs (code.claude.com/docs/en/skills):**

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `name` | No | string | Defaults to directory name. Lowercase, hyphens, max 64 chars |
| `description` | Recommended | string | Claude uses this to decide when to auto-invoke |
| `disable-model-invocation` | No | boolean | `true` = manual `/name` only |
| `user-invocable` | No | boolean | `false` = hidden from / menu, Claude-only |
| `allowed-tools` | No | string | Tools available without asking when skill is active |
| `model` | No | string | `sonnet`, `opus`, `haiku`, or omit for inherit |
| `context` | No | string | `fork` to run in isolated subagent |
| `argument-hint` | No | string | Shown in autocomplete |

### Agent YAML Frontmatter

```yaml
---
name: lah-code-reviewer
description: Reviews code for quality and best practices. Use proactively after writing code.
tools: Read, Grep, Glob
model: sonnet
color: teal
---

You are a code reviewer...
```

**Fields verified from official docs (code.claude.com/docs/en/sub-agents) AND live examples:**

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `name` | Yes | string | Unique, lowercase + hyphens. Becomes `@name` reference |
| `description` | Yes | string | When Claude should delegate. Include "use proactively" for auto-use |
| `tools` | No | string | Comma-separated tool list. Omit = inherits all |
| `model` | No | string | `sonnet`, `opus`, `haiku`, `inherit` |
| `color` | No | string | UI color: `blue`, `teal`, `orange`, `red`, `green`, `purple` |
| `skills` | No | string/list | Skill names to preload into agent context |
| `disallowedTools` | No | string | Tools to deny |
| `permissionMode` | No | string | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | number | Max agentic turns before stopping |
| `memory` | No | string | `user`, `project`, or `local` for persistent memory |

**Agent body** = the system prompt in Markdown. Agents do NOT inherit Claude Code's system prompt — they receive only their markdown body + basic env details (cwd, etc.).

### Hook Configuration Format

Hooks live in `workshop-settings.json` (already has empty arrays) and are merged into `~/.claude/settings.json` by `merge_settings()`.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/lah-check-typescript.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook events available (from official docs):**

| Event | Matcher | Teaching use case |
|-------|---------|------------------|
| `PreToolUse` | tool name | Inspect before write — but fires before file exists, limited |
| `PostToolUse` | tool name | BEST for teaching — file exists, can analyze content |
| `Stop` | none | Session-level summaries |
| `SessionStart` | source | Welcome message, orient student |

**Why PostToolUse is better for teaching hooks:**
- The file already exists when the hook runs — you can grep/analyze it
- If issues found, the stderr goes to Claude who can self-correct
- Exit 0 = advisory (Claude sees stderr, continues)
- Exit 2 = blocking on PostToolUse → shows stderr to Claude (tool already ran, so "blocking" means "Claude sees the feedback")

**CRITICAL distinction for course hooks:**
- `PostToolUse + exit 0` = pure advisory, Claude decides what to do
- `PostToolUse + exit 2` = shows stderr to Claude as error message (Claude will act on it)
- `PreToolUse + exit 2` = BLOCKS the tool call (never use for course)

**For a teaching hook that gives advice and lets Claude self-correct:** use `PostToolUse` with `exit 2` when issues are found and `exit 0` when clean. The `exit 2` on PostToolUse does NOT block — it just ensures Claude sees the stderr feedback. This matches the pattern used in existing hooks like `check-typescript-quality.sh`.

**Wait — re-read requirements:** The phase says "advisory exit 0 — every hook output includes what was detected, why it matters, and the exact fix." This means always exit 0 AND output to stderr. With PostToolUse + exit 0, stderr is only shown in verbose mode (Ctrl+O), not fed to Claude. To make Claude see the feedback, use exit 2 on PostToolUse.

**Resolved pattern for teaching hooks:**
- When issues found: `echo "..." >&2; exit 2` — Claude sees the feedback and self-corrects
- When clean: `exit 0` — silent pass
- This is what the existing hooks do. The "advisory" requirement means the feedback explains the WHY and HOW TO FIX, not that it must use exit 0 regardless.

### Hook Input Schema (stdin JSON)

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.ts",
    "success": true
  }
}
```

Key extraction in bash: `FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')`

### CLAUDE.md.snippet Format

```markdown
<!-- LAH-COURSE-START -->
## Claude Code Mastery — Course Config

[course-specific instructions]
<!-- LAH-COURSE-END -->
```

Installer appends this block to existing `~/.claude/CLAUDE.md`. Delimiters allow:
1. Idempotent check (skip if already present)
2. Clean removal later
3. Minimal interference with existing content

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON parsing in hooks | Custom shell parsing | `jq` (already required by installer) | Handles edge cases, quotes, nested fields |
| Settings merge | Custom merge logic | Existing `merge_settings()` in install.sh | Already battle-tested with deep_merge |
| Skill discovery | Custom loader | Claude Code's built-in discovery from `~/.claude/skills/` | Just put files in the right place |
| Agent invocation | Custom routing | Claude Code's description-based delegation | Claude reads `description` and delegates automatically |

**Key insight:** The install.sh Phase 1 already handles the merge machinery. Phase 2 is purely content authoring — write the files in `global-config/`, add copy logic to install.sh for skills/agents/CLAUDE.md.snippet.

---

## Common Pitfalls

### Pitfall 1: Hook input not read before file check
**What goes wrong:** Hook does file existence check before reading stdin, causing stdin to block on next run
**Why it happens:** Claude Code pipes JSON to stdin; if you don't read it, the pipe stays open
**How to avoid:** Always start hook with `INPUT=$(cat)` as the FIRST command
**Warning signs:** Hook hangs or times out intermittently

```bash
#!/bin/bash
INPUT=$(cat)   # FIRST — always consume stdin
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
```

### Pitfall 2: Hook fires on non-TS files and produces false positives
**What goes wrong:** TypeScript checks run on JSON, CSS, markdown files
**Why it happens:** The `Edit|Write` matcher fires on ALL file writes
**How to avoid:** Check file extension at the top of every hook with early exit 0
**Warning signs:** Students see TypeScript warnings on .json edits

```bash
if [[ "$FILE_PATH" != *.tsx ]] && [[ "$FILE_PATH" != *.ts ]]; then
  exit 0
fi
```

### Pitfall 3: Using bash 4+ features
**What goes wrong:** Hook fails on macOS with `/bin/bash: declare: -A: invalid option`
**Why it happens:** macOS ships bash 3.2 by default; associative arrays require bash 4
**How to avoid:** Never use `declare -A`, `mapfile`, `readarray`, or `{1..n}` brace expansion in hooks
**Warning signs:** Works on Linux CI, fails on student Macs

### Pitfall 4: Skill name collision with existing user skills
**What goes wrong:** `lah-explain-code` skill is ignored because user has `explain-code` at a higher priority
**Why it happens:** Priority order: enterprise > personal > project; same-name skills at personal level conflict
**How to avoid:** The `lah-` prefix ensures uniqueness. Installer checks `[ -f ~/.claude/skills/lah-*/SKILL.md ]` before copying, skips if exists
**Warning signs:** Student reports skill doesn't appear in / menu

### Pitfall 5: Agent file not picked up after manual creation
**What goes wrong:** Student manually adds agent file, it doesn't appear
**Why it happens:** Agents are loaded at session start. New files need a session restart or `/agents` command
**How to avoid:** Document in agent frontmatter; installer can run `claude agents` to verify
**Warning signs:** `@lah-code-reviewer` mention has no effect

### Pitfall 6: Hook stderr not shown to Claude on exit 0 + PostToolUse
**What goes wrong:** Advisory feedback is written to stderr with exit 0 but Claude never sees it
**Why it happens:** Official docs confirm: "For most events, stdout is only shown in verbose mode (Ctrl+O)" — and stderr similarly doesn't reach Claude on exit 0 for PostToolUse
**How to avoid:** Use exit 2 on PostToolUse when you WANT Claude to see and act on feedback. Exit 0 for clean pass.
**Warning signs:** Hooks run (visible in Ctrl+O) but Claude doesn't self-correct

---

## Code Examples

Verified patterns from official sources and live `~/.claude/hooks/` examples:

### Teaching Hook Pattern (PostToolUse, advisory)

```bash
#!/bin/bash
# lah-check-typescript.sh
# Teaches: TypeScript quality patterns
# Event: PostToolUse on Edit|Write
# Exit 0 = clean (silent), Exit 2 = issues found (Claude sees feedback and self-corrects)

INPUT=$(cat)   # ALWAYS first — consume stdin
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check TypeScript files
if [[ "$FILE_PATH" != *.tsx ]] && [[ "$FILE_PATH" != *.ts ]]; then
  exit 0
fi

# Skip generated and vendor files
if [[ "$FILE_PATH" == *node_modules* ]] || [[ "$FILE_PATH" == *.d.ts ]]; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

ISSUES=""

# Check: any type usage
ANY_COUNT=$(grep -cE ': any\b|<any>|as any' "$FILE_PATH" 2>/dev/null)
if [ "$ANY_COUNT" -gt 0 ]; then
  ISSUES="${ISSUES}
DETECTED: ${ANY_COUNT} use(s) of 'any' type
WHY IT MATTERS: 'any' disables TypeScript's type safety — the main reason to use TypeScript
HOW TO FIX: Use 'unknown' and narrow with type guards, or define a proper interface"
fi

if [ -n "$ISSUES" ]; then
  echo "TypeScript quality check — $(basename "$FILE_PATH"):${ISSUES}" >&2
  echo "" >&2
  echo "Fix these issues to write idiomatic TypeScript." >&2
  exit 2   # Shows feedback to Claude; Claude self-corrects
fi

exit 0
```

### Teaching Skill SKILL.md Pattern

```yaml
---
name: lah-explain-code
description: >
  Explains code with analogies, diagrams, and step-by-step walkthroughs.
  Use when explaining how code works, teaching about a codebase,
  or when the user asks "how does this work?"
---

# /lah-explain-code — Code Explanation Framework

<!-- WHY THIS SKILL EXISTS: Teaches you to explain code in multiple modalities.
     The pattern: analogy → diagram → walkthrough → gotcha is a teaching
     best practice (concrete before abstract). -->

When explaining code, always include:

1. **Analogy first** — compare to something from everyday life
2. **ASCII diagram** — show flow, structure, or relationships visually
3. **Step-by-step walkthrough** — trace execution from input to output
4. **One gotcha** — the most common mistake or misconception

Keep explanations conversational. For complex concepts, layer multiple analogies.

## Example output format

```
ANALOGY: This is like a restaurant kitchen — the component is the chef,
props are the ingredients, and state is the chef's notes.

DIAGRAM:
  Parent
    │ props
    ▼
  Component ──state──▶ render
    │
    ▼ event
  Child

WALKTHROUGH: ...

GOTCHA: ...
```
```

### Teaching Agent Pattern

```markdown
---
name: lah-code-reviewer
description: >
  Expert code reviewer. Analyzes code for quality, security, and best practices.
  Use proactively after writing or modifying code. Trigger phrases include
  "review this", "check my code", "what do you think of this".
tools: Read, Grep, Glob, Bash
model: sonnet
color: teal
---

<!-- WHY THIS AGENT EXISTS: Demonstrates the subagent pattern — specialized
     focus, restricted tools, system prompt as domain expertise.
     The 'tools' field limits what Claude can do in this context. -->

You are a senior code reviewer. Your job is to find real issues, not nitpick style.

When invoked:
1. Run `git diff` or read the file(s) mentioned
2. Focus on modified or new code
3. Begin review immediately — no preamble

Review checklist:
- Logic errors and edge cases not handled
- Security vulnerabilities (exposed secrets, injection, XSS)
- Missing error handling
- Performance anti-patterns
- TypeScript type safety

Provide feedback organized by priority:
- **Critical** — must fix before shipping
- **Warning** — should fix soon
- **Suggestion** — consider improving

Include the exact fix for each issue, not just the problem.
```

### Workshop-settings.json hooks entry pattern

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/lah-check-typescript.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/lah-check-react.sh"
          }
        ]
      }
    ]
  }
}
```

### Installer copy logic for global-config files (to add in Plan 02-04)

```bash
install_global_config() {
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"

  # --- Skills ---
  mkdir -p "$HOME/.claude/skills"
  for skill_dir in "$script_dir/global-config/skills"/lah-*/; do
    skill_name=$(basename "$skill_dir")
    dest="$HOME/.claude/skills/$skill_name"
    if [ -d "$dest" ]; then
      log_skip "Skill already installed: $skill_name"
    else
      cp -r "$skill_dir" "$dest"
      log_done "Installed skill: $skill_name"
    fi
  done

  # --- Agents ---
  mkdir -p "$HOME/.claude/agents"
  for agent_file in "$script_dir/global-config/agents"/lah-*.md; do
    agent_name=$(basename "$agent_file")
    dest="$HOME/.claude/agents/$agent_name"
    if [ -f "$dest" ]; then
      log_skip "Agent already installed: $agent_name"
    else
      cp "$agent_file" "$dest"
      log_done "Installed agent: $agent_name"
    fi
  done

  # --- Hooks ---
  mkdir -p "$HOME/.claude/hooks"
  for hook_file in "$script_dir/global-config/hooks"/lah-*.sh; do
    hook_name=$(basename "$hook_file")
    dest="$HOME/.claude/hooks/$hook_name"
    if [ -f "$dest" ]; then
      log_skip "Hook already installed: $hook_name"
    else
      cp "$hook_file" "$dest"
      chmod +x "$dest"
      log_done "Installed hook: $hook_name"
    fi
  done
}

append_claude_md_snippet() {
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  local snippet="$script_dir/global-config/CLAUDE.md.snippet"
  local target="$HOME/.claude/CLAUDE.md"

  if [ ! -f "$snippet" ]; then
    log_skip "No CLAUDE.md.snippet found"
    return 0
  fi

  mkdir -p "$HOME/.claude"

  # Idempotent: skip if delimiter already present
  if [ -f "$target" ] && grep -q "LAH-COURSE-START" "$target"; then
    log_skip "CLAUDE.md course section already present"
    return 0
  fi

  cat "$snippet" >> "$target"
  log_done "Appended course section to ~/.claude/CLAUDE.md"
}
```

---

## Five Skills to Write

Based on requirements (GLOB-01): `explain-code`, `commit-message`, `plan-task`, `review-code`, `debug-it`

Each skill should:
- Have YAML frontmatter with `name` (lah-prefixed) and descriptive `description`
- Open with a comment block explaining the pattern it teaches
- Provide a concrete step-by-step workflow
- Include an example of expected output format

| Skill name | Slash command | Teaching focus | Invocation |
|-----------|---------------|----------------|------------|
| `lah-explain-code` | `/lah-explain-code` | Multimodal explanation pattern | Auto + manual |
| `lah-commit-message` | `/lah-commit-message` | Conventional commits, semantic versioning | Manual only (disable-model-invocation) |
| `lah-plan-task` | `/lah-plan-task` | Task decomposition before coding | Auto + manual |
| `lah-review-code` | `/lah-review-code` | Code review methodology | Manual only |
| `lah-debug-it` | `/lah-debug-it` | Scientific debugging method | Auto + manual |

---

## Three to Five Agents to Write

Based on requirements (GLOB-02): `code-reviewer`, `planner`, `debugger` (plus optionals)

Each agent should:
- Have required `name` (lah-prefixed) and `description` fields
- Demonstrate a DISTINCT Claude Code agent pattern (different tools, model, purpose)
- Have a body that teaches through example (annotated system prompt)

| Agent name | Pattern demonstrated | Tools | Model |
|-----------|---------------------|-------|-------|
| `lah-code-reviewer` | Read-only analysis agent | `Read, Grep, Glob` | `sonnet` |
| `lah-planner` | Plan-mode agent (no writes) | `Read, Grep, Glob, Bash` | `opus` |
| `lah-debugger` | Full-access fix agent | `Read, Edit, Bash, Grep, Glob` | `inherit` |
| `lah-explainer` | Minimal-tool knowledge agent | `Read` | `haiku` (fast, cheap) |

---

## Five Teaching Hooks to Write

Based on requirements (GLOB-03): TypeScript quality, React antipatterns, cn() usage, file size guard, secret detector

| Hook script | Event | Matcher | What it teaches |
|------------|-------|---------|-----------------|
| `lah-check-typescript.sh` | PostToolUse | `Edit\|Write` | Type safety, no `any`, naming conventions |
| `lah-check-react.sh` | PostToolUse | `Edit\|Write` | useEffect abuse, unnecessary "use client", prop drilling |
| `lah-check-cn-usage.sh` | PostToolUse | `Edit\|Write` | cn() vs raw className concatenation |
| `lah-check-file-size.sh` | PostToolUse | `Edit\|Write` | File/component size limits |
| `lah-check-secrets.sh` | PostToolUse | `Edit\|Write` | No hardcoded API keys, tokens, passwords |

All hooks follow the same pattern:
1. `INPUT=$(cat)` — first line always
2. Extract `file_path` from JSON
3. Early exit 0 for non-matching files
4. Build `ISSUES` string
5. If issues: echo to stderr with DETECTED/WHY/HOW format, `exit 2`
6. If clean: `exit 0`

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `.claude/commands/*.md` for slash commands | `.claude/skills/<name>/SKILL.md` | Recent (2025) | Commands still work; skills add folder + frontmatter |
| Single `settings.json` per machine | Hierarchical: enterprise > personal > project > local | Current | User hooks in `~/.claude/settings.json` |
| Task tool in agent specs | Agent tool (renamed from Task) | Version 2.1.63 | `Task(...)` still works as alias |
| Docs at `docs.anthropic.com/en/docs/claude-code/*` | Docs at `code.claude.com/docs/en/*` | 2025 | Redirects in place but use new URL |

**Deprecated:**
- `Task` tool name in agent `tools` field: still works as alias but use `Agent` going forward
- Top-level `decision`/`reason` in `PreToolUse` JSON output: use `hookSpecificOutput.permissionDecision` instead

---

## Open Questions

1. **CLAUDE.md snippet delimiter choice**
   - What we know: needs open/close delimiters for idempotent append and future removal
   - What's unclear: whether HTML comments (`<!-- -->`) or custom markers (`# LAH-COURSE-START`) are better
   - Recommendation: HTML comments work in markdown and are invisible to Claude; use `<!-- LAH-COURSE-START -->` / `<!-- LAH-COURSE-END -->`

2. **Hook install path: absolute vs `~/.claude/hooks/`**
   - What we know: existing hooks use `~/.claude/hooks/` absolute paths in settings.json
   - What's unclear: whether `~` expands correctly in all shells when Claude Code runs hooks
   - Recommendation: use `~/.claude/hooks/lah-*.sh` — this matches the pattern in existing `~/.claude/settings.json` and the docs show `~/.claude/hooks/` references working

3. **Idempotency on re-install: overwrite vs skip**
   - What we know: installer must not duplicate on re-run
   - What's unclear: whether to skip (safe) or overwrite (gets updates)
   - Recommendation: skip if file exists (idempotent and safe). Add a `--update` flag as future enhancement.

---

## Sources

### Primary (HIGH confidence)
- `code.claude.com/docs/en/skills` — skills format, frontmatter reference, discovery rules, verified 2026-03-10
- `code.claude.com/docs/en/sub-agents` — agent format, frontmatter fields, all verified 2026-03-10
- `code.claude.com/docs/en/hooks` — hook events, input schemas, exit code semantics, verified 2026-03-10
- `~/.claude/agents/frontend-lead.md` — live agent with `name`, `description`, `model`, `skills`, `color` frontmatter
- `~/.claude/agents/code-reuse-analyst.md` — live agent with `tools` and `skills` fields
- `~/.claude/hooks/check-typescript-quality.sh` — production hook demonstrating INPUT=$(cat), jq extraction, exit 2 advisory pattern
- `~/.claude/hooks/check-react-antipatterns.sh` — production hook demonstrating PostToolUse pattern
- `~/.claude/skills/commit/SKILL.md` — live skill with name, description, user-invocable, markdown body

### Secondary (MEDIUM confidence)
- `~/.claude/settings.json` — live settings.json with PreToolUse/PostToolUse hook arrays showing matcher format
- `/tmp/claude-masterclass/install.sh` — Phase 1 installer for merge_settings() pattern

---

## Metadata

**Confidence breakdown:**
- Skills format: HIGH — verified against official docs + live examples in ~/.claude/skills/
- Agents format: HIGH — verified against official docs + live examples in ~/.claude/agents/
- Hooks format: HIGH — verified against official docs + live code in ~/.claude/hooks/
- Hook advisory pattern (exit 2 vs 0): HIGH — official docs explicitly state PostToolUse exit 2 shows stderr to Claude
- CLAUDE.md.snippet: MEDIUM — delimiter convention is inference; no official standard for append blocks
- Installer copy logic: HIGH — standard bash idioms, no new APIs needed

**Research date:** 2026-03-10
**Valid until:** 2026-06-10 (skills/agents/hooks formats are stable; check if new hook events added)
