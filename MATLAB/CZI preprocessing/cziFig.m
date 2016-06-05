function varargout = cziFig(varargin)
% CZIFIG MATLAB code for cziFig.fig
%      CZIFIG, by itself, creates a new CZIFIG or raises the existing
%      singleton*.
%
%      H = CZIFIG returns the handle to a new CZIFIG or the handle to
%      the existing singleton*.
%
%      CZIFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CZIFIG.M with the given input arguments.
%
%      CZIFIG('Property','Value',...) creates a new CZIFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cziFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cziFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cziFig

% Last Modified by GUIDE v2.5 30-May-2016 21:35:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cziFig_OpeningFcn, ...
                   'gui_OutputFcn',  @cziFig_OutputFcn, ...
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


% --- Executes just before cziFig is made visible.
function cziFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cziFig (see VARARGIN)

% Choose default command line output for cziFig
handles.output = hObject;

dummy = [mfilename('fullpath') '.m'];
currdir = fileparts(dummy);
funcPath = [currdir filesep '..'];
addpath(genpath(currdir));
addpath(funcPath);

handles.params.date = '230514';
handles.params.embryoNumber = 1;
handles.params.cutStartX = 1;
handles.params.cutStartY = 1;
handles.params.cutEndX = 50;
handles.params.cutEndY = 50;
handles.params.pixelSize = 1;
handles.params.frameTime = 1;
handles.params.kymSpacing = 1;

handles.params.dir = [0 1]; % up

set(handles.axImage, 'XTick', []);
set(handles.axImage, 'YTick', []);

updateUIParams(handles.params)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cziFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cziFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function updateUIParams(params)
    
handles = guidata(gcf);

set(handles.txtDate, 'String', params.date);
set(handles.txtENumber, 'String', num2str(params.embryoNumber));
set(handles.txtPixelSize, 'String', num2str(params.pixelSize));
set(handles.txtFrameTime, 'String', num2str(params.frameTime));
set(handles.txtStartX, 'String', num2str(params.cutStartX));
set(handles.txtEndX, 'String', num2str(params.cutEndX));
set(handles.txtStartY, 'String', num2str(params.cutStartY));
set(handles.txtEndY, 'String', num2str(params.cutEndY));
set(handles.txtKymSpacingUm, 'String', num2str(params.kymSpacing));

guidata(gcf, handles);
 
% --- handle errors. 
function errorHandler(ME)

if ischar(ME)
    uiwait(errordlg(ME, 'Error!', 'modal'));
else
    uiwait(errordlg(ME.message, 'Error!', 'modal'));
    rethrow(ME);
end

% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
disp('nsda');



% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonGenerateKym.
function buttonGenerateKym_Callback(hObject, eventdata, handles)
% hObject    handle to buttonGenerateKym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

% ensure that visualised cut position corresponds properly with underlying
% data
xy = handles.cutLine.getPosition();

handles.params.cutStartX = round(xy(1,1));
handles.params.cutEndX = round(xy(2,1));
handles.params.cutStartY = round(xy(1,2));
handles.params.cutEndY = round(xy(2,2));


initialString = get(hObject, 'String');
set(hObject, 'String', 'Working...');
set(hObject, 'Enable', 'off');
drawnow;

% check all fields are filled in sensibly...

% generate image data in expected format
fcell = get(handles.txtImagePath, 'String');
data = bfopen(fcell{1});
omeMeta = data{1,4};
data = data{1}(1:2:end,1);
newshape = [size(data{1}, 1), length(data), size(data{1}, 2)];
data = cell2mat(data);
data = reshape(data, newshape);
stack = permute(data, [1 3 2]);

% pad 100 pixels on each side...
newstack = zeros(size(stack, 1) + 200, size(stack, 2) + 200, size(stack, 3));
newstack(100:99 + size(stack, 1), 100:99 + size(stack, 2), :) = stack;
stack = newstack;
clear newstack;

% get (OME) metadata from data
curr_metadata = getMetadataFromOME(omeMeta, handles.params);
curr_metadata.acqMetadata.cycleTime = str2num(get(handles.txtFrameTime, 'String'));

