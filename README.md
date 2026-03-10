# Claude Code Mastery — Starter Kit

A working Next.js 16 app you can build in immediately. Clone it, run two commands, and you're ready for your first Claude Code session.

---

## Prerequisites

- **Node.js 20+** — [nodejs.org](https://nodejs.org)
- **pnpm 9+** — `npm install -g pnpm@9`
- **Claude Code** — [claude.ai/code](https://claude.ai/code)
- **Git**

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/your-org/claude-masterclass-starter.git
cd claude-masterclass-starter

# 2. Install dependencies and Claude Code config
bash install.sh

# 3. Start the dev server
bash start.sh
```

4. Open the module you're working on in the course and read the brief.
5. Open Claude Code in your project folder: `claude` — then describe your first task.

The app runs at **http://localhost:3000**.

---

## What's Included

| Path | What it is |
|------|------------|
| `src/app/` | Next.js App Router pages |
| `src/lib/utils.ts` | `cn()` utility (clsx + tailwind-merge) |
| `.claude/` | Claude Code config: agents, skills, rules |
| `install.sh` | Installs deps + copies Claude config |
| `start.sh` | Starts dev server |

---

## Troubleshooting

### EACCES: permission denied when installing Claude Code

Never use `sudo npm install -g @anthropic-ai/claude-code`. Use the native installer instead:

```bash
curl -fsSL https://claude.ai/install.sh | sh
```

This installs to `~/.local/bin`, which doesn't require root access.

---

### `claude: command not found` after install

The installer puts Claude Code in `~/.local/bin`. Add it to your PATH:

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# Apply immediately
source ~/.zshrc   # or source ~/.bashrc
```

Then verify: `claude --version`

---

### PowerShell: "running scripts is disabled on this system" (execution policy error)

Open PowerShell **as Administrator** and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then close and reopen your terminal.

---

## Next Steps

Once the server is running and Claude Code is open, pick your first module from the course portal and follow its brief. Each module is self-contained — you build one thing, ship it, and move on.

See `UPGRADING.md` to personalize your Claude config and grow beyond course defaults.
