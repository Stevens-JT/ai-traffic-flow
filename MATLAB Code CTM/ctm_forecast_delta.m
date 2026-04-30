function [flow_pred, speed_pred, density_pred] = ctm_forecast_delta(params, k_init, demand_up_series, Delta)

    vf   = params(1);
    w    = params(2);
    kj   = params(3);
    qmax = params(4);

    dx = 0.6;          % km
    dt = 5/3600;       % hours = 5 sec
    substeps = 60;     % 60 * 5 sec = 5 min

    cells = length(k_init);

    k = k_init;

    for t = 1:Delta

        demand_up = min(demand_up_series(t), qmax);

        for sub = 1:substeps

            demand = min(vf * k, qmax);
            supply = min(qmax, w * (kj - k));
            supply = max(supply, 0);

            F = zeros(1, cells+1);

            % Upstream boundary
            F(1) = min(demand_up, supply(1));

            % Internal interfaces
            for i = 1:cells-1
                F(i+1) = min(demand(i), supply(i+1));
            end

            % Downstream boundary
            F(cells+1) = demand(cells);

            F = max(F, 0);
            F = min(F, qmax);

            % Density update
            k_next = k + (dt/dx) * (F(1:cells) - F(2:cells+1));
            k_next = max(k_next, 1e-3);
            k_next = min(k_next, kj);

            k = k_next;
        end
    end

    % Final predicted density
    density_pred = k;

    % Final predicted flow
    flow_pred = F(2:cells+1);

    % Triangular-FD speed
    kcr = qmax / max(vf, 1e-6);

    speed_pred = zeros(1, cells);
    for i = 1:cells
        if k(i) <= kcr
            speed_pred(i) = vf;
        else
            speed_pred(i) = w * (kj - k(i)) / max(k(i), 1e-3);
        end
    end

    speed_pred = max(speed_pred, 5);
    speed_pred = min(speed_pred, vf);

end