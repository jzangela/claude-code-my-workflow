# CLAUDE.MD -- Graduate Regression Analysis Course

**Project:** Graduate Regression Analysis
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- render and confirm output at the end of every task
- **Single source of truth** -- Quarto `.qmd` is authoritative; all outputs derive from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
regression-analysis/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Quarto/                      # RevealJS .qmd files + theme
├── docs/                        # GitHub Pages (auto-generated)
├── scripts/                     # Utility scripts + R code
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers, textbooks, reference materials
```

---

## Commands

```bash
# Render Quarto slides
quarto render Quarto/file.qmd

# Deploy to GitHub Pages
./scripts/sync_to_docs.sh LectureN

# Quality score
Rscript scripts/quality_score.R Quarto/file.qmd
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/deploy [LectureN]` | Render Quarto + sync to docs/ |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/data-analysis [dataset]` | End-to-end R analysis |

---

## Quarto CSS Classes

| Class | Effect | Use Case |
|-------|--------|----------|
| `.smaller` | 85% font size | Dense content or equation-heavy slides |
| `.keybox` | Gold background, gold left border | Key takeaways |
| `.highlightbox` | Steel blue background, blue left border | Highlights, definitions |
| `.methodbox` | Navy background tint, blue left border | Methods, formal criteria |
| `.assumptionbox` | Gold border all sides | Assumptions, conditions |
| `.resultbox` | Gold background, gold border | Results, findings |
| `.eqbox` | Light blue tint | Displayed equations |
| `.softbox` | Light gold, italic | Soft commentary |
| `.quotebox` | Gold left border, quote mark | Quotations |
| `.positive` | Green bold text | Correct interpretations |
| `.negative` | Red bold text | Incorrect interpretations |
| `.hi` | Navy bold | Inline emphasis |
| `.hi-gold` | Gold bold | Secondary inline emphasis |

---

## Visual Standards

- **Palette:** Navy (#003366), Steel Blue (#4682B4), Gray (#6B7280), Gold (#D4A843)
- **Figures:** White background, 300 DPI, `.svg` preferred, `.png` fallback
- **Font:** Sans-serif (system default)
- **Math:** LaTeX notation via MathJax, consistent symbols across lectures

---

## Current Project State

| Lecture | Quarto | Key Content |
|---------|--------|-------------|
| 1: Introduction to Regression | `Lecture01_Introduction.qmd` | Why regression, intuition, simple linear model |
