function[] = plot_figure_6(output_filename)
    
    close all; 
    
    fig =  Plot_Disturbance_Profile('EWRS');
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 15); 
    title('Runoff Distribution');
    xlabel('Runoff [cfs]');
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3)/1.2, pos(4)/2]);
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)/1.2, pos(4)/2])
    print(gcf,strcat(output_filename, '_a'),'-dpdf','-r0')
    hold off; 

    [fig1, fig2, fig3] = Plot_Stormwater_System_Stage_Discharge_Curves('EWRS', 1);
    fig = fig1;
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 15); 
    legend boxoff;     
    xlim([0, 5.5]); title('Discharge to Combined Sewer (Penalty)');
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3)/1.2, pos(4)/2]);
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)/1.2, pos(4)/2])
    print(gcf,strcat(output_filename, '_b'),'-dpdf','-r0')
    hold off; 

    fig = fig2;
    set(0, 'CurrentFigure', fig);
    set(gca, 'FontSize', 15); 
    legend off; 
    xlim([0, 7]); title('Discharge to Combined Sewer (Penalty)');
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3)/1.2, pos(4)/2]);
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)/1.2, pos(4)/2])
    print(gcf,strcat(output_filename, '_c'),'-dpdf','-r0')
    hold off; 

    fig = fig3;
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 15); 
    legend off; 
    xlim([0, 7]); title('Discharge to Storm Sewer (No Penalty)');
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3)/1.2, pos(4)/2]);
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)/1.2, pos(4)/2])
    print(gcf,strcat(output_filename, '_d'),'-dpdf','-r0')
    hold off; 

end