{{! session.md.tpl — Template reference for start.sh session context injection }}
{{! Tokens: MODULE_NUM, MODULE_NAME, MODULE_DIR, START_DATE, SKILLS_LIST, AGENTS_LIST }}
{{! This file is documentation only — start.sh writes the actual session.md via heredoc }}

<!-- SESSION: written by start.sh — do not edit manually -->
<!-- Module: {{MODULE_NUM}} | Started: {{START_DATE}} -->

## Your Session Context

You are helping a student working on **Module {{MODULE_NUM}}: {{MODULE_NAME}}**.

**Working directory:** {{MODULE_DIR}}/

{{! SKILLS_LIST is populated by get_skills_for_module() in lib/session.sh }}
{{! Progressive disclosure: Module 1 gets 1 skill only. Modules 6–9 get all 5. }}
## Skills available this module

{{SKILLS_LIST}}

{{! AGENTS_LIST is populated by get_agents_for_module() in lib/session.sh }}
{{! Progressive disclosure: Module 1 gets 1 agent only. Modules 6–9 get all 4. }}
## Agents available this module

{{AGENTS_LIST}}

{{! Teaching mode is inherited from the global CLAUDE.md.snippet installed by install.sh. }}
{{! Do not repeat teaching mode rules here — session.md should be additive, not duplicative. }}

---

```
Token reference:
  {{MODULE_NUM}}   — Zero-padded module number (e.g. "04")
  {{MODULE_NAME}}  — First-line title from modules/XX/README.md, stripped of "# " prefix
  {{MODULE_DIR}}   — Basename of the module directory (e.g. "04-plan-your-product")
  {{START_DATE}}   — Output of: date "+%Y-%m-%d %H:%M"
  {{SKILLS_LIST}}  — Markdown bullet list from get_skills_for_module() in lib/session.sh
  {{AGENTS_LIST}}  — Markdown bullet list from get_agents_for_module() in lib/session.sh
```
