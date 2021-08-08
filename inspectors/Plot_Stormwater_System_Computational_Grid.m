%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots the computational grid for the Water System
% INPUT:
    % scenarioID = the string id of the scenario to use    
    % configurationID = the numeric id of the configuration to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Plot_Stormwater_System_Computational_Grid(scenarioID, configID)

    if ~contains(scenarioID, 'W')
        error('Plot_Stormwater_System_Computational_Grid is only supported for the stormwater system.');
    end

    global scenario;
    global config; 
    global ambient; 

    scenario = get_scenario(scenarioID); 
    config = get_config(configID); 

    calculate_ambient_variables(); 

    figure; scatter(ambient.xcoord(:,1),ambient.xcoord(:,2), 25, 'Black','filled');
    ylim([-1 max(ambient.x2s)+1]); 
    xlim([-1 max(ambient.x1s)+1]);
    l1 = line([scenario.combined_sewer_outlet_elevation(1) scenario.combined_sewer_outlet_elevation(1)], [-1 max(ambient.x2s)+1], 'LineWidth', 2, 'Color', [0, 0.447, 0.741]); 
    l2 = line([-1 max(ambient.x1s)+1], [scenario.combined_sewer_outlet_elevation(2) scenario.combined_sewer_outlet_elevation(2)], 'LineWidth', 2, 'Color', [0, 0.447, 0.741]); 
    l3 = line([-1 max(ambient.x1s)+1], [scenario.storm_sewer_outlet_elevation scenario.storm_sewer_outlet_elevation]+0.02, 'LineWidth', 2, 'Color', [0.466, 0.674, 0.188]);
    l4 = line([scenario.pump_elevation(1) scenario.pump_elevation(1)], [-1 max(ambient.x2s)+1], 'LineWidth', 2, 'Color', [0.494, 0.184, 0.556]); 
    l5 = line([-1 max(ambient.x1s)+1], [scenario.pump_elevation(2) scenario.pump_elevation(2)]-0.02, 'LineWidth', 2, 'Color', [0.494, 0.184, 0.556]); 
    l6 = line([-1 max(ambient.x1s)+1], [scenario.K_max(2) scenario.K_max(2)], 'LineWidth', 2, 'Color', [0.635, 0.078, 0.184]); 
    l7 = line([scenario.K_max(1) scenario.K_max(1)], [-1 max(ambient.x2s)+1], 'LineWidth', 2, 'Color', [0.635, 0.078, 0.184]); 

    % disable legends for one entry of the conceptual pairs
    set(get(get(l2, 'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % combined sewer
    set(get(get(l5, 'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % pump elevation
    set(get(get(l7, 'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % K_max

    title('Computational Grid'); xlabel('Tank 1 [ft]'); ylabel('Tank 2 [ft]'); 

    legend({'Grid','CS Outlet Elev.','SS Outlet Elev.','Pump Elev.', 'Constraints'}, 'Location','northwest');

end 