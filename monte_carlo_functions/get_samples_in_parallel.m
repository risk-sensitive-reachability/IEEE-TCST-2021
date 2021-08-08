%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generates many samples of the desired type. Intended
%   to be called from a methods like generate_histograms or 
%   generate_trajectories. The type argument determines the type 
%   of value returned. 
%           
% INPUT:
%   type : a string specifying the type to return: 
%        'state_trajectories' - (numer of trials, number of dimensions, number of timesteps +1)
%        'control_trajectories' - (numer of trials, number of timesteps)
%        'stage_cost_trajectories' - (number of trials, number of timesteps + 1)
%        'cumulative_costs' - (number of trials)
%
%   valueAtRiskOpt_nonneg_stage_cost : A matrix from Run_Transform_Step of 
%       the form valueAtRiskOpt_nonneg_stage_cost(real_state, confidence_level_index)
%   Zs : transition fo the confidence level under optimal policy
%	mus : optimal controllers
%	x0 : initial state vector
%	l0 : initial confidence level
%   nt : number of stage cost trajectories to sample 
%   cfg : config struct
%   scn : scenario struct
%   amb : ambient struct
% OUTPUT: 
%   samples: a matrix with size corresponding to type (see above)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function samples = get_samples_in_parallel(type, valueAtRiskOpt_nonneg_stage_cost, ...
    Zs, mus, x_index, l_index, nt, cfg, scn, amb)

    if ~startsWith(scn.id, 'Q')

        zInterpolants = get_z_interpolants(Zs);
        muInterpolants = get_mu_interpolants(mus); 

        nw = length(scn.ws); tick_P = zeros( nw + 1, 1 );                     % nw : number of possible values of wk

        for i = 1 : nw, tick_P(i+1) = tick_P(i) + scn.P(i); end               % tick_P = [ 0, P(1), P(1)+P(2), ..., P(1)+...+P(nw-1), 1 ] 
    
    elseif startsWith(scn.id, 'Q') %for LEQG muInterpolants to just mus which contains the feedback gains
        tick_P = nan;
        muInterpolants = mus;
        zInterpolants = nan;
    end
    
    N = cfg.T / cfg.dt; % number of timesteps per trial
    
    switch type
        case 'state_trajectories'
            samples = nan(nt, scn.dim, N+1); 
        case 'control_trajectories'
            samples = nan(nt, N); 
        case 'stage_cost_trajectories'
            samples = nan(nt, N+1); 
        case 'cumulative_costs'
            samples = nan(nt, 1); 
        case default
            error('samples of the specified type are not supported'); 
    end
    
    sample_cells = cell(nt, 1); 
    
    disp('start time:');
    display(datestr(datetime('now'),'HH:MM:SS'));
    
    if startsWith(scn.id,'A') || startsWith(scn.id,'C') % cvar methods
        y = cfg.ls(l_index);
    elseif startsWith(scn.id,'E') || startsWith(scn.id,'Q') % exponential utility method
        y = cfg.thetas(l_index);
    else
        error('no other scenario supported.');
    end
    
    if startsWith(scn.id,'A') % exact cvar method, has extra state that keeps track of running cumulative cost
        s0 = valueAtRiskOpt_nonneg_stage_cost(x_index, l_index);
        % recall from Run_Transform_Step: valueAtRiskOpt_nonneg_stage_cost(real_state, confidence_level_index)
    elseif startsWith(scn.id,'C') || startsWith(scn.id,'E') || startsWith(scn.id,'Q')
        s0 = nan; % dummy variable
    else
        error('no other scenario supported.');
    end
             
    p = gcp('nocreate'); 
    opts = parforOptions(p,'RangePartitionMethod',str2func('distribute_work'));
    
    % use cell array because parfor does not support 
    % switch statement that would index into sample matrix
    % in different ways
    parfor (q = 1:nt, opts)
                  
        stream = RandStream('Threefry','seed',0);
        stream.Substream = q;
        
        % get trajectory sample
        [myTraj, ~, myCtrl, myCosts] = sample_trajectory_parallel(...
            s0, amb.real_state_values(x_index,:), y, tick_P, ...
            muInterpolants, zInterpolants, scn, cfg, amb, stream);  
        
        switch type
            case 'state_trajectories'
                sample_cells{q} = myTraj; 
            case 'control_trajectories'
                sample_cells{q} = myCtrl; 
            case 'stage_cost_trajectories'
                sample_cells{q} = myCosts;  
            case 'cumulative_costs'
                sample_cells{q} = sum(myCosts); 
            case default
                error('samples of the specified type are not supported'); 
        end   
                    
    end
    
    % unpack cells
    for q = 1:nt
        switch type
            case 'state_trajectories'
                if scn.dim == 2
                   samples(q, :, :) = permute(sample_cells{q}, [3,2,1]);  % e.g. 49, 2, 10 => 10, 2, 49 
                elseif scn.dim == 1
                   samples(q, :, :) = sample_cells{q}';
                else
                   error('only developed for up to 2 dimensions'); 
                end
            case {'control_trajectories', 'stage_cost_trajectories' }
                samples(q, :) = sample_cells{q}; 
            case 'cumulative_costs'
                samples(q) = sample_cells{q};  
            case default
                error('samples of the specified type are not supported'); 
        end
    end  
    
    disp('end time:');
    display(datestr(datetime('now'),'HH:MM:SS'));
    
end