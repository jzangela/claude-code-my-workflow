---
paths:
  - "Figures/**/*"
  - "Quarto/**/*.qmd"
---

# Single Source of Truth: Quarto-First Workflow

**The Quarto `.qmd` file is the authoritative source for ALL lecture content.** Everything else is derived.

## The SSOT Chain

```
Quarto .qmd (SOURCE OF TRUTH)
  ├── RevealJS HTML (derived, via quarto render)
  ├── Bibliography_base.bib (shared)
  ├── Figures/ (R-generated or manually created)
  └── docs/ (deployed output)

NEVER edit derived artifacts (HTML, docs/) independently.
ALWAYS make changes in the .qmd source.
```

---

## Figure Freshness Protocol

**Before referencing any figure in a Quarto slide, verify it is current.**

1. If the figure is R-generated: ensure the R script has been re-run since last data/code change
2. If the figure is manually created: ensure it matches the current slide content
3. Use `.svg` format when possible; `.png` at 300 DPI as fallback

---

## CSS Class Parity

**Every styled element must have a corresponding CSS class defined in the theme.**

1. Before using a custom class (e.g., `.definition`, `.keypoint`), verify it exists in the theme SCSS
2. If a class is missing, create it before using it in slides
3. Maintain the class registry in CLAUDE.md

---

## Content Fidelity Checklist

```
[ ] Math check: every equation renders correctly in MathJax
[ ] Citation check: every @key resolves in Bibliography_base.bib
[ ] Figure check: every referenced image exists in Figures/
[ ] CSS check: every custom class is defined in theme
[ ] No orphan slides: every slide connects to the lecture narrative
```
