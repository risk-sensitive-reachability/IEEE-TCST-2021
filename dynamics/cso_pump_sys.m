%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Describes the instantaneous rate of water level change 
%   in a two-tank system connected by a bidirectional pump to mitigate 
%   combined sewer overflows. 
% INPUT:
    % xk(i) : water elevation at time k in tank i [ft]
    % uk : pump setting at time k [no units]
    % wk : average surface runoff rate on [k, k+1) [ft^3/s]
% OUTPUT:
    % xk_plus1(i) : water elevation at time k+1 in tank i [ft]
% ASSUMPTIONS: 
    % (1) System is outfitted with (passive) technology to linearize outflow with elevation
    % (2) u \in [-1, 1] provides linear control of pump flow rate
        % u = -1 : all power is devoted to putting water into tank 2
        % u = +1 : all power is devoted to putting water into tank 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xk_plus1 = cso_pump_sys( xk, uk, wk, cfg, scn, amb )

    % xk is a row vector where
    % xk(1) is x1 at current time step
    % xk(2) is x2 at current time step

    CSZ = scn.combined_sewer_outlet_elevation; % [ft] minimum elevation before discharge to combined sewer 
    CSR = scn.combined_sewer_outlet_radius;    % [ft] combined sewer outlet radius
    CSQ = scn.combined_sewer_outlet_quantity;  % [dimensionless] combined sewer outlet quantity

    SSZ = scn.storm_sewer_outlet_elevation;    % [ft] minimum elevation before discharge to storm sewer
    SSR = scn.storm_sewer_outlet_radius;       % [ft] storm sewer outlet radius

    % q_storm: discharge rate to storm sewer (from tank 2)
    q_storm_sewer = q_outlet_linearized(xk(2), 1, SSR, SSZ, amb.xmax(2)); 

    % q_to_combined_sewer: discharge to combined sewer from each tank
    q_to_combined_sewer_1 = q_outlet_linearized(xk(1), 1, CSR(1), CSZ(1), amb.xmax(1)) .* CSQ(1); 
    q_to_combined_sewer_2 = q_outlet_linearized(xk(2), 1, CSR(2), CSZ(2), amb.xmax(2)) .* CSQ(2);

    myeps = 1/12; % 1 inch

    % check if water is below (pump inlet - small amount)
    water_below_pump_inlet = (xk < (scn.pump_elevation - myeps));

    % check if water is in small band
    tank1_in_small_band = (xk(1) >= scn.pump_elevation(1) - myeps) && (xk(1) <= scn.pump_elevation(1) + myeps);
    tank2_in_small_band = (xk(2) >= scn.pump_elevation(2) - myeps) && (xk(2) <= scn.pump_elevation(2) + myeps);

    % pump is driving water from tank 1 to tank 2 but tank 1 elevation is too low
    % OR
    % pump is driving water from tank 2 to tank 1 but tank 2 elevation is too low
    if (water_below_pump_inlet(1) && uk < 0) || (water_below_pump_inlet(2) && uk >=0)
       q_pump = 0;  

    % pump is driving water from tank 1 to tank 2, but flow is partially
    % restricted because elevation in tank 1 is inside the band
    elseif (tank1_in_small_band && uk < 0)
       q_pump = q_pump_in_small_band_one_dim(xk(1), scn.pump_elevation(1), uk, myeps, scn.max_pump_rate);

    % pump is driving water from tank 2 to tank 1, but flow is partially
    % restricted because elevation in tank 2 is inside the band
    elseif (tank2_in_small_band && uk >= 0)
       q_pump = q_pump_in_small_band_one_dim(xk(2), scn.pump_elevation(2), uk, myeps, scn.max_pump_rate);

    % pumping is unrestricted in the desired direction
    % because the tank being pumped from has water level
    % above the band
    else
        % calculate desired pumping rate
        q_pump = scn.max_pump_rate * uk;
    end

    % f is a column vector where
    % f(1) is x1_dot
    % f(2) is x2_dot
    f = ones(scn.dim,1);

    if size(wk(:,1),1) == 2
       w1 = wk(1); 
       w2 = wk(2);   
    else
       w1 = wk;
       w2 = wk; 
    end

    f(1) = ( w1 - q_to_combined_sewer_1 + q_pump ) / scn.surface_area(1);                  % time-derivative of x1 [ft/s]
    f(2) = ( w2 - q_to_combined_sewer_2 - q_pump - q_storm_sewer ) / scn.surface_area(2);  % time-derivative of x2 [ft/s]

    xk_plus1 = xk + f' * cfg.dt; 

end