%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Gets a griddedInterpolant for the mus
% INPUT:
    % mus: optimal policies
    % globals: 
    %   config struct 
    %   ambient struct 
    %   global struct 
% OUTPUT:
    % griddedInterpolant of the mus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function F = get_mu_interpolants(musOpt)

    global config; 
    global ambient; 
    global scenario; 
    
    N = config.T/config.dt;

    F = cell(N, 1); 

    number_of_risk_aversion_levels = length(ambient.risk_aversion_to_optimal_control_mapping); 
    mu_grid_k_row_indices = 1:number_of_risk_aversion_levels;
    
    % put in row format and ascending order
    ls = ambient.risk_aversion_to_optimal_control_mapping;
    if iscolumn(ls)
        ls = ls';
    end
    
    % in the case where risk_aversion_to_optimal_control_mapping
    % is sorted, then mu_k(:,j_max) corresponds to max(ls)
    % e.g. mu_k(:,11) is ls(11) = 0.999, 
    % which is the desired result
    
    % if not sorted, need to make ascending for interpolant
    % we also need to index into mu_grid_k in reverse because
    % mu_k(:,j_max) corresponds to min(ls)
    % e.g. mu_k(:,11) would to ls(1) = 0.001
    % but mu_k(:,1) should be ls(1) = 0.001
    % and mu_k(:,11) should be ls(11) = 0.999
    if ~issorted(ls)
       ls = fliplr(ls);
       mu_grid_k_row_indices = fliplr(mu_grid_k_row_indices);
    end
    %musOpt = nan(number_of_real_states, length(ambient.risk_aversion_to_optimal_control_mapping), config.N);
    if scenario.dim == 1
        
        for i = 1:N
            
            mu_k = musOpt(:,:,i); 
            mu_grid_k = ones(number_of_risk_aversion_levels, ambient.x1n); 
            
            for j = 1:number_of_risk_aversion_levels
                mu_grid_k(mu_grid_k_row_indices(j),:) = (mu_k(:,j))';
                % 9th row of mu_grid_k corresponds to ls(1) = 0.999
                % 1st col of mu_grid_k corresponds to xs(1)
            end
            
            [L, X1] = ndgrid(ls, ambient.x1s); 
                            % [0.001 ... 0.999]  [20.5 ... 23.5]
            F{i} = griddedInterpolant(L, X1, mu_grid_k, 'linear');
            % F{i}[value_of_ls, value_of_x1] = value_of_control
            % ls increase down the rows, xs increase across cols left-to-right
            %   in L, X1, mu_grid_k
        end
        
    else 
        
        for i = 1:N
            mu_k = musOpt(:,:,i); 

            mu_grid_k = ones(number_of_risk_aversion_levels, ambient.x2n, ambient.x1n); 

                for j = 1:number_of_risk_aversion_levels

                    mu_grid_k(mu_grid_k_row_indices(j),:,:) = reshape(mu_k(:,j), [ambient.x2n, ambient.x1n]); 

                end

            [L, X2, X1] = ndgrid(ls, ambient.x2s, ambient.x1s);

            % to not allow extrapolation, need 'none'
            % unfortunately we need extrapolation to estimate ls = 0 or 1
            %  F{i} = griddedInterpolant(L, X2, X1, mu_grid_k, 'linear', 'none');
            F{i} = griddedInterpolant(L, X2, X1, mu_grid_k, 'linear');

        end
            
    end 

end