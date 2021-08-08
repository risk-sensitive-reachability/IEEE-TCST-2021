%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Builds the augmented state space for CVaR recursion
%   given possible stage costs
%
% INPUTs:
%  gx_all_values: ith possible value of the original stage cost 
%       (not necessarily non-negative) 
%  config struct 
%
% OUTPUTS: 
%  x3s : row vector of values for the additional state that keeps track 
%        of the cumulative cost up to current time
%  min_gx : lower bound of original stage cost, 
%        i.e., scenario.cost_function(...)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [min_gx, x3s] = get_AUG_state_range_SUMCOST(gx_all_values, config)

    min_gx = min(gx_all_values); % lower bound of original stage cost

    max_gx = max(gx_all_values); % upper bound of original stage cost

    % non-negative stage cost is scenario.cost_function(ambient.x1s,scenario) - min_gx

    % max non-negative stage cost is max_gx - min_gx

    % max cumulative non-negative stage cost is (max_gx - min_gx)*(N+1)

    x3max = (max_gx - min_gx) * (config.N+1);

    x3s = sort(unique([-x3max:config.augmented_state_grid_spacing:0, 0, x3max:-config.augmented_state_grid_spacing:0]));

end