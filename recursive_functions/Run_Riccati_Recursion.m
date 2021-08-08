%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Runs Riccati recursion for a particular scenario under a given configuration. 
% INPUT:
    % scenarioID = the string id of the scenario to use    
    % configurationID = the numeric id of the configuration to use
% OUTPUT: 
    %   [file] (after all recursion steps)
    %       /staging/{configurationID}/{scenarioID}/Transform_complete.mat : 
    %       a file containing tranformed results for all recursion steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = Run_Riccati_Recursion(scenarioID, configID)

    % check staging area for scenarioID, configurationID
    staging_area = get_staging_directory(scenarioID, configID); 
    complete_file = strcat(staging_area,'Transform_complete.mat');
    
    % if bellman complete file is available, inform user and return, 
    % otherwise 
    if isfile(complete_file) 
        disp('Riccati recurison is already complete for this scenario and configuration.'); 
        return; 
    end

    % declare globals
    global ambient; 
    global scenario;
    global config;
    
    scenario = get_scenario(scenarioID);
    config = get_config(configID);
    calculate_ambient_variables;

    %Riccati_Control_Gains(time_index, theta_index) is the 
    %   control gain for time time_index-1 and theta = config.thetas(theta_index)
    [Riccati_Control_Gains, Riccati_Matrices] = riccati_recursion_for_legq();

    % this name is used in generate_histograms, but is a different structure
    % compared to musOpt from the scenarios that require a grid
    musOpt = Riccati_Control_Gains; 

    % not applicable to Riccati recursion
    valueAtRiskOpt_nonneg_stage_cost = nan;
    Zs = nan;

    % save complete file
    save(complete_file, '-v7.3');

end


   