clear
clc
close all

%% Load data
data = load_detector_data('test_split_for_ctm (1).csv');

% remove initial warmup
start_idx = 10;

data.flow  = data.flow(start_idx:end,:);
data.speed = data.speed(start_idx:end,:);
data.time  = data.time(start_idx:end);

flow_gt  = data.flow;
speed_gt = data.speed;

N     = size(flow_gt,1);
cells = size(flow_gt,2);

%% Fixed calibrated parameters
% params = [vf, w, kj, qmax]
params_opt = [107.4365, 40.0000, 250, 7515.5236];

%% Forecast horizon
Delta = 1;   % choose 1, 3, or 6

%% Storage
flow_pred_all  = nan(N, cells);
speed_pred_all = nan(N, cells);

%% Forecast loop
for t = 1:N-Delta

    % Initialize density from observed data at time t
    k_init = flow_gt(t,:) ./ max(speed_gt(t,:),1e-3);
    k_init = max(k_init,1e-3);
    k_init = min(k_init,params_opt(3));

    % Smoothed upstream boundary demand for next Delta steps
    d0 = flow_gt(t,1);
    if t > 1
        d0 = 0.7 * flow_gt(t,1) + 0.3 * flow_gt(t-1,1);
    end
    d0 = min(d0, 0.9 * params_opt(4));

    demand_up_series = repmat(flow_gt(t,1), Delta, 1);

    [flow_pred, speed_pred] = ...
        ctm_forecast_delta(params_opt, k_init, demand_up_series, Delta);

    flow_pred_all(t,:)  = flow_pred;
    speed_pred_all(t,:) = speed_pred;

end

%% Compute RMSE per station
fprintf('\nValidation results for Delta = %d (%d min ahead)\n', Delta, Delta*5);

for i = 1:cells

    rmse_speed_i = sqrt(mean( ...
        (speed_gt(1:N-Delta,i) - speed_pred_all(1:N-Delta,i)).^2, 'omitnan'));

    rmse_flow_i = sqrt(mean( ...
        (flow_gt(1:N-Delta,i) - flow_pred_all(1:N-Delta,i)).^2, 'omitnan'));

    fprintf('Station %d -> RMSE speed = %.4f, RMSE flow = %.4f\n', ...
        i, rmse_speed_i, rmse_flow_i);

end

%% Overall RMSE
RMSEspeed = sqrt(mean( ...
    (speed_gt(1:N-Delta,:) - speed_pred_all(1:N-Delta,:)).^2, 'all', 'omitnan'));

RMSEflow = sqrt(mean( ...
    (flow_gt(1:N-Delta,:) - flow_pred_all(1:N-Delta,:)).^2, 'all', 'omitnan'));

PI = 0.5*(RMSEspeed/120) + 0.5*(RMSEflow/8000);

fprintf('\nOverall RMSEspeed = %.4f\n', RMSEspeed);
fprintf('Overall RMSEflow  = %.4f\n', RMSEflow);
fprintf('PI                = %.4f\n', PI);

%% Plots
figure

for i = 1:cells

    subplot(cells,2,2*i-1)
    plot(speed_gt(1:N-Delta,i),'k','LineWidth',1.2); hold on
    plot(speed_pred_all(1:N-Delta,i),'r')
    title(sprintf('Speed - Station %d', i))
    ylabel('km/h')
    legend('Ground truth','CTM forecast')

    subplot(cells,2,2*i)
    plot(flow_gt(1:N-Delta,i),'k','LineWidth',1.2); hold on
    plot(flow_pred_all(1:N-Delta,i),'r')
    title(sprintf('Flow - Station %d', i))
    ylabel('veh/h')
    legend('Ground truth','CTM forecast')

end

xlabel('Time step')