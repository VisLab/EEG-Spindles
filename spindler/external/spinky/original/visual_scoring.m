function varargout = visual_scoring(varargin)
% VISUAL_SCORING MATLAB code for visual_scoring.fig
%      VISUAL_SCORING, by itself, creates a new VISUAL_SCORING or raises the existing
%      singleton*.
%
%      H = VISUAL_SCORING returns the handle to a new VISUAL_SCORING or the handle to
%      the existing singleton*.
%
%      VISUAL_SCORING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUAL_SCORING.M with the given input arguments.
%
%      VISUAL_SCORING('Property','Value',...) creates a new VISUAL_SCORING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visual_scoring_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visual_scoring_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visual_scoring

% Last Modified by GUIDE v2.5 21-Mar-2016 17:20:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visual_scoring_OpeningFcn, ...
                   'gui_OutputFcn',  @visual_scoring_OutputFcn, ...
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


% --- Executes just before visual_scoring is made visible.
function visual_scoring_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visual_scoring (see VARARGIN)

% Choose default command line output for visual_scoring
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
n=1;
setappdata(gcf,'valeur_de_n',n);
 setappdata(gcf,'scalo_etat',0); 

% UIWAIT makes visual_scoring wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = visual_scoring_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in duration_bt.
function duration_bt_Callback(hObject, eventdata, handles)
% hObject    handle to duration_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
% R�cup�ration de l'identigfiant de la barre bleue
h(1) = findobj('type','line','linewidth',2.5,'color','b');
% R�cup�ration de l'identigfiant de la barre verte
h(2) = findobj('type','line','linewidth',2.5,'color','r');
% R�cup�ration des position en x des deux barres
xmin = get(h(1),'xdata');
xmax = get(h(2),'xdata');
duration=xmax(1)-xmin(1);
set(handles.duration_text,'string',[num2str(duration,3) ' sec']);

% --------------------------------------------------------------------
function File_menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data=load(uigetfile('*.mat','select the M-file'));
 X=fieldnames(data);
 raw_data=data.(X{1});
%N=30000;fs=1000;
if size(raw_data,1)>1
prompt = {'Enter scorer name:', 'Enter subject name','Select channel index','Enter sampling frequency(Hz):', 'Enter segment length (sec):'};
title = 'Configuration';

answer = inputdlg(prompt, title);

scorer=answer{1};
subj=answer{2};
elect=str2double(answer{3});
fs= str2double(answer{4});
N=str2double(answer{5})*fs;
setappdata(gcf,'fs',fs);
setappdata(gcf,'N',N);
xdata=data_epoching(raw_data(elect,:),N);
setappdata(gcf,'sb_name',subj);
setappdata(gcf,'name',scorer);

else
prompt = {'Enter scorer name:', 'Enter subject name','Enter sampling frequency(Hz):', 'Enter segment length (sec):'};
title = 'Configuration';
answer = inputdlg(prompt, title);
subj=answer{2};
scorer=answer{1};
fs= str2double(answer{3});
N=str2double(answer{4})*fs;
setappdata(gcf,'fs',fs);
setappdata(gcf,'N',N);
xdata=data_epoching(raw_data,N);
setappdata(gcf,'sb_name',subj);
setappdata(gcf,'name',scorer);
end


axes(handles.axes1);
set(handles.axes1,'visible','on');
cla(handles.axes1);
t=(0:N-1)/fs;
wn=[1 45];
n=getappdata(gcbf,'valeur_de_n');
yfilt=filter_fir(xdata{n},wn,80,fs);
plot(t,yfilt,'b');grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'signal',xdata);
% R�cuparation des limites du graphique
x = xlim;
y = ylim;
setappdata(gcf,'xlim',x);
setappdata(gcf,'ylim',y);


line([x(1) x(1)],[y(:)], 'linewidth',2.5,'color','b','buttondownfcn',@bdfcn);
line([x(2) x(2)],[y(:)], 'linewidth',2.5,'color','r','buttondownfcn',@bdfcn);

% Blocage des limites du graphique
set(gca,'xlimmode','manu')

set(handles.next_previous_panel,'visible','on');
set(handles.goto_bt,'visible','on');
set(handles.next_bt,'visible','on');
set(handles.previous_bt,'visible','on');
set(handles.nseg,'visible','on');
set(handles.segment_text,'visible','on');
set(handles.nseg,'string',int2str(n));

set(handles.scalo_bt,'visible','on');

set(handles.duration_bt,'visible','on');
set(handles.duration_text,'visible','on');

