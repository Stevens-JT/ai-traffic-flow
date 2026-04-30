# CTM Calibration and Forecasting Code Overview

This folder contains the MATLAB implementation of the Cell Transmission Model (CTM) calibration and forecasting procedure.

## Main files

### 1. `main_calibration.m`
This is the main script for the CTM calibration process. It loads the training detector data, initializes the CTM parameters, and runs the optimization routine. The goal is to estimate the optimal CTM parameters:

- free-flow speed `vf`
- congestion wave speed `w`
- jam density `kj`
- maximum flow/capacity `qmax`

The script uses `objective_function.m`, which repeatedly calls `ctm_simulation.m` during the optimization process. The expected output is the optimized parameter vector, together with the calibration results and plots such as flow, speed, and the fundamental diagram.

### 2. `ctm_simulation.m`
This function implements the CTM simulation used during calibration. Given a parameter vector and the observed flow and speed data, it simulates the evolution of density, flow, and speed across the five detector stations.

The simulation uses the demand-supply formulation of the CTM and updates density based on the conservation law. The output is the modeled flow, speed, and density over the full training time horizon.

### 3. `objective_function.m`
This function defines the performance criterion used by the optimizer in `main_calibration.m`.

It compares the simulated CTM outputs with the observed detector data and computes:

- flow RMSE
- speed RMSE
- normalized performance index `PI`

The optimizer minimizes this performance index in order to identify the best CTM parameters.

### 4. `main_forecast.m`
This script evaluates the calibrated CTM on the test dataset. It loads the test data, applies the optimized parameter values obtained from calibration, and performs forecasting for a selected horizon:

- `Delta = 1` for 5 minutes ahead
- `Delta = 3` for 15 minutes ahead
- `Delta = 6` for 30 minutes ahead

The script computes RMSE values per station and overall RMSE for both flow and speed. It also generates plots comparing CTM forecasts against the ground-truth test data.

### 5. `ctm_forecast_delta.m`
This function is called by `main_forecast.m`. It performs the actual Delta-step-ahead CTM forecast using the calibrated parameters and the current observed traffic state.

It initializes density from the current measured flow and speed, propagates the CTM dynamics forward for the selected forecast horizon, and returns the predicted flow, speed, and density.

## Suggested reading order

1. Run or inspect `main_calibration.m`
2. Review `objective_function.m`
3. Review `ctm_simulation.m`
4. Run or inspect `main_forecast.m`
5. Review `ctm_forecast_delta.m`

