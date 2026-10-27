# Traffic Flow Forecasting Using Physics-Based and Hybrid Machine Learning Models

A graduate research project for COMP 841 comparing a Cell Transmission Model (CTM), Temporal Ridge Regression (TRR), and a hybrid model that learns corrections to CTM outputs. The project explores whether traffic conservation dynamics and statistical learning from multiple highway detectors can complement each other in short-term speed and flow forecasting.

The implementation is an academic Python/Jupyter and MATLAB prototype. Saved experiments, rather than a deployed service, are the primary artifacts. **TRR outperforms persistence on the saved six-step test evaluation; hybrid and CTM conclusions remain provisional because of alignment and evaluation issues documented below.**

## Research objectives

Forecast speed and flow across five detector stations, compare physics-based and temporal statistical models, and investigate residual learning as a way to correct physics-model errors. Start with the [TRR notebook](TRR_Hybrid_models_code/AItrafficFlowTRR.ipynb), then inspect the [hybrid notebook](TRR_Hybrid_models_code/AItrafficFlowHybrid.ipynb) and [MATLAB implementation](MATLAB%20Code%20CTM/README.md).

## Methodology

**CTM.** Five cells use a triangular fundamental diagram with demand $D_i=\min(v_f k_i,q_{max})$, supply $S_i=\max(0,\min(q_{max},w(k_j-k_i)))$, and interface flow $F_{i+1/2}=\min(D_i,S_{i+1})$. Density follows conservation:

$$k_i^{n+1}=k_i^n+\frac{\Delta t}{\Delta x}(F_{i-1/2}-F_{i+1/2}).$$

Cells are 0.6 km long; 60 five-second integration steps represent each nominal five-minute observation interval. MATLAB calibrates parameters with constrained `fmincon`, minimizing $0.5\,RMSE_{speed}/120+0.5\,RMSE_{flow}/8000$. Calibration simulation averages interval outputs and blends past observed speed into modeled speed; forecasting instead initializes density from current measurements and returns final-step outputs. See [implementation details and caveats](docs/RESEARCH_AUDIT.md).

**TRR.** Pivot flow and speed across five stations; concatenate lags 0–5 of both variables into 60 features. This includes the current measurement and five preceding rows, spanning 25 minutes on a regular grid. Separate multi-output ridge models predict flow and speed six rows ahead:

$$\min_{W,b}\|Y-XW-\mathbf{1}b^T\|_F^2+\alpha\|W\|_F^2.$$

Features are standardized; the intercept is unpenalized. Seven regularization values from $10^{-4}$ to $10^2$ are searched independently for each variable. Both saved selections are 100.

**Hybrid.** Using the same lag features, train separate ridge models on $r=Y-\hat Y_{CTM}$ and reconstruct $\hat Y_{hybrid}=\hat Y_{CTM}+\hat r$. The notebook intersects CTM export timestamps with feature indices. The indices still represent forecast origins after target shifting, so this intersection needs a target-time audit before treating the result as a validated hybrid forecast.

## Experimental design and validation

The supplied detector extracts are described by the original documentation as US-101 data. They contain station IDs `717486`, `764766`, `717488`, `717489`, `717490`; geographic ordering, original download source, and extraction procedure are not supplied. Training covers eight observed dates, June 8–10 and 13–17, 2005 (11,495 station rows); testing covers June 20–22 (4,243 rows). Both notebooks use separate train/test files.

Four expanding-window folds train on the first four dates and validate on the fifth, then expand through the eighth date. The CV score averages fold RMSE computed over all station outputs. Final notebook metrics instead average the five per-station RMSEs. Persistence predicts each station’s current measurement at the future target.

`DELTA` values 1, 3 and 6 nominally mean 5, 15 and 30 minutes. The saved fitted notebook evaluations use **6**. Row shifts cross gaps, including the missing weekend, so elapsed horizons are not uniformly 30 minutes. Other horizon plots use manually entered arrays rather than a saved automated sweep.

Confirmed safeguards: test data are excluded from scaler fitting and model tuning; fold origins are chronological. Limitations: scaling is fitted on all training dates before CV, future target times are not purged across fold boundaries, and sampling continuity is not enforced. Thus the CV is not fully isolated against temporal leakage. [Full audit](docs/RESEARCH_AUDIT.md) records these issues without changing the experiments.

## Results

Values below are recovered from saved printed outputs, rounded to four decimals. Flow and speed are reported separately; these are means of per-station RMSEs, not pooled RMSE.

