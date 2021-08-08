function[] = plot_figure_5(output_filename)

    close all; 
    fig = Plot_Disturbance_Profile('ETRS');
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('Temperature Disturbance Distribution');
    ylabel('Probability');
    xlabel('Disturbance [deg C]'); 
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    legend off; 
    set(fig, 'Position', [pos(1), pos(2), pos(3) pos(4)/2]);
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3) pos(4)/2])
    print(gcf,output_filename,'-dpdf','-r0')

end