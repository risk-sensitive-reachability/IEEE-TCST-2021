%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Computes A & B matrices required for Riccati recursion given
%   the dynamics in therm_ctrl_load.m, where the state is xk - b
%   and the system dynamics are: (x_k+1 - b) = A*(xk - b) + B*uk + wk
% INPUT:
    % config struct
% OUTPUT: 
    % A : "A" matrix for Riccati recursion
    % B : "B" matrix for Riccati recursion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, B] = get_state_space_temp(config)

    [R, a, Pow, eta, b] = therm_ctrl_load_parameters(config);

    A = a;

    B = (a-1) * eta * R * Pow;

end
