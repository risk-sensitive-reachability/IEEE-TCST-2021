%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots disturbance profile for a given scenario
% INPUT:
    % scenarioID = the string id of the scenario to use    
    % useYLabel = (optional) if explicitly set to false, the yaxis will not
    % be labeled [useful for subplots]
% OUTPUT:
    % fig = figure handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fig] = Plot_Disturbance_Profile(scenarioID, useYLabel)

    global scenario;

    scenario = get_scenario(scenarioID); 
    
    fig = figure; 
    set_figure_properties; set(gcf,'defaultaxesfontsize',12)
    set(0, 'defaultTextInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter', 'latex');
    set(0, 'defaultLegendInterpreter', 'latex'); 
    
    if strcmp(scenario.risk_functional, 'WorstCase')
        wk = max(scenario.ws);
        plot([wk, wk], [0, 1], '--');  
        hold on; 
        scatter(wk, 1, 'Black', 'Filled'); 
        hold off;
    else 
         for i = 1:length(scenario.ws)
            wk = scenario.ws(i); 
            if startsWith(scenario.id, 'EW') || startsWith(scenario.id, 'AW')
                plot([wk, wk], [0, scenario.P(i)], '--', 'Color', '#02b1f0'); 
            else
                plot([wk, wk], [0, scenario.P(i)], '--');   
            end
            hold on; 
         end
        scatter(scenario.ws, scenario.P, 25, 'Black', 'Filled');
        hold off; 
    end
    
    if startsWith(scenario.id, 'ETR') || startsWith(scenario.id, 'ATR') || startsWith(scenario.id, 'CTR')
        title('Right Skew','FontSize',12);
    elseif startsWith(scenario.id, 'ETL') || startsWith(scenario.id, 'ATL') || startsWith(scenario.id, 'CTL')
        title('Left Skew','FontSize',12);
    else
      title(strcat(['Disturbance Profile for Scenario ', scenarioID]), 'FontSize',12); 
    end
    
    ylim([0, (max(scenario.P) + .02)]);
    
    if ~exist('useYLabel','var') || useYLabel == true
        ylabel('Probability', 'FontSize',12); 
    end
    
    xlabel(strcat(['Disturbance value [', scenario.wunits, ']']) , 'FontSize',12); 
    
end 