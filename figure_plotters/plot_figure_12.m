function[] = plot_figure_12(output_filename)

    % fulfill prerequisites
    Run_Recursion('AWRS',1);

    close all; 
    fig = Plot_Tradeoffs('AWRS', 1); 
    set(0, 'CurrentFigure', fig); 
    ylim([-5, 65]); 
    xlim([0 350]); 
    set(gca, 'FontSize', 12); 
    title('Water System, CVaR');
    ylabel('Expected Exceedance Above Value-at-Risk');
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3) pos(4)]);
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3) pos(4)])
    print(gcf,output_filename,'-dpdf','-r0')
    
end