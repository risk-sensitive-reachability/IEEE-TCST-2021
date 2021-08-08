%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Performs the exponential disutility Bellman backwards 
%    recursion, uk \in {0,1}
% INPUT: 
    % J_k+1 : optimal cost-to-go at time k+1, array
    % globals: 
    %   ambient struct
    %   config struct 
    %   scenario struct
% OUTPUT: 
    % J_k : optimal cost-to-go starting at time k, array
    % mu_k : optimal controller at time k, array
    % Zs_k : confidence level transitions under optimal policies 
    %   (not applicable to exponential disutility)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Zs_k, J_k, mu_k ] = exponential_disutility_Bellman_backup(J_kPLUS1)

    global ambient; 
    global config; 
    global scenario;
    
    amb = ambient; 
    cfg = config; 
    scn = scenario; 
    
    %thetas = -(1-config.ls)
   
    % thetas(1): least risk-averse (negative number close to 0)
    % ...
    % thetas(end): most risk-averse (most negative)
    % config.ls(1) = alpha : least risk-averse for cvar (close to 1)
    % ...
    % config.ls(end) = alpha : most risk-averse for cvar (positive number close to 0)
    
    % Comparison table if most_risk_averse_theta is -1000
    % This table is misleading since there isn't a quantitative comparison
    % between thetas for exponential utility and alphas for cvar.
    % thetas     |   config.ls = alphas    | description
    % -1         |    0.999                | nearly risk-neutral
    % -250       |    0.75                 | 25% risk-averse
    % -500       |    0.5                  | 50% risk-averse
    % -650       |    0.35                 | 65% risk-averse
    % -800       |    0.2                  | 80% risk-averse
    % -900       |    0.1                  | 90% risk-averse
    % -950       |    0.05                 | 95% risk-averse
    % -975       |    0.025                | 97.5% risk-averse
    % -990       |    0.01                 | 99% risk-averse
    % -995       |    0.005                | 99.5% risk-averse
    % -999       |    0.001                | 99.9% risk-averse
    
    % not clear what the most negative theta should be, we chose -100 here
    %most_risk_averse_theta = -100;
    
    %thetas = (1-config.ls) * most_risk_averse_theta;
    thetas = config.thetas;
    
    J_k = J_kPLUS1;     % initialize matrix with given size, values irrelevant
    mu_k = J_kPLUS1;    % initialize matrix with given size, values irrelevant
    
    Zs_k = ones(1, 1, 1); % pre-populate dummy variable
    
    for thetaIndex = 1:length(thetas)
    
        theta = thetas(thetaIndex); 
        
        if scenario.dim == 1
                J_kPLUS1_grid_for_theta = J_kPLUS1(:,thetaIndex); 
                F = griddedInterpolant(ambient.x1g, J_kPLUS1_grid_for_theta, 'linear'); 
        else 
            % in J_kPLUS1_grid each column represents a fixed value of x1
            % and the values of x2 change along the entries of this column (rows)
            J_kPLUS1_grid_for_theta = reshape(J_kPLUS1(:,thetaIndex), [ambient.x2n, ambient.x1n]); 

            % F([x2,x1]) finds the linear interpolated value of J_kPLUS1 at
            % state x1, x2, and theta = thetas(thetaIndex)
            F = griddedInterpolant(ambient.x2g, ambient.x1g, J_kPLUS1_grid_for_theta, 'linear'); 

        end

        J_k_theta = J_kPLUS1(:, thetaIndex);   % initialize matrix with given size, values irrelevant
        mu_k_theta = J_kPLUS1(:, thetaIndex);  % initialize matrix with given size, values irrelevant
        
        ones(scenario.nw, 1);     % column of ones / dummy variable

        stage_cost = ambient.c(:,1); % all cols of ambient.c are the same
        
        if ~isequal(ambient.c(:,1),ambient.c(:,2))
            error('issue with ambient.c, need to check calculate_ambient_variables');
        end
        us = scenario.allowable_controls;

        parfor z = 1 : amb.nx

            J_k_all_us = zeros(length(us),1);

            for m = 1 : length(us)

                u = us(m); 
                inside_expected_value_k_wk = zeros(scn.nw,1); 

                for i = 1 : scn.nw

                    % get next state realization
                    x_kPLUS1 = scn.dynamics(amb.xcoord(z,:), u, scn.ws(:,i), cfg, scn, amb);                

                    x_kPLUS1 = snap_to_boundary( x_kPLUS1, amb );
                    J_kPLUS1_theta = F(fliplr(x_kPLUS1)); 

                    inside_expected_value_k_wk(i) = exp((-theta/2)*(J_kPLUS1_theta));  

                end

                our_expected_value = sum(inside_expected_value_k_wk .* scn.P); 

                J_k_all_us(m) = stage_cost(z) + (-2/theta) * log(our_expected_value);

            end

            [optVal, optIdx] = min(J_k_all_us); 
            J_k_theta(z) = optVal; 
            mu_k_theta(z) = us(optIdx); 

        end
        
        J_k(:,thetaIndex) = J_k_theta;
        mu_k(:,thetaIndex) = mu_k_theta;
        
    end
    
end
