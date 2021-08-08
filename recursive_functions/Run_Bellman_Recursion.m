%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Runs Bellman recursion for a particular scenario under a given configuration. 
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
    %       /staging/{configurationID}/{scenarioID}/Transform_complete.mat : 
    %       a file containing tranformed results for all recursion steps
    %       the transform is defined by the transform_function specified
    %       by the scenario
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = Run_Bellman_Recursion(scenarioID, configurationID)

    % declare globals
    global ambient;
    global scenario;
    global config;

    % check staging area for scenarioID, configurationID
    staging_area = get_staging_directory(scenarioID, configurationID); 
    checkpoint_file = strcat(staging_area,'Bellman_checkpoint.mat');
    complete_file = strcat(staging_area,'Bellman_complete.mat');
    
    % if Bellman complete file is available, inform user and return, 
    % otherwise see if there is a checkpoint
    if isfile(complete_file) 
       
        disp('Bellman recurison is already complete for this scenario and configuration.'); 
        
        Run_Transform_Step(scenarioID, configurationID); 
        
        return; 
        
    % if checkpoint file is available, load it, otherwise start fresh
    elseif isfile(checkpoint_file)
        
        load(checkpoint_file); 
        
    else
        
        % Initialize variables used in value iteration
        [Js, mus, Zs, N, kNext] = setup_reachability(scenarioID, configurationID);   
        
    end
    
    k = kNext; 

    while k > 0 
        
        % track kNext for checkpointing
        kNext = k-1; 
        
        % record stage start
        write_log_start_stage(staging_area, k); 
        
        % run stage
        [ Zs(:,:,:,k), Js(:,:,k) , mus(:,:,k) ] = perform_Bellman_backup_step(Js(:,:,k+1)); 
        
        % save checkpoint
        save(checkpoint_file, '-v7.3'); 
        
        % record stage complete
        write_log_end_stage(staging_area, k); 
        
        % update time
        k = kNext; 
        
    end 

    % save complete file
    save(complete_file, '-v7.3');
    
    % cleanup
    if isfile(complete_file) && isfile(checkpoint_file)
        delete(checkpoint_file); 
    end
    
    Run_Transform_Step(scenarioID, configurationID); 

end