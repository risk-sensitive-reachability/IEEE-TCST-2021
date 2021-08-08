%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Initializes the ambient struct which contains information about
%         the state-space and means of indexing it, as well as some 
%         often-used results, such as the number of confidence levels. 
% INPUTS: 
%    globals:
%        config struct
%        scenario struct 
% OUTPUT:
%    globals:
%        ambient struct 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function calculate_ambient_variables

    global config;
    global scenario;
    global ambient;

    ambient = [];

    if ~startsWith(scenario.id, 'Q') %LEQG does not use this
        if startsWith(scenario.id, 'E')
            ambient.nl = length(config.thetas);
        else
            ambient.nl = length(config.ls);
        end
        ambient.nu = length(scenario.allowable_controls);
        ambient.nw = scenario.nw;
    end

    if scenario.dim == 1
        ambient.x1s = scenario.K_min-config.grid_lower_buffer:config.grid_spacing:scenario.K_max+config.grid_upper_buffer;
        ambient.x1g = ndgrid(ambient.x1s);
        ambient.x1n = length(ambient.x1s);
        ambient.nx = ambient.x1n;
        ambient.xcoord = ambient.x1s';
        ambient.xmax = max(ambient.x1s);
        ambient.xmin = min(ambient.x1s);
        ambient.real_state_values = ambient.xcoord; % so we keep track of real states before adding extra state
        ambient.x1g_real_states = ambient.x1g;

        if scenario.AUG_STATE
            gx_all_real_state_values = scenario.cost_function(ambient.real_state_values, scenario, config, ambient);

            [ambient.min_gx, ambient.x2s] = get_AUG_state_range_SUMCOST(gx_all_real_state_values, config);
            % [lower bound of ORIGINAL stage cost (may be negative), range of augmented state for cvar(sum cost) including 0]

            [X1, X2] = ndgrid(ambient.x1s, ambient.x2s);
            ambient.x1g = X1';
            ambient.x2g = X2';
            ambient.x2n = length(ambient.x2s);
            ambient.nx = ambient.x1n * ambient.x2n;
            ambient.xcoord = build_xcoord_2Dim(ambient); % this includes the augmented state
            if ~isequal(ambient.xmax, max(ambient.x1s))
                error('error with xmax');
            end
            if ~isequal(ambient.xmin, min(ambient.x1s))
                error('error with xmin');
            end
        end

    else
        ambient.x1s = scenario.K_min(1)-config.grid_lower_buffer:config.grid_spacing:(scenario.K_max(1)+config.grid_upper_buffer(1));
        ambient.x2s = scenario.K_min(2)-config.grid_lower_buffer:config.grid_spacing:(scenario.K_max(2)+config.grid_upper_buffer(2));
        [X1, X2] = ndgrid(ambient.x1s, ambient.x2s);
        ambient.x1g = X1';
        ambient.x2g = X2';
        ambient.x1n = length(ambient.x1s);
        ambient.x2n = length(ambient.x2s);
        ambient.nx = ambient.x1n * ambient.x2n;
        ambient.xmax = [max(ambient.x1s), max(ambient.x2s)];
        ambient.xmin = [min(ambient.x1s), min(ambient.x2s)];

        ambient.xcoord = build_xcoord_2Dim(ambient);

        ambient.real_state_values = ambient.xcoord; % so we keep track of real states before adding extra state
        ambient.x1g_real_states = ambient.x1g;
        ambient.x2g_real_states = ambient.x2g;

        %adds a third state with range [0, config.grid_upper_buffer] = [0,1.5].
        if scenario.AUG_STATE

            gx_all_real_state_values = scenario.cost_function(ambient.real_state_values, scenario, config, ambient);

            [ambient.min_gx, ambient.x3s] = get_AUG_state_range_SUMCOST(gx_all_real_state_values, config);
            % [lower bound of ORIGINAL stage cost (may be negative), range of augmented state for cvar(sum cost) including 0]

            %x3max = scenario.cost_function([max(ambient.x1s),max(ambient.x2s)], scenario, config, ambient)*(config.N+1);
            %ambient.x3s = sort(unique([-x3max:config.augmented_state_grid_spacing:0, 0, x3max:-config.augmented_state_grid_spacing:0]));

            [X1, X2, X3] = ndgrid(ambient.x1s, ambient.x2s, ambient.x3s);
            ambient.x1g = permute(X1, [2 1 3]);
            % first value of x1 in col 1, second value of x1 in col 2, etc.
            % a transpose that keeps 3rd dim the same
            ambient.x2g = permute(X2, [2 1 3]);
            % first value of x2 in row 1, second value of x2 in row 2, etc.
            ambient.x3g = permute(X3, [2 1 3]);
            % all entries in slice 1 is first value of x3, all entries in slice 2 is second value of x3, etc.
            % dim of each slice is # rows = # x2 values, # cols = # x1 values
            ambient.x3n = length(ambient.x3s);
            ambient.nx = ambient.x1n * ambient.x2n * ambient.x3n;

            z = 0;
            xcoord = zeros(ambient.nx,3);
            for i = 1:ambient.x1n
                for j = 1:ambient.x2n
                    for k = 1:ambient.x3n
                        z = z + 1;
                        xcoord(z,1) = ambient.x1s(i);
                        xcoord(z,2) = ambient.x2s(j);
                        xcoord(z,3) = ambient.x3s(k);
                    end
                end
            end
            ambient.xcoord = xcoord;

            if ~isequal(ambient.xmax, [max(ambient.x1s), max(ambient.x2s)])
                error('error with xmax');
            end

            if ~isequal(ambient.xmin, [min(ambient.x1s), min(ambient.x2s)])
                error('error with xmin');
            end
        end
    end

    if strcmp(func2str(scenario.bellman_backup_method), 'exponential_disutility_Bellman_backup')

        ambient.risk_aversion_to_optimal_control_mapping = config.thetas;

    elseif strcmp(func2str(scenario.bellman_backup_method), 'riccati_recursion_for_legq')

        ambient.risk_aversion_to_optimal_control_mapping = config.thetas;

    elseif strcmp(func2str(scenario.bellman_backup_method), 'State_aug_for_cvar_sum_backup')

        if scenario.dim == 1
            ambient.risk_aversion_to_optimal_control_mapping = ambient.x2s';
        elseif scenario.dim == 2
            ambient.risk_aversion_to_optimal_control_mapping = ambient.x3s';
        else
            error('only 1 and 2 dimensions supported');
        end

    else
        error('not a supported bellman backup method');

    end

end




