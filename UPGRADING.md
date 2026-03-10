# Upgrading Beyond the Course Defaults

This guide is for after you've completed the course — when you're ready to make the Claude config truly yours.

---

## 1. Personalize

The course ships a set of agents and skills prefixed `lah-` (like-a-human). These are teaching examples. Replace them with your own.

**Rename the prefix:**
```bash
# Example: rename lah-reviewer to your own handle
mv .claude/agents/lah-reviewer.md .claude/agents/yourname-reviewer.md
```

Update any references to the old name in your `.claude/CLAUDE.md` or other agent files.

**Swap the global CLAUDE.md:**
The course installs `.claude/CLAUDE.md` with conservative defaults tuned for learning. Once you're past the basics, replace it with your own. The course CLAUDE.md has comments marking each opinionated choice — use those as a starting point.

---

## 2. Extend

Add your own agents, skills, and hooks alongside the course files — don't delete the originals until you're sure you don't need them as reference.

**Add an agent:**
```bash
# Copy a lah-* file as a template
cp .claude/agents/lah-reviewer.md .claude/agents/my-reviewer.md
# Edit the name, description, and instructions
```

**Add a skill:**
```bash
cp .claude/skills/lah-example.md .claude/skills/my-skill.md
```

**Add a hook:**
Hooks live in `.claude/hooks/`. Each hook is a shell script that runs at a lifecycle point (pre-commit, post-tool-use, etc.). Copy an existing hook and modify the trigger and command.

See the [Claude Code docs on hooks](https://docs.anthropic.com/claude-code/hooks) for the full lifecycle reference.

---

## 3. Evolve

The course defaults are intentionally conservative — good for learning, not always right for production. Module 9 covers migrating to a production-grade CLAUDE.md.

Key differences from course defaults to production standards:
- **Hooks:** Course hooks are illustrative. Production hooks enforce real quality gates (typecheck, lint, test).
- **Agent autonomy:** Course agents ask for confirmation often. Production agents run more autonomously with `--dangerously-skip-permissions` on trusted tasks.
- **CLAUDE.md scope:** The course uses a single global file. Production setups layer global + per-project + per-directory configs.

When you're ready, follow Module 9's migration guide. It's a two-hour exercise, not a rewrite.

---

## 4. Update

The starter kit is updated as new course modules ship. Pull updates without losing your changes:

```bash
# Pull course updates
git pull origin main

# Re-run install.sh — it's idempotent (safe to run multiple times)
# It will not overwrite files you've modified
bash install.sh
```

If you want to refresh a specific course file, delete it first then re-run install.sh:
```bash
# Force-refresh a specific course file by removing it first
rm .claude/agents/lah-reviewer.md
bash install.sh
```

If you hit merge conflicts in `.claude/`, keep your version — your personalizations take precedence over course updates.