clear data;

userOptions = getUserOptions(handles);

%DEBUG w/SMALL MEDIAN FILTER
userOptions.medianFiltKernelSize = 9;
userOptions.showKymographOverlapOverlay = false;
userOptions.kymSpacingUm = str2double(get(handles.txtKymSpacingUm, 'String'));


for dind = handles.params.dir
    
    userOptions.kymDownOrUp = dind;
    
    %% Pre-process images in stack
    curr_metadata.kym_region = placeKymographs(curr_metadata, userOptions);
    [trim_stack, curr_metadata] = kymographPreprocessing(stack, curr_metadata, userOptions);

    %% Plot and save kymographs
    kymographs = plotAndSaveKymographsSlow(trim_stack, curr_metadata, userOptions);
    results = extractQuantitativeKymographData(kymographs, curr_metadata, userOptions);

end


set(hObject, 'String', initialString);
set(hObject, 'Enable', 'on');

function userOptions = getUserOptions(handles)

    userOptions = UserOptions();
    userOptions.outputFolder = get(handles.txtSaveRoot, 'String');

    


% --- Executes on button press in buttonBrowseImagePath.
function buttonBrowseImagePath_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

[fname, pname, ~] = uigetfile('*.czi');

set(handles.txtImagePath, 'String', [pname fname]);
imagePathChanged({[pname fname]}, hObject);

handles.cutLine = imline(handles.axImage, [handles.params.cutStartX handles.params.cutEndX], ...
            [handles.params.cutStartY handles.params.cutEndY]);
set(handles.cutLine, 'ButtonDownFcn', {@cutLine_ButtonDownFcn, handles})

addNewPositionCallback(handles.cutLine,@updateLinePos);

% Update handles structure
guidata(hObject, handles);


function txtImagePath_Callback(hObject, eventdata, handles)
% hObject    handle to txtImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtImagePath as text
%        str2double(get(hObject,'String')) returns contents of txtImagePath as a double
% Choose default command line output for cziFig
handles = guidata(gcf);

input = get(hObject,'String');
display(input);

imagePathChanged(input, hObject);

handles.cutLine = imline(handles.axImage, [handles.params.cutStartX handles.params.cutEndX], ...
            [handles.params.cutStartY handles.params.cutEndY]);
set(handles.cutLine, 'ButtonDownFcn', {@cutLine_ButtonDownFcn, handles})

addNewPositionCallback(handles.cutLine,updateLinePos);

% Update handles structure
guidata(hObject, handles);

% --- handles changes to image path independently of source of change. 
function imagePathChanged(new_image_path, hObject)
handles = guidata(gcf);

