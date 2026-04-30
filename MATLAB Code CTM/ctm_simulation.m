function [flow_model, speed_model, density_model] = ctm_simulation(params, flow_gt, speed_gt)

% params = [vf, w, kj, qmax, lambda_d, lambda_r]
% lambda_d, lambda_r not used yet

vf   = params(1);   % free flow speed (km/h)
w    = params(2);   % congestion wave speed (km/h)
kj   = params(3);   % jam density (veh/km)
qmax = params(4);   % capacity (veh/h)

cells = size(flow_gt,2);

dx = 0.6;          % km
dt = 5/3600;        
substeps = 60;      % 60 * 5 sec = 300 sec = 5 min

N = size(flow_gt,1);

flow_model    = zeros(N,cells);
speed_model   = zeros(N,cells);
density_model = zeros(N,cells);

% Initialization only
density_model(1,:) = flow_gt(1,:) ./ max(speed_gt(1,:),1e-3);
density_model(1,:) = max(density_model(1,:),1e-3);
density_model(1,:) = min(density_model(1,:),kj);

% Ramp settings
r = zeros(1,cells);   % on-ramp inflow (veh/h)
s = zeros(1,cells);   %#ok<NASGU> off-ramp split ratios (unused for now)

for t = 1:N-1

    k = density_model(t,:);

    % Boundary condition held constant over this 5-min interval
    demand_up = min(flow_gt(t,1), qmax);

    % Last-substep storage
    F = zeros(1, cells+1);   % interface flows
    v = zeros(1, cells);

    flow_accum  = zeros(1, cells);
    speed_accum = zeros(1, cells);

    for sub = 1:substeps

        demand = zeros(1,cells);
        supply = zeros(1,cells);

        % Demand / Supply from current state
        for i = 1:cells
            demand(i) = min(vf * k(i), qmax);
            supply(i) = min(qmax, w * (kj - k(i)));
            supply(i) = max(supply(i), 0);
        end

        % Interface flows
        F(1) = min(demand_up, supply(1));

        for i = 1:cells-1
            F(i+1) = min(demand(i), supply(i+1));
        end

        F(cells+1) = demand(cells);

        F = max(F,0);
        F = min(F,qmax);

        % Density update
        k_next = zeros(1,cells);
        for i = 1:cells
            k_next(i) = k(i) + (dt/dx) * (F(i) - F(i+1) + r(i));
        end

        % Physical bounds
        k_next = max(k_next,1e-3);
        k_next = min(k_next,kj);

        % Update state
        k = k_next;

        % Critical density
        kcr = qmax / max(vf,1e-6); %#ok<NASGU>

        % Raw speed from cell outflows
        v_raw = F(2:cells+1) ./ max(k,1e-3);

        % Mild speed assimilation
        if t == 1
            v = v_raw;
        else
            v = 0.7 * v_raw + 0.3 * speed_gt(t-1,:);
        end

        v = max(v,5);
        v = min(v,vf);

        flow_accum  = flow_accum  + F(2:cells+1);
        speed_accum = speed_accum + v;


        % Safety
        if any(isnan(k)) || any(isinf(k)) || any(isnan(F)) || any(isinf(F)) || ...
           any(isnan(v)) || any(isinf(v))
            error('Numerical instability at timestep %d, substep %d', t, sub);
        end
    end

    % Store final density state after 60 substeps
    density_model(t+1,:) = k;

    % Store 5-min averaged flow and speed
    flow_model(t,:)  = flow_accum  / substeps;
    speed_model(t,:) = speed_accum / substeps;
end

% Fill final row
flow_model(end,:)    = flow_model(end-1,:);
speed_model(end,:)   = speed_model(end-1,:);
density_model(end,:) = density_model(end-1,:);

end