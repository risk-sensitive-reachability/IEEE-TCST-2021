%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Samples a single trajectory, tracking real state,
%   confidence level (if dynamic in the given formulation), controls used
%   and costs incurred. 
%
%   Note: If xk+1 > max(xs), we set xk+1 = max(xs). 
%   This ensures that scenario tree is equivalent to that used in 
%   dynamic programming.
%
% INPUT:
%   s0 : valueAtRiskOpt_nonneg_stage_cost(x_index, l_index) 
%       (this is a dummy for 'E' and 'C' scenarios, only a real number for 'A' scenarios)
%   x0 : initial state, real number
%   l0 : initial confidence level, (0-1)
%   tick_P : an array of discrete probability bins
%       [ 0, P(1), P(1)+P(2), ..., P(1)+...+P(nw-1), 1 ], nw = length(ws)
%   P(i) : probability that wk = ws(i)
%   muInterpolants : a vector of N cells containing gridded interpolant of
%       the optimal policy for each timestep
%   zInterpolants : a vector of N cells containing gridded interpolant of
%       the risk envelope for each timestep
% globals
%   scenario struct
%   config struct
%   ambient struct
% OUTPUT:
%   myTraj_real : trajectory in the real state space
%       myTraj_real(1) = x0, myTraj_real(2) = x1, ..., myTraj_real(N+1) = xN
%   myConf : confidence level at each step in the trajectory
%       myConf(1) = l0, myConf(2) = l1, ..., myConf(N+1) = lN
%   myCtrl : controls used at each step in the trajectory
%       myCtrl(1) = u1, myCtrl(2) = u2, ..., myCtrl(N) = uN
%   myCost : stage costs at each step in the trajectory
%       myCost(1) = cost(x0); myCost(2) = cost(x2); ..., myCost(N+1) = cost(xN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [myTraj_real, myConf, myCtrl, myCosts] = sample_trajectory_parallel(...
    s0, x0, l0, tick_P, muInterpolants, zInterpolants, scenario, config, ambient, stream)

    N = config.T/config.dt;

    myConf = [ l0; zeros( N, 1 ) ];
    myCtrl = zeros(N, 1);

    if ~startsWith(scenario.id, 'Q') % cost function is different for LEQG scenario
        myCosts = [ scenario.cost_function(x0, scenario, config, ambient) ; zeros(N, 1)];
        if scenario.dim == 1
            myTraj_real = [ x0; zeros(N, 1) ];                % initialize trajectory
        else
            myTraj_real = [ x0; zeros(N, 2) ];
        end

    elseif startsWith(scenario.id, 'Q') %only written for 1 dim now
        % Recall that dynamics are: (xk+1 - b) = A * (xk - b) + B * uk + wk
        % xkprime = xk - b

        x0prime_sample = get_x0_prime_sample(x0, config, scenario, stream);

        myTraj_real = [ x0prime_sample; zeros(N, 1) ];

        u0 = get_opt_control_LEQG(muInterpolants, x0prime_sample, 1, l0, config);

        myCosts = [ get_stage_cost_LEQG(x0prime_sample, u0); zeros(N, 1)];

    end

    if scenario.AUG_STATE == 1
        myTraj_AUG = [ s0; zeros(N, 1) ];
    end

    for k = 0 : N-1                                                 % for each time point

        xk = myTraj_real(k+1,:);                                    % state at time k

        if startsWith(scenario.id, 'Q')
            xkprime = myTraj_real(k+1,:);
        end

        if scenario.AUG_STATE == 1                                  % extra state at time k, only applicable for 'A' scenario
            sk = myTraj_AUG(k+1);
        end

        lk = myConf(k+1);

        if ~startsWith(scenario.id, 'Q')
            wk = sample_disturbance_parallel(scenario.ws, tick_P, stream);  % sample the disturbance at time k according to P
        elseif startsWith(scenario.id, 'Q')
            wk = 0 + sqrt(scenario.variance)*randn(stream,1); %assumes normally distributed with zero-mean, variance = scenario.variance = 0.03
        end

        if ~startsWith(scenario.id, 'Q')
            if scenario.AUG_STATE ~= 1 % exp. utility or approx. cvar method via lp
                if scenario.dim == 1
                    u = muInterpolants{k+1}(lk, xk(1));         % 1D
                elseif scenario.dim == 2
                    u = muInterpolants{k+1}(lk, xk(2), xk(1));  % 2D
                else
                    error('scenario.dim not defined properly');
                end
            elseif scenario.AUG_STATE == 1 % exact cvar method via state aug.
                if scenario.dim == 1
                    u = muInterpolants{k+1}(sk, xk(1));         % 1D
                elseif scenario.dim == 2
                    u = muInterpolants{k+1}(sk, xk(2), xk(1));  % 2D
                else
                    error('scenario.dim not defined properly');
                end
            else
                error('AUG_STATE not defined properly');
            end

            if u > max(scenario.allowable_controls)
                u = max(scenario.allowable_controls);
            end

            if u < min(scenario.allowable_controls)
                u = min(scenario.allowable_controls);
            end
        end

        if startsWith(scenario.id, 'Q')
            u = get_opt_control_LEQG(muInterpolants, xkprime, k+1, l0, config);
            %xkprime is in the units of [original temp. state] - b
        end

        myCtrl(k+1) = u;

        if ~startsWith(scenario.id, 'Q')
            % get next state realization
            x_kPLUS1 = scenario.dynamics(xk, u, wk, config, scenario, ambient);

            x_kPLUS1 = snap_to_boundary( x_kPLUS1, ambient );               % snap to grid on boundary

        elseif startsWith(scenario.id, 'Q')
            [A, B] = get_state_space_temp(config);

            x_kPLUS1prime = A*xkprime + B*u + wk;
            %xprime is in the units of [original temp. state] - b

        end

        if scenario.AUG_STATE == 1  % exact cvar method via aug state
            shifted_stage_cost_k = scenario.cost_function(xk, scenario, config, ambient) - ambient.min_gx; % make stage cost non-negative
            s_kPLUS1 = sk - shifted_stage_cost_k; % dynamics of aug state
            s_kPLUS1 = snap_to_boundary_extra_state( s_kPLUS1, ambient );
        end

        if startsWith(scenario.id,'C') %approx. cvar via LP method
            if scenario.dim == 1
                l_kPLUS1 = zInterpolants{k+1}(wk, lk, xk(1)) * lk;             % 1D
            elseif scenario.dim == 2
                l_kPLUS1 = zInterpolants{k+1}(wk, lk, xk(2), xk(1)) * lk;      % 2D
            else
                error('scenario.dim not defined properly!');
            end
            if l_kPLUS1 > max(config.ls), l_kPLUS1 = max(config.ls); end
            if l_kPLUS1 < min(config.ls), l_kPLUS1 = min(config.ls); end

        elseif startsWith(scenario.id,'A') || startsWith(scenario.id,'E') || startsWith(scenario.id,'Q') % exact cvar via state aug., or exact exp. utility
            l_kPLUS1 = lk;
        end

        if ~startsWith(scenario.id, 'Q')
            myTraj_real(k+2,:) = x_kPLUS1;                                   % state at time k+1
        elseif startsWith(scenario.id, 'Q')
            myTraj_real(k+2,:) = x_kPLUS1prime;
        end

        if scenario.AUG_STATE == 1
            myTraj_AUG(k+2) = s_kPLUS1;
        end

        if ~startsWith(scenario.id, 'Q')
            myCosts(k+2) = scenario.cost_function(x_kPLUS1, scenario, config, ambient);  % real stage cost at time k+1
        elseif startsWith(scenario.id, 'Q')
            if k+2 == N+1 % last time step
                myCosts(k+2) = get_terminal_cost_LEQG(x_kPLUS1prime);
            else
                ukPLUS1 = get_opt_control_LEQG(muInterpolants, x_kPLUS1prime, k+2, l0, config);
                %optimal control at time k+1
                myCosts(k+2) = get_stage_cost_LEQG(x_kPLUS1prime, ukPLUS1);
            end
        end

        myConf(k+2) = l_kPLUS1;                                     % confidence at time k+1

    end

end