% check that new image path is a character string, anc dialog hasn't been
% cancelled
if ischar(new_image_path)

    % make sure UI reflects underlying data
    set(handles.txtImagePath, 'String', new_image_path);

    % check that path is a .czi file
    [~,~,ext] = fileparts(new_image_path{1});
    if ~strcmp(ext, '.czi')
        errorHandler('Image must be CZI format!');
    else
        try
            % load first frame to image preview pane
    %         data = bfopen(new_image_path{1});
    %         omeMeta = data{1,4};
    %         im = data{1}{1};
            % don't load whole series yet...
            reader = bfGetReader(new_image_path{1});
            omeMeta = reader.getMetadataStore();
            im = bfGetPlane(reader, 1);
            padim = zeros(size(im, 1)+200, size(im, 2)+200);
            padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
            im = padim;
            clear padim; 

            imagesc(im);
            colormap gray;
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);

            % figure out and populate default parameters
            handles.params.pixelSize = double(omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
            handles.params.frameTime = double(omeMeta.getPlaneDeltaT(0, 1).value()) - double(omeMeta.getPlaneDeltaT(0, 0).value());
    %         guidata(hObject, handles);
            updateUIParams(handles.params);


        catch ME
            errorHandler(ME);

        end

    end

end
    
% Update handles structure
guidata(hObject, handles);


function cutLine_ButtonDownFcn(hObject, eventdata, handles)
% handles = guidata(gcf);
disp('button down!');
   

% --- Executes during object creation, after setting all properties.
function txtImagePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtDate_Callback(hObject, eventdata, handles)
% hObject    handle to txtDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDate as text
%        str2double(get(hObject,'String')) returns contents of txtDate as a double


% --- Executes during object creation, after setting all properties.
function txtDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtENumber_Callback(hObject, eventdata, handles)
% hObject    handle to txtENumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtENumber as text
%        str2double(get(hObject,'String')) returns contents of txtENumber as a double


% --- Executes during object creation, after setting all properties.
function txtENumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtENumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtFrameTime_Callback(hObject, eventdata, handles)
% hObject    handle to txtFrameTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFrameTime as text
%        str2double(get(hObject,'String')) returns contents of txtFrameTime as a double


% --- Executes during object creation, after setting all properties.
function txtFrameTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFrameTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to txtPixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPixelSize as text
%        str2double(get(hObject,'String')) returns contents of txtPixelSize as a double


% --- Executes during object creation, after setting all properties.
function txtPixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSaveRoot_Callback(hObject, eventdata, handles)
% hObject    handle to txtSaveRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSaveRoot as text
%        str2double(get(hObject,'String')) returns contents of txtSaveRoot as a double


% --- Executes during object creation, after setting all properties.
function txtSaveRoot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSaveRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonBrowseSaveRoot.
function buttonBrowseSaveRoot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

filename = get(handles.txtImagePath, 'String');
filename = filename{1};
[default_folder ,~,~] = fileparts(filename) 
pname = uigetdir(default_folder);

set(handles.txtSaveRoot, 'String', pname);

% Update handles structure
guidata(hObject, handles);


function txtStartX_Callback(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStartX as text
%        str2double(get(hObject,'String')) returns contents of txtStartX as a double

handles = guidata(gcf);
% handles.params.cutStartX = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(1,1) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtStartX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtStartY_Callback(hObject, eventdata, handles)
% hObject    handle to txtStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStartY as text
%        str2double(get(hObject,'String')) returns contents of txtStartY as a double
handles = guidata(gcf);
% handles.params.cutStartY = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(1,2) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtStartY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtEndX_Callback(hObject, eventdata, handles)
% hObject    handle to txtEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtEndX as text
%        str2double(get(hObject,'String')) returns contents of txtEndX as a double
handles = guidata(gcf);
% handles.params.cutEndX = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(2,1) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtEndX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtEndY_Callback(hObject, eventdata, handles)
% hObject    handle to txtEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtEndY as text
%        str2double(get(hObject,'String')) returns contents of txtEndY as a double
handles = guidata(gcf);
% handles.params.cutEndY = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(2,2) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtEndY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSelectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to menuSelectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axImage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtStartX.
function txtStartX_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
set(handles.txtStartX, 'Enable', 'on');

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtEndX.
function txtEndX_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
set(handles.txtEndX, 'Enable', 'on');

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtStartY.
function txtStartY_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
set(handles.txtStartY, 'Enable', 'on');

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtEndY.
function txtEndY_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- Executes when selected object is changed in panelKymDir.
function panelKymDir_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelKymDir 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radioUp'
        handles.params.dir = 1;
    case 'radioDown'
        handles.params.dir = 0;
    case 'radioBoth'
        handles.params.dir = [0 1];
    
end


function updateLinePos(hObject, eventdata)

disp(hObject)

handles = guidata(gcf);

set(handles.txtStartX, 'String', num2str(hObject(1)));
set(handles.txtEndX, 'String', num2str(hObject(2)));
set(handles.txtStartY, 'String', num2str(hObject(3)));
set(handles.txtEndY, 'String', num2str(hObject(4)));



function txtKymSpacingUm_Callback(hObject, eventdata, handles)
% hObject    handle to txtKymSpacingUm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtKymSpacingUm as text
%        str2double(get(hObject,'String')) returns contents of txtKymSpacingUm as a double



% --- Executes during object creation, after setting all properties.
function txtKymSpacingUm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtKymSpacingUm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
