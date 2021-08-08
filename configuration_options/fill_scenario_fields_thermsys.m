%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: 
%    Fills several fields of scenario struct for thermostatic regulator system
% INPUT:
%   scenarioId = the string id of the scenario to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scenario = fill_scenario_fields_thermsys(scenarioId)

	scenario = []; scenario.dim = 1;

	scenario.title = ['Scenario ', scenarioId];

    scenario.K_max = 21;  % [deg C]
    scenario.K_min = 20;  % [deg C]
    
    switch(scenarioId)
        case 'TLS'
            % Left skew variance:  0.0303, left skew mean: 0.1479
            [scenario.ws, scenario.P, scenario.nw, scenario.wunits] = get_temperature_disturbance_profile('left skew'); 
        case {'TRS', 'PRS'}
            % Right skew variance: 0.0303, right skew mean: -0.1479
            [scenario.ws, scenario.P, scenario.nw, scenario.wunits] = get_temperature_disturbance_profile('right skew');
        case 'TNS'
            % No skew variance: 0.0268, no skew mean: very very close to 0
            [scenario.ws, scenario.P, scenario.nw, scenario.wunits] = get_temperature_disturbance_profile('no skew'); 
        case 'TGS'
            % Gaussian with variance  = 0.03, mean = 0; compare with above
            scenario.variance = 0.03; scenario.mean = 0; scenario.wunits = 'deg C'; 
        otherwise
            error('no disturbance defined for scenario')
    end

    if startsWith(scenarioId, 'TL') || startsWith(scenarioId, 'TR') || startsWith(scenarioId, 'TN')
        % stage_cost_temp is: gx = max( scenario.K_min - x, x - scenario.K_max );
        scenario.cost_function = str2func('stage_cost_temp'); 
        scenario.allowable_controls = 0: 0.1: 1;  
    elseif startsWith(scenarioId, 'PR')
        % non_negative_stage_cost_temp is: gx = max( scenario.K_min - x, x - scenario.K_max ) + (scenario.K_max-scenario.K_min)/2;
        % e.g. the value at the center of the constraint set is zero, all other states have positive cost
        scenario.cost_function = str2func('non_negative_stage_cost_temp'); 
        scenario.allowable_controls = 0: 0.1: 1;  
    elseif startsWith(scenarioId, 'TG')
        scenario.cost_function = str2func('get_quadratic_mat_temp');
        % note: scenario.allowable_controls = 'real line';  
    else
        error('cost function not defined for specified scenario'); 
    end
    
    scenario.dynamics = str2func('therm_ctrl_load');

end
