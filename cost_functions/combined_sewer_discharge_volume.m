%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes total volume contributed to combined sewer
%   when in regulatory excess.
% INPUT: x(i,:) = [ith water level tank 1, ith water level tank 2]
%               = [ith value x1          , ith value x2          
% OUTPUT: 
%   cx : Total discharge volume to the combined sewer in excess of
%        regulatory allowance. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cx = combined_sewer_discharge_volume(x, scn, cfg, amb)

    if ~exist('scn','var')
        global scenario;
        scn = scenario; 
    end
    
    if ~exist('cfg','var')
        global config; 
        cfg = config;  
    end
        
    if ~exist('amb','var')
        global ambient; 
        amb = ambient; 
    end
    
    cubic_feet_per_hundred_cubic_feet = 0.01;

    discharge_rate_to_combined_sewer_from_tank1 = ... 
        q_outlet_linearized(x(:,1), 1, scn.combined_sewer_outlet_radius(1), ...
        scn.combined_sewer_outlet_elevation(1), amb.xmax(1)) .* scn.combined_sewer_outlet_quantity(1);

    discharge_rate_to_combined_sewer_from_tank2 = ...
        q_outlet_linearized(x(:,2), 1, scn.combined_sewer_outlet_radius(2), ...
        scn.combined_sewer_outlet_elevation(2), amb.xmax(2)) .* scn.combined_sewer_outlet_quantity(2);

    allowable_discharge_rate_to_combined_sewer_from_tank1_at_Kmax = ... 
        q_outlet_linearized(scn.K_max(1), 1, scn.combined_sewer_outlet_radius(1), ...
        scn.combined_sewer_outlet_elevation(1), amb.xmax(1)) .* scn.combined_sewer_outlet_quantity(1);

    allowable_discharge_rate_to_combined_sewer_from_tank2_at_Kmax = ...
        q_outlet_linearized(scn.K_max(2), 1, scn.combined_sewer_outlet_radius(2), ...
        scn.combined_sewer_outlet_elevation(2), amb.xmax(2)) .* scn.combined_sewer_outlet_quantity(2);

    % find the combined discharge rate to the sewer in excess of regulatory allowances
    rate_of_regulatory_excess = ...
        max(discharge_rate_to_combined_sewer_from_tank1 - allowable_discharge_rate_to_combined_sewer_from_tank1_at_Kmax,0) +...
        max(discharge_rate_to_combined_sewer_from_tank2 - allowable_discharge_rate_to_combined_sewer_from_tank2_at_Kmax,0);

    % assume discharge is constant over the timestep
    total_volume_discharged_above_regulatory_rate_limits = ...
        rate_of_regulatory_excess * cfg.dt * cubic_feet_per_hundred_cubic_feet; %penalty is in  

    % stage cost is based on total discharge volume to combiend sewer
    cx = total_volume_discharged_above_regulatory_rate_limits; 

end
