# Feature Research

**Domain:** Developer education starter kit — Claude Code Mastery course companion
**Researched:** 2026-03-10
**Confidence:** HIGH (Claude Code docs from official source; peer kit analysis from live repos)

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features learners assume exist. Missing these = kit feels incomplete or unprofessional.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Module-aligned workspace folders | Every course repo (Wes Bos, KCD, fCC) organises files by lesson/module. Students need orientation. | LOW | `module-01-getting-started/`, `module-02-engineering-lead/`, etc. Each folder = one course module. |
| README with clear first-step instructions | First thing every learner opens. If it doesn't tell them what to do in 60 seconds, they leave. | LOW | Must cover: clone → install → verify → open Claude Code. No jargon. |
| Environment verification script | Epic Workshop App does this; every university CS course does it. Prevents "it doesn't work on my machine" DMs. | MEDIUM | Bash + PowerShell scripts. Checks: Node.js ≥ 18, Git, Claude Code CLI, API key set. Outputs pass/fail per check with fix instructions. |
| Cross-platform setup (macOS / Windows / Linux) | Audience is beginners. They're on every OS. Failing on Windows kills course credibility. | MEDIUM | Three install paths. Windows needs winget or WSL2 guidance. macOS uses Homebrew. Linux uses apt/nvm. |
| Pre-written CLAUDE.md that works out of the box | Learners come to the course to learn how to use CLAUDE.md. They need a working model to study and modify. | LOW | Placed at repo root. Must teach patterns via inline comments explaining WHY each section exists. |
| Starter exercises with clear problem/solution separation | Wes Bos: `starter-files/` + `stepped-solutions/`. KCD: `*.problem.*` + `*.solution.*`. Students expect this pattern. | LOW | Each module folder has `exercises/` subfolder with `.starter` and `.solution` variants. |
| .gitignore pre-configured | Every developer starter kit includes this. Missing it means beginners accidentally commit `.env` files. | LOW | Covers `.env`, `node_modules/`, `.DS_Store`, `*.local`, Claude Code session logs. |
| .env.example with all required variables | Beginners don't know what env vars they need. A broken `.env` setup is the #1 support request for any course. | LOW | `ANTHROPIC_API_KEY=your_key_here` with inline comments explaining where to get each key. |
| At least one working CLAUDE.md per module | Students need to see Claude Code behaving differently in different project contexts. | MEDIUM | Each module folder has its own `.claude/CLAUDE.md` scoped to that module's learning objectives. |
| License file | Professional expectation. Open source standard. | LOW | MIT license is the convention for educational repos. |

---

### Differentiators (Competitive Advantage)

