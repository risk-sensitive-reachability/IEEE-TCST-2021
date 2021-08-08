%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: 
%    Fills several fields of scenario struct for stormwater system
% INPUT:
%   scenarioId = the string id of the scenario to use
%   number_of_controls = the number of controls to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scenario = fill_scenario_fields_watersys(scenarioId, number_of_controls) 
    
    scenario = []; scenario.dim = 2;
    
    scenario.surface_area = [30000, 10000];               % [ft^2] tank surface area

    scenario.pump_elevation = [1, 1];                     % [ft] minimum tank elevation before pumping can occur
    
    if scenario.pump_elevation(1) ~= scenario.pump_elevation(2)
        error('should make pump elevations same so cso_pump_sys.m makes sense');
    end

    scenario.max_pump_rate = 10;                          % [cfs] maximum pumping rate 

    scenario.combined_sewer_outlet_quantity = [3, 1];     % [dimensionless] number of oulets discharging to combined sewer
    scenario.combined_sewer_outlet_elevation = [3, 4];    % [ft] minimum elevation before discharge to combined sewer
    scenario.combined_sewer_outlet_radius = [1/4, 3/8];   % [ft] radius of combined sewer outlets

    scenario.storm_sewer_outlet_elevation = 1;            % [ft] minimum elevation in tank 2 before discharge to storm sewer
    scenario.storm_sewer_outlet_radius = 1/3;             % [ft] radius of storm sewer outlet
    
    scenario.K_min = zeros(2,1);
    scenario.K_max = (scenario.combined_sewer_outlet_elevation + [0, 0])';

    [scenario.ws, scenario.P, scenario.nw, scenario.wunits] = ...
        get_runoff_disturbance_profile('major right skew');
    
    scenario.cost_function = str2func('combined_sewer_discharge_volume');
    scenario.dynamics = str2func('cso_pump_sys');
    
    if number_of_controls == 3
        scenario.allowable_controls = [0, 1, -1];
    elseif number_of_controls == 5
        scenario.allowable_controls = [0, 1, 0.5, -1, -0.5]; 
    else
        error('not a valid number of controls'); 
    end
    
end