function PI = objective_function(params, flow_gt, speed_gt)

try

    [flow_model, speed_model, ~] = ctm_simulation(params, flow_gt, speed_gt);

    % RMSE across all stations and timesteps
    RMSEspeed = sqrt(mean((speed_gt(:) - speed_model(:)).^2, 'omitnan'));
    RMSEflow  = sqrt(mean((flow_gt(:)  - flow_model(:)).^2,  'omitnan'));

    % Performance Index
    %PI = RMSEspeed + RMSEflow;
    PI = 0.5*(RMSEspeed/120) + 0.5*(RMSEflow/8000);

    % Prevent optimizer crashes
    if isnan(PI) || isinf(PI)
        PI = 1e12;
    end

    % Debug print
    fprintf('RMSEspeed = %.4f, RMSEflow = %.4f, PI = %.4f\n', RMSEspeed, RMSEflow, PI);

catch
    PI = 1e12;
end

end