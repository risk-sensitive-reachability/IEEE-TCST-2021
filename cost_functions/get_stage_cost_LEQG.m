%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes quadratic terminal cost for the thermostatic
%   regulator subject to LEQG
% INPUT: 
%	xprime = x - b, where x is original temperature state
%   u = control state
% OUTPUT: 
%   terminal_cost_value : stage LEQG cost based on xprime and u
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stage_cost_value = get_stage_cost_LEQG(xprime, u)

    [R, Q, RN] = get_quadratic_mat_temp();

    % R = state_stage_cost_matrix
    % Q = control_stage_cost_matrix 
    % RN = terminal_cost_matrix

    stage_cost_value = xprime'*R*xprime + u'*Q*u;

end

    
   