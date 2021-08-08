function[] = plot_figure_11(output_filename)

    % fulfill prerequisites
    Run_Recursion('EWRS',1);
    
    close all; 
    figs = { }; 
    figs{1} = Plot_Tradeoffs('EWRS',1,[2 2]);
    fig = figs{1}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = [2, 2]^T$$');
    xlabel('Variance');
    ylabel('Expectation'); 
    set(fig,'Units','Inches'); 
    ylim([67, 67.5]);
    xlim([150, 165]); 
    legend off; 

    figs{2} = Plot_Tradeoffs('EWRS',1,[2.3 2.3]);
    fig = figs{2}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = [2.3, 2.3]^T$$');
    xlabel('');
    ylabel(''); 
    set(fig,'Units','Inches'); 
    ylim([121.3, 121.7]);
    xlim([222, 227]); 
    legend off; 

    figs{5} = Plot_Tradeoffs('EWRS',1,[3 4]);
    fig = figs{5}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = [3, 4]^T$$');
    xlabel('');
    ylabel(''); 
    set(fig,'Units','Inches'); 
    ylim([278, 287]);
    xlim([80, 145]); 
    legend off; 

    figs{4} = Plot_Tradeoffs('EWRS',1,[2 5.5]);
    fig = figs{4}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = [2, 5.5]^T$$');
    xlabel('');
    ylabel(''); 
    xlim([40, 325]); 
    ylim([210, 250]); 
    set(fig,'Units','Inches');  
    legend off; 

    figs{3} = Plot_Tradeoffs('EWRS',1,[2 5]);
    fig = figs{3}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = [2, 5]^T$$');
    xlabel('');
    ylabel(''); 
    xlim([200, 720]); 
    ylim([185, 202]); 
    set(fig,'Units','Inches'); 
    legend off; 

    figs{6} = Plot_Tradeoffs('EWRS',1);
    fig = figs{6}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('composite');
    xlabel('');
    ylabel(''); 
    xlim([10, 720]); 
    ylim([50, 325]); 
    set(fig,'Units','Inches'); 
    legend off; 

    fig = figure(100); 
    set(0, 'CurrentFigure', figure(100)); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3)*2.5 pos(4)/2]);

    ax = zeros(6,1); 
    for i = 1:6
        ax(i)=subplot(1,6,i); 
    end

    for i = 1:6
      h = get(figs{i}, 'Children'); 
      newh = copyobj(h, 100); 

      possub = get(ax(i), 'Position'); 
      set(newh,'Position',...
          [possub(1) possub(2)*2.5 possub(3)/1.05 possub(4)/2.25]);    

      delete(ax(i));  
    end
 
    sgtitle('Stormwater System, EU', 'FontSize', 14); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[13 3])
    print(gcf,output_filename,'-dpdf','-r0')
    
end