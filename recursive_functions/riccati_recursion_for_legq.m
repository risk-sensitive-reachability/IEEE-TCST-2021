
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Performs the Riccati recursion for 
%   linear exponential-of-quadratic Gaussian  (LEQR) optimal control.  
%   
%   implements, Theorem 3 of 
%       P. Whittle, “Risk-sensitive linear/quadratic/Gaussian control,” 
%       Advances in Applied Probability, vol. 13, no. 4, pp. 764–777, 1981.
%
% INPUT: 
    % globals: 
    %   config struct 
    %   scenario struct
% OUTPUT: 
    % Riccati_Control_Gains (time_index, theta_index) : control gain for 
    %   time time_index-1 and theta = config.thetas(theta_index), i.e.,
    %   optimal control is
    %       Riccati_Control_Gains(time_index, theta_index) * current state
    %
    % Riccati_Matrices (time_index, theta_index) : 
    %   (Pi_t) for time time_index-1 and theta = config.thetas(theta_index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Riccati_Control_Gains, Riccati_Matrices] = riccati_recursion_for_legq()

    global config;
    global scenario;

    if ~isequal(scenario.dim, 1)
        error('riccati_recursion for leqg only written for real dim = 1 now');
    end

    [R, Q, RN] = get_quadratic_mat_temp();
    % R = state stage cost matrix
    % Q = control stage cost matrix
    % RN = terminal cost matrix

    [A, B] = get_state_space_temp(config);

    wk_var = scenario.variance;

    N_thetas = length(config.thetas);

    Riccati_Control_Gains = nan(config.N, N_thetas);

    Riccati_Matrices = nan(config.N+1, N_thetas);

    for theta_index = 1 : N_thetas

        theta = config.thetas(theta_index);

        Riccati_Matrices(config.N+1, theta_index) = RN;
        % time_index = N+1 corresponds to time N

        P_tplus1 = RN; %initialization to backwards recursion

        for time_index = config.N : -1 : 1
            % time_index = N corresponds to time N-1
            % time_index = 1 corresponds to time 0

            if P_tplus1 < -1/(theta * wk_var)

                inner_matrix = B*1/Q*B' + theta*wk_var + 1/P_tplus1;

                inv_inner_matrix = 1/inner_matrix;

                P_t = R + A' * inv_inner_matrix * A;

                K_t = -1/Q * B' * inv_inner_matrix * A;

                Riccati_Control_Gains(time_index, theta_index) = K_t;

                Riccati_Matrices(time_index, theta_index) = P_t;

                P_tplus1 = P_t;

            else

                error(['theta is too negative. Failed at time index = ',...
                    num2str(time_index), 'theta = ', num2str(theta)]);

            end
            
        end
        
    end
    
end