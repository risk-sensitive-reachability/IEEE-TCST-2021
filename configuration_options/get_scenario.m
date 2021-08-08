%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE:
%   Create a structure containing scenario-specifc details
% INPUT:
%   scenarioID = the string id of the scenario to use
% OUTPUT:
%   scenario = a structure containing scenario-specific details
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\

function scenario = get_scenario(scenarioID)

    % initialize base scenario from last three letters of scenario ID
    baseScenario = cell2mat(extractBetween(scenarioID, 2, 4));

    % scenario naming convention:
    %   first letter indicates the recursion type
    %       A => Augmented State CVaR Recursion
    %       E => Exponential Utilty Recursion
    %       Q => LEQR Recursion
    %   second letter indicates the system type
    %       T => Thermostatic Regulator (real costs)
    %       P => Thermostatic Regulator (non-negative costs)
    %       W => Stormwater System
    %   third letter and fourth letter indicate probability distribution
    %       RS => 'right skew'
    %       GS => Gaussian (for LEQG)
    %
    %   for the water system only
    %       if the scenario ends in 5, then 5 control states are used
    %       otherwise, then 3 control states are used
    number_of_controls = 3;
    scenarioLength = length(scenarioID);
    if scenarioLength > 4
        number_of_controls = str2double(cell2mat(extractBetween(scenarioID, 5, scenarioLength)));
    end

    switch baseScenario

        %   thermostatic regulator example,
        case { ...
                'PRS', ...  %   right skew - non-negative costs
                'TRS', ...  %   right skew - real valued costs
                'TLS', ...  %   left skew - real valued costs
                'TNS', ...  %   no skew - real valued costs
                'TGS', ...  %   Gaussian (for LEQG)
                }
            scenario = fill_scenario_fields_thermsys(baseScenario);

            %   two tank stormwater example
            %   linear pump system for CSO mitigation
            %   right skew
        case 'WRS'
            scenario = fill_scenario_fields_watersys(baseScenario, number_of_controls);

        otherwise
            error('no matching scenario found');
    end

    % setup common properties
    scenario.title = ['Scenario ', scenarioID];

    scenario.AUG_STATE = 0;
    if startsWith(scenarioID, 'E')
        scenario.risk_functional = 'EXP';
        scenario.bellman_backup_method = str2func('exponential_disutility_Bellman_backup');
        if startsWith(scenarioID, 'EP') % P implies temperature system with non-negative costs (see above)
            scenario.transform_function = str2func('non_negative_cost_transform_for_temp_system');
        else
            scenario.transform_function = str2func('identity_transform');
        end
    elseif startsWith(scenarioID, 'A')
        scenario.risk_functional = 'CVAR';
        scenario.AUG_STATE = 1;
        scenario.bellman_backup_method = str2func('State_aug_for_cvar_sum_backup');
        scenario.transform_function = str2func('cvar_augmented_state_transform');
    elseif startsWith(scenarioID, 'Q')
        scenario.risk_functional = 'EXP';
        scenario.bellman_backup_method = str2func('riccati_recursion_for_legq');
        scenario.transform_function = str2func('identity_transform');
    else
        error('no matching scenario found');
    end
    scenario.cost_function_aggregation = str2func('sum');
    scenario.id = scenarioID;

end



