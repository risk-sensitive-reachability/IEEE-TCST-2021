%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes signed distance to temperature constraints
% INPUT: 
%	State vector X
% 	Scenario sruct
% OUTPUT: Signed distance w.r.t. constraints K
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gx = stage_cost_temp(x, scn, cfg, amb) 

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

gx = max( scn.K_min - x, x - scn.K_max );


