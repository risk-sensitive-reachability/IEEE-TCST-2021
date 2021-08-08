%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generates tradeoff curves from many random trajectories
%   originating from the same initial condition (one for each initial
%   confidence level if using CVaR, one for each theta if using exponential
%   disutility).
% NOTE: There is a lot of tedious presentation specific code in this
%   dedicated to offsetting text labels for visual presentation, but the
%   points plotted are unadjusted from the experimental values.
% INPUTS:
%   scenarioID = the string id of the scenario to use
%   configurationID = the numeric id of the configuration to use
%   x0 [optional] = specify a single initial condition to plot
%       otherwise all applicable initial conditions will be plotted
%   [file]
%       /staging/{configurationID}/{scenarioID}/Transform_complete.mat : a
%       file containing results for all recursion steps
% OUTPUTS
%   fig = figure handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fig] = Plot_Tradeoffs(scenarioID, configurationID, x0)

    set(0, 'defaultTextInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter', 'latex');
    set(0, 'defaultLegendInterpreter', 'latex');

    if exist('x0','var')
        myx0 = x0;

        legend_text = {strcat('$x = ',mat2str(x0),'$')};
        N_X0 = 1;

    else
        % thermostatic regulator
        if startsWith(scenarioID, 'AT') || startsWith(scenarioID, 'ET') || ...
                startsWith(scenarioID, 'EP') || startsWith(scenarioID, 'QT')

            % initial conditions of interest for temperature system
            myx0 = [19.8, 20, 20.5, 21, 21.2]';

            legend_text = {'$x = 19.8$', '$x = 20$', '$x = 20.5$', '$x = 21$', '$x = 21.2$'};

            % water system
        elseif startsWith(scenarioID, 'AW') || startsWith(scenarioID, 'EW')

            % initial conditions of interest for water system
            myx0 = [ 2 2; 2.3 2.3; 2 5; 2 5.5; 3 4 ];

            legend_text = {'$x = [2, 2]^T$', '$x = [2.3, 2.3]^T$',  ...
                '$x = [2, 5]^T$', '$x = [2, 5.5]^T$', '$x = [3, 4]^T$'};

        else
            error('Plotting tradeoffs is not supported for this scenario.');
        end

        N_X0 = length(myx0);
    end

    plot_pt_style = {'-h', '-o', '-^', '-s', '-d'};

    mycolors = {'blue', [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250],...
        [0.4940 0.1840 0.5560], [0.3010 0.7450 0.9330], };

    fig = figure;

    set(gcf,'color','w');

    for x0_index = 1 : N_X0

        x0 = myx0(x0_index,:);

        %0 flag suppresses plot output (in this loop)
        %to permit plotting individual x0's we do a loop at the end of the
        %function so that matlab doesn't get figure handles confused
        [myXdata_x0, myYdata_x0, labels, Xdata_label, Ydata_label] = tradeoff_helper(scenarioID, ...
            configurationID, x0, 0, plot_pt_style{x0_index}, mycolors{x0_index}, legend_text{x0_index});

        if N_X0 == 1
            if startsWith(scenarioID, 'EW')

                if isequal(x0, [2 2])
                    x0_index = 1;
                elseif isequal(x0, [2.3 2.3])
                    x0_index = 2;
                elseif isequal(x0, [3, 4])
                    x0_index = 5;
                elseif isequal(x0, [2, 5.5])
                    x0_index = 4;
                elseif isequal(x0, [2, 5])
                    x0_index = 3;
                end
            elseif startsWith(scenarioID, 'AT') || configurationID == 6
                if isequal(x0, 19.8)
                    x0_index = 1;
                elseif isequal(x0, 20)
                    x0_index = 2;
                elseif isequal(x0, 20.5)
                    x0_index = 3;
                elseif isequal(x0, 21)
                    x0_index = 4;
                elseif isequal(x0, 21.2)
                    x0_index = 5;
                end
            end
        end

        plot(myXdata_x0, myYdata_x0, plot_pt_style{x0_index},...
            'Color', mycolors{x0_index},...
            'MarkerFaceColor', mycolors{x0_index});

        hold on;

        label_index_to_show = [1, length(labels)];

        if startsWith(scenarioID, 'AT') || startsWith(scenarioID, 'CT')
            if N_X0 == 1
                if x0 == 19.8
                    text(myXdata_x0(label_index_to_show(1))+0.75, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-1.5, ...
                        myYdata_x0(label_index_to_show(2))+0.75, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif x0 == 20
                    text(myXdata_x0(label_index_to_show(1))+0.5, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-1.5, ...
                        myYdata_x0(label_index_to_show(2))+0.5, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif x0 == 20.5
                    text(myXdata_x0(label_index_to_show(1))+0.325, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-0.75, ...
                        myYdata_x0(label_index_to_show(2))+0.3, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif x0 == 21
                    text(myXdata_x0(label_index_to_show(1))+0.325, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-0.75, ...
                        myYdata_x0(label_index_to_show(2))+0.3, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif x0 == 21.2
                    text(myXdata_x0(label_index_to_show(1))+0.4, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-0.75, ...
                        myYdata_x0(label_index_to_show(2))+0.3, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                end
            end

        elseif startsWith(scenarioID, 'ET')
            num_labels = length(labels);
            label_index_to_show = [1, num_labels];
            for i = 1:length(label_index_to_show)

                if configurationID == 6
                    if i == 1
                        if x0 == 21.2 || x0 == 21
                            text(myXdata_x0(label_index_to_show(i))-0.0015,...
                                myYdata_x0(label_index_to_show(i))+0.006,...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        elseif x0 == 20.5
                            text(myXdata_x0(label_index_to_show(i))-0.001,...
                                myYdata_x0(label_index_to_show(i))+0.005,...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        end
                    else
                        if x0 == 21.2
                            text(myXdata_x0(label_index_to_show(i))+0.001,...
                                myYdata_x0(label_index_to_show(i)),...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        else

                            text(myXdata_x0(label_index_to_show(i))+0.0005,...
                                myYdata_x0(label_index_to_show(i)),...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        end

                    end

                else

                    if x0_index == 1
                        text(myXdata_x0(label_index_to_show(i)) + .05,...
                            myYdata_x0(label_index_to_show(i)) + 0.05,...
                            labels{(label_index_to_show(i))}, ...
                            'FontSize', 12);
                    elseif x0_index == 2
                        text(myXdata_x0(label_index_to_show(i)) + .05,...
                            myYdata_x0(label_index_to_show(i)),...
                            labels{(label_index_to_show(i))}, ...
                            'FontSize', 12);
                    elseif x0_index == 3
                        text(myXdata_x0(label_index_to_show(i)) + .05,...
                            myYdata_x0(label_index_to_show(i)),...
                            labels{(label_index_to_show(i))}, ...
                            'FontSize', 12);
                    elseif x0_index == 4
                        if(i == 1)
                            text(myXdata_x0(label_index_to_show(i)) - .2,...
                                myYdata_x0(label_index_to_show(i))-.155,...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        else
                            text(myXdata_x0(label_index_to_show(i)) + .05,...
                                myYdata_x0(label_index_to_show(i)),...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        end

                    elseif x0_index == length(myx0)
                        if i~= 1
                            text(myXdata_x0(label_index_to_show(i)) - .2,...
                                myYdata_x0(label_index_to_show(i)),...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        else
                            text(myXdata_x0(label_index_to_show(i)) - .25,...
                                myYdata_x0(label_index_to_show(i))-.155,...
                                labels{(label_index_to_show(i))}, ...
                                'FontSize', 12);
                        end
                    end
                end
            end

        elseif startsWith(scenarioID, 'QT')
            label_index_to_show = [1, 9];

            yoffset = 0 ;
            xoffset = 0;
            switch(x0)
                case 19.8
                    yoffset = 0.35;
                    xoffset = 0.0025;

                case 20
                    yoffset = 0.15;
                    xoffset = 0.0025;

                case 20.5
                    xoffset = 0.005;
                    yoffset = 0.15;

                case 21
                    xoffset = 0.005;
                    yoffset = 0.2;

                case 21.2
                    yoffset = -0.1;
                    xoffset = 0.001;
            end

            if(configurationID ~= 100) % if not test configuration
                text(myXdata_x0(label_index_to_show(1))+ 0.0025 +xoffset,...
                    myYdata_x0(label_index_to_show(1))-0.25+yoffset, labels{label_index_to_show(1)},...
                    'FontSize', 12);
                for i = 2:length(label_index_to_show)
                    text(myXdata_x0(label_index_to_show(i))- 0.01, ...
                        myYdata_x0(label_index_to_show(i))+0.5, labels{label_index_to_show(i)}, ...
                        'FontSize', 12);
                end
            end

        elseif startsWith(scenarioID, 'EP')

            if x0 == 19.8 || x0 == 20

                text(myXdata_x0(1), myYdata_x0(1)-0.15, labels{1},...
                    'FontSize', 12);
                id = 4;
                text(myXdata_x0(id)-0.1, myYdata_x0(id)+0.125, labels{id},...
                    'FontSize', 12);

            else
                text(myXdata_x0(1)- 0.27, myYdata_x0(1)-0.15, labels{1},...
                    'FontSize', 12);
                id = 4;
                text(myXdata_x0(id)+0.02, myYdata_x0(id)+0.125, labels{id},...
                    'FontSize', 12);
            end

        elseif startsWith(scenarioID, 'EW')

            if N_X0 == 1
                label_index_to_show = [1, length(labels)];
                if isequal(x0, [3 4])
                    text(myXdata_x0(label_index_to_show(1)), ...
                        myYdata_x0(label_index_to_show(1))+1.5, ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-4, ...
                        myYdata_x0(label_index_to_show(2))-2, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif isequal(x0, [2 5.5])
                    text(myXdata_x0(8)-15, ...
                        myYdata_x0(8)-7, ... //-5
                        labels{8}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(1))-50, ...
                        myYdata_x0(label_index_to_show(1))+10, ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))+11, ...
                        myYdata_x0(label_index_to_show(2))-1, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif isequal(x0, [2 5])
                    text(myXdata_x0(label_index_to_show(1))-55, ...
                        myYdata_x0(label_index_to_show(1))+5, ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-35, ...
                        myYdata_x0(label_index_to_show(2))-3.5, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif isequal(x0, [2.3 2.3])
                    text(myXdata_x0(label_index_to_show(1))+0.2, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))-0.35, ...
                        myYdata_x0(label_index_to_show(2))-0.09, ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                elseif isequal(x0, [2 2])
                    text(myXdata_x0(label_index_to_show(1))+1, ...
                        myYdata_x0(label_index_to_show(1)), ...
                        labels{label_index_to_show(1)}, ...
                        'FontSize', 12);
                    text(myXdata_x0(label_index_to_show(2))+1, ...
                        myYdata_x0(label_index_to_show(2)), ...
                        labels{label_index_to_show(2)}, ...
                        'FontSize', 12);
                end
            end

        elseif startsWith(scenarioID, 'AW')
            label_index_to_show = [1, length(labels)];
            if isequal(x0, [2 5.5])
                text(myXdata_x0(label_index_to_show(1))-5, ...
                    myYdata_x0(label_index_to_show(1))+3, ...
                    labels{label_index_to_show(1)}, ...
                    'FontSize', 12);
                text(myXdata_x0(label_index_to_show(2))-5, ...
                    myYdata_x0(label_index_to_show(2))-3, ...
                    labels{label_index_to_show(2)}, ...
                    'FontSize', 12);
            else
                text(myXdata_x0(label_index_to_show(1))-15, ...
                    myYdata_x0(label_index_to_show(1))+3, ...
                    labels{label_index_to_show(1)}, ...
                    'FontSize', 12);
                text(myXdata_x0(label_index_to_show(2))-15, ...
                    myYdata_x0(label_index_to_show(2))-3, ...
                    labels{label_index_to_show(2)}, ...
                    'FontSize', 12);
            end
        end

    end

    xlabel(Xdata_label);
    ylabel(Ydata_label);
    if startsWith(scenarioID, 'QT')
        ylim([10 23]);
    end
    title(strcat(scenarioID));

    if startsWith(scenarioID, 'ET') || startsWith(scenarioID, 'EP')
        legend(legend_text, 'Interpreter', 'Latex', 'Fontsize', 12, 'Location','southeast');
    elseif startsWith(scenarioID, '')
        legend(legend_text, 'Interpreter', 'Latex', 'Fontsize', 12, 'Location','northeast');
    end

    grid on;

end


function [myXdata, myYdata, ra_level_labels, Xdata_label, Ydata_label] = tradeoff_helper(scenarioID, ...
    configurationID, x0, YESPLOT, plot_pt_style_str, mycolor_str, legend_str)

    staging_area = get_staging_directory(scenarioID, configurationID);
    transform_file = strcat([staging_area,'Transform_complete.mat']);

    % if bellman_file is available, load it, otherwise prompt to Run_Bellman_Recursion.
    if isfile(transform_file)

        load(transform_file);

    else

        error('No results available for this scenario and configuration. Please Run_Bellman_Recursion.');

    end

    staging_area = get_staging_directory(scenarioID, configurationID);

    % load globals
    global scenario;
    global ambient;
    global config;
    
    if startsWith(scenarioID, 'A')
       confidence_levels_to_evaluate = config.ls; 
    elseif startsWith(scenarioID, 'E') || startsWith(scenarioID, 'Q')
       confidence_levels_to_evaluate = config.thetas';
    else
        error('unexpected scenario');
    end

    nc = length(confidence_levels_to_evaluate);
    ra_level_labels = cell(nc,1);
    for i = 1 : nc
        ra_level_labels{i} = num2str(confidence_levels_to_evaluate(i));
    end

    nle = length(confidence_levels_to_evaluate);
    variance = zeros(nle, 1);
    expectation = zeros(nle, 1);
    skew = zeros(nle, 1);
    kurt = zeros(nle, 1);
    sup = zeros(nle, 1);
    value_at_risk = zeros(nle, 1);
    average_deviations_greater_than_var = zeros(nle, 1);
    certainty_equivalent = zeros(nle, 1);
    rprem = zeros(nle, 1);
    standard_dev = zeros(nle, 1);

    number_of_trials = 0;

    for j = 1:nle

        l0 = confidence_levels_to_evaluate(j);

        path_to_cumulative_cost_file = strcat([staging_area,'cumulative_costs_',mat2str(x0),'_',num2str(l0),'.mat']);

        if isfile(path_to_cumulative_cost_file)
            disp(path_to_cumulative_cost_file);
            cumulative_costs = load(path_to_cumulative_cost_file, 'cumulative_costs');
            cumulative_costs = cumulative_costs.cumulative_costs; 
        else
            disp(strcat('No cumulative cost file for x0 = ', {' '}, mat2str(x0), ...
                ' and confidence level ', {' '}, num2str(l0), {' '}, 'was found.'));
            disp(strcat('Generating cumulative costs from ', {' '},...
                mat2str(config.monte_carlo_trials), {' '}, 'trajectories...')); 
            cumulative_costs = generate_reproducible_samples_in_parallel('cumulative_costs', ...
                valueAtRiskOpt_nonneg_stage_cost, Zs, musOpt, x0, l0, config.monte_carlo_trials);
            save(path_to_cumulative_cost_file, 'cumulative_costs', '-v7.3'); 
        end

        % if not initialized, then number of trials
        % should be set from first file loaded
        dim = size(cumulative_costs);
        if number_of_trials == 0

            number_of_trials = dim(1);

        else
            if dim(1) ~= number_of_trials
                error(strcat(['Mismatch in expected size. Was: ', mat2str(dim(1)), '. Expected: ', mat2str(dim(1)), '.']));
            end
        end

        variance(j) = var(cumulative_costs);
        expectation(j) = mean(cumulative_costs);
        skew(j) = skewness(cumulative_costs);
        kurt(j) = kurtosis(cumulative_costs);
        sup(j) = max(cumulative_costs);
        certainty_equivalent(j) = (-2/l0)*log(mean(exp((-l0/2) .* cumulative_costs)));
        rprem(j) = certainty_equivalent(j) - expectation(j);
        standard_dev(j) = sqrt(variance(j));

        if(l0 < 0)
            l0_q = 0.5; % dummy value
        else
            l0_q = l0;
        end

        value_at_risk(j) = quantile(cumulative_costs, 1-l0_q);
        average_deviations_greater_than_var(j) = mean( max(cumulative_costs - value_at_risk(j), 0) );
        if isnan(average_deviations_greater_than_var(j))
            error('there may be too few samples. issue with average_deviations_greater_than_var');
        end

        if startsWith(scenarioID, 'C') || startsWith(scenarioID, 'A')
            myXdata = value_at_risk;
            myYdata = average_deviations_greater_than_var;
            Xdata_label = 'Value-at-Risk';
            Ydata_label = 'Expected Exceedance above Value-at-Risk';
        elseif startsWith(scenarioID, 'E') || startsWith(scenarioID, 'Q')
            myXdata = variance;
            myYdata = expectation;
            Xdata_label = 'Variance';
            Ydata_label = 'Expectation';
        else
            error('unexpected scenario');
        end

    end

    if YESPLOT
        figure;
        set(gcf,'color','w');
        plot(myXdata, myYdata, plot_pt_style_str, 'Color', mycolor_str, 'MarkerFaceColor', mycolor_str);
        title(strcat(scenarioID));
        xlabel(Xdata_label);
        ylabel(Ydata_label);
        legend(legend_str, 'Interpreter', 'Latex', 'Fontsize', 12);
        diffy = max(myYdata) - min(myYdata);
        diffx = max(myXdata) - min(myXdata);
        text(myXdata - diffx/8, myYdata + diffy/10, ra_level_labels);
        axis([min(myXdata) - diffx/5, max(myXdata) + diffx/5, min(myYdata) - diffy/5, max(myYdata) + diffy/5]);
        grid on;

        if startsWith(scenarioID, 'C') || startsWith(scenarioID, 'A')
            saveas(gcf, strcat([staging_area, 'value_at_risk__expected_deviations_',mat2str(x0), '.fig']));
        elseif startsWith(scenarioID, 'E') || startsWith(scenarioID, 'Q')
            saveas(gcf, strcat([staging_area, 'expectation__variance_',mat2str(x0), '.fig']));
        else
            error('unexpected scenario');
        end
    end

end