set(handles.choose_panel,'visible','on');
set(handles.Spindles_rad,'visible','on');
set(handles.Kcomplex_rad,'visible','on');
set(handles.validate_bt,'visible','on');
set(handles.cancel_bt,'visible','on');


 

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
function exit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to exit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in previous_bt.
function previous_bt_Callback(hObject, eventdata, handles)
% hObject    handle to previous_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
compt=1;
setappdata(gcf,'compt_events',compt);
setappdata(gcf,'selected_event',[]);
x=getappdata(gcbf,'signal');
n=getappdata(gcbf,'valeur_de_n');
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
axes(handles.axes1);
cla;
 n=n-1;
wn=[1 45];
t=(0:N-1)/fs;
 yfilt=filter_fir(x{n},wn,80,fs);
 plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'valeur_de_n',n);
 % R�cuparation des limites du graphique
x = xlim;
y = ylim;
setappdata(gcf,'xlim',x);
setappdata(gcf,'ylim',y);
line([x(1) x(1)],y(:), 'linewidth',2.5,'color','b','buttondownfcn',@bdfcn);
line([x(2) x(2)],y(:), 'linewidth',2.5,'color','r','buttondownfcn',@bdfcn);
 % Blocage des limites du graphique
set(gca,'xlimmode','manu');
set(handles.nseg,'string',int2str(n));
axes(handles.axes2);cla;
set(handles.axes2,'visible','off');
setappdata(gcf,'scalo_etat',0);  set(handles.scalo_bt,'String','Show scalogram');  
set(handles.next_previous_panel,'position',[0.3586326767091541 0.3607784431137725  0.24971031286210899 0.07185628742514968]);
set(handles.choose_panel,'position',[0.7809965237543453 0.22155688622754494  0.2033603707995365 0.2125748502994012]); 
setappdata(gcf,'scalo_etat',0); 
% --- Executes on button press in next_bt.
function next_bt_Callback(hObject, eventdata, handles)
% hObject    handle to next_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

compt=1;
setappdata(gcf,'compt_events',compt);
setappdata(gcf,'selected_event',[]);
x=getappdata(gcbf,'signal');
n=getappdata(gcbf,'valeur_de_n');
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
axes(handles.axes1);
cla;
 n=n+1;
wn=[1 45];
t=(0:N-1)/fs;
 yfilt=filter_fir(x{n},wn,80,fs);
 plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'valeur_de_n',n);
 % R�cuparation des limites du graphique
x = xlim;
y = ylim;
setappdata(gcf,'xlim',x);
setappdata(gcf,'ylim',y);
line([x(1) x(1)],y(:), 'linewidth',2.5,'color','b','buttondownfcn',@bdfcn);
line([x(2) x(2)],y(:), 'linewidth',2.5,'color','r','buttondownfcn',@bdfcn);
 % Blocage des limites du graphique
set(gca,'xlimmode','manu');
set(handles.nseg,'string',int2str(n));

axes(handles.axes2);cla;
set(handles.axes2,'visible','off');
setappdata(gcf,'scalo_etat',0);  set(handles.scalo_bt,'String','Show scalogram');  
set(handles.next_previous_panel,'position',[0.3586326767091541 0.3607784431137725  0.24971031286210899 0.07185628742514968]);
set(handles.choose_panel,'position',[0.7809965237543453 0.22155688622754494  0.2033603707995365 0.2125748502994012]); 
setappdata(gcf,'scalo_etat',0); 

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


% --- Executes on button press in validate_bt.
function validate_bt_Callback(hObject, eventdata, handles)
% hObject    handle to validate_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etatkp= get(handles.Kcomplex_rad,'Value');
etatsp= get(handles.Spindles_rad,'Value');

scorer=getappdata(gcbf,'name');

subj_name=getappdata(gcbf,'sb_name');

if etatkp==1
    axes(handles.axes1);    
