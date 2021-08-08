%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots outflows through each passive outlet
% INPUT:
% scenarioID = the string id of the scenario to use
% configurationID = the numeric id of the configuration to use
% OUTPUT:
% fig1 : figure handle for natural and regulated discharge to combined sewer (tank 1)
% fig2 : figure handle for natural and regulated discharge to combined sewer (tank 2)
% fig3 : figure handle for natural and regulated discharge to storm sewer (tank 2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fig1, fig2, fig3] = Plot_Stormwater_System_Stage_Discharge_Curves(scenarioID, configID)

    global scenario;
    global config;
    global ambient;

    fontSize = 14;
    set(0, 'defaultTextInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter', 'latex');
    set(0, 'defaultLegendInterpreter', 'latex');

    scenario = get_scenario(scenarioID);
    config = get_config(configID);

    if ~contains(scenarioID, 'W')
        error('Plot_Stormwater_System_Stage_Discharge_Curves is only supported for the stormwater system.');
    end

    calculate_ambient_variables();

    natural_cs_discharge_s1 = q_outlet_natural(ambient.x1s, 1, scenario.combined_sewer_outlet_radius(1), scenario.combined_sewer_outlet_elevation(1)) .* scenario.combined_sewer_outlet_quantity(1);
    linearized_cs_discharge_s1 = q_outlet_linearized(ambient.x1s, 1, scenario.combined_sewer_outlet_radius(1), scenario.combined_sewer_outlet_elevation(1), ambient.xmax(1)) .* scenario.combined_sewer_outlet_quantity(1);

    natural_cs_discharge_s2 = q_outlet_natural(ambient.x2s, 1, scenario.combined_sewer_outlet_radius(2), scenario.combined_sewer_outlet_elevation(2)) .* scenario.combined_sewer_outlet_quantity(2);
    linearized_cs_discharge_s2 = q_outlet_linearized(ambient.x2s, 1, scenario.combined_sewer_outlet_radius(2), scenario.combined_sewer_outlet_elevation(2), ambient.xmax(2)) .* scenario.combined_sewer_outlet_quantity(2);

    natural_ss_discharge_s2 = q_outlet_natural(ambient.x2s, 1, scenario.storm_sewer_outlet_radius, scenario.storm_sewer_outlet_elevation);
    linearized_ss_discharge_s2 = q_outlet_linearized(ambient.x2s, 1, scenario.storm_sewer_outlet_radius, scenario.storm_sewer_outlet_elevation, ambient.xmax(2));

    fig1 = figure;
    hold on;
    plot(ambient.x1s, natural_cs_discharge_s1, '--', 'LineWidth', 2);
    plot(ambient.x1s,linearized_cs_discharge_s1, '-', 'LineWidth', 2);
    xline(scenario.combined_sewer_outlet_elevation(1), '-.', 'LineWidth', 2);

    hold off;

    title('Natural and Regulated Discharge to Combined Sewer (Tank 1)'); xlabel('Water Elevation [ft]'); ylabel('Discharge [cfs]');
    legend({'Natural','Regulated','Outlet Elev.','CSO Constraint'}, 'Location','northwest', 'FontSize', 14);
    set(gca, 'FontSize', fontSize);

    fig2 = figure;
    hold on;
    plot(ambient.x2s, natural_cs_discharge_s2, '--', 'LineWidth', 2);
    plot(ambient.x2s, linearized_cs_discharge_s2, '-', 'LineWidth', 2);
    xline(scenario.combined_sewer_outlet_elevation(2), '-.', 'LineWidth', 2);
    hold off;

    title('Natural and Regulated Discharge to Combined Sewer (Tank 2)'); xlabel('Water Elevation [ft]'); ylabel('Discharge [cfs]');
    legend({'Natural','Regulated','Outlet Elev.','CSO Constraint'}, 'Location','northwest', 'FontSize', 14);
    set(gca, 'FontSize', fontSize);

    fig3 = figure;
    hold on;
    plot(ambient.x2s, natural_ss_discharge_s2, '--', 'LineWidth', 2);
    plot(ambient.x2s, linearized_ss_discharge_s2, '-', 'LineWidth', 2, 'Color', '#72ad47');
    xline(scenario.storm_sewer_outlet_elevation(1), '-.', 'LineWidth',2);
    hold off;

    title('Natural and Regulated Discharge to Storm Sewer (Tank 2)'); xlabel('Water Elevation [ft]'); ylabel('Discharge [cfs]');
    legend({'Natural','Regulated','Outlet Elev.','CSO Constraint'}, 'Location','northwest', 'FontSize', 14);
    set(gca, 'FontSize', fontSize);
    ylim([0, 4.25]);

end