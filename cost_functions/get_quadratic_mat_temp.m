%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes cost matrices for LEQR example
% OUTPUT: 
    % R_state_stage_cost_matrix = matrix of stage costs 'R'
    % control_stage_cost_matrix = matrix of control costs 'Q'
    % terminal_cost_matrix = matrix of terminal costs 'RN' 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R_state_stage_cost_matrix, ...
    Q_control_stage_cost_matrix, ...
    terminal_cost_matrix] = get_quadratic_mat_temp()

    R_state_stage_cost_matrix = 0.01;

    Q_control_stage_cost_matrix = 1;

    terminal_cost_matrix = R_state_stage_cost_matrix;

end





