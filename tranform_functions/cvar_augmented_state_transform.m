%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Adapts recursion results into the format required for 
%   downstream analysis. Performs a transform that identifies the 
%   optimal value at risk for each confidence level. 
% INPUT:
    % bellman_file = a path to a file containing Bellman recursion results 
% OUTPUT: 
    % transform_file = a path for the output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = cvar_augmented_state_transform(bellman_file, transform_file)

    % declare globals so they are saved with results 
    global ambient;
    global scenario;
    global config;

    % if bellman file is available, load it
    load(bellman_file);
        
    % defensive; recalculate ambient
    calculate_ambient_variables();
    
    if size(ambient.xcoord,2) == 3 % dim of real states = 2, dim of aug state = 1
        number_of_real_states = ambient.x1n * ambient.x2n; 
        number_of_aug_states = ambient.x3n;
        values_of_aug_states = ambient.x3s;    
    elseif size(ambient.xcoord,2) == 2 % dim of real states = 1, dim of aug state = 1
        number_of_real_states = ambient.x1n;
        number_of_aug_states = ambient.x2n;
        values_of_aug_states = ambient.x2s;
    else
        error('only 1 and 2 dimensional systems supported'); 
    end

    
    valueAtRiskOpt_nonneg_stage_cost = nan(number_of_real_states, ambient.nl);
    
    JsOpt = nan(number_of_real_states, ambient.nl, config.N); 
    J0Opt = nan(number_of_real_states, ambient.nl);
    
    musOpt = nan(number_of_real_states, ...
        length(ambient.risk_aversion_to_optimal_control_mapping),...
        config.N);
    
    for timestep = config.N:-1:1
    
        Jk = Js(:,:,timestep); % time k
        % for AWRS equivalent to Js(:,:,1)
        % recall Js = zeros(ambient.nx, 1, N+1) is initialized in
        % set_up_reachability if AUG_STATE == 1, so I think Js(:,1,1) = Js(:,:,1) for any
        % scenario beginning with 'A' (augmented state, cvar of sum cost)
        
        for real_state = 1 : number_of_real_states
               
           % note: indices relative to full augmented Js vector
           % the length of indices_of_this_real_state_in_augmented_space should be equal to number_of_aug_states 
           indices_of_this_real_state_in_augmented_space = (real_state-1)*number_of_aug_states + 1 : real_state * number_of_aug_states;
           
           % extract optimal controls 
           musOpt(real_state, :, timestep) = mus(indices_of_this_real_state_in_augmented_space, :, timestep); 

           % see check below, this should always be equal to the values of augmented states (ambient.x3s if dim of real states is 2)
           augmented_states = ambient.xcoord( indices_of_this_real_state_in_augmented_space, end );

           % subset of augmented_states where the elements are non_negative
           % if dim of real states is 2, then the size of this vector should be approximately
           % ceil(ambient.x3n/2) [-B_bar to B_bar, inclusive of zero]
           non_negative_augmented_states = augmented_states(augmented_states >= 0);

           % note: indices relative to full augmented Js vector, subset to where corresponding s values are non-negative
           % this should have same legnth as non_negative_augmented_states 
           indices_of_non_negative_augmented_states_for_this_real_state = indices_of_this_real_state_in_augmented_space(augmented_states >= 0);              

           % only grab Js associated for this particular state and the
           % non-negative values of s
           Js_of_non_negative_augmented_states_at_this_real_state = Jk(indices_of_non_negative_augmented_states_for_this_real_state); 

           for confidence_level_index = 1 : length(config.ls)

               alpha = config.ls(confidence_level_index); 

               hs = non_negative_augmented_states + 1/alpha * Js_of_non_negative_augmented_states_at_this_real_state;

               % note: optimal_index_within_non_negative_augmented_states is an index relative to the vector non_negative_augmented_states, not full augmented Js vector 
               [CVaR_alpha_real_state_nonneg_stage_cost, optimal_index_within_non_negative_augmented_states] = min(hs);

               % this is optimal S0 for this real state and alpha
               valueAtRiskOpt_nonneg_stage_cost(real_state, confidence_level_index) = non_negative_augmented_states(optimal_index_within_non_negative_augmented_states);

               % optimal CVaR at for this real state and alpha, sum of original stage costs (which may be negative)
               % CVaR( sum original_stage_cost ) = CVaR( sum non-negative_stage_cost ) + (N+1) * lower_bound_of_original_stage_cost
               JsOpt(real_state, confidence_level_index, timestep) = CVaR_alpha_real_state_nonneg_stage_cost + (config.N + 1) * ambient.min_gx; 

           end

           % checks
           expect_non_negative_s = ambient.xcoord(indices_of_non_negative_augmented_states_for_this_real_state, end);
           if min(expect_non_negative_s) < 0
              error('found negative s when expected non-negative'); 
           end

           if ~isequal( ambient.xcoord((real_state-1)*number_of_aug_states + 1, 1:end-1), ambient.xcoord((real_state-1)*number_of_aug_states + 2, 1:end-1) )
              error('unexpected xcoord dimensions');
           end

           if ~isequal( augmented_states, values_of_aug_states' )
              error('unexpected augmented state dimensions');
           end
        end
    end
    
    J0Opt(:,:) = JsOpt(:,:,1); 
        
    % save complete file
    save(transform_file, '-v7.3');
    
end

    % structure of ambient.xcoord when dim of real states is 2
    %------------------------------------------
    % x1     x2       x3 (s)     entry of myJ0
    % 1       1       1          1
    % 1       1       2          2
    % 1       1.5     1          3
    % 1       1.5     2          4
    % 3       1       1          5
    % 3       1       2          6
    % 3       1.5     1          7
    % 3       1.5     2          8
    % for each (x1,x2), we need to look at the corresponding possible values of s
    
    %bestVaRs(real_state, confidence_level) = augmented_states(augmented_state_index); % Estimate of Value_at_Risk_myAlpha( \bar{Z} )
    % bestCVaRs(j,y) = inf CVaR_{myAlpha,x}( \bar{Z} )
    % myAlpha = config.ls(j)
    % x = [x1,x2] = ambient.xcoord((real_state-1)*ambient.x3n + 1, 1:2)