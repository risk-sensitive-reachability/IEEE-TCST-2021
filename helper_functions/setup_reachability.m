%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Initializes variables prior to running Bellman recursion
% INPUTs:
%  scenarioID: the string id of the scenario to use
%  configurationID: the numeric id of the configuration to use
%  globals: 
%   ambient struct 
%   scenario struct 
%   config struct 
% OUTPUTS: 
%   Js: a cell array for storing the values associated with optimal control policies
%   mus: a cell array for storing optimal control policies
%   Zs: a cell array for storing the confidence level transitions associated with the optimal contorl policies
%   N: the number of discrete time points in the simulation
%   kNext : the initial value of the backwards recursion time index
%           (tracked so that the hotstart process to infer where the
%           recursion left off)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[Js, mus, Zs, N, kNext] = setup_reachability(scenarioID, configurationID)

    global ambient; 
    global scenario;
    global config;
    
    % load scenario and configuration
    scenario = get_scenario(scenarioID); 
    config = get_config(configurationID); 
    calculate_ambient_variables(); 

    disp(strcat(['Running scenario: (', scenarioID, ') ', scenario.title, ' under simulator configuration (',num2str(configurationID) ,').']))

    N = config.T/config.dt;         % Time horizon: {0, 1, 2, ..., N} = {0, 5min, 10min, ..., 240min} = {0, 300sec, 600sec, ..., 14400sec}

    if scenario.AUG_STATE == 1
        
        Js = zeros(ambient.nx, 1, N+1);    % Contains optimal value functions to be solved via dynamic programming
                                           % Js{1} is J0, Js{2} is J1, ..., Js{N+1} is JN  
        Zs = ones(1,1,1,N);            
        
        mus = zeros(ambient.nx, 1, N); 
                                           
    else
        
        Js = zeros(ambient.nx, ambient.nl, N+1);
        
        Zs = ones(ambient.nx, ambient.nl, scenario.nw, N);  % Optimal Z
        
        mus = zeros(ambient.nx, ambient.nl, N); 
        
    end
                                  
    ambient.c = initialize_stage_cost_matrix();
    
    Js(:,:,N+1) = ambient.c; 
    
    kNext = N; 
    
end