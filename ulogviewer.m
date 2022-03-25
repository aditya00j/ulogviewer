function varargout = ulogviewer(varargin)
% ULOGVIEWER MATLAB code for ulogviewer.fig
%      ULOGVIEWER, by itself, creates a new ULOGVIEWER or raises the existing
%      singleton*.
%
%      H = ULOGVIEWER returns the handle to a new ULOGVIEWER or the handle to
%      the existing singleton*.
%
%      ULOGVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULOGVIEWER.M with the given input arguments.
%
%      ULOGVIEWER('Property','Value',...) creates a new ULOGVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ulogviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ulogviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ulogviewer

% Last Modified by GUIDE v2.5 08-Dec-2020 12:35:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ulogviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @ulogviewer_OutputFcn, ...
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


% --- Executes just before ulogviewer is made visible.
function ulogviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ulogviewer (see VARARGIN)

% Choose default command line output for ulogviewer
handles.output = hObject;

% REPLACE this with the location of your installed ulog2csv binary
handles.ulog2csv = '/opt/anaconda3/bin/ulog2csv';

handles.data = struct;
handles.messages = {};
handles.fields = struct;
handles.temp_dir = '';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ulogviewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ulogviewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonSelect.
function buttonSelect_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('*.ulg');
if file
    
    % Delete existing csv files in temp directory
    temp_dir = [path '/temp'];
    handles.temp_dir = temp_dir;
    
    all_files = dir(fullfile(temp_dir, '*.csv'));
    for k = 1 : length(all_files)
        filename = all_files(k).name;
        full_filename = fullfile(temp_dir, filename);
        fprintf(1, 'Deleting %s\n', filename);
        delete(full_filename);
    end
    
    full_file = [path file];
    set(handles.textFilename,'String',file);
    orig_file = strrep(file,'.ulg','');
    
    fprintf('Reading %s... ', full_file);
    sys_cmd = [handles.ulog2csv ' -o' temp_dir ' ' full_file];
    system(sys_cmd);
    disp('done');
    
    % read all CSV files
    all_files = dir(fullfile(temp_dir, '*.csv'));
    handles.data = struct;
    handles.messages = cell(length(all_files),1);
    handles.fields = struct;
    for k = 1:length(all_files)
        
        filename = all_files(k).name;

        % Get message name
        message = strrep(filename, '.csv','');
        message = strrep(message, strcat(orig_file,'_'),'');
        
        handles.messages{k} = message;
        full_filename = fullfile(temp_dir, filename);
        this_table = readtable(full_filename);
        handles.data.(message) = this_table;
        
        % Get field names
        this_fields = this_table.Properties.VariableNames;
        
        % First field is 'timestamp', remove it from list
        handles.fields.(message) = this_fields(2:end);
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Update message list
    set(handles.listMessages,'String',handles.messages);
    set(handles.listMessages,'Value',1);
    
    listMessages_Callback(handles.listMessages, eventdata, handles);
    
end


% --- Executes on button press in buttonHold.
function buttonHold_Callback(hObject, eventdata, handles)
% hObject    handle to buttonHold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of buttonHold


% --- Executes on button press in buttonPlot.
function buttonPlot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

this_message = handles.messages{get(handles.listMessages,'Value')};
this_data = handles.data.(this_message);
xdata = this_data.timestamp/1e6;

idx = get(handles.listFields,'Value');
this_fields = get(handles.listFields,'String');
ydata = cell(length(idx),1);
ynames = cell(length(idx),1);
for i = 1:length(idx)
    ydata{i} = this_data.(this_fields{idx(i)});
    ynames{i} = strcat(this_message,'.',this_fields{idx(i)});
end

if (~get(handles.buttonHold,'Value'))
    cla(handles.plotAxes)
end

hold(handles.plotAxes,'on')
for i = 1:length(ydata)
    plot(handles.plotAxes,xdata,ydata{i},'DisplayName',strrep(ynames{i},'_','\_'));
end
    


% --- Executes on button press in buttonClear.
function buttonClear_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.plotAxes)


% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h0 = get(gcf,'CurrentAxes');
hc = get(h0,'Children');
figure; ha = axes; grid on; box on
copyobj(hc,ha);
xlabel(get(get(h0,'xlabel'),'string'))
ylabel(get(get(h0,'ylabel'),'string'))


% --- Executes on selection change in listMessages.
function listMessages_Callback(hObject, eventdata, handles)
% hObject    handle to listMessages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listMessages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listMessages
contents = cellstr(get(hObject,'String'));
this_message = contents{get(hObject,'Value')};
set(handles.listFields, 'String', handles.fields.(this_message));
set(handles.listFields, 'Value', 1);



% --- Executes during object creation, after setting all properties.
function listMessages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listMessages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listFields.
function listFields_Callback(hObject, eventdata, handles)
% hObject    handle to listFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listFields contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFields


% --- Executes during object creation, after setting all properties.
function listFields_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Delete existing csv files in temp directory

if handles.temp_dir
    rmdir(handles.temp_dir,'s');
end
