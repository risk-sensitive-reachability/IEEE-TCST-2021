function[] = plot_figure_10(output_filename)

    % fulfill prerequisites
    Run_Recursion('QTGS',3);
    
    close all; 
    fig = Plot_Tradeoffs('QTGS', 3); 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 13); 
    title('Thermostatic Regulator, LEQR');
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,output_filename,'-dpdf','-r0')
    
end