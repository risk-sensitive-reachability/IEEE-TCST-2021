%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Performs Bellman backup to minimize E_x^\pi( sum( Y - s, 0 )), 
% where s = config.svar
% INPUT: 
    % J_k+1 : optimal cost-to-go at time k+1, array
    % globals: 
    %   ambient struct
    %   config struct 
    %   scenario struct
% OUTPUT: 
    % Zs_k : confidence level transitions, dummy variable
    % J_k : optimal cost-to-go starting at time k, array
    % mu_k : optimal controller at time k, array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Zs_k, J_k, mu_k ] = State_aug_for_cvar_sum_backup(J_kPLUS1)

    global ambient; global config; global scenario;
    
    amb = ambient; cfg = config; scn = scenario; 
    
    stage_cost_shifted = shift_stage_cost_vector_AUGSTATE(scenario, config, ambient);
    % jth value of real state [x1 x2 ... x_n] is ambient.xcoord(j,1:end-1)
    % stage_cost_shifted(j) = scenario.cost_function(ambient.xcoord(j,1:end-1), scenario, config, ambient) - ambient.min_gx;
    
    if startsWith(scenario.id,'A') && size(ambient.xcoord,2) == 3 % dim of real states = 2, dim of aug state = 1
    
        J_kPLUS1_grid = zeros(ambient.x2n, ambient.x1n, ambient.x3n);
        % In J_kPLUS1_grid(:,:,k) each column represents a fixed value of x1
        % and the values of x2 change along the entries of this column (rows)
        % ambient.x3s(k) is the associated value of x3
        
        % test to show columns are fixed x1
        % reshape(ambient.xcoord(k:ambient.x3n:length(J_kPLUS1),1),[ambient.x2n, ambient.x1n])
        
        % test to show rows correspond to fixed x2
        % reshape(ambient.xcoord(k:ambient.x3n:length(J_kPLUS1),1),[ambient.x2n, ambient.x1n])
    
        for aug_state = 1 : ambient.x3n
        % select entries of J_kPLUS1 corresponding to kth value of x3
        
            if ~isequal( ambient.xcoord( aug_state:ambient.x3n:end, 3 ), ambient.x3s(aug_state)*ones(ambient.x2n*ambient.x1n,1) )
                error('issue with x3index'); 
            end
        
            J_kPLUS1_grid(:,:,aug_state) = reshape( J_kPLUS1(aug_state:ambient.x3n:end), [ambient.x2n, ambient.x1n] );
            
        end
        
        % F([x2, x1, x3]) finds the linear interpolated value of J_kPLUS1 at state x1, x2, x3
        % ambients are computed in calculate_ambient_variables.
        F = griddedInterpolant(ambient.x2g, ambient.x1g, ambient.x3g, J_kPLUS1_grid, 'linear'); 
        
    elseif startsWith(scenario.id,'A') && size(ambient.xcoord,2) == 2 % dim of real states = 1, dim of aug state = 1
        
        J_kPLUS1_grid = reshape(J_kPLUS1, [ambient.x2n, ambient.x1n]);
        % col 1 of J_kPLUS1_grid corresponds to min value of x1
        % last col of J_kPLUS1_grid corresponds to max value of x1
        % row 1 of J_kPLUS1_grid corresponds to min value of x2
        % last row of J_kPLUS1_grid corresponds to max value of x2
        % reshape takes the first ambient.x2n entries of J_kPLUS1 (corresonds to min val of x1, all val of x2) and puts
        % them in col 1 of J_kPLUS1_grid; 
        % reshape takes the 2nd set of ambient.x2n entries of J_kPLUS1 (corresonds to 2nd smallest val of x1, all val of x2) and puts
        % them in col 2 of J_kPLUS1_grid, etc.
        % F([x2,x1]) finds the linear interpolated value of J_kPLUS1 at state x1 (real state), x2 (extra state)
        F = griddedInterpolant(ambient.x2g, ambient.x1g, J_kPLUS1_grid, 'linear');     
    
    else 
        error('only written for scenario starting with A and dim of real states = 1 or = 2');
    end
    
    J_k = J_kPLUS1; 
    mu_k = J_kPLUS1;
   
    Zs_k = ones(1, 1, 1);
    
    us = scenario.allowable_controls;
            
    parfor z = 1 : amb.nx
        
        J_k_all_us = zeros(length(us),1);
        
        for m = 1 : length(us)
            
            u = us(m); 
            inside_expected_value_k_wk = zeros(scn.nw,1); 
            
            for i = 1 : scn.nw
        
                % get next state realization
                x_kPLUS1 = scn.dynamics(amb.xcoord(z,1:end-1), u, scn.ws(:,i), cfg, scn, amb);     %last col of amb.xcoord is extra state            
                
                x_kPLUS1 = snap_to_boundary( x_kPLUS1, amb ); % computed using only x1 and x2 (no info about the extra state x3)
                
                extra_kPLUS1 = amb.xcoord(z,end) - stage_cost_shifted(z); % dynamics of extra state
                
                %it's possible for extra_kPLUS1 to be outside of [-B, B]
                %because if s_t = -B, then s_{t+1} = -B - positive number
                %is possible. So, we choose to clip the value of s_{t+1} so
                %that it stays in [-B,B] to keep state space of reasonable
                %size
            
                extra_kPLUS1 = snap_to_boundary_extra_state( extra_kPLUS1, amb );
                
                
                
                
                if startsWith(scn.id,'A') && size(amb.xcoord,2) == 3 % dim of real states = 2, dim of aug state = 1
                    % F([x2, x1, x3]) finds the linear interpolated value of J_kPLUS1 at state x1, x2, x3; x3 is extra state
                    inside_expected_value_k_wk(i) = F([fliplr(x_kPLUS1), extra_kPLUS1]); %comes from griddedInterpolant
                
                elseif startsWith(scn.id,'A') && size(amb.xcoord,2) == 2 % dim of real states = 1, dim of aug state = 1
                    % F([x2, x1]) finds the linear interpolated value of J_kPLUS1 at state [x1 x2]; x2 is extra state
                    inside_expected_value_k_wk(i) =  F( [extra_kPLUS1, x_kPLUS1] ); 
                    
                else
                    error('scenario not written yet');
                end
                
            end
            
            our_expected_value = sum(inside_expected_value_k_wk .* scn.P); 
           
            J_k_all_us(m) = our_expected_value;
            
        end
        
        [optVal, optIdx] = min(J_k_all_us); 
        J_k(z) = optVal; 
        mu_k(z) = us(optIdx); 
        
    end
end