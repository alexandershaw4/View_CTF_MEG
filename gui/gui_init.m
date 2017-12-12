function varargout = gui_init(varargin)
% A MATLAB implementation of DataEditor for viewing CFT MEG datasets [.ds]
%
% Permits marking of BAD trials and writing to markerfile.
%
% Backend is my lightweight reader function 'CTF_ViewLight'.
%
% AS17


% Edit the above text to modify the response to help gui_init

% Last Modified by GUIDE v2.5 03-Apr-2017 15:19:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_init_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_init_OutputFcn, ...
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


% --- Executes just before gui_init is made visible.
function gui_init_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_init (see VARARGIN)

% Choose default command line output for gui_init
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_init wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_init_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

contents = cellstr(get(hObject,'String'));
trial = contents{get(hObject,'Value')};
%if isempty(trial);
%    trial = 1;
%end
tr_id = find(strcmp(handles.Markers.marker_names,trial));
handles.tr_id = tr_id;

thesetrials = handles.Markers.trial_times{tr_id};
thesetrials = thesetrials(:,1);
thesebad    = handles.BAD(thesetrials);

handles.current.thesetrials = thesetrials;
handles.current.thesebad = thesebad;

plotdata = handles.Data(:,:,thesetrials);
handles.plotdata = plotdata;


% FIGURE:
[handles.nch,nsamp,handles.ntr] = size(plotdata);
handles.ind  = 1;
handles.SCALE = 1;

set(handles.slider1, 'Min', 1);
set(handles.slider1, 'Max', handles.ntr);
set(handles.slider1, 'Value', 1);
set(handles.slider1, 'SliderStep', [1/handles.ntr , 10/handles.ntr ]);

set(handles.slider2, 'Min', 1);
set(handles.slider2, 'Max', 6);
set(handles.slider2, 'Value', 1);
set(handles.slider2, 'SliderStep', [1/6 , 10/6]);


guidata(hObject, handles);


% do plot (bushbutton 2)



% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get Dir
handles.Dataset = uigetdir('pwd','Select CTF .ds Dataset');

% Load Data & Info
[handles.Data,handles.times,handles.Markers,handles.D,handles.info] = ...
    CTF_ViewLight(handles.Dataset);

% Get marker names
Mrks = handles.Markers.marker_names;

% update trials listbox
set(handles.listbox1, 'String', Mrks)

% get bad indices
BAD  = find(strcmp(Mrks,'BAD'));
try
    BADi = handles.Markers.trial_times{BAD};
    BADi = BADi(:,1);
catch
    % if there aren't any bad, YET!
    BADi = [];
end
BAD  = zeros(1,size(handles.Data,3))';
handles.BAD = BAD;
handles.BAD(BADi) = 1;

% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

TRL = get(hObject,'Value');
handles.ind = round(TRL);

set(handles.radiobutton1,'Value',handles.current.thesebad(round(TRL)));

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% plot / update plot
% for i = 1:handles.nch
%         tmp_s = max( handles.plotdata(i,:,round(handles.ind)) );
%         scl(i) = tmp_s*1.2;
%         if i > 1; scl(i) = scl(i) + scl(i-1); end
% end

%if no trial clcked on, assume 1
% try handles.ind;
% catch
%     handles.ind = 1;
%     listbox1_Callback(hObject, eventdata, handles)
% end

MEGid = handles.info.MEGid;
EEGid = handles.info.EEGid;

prewhite = TSNorm(squeeze(handles.plotdata(:,:,round(handles.ind))),1,1,1);
prewhite(isnan(prewhite)) = 0;

for i = 1:handles.nch
    this = (i)+(handles.SCALE*squeeze(prewhite(i,:)));
    if any(this);    
        if     any(ismember(MEGid,i)); col = 'b';
        elseif any(ismember(EEGid,i)); col = 'g';
        else                           col = 'k';
        end
        plot(handles.times,this,col);hold on;
    end
end
ylim([1 handles.nch]);
CH = cellstr(handles.info.Labels);
set(gca,'YTick',1:length(CH),'YTickLabel',CH);
xlabel('Time (s)');
title(sprintf('Trial %d of %d for trial type %s',round(handles.ind),...
    handles.ntr,handles.Markers.marker_names{handles.tr_id}));
hold off;

guidata(hObject, handles);


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
SCALE = get(hObject,'Value');
handles.SCALE = round(SCALE);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

% BAD trial flag
isbad = get(hObject,'Value');
handles.current.thesebad(handles.ind) = isbad;
handles.BAD(handles.current.thesetrials) = handles.current.thesebad;


guidata(hObject, handles);



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% SAVE bad trial defs 
BAD  = find(strcmp(handles.Markers.marker_names,'BAD')); % re find bad trial class
handles.Markers.trial_times{BAD} = handles.BAD;

% now put these into the mrk structure .mrk
BADi  = find(strcmp({handles.D.mrk.Name},'BAD'));
handles.D.mrk(BADi).trial = unique(find( handles.Markers.trial_times{BAD} ))';
handles.D.mrk(BADi).time = zeros(1,length(handles.D.mrk(BADi).trial));

writeMarkerFile('MarkerFile.mrk',handles.D.mrk)
