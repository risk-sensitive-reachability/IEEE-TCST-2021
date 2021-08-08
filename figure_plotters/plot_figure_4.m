function[] = plot_figure_4(output_filename)

    close all; 
    
    % get path to skewnormal input files
    slash = '/'; if (ispc); slash = '\'; end
    directory = strcat('IEEE-TCST-2021',slash,'misc',slash,'skewnormal_example',slash);

    % handle missing files or load data
    controls_filepath = strcat(directory, 'skewnormal_example_controls.mat');
    error_message_base = 'The file can be generated by running the skewnormal_example.nb in Mathematica or downloaded from https://github.com/Risk-Sensitive-Reachability/IEEE-TCST-2021.';
    hundredThousandSamples = nan(251, 1E5);
    
    for i = 1:251
        samples_filepath = strcat(directory, slash, 'samples', slash,...
            'skewnormal_example_phi_1E5_samples_',mat2str(i),'.mat'); 
        if samples_filepath
            if ~isfile(samples_filepath)
               error(['Expected skewnormal_example_phi_1E5_samples_,' mat2str(i), ...
                   '.mat in misc/skewnormal_example/samples/. ', error_message_base]);
            end
            hundredThousandSamples(i,:) = load(samples_filepath, 'Expression1').Expression1;
        end
    end
    if ~isfile(controls_filepath)
        error(['Expected skewnormal_example_controls.mat in misc/skewnormal_example. ', error_message_base]);
    end

    controls = load('skewnormal_example_controls.mat', 'Expression1').Expression1; 
    
    % determine alpha values to evaluate
    alphas = [1, 0.5, 0.25, 0.15, 0.1, 0.075, 0.05];
    cvars = nan(length(controls), length(alphas)); 
    vars = nan(length(controls), length(alphas)); 

    % plot cvar(phi(u,w), alpha) for each alpha in alphas
    hold on; 
    for aindex = 1:length(alphas)

        for uindex = 1:length(controls)

            alpha = alphas(aindex);  
            Z = hundredThousandSamples(uindex,:);
            vars(uindex, aindex) = quantile(Z, 1-alpha); 
            cvars(uindex, aindex) = estimate_CVaR_from_emperical_data(Z, alpha, vars(uindex, aindex)); 

        end

        plot(controls, cvars(:, aindex), '-', 'LineWidth', 2);
        hold on; 
    end

    % plot and optimal points for all alphas
    xpos = 0.255;
    text(xpos, 6.2, '$$\alpha =$$', 'FontSize', 13); 
    for alphaIndex = 1:length(alphas)

       isSecondToLastAlpha = alphas(alphaIndex) == 0.075;

       [optimal_cvar, optimal_u_index] = min(cvars(:,alphaIndex));
       plot(controls(optimal_u_index), optimal_cvar, 'o', 'MarkerFaceColor','k', 'Color', 'None');

       offset = 0; 
       if(isSecondToLastAlpha)
           offset = 0.05; 
       end

       text(...
           xpos,...
           cvars(end,alphaIndex)+offset, strcat('$$',mat2str(alphas(alphaIndex)), '$$'),...
           'FontSize', 13);
    end

    rectangle('Position',[0.115, 6.8, 0.13, 1], 'EdgeColor', 'w', 'FaceColor', 'w');

    ylabelstring = 'CVaR[$$\phi(u,W),\alpha$$]';

    % build the legend
    h = zeros(1, 1);
    h(1) = plot(NaN,NaN,'-','LineWidth', 2, 'Color', '#888888');
    h(2) = plot(NaN,NaN,'o','LineWidth', 2, 'MarkerFaceColor', 'Black', 'Color', 'None');
    leg = legend(h,ylabelstring, 'CVaR[$$\phi(u^\ast,W),\alpha$$]', ...
        'FontSize', 13, 'Orientation', 'vertical', 'Location', 'northeast');
    legend boxon; 


    hold off; 
    grid on; 

    xlabel('$u$'); ylabel(ylabelstring); title('CVaR[$$\phi(u,W),\alpha$$] for $$\alpha \in [0.05, 1]$$');
    ylim([0, 8]); 
    set(gca, 'FontSize', 13); 

    hold off; 

    % save the image
    set(gcf,'Units','Inches'); 
    pos = get(gcf, 'Position'); 
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,output_filename,'-dpdf','-r0')

end