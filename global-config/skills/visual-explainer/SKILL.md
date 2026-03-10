---
name: visual-explainer
description: >
  Generate a self-contained HTML file that visually explains a concept, system,
  or data structure. Use this when a diagram would be clearer than words.
  Auto-invokes for architecture overviews, flowcharts, data flow, comparisons,
  and any time you'd otherwise draw an ASCII diagram.
---

# /visual-explainer — Make it visual

Generate a beautiful, self-contained HTML diagram saved to `~/.agent/diagrams/`.
Open it in the browser immediately after writing.

## When to use

- Architecture diagrams (how components connect)
- Data flow (request → response lifecycle)
- Feature concept boards (pitching an idea visually)
- Comparison tables (tech choices, approaches)
- State machines or user flows
- Any time ASCII art would feel inadequate

## Output rules

1. **Self-contained HTML** — all CSS inline, no external assets except Google Fonts and CDN libraries
2. **Montserrat font** — clean, professional: `https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&display=swap`
3. **Save to** `~/.agent/diagrams/descriptive-name.html`
4. **Open immediately** with `open ~/.agent/diagrams/descriptive-name.html` (macOS)
5. **Tell the user** the file path

## Color palette

Use these consistently:
- Dark navy: `#1a2744` (backgrounds, headers)
- Mid navy: `#243565` (surfaces)
- Accent blue: `#3B82C4` (highlights, links)
- Cream: `#FFF8E7` (light backgrounds)
- Lime: `#DEFEB3` (success, highlights)
- Gold: `#D4A64A` (warnings, attention)
- Text: `#1C2B3A` on light, `#F0F4F8` on dark

## Diagram types

- **Architecture** → CSS grid cards with arrow connectors
- **Flowchart** → Mermaid.js `graph TD` or `graph LR`
- **Sequence** → Mermaid.js `sequenceDiagram`
- **Data table** → HTML `<table>` with styled headers
- **State machine** → Mermaid.js `stateDiagram-v2`

## Mermaid setup

```html
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({ startOnLoad: true, theme: 'base',
    themeVariables: { primaryColor: '#243565', primaryTextColor: '#F0F4F8' }
  });
</script>
```

## Quality check before saving

- Does the diagram actually answer what was asked?
- Does it look good at different browser widths?
- Is every label readable (contrast, font size ≥ 12px)?
- Open it to confirm no broken layout before telling the user it's done.
