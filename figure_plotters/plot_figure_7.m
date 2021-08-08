function[] = plot_figure_7(output_filename)
    
    % fulfill prerequisites
    Run_Recursion('ATRS',0);

    close all; 
    
    figs = { }; 
    figs{5} = Plot_Tradeoffs('ATRS',0,19.8);
    fig = figs{5}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 19.8$$');
    xlabel('');
    ylabel('');
    set(fig,'Units','Inches'); 
    ylim([-0.8, 3.5]);
    xlim([-7.2, 8.2]); 
    legend off; 

    figs{4} = Plot_Tradeoffs('ATRS',0,20);
    fig = figs{4}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 20$$');
    xlabel('');
    ylabel(''); 
    set(fig,'Units','Inches');  
    ylim([-0.8, 2.8]);
    xlim([-6.2, 3.6]); 
    legend off; 

    figs{3} = Plot_Tradeoffs('ATRS',0,20.5);
    fig = figs{3}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 20.5$$');
    xlabel('');
    ylabel(''); 
    set(fig,'Units','Inches'); 
    ylim([-0.4, 1.52]);
    xlim([-6.2, -1.9]); 
    legend off; 

    figs{2} = Plot_Tradeoffs('ATRS',0,21);
    fig = figs{2}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 21$$');
    xlabel('');
    ylabel(''); 
    xlim([-6.2, -1]); 
    ylim([-0.4, 1.52]); 
    set(fig,'Units','Inches'); 
    legend off; 

    figs{1} = Plot_Tradeoffs('ATRS',0,21.2);
    fig = figs{1}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 21.2$$');
    xlabel('Value-At-Risk');
    ylabel({'Expected Exceedance';'Above Value-at-Risk'}); 
    ylim([-0.4, 1.5]); 
    xlim([-6.2, 0.1]); 
    set(fig,'Units','Inches'); 
    legend off; 

    figs{6} = Plot_Tradeoffs('ATRS',0);
    fig = figs{6}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('composite');
    xlabel('');
    ylabel(''); 
    ylim([-0.4, 3.2]); 
    xlim([-7.2, 6.2]); 
    set(fig,'Units','Inches'); 
    legend off; 

    fig = figure(100); 
    set(0, 'CurrentFigure', figure(100)); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3)*2.25 pos(4)/2]);

    ax = zeros(6,1); 
    for i = 1:6
        ax(i)=subplot(1,6,i); 
    end

    for i = 1:6
      h = get(figs{i}, 'Children'); 
      newh = copyobj(h, 100); 

      possub = get(ax(i), 'Position'); 
      set(newh,'Position',...
          [possub(1) possub(2)*2.5 possub(3) possub(4)/2.25]);    

      delete(ax(i));  
    end

    sgtitle('Thermostatic Regulator, CVaR', 'FontSize', 14); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[12 3])
    print(gcf,output_filename,'-dpdf','-r0')

end