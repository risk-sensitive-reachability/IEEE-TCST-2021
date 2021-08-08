%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Defines discrete-time dynamics of Thermostatically controlled load 
% Adopted from: 
%   I. Yang, “A dynamic game approach to distributionally robust safety
%   specifications for stochastic systems,” Automatica, vol. 94, pp. 94–101,
%   2018.
% INPUT:
    % xk : temperature at time k [deg C]
    % uk : power setting at time k [no units]
    % wk : disturbance at time k [deg C]
    % config struct 
    % scenario struct
    % ambient struct
% OUTPUT:
    % xkPLUS1 : temperature at time k+1 [deg C]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xkPLUS1 = therm_ctrl_load( xk, uk, wk, config, scenario, ambient) 

    [R, a, Pow, eta, b] = therm_ctrl_load_parameters(config);

    xkPLUS1 = a*xk + (1 - a)*(b - eta * R * Pow * uk) + wk;

end
