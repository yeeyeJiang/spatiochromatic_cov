function plot_save(x,y,lty,xlab,ylab,simple_line_flag)
    %helper function for visulaization

    figure;
    
    if simple_line_flag
        plot(x,y,lty); 
        %hold on
        %plot(x, repelem(mean(y),length(x)),'-');
        %hold off
    else
        plot(x,y(:,1),'Color','r','LineStyle','-')
        hold on
        plot(x,y(:,2),'Color','r','LineStyle','--')
        plot(x,y(:,3),'Color','r','LineStyle',':')
        
        plot(x,y(:,4),'Color','g','LineStyle','-')
        plot(x,y(:,5),'Color','g','LineStyle','--')
        plot(x,y(:,6),'Color','g','LineStyle',':')
        
        plot(x,y(:,7),'Color','b','LineStyle','-')
        plot(x,y(:,8),'Color','b','LineStyle','--')
        plot(x,y(:,9),'Color','b','LineStyle',':')
        hold off
        
        legend({'RR','RG','RB','GR','GG','GB','BR','BG','BB'})
    end
       
    xlabel(xlab,'Interpreter','latex')
    ylabel(ylab,'Interpreter','latex')

    xlim([min(x),max(x)])
    set(gca,'FontSize',25)
 
    p=gcf;
    set(p,'Units', 'Inches', 'Position', [0, 0, 9.125*1.5, 6.25*1.5], 'PaperUnits', 'Inches', 'PaperSize', [9.125*1.5, 6.25*1.5])
    saveas(p,'fig.pdf')
    
end