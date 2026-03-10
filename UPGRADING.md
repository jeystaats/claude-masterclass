# Upgrading Beyond the Course Defaults

This guide is for after you've completed the course — when you're ready to make the Claude config truly yours.

---

## 1. Personalize Your Agents

The course ships 13 agents into `~/.claude/agents/`. These are real production agents, not teaching examples. Customize them by editing the files directly.

**Edit an agent:**
```bash
# Open any agent in your editor
code ~/.claude/agents/agent-orchestrator.md

# Or view all agents
ls ~/.claude/agents/
```

**Add your own agent:**
```bash
# Copy an existing one as a template
cp ~/.claude/agents/react-component-architect.md ~/.claude/agents/my-specialist.md
# Edit the name, description, and instructions inside
```

**The YAML frontmatter** at the top of each agent file controls the name, description, model, and tools. Edit it to match your style.

---

## 2. Add Your Own Skills

Skills live in `~/.claude/skills/`. Each skill is a directory with a `SKILL.md` file.

**Create a new skill:**
```bash
mkdir -p ~/.claude/skills/my-skill
cat > ~/.claude/skills/my-skill/SKILL.md << 'SKILL'
---
name: my-skill
description: >
  What this skill does and when it triggers.
---

# /my-skill — What it does

## Instructions
...
SKILL
```

The course ships: `/breakdown`, `/plan`, `/commit`, `/review`, `/debug`

---

## 3. Extend Your Hooks

Hooks live in `~/.claude/hooks/`. Each hook is a shell script that runs on Claude Code lifecycle events.

**View your active hooks:**
```bash
ls ~/.claude/hooks/
```

**The 5 course hooks** (`lah-check-*.sh`) run on every file write and check for TypeScript quality, React patterns, cn() usage, file size, and secrets.

**Add a custom hook:** Copy an existing hook and modify the trigger condition. See the [Claude Code hooks docs](https://docs.anthropic.com/claude-code/hooks) for the full lifecycle reference.

---

## 4. Update

The starter kit is updated as the course evolves. Pull updates without losing your changes:

```bash
cd ~/Documents/claude-mastery-starter

# Pull course updates
git pull origin main

# Re-run install.sh — it's idempotent (safe to run multiple times)
# It will not overwrite files you've already customized
bash install.sh
```

---

## 5. Graduate to a Production CLAUDE.md

The course CLAUDE.md is intentionally conservative — good for learning. Production setups layer global + per-project + per-directory configs.

Module 9 covers this migration. Key differences:
- **Hooks:** Course hooks are illustrative. Production hooks enforce real quality gates (typecheck, lint, test on CI).
- **Agent autonomy:** Course agents ask for confirmation often. Production agents can run more autonomously.
- **CLAUDE.md scope:** The course uses one global file. Production uses global + per-repo + per-directory layering.
