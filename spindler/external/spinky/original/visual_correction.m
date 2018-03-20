function varargout = visual_correction(varargin)
% VISUAL_CORRECTION MATLAB code for visual_correction.fig
%      VISUAL_CORRECTION, by itself, creates a new VISUAL_CORRECTION or raises the existing
%      singleton*.
%
%      H = VISUAL_CORRECTION returns the handle to a new VISUAL_CORRECTION or the handle to
%      the existing singleton*.
%
%      VISUAL_CORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUAL_CORRECTION.M with the given input arguments.
%
%      VISUAL_CORRECTION('Property','Value',...) creates a new VISUAL_CORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visual_correction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visual_correction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visual_correction

% Last Modified by GUIDE v2.5 23-Apr-2016 15:02:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visual_correction_OpeningFcn, ...
                   'gui_OutputFcn',  @visual_correction_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visual_correction is made visible.
function visual_correction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visual_correction (see VARARGIN)

% Choose default command line output for visual_correction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
setappdata(gcf,'valeur_de_n',1)
setappdata(gcf,'kp_load',0');
setappdata(gcf,'sp_load',0');
setappdata(gcf,'scalo_stat',1');
set(handles.kp_radiobutton,'value',0);
set(handles.sp_radiobutton,'value',0);
setappdata(gcf,'autosave',0);
setappdata(gcf,'savestat',0);


% UIWAIT makes visual_correction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = visual_correction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in goto_bt.
function goto_bt_Callback(hObject, eventdata, handles)
% hObject    handle to goto_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xdata=getappdata(gcbf,'signal');
n=str2double(get(handles.nseg,'string'));
set(handles.nseg,'string',num2str(n))
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
axes(handles.axes1);
cla;
wn=[1 45];
t=(0:N-1)/fs;
yfilt=filtrage_fir(xdata{n},wn,80,fs);
plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'valeur_de_n',n);

save_etat=getappdata(gcbf,'autosave');

getappdata(gcbf,'file_score_kp');
getappdata(gcbf,'file_score_sp');

if save_etat==1
    
    possp=getappdata(gcbf,'pos_sp'); 
    poskp=getappdata(gcbf,'score_kp');

    nbrsp=getappdata(gcbf,'nbr_sp'); 
    nbrkp=getappdata(gcbf,'nbr_kp'); 



else 
    possp=getappdata(gcbf,'pos_sp_init'); 
    poskp=getappdata(gcbf,'score_kp_init');

    nbrsp=getappdata(gcbf,'nbr_sp_init'); 
    nbrkp=getappdata(gcbf,'nbr_kp_init'); 
 
end

setappdata(gcf,'score_kp', poskp);
setappdata(gcf,'pos_sp', possp);
setappdata(gcf,'nbr_sp',nbrsp);
setappdata(gcf,'nbr_kp',nbrkp);

scalo_stat=getappdata(gcbf,'scalo_stat');
set(handles.kp_radiobutton,'value',0);
set(handles.sp_radiobutton,'value',0);
if scalo_stat==0
        axes(handles.axes4);cla; 
        set(handles.axes4,'visible','off');set(handles.scalo_bt,'String','Show scalogram');  
        setappdata(gcf,'scalo_stat',1);
        
    if etat_sp==0 && etat_kp==0
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074 0.391566265060241 0.2 0.06506024096385543]); 
    elseif  etat_sp==0 && etat_kp==1
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);
              
            set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
       
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
           
           axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));
    elseif  etat_sp==1 && etat_kp==0
          
        
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);  
            set(handles.axes3,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
            set(handles.sp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            
                    
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_edit,'string',int2str(nbrsp{n}));
            
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
                       
    elseif  etat_sp==1 && etat_kp==1
        
        
           set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.3060240963855422 0.2 0.06506024096385543]);
            
           
           set(handles.sp_text,'units','normalized','position',[0.027920227920227917 0.46867469879518076 0.043874643874643876 0.019277108433734924]);
           set(handles.axes3,'units','normalized','position',[0.02735042735042735 0.3963855421686747 0.9407407407407407 0.06144578313253013 ]);
        
           set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
           set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013]);
           
                             
         
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.09397590361445785  0.16125356125356127 0.2349397590361446]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[ 0.02735042735042735 0.09397590361445785 0.14301994301994297 0.22891566265060243]);
        
           axes(handles.axes2);cla
           jj=0.5*ones(1,N);
           plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
           set(handles.kp_edit,'string',int2str(nbrkp{n}));
           
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
    end
else
    
    if  etat_sp==0 && etat_kp==1
            axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));

    elseif  etat_sp==1 && etat_kp==0
axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
    elseif  etat_sp==1 && etat_kp==1
         
        
        axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
            axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));
    end
end
    


function nseg_Callback(hObject, eventdata, handles)
% hObject    handle to nseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nseg as text
%        str2double(get(hObject,'String')) returns contents of nseg as a double


% --- Executes during object creation, after setting all properties.
function nseg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in previous_bt.
function previous_bt_Callback(hObject, eventdata, handles)
% hObject    handle to previous_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xdata=getappdata(gcbf,'signal');
n=str2double(get(handles.nseg,'string'));
n=n-1;
set(handles.nseg,'string',num2str(n))
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
axes(handles.axes1);
cla;
wn=[1 45];
t=(0:N-1)/fs;
yfilt=filtrage_fir(xdata{n},wn,80,fs);
plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'valeur_de_n',n);

save_stat=getappdata(gcbf,'savestat');

% possp=getappdata(gcbf,'pos_sp');
% poskp=getappdata(gcbf,'score_kp');
% % assignin('base','AA',possp);
% nbrsp=getappdata(gcbf,'nbr_sp'); 
% nbrkp=getappdata(gcbf,'nbr_kp'); 

save_etat=getappdata(gcbf,'autosave');
if save_etat==1 || save_stat==1
    
    possp=getappdata(gcbf,'pos_sp'); 
    poskp=getappdata(gcbf,'score_kp');

    nbrsp=getappdata(gcbf,'nbr_sp'); 
    nbrkp=getappdata(gcbf,'nbr_kp'); 

else 
    possp=getappdata(gcbf,'pos_sp_init'); 
    poskp=getappdata(gcbf,'score_kp_init');

    nbrsp=getappdata(gcbf,'nbr_sp_init'); 
    nbrkp=getappdata(gcbf,'nbr_kp_init'); 
 
end
setappdata(gcf,'score_kp', poskp);
setappdata(gcf,'pos_sp', possp);
setappdata(gcf,'nbr_sp',nbrsp);
setappdata(gcf,'nbr_kp',nbrkp);

etat_kp=getappdata(gcbf,'kp_load');
etat_sp=getappdata(gcbf,'sp_load');

getappdata(gcbf,'file_score_kp');
getappdata(gcbf,'file_score_sp');

scalo_stat=getappdata(gcbf,'scalo_stat');
set(handles.kp_radiobutton,'value',0);
set(handles.sp_radiobutton,'value',0);
if scalo_stat==0
        axes(handles.axes4);cla; 
        set(handles.axes4,'visible','off');set(handles.scalo_bt,'String','Show scalogram');  
        setappdata(gcf,'scalo_stat',1);
        
    if etat_sp==0 && etat_kp==0
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074 0.391566265060241 0.2 0.06506024096385543]); 
    elseif  etat_sp==0 && etat_kp==1
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);
              
            set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
       
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
           
           axes(handles.axes2);cla
           
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));
    elseif  etat_sp==1 && etat_kp==0
          
        
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);  
            set(handles.axes3,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
            set(handles.sp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            
                    
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_edit,'string',int2str(nbrsp{n}));
            
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
                       
    elseif  etat_sp==1 && etat_kp==1
        
        
           set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.3060240963855422 0.2 0.06506024096385543]);
            
           
           set(handles.sp_text,'units','normalized','position',[0.027920227920227917 0.46867469879518076 0.043874643874643876 0.019277108433734924]);
           set(handles.axes3,'units','normalized','position',[0.02735042735042735 0.3963855421686747 0.9407407407407407 0.06144578313253013 ]);
        
           set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
           set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013]);
           
                             
         
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.09397590361445785  0.16125356125356127 0.2349397590361446]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[ 0.02735042735042735 0.09397590361445785 0.14301994301994297 0.22891566265060243]);
        
           axes(handles.axes2);cla
           jj=0.5*ones(1,N);
           plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
           set(handles.kp_edit,'string',int2str(nbrkp{n}));
           
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
    end
