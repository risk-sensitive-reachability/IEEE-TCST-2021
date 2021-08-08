%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Runs transform to get optimal results after Bellman recursion. 
% INPUT:
    % scenarioID = the string id of the scenario to use    
    % configurationID = the numeric id of the configuration to use
    % [optional "hot start" file)
    %    /staging/{configurationID}/{scenarioID}/checkpoint.mat : 
    %        a file containing any previously completed recursion steps
% OUTPUT: 
    %   [file] (after each recursion step) :
    %       /staging/{configurationID}/{scenarioID}/Bellman_checkpoint.mat - 
    %       a file containing results for any completed recursion steps
    %   [file] (after each recursion step) :
    %       /staging/{configurationID}/{scenarioID}/times.txt - 
    %       a file containing the bellman 
    %   [file] (after all recursion steps)
    %       /staging/{configurationID}/{scenarioID}/Bellman_complete.mat : a
    %       file containing results for all recursion steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = Run_Transform_Step(scenarioID, configurationID)

    % declare globals so they are saved with results 
    global ambient;
    global scenario;
    global config;

    % check staging area for scenarioID, configurationID
    staging_area = get_staging_directory(scenarioID, configurationID); 
    bellman_file = strcat(staging_area,'Bellman_complete.mat');
    transform_file = strcat(staging_area,'Transform_complete.mat');
    
    % if bellman complete file is available, inform user and return, 
    % otherwise see if there is a checkpoint
    if ~isfile(bellman_file) 
       
        error('No results available for this scenario and configuration. Please Run_Bellman_Recursion first.');
        
    
    elseif isfile(transform_file)
        
        disp('Transform is already complete for this scenario and configuration.');
        return
        
    end
    
    scenario = get_scenario(scenarioID); 
    
    scenario.transform_function(bellman_file,transform_file); 
  
    
    % if data file is available, load it, otherwise prompt to Run_Bellman_Recursion and Run_Transform_Step.
    if isfile(transform_file)
       load(transform_file); 
    else
       error('No results available for this scenario and configuration. Please Run_Transform_Step first.');
    end
    
    if isinf(max(max(J0Opt))) % best value function at time 0
        error('Risk-sensivitity parameters need to be made less extreme since there is a value of JsOpt that is infinity.'); 
    end

end

