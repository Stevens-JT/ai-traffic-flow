clear
clc
close all

%% Load data
data = load_detector_data('train_split_for_ctm');

% remove initial warmup
start_idx = 10;

data.flow  = data.flow(start_idx:end,:);
data.speed = data.speed(start_idx:end,:);
data.time  = data.time(start_idx:end);

flow_gt  = data.flow;
speed_gt = data.speed;

cells = size(flow_gt,2);

%% Data check
fprintf('Checking data...\n');
fprintf('NaN in speed: %d\n', sum(isnan(speed_gt(:))));
fprintf('NaN in flow: %d\n', sum(isnan(flow_gt(:))));
fprintf('Min speed: %.2f\n', min(speed_gt(:)));
fprintf('Max speed: %.2f\n', max(speed_gt(:)));
fprintf('Min flow: %.2f\n', min(flow_gt(:)));
fprintf('Max flow: %.2f\n', max(flow_gt(:)));

%% Parameters
params0 = [80, 20, 200, 5000, 0.5, 0.5];

lb = [40,  5,  80,  800, 0.0, 0.0];
ub = [120, 40, 250, 13000, 1.0, 1.0];

%% Optimization
options = optimoptions('fmincon', ...
    'Display','iter', ...
    'Algorithm','interior-point', ...
    'MaxIterations',100, ...
    'MaxFunctionEvaluations',5000);

params_opt = fmincon(@(p)objective_function(p,flow_gt,speed_gt), ...
                     params0,[],[],[],[],lb,ub,[],options);

%% Print optimal parameters
fprintf('\nOptimal parameters:\n');
fprintf('vf       = %.4f\n', params_opt(1));
fprintf('w        = %.4f\n', params_opt(2));
fprintf('kj       = %.4f\n', params_opt(3));
fprintf('qmax     = %.4f\n', params_opt(4));
fprintf('lambda_d = %.6f\n', params_opt(5));
fprintf('lambda_r = %.6f\n', params_opt(6));

%% Final simulation
[flow_model, speed_model, density_model] = ...
    ctm_simulation(params_opt, flow_gt, speed_gt);

%% RMSE per station
for i = 1:cells

    rmse_speed_i = sqrt(mean((speed_gt(:,i) - speed_model(:,i)).^2,'omitnan'));
    rmse_flow_i  = sqrt(mean((flow_gt(:,i)  - flow_model(:,i)).^2,'omitnan'));

    fprintf('Station %d -> RMSE speed = %.4f, RMSE flow = %.4f\n',...
            i, rmse_speed_i, rmse_flow_i);

end

%% Final PI
PI = objective_function(params_opt,flow_gt,speed_gt);
fprintf('Final PI = %.4f\n', PI);

%% SPEED / FLOW plots
figure

for i = 1:cells

    subplot(cells,2,2*i-1)
    plot(speed_gt(:,i),'k','LineWidth',1.2); hold on
    plot(speed_model(:,i),'r')
    title(sprintf('Speed - Station %d',i))
    ylabel('km/h')
    legend('Ground truth','CTM')

    subplot(cells,2,2*i)
    plot(flow_gt(:,i),'k','LineWidth',1.2); hold on
    plot(flow_model(:,i),'r')
    title(sprintf('Flow - Station %d',i))
    ylabel('veh/h')
    legend('Ground truth','CTM')

end

xlabel('Time step')

%% Density plots
figure

for i = 1:cells

    subplot(cells,1,i)
    plot(density_model(:,i),'b')
    title(sprintf('Density - Cell %d',i))
    ylabel('veh/km')

end

xlabel('Time step')

%% Fundamental diagrams from DATASET

density_gt = flow_gt ./ max(speed_gt,1e-3);

figure

for i = 1:cells

    subplot(2,3,i)

    scatter(density_gt(:,i), flow_gt(:,i), 8, 'k','filled')

  
    hold on
    vf   = params_opt(1);
    w    = params_opt(2);
    kj   = params_opt(3);
    qmax = params_opt(4);

    k = linspace(0,kj,200);

    q1 = vf * k;
    q2 = qmax * ones(size(k));
    q3 = w * (kj - k);

    q_fd = min(min(q1,q2),q3);

    plot(k,q_fd,'r','LineWidth',2)

    legend('Data','CTM FD')
    xlabel('Density (veh/km)')
    ylabel('Flow (veh/h)')
    title(sprintf('Empirical FD - Station %d',i))

end