else
    if  etat_sp==0 && etat_kp==1
            axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));

    elseif  etat_sp==1 && etat_kp==0
axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
    elseif  etat_sp==1 && etat_kp==1
         
        
        axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
            axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));
    end
end
    

% --- Executes on button press in next_bt.
function next_bt_Callback(hObject, eventdata, handles)
% hObject    handle to next_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xdata=getappdata(gcbf,'signal');
n=str2double(get(handles.nseg,'string'));
n=n+1;
set(handles.nseg,'string',num2str(n))
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
axes(handles.axes1);
cla;
wn=[1 45];
t=(0:N-1)/fs;
yfilt=filtrage_fir(xdata{n},wn,80,fs);
plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'valeur_de_n',n);

% possp=getappdata(gcbf,'pos_sp'); 
% nbrsp=getappdata(gcbf,'nbr_sp'); 
% 
% poskp=getappdata(gcbf,'score_kp');
% nbrkp=getappdata(gcbf,'nbr_kp'); 

save_etat=getappdata(gcbf,'autosave');
etat_kp=getappdata(gcbf,'kp_load');
etat_sp=getappdata(gcbf,'sp_load');

sp_file=getappdata(gcbf,'file_score_sp');
kp_file=getappdata(gcbf,'file_score_kp');

save_stat=getappdata(gcbf,'savestat');
% assignin('base','pfffff',save_stat);
if save_etat==1 
    
    possp=getappdata(gcbf,'pos_sp'); 
    poskp=getappdata(gcbf,'score_kp');

    nbrsp=getappdata(gcbf,'nbr_sp'); 
    nbrkp=getappdata(gcbf,'nbr_kp'); 
    
   
    if etat_kp==0 && etat_sp==1
            if isempty(possp{n-1});

            newline=[int2str(n-1) ' 0'];

            else
             [posnew,~] = pos2onset(possp{n-1},fs);
            newline=[int2str(n-1) ' ' int2str(nbrsp{n-1}) ' ' num2str((posnew))];

            end
            %modification du fichier text

            fid = fopen(sp_file, 'r+');
            s = textscan(fid, '%s', 'delimiter', '\n');
            s{1}{n-1}=newline;
            fclose(fid);
            fid = fopen(sp_file,'r+');
            for i=1:length(s{1})
            fprintf(fid,'%s \n',s{1}{i});
            end

    elseif etat_kp==1 && etat_sp==0

            if isempty(poskp{n-1});

            newline=[int2str(n-1) ' 0'];

            else
            newline=[int2str(n-1) ' ' int2str(nbrkp{n-1}) ' ' num2str((poskp{n-1}'/fs))];

            end
            %modification du fichier text

            fid = fopen(kp_file, 'r+');
            s = textscan(fid, '%s', 'delimiter', '\n');
            s{1}{n-1}=newline;
            fclose(fid);
            fid = fopen(kp_file,'r+');
            for i=1:length(s{1})
            fprintf(fid,'%s \n',s{1}{i});
            end
    elseif etat_kp==1 && etat_kp==1

            %Kcomplex File modification
            if isempty(poskp{n-1});

            newline=[int2str(n-1) ' 0'];

            else
            newline=[int2str(n-1) ' ' int2str(nbrkp{n-1}) ' ' num2str((poskp{n-1}'/fs))];

            end
            %modification du fichier text

            fid = fopen(kp_file, 'r+');
            s = textscan(fid, '%s', 'delimiter', '\n');
            s{1}{n-1}=newline;
            fclose(fid);
            fid = fopen(kp_file,'r+');
            for i=1:length(s{1})
            fprintf(fid,'%s \n',s{1}{i});
            end



            % Spindles file modification
            if isempty(possp{n-1});

            newline2=[int2str(n-1) ' 0'];

            else
             [posnew,~] = pos2onset(possp{n-1},fs);
            newline2=[int2str(n-1) ' ' int2str(nbrsp{n-1}) ' ' num2str((posnew))];

            end
            %modification du fichier text

            fid2 = fopen(sp_file, 'r+');
            s = textscan(fid, '%s', 'delimiter', '\n');
            s{1}{n-1}=newline2;
            fclose(fid2);
            fid2 = fopen(sp_file,'r+');
            for i=1:length(s{1})
            fprintf(fid2,'%s \n',s{1}{i});
            end
    end


elseif save_etat==0 
    
    if save_stat==0

   
    possp=getappdata(gcbf,'pos_sp_init'); 
    poskp=getappdata(gcbf,'score_kp_init');

    nbrsp=getappdata(gcbf,'nbr_sp_init'); 
    nbrkp=getappdata(gcbf,'nbr_kp_init'); 
    else 
  
    possp=getappdata(gcbf,'pos_sp'); 
    poskp=getappdata(gcbf,'score_kp');

    nbrsp=getappdata(gcbf,'nbr_sp'); 
    nbrkp=getappdata(gcbf,'nbr_kp'); 
    


    
    end
    
end


setappdata(gcf,'score_kp', poskp);
setappdata(gcf,'pos_sp', possp);
setappdata(gcf,'nbr_sp',nbrsp);
setappdata(gcf,'nbr_kp',nbrkp);


scalo_stat=getappdata(gcbf,'scalo_stat');
set(handles.kp_radiobutton,'value',0);
set(handles.sp_radiobutton,'value',0);
if scalo_stat==0
        axes(handles.axes4);cla; 
        set(handles.axes4,'visible','off');   set(handles.scalo_bt,'String','Show scalogram');  
        setappdata(gcf,'scalo_stat',1);
        
    if etat_sp==0 && etat_kp==0
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074 0.391566265060241 0.2 0.06506024096385543]); 
    elseif  etat_sp==0 && etat_kp==1
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);
              
            set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
       
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
           
           axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));
    elseif  etat_sp==1 && etat_kp==0
          
        
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);  
            set(handles.axes3,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
            set(handles.sp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            
                    
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_edit,'string',int2str(nbrsp{n}));
            
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
                       
    elseif  etat_sp==1 && etat_kp==1
        
        
           set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.3060240963855422 0.2 0.06506024096385543]);
            
           
           set(handles.sp_text,'units','normalized','position',[0.027920227920227917 0.46867469879518076 0.043874643874643876 0.019277108433734924]);
           set(handles.axes3,'units','normalized','position',[0.02735042735042735 0.3963855421686747 0.9407407407407407 0.06144578313253013 ]);
        
           set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
           set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013]);
           
                             
         
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.09397590361445785  0.16125356125356127 0.2349397590361446]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[ 0.02735042735042735 0.09397590361445785 0.14301994301994297 0.22891566265060243]);
        
           axes(handles.axes2);cla
           jj=0.5*ones(1,N);
           plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
           set(handles.kp_edit,'string',int2str(nbrkp{n}));
           
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
    end
else
    
    if  etat_sp==0 && etat_kp==1
            axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));

    elseif  etat_sp==1 && etat_kp==0
           axes(handles.axes3);cla; 
           imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
           set(handles.sp_edit,'string',int2str(nbrsp{n}));
    elseif  etat_sp==1 && etat_kp==1
         
        
            axes(handles.axes3);cla; 
            imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors;
            set(handles.sp_edit,'string',int2str(nbrsp{n}));
            axes(handles.axes2);cla
          
            jj=0.5*ones(1,N);
            plot(poskp{n}/fs,jj(poskp{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nbrkp{n}));
    end
end




% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_data_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=load(uigetfile('*.mat','select the M-file'));
X=fieldnames(data);
raw_data=data.(X{1});
%N=30000;fs=1000;
if size(raw_data,1)>1
prompt = {'Select channel index','Enter sampling frequency(Hz):', 'Enter segment length (sec):','Enter examiner name:'};
title = 'Configuration';

answer = inputdlg(prompt, title);

elect=str2double(answer{1});
fs= str2double(answer{2});
examinator= answer{3};
N=str2double(answer{3})*fs;
setappdata(gcf,'fs',fs);
setappdata(gcf,'N',N);
xdata=data_epoching(raw_data(elect,:),N);


else
prompt = {'Enter sampling frequency(Hz):', 'Enter segment length (sec):','Enter examiner name'};
title = 'Configuration';
answer = inputdlg(prompt, title);
fs= str2double(answer{1});
N=str2double(answer{2})*fs;
examinator= answer{3};

setappdata(gcf,'fs',fs);
setappdata(gcf,'N',N);
xdata=data_epoching(raw_data,N);

end


axes(handles.axes1);
set(handles.axes1,'visible','on');
cla(handles.axes1);
t=(0:N-1)/fs;
wn=[1 45];
n=getappdata(gcbf,'valeur_de_n');
yfilt=filter_fir(xdata{n},wn,80,fs);
plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'signal',xdata);