Features that set this kit apart from generic "clone this repo" course starters. These are what make students tell others about the course.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Instructional hooks that explain WHY | No other course starter does this. A `PostToolUse` hook that prints "Claude just edited a file. Here's why that matters for your workflow..." transforms passive learners into active ones. | MEDIUM | Hooks live in `.claude/settings.json`. Use `type: "command"` with `echo` output to inject teaching moments. e.g., after a `Write` event, surface a tip about file safety. |
| Pre-built beginner agents with documented personas | KCD uses fictional character guides (Kody, Marty). This kit ships with real, working Claude Code agents as `.claude/agents/` files that model expert behaviour learners can study and extend. | MEDIUM | Start with 3-5 agents: `code-reviewer.md`, `planner.md`, `debugger.md`. Each agent's SKILL.md includes a "What I am and why" section at the top. |
| Curated global skills installer | No existing course ships skills to `~/.claude/skills/`. This kit includes an `install-global-skills.sh` script that places a curated set of beginner-friendly skills globally so they work in any project. | MEDIUM | Skills: `explain-code`, `commit-message`, `code-review`, `plan-task`. Each SKILL.md has heavy commenting explaining the frontmatter fields. |
| Module progress checklist (markdown) | Epic Workshop App has progress tracking UI. This kit has a simpler but learnable version: a `PROGRESS.md` in each module that students fill in as they complete lessons. | LOW | Checkbox markdown. Learners get the satisfaction of checking off items. No server required. |
| "Read this before asking Claude" inline patterns | The CLAUDE.md teaches Claude Code conventions while simultaneously teaching the learner. Comments like `# WHY THIS SECTION EXISTS: ...` turn the config file into a lesson. | LOW | Apply to root CLAUDE.md and all module CLAUDE.mds. This is a writing/content decision, not a technical feature. |
| Validation hooks for exercises | After a student completes an exercise, a `Stop` hook runs a lightweight check (e.g., does the expected output file exist? Does `git diff` show expected changes?) and prints a "you did it" or "check these things" message. | HIGH | Start with 2-3 modules only. Use `type: "prompt"` hooks so Claude evaluates the output rather than a rigid regex check. This is complex to build correctly — defer to v1.x. |
| Module-scoped settings.json examples | Each module has its own `.claude/settings.json` showing the hooks relevant to that lesson. Students can literally diff how hooks evolve from module to module. | LOW | This is pedagogically unique. Module 1 has zero hooks. Module 6 has 4. Module 9 has a full setup. |
| Annotated skills as learning artefacts | Each skill file in the kit has a `## How this skill works` section explaining its frontmatter choices. A learner reading `commit-message/SKILL.md` learns the full skills format from a single file. | LOW | Pure content/writing work. No new technical complexity. |
| Upgrade path documentation | A `UPGRADING.md` that explains how to fork this kit, personalise it, and evolve the CLAUDE.md as they level up through the course. Modelled on T3 Stack's "What's next" philosophy. | LOW | Documents the deliberate evolution from "basic CLAUDE.md" to "full hooks + skills + agents" setup. |

---

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem logical but create friction, maintenance burden, or pedagogical harm.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Auto-install Claude Code CLI during setup | Convenience. Students want one script that handles everything. | Claude Code requires the user to authenticate interactively. Cannot be scripted. Also, running arbitrary scripts that install global CLIs is a security smell for beginners. | Provide a clear `SETUP.md` with copy-pasteable commands per OS. Verification script checks if CLI is installed but does not install it. |
| Interactive web UI progress tracker | Epic Workshop App has one. Students may expect it. | Requires a server, Node.js tooling, and adds a maintenance surface that's orthogonal to teaching Claude Code. Beginners spend time debugging the tracker, not learning. | Markdown progress checklists (`PROGRESS.md`) per module. Zero dependencies. |
| Automated solution grading / test suite | freeCodeCamp and Codecademy grade exercises programmatically. Beginners expect it. | Claude Code is non-deterministic. Grading a conversation output is not feasible. Binary pass/fail tests discourage the exploratory mindset Claude Code requires. Sets wrong expectations. | Use `type: "prompt"` hooks as soft validators that suggest, not grade. Frame exercises as "conversations to have" not "tests to pass". |
| Pre-configured MCP servers | Power users want a full MCP setup out of the box. | MCP requires credentials (GitHub tokens, Notion API keys) that beginners don't have. A broken MCP setup on first run destroys confidence. | Include a `NEXT-STEPS.md` in the final module pointing to MCP setup guides. Keep the base kit credential-free. |
| `pnpm` / `yarn` / `bun` as the default package manager | Some instructors prefer these. | Beginners know `npm`. Any deviation adds an install step and a mental model shift before they've even started. T3 App uses pnpm but they have the audience for it. | Use `npm` as the default. Add a note that `pnpm` is a valid alternative for learners who already know it. |
| Git hooks via Husky | Some developers auto-run linters on commit. | Adds a devDependency, requires `npm install`, can fail in unexpected ways on Windows, and is orthogonal to the Claude Code learning objective. | Teach Claude Code's built-in `PreToolUse` hooks on Bash commands instead. That's more relevant to the course topic. |
| Multiple CLAUDE.md "variations" per module | Covering every possible setup variation seems thorough. | Cognitive overload. Beginners can't evaluate tradeoffs. Analysis paralysis. | One opinionated CLAUDE.md per module. Explain why it's built the way it is. Mention alternatives in comments only. |
| Discord/Slack integration hooks | Looks impressive in demos. | Requires server setup, credentials, and is not relevant to the core Claude Code workflow being taught. | Teach the notification hook pattern (macOS `osascript`) as it works out of the box with zero credentials. |

