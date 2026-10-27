# Python notebooks: TRR and CTM residual learning

Read the [project overview](../README.md) and [research audit](../docs/RESEARCH_AUDIT.md) before interpreting the saved results. These notebooks preserve the original experiment code and outputs; added Markdown explains methodology and known limitations.

## Inputs and working directory

Run Jupyter from this directory. Both notebooks read `train_split_for_ctm.csv` and `test_split_for_ctm.csv`. The hybrid additionally reads `ctm_outputs__train_forResiduals.csv` and `ctm_outputs_test_D6_forResiduals.csv`. D1 and D3 test exports are included, but selecting a different horizon also requires verifying training-export semantics and all timestamp alignment.

The detector files contain raw mph speeds and veh/h flow. Python multiplies speed by 1.6; CTM exports use the MATLAB convention of 1.60934. Six lags include lag 0, giving five previous rows plus the current observation. `DELTA = 6` shifts targets six rows ahead, nominally 30 minutes, with exceptions across gaps. Older inline comments and the original [FAQ](FAQ_revised.docx) overstate continuous sampling and validation isolation; the audit supersedes those interpretations.

## Environment and execution

From the repository root:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -r TRR_Hybrid_models_code/requirements.txt
cd TRR_Hybrid_models_code
jupyter lab
```

On Windows PowerShell use `.venv\Scripts\Activate.ps1`. Choose the environment’s Python kernel. Optional kernel registration, from the activated environment:

```bash
python -m ipykernel install --user --name traffic-modeling --display-name "Python (traffic-modeling)"
```

Open [AItrafficFlowTRR.ipynb](AItrafficFlowTRR.ipynb) for the standalone model and persistence baseline or [AItrafficFlowHybrid.ipynb](AItrafficFlowHybrid.ipynb) for residual learning followed by standalone comparisons. Run top to bottom when intentionally reproducing experiments. To save a separate executed copy from this directory:

```bash
jupyter nbconvert --to notebook --execute AItrafficFlowTRR.ipynb --output AItrafficFlowTRR.executed.ipynb --ExecutePreprocessor.timeout=-1
```

Replace both notebook names for a hybrid execution. Execution can take time; no notebooks were rerun during the documentation update. The existing pinned requirements were retained and have not been verified in a fresh environment.

## Reading the experiments

Both notebooks load data, construct station-wide lag features, standardize them, tune ridge penalties with four expanding date folds, fit final models and evaluate per-station RMSE. The hybrid first intersects supplied CTM timestamps with feature indices, learns flow and speed residuals, then adds predicted residuals back to CTM values.

Final results average per-station RMSE; CV instead uses pooled station MSE before taking its square root. The standalone test has 837 origins and the hybrid has 833. Timestamp intersections do not resolve forecast-origin versus target-time semantics. The hybrid trajectory plot uses standalone predictions despite its legend. Horizon plots contain manually entered arrays. Refer to the root results table for qualified numerical reporting; do not infer a controlled hybrid improvement from the merged table.
