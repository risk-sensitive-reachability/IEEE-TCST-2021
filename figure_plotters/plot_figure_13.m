function[] = plot_figure_13(output_filename)

    % fulfill prerequisites
    Run_Recursion('AWRS',1);
    Run_Recursion('EWRS',1);

    close all; 
    fig = Plot_Level_Sets('EWRS',1,[-5e-05,-2]);
    set(0, 'CurrentFigure', fig); 
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3) pos(4)/1.75]);
    pos = get(fig, 'Position'); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3) pos(4)]);
    print(gcf,strcat(output_filename,'_a'),'-dpdf','-r0');
    
    close all; 
    fig = Plot_Level_Sets('AWRS',1,[0.999, 0.005]);
    set(0, 'CurrentFigure', fig); 
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3) pos(4)/1.75]);
    pos = get(fig, 'Position'); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3) pos(4)]);
    print(gcf,strcat(output_filename,'_b'),'-dpdf','-r0')
    
end