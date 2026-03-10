# Requirements — Claude Code Mastery Starter Kit

## v1 Requirements

### Installer
- [ ] **INST-01**: Student can run one command on macOS/Linux to install Node.js, Git, pnpm, and Claude Code CLI
- [ ] **INST-02**: Student can run one command on Windows (PowerShell) to install the same stack
- [ ] **INST-03**: Installer backs up existing `~/.claude/` config before writing (timestamped backup)
- [ ] **INST-04**: Installer is idempotent (safe to re-run without duplication)
- [ ] **INST-05**: Installer clones starter kit to `~/Documents/claude-mastery-starter`

### Global Config
- [ ] **GLOB-01**: Installer places 5 beginner-friendly skills to `~/.claude/skills/lah-*/`
- [ ] **GLOB-02**: Installer places 3-5 beginner agents to `~/.claude/agents/lah-*.md`
- [ ] **GLOB-03**: Installer merges 5 teaching hooks into `~/.claude/settings.json` (advisory only, exit 0)
- [ ] **GLOB-04**: All global installs use `lah-` prefix to avoid collisions
- [ ] **GLOB-05**: Installer appends course section to `~/.claude/CLAUDE.md` with clear delimiters

### Module Structure
- [ ] **MOD-01**: Repo has 9 module folders matching course slugs
- [ ] **MOD-02**: Each module folder has a README with objectives and lesson list
- [ ] **MOD-03**: Key modules (1, 4, 6) have starter exercise files
- [ ] **MOD-04**: Each module folder has a `PROGRESS.md` checklist

### CLAUDE.md
- [ ] **CMD-01**: Root CLAUDE.md is under 80 lines with `@imports` for detailed sections
- [ ] **CMD-02**: CLAUDE.md teaches patterns via inline comments explaining WHY
- [ ] **CMD-03**: CLAUDE.md references correct stack: Next.js 16, React 19, Tailwind v4, TypeScript 5
- [ ] **CMD-04**: At least 3 module-scoped `.claude/CLAUDE.md` files (modules 1, 4, 9) showing progressive complexity

### Session Launcher
- [ ] **SESS-01**: `start.sh` launches Claude Code with teaching mode instructions
- [ ] **SESS-02**: `start.sh` accepts optional module number to scope the session
- [ ] **SESS-03**: Running `start.sh` without args shows available modules and prompts selection

### Project Scaffold
- [ ] **SCAF-01**: Next.js 16 + React 19 + Tailwind v4 + TypeScript scaffold works out of the box
- [ ] **SCAF-02**: `cn()` utility is included and properly configured
- [ ] **SCAF-03**: `.env.example` with all required variables documented
- [ ] **SCAF-04**: `.gitignore` covers .env, node_modules, .DS_Store, Claude Code logs

### Documentation
- [ ] **DOC-01**: README gets student from clone to first Claude Code session in under 5 minutes
- [ ] **DOC-02**: Troubleshooting section covers EACCES, command not found, PowerShell execution policy
- [ ] **DOC-03**: `UPGRADING.md` explains how to personalize and evolve the setup

---

## v2 Requirements (Deferred)

- Exercise validation hooks (complex, needs careful UX testing)
- Module-scoped settings.json showing hook progression across all 9 modules
- Git branch-based exercises (KCD pattern)
- MCP server examples for Module 9
- Video walkthrough links embedded in READMEs

## Out of Scope

- Course content (lives on academy.likeahuman.ai platform)
- Automated grading (non-deterministic AI outputs make binary pass/fail harmful)
- Production deployment config (this is a learning sandbox, not a production app)
- Real database dependencies (keeps starter kit lightweight)
- Payment/auth integration (handled by platform)

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| INST-01 | Phase 1 — Installer Foundation | Pending |
| INST-02 | Phase 1 — Installer Foundation | Pending |
| INST-03 | Phase 1 — Installer Foundation | Pending |
| INST-04 | Phase 1 — Installer Foundation | Pending |
| INST-05 | Phase 1 — Installer Foundation | Pending |
| SCAF-03 | Phase 1 — Installer Foundation | Pending |
| SCAF-04 | Phase 1 — Installer Foundation | Pending |
| GLOB-01 | Phase 2 — Global Config Content | Pending |
| GLOB-02 | Phase 2 — Global Config Content | Pending |
| GLOB-03 | Phase 2 — Global Config Content | Pending |
| GLOB-04 | Phase 2 — Global Config Content | Pending |
| GLOB-05 | Phase 2 — Global Config Content | Pending |
| MOD-01 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| MOD-02 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| MOD-03 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| MOD-04 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| CMD-01 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| CMD-02 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| CMD-03 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| CMD-04 | Phase 3 — Module Structure and CLAUDE.md | Pending |
| SESS-01 | Phase 4 — Session Launcher | Pending |
| SESS-02 | Phase 4 — Session Launcher | Pending |
| SESS-03 | Phase 4 — Session Launcher | Pending |
| SCAF-01 | Phase 5 — Scaffold and Docs | Pending |
| SCAF-02 | Phase 5 — Scaffold and Docs | Pending |
| DOC-01 | Phase 5 — Scaffold and Docs | Pending |
| DOC-02 | Phase 5 — Scaffold and Docs | Pending |
| DOC-03 | Phase 5 — Scaffold and Docs | Pending |
