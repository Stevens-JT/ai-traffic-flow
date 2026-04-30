function data = load_detector_data(filename)

    if nargin < 1
        filename = 'test_split_for_ctm (1).csv';
    end

    T = readtable(filename);

    % Convert datetime if needed
    if ~isdatetime(T.datetime)
    T.datetime = datetime(T.datetime, 'InputFormat', 'M/d/yyyy H:mm');
    end

    stations = unique(T.Station);
    times = unique(T.datetime);

    cells = length(stations);
    N = length(times);

    data.time = times;

    flow  = nan(N, cells);
    speed = nan(N, cells);

    for s = 1:cells
        
        station_id = stations(s);
        idx = T.Station == station_id;
        Ts = T(idx,:);

        % Match time indices
        [lia, loc] = ismember(Ts.datetime, times);

        % Flow is already in veh/h
        flow(loc(lia), s) = Ts.flow(lia);

        % Speed: mph -> km/h
        speed(loc(lia), s) = Ts.speed(lia) * 1.60934;
    end

    % Replace NaN with 0
    flow(isnan(flow)) = 0;
    speed(isnan(speed)) = 0;

    % Density in veh/km
    density = flow ./ max(speed, 1e-6);

    data.flow = flow;
    data.speed = speed;
    data.density = density;

    fprintf('Loaded %d time steps and %d stations.\n', size(flow,1), size(flow,2));

end