setappdata(gcf,'examiner',examinator);
% x = xlim;
% y = ylim;
% setappdata(gcf,'xlim',x);
% setappdata(gcf,'ylim',y);
% 
% 
% line([x(1) x(1)],y(:), 'linewidth',2.5,'color','b','buttondownfcn',@bdfcn);
% line([x(2) x(2)],y(:), 'linewidth',2.5,'color','r','buttondownfcn',@bdfcn);
% 
% % Blocage des limites du graphique
% set(gca,'xlimmode','manu')
set(handles.next_previous_panel,'visible','on');
set(handles.goto_bt,'visible','on');
set(handles.next_bt,'visible','on');
set(handles.previous_bt,'visible','on');
set(handles.nseg,'visible','on');
set(handles.segment_text,'visible','on');
set(handles.nseg,'string',int2str(n));
set(handles.scalo_bt,'visible','on');



function wbufcn(obj,event)
% Fonction � ex�cuter quand on rel�che la souris
set(obj,'windowbuttonmotionfcn',[],'pointer','arrow');

function wbmfcn(obj,event,h)
% Fonction � ex�cuter quand on d�place la souris
% OBJ : identifiant de la fenetre courante
% H : identifiant de la barre s�lectionn�e

% Modification du pointeur de la souris (juste esth�tique)
set(obj,'pointer','fleur');
% R�cup�ration des coordonn�es du pointeur de la souris
cp = get(gca,'currentpoint');
% Modification de la position en x de la barre s�lectionn�e
set(h,'xdata',[cp(1);cp(1)]);

function bdfcn(obj,event)
% Fonction a ex�cuter quand on clique sur une barre
% OBJ : identifiant de la barre s�lectionn�e
% WindowButtonMotionFcn : fonction � ex�cuter quand on d�place la souris
% WindowButtonUpFcn : fonction � ex�cuter quand on rel�che la souris
set(gcf,'windowbuttonmotionfcn',{@wbmfcn,obj},  ...
    'windowbuttonupfcn',@wbufcn);

% --------------------------------------------------------------------
function load_kp_score_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_kp_score_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

exp=getappdata(gcbf,'examiner');

choice = questdlg(['Hello ' exp ' ,is this your first Kcomplex score correction?' ],'Correction ',	'Yes','No', 'Yes');
switch choice
    case 'No'
        [new_kp_file,PathName_kp,FilterIndex] = uigetfile('*.txt','Select the score file');
       
       
    case 'Yes'
        [FileName_kp,PathName_kp,FilterIndex] = uigetfile('*.txt','Select the score file');
        
        ind=strfind(FileName_kp,'.txt');
        

        new_kp_file=[FileName_kp(1:ind-1) '_corrected_by_' exp '.txt'];
        copyfile(FileName_kp,new_kp_file);
        

end

fid = fopen(new_kp_file);
tline = fgetl(fid);
i=1;
n=str2double(get(handles.nseg,'string'));

set(handles.uitoolbar2,'visible','on');
setappdata(gcf,'file_score_kp',new_kp_file)
scalo_stat=getappdata(gcbf,'scalo_stat');
N=getappdata(gcbf,'N');
fs=getappdata(gcbf,'fs');
while ischar(tline)
    m(i)= textscan(tline,'%f');
    tline = fgetl(fid);
   i=i+1;
end

fclose(fid);
for j=1:length(m)
    A=m{j};
    if size(A,1)>2
    M{j}=A(3:end)*fs;
    nbr_kp1{j}=A(2);
    else
    M{j}=[];
    nbr_kp1{j}=0;

    end
end
setappdata(gcf,'score_kp',M) ;setappdata(gcf,'score_kp_init',M) ;

setappdata(gcf,'nbr_kp',nbr_kp1) ;setappdata(gcf,'nbr_kp_init',nbr_kp1) ;

if strcmp(get(handles.axes3,'visible'),'on')
    if scalo_stat==1
    set(handles.kp_text,'visible','on','Units','normalized','position',[0.027920227920227917 0.46867469879518076 0.043874643874643876 0.019277108433734924]);
    axes(handles.axes2);cla
    set(handles.axes2,'visible','on','Units','normalized','position',[0.02735042735042735 0.3963855421686747 0.9407407407407407 0.06144578313253013]);
    set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074  0.3060240963855422 0.2 0.06506024096385543]);
    jj=0.5*ones(1,N);
    plot(M{n}/fs,jj(M{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
    
%     set(handles.select_event,'visible','on','units','normalized','position',[0.7028508771929824 0.04748982360922659 0.16502192982456143 0.20488466757123475]); 
%     set(handles.sp_rd,'visible','on'); set(handles.kp_rd,'visible','on');set(handles.kp_edit,'visible','on','string',int2str(nbr_kp{n}));set(handles.sp_edit,'visible','on');
    setappdata(gcf,'kp_load',1); setappdata(gcf,'sp_load',1) ;
    

    set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.09397590361445785  0.16125356125356127 0.2349397590361446]);
    
    set(handles.kp_radio,'visible','on','Units','normalized','position',[0.03942652329749104 0.25 0.31899641577060933 0.12222222222222223]);
    set(handles.kp_edit,'visible','on','Units','normalized','position',[0.5017921146953405 0.23333333333333334 0.11827956989247312 0.17777777777777776],'string',int2str(nbr_kp1{n}));
     set(handles.edit_bt_kp,'visible','on','Units','normalized','position',[0.7491039426523297 0.22222222222222224 0.2114695340501792 0.18333333333333332]);
     
     
     set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.09397590361445785 0.14301994301994297 0.22891566265060243]);
     set(handles.kp_radiobutton,'visible','on','Units','normalized','position',[0.03643724696356275 0.48 0.5303643724696356 0.11428571428571432]);
     
     
     
    else
    set(handles.kp_text,'visible','on','Units','normalized','position',[0.027920227920227917  0.33975903614457836 0.04387464387464386 0.019277108433734924]);
    axes(handles.axes2);cla
    set(handles.axes2,'visible','on','Units','normalized','position',[0.02735042735042735 0.26746987951807233 0.9407407407407407 0.06144578313253013]);
    set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074  0.18313253012048195 0.2 0.06506024096385543]);
    jj=0.5*ones(1,N);
    plot(M{n}/fs,jj(M{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
  
%     set(handles.select_event,'visible','on','units','normalized','position',[0.7028508771929824 0.04748982360922659 0.16502192982456143 0.20488466757123475]); 
%     set(handles.sp_rd,'visible','on'); set(handles.kp_rd,'visible','on');set(handles.kp_edit,'visible','on','string',int2str(nbr_kp{n}));set(handles.sp_edit,'visible','on');
    setappdata(gcf,'kp_load',1); setappdata(gcf,'sp_load',1) ;
  
    set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376069 0.004819277108433735 0.16125356125356127 0.23493975903614459]);
    
    set(handles.kp_radio,'visible','on','Units','normalized','position',[0.03942652329749104 0.25 0.31899641577060933 0.12222222222222223]);
    set(handles.kp_edit,'visible','on','Units','normalized','position',[0.5017921146953405 0.23333333333333334 0.11827956989247312 0.17777777777777776],'string',int2str(nbr_kp1{n}));
   set(handles.edit_bt_kp,'visible','on','Units','normalized','position',[0.7491039426523297 0.22222222222222224 0.2114695340501792 0.18333333333333332]);
   
   
   
    set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.016867469879518072 0.14301994301994297 0.22891566265060243]);
     set(handles.kp_radiobutton,'visible','on','Units','normalized','position',[0.03643724696356275 0.48 0.5303643724696356 0.11428571428571432]);
    end
    
