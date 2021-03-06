%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: A generic method that calls a particular recursive Bellman 
%   function specified in the scenario
% INPUT: 
    % J_k+1 : optimal cost-to-go at time k+1, array
    % globals: 
    %   scenario struct
% OUTPUT: 
    % J_k : optimal cost-to-go starting at time k, array
    % mu_k : optimal controller at time k, array
    % Zs_k : confidence level transitions under optimal policies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Zs_k, J_k, mu_k ] = perform_Bellman_backup_step(J_kPLUS1)

    global scenario; 
    [Zs_k, J_k, mu_k] = scenario.bellman_backup_method(J_kPLUS1);
    
end