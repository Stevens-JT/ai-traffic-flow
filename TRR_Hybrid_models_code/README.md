# CTM

To run the CTM code go into the folder MATLAB Code CTM and read the README.md there.

# Hybrid CTM–Ridge Traffic Modeling

This repository contains the code and data pipeline used to compare a physics-based Cell Transmission Model (CTM), a Temporal Ridge Regression (TRR) model, and a hybrid CTM-ridge residual-learning model for short-term traffic forecasting on the US-101 detector dataset.

## What this project does

The pipeline supports three main modeling tasks:

1. **Temporal Ridge Regression (TRR)**
   - Builds a wide spatiotemporal feature matrix from lagged flow and speed values across all five stations.
   - Trains separate ridge regression models for future flow and future speed.
   - Uses rolling time-series cross-validation to tune the ridge regularization parameter.

2. **Hybrid CTM-Ridge Residual Learning**
   - Uses CTM outputs as a physics-based baseline forecast.
   - Computes residuals between the true targets and CTM predictions.
   - Trains ridge regression models to predict residual corrections.
   - Forms the hybrid forecast as:
     - `hybrid = CTM + learned residual`

3. **Evaluation and Visualization**
   - Reports mean per-station RMSE values.
   - Produces per-station comparisons and forecast plots.

## Data and unit conventions

- The raw detector speed data in the train/test CSV files are recorded in **mph**.
- Before TRR training and evaluation, the notebook converts speed to **km/h** by multiplying by `1.6`.
- The CTM outputs used for hybrid residual learning are also in **km/h**.
- Therefore, the final reported TRR and hybrid speed results are in **km/h**.
- Flow is reported in **veh/h**.

## Expected files

Place the following files in the same directory as the notebook unless you modify the file paths in the code:

### Required train/test detector data
- `train_split_for_ctm.csv`
- `test_split_for_ctm.csv`

### Required CTM outputs for hybrid modeling
- `ctm_outputs__train_forResiduals.csv`
- `ctm_outputs_test_D6_forResiduals.csv`

### Optional CTM outputs for other horizons in hybrid modeling
- `ctm_outputs_test_D1_forResiduals.csv`
- `ctm_outputs_test_D3_forResiduals.csv`

## Notebook
In the commands below, replace:

- `AItrafficFlowHybrid.ipynb`

with 
- `AItrafficFlowTRR.ipynb`

if you desire to run the temporal ridge regression notebook.

## Recreating the Python virtual environment

This project was developed in a Python virtual environment. The environment can be recreated from `requirements.txt`.

### 1. Create the virtual environment

On macOS/Linux:

```bash
python3.12 -m venv .venv
```

If `python3.12` is not available, use:

```bash
python -m venv .venv
```

### 2. Activate the virtual environment

On macOS/Linux:

```bash
source .venv/bin/activate
```

On Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

### 3. Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. (Optional) Register the environment as a Jupyter kernel

```bash
python -m ipykernel install --user --name traffic-modeling --display-name "Python (traffic-modeling)"
```

## How to run the pipeline

### Option A — Run interactively in Jupyter

Launch Jupyter Lab:

```bash
jupyter lab
```

Then open the final notebook and run the cells from top to bottom.

### Option B — Execute the notebook from the command line

```bash
jupyter nbconvert --to notebook --execute AItrafficFlowHybrid.ipynb \
  --output AItrafficFlowHybrid.executed.ipynb \
  --ExecutePreprocessor.timeout=-1
```

This executes the notebook end-to-end and saves an executed copy.

## Pipeline order inside the notebook

The notebook should be run in the following order:

1. **Imports and configuration**
   - Sets `K_LAGS`, `DELTA`, and file paths.

2. **Load detector train/test data**
   - Reads `train_split_for_ctm.csv` and `test_split_for_ctm.csv`.
   - Converts raw speed from mph to km/h.

3. **Preprocessing**
   - Keeps the required columns.
   - Drops rows with missing flow/speed values.

4. **Construct wide spatiotemporal features**
   - Preserves station order from the training file.
   - Creates lagged flow and speed features across all stations.
   - Builds target matrices for flow and speed.

5. **Scale features**
   - Standardizes the TRR input matrix using training-data statistics only.

6. **Build rolling cross-validation folds**
   - Uses expanding-window time-series CV.

7. **Train and evaluate baseline TRR**
   - Tune `lambda` for flow and speed separately.
   - Train final ridge models.
   - Predict on the test set.
   - Compute per-station and average RMSE.

8. **Load CTM outputs and align timestamps**
   - Load the CTM train and test forecast files.
   - Align on the timestamps common to both CTM outputs and TRR targets.

9. **Train and evaluate the hybrid model**
   - Compute residual targets.
   - Tune residual ridge models for flow and speed.
   - Predict residuals and reconstruct the hybrid forecast.
   - Compute per-station and average RMSE.

10. **Generate plots/tables**
   - Per-station TRR vs hybrid comparisons.
   - Ground truth vs model forecast plots.

## Key parameters

The main parameters in the notebook are:

- `K_LAGS = 6`
  - Uses 30 minutes of lag history at 5-minute resolution.
- `DELTA = 6`
  - Corresponds to a 30-minute-ahead forecast horizon.

If you change `DELTA`, make sure the matching CTM forecast files and downstream evaluation logic also correspond to that horizon.

## Expected outputs

Running the final notebook should produce:

- Baseline TRR flow and speed RMSE values
- Hybrid flow and speed RMSE values
- Per-station RMSE comparisons
- Plots comparing:
  - ground truth vs TRR
  - ground truth vs hybrid
  - RMSE across models/horizons (if included)

## Recommended project structure

A simple layout is:

```text
project/
├── AItrafficFlowHybrid.ipynb
├── AItrafficFlowTRR.ipynb
├── README.md
├── requirements.txt
├── FAQ_revised.docx
├── train_split_for_ctm.csv
├── test_split_for_ctm.csv
├── ctm_outputs__train_forResiduals.csv
├── ctm_outputs_test_D1_forResiduals.csv
├── ctm_outputs_test_D3_forResiduals.csv
├── ctm_outputs_test_D6_forResiduals.csv
└── figures/
```

## Troubleshooting

### File not found
If the notebook cannot find input files, verify that:
- the CSV files are in the same folder as the notebook, or
- the file path variables at the top of the notebook were updated correctly.

### Unit confusion
If speed results look inconsistent:
- verify whether speed conversion from mph to km/h is active,
- verify that the CTM speed outputs used for residual learning are also in km/h,
- ensure the paper/report labels final speed RMSE values in km/h.

### Metric inconsistencies
If a table and the surrounding text disagree, make sure all reported values come from the same final notebook run. This project uses **mean per-station RMSE** unless otherwise noted.

### Hybrid alignment issues
If the hybrid block throws indexing errors, confirm that:
- CTM outputs were loaded correctly,
- datetime columns were parsed correctly,
- train/test alignment is performed using the timestamp intersection before residual computation.

## Citation / reporting note

When documenting results from the final notebook:
- report **flow RMSE in veh/h**,
- report **speed RMSE in km/h**,
- clearly state that raw speed was originally recorded in mph and converted before modeling.

