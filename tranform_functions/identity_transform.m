%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Adapts recursion results into the format required for 
%   downstream analysis. Uses an 'identity' transform that leaves the
%   result values untransformed. 
% INPUT:
    % bellman_file = a path to a file containing Bellman recursion results 
% OUTPUT: 
    % transform_file = a path for the output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[] = identity_transform(bellman_file, transform_file)

    % declare globals so they are saved with results 
    global ambient;
    global scenario;
    global config;

    % load Bellman
    load(bellman_file);
    
    % identity transform does not modify Js
    JsOpt = Js;         % optimal Js for all time
    J0Opt = Js(:,:,1);  % optimal Js for time 0
    musOpt = mus;       % optimal controls 
    
    % not applicable under identity transform
    valueAtRiskOpt_nonneg_stage_cost = nan;
        
    % save complete file
    save(transform_file, '-v7.3');
    
end