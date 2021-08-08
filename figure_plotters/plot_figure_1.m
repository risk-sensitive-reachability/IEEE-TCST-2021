function[] =  plot_figure_1(output_filename)
    
    set(0, 'defaultTextInterpreter', 'latex');
    set(0, 'defaultAxesTickLabelInterpreter', 'latex');
    set(0, 'defaultLegendInterpreter', 'latex'); 

    snpdf = @(x) 0.274829 * exp(-0.237288 * (-1.0522 + x)^2) * erfc(1.05889 * (-1.0522 + x));

    close all;
    subplot(2, 1, 1); 
    u = 0:0.001:0.25;
    w = -4:0.001:03;

    [uu, ww] = meshgrid(u, w); 
    phi = @(u, W) u.^2 + (W+u).^2;

    pp = phi(uu, ww); 

    [Cminor, hminor] = contour(ww, uu, pp,... 
        [0.125, 0.250, 0.375, 0.500, 0.625, 0.750, 0.875, 0.9], ...
        ':', 'LineWidth', 1, 'Fill', 'off', 'LineColor', '#888888');
    hold on; 
    [C, h] = contour(ww, uu, pp,... 
        'LineWidth', 1, 'Fill', 'off', 'LevelStep', 1, 'LineColor', '#888888');

    % draw vertical lines at w = mean(W), w = quantile(W, 0.025), w = quantile(W, 0.0975)
    xline(0, '--', 'Color', 'red', 'LineWidth', 2, 'Color', '#A2142F'); 
    xline(-2.20141, '--', 'Color', 'blue', 'LineWidth', 2, 'Color', '#0072BD' );
    xline(1.71113, '--', 'Color', 'blue', 'LineWidth', 2, 'Color', '#0072BD' );

    clabel(Cminor, hminor, 0.125, 'Interpreter', 'Latex', 'FontSize', 11); 
    clabel(C, h, [1, 3, 5, 7, 9, 11, 13, 15], 'FontUnits', 'normalized',...
        'LabelSpacing', 100, 'Interpreter', 'Latex', 'FontSize', 11);

    title('$$\phi(u,w)$$')
    xlabel('$$w$$')
    ylabel('$$u$$'); 
    set(gca, 'FontSize', 13); 


    % next, align a copy of the pdf(w) for comparison
    subplot(2, 1, 2); 
    fplot(snpdf, 'LineWidth', 2, 'Color', '#77AC30')
    ylim([0, 0.45]);
    xlim([-4, 3]);
    title('Probability Distribution of $$W$$'); 
    xlabel('$$w$$')
    ylabel('Density'); 

    % draw vertical lines at w = mean(W), w = quantile(W, 0.025), w = quantile(W, 0.0975)
    xline(0, '--', 'Color', 'red', 'LineWidth', 2, 'Color', '#A2142F'); 
    xline(-2.20141, '--', 'Color', 'blue', 'LineWidth', 2, 'Color', '#0072BD' );
    xline(1.71113, '--', 'Color', 'blue', 'LineWidth', 2, 'Color', '#0072BD' ); 

    % add combined legend
    hold on; 
    h = zeros(3, 1);
    h(1) = plot(NaN,NaN,'o','Color','w');
    h(2) = plot(NaN,NaN,':','LineWidth', 1, 'Color', '#888888');
    h(3) = plot(NaN,NaN,'-','LineWidth', 1, 'Color', '#888888'); 
    h(4) = plot(NaN,NaN,'-','LineWidth', 2, 'Color', '#77AC30');
    h(5) = plot(NaN,NaN,'--','LineWidth', 2, 'Color', '#A2142F');
    h(6) = plot(NaN,NaN,'--','LineWidth', 2, 'Color', '#0072BD');

    leg = legend(h,...
        'contours of $$\phi(u,w)$$',...
        'by 0.125 $$\in$$ (0,1)',...
        'by 1',...
        'probability density of $$W$$',...
        'mean($$W$$)', ...
        'quantile($$W$$) for p = {0.025, 0.975}',...
        'FontSize', 11.5, 'Orientation', 'vertical', 'NumColumns', 2, ...
        'Location', 'southoutside');

    legend boxoff; 

    fig = gcf; 
    fig.Position(2) = fig.Position(2) - 300; 
    fig.Position(4) = fig.Position(4) + 300; 
    set(gca, 'FontSize', 13); 

    set(gcf,'Units','Inches'); 
    pos = get(gcf, 'Position'); 
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,output_filename,'-dpdf','-r0')
    hold off; 

end