# Final presentation review

## Files changed

- Replaced root `README.md` with methods, qualified results, saved figure, repository map, reproduction instructions and limitations.
- Rewrote `TRR_Hybrid_models_code/README.md`; added `MATLAB Code CTM/README.md` and updated its `README.txt` pointer.
- Added explanatory Markdown to both current notebooks, preserving every original cell, output and notebook metadata object.
- Added `.gitignore`, `docs/RESEARCH_AUDIT.md`, `figures/trr_saved_predictions.png`, and this review.
- Added `archive/README.md` and relocated two distinct hybrid checkpoint notebooks there byte-for-byte.

## Files removed

The six tracked entries under `.ipynb_checkpoints/` were removed from that generated directory. Two hybrid notebooks survive in `archive/`; the TRR notebook, requirements and two detector CSV checkpoints were verified duplicates before removal. No current datasets, experimental results or source code were removed. Python/MATLAB dataset copies remain to preserve relative paths.

## Validation outcomes

Passed: notebook JSON/cell structure and Python syntax checks; exact comparison of original notebook cell objects (including outputs) and notebook metadata with Git; source/data/requirements/FAQ byte comparisons; historical notebook byte comparisons; local Markdown/image link checks; PNG signature/dimensions; metric lookup against saved printed output; ignore-pattern checks; and `git diff --check`.

Notebook structure was checked with the standard library; `nbformat` is unavailable, so its schema validator was not run. A clean Python environment and MATLAB execution were not tested. No full experiments, installs, commits or pushes were performed.

## Scientific and reproducibility concerns

The main concerns are CTM current-time scoring instead of future-target scoring, confirmed mislabeled export ground-truth station columns, unresolved hybrid target-time alignment, different hybrid/TRR evaluation subsets, pre-CV scaling, unpurged future targets across fold boundaries, shifts across missing time intervals, and different speed conversion constants. The hybrid trajectory plot is mislabeled and horizon summaries are hard coded. Calibration needs a filename correction, and CTM export generation code is missing. The detailed audit provides evidence and next steps.

## Before publishing

Review the qualified results and audit, establish dataset attribution/redistribution terms, and recover the CTM exporter before strengthening any comparative claim. Correct and rerun evaluation in a separate research change with consistent station IDs, times, units, shared rows, and isolated CV preprocessing.

The repository is suitable to link from a Senior ML Engineer resume as an academic scientific-ML project with transparent limitations. It demonstrates inspectable modeling and evaluation work; it does not establish production experience or a validated hybrid advantage. Resolving the methodological issues would materially strengthen it for rigorous technical review.

Changes are local and unstaged. Review with `git diff` and `git status --short`; new files are listed by status. A complete patch including new files is also provided at `/tmp/ai-traffic-flow-presentation.diff` for this workspace session.
