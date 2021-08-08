%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Returns all parameters for thermostatic regulator system
% OUTPUT: 
%   parameters required for thermostatic regulator system; please
%   see reference for more details
% REFERENCE: 
%   I. Yang, “A dynamic game approach to distributionally robust safety
%   specifications for stochastic systems,” Automatica, vol. 94, pp. 94–101,
%   2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [R, a, Pow, eta, b] = therm_ctrl_load_parameters(config)

    h = config.dt; % in hours
    C = 2; % thermal capacitance in kilowatt hours per deg C
    R = 2; % thermal resistance in deg C per kilowatt
    a = exp( -h / (C*R) ); % (called "alpha" in Yang 2018)
    Pow = 14; % range of energy transfer to/from thermal mass in kilowatts
    eta = 0.7; % control efficiency coefficient
    b = 32; % degrees C (called "theta" in Yang 2018)

end