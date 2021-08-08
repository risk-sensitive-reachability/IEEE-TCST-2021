%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Adapts recursion results into the format required for 
%   downstream analysis. Performs a transform that re-translate's 
%   non-negative stage costs into their real equivalents.
% INPUT:
    % bellman_file = a path to a file containing Bellman recursion results 
% OUTPUT: 
    % transform_file = a path for the output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = non_negative_cost_transform_for_temp_system(bellman_file, transform_file)

    % declare globals so they are saved with results 
    global ambient;
    global scenario;
    global config;

    % if bellman file is available, load it
    load(bellman_file);
    
    % re-translate Js from non-negative space 
    max_distance_inside_safe_set = (scenario.K_max-scenario.K_min)/2;
    Js_translation = -(max_distance_inside_safe_set*(config.N+1));
    
    JsOpt = Js + Js_translation;            % optimal Js for all time
    J0Opt = Js(:,:,1) + Js_translation;     % optimal Js for time 0
    musOpt = mus;                           % optimal controls 
    
    % not applicable under this transform
    valueAtRiskOpt_nonneg_stage_cost = nan; 
        
    % save complete file
    save(transform_file, '-v7.3');
    
end