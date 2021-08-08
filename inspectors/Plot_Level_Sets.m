%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Plots level sets for a particular scenario under a given configuration. 
% INPUT:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
%   levels [optional] = confidence levels to evaluate; if excluded
%       evaluates all configured confidence levels
%   [file]
%       /staging/{configurationID}/{scenarioID}/Transform_complete.mat : a
%       file containing optimal value function and policy for all risk-sensitivity levels
% OUTPUTS:
%   fig = a figure handles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[fig] = Plot_Level_Sets(scenarioID, configurationID, levels)

    if ~contains(scenarioID, 'W')
        error('Plot_Level_Sets is only supported for the stormwater system.');
    end

    set(0, 'defaultTextInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter', 'latex');
    set(0, 'defaultLegendInterpreter', 'latex'); 

    staging_area = get_staging_directory(scenarioID, configurationID); 
    transform_data_file = strcat([staging_area,'Transform_complete.mat']);
    
    % if data file is available, load it, otherwise prompt to Run_Bellman_Recursion and Run_Transform_Step.
    if isfile(transform_data_file)

       load(transform_data_file); 

    else

       error('No results available for this scenario and configuration. Please Run_Transform_Step first.');

    end
    
    % load globals
    global scenario;
    global config;
    global ambient; 
    
    % JsOpt(real_state_index, confidence_level_index) = optimal value function, time 0
    % at initial condition ambient.real_state_values(real_state_index),
    % risk-sensitivity level config.ls(confidence_level_index) if scenario is A, or
    % config.thetas(confidence_level_index) if scenario is E
   if exist('levels','var')
        confidence_levels_to_evaluate = levels; 
        indices_to_evaluate = nan(1,length(levels)); 
        for i = 1:length(confidence_levels_to_evaluate)

            if startsWith(scenario.id,'A') || startsWith(scenario.id,'C') 
                indices_to_evaluate(i) = find(config.ls == levels(i), 1); 
            elseif startsWith(scenario.id,'E')
                indices_to_evaluate(i) = find(config.thetas == levels(i), 1);
            else
                error('unsupported scenario'); 
            end

        end  
    else
        if startsWith(scenario.id,'A') || startsWith(scenario.id,'C') % exact cvar method via state aug, approx cvar method via LP
            confidence_levels_to_evaluate = config.ls;   
        elseif startsWith(scenario.id,'E') || startsWith(scenario.id,'Q') % exponential utility method
            confidence_levels_to_evaluate = config.thetas; 
        end
        indices_to_evaluate = 1:length(confidence_levels_to_evaluate); 
    end
    
    if scenario.dim == 2
        max_val = max(max(J0Opt)); min_val = min(min(J0Opt)); N_contours = 5;
        rs_to_show = linspace(min_val, max_val, N_contours);
        
    elseif scenario.dim == 1 % hard-coded for temperature system to see comparable lines for CVAR and EU cases.
        N_contours = 4;
        rs_to_show = linspace(3, 18, N_contours);
        mylinestyle = cell(length(rs_to_show),1);
        mylinestyle{1} = '-.r';
        mylinestyle{2} = '-k'; 
        mylinestyle{3} = '-.b';
        mylinestyle{4} = '-m';
        YMIN = 0;
        YMAX = max(rs_to_show)+2;
        XMIN = min(ambient.real_state_values);
        XMAX = max(ambient.real_state_values);
    else
        error('only built for real dim 2 or 1');
    end
   
    fig = figure; 
    set(gcf,'color','w');

    if scenario.dim == 2
        
        j = 0; 
        for i = indices_to_evaluate
            
            j = j + 1; 
            
            opt_value_func_grid_i = reshape( J0Opt(:, i), [ambient.x2n, ambient.x1n] );
            
            subplot(1, length(indices_to_evaluate), j);
            set(gca,'FontSize',12); 

            % plot contstraints
            hold on; 
            line([scenario.K_max(2); scenario.K_max(2)], [scenario.K_min(1); scenario.K_max(1)], 'linewidth', 3, 'color', 'k'); 
            line([scenario.K_min(2); scenario.K_max(2)], [scenario.K_max(1); scenario.K_max(1)], 'linewidth', 3, 'color', 'k'); 
            plot(scenario.K_max(2), scenario.K_max(1), '.', 'Color', 'k'); 
            
            xlim([0, 7]); 
            ylim([0, 5.5]); 
            
            [C, h] = contour(ambient.x2g_real_states, ambient.x1g_real_states, opt_value_func_grid_i, 0:100:500);
            
            clabel(C,h, 'Interpreter', 'Latex', 'Fontsize', 12, 'LabelSpacing', 100);
            h.LineWidth = 2; 
 
            hex = ['#1E3888','#47A8BD','#F5c263','#FFAD69','#9C3848']';
            rgb = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
            colormap(rgb); 
            
            if startsWith(scenario.id,'A') || startsWith(scenario.id,'C')
                title(['$\alpha$ = ', num2str(config.ls(i))], 'Interpreter','Latex', 'FontSize', 12); 
            elseif startsWith(scenario.id,'E')
                 title(['$\theta$ = ', num2str(config.thetas(i))], 'Interpreter','Latex', 'FontSize', 12); 
            else
                error('no other scenario type supported');
            end
            
            xlabel('$x_2$','Interpreter','Latex','FontSize', 12);
            ylabel('$x_1$','Interpreter','Latex','FontSize', 12);
            
            grid on;
 
        end
        
        if startsWith(scenario.id,'E')
            sgtitle('Stormwater System, EU, Safe Sets','FontSize', 14); 
        elseif startsWith(scenario.id,'A')
            sgtitle('Stormwater System, CVaR, Safe Sets','FontSize', 14); 
        end
        
    elseif scenario.dim == 1
        
        for i = 1 : ambient.nl
        
            opt_value_func_grid_i = J0Opt(:, i);
            
            subplot(2, ceil(ambient.nl/2), i);
            
            for r = 1 : length(rs_to_show)
                
                is_real_state_in_level_set = ( opt_value_func_grid_i <= rs_to_show(r) );
               
                num_real_states_in_level_set = sum(is_real_state_in_level_set);
                
                vals_xaxis = ambient.real_state_values(is_real_state_in_level_set);
                
                vals_yaxis = rs_to_show(r)*ones(num_real_states_in_level_set,1);
                
                plot(vals_xaxis, vals_yaxis, mylinestyle{r}, 'linewidth', 2 );
                
                hold on;
                
            end
           
            if startsWith(scenario.id,'A') || startsWith(scenario.id,'C')
                title(['$\alpha$ = ', num2str(config.ls(i))], 'Interpreter','Latex', 'FontSize', 12); 
            elseif startsWith(scenario.id,'E')
                 title(['$\theta$ = ', num2str(config.thetas(i))], 'Interpreter','Latex', 'FontSize', 12); 
            else
                error('no other scenario type supported');
            end
            axis([XMIN XMAX YMIN YMAX]);
            xlabel('$x_1$','Interpreter','Latex','FontSize', 12);
            ylabel('$r$','Interpreter','Latex','FontSize', 12);
            grid on;
        
        end
        
    else
        error('Plot_Level_Sets only supported for real state dim = 2 or real state dim = 1.');
    end
  
end