%     axes2_init=get(handles.axes2,'position');
%     setappdata(gcf,'position_scalo0_axes2',axes2_init);
%     
%     kp_text_init=get(handles.kp_text,'position');
%     setappdata(gcf,'position_scalo0_kp_text',kp_text_init);
    
else
    
    if scalo_stat==1
        
    set(handles.kp_text,'visible','on','Units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
    axes(handles.axes2);cla
    set(handles.axes2,'visible','on','Units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013]);
    set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);
    jj=0.5*ones(1,N);
    plot(M{n}/fs,jj(M{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
   
%     set(handles.select_event,'visible','on','units','normalized','position',[0.7028508771929824 0.04748982360922659 0.16502192982456143 0.20488466757123475]); 
%     set(handles.sp_rd,'visible','on'); set(handles.kp_rd,'visible','on');set(handles.kp_edit,'visible','on','string',int2str(nbr_kp{n}));set(handles.sp_edit,'visible','on');
    setappdata(gcf,'kp_load',1); setappdata(gcf,'sp_load',0);
     
    
    set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
    
    set(handles.kp_radio,'visible','on','Units','normalized','position',[0.03225806451612903 0.7166666666666667 0.3369175627240144 0.1166666666666667]);
    set(handles.kp_edit,'visible','on','Units','normalized','position',[0.4946236559139785 0.6833333333333333 0.11827956989247312 0.1777777777777778],'string',int2str(nbr_kp1{n}));
    set(handles.edit_bt_kp,'visible','on','Units','normalized','position',[0.7383512544802867 0.6833333333333333 0.22580645161290325 0.18333333333333335]);
    
    
    set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
    set(handles.kp_radiobutton,'visible','on','Units','normalized','position',[0.04048582995951417 0.76 0.5303643724696356 0.11428571428571432]);
    else
        
    set(handles.kp_text,'visible','on','Units','normalized','position',[0.028490028490028487 0.4373493975903615 0.04387464387464386 0.019277108433734924]);
    axes(handles.axes2);cla
    set(handles.axes2,'visible','on','Units','normalized','position',[0.027920227920227917 0.3662650602409639 0.9401709401709402 0.06144578313253013]);
    set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074 0.27951807228915665 0.2 0.06506024096385543]);
    jj=0.5*ones(1,N);
    plot(M{n}/fs,jj(M{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
 
%     set(handles.select_event,'visible','on','units','normalized','position',[0.7028508771929824 0.04748982360922659 0.16502192982456143 0.20488466757123475]); 
%     set(handles.sp_rd,'visible','on'); set(handles.kp_rd,'visible','on');set(handles.kp_edit,'visible','on','string',int2str(nbr_kp{n}));set(handles.sp_edit,'visible','on');
    setappdata(gcf,'kp_load',1); setappdata(gcf,'sp_load',0) ;
    
     set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.0963855421686747 0.16125356125356127 0.23493975903614459]);
    
    set(handles.kp_radio,'visible','on','Units','normalized','position',[0.03225806451612903 0.7166666666666667 0.3369175627240144 0.1166666666666667]);
    set(handles.kp_edit,'visible','on','Units','normalized','position',[0.4946236559139785 0.6833333333333333 0.11827956989247312 0.1777777777777778],'string',int2str(nbr_kp1{n}));
    set(handles.edit_bt_kp,'visible','on','Units','normalized','position',[0.7383512544802867 0.6833333333333333 0.22580645161290325 0.18333333333333335]);
    
    
    set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.0963855421686747 0.14301994301994297 0.22891566265060243]);
    set(handles.kp_radiobutton,'visible','on','Units','normalized','position',[0.04048582995951417 0.76 0.5303643724696356 0.11428571428571432]);
    end
    
     
end

   
    
    
% --------------------------------------------------------------------
function load_sp_score_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_sp_score_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


exp=getappdata(gcbf,'examiner');

choice = questdlg(['Hello ' exp ' ,is this your first Spindles score correction?' ],'Correction ',	'Yes','No', 'Yes');
switch choice
    case 'No'
        [new_sp_file,PathName_sp,FilterIndex] = uigetfile('*.txt','Select the score file');
       
       
    case 'Yes'
        [FileName_sp,PathName_sp,FilterIndex] = uigetfile('*.txt','Select the score file');
        
        ind=strfind(FileName_sp,'.txt');
        

        new_sp_file=[FileName_sp(1:ind-1) '_corrected_by_' exp '.txt'];
        copyfile(FileName_sp,new_sp_file);
        

end

set(handles.uitoolbar2,'visible','on');

fid = fopen(new_sp_file);
tline = fgetl(fid);
i=1;
n=str2double(get(handles.nseg,'string'));

scalo_stat=getappdata(gcbf,'scalo_stat');
setappdata(gcf,'file_score_sp',new_sp_file)

N=getappdata(gcbf,'N');
fs=getappdata(gcbf,'fs');
while ischar(tline)
    m(i)= textscan(tline,'%f');
    tline = fgetl(fid);
   i=i+1;
end

fclose(fid);

for j=1:length(m)
    A=m{j};
    if size(A,1)>2
     zind=find(A(3:end)==0);
    mat=A(3:end);
    mat(zind)=0.001;
     M{j}=mat*fs;   
        
    nbrsp{j}=A(2);
    else
    M{j}=[];nbrsp{j}=0;
    end
end


for jj=1:length(M) 
    H=M{jj};
    if isempty(H)==1
        possp{jj}=zeros(1,N);
    else
        tab=zeros(1,N);
        for kk=1:length(H)/2
           
            tab(H(2*kk-1):H(2*kk))=1;
        end
        possp{jj}=tab;
    end
    
end
setappdata(gcf,'pos_sp',possp);setappdata(gcf,'pos_sp_init',possp);
setappdata(gcf,'nbr_sp',nbrsp);setappdata(gcf,'nbr_sp_init',nbrsp);

    if strcmp(get(handles.axes2,'visible'),'on')
        if scalo_stat==1 
            
            set(handles.sp_text,'visible','on','Units','normalized','position',[0.027920227920227917 0.46867469879518076 0.043874643874643876 0.019277108433734924]);
            axes(handles.axes3);cla
            set(handles.axes3,'visible','on','Units','normalized','position',[0.02735042735042735 0.3963855421686747 0.9407407407407407 0.06144578313253013]);
            set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074  0.3060240963855422 0.2 0.06506024096385543]);
           
            imagesc(possp{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
            setappdata(gcf,'kp_load',1);setappdata(gcf,'sp_load',1);
            
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.09397590361445785  0.16125356125356127 0.2349397590361446]);

            set(handles.sp_radio,'visible','on','Units','normalized','position',[0.03942652329749104 0.25 0.31899641577060933 0.12222222222222223]);
            set(handles.sp_edit,'visible','on','Units','normalized','position',[0.5017921146953405 0.23333333333333334 0.11827956989247312 0.17777777777777776],'string',int2str(nbrsp{n}));
            set(handles.edit_bt_sp,'visible','on','Units','normalized','position',[0.7491039426523297 0.22222222222222224 0.2114695340501792 0.18333333333333332]);
           
            
            
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.09397590361445785 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_radiobutton,'visible','on','Units','normalized','position',[0.03643724696356275 0.48 0.5303643724696356 0.11428571428571432]);


        else
            
            set(handles.sp_text,'visible','on','Units','normalized','position',[0.027920227920227917  0.33975903614457836 0.04387464387464386 0.019277108433734924]);
            axes(handles.axes3);cla
            set(handles.axes3,'visible','on','Units','normalized','position',[0.02735042735042735 0.26746987951807233 0.9407407407407407 0.06144578313253013]);
            set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074  0.18313253012048195 0.2 0.06506024096385543]);
            imagesc(possp{n});colormap(parula);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
           setappdata(gcf,'kp_load',1) ;setappdata(gcf,'sp_load',1) ;
