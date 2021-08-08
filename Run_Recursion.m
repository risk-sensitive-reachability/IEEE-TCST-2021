%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Runs recursion for a particular scenario under a given configuration. 
% INPUT:
    % scenarioID = the string id of the scenario to use    
    % configurationID = the numeric id of the configuration to use
    % [optional "hot start" file)
    %    /staging/{configurationID}/{scenarioID}/checkpoint.mat : 
    %        a file containing any previously completed recursion steps
% OUTPUT: 
    %   [file] (after all recursion steps) 
    %       /staging/{configurationID}/{scenarioID}/Transform_complete.mat : 
    %       a file containing tranformed results for all recursion steps
    %       the transform is defined by the transform_function specified
    %       by the scenario
    %   For Bellman recursion only: 
    %       [file] (after each recursion step) :
    %           /staging/{configurationID}/{scenarioID}/Bellman_checkpoint.mat - 
    %           a file containing results for any completed recursion steps
    %       [file] (after each recursion step) :
    %           /staging/{configurationID}/{scenarioID}/times.txt - 
    %           a file containing the bellman 
    %       [file] (after all recursion steps) 
    %           /staging/{configurationID}/{scenarioID}/Bellman_complete.mat : 
    %           a file containing results for all recursion steps
    %           prior to running any transforms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = Run_Recursion(scenarioID, configurationID)

    if startsWith(scenarioID, 'Q')
       Run_Riccati_Recursion(scenarioID, configurationID); 
    else
       Run_Bellman_Recursion(scenarioID, configurationID); 
    end

end

