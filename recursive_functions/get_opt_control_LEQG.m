%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Selects optimal control for the thermostatic regulator 
%   using LEQG. 
%
% INPUT:
%   musOpt : optimal gains, i.e., musOpt(time_index, theta_index) are the 
%       Riccati_Control_Gains(time_index, theta_index) = control gain 
%       for time time_index-1 and theta = config.thetas(theta_index)
%   xprime : x - b, where x is original temperature state
%   time_index : index of the current time
%   theta_value : the risk aversion parameter value
%   config : configuration struct
% OUTPUT:
%   x0prime_sample = a random sample of x0'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function u = get_opt_control_LEQG(musOpt, xprime, time_index, theta_value, config)

    theta_index = find(config.thetas == theta_value);

    if isempty(theta_index)
       error('could not find theta_index');  
    end

    opt_gain = musOpt(time_index, theta_index);

    u = opt_gain * xprime;

end