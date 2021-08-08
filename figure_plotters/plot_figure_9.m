function[] = plot_figure_9(output_filename)
    
    % fulfill prerequisites
    Run_Recursion('EPRS',5);

    close all; 
    fig = Plot_Tradeoffs('EPRS', 5); 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 13); 
    title('Thermostatic Regulator, EU with Non-Negative Costs');
    xlim([0,3.5])
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,output_filename,'-dpdf','-r0')
    
end