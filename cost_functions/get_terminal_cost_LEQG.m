%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes quadratic terminal cost for the thermostatic
%   regulator subject to LEQG
% INPUT: 
%	xprime = x - b, where x is original temperature state
% OUTPUT: 
%   terminal_cost_value : terminal LEQG cost based on xprime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function terminal_cost_value = get_terminal_cost_LEQG(xprime)

    [R, Q, RN] = get_quadratic_mat_temp();

    % R = state_stage_cost_matrix
    % Q = control_stage_cost_matrix 
    % RN = terminal_cost_matrix

    terminal_cost_value = xprime' * RN * xprime;
    
end