function  Edit_interface(nbr,pos,num_seg,ax,N,f,H,event)
   
global data a b new_nbr new_pos new_nbrsp new_possp axx L fs Hpr ev b_onset
ev=event;
Hpr=H;
fs=f;
axx=ax;
L=N;
 a=nbr;%(num_seg)
b=pos{num_seg};
new_nbr=[];
new_pos=[];
new_nbrsp=[];
new_possp=[];

%% Figure creation : 

screenUnits=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);
figWidth=240;
figHeight=(a*40)+125;
figPos=[(screenSize(3)-figWidth)/2 (screenSize(4)-figHeight)/2  ...
             figWidth                    figHeight];
%figPos=[0.4947916666666667 0.6611111111111111 0.23593749999999997 0.5564814814814815];
hFig=figure(...
    'IntegerHandle'     ,'off'                    ,...
    'DoubleBuffer'      ,'on'                     ,...
    'HandleVisibility'  ,'on'                     ,...
    'Name'              ,'Edit automatic score'   ,...
    'MenuBar'           ,'none'                   ,...
    'NumberTitle'       ,'off'                    ,...
    'Units'             ,'normalized'             ,... 
    'UserData'          ,[]                       ,...
    'Colormap'          ,[0 0 0]                  ,...
    'Pointer'           ,'arrow'                  ,...
    'Visible'           ,'on'                     ...
    );

set(hFig, 'Units','pixels','position',figPos);%,'OuterPosition',[0 0.035 1 0.965]
data.hFig = hFig;







data.textevent = uicontrol('Style', 'text','Parent',data.hFig,'Value',0,'String','Event','Tag','event_text',...
    'Units','pixels','Position', [15 figHeight-50 100 30],'FontName','Times New Roman',...
                 'FontWeight','bold',...
                 'fontsize',10,'HorizontalAlignment','left'); %(T(kk)*1720)/N 10 20 20,[new_x ] =event_position(T,selected_event,N,fs )

data.textduration = uicontrol('Style', 'text','Parent',data.hFig,'Value',0,'String','Onset(sec)','Tag','onset_text',...
    'Units','pixels','Position', [140 figHeight-50 150 30],'FontName','Times New Roman',...
                 'FontWeight','bold','HorizontalAlignment','left','fontsize',10);
yy=figHeight-80;

for kk=1:a
    if ev==1
        name=['Kcomplex ' int2str(kk)];
        b_onset=b/fs;
    else
        name=['Spindles ' int2str(kk)];
       
      
            y=b;
            sa=sign(diff([-inf y]));
            sb=sign(diff([-inf y(end:-1:1)]));
            sb=sb(end:-1:1);
            d=find(sb==-1);
            f=find(sa==-1);
            %spindle_duration=(f-d)/fs;

            for i=1:length(f)
            gh(2*i-1)=d(i)/fs;
            gh(2*i)=f(i)/fs;
            end
            b_onset=gh;
            gh=[];
      
    end
    GUI.del(kk) = uicontrol('Style', 'checkbox','Parent',data.hFig,'Value',0,'String',name,'Tag', int2str(kk),...
    'Units','pixels','Position', [15 yy 100 30]); %(T(kk)*1720)/N 10 20 20,[new_x ] =event_position(T,selected_event,N,fs )
   
    GUI.onset(kk) = uicontrol('Style', 'text','Parent',data.hFig,'Value',0,'String',num2str(b_onset(kk)) ,'Tag',['text_' int2str(kk)],...
    'Units','pixels','Position', [130 yy-9 100 30],'HorizontalAlignment','center'); %(T(kk)*1720)/N 10 20 20,[new_x ] =event_position(T,selected_event,N,fs )
       yy=yy-40;
end
data.push(1) = uicontrol('style','push',...
                 'parent',data.hFig,...
                 'unit','pixel',...
                 'position',[figWidth-110 yy-35 100 30 ],...   %button position normalized[0.7 ((nbr*2))/100 0.25 0.06]                        
                 'foregroundcolor','k',...
                 'FontName','Times New Roman',...
                 'FontWeight','bold',...
                 'fontsize',10,...
                 'visible','on',...
                 'string','Delete');
set(data.push(1),'call',{@push1_call,data});

data.push(2) = uicontrol('style','push',...
                 'parent',data.hFig,...
                 'unit','pixel',...
                 'position',[figWidth-225 yy-35 100 30 ],...   %button position normalized[0.7 ((nbr*2))/100 0.25 0.06]                        
                 'foregroundcolor','k',...
                 'FontName','Times New Roman',...
                 'FontWeight','bold',...
                 'fontsize',10,...
                 'visible','on',...
                 'string','Cancel');
set(data.push(2),'call',{@push2_call,data});

%% - Functions definitions :

% Push button fcn :
function push1_call(varargin)
global a b new_nbr new_pos new_nbrsp new_possp axx L fs Hpr ev 
global data; 
if isempty (a) ==1
    errordlg('Please select events to delete','Selection error');
else
h = findobj(data.hFig,'Style','checkbox','value',1);

for j=1:size(h,1)
    selected_event(j)=str2double(h(j).Tag);%
end


axes(axx);
 if ev==1
     a=a-length(selected_event);
     b(selected_event)=[];
     new_nbr=a;
     new_pos=b;

    cla;
    jj=0.5*ones(1,L);
    plot(new_pos/fs,jj(new_pos),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
    %set(Hpr.kcomplex_text,'string',int2str(new_nbr))
 else
     
     a=a-length(selected_event);
 
     
     new_nbrsp=a;
     new_possp=b;
     
     [pp,nn]=findpeaks(b,'MINPEAKDISTANCE',fs);
    del=nn(selected_event);
    for ll=1:length(del)
       new_possp(del(ll):del(ll)+2*fs)=0;
    end
     %set(Hpr.sp_edit,'string',int2str(new_nbrsp)) 
     cla;
     
   imagesc(new_possp);colormap(parula);set(gca, 'XTick', []);set(gca, 'YTick', []);%set(gca,'color',[0,0.5,0.4]);
 end
end

delete(data.hFig);
clear a b; 

function push2_call(varargin)
global new_nbr new_pos new_nbrsp new_possp ev a b data

if ev==1
     
     new_nbr=a;
     new_pos=b;

    
 else
     
     new_nbrsp=a;
     new_possp=b;
end
delete(data.hFig);
clear a b; 
