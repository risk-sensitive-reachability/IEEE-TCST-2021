%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Gets a griddedInterpolant for the Zs
% NOTE: This is a deprecated hold-over from LP-based CVaR method.
%   It will be removed in a later refactor. 
% INPUT:
    % Zs: transition of the confidence level under optimal policy
    % globals: 
    %   config struct 
    %   ambient struct 
    %   global struct 
% OUTPUT:
    % griddedInterpolant of the Zs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function F = get_z_interpolants(Zs)

    global config; 
    global ambient; 
    global scenario; 

    N = config.T/config.dt;

    F = cell(N, 1); 
    
    if startsWith(scenario.id, 'A') || startsWith(scenario.id, 'E') || startsWith(scenario.id, 'Q')
        
        if scenario.dim == 2
            
            for i = 1 : N
                F{i} = griddedInterpolant(ones(2,2,2,2), 'linear'); 
            end
            
        elseif scenario.dim == 1
            
            for i = 1 : N
                 F{i} = griddedInterpolant(ones(2,2,2), 'linear'); 
            end
            
        else
            error('no other scenario dim written');
        end
        
    else
    
    if scenario.dim == 1
        
        for i = 1:N
            Zs_k = Zs(i);
            Z_grid_k = ones(scenario.nw, ambient.nl, ambient.x1n); 
            for j = 1:ambient.nl
                reverse = fliplr(1:ambient.nl);
                % extracts column of Zs_k corresponding to a confidence level j
                Zs_k_l = full([Zs_k{1}{:,j}]);
                for q = 1:scenario.nw
                % get the qth disturbance element across all x values at confidence level ls(j) at time i
                    Z_grid_k(q, reverse(j), :) = Zs_k_l(q,:);
                end 
            end
            % map negative Zs (rounding error) to zero; you can run this to check this is true, max(Z_grid_k(Z_grid_k < 0))
            Z_grid_k(Z_grid_k < 0) = 0; 
            [W, L, X1] = ndgrid(scenario.ws, fliplr(config.ls'), ambient.x1s);   
            F{i} = griddedInterpolant(W, L, X1, Z_grid_k, 'linear');
        end
        
    elseif(scenario.dim == 2)
    
        for i = 1:N

            Zs_k = Zs(i);
            Z_grid_k = ones(scenario.nw, ambient.nl, ambient.x2n, ambient.x1n); 
          
                for j = 1:ambient.nl

                    reverse = fliplr(1:ambient.nl);

                    % extracts column of Zs_k corresponding to a confidence
                    % level j
                    Zs_k_l = full([Zs_k{1}{:,j}]);

                    for q = 1:scenario.nw

                        % get the qth disturbance element across all x values
                        % at confidence level ls(j) at time i
                        Z_grid_k(q, reverse(j), :, :) = reshape(Zs_k_l(q,:), [ambient.x2n, ambient.x1n]); %                

                    end 

                end

          % map negative Zs (rounding error) to zero
          % you can run this to check this is true
          %max(Z_grid_k(Z_grid_k < 0))
          Z_grid_k(Z_grid_k < 0) = 0; 

          [W, L, X2, X1] = ndgrid(scenario.ws, fliplr(config.ls'), ambient.x2s, ambient.x1s); 

          % to not allow extrapolation, need 'none'
          % unfortunately we need extrapolation to estimate ls = 0 or 1
          % F{i} = griddedInterpolant(W, L, X2, X1, Z_grid_k, 'linear', 'none');
          F{i} = griddedInterpolant(W, L, X2, X1, Z_grid_k, 'linear');
       
        end
        
    else
        
        error('only 1 and 2 dimensional systems supported')

    end

    end
end