---

## Feature Dependencies

```
Environment Verification Script
    └──requires──> .env.example (to know which vars to check)
    └──requires──> SETUP.md (to point to fix instructions)

Module CLAUDE.md files
    └──requires──> Root CLAUDE.md (establishes the pattern)
    └──enhances──> Module-scoped settings.json (hooks teach via CLAUDE.md context)

Global Skills Installer (install-global-skills.sh)
    └──requires──> Skills directory with valid SKILL.md files
    └──enhances──> Annotated skills as learning artefacts (skills are only useful if documented)

Instructional Hooks (settings.json per module)
    └──requires──> Module workspace folders (hooks are scoped to a directory)
    └──requires──> Learner has Claude Code ≥ version with hook support

Pre-built Beginner Agents (.claude/agents/)
    └──requires──> Root CLAUDE.md (agents inherit from project context)
    └──enhances──> Module progress checklists (agent files document what each module teaches)

Validation Hooks (exercise checkers)
    └──requires──> Module exercises with defined expected outputs (HIGH complexity)
    └──requires──> Instructional Hooks (same settings.json infrastructure)
    └──conflicts──> Automated solution grading anti-feature (must remain advisory, not binary)

Module Progress Checklists (PROGRESS.md)
    └──requires──> Module-aligned workspace folders
    └──enhances──> Upgrade path documentation (learners track their journey)

Upgrade Path Documentation (UPGRADING.md)
    └──requires──> All other features to exist so there is something to document upgrading from
```

### Dependency Notes

- **Environment verification requires .env.example:** The script needs to know which variables to check existence for. Build `.env.example` first.
- **Module CLAUDE.mds require root CLAUDE.md:** Students learn the pattern at root level first. Module-scoped variants build on that mental model.
- **Global skills installer requires annotated SKILL.md files:** Installing undocumented skills is worthless for learners. Content and code ship together.
- **Validation hooks conflict with grading anti-feature:** Validation hooks must always be advisory. If they become binary pass/fail, they become the grading anti-feature. The constraint is in the prompt design, not the hook type.

---

## MVP Definition

### Launch With (v1)

The minimum viable kit that makes the course feel professional and teaches the key Claude Code concepts.

- [ ] Module-aligned workspace folders (9 folders, one per course module) — orientation is non-negotiable
- [ ] Root `CLAUDE.md` with instructional comments — this is the course's primary teaching artefact
- [ ] Module-scoped CLAUDE.md files (at least modules 1, 4, 8) — shows how context evolves
- [ ] Environment verification script (macOS + Linux) — stops 80% of "it doesn't work" support tickets
- [ ] `.env.example` with `ANTHROPIC_API_KEY` and inline comments — prevents the #1 beginner mistake
- [ ] README with ≤ 5 steps to first successful Claude Code run — first impression cannot be fixed after ship
- [ ] Module-scoped `settings.json` examples (modules 1, 6, 9) — concrete diff showing hook evolution
- [ ] 3 annotated skills: `explain-code`, `commit-message`, `plan-task` — core Claude Code skill format taught through examples
- [ ] 2 pre-built agents: `code-reviewer.md`, `planner.md` — agent format taught through working examples
- [ ] `.gitignore` — no learner should ever accidentally commit their API key

### Add After Validation (v1.x)

Features to add after confirming learners can complete module 1 without support tickets.

- [ ] Windows setup path (PowerShell verification script) — add when Windows user share in course analytics warrants it
- [ ] Instructional hooks for modules 3-6 — add after confirming root CLAUDE.md commentary approach works
- [ ] Global skills installer script — add when skills directory is stable and tested on all 3 OS
- [ ] Module progress checklists (all 9 modules) — add after confirming markdown-only approach is sufficient
- [ ] 2 additional agents: `debugger.md`, `docs-writer.md` — add once core 2 agents are validated by learners

### Future Consideration (v2+)

Features to defer until post-launch feedback justifies the complexity.

