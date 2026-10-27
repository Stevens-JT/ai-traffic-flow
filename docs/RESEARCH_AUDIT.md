# Research audit and presentation review

This audit compares checked-in code, CSVs, notebook outputs and the original FAQ. It does not rerun model fitting, optimize MATLAB parameters or certify a clean environment.

## Evidence and recoverable results

Both current notebooks contain six-row-ahead fitted evaluations, 60 features, four expanding date folds, and selected ridge alpha 100 for both variables. In the original TRR notebook, zero-based cell 17 prints flow RMSE 818.9118382986668 and speed RMSE 8.188262027173726; cell 20 prints persistence 880.3109420623539 and 8.794121382004798. In the original hybrid notebook, cell 18 prints 799.499766499411 and 9.894793864536926. These are means of per-station RMSE. New explanatory Markdown shifts cell positions; locate results by their code headings or printed labels.

Standalone predictions cover 837 origins; hybrid predictions cover 833. Training feature rows are 2288; the hybrid intersection has 2284. These are not identical evaluation sets. The original merged station table and FAQ’s statement that hybrid improves flow are insufficient to establish a controlled gain. Other-horizon arrays are hand entered and do not include full saved fitting evidence for those runs. No CTM evaluation number is promoted to the root table because future-target scoring is not established.

## Methodological issues requiring new, separately reviewed experiments

1. **CTM forecast scoring uses current observations.** `main_forecast.m` stores a forecast at row `t` but subtracts `flow_gt(1:N-Delta,:)` and `speed_gt(1:N-Delta,:)`. Correct future-target evaluation requires checking against rows `1+Delta:N`, with appropriate physical time handling. Plots also use current observations. The computed smoothed/capped `d0` is unused.
2. **CTM export station labels disagree with raw data.** MATLAB orders IDs with sorted `unique`; Python preserves `[717486, 764766, 717488, 717489, 717490]`. An exact flow comparison at each of the 834 D6 export timestamps gives the mapping below. This is direct evidence of ground-truth label mismatch, not proof of every prediction column’s identity; the exporter is missing.

   | D6 export ground-truth column suffix | Raw detector whose flow matches all 834 rows |
   |---|---|
   | 717486 | 717486 |
   | 764766 | 717488 |
   | 717488 | 717489 |
   | 717489 | 717490 |
   | 717490 | 764766 |

3. **Origin and target timestamps are conflated.** `shift(-delta)` moves target values but leaves origin indices unchanged. Hybrid code intersects those indices with CTM export timestamps. D6 exported `flow_gt_717486` matches raw station 717486 at the export timestamp on all 834 rows, whereas the notebook target refers to six later rows. The CSV ground truth is not used by the notebook to establish target alignment. A matching index is not sufficient evidence that the CTM forecast predicts the same target.
4. **CV preprocessing is not fold-local.** StandardScaler is fitted on all training dates before CV. Test statistics are excluded, but validation dates influence CV preprocessing. Targets are shifted before date masks; training-origin rows near a fold boundary can contain targets from a validation date. Purging based on target time is needed.
5. **Row shifts do not enforce elapsed time.** Sorted pivots are shifted across midnight, missing records and the June 10–13 weekend gap. Six rows ahead is only nominally 30 minutes. Six input lags include the present and span 25 minutes on a regular grid, rather than six previous measurements. CTM also advances a fixed interval per row regardless of timestamp gaps.
6. **Units differ slightly.** Python uses 1.6 and MATLAB uses 1.60934 to convert mph to km/h. CTM exports use the latter convention; hybrid residuals mix them. Neither conversion is silently changed here.
7. **Calibration and forecasting differ.** Simulation includes previous-speed assimilation, interval averaging and final-row copying; forecasting uses triangular-FD final-state speed and final-substep flow. The training export is unversioned and has no horizon identifier. Calibration offers six parameters although two are unused, and fixed forecast parameters are not automatically taken from optimization. Parameter values at bounds and lack of saved optimization logs limit calibration assessment.
8. **Visualization provenance.** The hybrid trajectory legend says Hybrid but plots standalone TRR prediction variables. Horizon and per-station summary charts use hard-coded arrays. The root figure instead exports the saved TRR trajectory PNG directly; its x-axis is origin time.

## Data inventory and provenance

The two detector input schemas are `Station, datetime, flow, speed`. They contain 11,495 training and 4,243 test station rows. Eight training dates and three test dates are present. The original Python guide describes US-101 data, but no original source URL, extraction script, detector geography or redistribution terms are supplied. Do not infer physical station ordering from IDs alone. MATLAB fills absent station/time values with zero; Python drops incomplete feature/target rows.

The training data is byte-identical in the Python and MATLAB directories (SHA-256 prefix `022d5433e2d04c3f`); their test files are byte-identical (`b6cc6fd570e33916`). Both copies remain because relative paths depend on them. CTM training and D1/D3/D6 exports contain 2290/839/837/834 rows and 21 columns each. Their generation is absent from the six MATLAB source files. Original `FAQ_revised.docx` is preserved as a historical submission document; its continuity, validation-isolation and hybrid-improvement statements require the qualifications above.

## Cleanup and preserved artifacts

Removed six entries from `.ipynb_checkpoints/`: three notebook checkpoints, requirements checkpoint and two data checkpoints. Two distinct hybrid notebooks were relocated byte-for-byte to `archive/AItrafficFlowHybrid-historical.ipynb` and `archive/AItrafficFlowHybrid_copy-historical.ipynb`; the TRR checkpoint and non-notebook files were verified duplicates of current artifacts before removal. The archive retains research states and outputs; it is not the supported reproduction entry point. Root ignore rules exclude future checkpoints, caches, environments, temporary files and separately executed notebook copies. The existing Python-local ignore file is retained.

Root and Python READMEs were rewritten, a MATLAB Markdown guide added, and its older text guide replaced with a pointer. All six MATLAB sources, all eight non-checkpoint CSVs, pinned requirements and original FAQ remain unchanged. Current notebooks receive Markdown cells only; original cell objects, metadata and saved outputs remain intact. No experiment or unsupported functionality was added.

## Reproduction limits and publication next steps

Calibration’s load argument omits `.csv`; the MATLAB guide describes the exact manual correction. No MATLAB installation/version verification or Optimization Toolbox execution was performed. The Python pinned environment has not been installed in a clean environment in this review. Existing outputs can be inspected, but end-to-end regeneration of CTM residual inputs is not available.

Before publishing stronger scientific conclusions, recover or reconstruct the exporter with explicit station IDs and origin/target timestamps, correct future-target scoring, use a common evaluation subset, reconcile unit conversions and repeat validation with fold-local preprocessing, target-time purging and gap-aware horizons. Preserve the current saved run as historical evidence when doing so. Add dataset attribution and permission information once established. No changes were committed or pushed.

## Validation record

Lightweight checks compare every original current-notebook cell against Git, validate notebook JSON structure and Python code syntax, check relative Markdown/image links, verify figure PNG structure, confirm numerical result provenance and ignore patterns, and check unchanged source/data hashes. No full model run is part of these checks. See `PRESENTATION_REVIEW.md` for the final review outcome.