% R�cup�ration de l'identigfiant de la barre bleue
h(1) = findobj('type','line','linewidth',2.5,'color','b');
% R�cup�ration de l'identigfiant de la barre rouge
h(2) = findobj('type','line','linewidth',2.5,'color','r');
% R�cup�ration des position en x des deux barres
xmin = get(h(1),'xdata');
xmax = get(h(2),'xdata');
trace=line([xmin(1),xmax(1)],[100,100],'color','k','linewidth',1.5);
setappdata(gcf,'trace',trace);
n=getappdata(gcbf,'valeur_de_n');
M=[xmin(1) xmax(1)];
file_name=['Kcomplex_visual_score_by_' scorer '_for_' subj_name '.txt'];
fid=fopen(file_name,'a+');
   fprintf(fid,'\n %s %d %d',int2str(n),M.');
fclose(fid);
elseif etatsp==1
axes(handles.axes1);
h(1) = findobj('type','line','linewidth',2.5,'color','b');
% R�cup�ration de l'identigfiant de la barre verte
h(2) = findobj('type','line','linewidth',2.5,'color','r');
% R�cup�ration des position en x des deux barres
xmin = get(h(1),'xdata');
xmax = get(h(2),'xdata');
trace=line([xmin(1),xmax(1)],[50,50],'color',[0 0.5 0],'linewidth',1.5);%[0.749,0.749,0.0]
setappdata(gcf,'trace',trace);
n=getappdata(gcbf,'valeur_de_n');
M=[xmin(1) xmax(1)];
file_name=['Spindles_visual_score_by_' scorer '_for_' subj_name  '.txt'];
fid=fopen(file_name,'a+');
fprintf(fid,'\n %s %d %d',int2str(n),M.');
fclose(fid);
else
    errordlg('Please select event','Event selection Error');
end

% --- Executes on button press in cancel_bt.
function cancel_bt_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in goto_bt.
function goto_bt_Callback(hObject, eventdata, handles)
% hObject    handle to goto_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

compt=1;
setappdata(gcf,'compt_events',compt);
setappdata(gcf,'selected_event',[]);
x=getappdata(gcbf,'signal');

n= str2double(get(handles.nseg, 'string'));
            
fs=getappdata(gcbf,'fs');
N=getappdata(gcbf,'N');
axes(handles.axes1);
cla;

wn=[1 45];
t=(0:N-1)/fs;
 yfilt=filter_fir(x{n},wn,80,fs);
 plot(t,yfilt);grid on;axis([0 N/fs -250 250]);
setappdata(gcf,'valeur_de_n',n);
 % R�cuparation des limites du graphique
x = xlim;
y = ylim;
setappdata(gcf,'xlim',x);
setappdata(gcf,'ylim',y);
line([x(1) x(1)],[y(:)], 'linewidth',2.5,'color','b','buttondownfcn',@bdfcn);
line([x(2) x(2)],[y(:)], 'linewidth',2.5,'color','r','buttondownfcn',@bdfcn);
 % Blocage des limites du graphique
set(gca,'xlimmode','manu')
set(handles.nseg,'string',int2str(n));
axes(handles.axes2);cla;
set(handles.axes2,'visible','off');
setappdata(gcf,'scalo_etat',0);  set(handles.scalo_bt,'String','Show scalogram');  
set(handles.next_previous_panel,'position',[0.3586326767091541 0.3607784431137725  0.24971031286210899 0.07185628742514968]);
set(handles.choose_panel,'position',[0.7809965237543453 0.22155688622754494  0.2033603707995365 0.2125748502994012]); 
setappdata(gcf,'scalo_etat',0); 


% --- Executes on button press in scalo_bt.
function scalo_bt_Callback(hObject, eventdata, handles)
% hObject    handle to scalo_bt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=getappdata(gcbf,'signal');
n=getappdata(gcbf,'valeur_de_n');
fs=getappdata(gcbf,'fs'); N=getappdata(gcbf,'N');
scalo=getappdata(gcbf,'scalo_etat');
if scalo==0
 setappdata(gcf,'scalo_etat',1);  set(handles.scalo_bt,'String','Hide scalogram');  
 set(handles.axes2,'visible','on');
 axes(handles.axes2);cla;
 
t=(0:N-1)/fs;
sc=1./((10.5:0.15:16.5)/fs); %selon AASM sleep spindles dans la bande [11 16]
wname='fbsp 20-0.5-1';  %;% 'cmor2-1.114''shan 0.5-1'
W=cwt(x{n},sc,wname);

freq= scal2frq(sc,wname,1/fs);
        % wscalogram('image',W,'scales',freq);colormap(jet)
imagesc(t,freq,abs(W));colormap(jet);freezeColors; set(gca, 'XTick', []);  
set(handles.next_previous_panel,'position',[0.3586326767091541 0.1796407185628742 0.24971031286210899 0.07185628742514968]);
set(handles.choose_panel,'position',[0.7809965237543453 0.037425149700598806 0.2033603707995365 0.2125748502994012]);

else
     axes(handles.axes2);cla;
     set(handles.axes2,'visible','off');
    setappdata(gcf,'scalo_etat',0);  set(handles.scalo_bt,'String','Show scalogram');  
   set(handles.next_previous_panel,'position',[0.3586326767091541 0.3607784431137725  0.24971031286210899 0.07185628742514968]);
set(handles.choose_panel,'position',[0.7809965237543453 0.22155688622754494  0.2033603707995365 0.2125748502994012]); 
     setappdata(gcf,'scalo_etat',0); 
end
