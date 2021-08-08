%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Builds a vector of shifted stage costs sot hat the 
%   stage cost is non-negative. Assumes that the last column of 
%   ambient.xcoord contains the value of the augmented state. 
%
%   The jth value of real state [x1 x2 ... x_n] is 
%   ambient.xcoord(j,1:end-1) and stage_cost_shifted(j) = 
%   scenario.cost_function(ambient.xcoord(j,1:end-1),...) - ambient.min_gx;
%
% INPUTs:
%   ambient struct 
%   scenario struct 
%   config struct 
%
% OUTPUTS: 
%  stage_cost_shifted : vector of shifted stage costs so that the 
%   stage cost is non-negative
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stage_cost_shifted = shift_stage_cost_vector_AUGSTATE(scenario, config, ambient)

stage_cost_shifted = ...
    scenario.cost_function(ambient.xcoord(:,1:end-1),scenario, config, ambient)...
    - ambient.min_gx;  

end


        
        