%           set(handles.select_event,'visible','on','units','normalized','position',[]); 
%           set(handles.kp_rd,'visible','on'); set(handles.sp_rd,'visible','on'); set(handles.sp_edit,'visible','on','string',int2str(nbr_sp{n}));set(handles.kp_edit,'visible','on');  
            
 
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376069 0.004819277108433735 0.16125356125356127 0.23493975903614459]);
           set(handles.sp_radio,'visible','on','Units','normalized','position',[0.03942652329749104 0.25 0.31899641577060933 0.12222222222222223]);
            set(handles.sp_edit,'visible','on','Units','normalized','position',[0.5017921146953405 0.23333333333333334 0.11827956989247312 0.17777777777777776],'string',int2str(nbrsp{n}));
            set(handles.edit_bt_sp,'visible','on','Units','normalized','position',[0.7491039426523297 0.22222222222222224 0.2114695340501792 0.18333333333333332]);
            
           
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.016867469879518072 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_radiobutton,'visible','on','Units','normalized','position',[0.03643724696356275 0.48 0.5303643724696356 0.11428571428571432]);
        end
    else
        if scalo_stat==1

            set(handles.sp_text,'visible','on','Units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            axes(handles.axes3);cla
            set(handles.axes3,'visible','on','Units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013]);
            set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);
            imagesc(possp{n});colormap(parula);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
            setappdata(gcf,'kp_load',0) ;setappdata(gcf,'sp_load',1) ;

            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
    
            set(handles.sp_radio,'visible','on','Units','normalized','position',[0.03225806451612903 0.7166666666666667 0.3369175627240144 0.1166666666666667 ]);
            set(handles.sp_edit,'visible','on','Units','normalized','position',[0.4946236559139785 0.6833333333333333 0.11827956989247312 0.1777777777777778],'string',int2str(nbrsp{n}));
            set(handles.edit_bt_sp,'visible','on','Units','normalized','position',[0.7383512544802867 0.6833333333333333 0.22580645161290325 0.18333333333333335]);
            
            
             set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_radiobutton,'visible','on','Units','normalized','position',[0.04048582995951417 0.76 0.5303643724696356 0.11428571428571432]);
            
        else
            
            set(handles.sp_text,'visible','on','Units','normalized','position',[0.028490028490028487 0.4373493975903615 0.04387464387464386 0.019277108433734924]);
            axes(handles.axes3);cla
            set(handles.axes3,'visible','on','Units','normalized','position',[0.027920227920227917 0.3662650602409639 0.9401709401709402 0.06144578313253013]);
            set(handles.next_previous_panel,'visible','on','Units','normalized','position',[0.4074074074074074 0.27951807228915665 0.2 0.06506024096385543]);
            imagesc(possp{n});colormap(parula);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
            setappdata(gcf,'kp_load',0) ;setappdata(gcf,'sp_load',1) ;
%           set(handles.select_event,'visible','on','units','normalized','position',[]); 
%           set(handles.kp_rd,'visible','off'); set(handles.sp_rd,'visible','on');set(handles.sp_edit,'visible','on','string',int2str(nbr_sp{n}));set(handles.kp_edit,'visible','off');  
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.0963855421686747 0.16125356125356127 0.23493975903614459]);
    
            set(handles.sp_radio,'visible','on','Units','normalized','position',[0.03225806451612903 0.7166666666666667 0.3369175627240144 0.1166666666666667 ]);
            set(handles.sp_edit,'visible','on','Units','normalized','position',[0.4946236559139785 0.6833333333333333 0.11827956989247312 0.1777777777777778],'string',int2str(nbrsp{n}));
            set(handles.edit_bt_sp,'visible','on','Units','normalized','position',[0.7383512544802867 0.6833333333333333 0.22580645161290325 0.18333333333333335]);
            
            
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.0963855421686747 0.14301994301994297 0.22891566265060243]);
            set(handles.sp_radiobutton,'visible','on','Units','normalized','position',[0.04048582995951417 0.76 0.5303643724696356 0.11428571428571432]);

        end
        
    end

% --------------------------------------------------------------------
function exit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to exit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in scalo_bt.
function scalo_bt_Callback(hObject, eventdata, handles)
% hObject    handle to scalo_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=getappdata(gcbf,'signal');
n=getappdata(gcbf,'valeur_de_n');
etat_kp=getappdata(gcbf,'kp_load');
etat_sp=getappdata(gcbf,'sp_load');
sclo_stat=getappdata(gcbf,'scalo_stat');
fs=getappdata(gcbf,'fs');

if sclo_stat==1
        axes(handles.axes4);cla;
        set(handles.axes4,'visible','on','units','normalized','position',[0.027920227920227917 0.47469879518072294 0.9401709401709402 0.10240963855421686 ]);
        sc=1./((10.5:0.15:16.5)/fs); %selon AASM sleep spindles dans la bande [11 16]
        wname='fbsp 20-0.5-1';  %;% 'cmor2-1.114''shan 0.5-1'
        W=cwt(x{n},sc,wname);
        freq= scal2frq(sc,wname,1/fs);
        N=getappdata(gcbf,'N');
        t=(0:N-1)/fs;
        set(handles.scalo_bt,'String','Hide scalogram');  
        % wscalogram('image',W,'scales',freq);colormap(jet)
        imagesc(t,freq,abs(W));colormap(jet);freezeColors; set(gca, 'XTick', []);  
        setappdata(gcf,'scalo_stat',0);

         if etat_kp==1 && etat_sp==1
        
        set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.18313253012048195 0.2 0.06506024096385543]);
      
        set(handles.sp_text,'units','normalized','position',[0.027920227920227917  0.33975903614457836 0.04387464387464386 0.019277108433734924]);
        set(handles.axes3,'units','normalized','position',[0.02735042735042735 0.26746987951807233 0.9407407407407407 0.06144578313253013]);
        
        set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.4481927710843374 0.04387464387464386 0.019277108433734924]);
        set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.3734939759036145 0.9401709401709402 0.0614457831325301 ]);
        
        set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376069 0.004819277108433735 0.16125356125356127 0.23493975903614459]);
    
        set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.016867469879518072 0.14301994301994297 0.22891566265060243]);
        
         elseif etat_kp==0 && etat_sp==1
        
        set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074 0.27951807228915665 0.2 0.06506024096385543]);
        
       
        set(handles.sp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
        set(handles.axes3,'units','normalized','position',[0.027920227920227917 0.3662650602409639 0.9401709401709402 0.06144578313253013]);
               
        
        set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.0963855421686747 0.16125356125356127 0.23493975903614459]);
        set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.0963855421686747 0.14301994301994297 0.22891566265060243]);
        elseif etat_kp==1 && etat_sp==0
        
        set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074 0.27951807228915665 0.2 0.06506024096385543]);
         
        
        set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
        set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.3662650602409639 0.9401709401709402 0.06144578313253013]);
     
        set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.0963855421686747 0.16125356125356127 0.23493975903614459]);
        set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.0963855421686747 0.14301994301994297 0.22891566265060243]);
        
        elseif etat_kp==0 && etat_sp==0
       
        set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074 0.391566265060241 0.2 0.06506024096385543]); 
        set(handles.select_event,'visible','off');
        end
        
else
    if etat_kp==0 && etat_sp==0 
            
            set(handles.next_previous_panel,'units','normalized','position',[ 0.4074074074074074 0.5120481927710844 0.2 0.06506024096385543]);
         
            
        elseif etat_kp==0 && etat_sp==1
            
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);  
            set(handles.axes3,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
            set(handles.sp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            
                    
            set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
            set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
             
        elseif etat_kp==1 && etat_sp==0
            
            set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.42530120481927713 0.2 0.06506024096385543]);
              
            set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
            set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013 ]);
       
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.2 0.16125356125356127 0.23493975903614456]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[0.02735042735042735 0.2 0.14301994301994297 0.22891566265060243]);
      
        elseif etat_kp==1 && etat_sp==1
          
           set(handles.next_previous_panel,'units','normalized','position',[0.4074074074074074  0.3060240963855422 0.2 0.06506024096385543]);
            
           
           set(handles.sp_text,'units','normalized','position',[0.027920227920227917 0.46867469879518076 0.043874643874643876 0.019277108433734924]);
           set(handles.axes3,'units','normalized','position',[0.02735042735042735 0.3963855421686747 0.9407407407407407 0.06144578313253013 ]);
        
           set(handles.kp_text,'units','normalized','position',[0.028490028490028487 0.591566265060241 0.04387464387464386 0.01927710843373498]);
           set(handles.axes2,'units','normalized','position',[0.027920227920227917 0.5168674698795181 0.9401709401709402 0.06144578313253013]);
           
                             
         
           set(handles.select_event,'visible','on','Units','normalized','position',[0.8068376068376067 0.09397590361445785  0.16125356125356127 0.2349397590361446]);
           set(handles.FN_panel,'visible','on','Units','normalized','position',[ 0.02735042735042735 0.09397590361445785 0.14301994301994297 0.22891566265060243]);

    end
   
    set(handles.scalo_bt,'String','Show scalogram');
    axes(handles.axes4);cla;
    set(handles.axes4,'visible','off');
    setappdata(gcf,'scalo_stat',1);
