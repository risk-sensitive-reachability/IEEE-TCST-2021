%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Defines the stage cost as an exponential of the signed distance w.r.t. constraint set
% INPUT:
%	globals:
%		ambient struct
%		config struct
%		scenario struct
% OUTPUT: Stage cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function c = initialize_stage_cost_matrix()

    global scenario
    global config
    global ambient

    if ~strcmp(func2str(scenario.cost_function_aggregation),'sum')
        error('sum is the only supported cost function aggregation')
    end

    % ambient.min_gx is the lower bound of the original stage cost
    % augmented state method for sum_cost uses non-negative (shifted) stage
    % costs, these are shifted back to the original stage cost in the transform
    % step (transform step occurs after Bellman recursion is finished)
    % recall that ambient is computed in calculate_ambient_variables.m
    % A in scenario id pertains to AUGMENTED STATE method
    if startsWith(scenario.id,'A') && size(ambient.xcoord,2) == 3 % dim of real states = 2, dim of aug state = 1
        c = zeros(ambient.nx,1);
        for j = 1:ambient.nx
            x1 = ambient.xcoord(j,1);
            x2 = ambient.xcoord(j,2);
            extra_state = ambient.xcoord(j,3); % extra state
            gx_shifted = scenario.cost_function([x1 x2], scenario, config, ambient) - ambient.min_gx;
            c(j) = max(gx_shifted - extra_state, 0 );
        end

    elseif startsWith(scenario.id,'A') && size(ambient.xcoord,2) == 2 % dim of real states = 1, dim of aug state = 1
        c = zeros(ambient.nx,1);
        for j = 1:ambient.nx
            x1 = ambient.xcoord(j,1);
            extra_state = ambient.xcoord(j,2); % extra state
            gx_shifted = scenario.cost_function(x1, scenario, config, ambient) - ambient.min_gx;
            c(j) = max(gx_shifted - extra_state, 0 );
        end

    else
        % assumes cost is only based on X and not confidence-level y
        % column vector, col(i) = stage cost for ith state
        % ambient.xcoord(i,:) = [x1 value, x2 value] for ith state
        col = scenario.cost_function(ambient.xcoord, scenario, config, ambient);

        if startsWith(scenario.id, 'E')
            c = repmat(col, [1,length(config.thetas)]); % [col, col, ..., col], where # repeats = # confidence levels
        else
            c = repmat(col, [1,length(config.ls)]); % [col, col, ..., col], where # repeats = # confidence levels
        end

    end

end