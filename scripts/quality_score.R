#!/usr/bin/env Rscript
#' Quality Scoring System for Academic Course Materials
#'
#' Calculates objective quality scores (0-100) based on defined rubrics.
#' Enforces quality gates: 80 (commit), 90 (PR), 95 (excellence).
#'
#' Usage:
#'   Rscript scripts/quality_score.R Quarto/Lecture01_Introduction.qmd
#'   Rscript scripts/quality_score.R Quarto/Lecture01_Introduction.qmd --summary
#'   Rscript scripts/quality_score.R scripts/R/simulations.R
#'
#' Exit Codes:
#'   0 = Score >= 80 (commit allowed)
#'   1 = Score < 80 (commit blocked)
#'   2 = Auto-fail (compilation/syntax error)

# ==============================================================================
# THRESHOLDS
# ==============================================================================

THRESHOLDS <- list(commit = 80, pr = 90, excellence = 95)

# ==============================================================================
# ISSUE DETECTION
# ==============================================================================

check_quarto_compilation <- function(filepath) {

result <- tryCatch(
    system2("quarto", c("render", filepath, "--to", "html"),
            stdout = TRUE, stderr = TRUE, timeout = 120),
    error = function(e) list(status = 1, stderr = conditionMessage(e))
  )
  status <- attr(result, "status")
  if (is.null(status)) status <- 0
  list(success = status == 0,
       error = if (status != 0) paste(result, collapse = "\n") else "")
}

check_equation_overflow <- function(content) {
  lines <- strsplit(content, "\n")[[1]]
  overflows <- integer(0)
  in_math <- FALSE
  math_delim <- NULL

  for (i in seq_along(lines)) {
    stripped <- trimws(lines[i])

    # $$ delimiter
    if (grepl("\\$\\$", stripped) && !identical(math_delim, "env")) {
      if (!in_math) {
        in_math <- TRUE
        math_delim <- "$$"
        # Single-line $$ ... $$
        parts <- strsplit(stripped, "\\$\\$")[[1]]
        if (length(parts) >= 3 && nchar(trimws(parts[2])) > 120) {
          overflows <- c(overflows, i)
        }
        if (length(gregexpr("\\$\\$", stripped)[[1]]) >= 2) {
          in_math <- FALSE
          math_delim <- NULL
        }
        next
      } else {
        in_math <- FALSE
        math_delim <- NULL
        next
      }
    }

    # \begin{equation/align/...}
    if (!in_math && grepl("\\\\begin\\{(equation|align|gather|multline)\\*?\\}", stripped)) {
      in_math <- TRUE
      math_delim <- "env"
      next
    }

    # \end{equation/align/...}
    if (grepl("\\\\end\\{(equation|align|gather|multline)\\*?\\}", stripped)) {
      in_math <- FALSE
      math_delim <- NULL
      next
    }

    # Inside math block: check line length
    if (in_math) {
      code_part <- sub("%.*", "", lines[i])
      if (nchar(trimws(code_part)) > 120) {
        overflows <- c(overflows, i)
      }
    }
  }
  overflows
}

check_broken_citations <- function(content, bib_file) {
  # Quarto-style @key citations
  cited_keys <- character(0)

  # [@key] or [@key1; @key2]
  bracket_matches <- gregexpr("\\[([^\\]]*@[^\\]]+)\\]", content, perl = TRUE)
  if (bracket_matches[[1]][1] != -1) {
    bracket_texts <- regmatches(content, bracket_matches)[[1]]
    for (bt in bracket_texts) {
      keys <- regmatches(bt, gregexpr("@([\\w:.#$%&\\-+?<>~/]+)", bt, perl = TRUE))[[1]]
      keys <- sub("^@", "", keys)
      cited_keys <- c(cited_keys, keys)
    }
  }

  # Standalone @key
  standalone <- regmatches(content,
    gregexpr("(?<![.\\w])@([\\w:.#$%&\\-+?<>~/]+)", content, perl = TRUE))[[1]]
  standalone <- sub("^@", "", standalone)
  # Filter out Quarto directives
  standalone <- standalone[!standalone %in% c("fig", "tbl", "sec", "eq", "lst")]
  cited_keys <- unique(c(cited_keys, standalone))

  if (length(cited_keys) == 0) return(character(0))
  if (!file.exists(bib_file)) return(cited_keys)

  bib_content <- readLines(bib_file, warn = FALSE)
  bib_content <- paste(bib_content, collapse = "\n")
  bib_keys <- regmatches(bib_content,
    gregexpr("@\\w+\\{([^,]+),", bib_content, perl = TRUE))[[1]]
  bib_keys <- sub("^@\\w+\\{", "", bib_keys)
  bib_keys <- sub(",$", "", bib_keys)

  setdiff(cited_keys, bib_keys)
}

