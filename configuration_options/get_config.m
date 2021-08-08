%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Create a structure containing scenario-agnostic simulation information
% INPUT:
%   configId = the numeric id of the configuration to use
% OUTPUT:
%   config = a structure containing scenario-agnostic simulation information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function config = get_config(configId)

    config = [];
    
    % number of samples to use when running Monte Carlo analysis
    config.monte_carlo_trials = 10e6; 
    
    switch configId

        % configurations relavent to the thermostatic regulator
        % configId 0 has a large range of theta values
        %   - useful e.g., for real valued costs
        % configId 5 has a more restricted range of theta values
        %   - useful e.g., for non-negative costs
        % configId 6 is a detailed look at theta <= -3
        %   - useful e.g., for a zoomed-in look at mean-variance tradeoff
        case {0, 5, 6}

            % assign thetas for EU
            if configId == 0
                config.id = '0';
                config.thetas = [-0.00005, -3, -9, -12, -15, -18, -24, -30, -60];
            elseif configId == 5
                config.id = '5';
                config.thetas = [-0.00005, -6, -7, -8];
            elseif configId == 6
                config.id = '6';
                config.thetas = [-0.00005, -0.5, -0.75, -1, -1.25, -1.5, -1.75, -2, -2.5, -3];
            end

            config.grid_spacing = 1/10;                        % [degrees C]
            config.dt = 5/60;                                  % Duration of [k, k+1) in hours, 5 min = 5/60 h
            config.augmented_state_grid_spacing = 1;           % [degrees C]
            config.T = 1;                                      % length of time horizon in hours, 60 min = 1 h
            config.grid_upper_buffer = 2;                      % [deg C]
            config.grid_lower_buffer = 2;                      % [deg C]
            config.ls = [ 0.999, 0.5, 0.05, 0.005 ]';          % alpha levels for CVaR

        case 3                                                 % temperature example for LEQG (we use grid to get initial condition for histograms)
            config.id = '3';
            config.dt = 5/60;
            config.T = 1;
            config.thetas = [-0.00005, -12, -30, -35, -40, -45, -50, -55, -60];
            config.grid_spacing = 1/10;
            config.grid_upper_buffer = 2;                      % [deg C]
            config.grid_lower_buffer = 2;

        case 1                                                 % water example
            config.id = '1';
            config.grid_spacing = 1/10;                        % [ft] state discretization interval
            config.augmented_state_grid_spacing = 5;           % [100s of ft3 ]
            config.dt = 300;                                   % Duration of [k, k+1) [sec], 5min = 300sec
            config.T = 3600*4;                                 % Design storm length [sec], 4h = 4h*3600sec/h
            config.grid_upper_buffer = [2.5, 3];               % [ft]
            config.grid_lower_buffer = 0;                      % [ft]
            config.ls = [ 0.999, 0.5, 0.05, 0.005 ]';          % alpha levels for CVaR
            config.thetas = [-0.00005, -0.0005, -0.005, ...    % theta levels for EU
                -0.05, -0.25, -0.5, -0.75, -1, -1.25, ...
                -1.5, -1.75, -2 ];

        case 100                                               % water example test configuration
            config.id = '100';                                 %   for quickly testing all workflows
            config.grid_spacing = 1;                           % [ft] state discretization interval
            config.augmented_state_grid_spacing = 50;          % [100s of ft3 ]
            config.dt = 300;                                   % Duration of [k, k+1) [sec], 5min = 300sec
            config.T = 300 * 2;                                % Design storm length [sec], 4h = 4h*3600sec/h
            config.grid_upper_buffer = [2.5, 3];               % [ft]
            config.grid_lower_buffer = 0;                      % [ft]
            config.ls = [ 0.999, 0.5, 0.05, 0.005 ]';          % alphas for CVar
            most_risk_averse_theta = -8;                       % theats for EU
            config.thetas = [-linspace( min(config.ls), -most_risk_averse_theta/2, length(config.ls)-1 ), most_risk_averse_theta];
            config.monte_carlo_trials = 1000; 

        otherwise
            disp('error loading config')

    end

    config.N = config.T/config.dt;

end