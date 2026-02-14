---
paths:
  - "Quarto/**/*.qmd"
---

# Quarto Authoring Conventions

**All lecture content is authored in Quarto `.qmd` files.** This project does not use Beamer.

## Slide Structure

- One `.qmd` file per lecture: `Quarto/Lecture01_Topic.qmd`
- Use level-2 headings (`##`) for slide titles
- Use horizontal rules (`---`) only when needed for untitled slides
- Keep one concept per slide; split rather than overcrowd

## Math Notation

- Use `$...$` for inline math, `$$...$$` for display math
- Consistent notation across all lectures (see CLAUDE.md visual standards)
- Common symbols: $Y_i$ (outcome), $X_i$ (predictor), $\beta$ (coefficients), $\varepsilon_i$ (error)
- Always define notation before first use on a slide

## Citations

- Use `@key` format, referencing `Bibliography_base.bib`
- Place citations in parentheses: `[@author2024]`
- Verify every citation key exists in the `.bib` file before committing

## Progressive Builds

- Do NOT use `::: {.incremental}` or `. . .` fragments
- Instead, use multiple slides to build up content progressively
- Use color emphasis and visual hierarchy for attention guidance

## Code Blocks

- Use `{r}` code chunks for R demonstrations
- Set `echo: true` for teaching code, `echo: false` for figure-only output
- Always include `#| fig-alt:` for accessibility