end
   

% setappdata(gcf,'kp_load',0');
% setappdata(gcf,'sp_load',0');
% setappdata(gcf,'scalo_stat',0');


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edit_bt_kp.
function edit_bt_kp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bt_kp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileName=getappdata(gcbf,'file_score_kp');
nbr_kp1=getappdata(gcbf,'nbr_kp');
poskp=getappdata(gcbf,'score_kp');
N=getappdata(gcbf,'N');
f=getappdata(gcbf,'fs');

ax=handles.axes2;
n=str2double(get(handles.nseg,'string'));
event=1;
nbrkp=nbr_kp1{n};
if numel(nbrkp)>0 
    
Edit_interface(nbrkp,poskp,n,ax,N,f,handles,event)

global new_pos new_nbr
uiwait
setappdata(gcf,'changement',1);
poskp{n}=new_pos;
nbr_kp1{n}=new_nbr;
setappdata(gcf,'score_kp',poskp);
setappdata(gcf,'nbr_kp',nbr_kp1);
  n=str2double(get(handles.nseg,'string'));
  set(handles.kp_edit,'string',int2str(new_nbr))
% if isempty(new_pos)
% 
%         newline=[int2str(n) ' 0'];
% 
%         else
%         newline=[int2str(n) ' ' int2str(new_nbr) ' ' num2str((new_pos'./f))];
%       
% end
% %modification du fichier text
% 
% fid = fopen(FileName, 'r+');
% 
% s = textscan(fid, '%s', 'delimiter', '\n');
% s{1}{n}=newline;
% fclose(fid);
% fid = fopen(FileName,'w');
% for i=1:length(s{1})
% fprintf(fid,'%s \n',s{1}{i});
% end


else
      errordlg('No detected Kcomplex ','Edit error');
end

% --- Executes on button press in edit_bt_kp.
function edit_bt_sp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bt_kp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nbr=getappdata(gcbf,'nbr_sp');

possp=getappdata(gcbf,'pos_sp');
N=getappdata(gcbf,'N');
fech=getappdata(gcbf,'fs');
Filename=getappdata(gcbf,'file_score_sp');
ax1=handles.axes3;
n=str2double(get(handles.nseg,'string'));
nbrsp=nbr{n};
event=2;
if numel(nbrsp) >0 
    
Edit_interface(nbrsp,possp,n,ax1,N,fech,handles,event)

global new_possp new_nbrsp
uiwait
possp{n}=new_possp;
nbr{n}=new_nbrsp;
setappdata(gcf,'pos_sp',possp);
setappdata(gcf,'nbr_sp',nbr);
set(handles.sp_edit,'string',int2str(new_nbrsp))
n=str2double(get(handles.nseg,'string'));


            y=new_possp;
            sa=sign(diff([-inf y]));
            sb=sign(diff([-inf y(end:-1:1)]));
            sb=sb(end:-1:1);
            d=find(sb==-1);
            f=find(sa==-1);
            %spindle_duration=(f-d)/fs;
          
            for i=1:length(f)
            gh(2*i-1)=d(i)/fech;
            gh(2*i)=f(i)/fech;
            end
            if isempty(f)
               new_onset=[];
            else
            new_onset=gh;
            gh=[];
            end
        setappdata(gcf,'changement',1);    
% if isempty(new_possp)
%         newline=[int2str(n) ' 0'];
%         else
%         newline=[int2str(n) ' ' int2str(new_nbrsp) ' ' num2str((new_onset))];
% end
% %modification du fichier text
% 
% fid = fopen(Filename, 'r+');
% % read the entire file, if not too big
% s = textscan(fid, '%s', 'delimiter', '\n');
%  
% s{1}{n}=newline;
% fclose(fid);
% fid = fopen(Filename,'w');
% for i=1:length(s{1})
% fprintf(fid,'%s \n',s{1}{i});
% end


else
      errordlg('No detected Spindles ','Edit error');
end

function kp_edit_Callback(hObject, eventdata, handles)
% hObject    handle to kp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kp_edit as text
%        str2double(get(hObject,'String')) returns contents of kp_edit as a double


% --- Executes during object creation, after setting all properties.
function kp_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sp_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sp_edit as text
%        str2double(get(hObject,'String')) returns contents of sp_edit as a double


% --- Executes during object creation, after setting all properties.
function sp_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_bt.
function add_bt_Callback(hObject, eventdata, handles)
% hObject    handle to add_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etatkp= get(handles.kp_radiobutton,'Value');
etatsp= get(handles.sp_radiobutton,'Value');
N=getappdata(gcbf,'N');
fs=getappdata(gcbf,'fs');
n= str2double(get(handles.nseg,'string'));
Filename_sp=getappdata(gcbf,'file_score_sp');
FileName_kp=getappdata(gcbf,'file_score_kp');

poskp1=getappdata(gcbf,'score_kp');
nbrkp1=getappdata(gcbf,'nbr_kp');

nbrsp1=getappdata(gcbf,'nbr_sp');

possp1=getappdata(gcbf,'pos_sp');
setappdata(gcf,'changement',1);
if etatkp==1
           
            h = findobj('type','line','linewidth',2.5,'color','r');
            xmin = get(h,'xdata');
            M=xmin(1);
            
            

            new_onset=sort([poskp1{n};floor(M*fs)]);
%             assignin('base', 'X', new_onset);
            new_nbrkp=length(new_onset);
            poskp1{n}=new_onset;
            setappdata(gcf,'score_kp',poskp1);
            nbrkp1{n}=new_nbrkp;
            setappdata(gcf,'nbr_kp',nbrkp1);
            axes(handles.axes2);cla
            jj=0.5*ones(1,N);
            plot(poskp1{n}/fs,jj(poskp1{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(new_nbrkp));

            %%
            
%             newline=[int2str(n) ' ' int2str(new_nbrkp) ' ' num2str((new_onset))];
%             fid=fopen(FileName_kp,'r+');
%             s = textscan(fid, '%s', 'delimiter', '\n');
%             s{1}{n}=newline;
%             fclose(fid);
%             fid = fopen(Filename,'w');
%             for i=1:length(s{1})
%             fprintf(fid,'%s \n',s{1}{i});
%             end
%             fprintf(fid,'\n %s %d %d',int2str(n),M.');
%             fclose(fid);

elseif etatsp==1
                axes(handles.axes1);
                h(1) = findobj('type','line','linewidth',2.5,'color','b');
                % R�cup�ration de l'identigfiant de la barre verte
                h(2) = findobj('type','line','linewidth',2.5,'color','k');
                % R�cup�ration des position en x des deux barres
                xmin = get(h(1),'xdata');
                xmax = get(h(2),'xdata');
                Msp=[xmin(1);xmax(1)];
                possp1{n}(floor(xmin(1)*fs):floor(xmax(1)*fs))=1;
        %       new_onsetsp=sort([possp{n};Msp]); 
        %       possp{n}=new_onsetsp;
                new_nbrsp=nbrsp1{n}+1;
                nbrsp1{n}=new_nbrsp;
                setappdata(gcf,'pos_sp',possp1);
                setappdata(gcf,'nbr_sp',nbrsp1);

        %       assignin('base', 'X', possp);
                axes(handles.axes3);cla
                set(handles.sp_edit,'string',int2str(new_nbrsp));
                imagesc(possp1{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
        %       file_name=[scorer '_' subj_name  '_Spindles.txt'];
        %       fid=fopen(file_name,'a+');
        %       fprintf(fid,'\n %s %d %d',int2str(n),M.');
        %       fclose(fid);
else
        errordlg('Please select event','Event selection Error');
end


% --- Executes when selected object is changed in FN_panel.
function FN_panel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in FN_panel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 xdata= getappdata(gcbf,'signal');
N=getappdata(gcbf,'N');
fs=getappdata(gcbf,'fs'); 
axes(handles.axes1);cla
            t=(0:N-1)/fs;
            wn=[1 45];
            n=getappdata(gcbf,'valeur_de_n');
            yfilt=filter_fir(xdata{n},wn,80,fs);
            plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
   switch get(get(handles.FN_panel,'SelectedObject'),'Tag')
       case 'kp_radiobutton'
               
           axes(handles.axes1); 
            x = xlim;
            y = ylim;
            setappdata(gcf,'xlim',x);
            setappdata(gcf,'ylim',y);
            line([x(1) x(1)],[y(1),-100], 'linewidth',2.5,'color','r','buttondownfcn',@bdfcn);
    
            % Blocage des limites du graphique
            set(gca,'xlimmode','manu')
    
       case 'sp_radiobutton'
            
            axes(handles.axes1); 
            x = xlim;
            y = ylim;
            setappdata(gcf,'xlim',x);
            setappdata(gcf,'ylim',y);


            line([x(1) x(1)],y(:), 'linewidth',2.5,'color','b','buttondownfcn',@bdfcn);
            line([x(2) x(2)],y(:), 'linewidth',2.5,'color','k','buttondownfcn',@bdfcn);

            % Blocage des limites du graphique
            set(gca,'xlimmode','manu')
   end


% --- Executes on button press in save_bt.
function save_bt_Callback(hObject, eventdata, handles)
% hObject    handle to save_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function autosave_bt_OnCallback(hObject, eventdata, handles)
% hObject    handle to autosave_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(gcf,'autosave',1)


% --------------------------------------------------------------------
function autosave_bt_OffCallback(hObject, eventdata, handles)
% hObject    handle to autosave_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(gcf,'autosave',0)


% --------------------------------------------------------------------
function refresh_bt_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to refresh_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Are you sure to reset? This will remove all your modifications' ,'Reset ',	'Reset','Cancel', 'Cancel');
switch choice
    case 'Cancel'

               
       
    case 'Reset'
       
pos_kp_init=getappdata(gcbf,'score_kp_init') ;
nb_kp_init=getappdata(gcbf,'nbr_kp_init') ;

poskp=getappdata(gcbf,'score_kp');
nbrkp=getappdata(gcbf,'nbr_kp');

pos_sp_init=getappdata(gcbf,'pos_sp_init') ;
nb_sp_init=getappdata(gcbf,'nbr_sp_init') ;
% assignin('base','nb',pos_sp_init)
possp=getappdata(gcbf,'pos_sp');
nbrsp=getappdata(gcbf,'nbr_sp');
% assignin('base','nbmod',possp) 
etat_kp=getappdata(gcbf,'kp_load');
etat_sp=getappdata(gcbf,'sp_load');

n=getappdata(gcbf,'valeur_de_n');
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
if etat_kp==0 && etat_sp==1
         axes(handles.axes3);cla
         set(handles.sp_edit,'string',int2str(nb_sp_init{n}));
         imagesc(pos_sp_init{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors 
         possp{n}=pos_sp_init{n};
         nbrsp{n}=nb_sp_init{n};
         
         setappdata(gcf,'pos_sp',possp);
         setappdata(gcf,'nbr_sp',nbrsp); 
         set(handles.sp_radiobutton,'value',0);
elseif etat_kp==1 && etat_sp==0

            axes(handles.axes2);cla
            jj=0.5*ones(1,N);
            plot(pos_kp_init{n}/fs,jj(pos_kp_init{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nb_kp_init{n}));

            poskp{n}=pos_kp_init{n};
            nbrkp{n}=nb_kp_init{n};
         
            setappdata(gcf,'score_kp',poskp);
            setappdata(gcf,'nbr_kp',nbrkp);
             set(handles.kp_radiobutton,'value',0);
elseif etat_kp==1 && etat_sp==1
    
         axes(handles.axes3);cla
         set(handles.sp_edit,'string',int2str(nb_sp_init{n}));
         imagesc(pos_sp_init{n});colormap(parula);set(gca,'YTick',[]);set(gca,'XTick',[]),set(gca,'color',[0.200000002980232 0 0.600000023841858]);freezeColors
         
         possp{n}=pos_sp_init{n};
         nbrsp{n}=nb_sp_init{n};
         
         setappdata(gcf,'pos_sp',possp);
         setappdata(gcf,'nbr_sp',nbrsp);
         
            axes(handles.axes2);cla
            jj=0.5*ones(1,N);
            plot(pos_kp_init{n}/fs,jj(pos_kp_init{n}),'k^','markerfacecolor','y','markersize',13);axis([0 30 0 1]);set(gca, 'XTick', []);set(gca, 'YTick', []);set(gca,'color',[0.200000002980232 0 0.600000023841858]);
            set(handles.kp_edit,'string',int2str(nb_kp_init{n}));
            
            poskp{n}=pos_kp_init{n};
            nbrkp{n}=nb_kp_init{n};
         
            setappdata(gcf,'score_kp',poskp);
            setappdata(gcf,'nbr_kp',nbrkp);
            
            set(handles.kp_radiobutton,'value',0);
            set(handles.sp_radiobutton,'value',0);
end

end



% --------------------------------------------------------------------
function export_menu_Callback(hObject, eventdata, handles)
% hObject    handle to export_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function kp_export_menu_Callback(hObject, eventdata, handles)
% hObject    handle to kp_export_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function sp_export_menu_Callback(hObject, eventdata, handles)
% hObject    handle to sp_export_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function txt_file_sp_Callback(hObject, eventdata, handles)
% hObject    handle to txt_file_sp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etat_sp=getappdata(gcbf,'sp_load');fs=getappdata(gcbf,'fs');
sig=getappdata(gcbf,'signal');

if etat_sp ==1
possp=getappdata(gcbf,'pos_sp');

nbrsp=getappdata(gcbf,'nbr_sp');
% assignin('base','pos',possp);
% assignin('base','nbr',nbrsp);
% assignin('base','X',sig);
nbr_tot= sum(cell2mat(nbrsp));


duree_seg=getappdata(gcbf,'N')/fs;duree_sig=length(possp)*duree_seg;

for j=1:length(possp)
   KK= find(possp{j})==1;
   
    if numel(KK)>0
    [onsets,spindle_duration] = pos2onset(possp{j},fs);
    x=sig{j}(possp{j}==1);
    [v_e, v_n]=bf_envhilb(x);
    else
     spindle_duration=0;
     v_e=0;
    end
    M_duration(j)=mean(spindle_duration);
    M_amp(j)=mean(v_e);
end

mean_duration=mean(M_duration(M_duration>0));
mean_amp=mean(M_amp(M_amp>0));

frq=nbr_tot/duree_sig;
field {1} = 'Total_number';  value(1) = nbr_tot;
field {2} = 'Density';  value(2) = nbr_tot/length(possp);
field {3} = 'Mean_duration';  value(3) = mean_duration;
field {5} = 'Mean_amptliude';  value(5) = mean_amp;
field {4} = 'Frequency';  value(4) = frq;

%
filesp=getappdata(gcbf,'file_score_sp');
C=textscan(filesp,'%s','delimiter','_');
C{1}{1}='Detection';
C{1}{2}='Results';
file_name = strjoin(C{1},'_');

 fid=fopen(file_name,'a+');
 for kk=1:length(field)
 fprintf(fid,'%s %s \n',field{kk},num2str(value(kk)));
 end
 fclose(fid);

else
     errordlg('Please load Spindles score','Spindles loading Error');
end

% --------------------------------------------------------------------
function mat_file_sp_Callback(hObject, eventdata, handles)
% hObject    handle to mat_file_sp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etat_sp=getappdata(gcbf,'sp_load');fs=getappdata(gcbf,'fs');
sig=getappdata(gcbf,'signal');

if etat_sp ==1
possp=getappdata(gcbf,'pos_sp');

nbrsp=getappdata(gcbf,'nbr_sp');
% assignin('base','pos',possp);
% assignin('base','nbr',nbrsp);
% assignin('base','X',sig);
nbr_tot= sum(cell2mat(nbrsp));


duree_seg=getappdata(gcbf,'N')/fs;duree_sig=length(possp)*duree_seg;

for j=1:length(possp)
   KK= find(possp{j})==1;
   
    if numel(KK)>0
    [onsets,spindle_duration] = pos2onset(possp{j},fs);
    x=sig{j}(possp{j}==1);
    [v_e, v_n]=bf_envhilb(x);
    else
     spindle_duration=0;
     v_e=0;
    end
    M_duration(j)=mean(spindle_duration);
    M_amp(j)=mean(v_e);
end

mean_duration=mean(M_duration(M_duration>0));
mean_amp=mean(M_amp(M_amp>0));

 frq=nbr_tot/duree_sig;
field1 = 'Total_number';  value1 = nbr_tot;
field2 = 'Density';  value2 = nbr_tot/length(possp);
 field3 = 'Mean_duration';  value3 = mean_duration;
 field5 = 'Mean_amptliude';  value5 = mean_amp;
 field4 = 'Frequency';  value4 = frq;
Results = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5);
%
filesp=getappdata(gcbf,'file_score_sp');
C=textscan(filesp,'%s','delimiter','_');
C{1}{1}='Detection';
C{1}{2}='Results';
file_name = strjoin(C{1},'_');
save([file_name '.mat'],'Results');
else
     errordlg('Please load Spindles score','Spindles loading Error');
end
% --------------------------------------------------------------------
function txt_menu_kp_Callback(hObject, eventdata, handles)
% hObject    handle to txt_menu_kp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

etat_kp=getappdata(gcbf,'kp_load');fs=getappdata(gcbf,'fs');
sig=getappdata(gcbf,'signal');

if etat_kp ==1
poskp=getappdata(gcbf,'score_kp');

nbrkp=getappdata(gcbf,'nbr_kp');
%  assignin('base','pos',poskp);
%  assignin('base','nbr',nbrkp);
% assignin('base','X',sig);

nbr_tot= sum(cell2mat(nbrkp));
duree_seg=getappdata(gcbf,'N')/fs;duree_sig=length(poskp)*duree_seg;
den=nbr_tot/length(poskp);
freq=nbr_tot/duree_sig;
for j=1:length(poskp)
    if numel(poskp{j})>0
        amp=sig{j}(poskp {j});
    else
        amp=0;
    end
     M_amp(j)=mean(amp);
end
mean_amp=mean(M_amp(M_amp<0));


field {1} = 'Total_number';  value(1) = nbr_tot;
field {2} = 'Density';  value(2) = den;
field {3} = 'Frequency';  value(3) = freq;
field {4} = 'Mean amplitude';  value(4) = mean_amp;
% 
% %
filekp=getappdata(gcbf,'file_score_kp');
C=textscan(filekp,'%s','delimiter','_');
C{1}{1}='Detection';
C{1}{2}='Results';
file_name = strjoin(C{1},'_');

 fid=fopen(file_name,'a+');
 for kk=1:length(field)
 fprintf(fid,'%s %s \n',field{kk},num2str(value(kk)));
 end
 fclose(fid);

else
     errordlg('Please load Kcomplex score','Kcomplex loading Error');
end
% --------------------------------------------------------------------
function mat_file_kp_Callback(hObject, eventdata, handles)
% hObject    handle to mat_file_kp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etat_kp=getappdata(gcbf,'kp_load');fs=getappdata(gcbf,'fs');
sig=getappdata(gcbf,'signal');

if etat_kp ==1
poskp=getappdata(gcbf,'score_kp');

nbrkp=getappdata(gcbf,'nbr_kp');
%  assignin('base','pos',poskp);
%  assignin('base','nbr',nbrkp);
assignin('base','X',sig);

nbr_tot= sum(cell2mat(nbrkp));
duree_seg=getappdata(gcbf,'N')/fs;duree_sig=length(poskp)*duree_seg;
den=nbr_tot/length(poskp);
freq=nbr_tot/duree_sig;
for j=1:length(poskp)
    if numel(poskp{j})>0
        amp=sig{j}(poskp {j});
    else
        amp=0;
    end
     M_amp(j)=mean(amp);
end
mean_amp=mean(M_amp(M_amp<0));


field1 = 'Total_number';  value1 = nbr_tot;
field2 = 'Density';  value2 = den;
field3 = 'Frequency';  value3 = freq;
field4 = 'Mean_amplitude';  value4 = mean_amp;
% 
% %
filekp=getappdata(gcbf,'file_score_kp');
C=textscan(filekp,'%s','delimiter','_');
C{1}{1}='Detection';
C{1}{2}='Results';
file_name = strjoin(C{1},'_');
Results = struct(field1,value1,field2,value2,field3,value3,field4,value4);
save([file_name '.mat'],'Results');
else
     errordlg('Please load Spindles score','Spindles loading Error');
end
% 


% --------------------------------------------------------------------
function save_bt_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etat_kp=getappdata(gcbf,'kp_load');
etat_sp=getappdata(gcbf,'sp_load');

sp_file=getappdata(gcbf,'file_score_sp');
kp_file=getappdata(gcbf,'file_score_kp');


fs=getappdata(gcbf,'fs');

n=getappdata(gcbf,'valeur_de_n');
possp=getappdata(gcbf,'pos_sp'); 
    poskp=getappdata(gcbf,'score_kp');

    nbrsp=getappdata(gcbf,'nbr_sp'); 
    nbrkp=getappdata(gcbf,'nbr_kp'); 
    
    
   
if etat_kp==0 && etat_sp==1
        if isempty(possp{n});

        newline=[int2str(n) ' 0'];

        else
         [posnew,~] = pos2onset(possp{n},fs);
        newline=[int2str(n) ' ' int2str(nbrsp{n}) ' ' num2str((posnew))];
      
        end
        %modification du fichier text
       
        fid = fopen(sp_file, 'r+');
        s = textscan(fid, '%s', 'delimiter', '\n');
        s{1}{n}=newline;
        fclose(fid);
        fid = fopen(sp_file,'r+');
        for i=1:length(s{1})
        fprintf(fid,'%s \n',s{1}{i});
        end
        
elseif etat_kp==1 && etat_sp==0
       
        if isempty(poskp{n});

        newline=[int2str(n) ' 0'];

        else
        newline=[int2str(n) ' ' int2str(nbrkp{n}) ' ' num2str((poskp{n}'/fs))];
      
        end
        %modification du fichier text
       
        fid = fopen(kp_file, 'r+');
        s = textscan(fid, '%s', 'delimiter', '\n');
        s{1}{n}=newline;
        fclose(fid);
        fid = fopen(kp_file,'r+');
        for i=1:length(s{1})
        fprintf(fid,'%s \n',s{1}{i});
        end
elseif etat_kp==1 && etat_kp==1
        
        %Kcomplex File modification
        if isempty(poskp{n});

        newline=[int2str(n) ' 0'];

        else
        newline=[int2str(n) ' ' int2str(nbrkp{n}) ' ' num2str((poskp{n}'/fs))];
      
        end
        %modification du fichier text
       
        fid = fopen(kp_file, 'r+');
        s = textscan(fid, '%s', 'delimiter', '\n');
        s{1}{n}=newline;
        fclose(fid);
        fid = fopen(kp_file,'r+');
        for i=1:length(s{1})
        fprintf(fid,'%s \n',s{1}{i});
        end
        
        
        
        % Spindles file modification
        if isempty(possp{n});

        newline2=[int2str(n) ' 0'];

        else
         [posnew,~] = pos2onset(possp{n},fs);
        newline2=[int2str(n) ' ' int2str(nbrsp{n}) ' ' num2str((posnew))];
      
        end
        %modification du fichier text
       
        fid2 = fopen(sp_file, 'r+');
        s = textscan(fid, '%s', 'delimiter', '\n');
        s{1}{n}=newline2;
        fclose(fid2);
        fid2 = fopen(sp_file,'r+');
        for i=1:length(s{1})
        fprintf(fid2,'%s \n',s{1}{i});
        end
end
setappdata(gcf,'score_kp', poskp);
setappdata(gcf,'pos_sp', possp);
setappdata(gcf,'nbr_sp',nbrsp);
setappdata(gcf,'nbr_kp',nbrkp);
setappdata(gcf,'savestat',1)


% --------------------------------------------------------------------
function autosave_bt_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to autosave_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
