# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Content ambiguity:** "Spec unclear on X. Assume Y?"
- **Scope question:** "Also refactor Y while here, or focus on X?"
- **Pedagogy choice:** "Include this derivation or keep it intuitive?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (rendering, tests, compilation)
- Documentation (logs, commits)
- Plotting (per established standards)
- Deployment (after you approve, I ship automatically)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Path convention:** `here::here()` for R scripts; relative paths in Quarto
- **Seed convention:** `set.seed(12345)` once at top of any stochastic R script
- **Figure standards:** White background, 300 DPI, `.svg` preferred, minimal theme
- **Color palette:** Navy (#003366), Steel Blue (#4682B4), Gray (#6B7280), Gold (#D4A843)
- **No fragments:** Never use incremental/fragment builds in slides

---

## Preferences

**Visual:** Clean, publication-ready figures. Minimal chart junk. Consistent palette.
**Reporting:** Concise bullets. Details on request.
**Session logs:** Always (post-plan, incremental, end-of-session)
**Notation:** Consistent across lectures — $Y_i$, $X_i$, $\beta$, $\varepsilon_i$

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
