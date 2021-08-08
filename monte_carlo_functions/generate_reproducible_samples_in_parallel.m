%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generates many samples of the desired type. Intended
%   to be called from a methods like generate_histograms or 
%   generate_trajectories. The type argument determines the type 
%   of value returned. 
%
%   Note: this method mostly checks that it is valid to proceed,
%   then dispatches get_samples_in_parallel, which is where the
%   sampling actually happens. 
%           
% INPUT:
%   type: a string specifying the type to return: 
%        'state_trajectories' - (numer of trials, number of dimensions, number of timesteps +1)
%        'control_trajectories' - (numer of trials, number of timesteps)
%        'stage_cost_trajectories' - (number of trials, number of timesteps + 1)
%        'cumulative_costs' - (number of trials)
%
%   valueAtRiskOpt_nonneg_stage_cost: A matrix from Run_Transform_Step of 
%       the form valueAtRiskOpt_nonneg_stage_cost(real_state, confidence_level_index)
%   Zs: transition fo the confidence level under optimal policy
%	mus: optimal controllers
%	x0: initial state vector
%	l0: initial confidence level
%   n: number of stage cost trajectories to sample 
% OUTPUT: 
%   samples: a matrix with size corresponding to type (see above)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function samples = generate_reproducible_samples_in_parallel(type, valueAtRiskOpt_nonneg_stage_cost, Zs, mus, x0, l0, n)
    
    global ambient;
    global scenario; 
    global config; 
    
    amb = ambient;
    cfg = config; 
    scn = scenario; 
    
    fuzzy_boundary_offset = cfg.grid_spacing/2;
    
    if scenario.dim == 2
        x_index = find(...
            and(...
                and(...
                    ambient.real_state_values(:,1) > x0(1)-fuzzy_boundary_offset,...
                    ambient.real_state_values(:,1) > x0(1)+fuzzy_boundary_offset),...
                and(...
                    ambient.real_state_values(:,2) > x0(2)-fuzzy_boundary_offset, ...
                    ambient.real_state_values(:,2) < x0(2)+fuzzy_boundary_offset)...
                )...
            ,1);
    elseif scenario.dim == 1
        x_index = find(ambient.real_state_values(:,1) == x0); 
    else
        error('no other scenario.dim supported.');
    end
     
    if or(startsWith(scenario.id,'A'),startsWith(scenario.id,'C')) % cvar methods
        l_index = find(config.ls == l0); 
    elseif startsWith(scenario.id,'E') || startsWith(scenario.id,'Q') % exponential utility methods
        l_index = find(config.thetas == l0);
    else
        error('no other scenario supported.');
    end
    
    if isempty(l_index)
       error('could not find lindex');  
    end
    
    if isempty(x_index)
       error('could not find xindex');  
    end
        
    samples = get_samples_in_parallel(type, valueAtRiskOpt_nonneg_stage_cost, Zs, mus, x_index, l_index, n, cfg, scn, amb);

end
                