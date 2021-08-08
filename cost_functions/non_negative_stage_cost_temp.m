%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes signed distance to temperature constraints then
%   adds a bias term to ensure the costs are non-negative. (i.e., the 
%   center of the constraint set has a value of 0.)
% INPUT: 
%	State vector X
% 	Scenario sruct
% OUTPUT: Signed distance w.r.t. constraints K
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gx = non_negative_stage_cost_temp(x, scn, cfg, amb) 

    if ~exist('scn','var')
        global scenario;
        scn = scenario; 
    end
    
    if ~exist('cfg','var')
        global config; 
        cfg = config;  
    end
        
    if ~exist('amb','var')
        global ambient; 
        amb = ambient; 
    end

    center_of_constraint_set = ((scn.K_min+scn.K_max)/2);                               % center of constraint set [deg C.]
    distance_from_center_to_constraint_boundary = scn.K_max - center_of_constraint_set; % also equivalent to center_of_constraint_set - scn.K_min; 
    
    % note, the following would also be equivalent
    % distance_from_center_to_constraint_boundary = (scn.K_max-scn.K_min)/2; 
    
    gx = max( scn.K_min - x, x - scn.K_max ) + distance_from_center_to_constraint_boundary; 