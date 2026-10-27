# MATLAB Cell Transmission Model

These scripts implement five-cell CTM calibration, simulation and nominal multi-step forecasting. See the [project overview](../README.md) and [audit](../docs/RESEARCH_AUDIT.md) for interpretation limits.

## Files and methods

- `load_detector_data.m`: pivots stations using sorted `unique` IDs, converts mph to km/h with 1.60934, fills missing measurements with zero, and derives density as flow/speed.
- `ctm_simulation.m`: triangular demand/supply model, 0.6 km cells, five-second substeps, averaged five-minute outputs and mild speed assimilation from previous observations. Ramp inflow is zero.
- `objective_function.m`: minimizes `0.5*(RMSEspeed/120) + 0.5*(RMSEflow/8000)`, using pooled errors.
- `main_calibration.m`: removes the first nine time rows and uses constrained `fmincon` (Optimization Toolbox). It optimizes six parameters, but the last two are unused by the simulation.
- `ctm_forecast_delta.m`: initializes from observed density, holds upstream demand constant over the horizon and returns final-step flow/speed. Downstream outflow equals cell demand.
- `main_forecast.m`: fixed parameters `[107.4365, 40, 250, 7515.5236]`, default `Delta = 1`; values 1, 3, 6 nominally represent 5, 15, 30 minutes.

## Running and known blockers

Set the MATLAB Current Folder to this directory. The training and test CSVs are included; their bytes duplicate the Python inputs but the test filename here contains ` (1)`.

To inspect the current forecast behavior:

```matlab
main_forecast
```

**Its printed errors are not validated future-target errors:** forecasts generated from row `t` are compared to observations at row `t`, rather than `t + Delta`. The plots have the same issue. The smoothed boundary variable `d0` is computed but not used; upstream demand actually repeats current first-station flow. Do not quote these errors as multi-step forecasting performance.

Calibration also requires a filename correction before running: change the load argument in `main_calibration.m` from `'train_split_for_ctm'` to `'train_split_for_ctm.csv'`. Then, with Optimization Toolbox installed:

```matlab
main_calibration
```

This optimization may be expensive. The documentation update does not change or rerun the scripts. `main_forecast` starts with `clear` and uses fixed parameters; it does not automatically reuse a preceding calibration result. Transfer calibrated values explicitly if conducting a new experiment.

No MATLAB version or saved optimization log is provided. No checked-in script writes the `ctm_outputs*.csv` files used by the hybrid notebook. Their generation, station mapping, and origin/target timestamp convention must be recovered before claiming end-to-end reproducibility.