check_r_syntax <- function(filepath) {
  result <- tryCatch({
    parse(filepath)
    list(success = TRUE, error = "")
  }, error = function(e) {
    list(success = FALSE, error = conditionMessage(e))
  })
  result
}

check_hardcoded_paths <- function(content) {
  lines <- strsplit(content, "\n")[[1]]
  issues <- integer(0)
  for (i in seq_along(lines)) {
    if (grepl("[\"'][/\\\\]|[\"'][A-Za-z]:[/\\\\]", lines[i])) {
      if (!grepl("http:|https:|file://|/tmp/", lines[i])) {
        issues <- c(issues, i)
      }
    }
  }
  issues
}

# ==============================================================================
# SCORING
# ==============================================================================

score_quarto <- function(filepath) {
  content <- paste(readLines(filepath, warn = FALSE), collapse = "\n")
  score <- 100
  issues <- list(critical = list(), major = list(), minor = list())
  auto_fail <- FALSE

  # Check compilation
  comp <- check_quarto_compilation(filepath)
  if (!comp$success) {
    auto_fail <- TRUE
    issues$critical <- c(issues$critical, list(list(
      type = "compilation_failure",
      description = "Quarto compilation failed",
      details = substr(comp$error, 1, 200),
      points = 100
    )))
    return(generate_report(filepath, 0, issues, auto_fail))
  }

  # Check equation overflow
  eq_overflows <- check_equation_overflow(content)
  for (line in eq_overflows) {
    issues$critical <- c(issues$critical, list(list(
      type = "equation_overflow",
      description = sprintf("Potential equation overflow at line %d", line),
      details = "Single equation line >120 chars may overflow slide",
      points = 20
    )))
    score <- score - 20
  }

  # Check broken citations
  bib_file <- file.path(dirname(dirname(filepath)), "Bibliography_base.bib")
  broken <- check_broken_citations(content, bib_file)
  for (key in broken) {
    issues$critical <- c(issues$critical, list(list(
      type = "broken_citation",
      description = sprintf("Citation key not in bibliography: %s", key),
      details = "Add to Bibliography_base.bib or fix key",
      points = 15
    )))
    score <- score - 15
  }

  generate_report(filepath, max(0, score), issues, auto_fail)
}

score_r_script <- function(filepath) {
  content <- paste(readLines(filepath, warn = FALSE), collapse = "\n")
  score <- 100
  issues <- list(critical = list(), major = list(), minor = list())
  auto_fail <- FALSE

  # Check syntax
  syn <- check_r_syntax(filepath)
  if (!syn$success) {
    auto_fail <- TRUE
    issues$critical <- c(issues$critical, list(list(
      type = "syntax_error",
      description = "R syntax error",
      details = substr(syn$error, 1, 200),
      points = 100
    )))
    return(generate_report(filepath, 0, issues, auto_fail))
  }

  # Check hardcoded paths
  path_issues <- check_hardcoded_paths(content)
  for (line in path_issues) {
    issues$critical <- c(issues$critical, list(list(
      type = "hardcoded_path",
      description = sprintf("Hardcoded absolute path at line %d", line),
      details = "Use relative paths or here::here()",
      points = 20
    )))
    score <- score - 20
  }

  # Check for set.seed() if randomness detected
  random_fns <- c("rnorm", "runif", "sample", "rbinom", "rnbinom", "rpois")
  has_random <- any(sapply(random_fns, function(fn) grepl(fn, content, fixed = TRUE)))
  has_seed <- grepl("set\\.seed", content)
  if (has_random && !has_seed) {
    issues$major <- c(issues$major, list(list(
      type = "missing_set_seed",
      description = "Missing set.seed() for reproducibility",
      details = "Add set.seed(12345) after library() calls",
      points = 10
    )))
    score <- score - 10
  }

  generate_report(filepath, max(0, score), issues, auto_fail)
}

# ==============================================================================
# REPORTING
# ==============================================================================

generate_report <- function(filepath, score, issues, auto_fail) {
  if (auto_fail) {
    status <- "FAIL"
  } else if (score >= THRESHOLDS$excellence) {
    status <- "EXCELLENCE"
  } else if (score >= THRESHOLDS$pr) {
    status <- "PR_READY"
  } else if (score >= THRESHOLDS$commit) {
    status <- "COMMIT_READY"
  } else {
    status <- "BLOCKED"
  }

  counts <- list(
    critical = length(issues$critical),
    major = length(issues$major),
    minor = length(issues$minor),
    total = length(issues$critical) + length(issues$major) + length(issues$minor)
  )

  list(
    filepath = filepath,
    score = score,
    status = status,
    auto_fail = auto_fail,
    issues = issues,
    counts = counts
  )
}

