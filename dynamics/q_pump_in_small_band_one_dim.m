%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes a continuous function for one_state \in 
%   [pump_elevation - myeps, pump_elevation + myeps] so that: 
%      - pump_rate_in_small_band = 0 if one_state = pump_elevation - myeps
%      - pump_rate_in_small_band = max_pump_rate * u if one_state = pump_elevation + myeps,
%           where myeps is a small positive number
% INPUTS: 
%   one_state : one of the tank states [ft]
%   pump_elevation : elevation of pump [ft]
%   u : pump control state
%   myeps : small positive number 
%   max_pump_rate : maximum pumping rate supported by pump [cfs]
%   
% OUTPUTS:
%   pump_rate_in_small_band : a scaled pumping rate that 
%       accounts for 'pump startup' [cfs]
function pump_rate_in_small_band = q_pump_in_small_band_one_dim(one_state, pump_elevation, u, myeps, max_pump_rate)

    pump_rate_in_small_band = max_pump_rate * u / (2 * myeps) * (one_state + myeps - pump_elevation);

end