| Evaluation | Model | Test origins | Flow RMSE (veh/h) | Speed RMSE (km/h) |
|---|---|---:|---:|---:|
| Same six-row-ahead targets | TRR | 837 | 818.9118 | 8.1883 |
| Same six-row-ahead targets | Persistence | 837 | 880.3109 | 8.7941 |
| Separate subset; alignment unresolved | Hybrid CTM + TRR | 833 | 799.4998 | 9.8948 |
| No validated comparable forecast evaluation | CTM | — | — | — |

TRR has lower mean errors than persistence for both variables on their shared evaluation. It does not win at every station: persistence has lower speed RMSE at the first three stations. The hybrid’s smaller reported flow error does **not** establish an improvement over TRR, because the rows differ and CTM timing needs verification and export ground-truth station labels disagree with raw detector IDs (see the audit). MATLAB forecast scoring compares predictions to current rather than future observations, and no saved MATLAB evaluation log is included. CTM CSVs alone do not resolve this discrepancy.

Python uses `mph × 1.6`; MATLAB and supplied CTM ground-truth columns use `mph × 1.60934`. Both are labeled km/h, but the conversion difference also affects residual learning.

## Visualizations

![Saved TRR speed and flow predictions for five stations](figures/trr_saved_predictions.png)

Exported directly from the saved TRR notebook’s **Multi-Station Prediction Plot**, without rerunning the experiment. Left: speed (km/h); right: flow (veh/h), June 20, 2005. The x-axis shows forecast-origin timestamps; target values are six rows ahead. The hybrid notebook’s analogous plot is mislabeled: its code plots standalone TRR predictions. Hard-coded horizon charts are retained in the notebooks but are not used here as verified experimental evidence.

## Repository structure

```text
.
├── README.md
├── docs/RESEARCH_AUDIT.md          # Evidence, limitations, cleanup and checks
├── figures/trr_saved_predictions.png
├── TRR_Hybrid_models_code/
│   ├── AItrafficFlowTRR.ipynb      # TRR and persistence evaluations
│   ├── AItrafficFlowHybrid.ipynb   # CTM residual learning and comparisons
│   ├── README.md                  # Python reproduction notes
│   ├── requirements.txt           # Existing pinned environment
│   ├── *_split_for_ctm.csv        # Detector extracts
│   ├── ctm_outputs*.csv           # Supplied physics outputs
│   └── FAQ_revised.docx           # Original submission FAQ; see audit caveats
├── MATLAB Code CTM/               # Calibration, simulation, forecast and data
└── archive/                       # Distinct historical checkpoint notebooks
```

## Installation and reproduction

From the repository root, create a Python environment (Python 3.12 was specified by the original setup instructions):

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -r TRR_Hybrid_models_code/requirements.txt
cd TRR_Hybrid_models_code
jupyter lab
```

On Windows PowerShell activate with `.venv\Scripts\Activate.ps1`. Open either notebook and select the environment’s kernel. Inspect saved results without execution, or explicitly run cells top to bottom to repeat that experiment. Keep the working directory here so relative CSV paths resolve. See the [Python guide](TRR_Hybrid_models_code/README.md) for inputs and optional execution commands. Changing `DELTA` requires a corresponding CTM export and verified alignment; the training export has no horizon identifier.

For MATLAB, use the [MATLAB guide](MATLAB%20Code%20CTM/README.md). `main_forecast.m` uses fixed parameters and defaults to `Delta = 1`; calibration requires Optimization Toolbox. There is a filename issue in calibration and unresolved forecast target indexing. The checked-in scripts do not export the CTM CSVs used by Python.

All current input CSVs are included. No clean-environment installation, notebook execution, or MATLAB experiment was performed during this presentation update; full reproducibility is **not established**.

## Limitations and future work

This research prototype covers a small detector extract and a short temporal holdout; generalization to other roads, seasons, or traffic regimes is untested. CTM assumes uniform cells, a triangular fundamental diagram, zero ramp inflow, and a free downstream boundary. Linear residual learning may not represent nonlinear congestion transitions.

Before further scientific claims, verify CTM export station identities and target timestamps, score all models on identical origins and targets, use consistent speed conversion, enforce actual elapsed horizons, and fit preprocessing within each CV fold with target-time purging. Future work could automate horizon sweeps and investigate additional datasets or nonlinear residual models. These are proposed extensions, not implemented functionality.

## Technologies

Python, JupyterLab, NumPy, pandas, scikit-learn (`Ridge`, `StandardScaler`, MSE), Matplotlib, seaborn, and MATLAB with Optimization Toolbox. SciPy and notebook/kernel packages are also pinned in the existing requirements. The research combines numerical traffic modeling, temporal feature construction, regularized regression, chronological validation, and station-level error analysis.
