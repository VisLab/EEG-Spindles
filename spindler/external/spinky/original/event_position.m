function [new_x ] =event_position( old_position,selected_event,N,fs )
new_x=old_position;
new_x(selected_event)=[];
axes(handles.axes2);cla
set(handles.axes2,'visible','on');
jj=0.5*ones(1,N);
plot(new_x/fs,jj(new_x),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0,0.5,0.4]);

end

