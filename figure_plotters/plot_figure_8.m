function[] = plot_figure_8(output_filename)

    close all;
    
    % fulfill prerequisites
    Run_Recursion('ETRS',0);
    Run_Recursion('ETRS',6);
        
    fig = Plot_Tradeoffs('ETRS', 0); 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 13); 
    title('Thermostatic Regulator, EU');
    xlim([0,3.5]);
    set(fig,'Units','Inches'); 
    pos = get(fig, 'Position'); 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    print(gcf,strcat(output_filename,'_a'),'-dpdf','-r0');
    hold off; 

    % plot zoomed in tradeoffs
    close all; 
    figs = { }; 

    figs{3} = Plot_Tradeoffs('ETRS',6,20.5);
    fig = figs{3}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 20.5$$');
    xlabel('');
    ylabel(''); 
    set(fig,'Units','Inches'); 
    xlim([0.2935, 0.299]);
    ylim([-4.671, -4.647]); 
    legend off; 

    figs{2} = Plot_Tradeoffs('ETRS',6,21);
    fig = figs{2}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 21$$');
    xlim([0.2965, 0.303]); 
    ylim([-4.132, -4.102]); 
    xlabel('');
    ylabel(''); 
    set(fig,'Units','Inches'); 
    legend off; 

    figs{1} = Plot_Tradeoffs('ETRS',6,21.2);
    fig = figs{1}; 
    set(0, 'CurrentFigure', fig); 
    set(gca, 'FontSize', 12); 
    title('$$x = 21.2$$');
    xlim([0.3338, 0.343]); 
    ylim([-3.715, -3.685]); 
    set(fig,'Units','Inches'); 
    legend off; 
    
    fig = figure(100); 
    set(0, 'CurrentFigure', figure(100)); 
    pos = get(fig, 'Position'); 
    set(fig, 'Position', [pos(1), pos(2), pos(3) pos(4)/3]);

    ax = zeros(3,1); 
    for i = 1:3
        ax(i)=subplot(1,3,i); 
    end

    for i = 1:3
      h = get(figs{i}, 'Children'); 
      newh = copyobj(h, 100); 

      possub = get(ax(i), 'Position'); 
      set(newh,'Position',...
          [possub(1)*1.1 possub(2)*3 possub(3) possub(4)/2]);  

      delete(ax(i));  
    end

    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[12 3])
    print(gcf,strcat(output_filename,'_b'),'-dpdf','-r0')
    
end