print_report <- function(report, summary_only = FALSE) {
  cat(sprintf("\n# Quality Score: %s\n\n", basename(report$filepath)))

  status_label <- switch(report$status,
    EXCELLENCE = "[EXCELLENCE]",
    PR_READY = "[PASS]",
    COMMIT_READY = "[PASS]",
    BLOCKED = "[BLOCKED]",
    FAIL = "[FAIL]"
  )

  cat(sprintf("## Overall Score: %d/100 %s\n", report$score, status_label))

  if (report$status == "BLOCKED") {
    cat(sprintf("\n**Status:** BLOCKED - Cannot commit (score < %d)\n",
        THRESHOLDS$commit))
  } else if (report$status == "COMMIT_READY") {
    cat(sprintf("\n**Status:** Ready for commit (score >= %d)\n", THRESHOLDS$commit))
    gap <- THRESHOLDS$pr - report$score
    cat(sprintf("**Next milestone:** PR threshold (%d+)\n", THRESHOLDS$pr))
    cat(sprintf("**Gap analysis:** Need +%d points to reach PR quality\n", gap))
  } else if (report$status == "PR_READY") {
    cat(sprintf("\n**Status:** Ready for PR (score >= %d)\n", THRESHOLDS$pr))
    gap <- THRESHOLDS$excellence - report$score
    if (gap > 0) {
      cat(sprintf("**Gap analysis:** +%d points to excellence\n", gap))
    }
  } else if (report$status == "EXCELLENCE") {
    cat(sprintf("\n**Status:** Excellence achieved! (score >= %d)\n",
        THRESHOLDS$excellence))
  } else if (report$status == "FAIL") {
    cat("\n**Status:** Auto-fail (compilation/syntax error)\n")
  }

  if (summary_only) {
    cat(sprintf("\n**Total issues:** %d (%d critical, %d major, %d minor)\n",
        report$counts$total, report$counts$critical,
        report$counts$major, report$counts$minor))
    return(invisible(report))
  }

  # Detailed issues
  cat(sprintf("\n## Critical Issues (MUST FIX): %d\n", report$counts$critical))
  if (report$counts$critical == 0) {
    cat("No critical issues - safe to commit\n\n")
  } else {
    for (i in seq_along(report$issues$critical)) {
      issue <- report$issues$critical[[i]]
      cat(sprintf("%d. **%s** (-%d points)\n", i, issue$description, issue$points))
      cat(sprintf("   - %s\n\n", issue$details))
    }
  }

  if (report$counts$major > 0) {
    cat(sprintf("## Major Issues (SHOULD FIX): %d\n", report$counts$major))
    for (i in seq_along(report$issues$major)) {
      issue <- report$issues$major[[i]]
      cat(sprintf("%d. **%s** (-%d points)\n", i, issue$description, issue$points))
      cat(sprintf("   - %s\n\n", issue$details))
    }
  }

  if (report$status == "BLOCKED") {
    cat("## Recommended Actions\n")
    cat("1. Fix all critical issues above\n")
    cat(sprintf("2. Re-run quality score (target: >=%d)\n", THRESHOLDS$commit))
    cat("3. Commit after reaching threshold\n\n")
  }

  invisible(report)
}

# ==============================================================================
# CLI
# ==============================================================================

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) == 0) {
    cat("Usage: Rscript scripts/quality_score.R <file> [--summary]\n")
    cat("Supported: .qmd, .R\n")
    quit(status = 1)
  }

  summary_only <- "--summary" %in% args
  filepaths <- args[!grepl("^--", args)]

  exit_code <- 0

  for (fp in filepaths) {
    if (!file.exists(fp)) {
      cat(sprintf("Error: File not found: %s\n", fp))
      exit_code <- 1
      next
    }

    ext <- tools::file_ext(fp)

    report <- tryCatch({
      if (ext == "qmd") {
        score_quarto(fp)
      } else if (ext == "R") {
        score_r_script(fp)
      } else {
        cat(sprintf("Error: Unsupported file type: .%s\n", ext))
        NULL
      }
    }, error = function(e) {
      cat(sprintf("Error scoring %s: %s\n", fp, conditionMessage(e)))
      NULL
    })

    if (!is.null(report)) {
      print_report(report, summary_only = summary_only)
      if (report$auto_fail) {
        exit_code <- max(exit_code, 2)
      } else if (report$score < THRESHOLDS$commit) {
        exit_code <- max(exit_code, 1)
      }
    }
  }

  quit(status = exit_code)
}

main()