- [ ] Validation hooks for exercises — requires significant content authoring per exercise; only valuable if course completion rate data shows students get stuck and need in-context feedback
- [ ] Upgrade path documentation (UPGRADING.md) — only meaningful once learners have completed the course and want to personalise their setup; premature for v1
- [ ] MCP setup guide as bonus module — only add if learners ask; keep base kit credential-free

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Module-aligned workspace folders | HIGH | LOW | P1 |
| Root CLAUDE.md with instructional comments | HIGH | LOW | P1 |
| Environment verification script | HIGH | MEDIUM | P1 |
| .env.example | HIGH | LOW | P1 |
| README with clear first steps | HIGH | LOW | P1 |
| .gitignore | HIGH | LOW | P1 |
| Module CLAUDE.md files (selected) | HIGH | LOW | P1 |
| 3 annotated skills | HIGH | LOW | P1 |
| 2 pre-built agents | HIGH | LOW | P1 |
| Module-scoped settings.json examples | MEDIUM | LOW | P1 |
| Windows setup path | HIGH | MEDIUM | P2 |
| Instructional hooks | HIGH | MEDIUM | P2 |
| Global skills installer script | MEDIUM | MEDIUM | P2 |
| Module progress checklists | MEDIUM | LOW | P2 |
| Additional agents (4-5 total) | MEDIUM | LOW | P2 |
| Validation hooks | MEDIUM | HIGH | P3 |
| Upgrade path documentation | MEDIUM | LOW | P3 |
| MCP setup guide | LOW | LOW | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

---

## Competitor Feature Analysis

| Feature | Wes Bos (Learn Node) | KCD (Epic Workshop) | freeCodeCamp | Our Approach |
|---------|----------------------|---------------------|--------------|--------------|
| Workspace structure | `starter-files/` + `stepped-solutions/` | `exercises/` with `*.problem.*` + `*.solution.*` | In-browser IDE, no local files | Module folders with `exercises/.starter` + `exercises/.solution` |
| Setup experience | Manual `npm install` | `npm run setup` script with system checks | Browser-only, no setup | Verification script with pass/fail per check + fix instructions |
| Context files | None | Character guides in README | None | Instructional CLAUDE.md files that teach while guiding |
| Progress tracking | None | Web UI with completion state | In-platform | Markdown PROGRESS.md checklists, no server |
| Hooks / automation | None | None | None | Pre-built settings.json examples per module showing hook evolution |
| Agent/skills format | Not applicable | Not applicable | Not applicable | Working agents + annotated skills as primary teaching artefacts |
| Beginner-friendliness | Assumes prior JS knowledge | Assumes TypeScript comfort | Starts from zero | Starts from zero; verification script catches missing prerequisites |
| Cross-platform | macOS-centric | macOS-centric | Browser (universal) | Explicit macOS + Linux + Windows paths |

---

## Sources

- [Epic Workshop App features — epicreact.dev](https://www.epicreact.dev/tips/get-started-with-the-epic-workshop-app) — HIGH confidence (official docs)
- [KCD web-app-fundamentals GitHub — exercise structure](https://github.com/epicweb-dev/web-app-fundamentals) — HIGH confidence (live repo)
- [Wes Bos Learn-Node — starter/solution pattern](https://github.com/wesbos/Learn-Node) — HIGH confidence (live repo)
- [Claude Code hooks guide — official docs](https://code.claude.com/docs/en/hooks-guide) — HIGH confidence (official docs, fetched March 2026)
- [Claude Code skills guide — official docs](https://code.claude.com/docs/en/skills) — HIGH confidence (official docs, fetched March 2026)
- [Claude Code customization guide — alexop.dev](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/) — MEDIUM confidence (verified against official docs)
- [Awesome Claude Code — hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — MEDIUM confidence (community curation, live repo)
- [CLAUDE.md + hooks beginner guide — genaiunplugged.substack.com](https://genaiunplugged.substack.com/p/claude-code-skills-commands-hooks-agents) — MEDIUM confidence (practitioner write-up, content verified against official docs)
- [create-t3-app design philosophy](https://create.t3.gg/en/faq) — MEDIUM confidence (official T3 docs, used as design philosophy reference only)

---
*Feature research for: Claude Code Mastery course companion starter kit*
*Researched: 2026-03-10*
