function varargout = viewerMain(varargin)
% VIEWERMAIN MATLAB code for viewerMain.fig
%      VIEWERMAIN, by itself, creates a new VIEWERMAIN or raises the existing
%      singleton*.
%
%      H = VIEWERMAIN returns the handle to a new VIEWERMAIN or the handle to
%      the existing singleton*.
%
%      VIEWERMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWERMAIN.M with the given input arguments.
%
%      VIEWERMAIN('Property','Value',...) creates a new VIEWERMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewerMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewerMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewerMain

% Last Modified by GUIDE v2.5 28-Mar-2016 16:35:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewerMain_OpeningFcn, ...
                   'gui_OutputFcn',  @viewerMain_OutputFcn, ...
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


% --- Executes just before viewerMain is made visible.
function viewerMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewerMain (see VARARGIN)

handles.softwareVersion = 1.0;

% Choose default command line output for viewerMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

dummy = [mfilename('fullpath') '.m'];
currdir = fileparts(dummy);
funcPath = [currdir filesep '..'];
addpath(genpath(currdir));
addpath(funcPath);

javaaddpath([currdir filesep 'Archive' filesep 'jxl.jar']);
javaaddpath([currdir filesep 'Archive' filesep 'MXL.jar']);
    
set(handles.axUpFirstFrame, 'XTick', []);
set(handles.axDownFirstFrame, 'XTick', []);
set(handles.axUpFirstFrame, 'YTick', []);
set(handles.axDownFirstFrame, 'YTick', []);

xlab = 'Kymograph position along cut, \mum';
ylab = 'Membrane speed, \mum s^{-1}';

xlabel(handles.axUpSpeedVPosition, xlab);
ylabel(handles.axUpSpeedVPosition, ylab);
xlabel(handles.axDownSpeedVPosition, xlab);
ylabel(handles.axDownSpeedVPosition, ylab);

handles.manualSpeeds = [];

handles.linTexpF = true;
set(handles.menuExpFit,'Enable','off');

handles.kymAxisThickness = 1;

guidata(hObject, handles);

% UIWAIT makes viewerMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewerMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuLoadData_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

default_folder = 'C:\Users\Doug\Documents\DOug- cuts\Processed data 20160314\080316 apical surface distance values\Apical';
if ~isfield(handles, 'baseFolder')
    sf = default_folder;
else
    if ischar(handles.baseFolder)
        sf = handles.baseFolder;
    else
        sf = default_folder;
    end
end

base_folder = uigetdir(sf, 'Choose the base folder to populate the data list...');

if ~isequal(base_folder, 0)
    dataList = cell(0);
    handles.baseFolder = base_folder;

    folders = dir([base_folder filesep '*Embryo*']);
    pattern = ' (down|up)?wards';
    a = regexp({folders.name},pattern, 'split');
    
    for ind = 1:length(a)
        b(ind) = a{ind}(1);
    end
    
    [~,ia,~] = unique(b);
    
    folders = folders(ia);

    for fInd = 1:length(folders)

        s = dir([base_folder filesep folders(fInd).name filesep 'trimmed_cutinfo_cut_*.txt']);

        for cInd = 1:length(s)

            cutNumber = sscanf(s(cInd).name, 'trimmed_cutinfo_cut_%d.txt');
            ex = '(?<date>\d+), Embryo (?<embryoNumber>\w+) (up|down)?wards';
            out = regexp(folders(fInd).name, ex, 'names');

            dataList = [dataList; cellstr(sprintf('Date = %s, Embryo = %s, Cut = %d', ...
                out.date, out.embryoNumber, cutNumber))];

        end

    end

    exps = dir([base_folder filesep folders(1).name filesep '*exponential*']);
    if ~isempty(exps)
        set(handles.menuExpFit,'Enable','on');
    end
    
    set(handles.listData, 'String', dataList);

    guidata(hObject, handles);

    %% Fire selection event for first item in list
    if ~isempty(dataList)
        set(handles.listData, 'Value', 1);
        callback = get(handles.listData, 'Callback');
        callback(handles.listData, []);
    end
end

% guidata(hObject, handles);
        
% --- Executes on selection change in listData.
function listData_Callback(hObject, eventdata, handles)
% hObject    handle to listData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'manualLine')
    if ~isempty(handles.manualLine)
        delete(handles.manualLine);
    end
end

contents = cellstr(get(hObject,'String')); % returns listData contents as cell array
selected = contents{get(hObject,'Value')}; % returns selected item from listData
disp(selected);
%% start busy
busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');
butDownFcn = {@axUpSpeedVPosition_ButtonDownFcn, handles};
butDownFcns = repmat(butDownFcn, 1, 4);
disableEnableOnClick([handles.axDownSpeedVPosition; handles.axUpSpeedVPosition]);


%% Get and plot speed vs position
ex = 'Date = (?<date>\w+), Embryo = (?<embryoNumber>\w+), Cut = (?<cutNumber>\d+)';
s = regexp(selected, ex, 'names');
dt = s.date;
embryoNumber = s.embryoNumber;
cutNumber = s.cutNumber;

if handles.linTexpF
    expTxt = '';
    expTxt2 = ', S';
else
    expTxt = ' exponential fit';
    expTxt2 = ', exponential s';
end

handles.date = dt;
handles.cutNumber = cutNumber;
handles.embryoNumber = embryoNumber;

axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
titleAppendices = {['upwards' expTxt]; ['downwards' expTxt]};

% buttonDownFcns = {{@axUpSpeedVPosition_ButtonDownFcn, handles};...
%     {@axDownSpeedVPosition_ButtonDownFcn, handles}};

try
    for ind = 1:length(axHandles)

        figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber expTxt2 'peed against cut position upwards' expTxt '.fig']);...
            cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber expTxt2 'peed against cut position downwards' expTxt '.fig'])];


        axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
    
        fpath = figFilePaths{ind};
        
        h = openfig(fpath, 'new', 'invisible');
        ax = get(h, 'Children');
        dataObjs = get(ax, 'Children');
        handles.speeds{ind} = get(dataObjs, 'YData');
        handles.poss{ind} = get(dataObjs, 'XData');

        handles.plotHandles{ind} = plot(axHandles(ind), handles.poss{ind}, handles.speeds{ind}, 'x-');
        xlab = 'Kymograph position along cut, \mum';
        ylab = 'Membrane speed, \mum s^{-1}';
        xlabel(axHandles(ind), xlab);
        ylabel(axHandles(ind), ylab);
        title(axHandles(ind), sprintf('%s, Embryo %s, Cut %s, %s', dt, embryoNumber, cutNumber, titleAppendices{ind}));
        
    end
catch ME
    disp(ME)
    uiwait(msgbox(['No figure to load at ' fpath]));   
    axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
    handles.plotHandles{ind} = plot([1,2,3,4,5], zeros(1,5),'Parent',axHandles(ind));
end
        %% Get and plot first frames and relevant lines
try
        figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', 5 s pre-cut upwards.fig']);...
            cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', 5 s pre-cut downwards.fig'])];

        axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];
        handles.kymLines = [];

        for ind = 1:length(axHandles)

            fpath = figFilePaths{ind};

            h = openfig(fpath, 'new', 'invisible');
            ax = get(h, 'Children');
            dataObjs = get(ax, 'Children');
            im = get(dataObjs(end), 'CData');

            imH = imagesc(im, 'Parent', axHandles(ind));
            colormap(axHandles(ind), gray)

            set(axHandles(ind), 'XTick', []);
            set(axHandles(ind), 'YTick', []);

            %% scale bar...
            sc_line_x = get(dataObjs(2), 'XData');
            sc_line_y = get(dataObjs(2), 'YData');
            line(sc_line_x, sc_line_y, 'Parent', axHandles(ind), 'Color', 'w', ...
                'LineWidth', 3);
            handles.umPerPixel = 20/diff(sc_line_x); %  ASSUMES SCALE BAR IS ALWAYS 20!

            %% cut line...
            cut_line_x = get(dataObjs(end-1), 'XData');
            cut_line_y = get(dataObjs(end-1), 'YData');
            line(cut_line_x, cut_line_y, 'Parent', axHandles(ind), 'Color', 'b', ...
                'LineWidth', 2);

            %% kymograph lines...   
            kym_lines = zeros(1,length(dataObjs)-4);
            x = [kym_lines; kym_lines];
            y = x;
            for lInd = 3:(length(dataObjs)-2)
        %         for lInd = 3:(length(dataObjs)-2)
                x(:,lInd-2) = get(dataObjs(lInd), 'XData')';
                y(:,lInd-2) = get(dataObjs(lInd), 'YData')';
                kym_lines(lInd-2) = line(get(dataObjs(lInd), 'XData'), get(dataObjs(lInd), 'YData'), ...
                    'Parent', axHandles(ind), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
            end


            offset = handles.umPerPixel * sqrt((x(1,1) - cut_line_x(1))^2 + (y(1,1) - cut_line_y(1))^2);
            handles.positionsAlongLine = (-handles.umPerPixel * sqrt((x(1,end) - x(1,:)).^2 + (y(1,end) - y(1,:)).^2) + offset);
            baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
            folder = [baseFolder2 ' downwards'];
            mdfpath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
            handles.positionsAlongLine = getKymPosMetadataFromText(mdfpath);    
            handles.zoomBoxLTBR(ind,:) = [min(x(:)) min(y(:)) max(x(:)) max(y(:))];

        %     %% find which attempted kymograph lines are represented in results
        %     plotPos = round(100*handles.poss{ind})/100;
        %     drawnPos = round(100*handles.positionsAlongLine)/100;
        %     [~,~,included] = intersect(plotPos, drawnPos);
        %     toRemove = 1:length(kym_lines);
        %     toRemove(included)=[];
        %     delete(kym_lines(toRemove));

            handles.kymLines(ind,:) = fliplr(kym_lines);

            set(imH, 'UIContextMenu', handles.menuPreCutFig);
            set(handles.menuZoomToggle, 'Checked', 'off')
%             catch
%                 msgbox(['No figure to load at ' fpath]);
%             end
        end
    
catch ME
    disp(ME)
    uiwait(msgbox(['No figure to load at ' fpath]));   
    axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];
    imagesc(zeros(5),'Parent',axHandles(ind));

end
            

      
% Load distance from apical surface for current cut
fname = [handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep ...
    'trimmed_cutinfo_cut_' cutNumber '.txt' ];
varn = 'metadata.distanceToApicalSurface';
try
    handles.currentApicalSurfaceToCutDistance = getNumericMetadataFromText(fname, varn);
catch
    handles.currentApicalSurfaceToCutDistance = NaN;
end


%% end busy
busyDlg(busyOutput);
tempHand = [handles.axDownSpeedVPosition; handles.axUpSpeedVPosition];
for ind = 1:length(handles.plotHandles)
    tempHand = [tempHand; handles.plotHandles{ind}];
end

disableEnableOnClick(tempHand, butDownFcns);

set(handles.listData, 'Enable', 'on');
close(h);

cla(handles.axUpSelectedKym, 'reset');
cla(handles.axDownSelectedKym, 'reset');

% TODO: add function, broken out from callback, to allow checking whether
% data has already been added to the list to be exported - upon this, we
% can base the coloring of the title and the checked state in the UI menu. 
set(handles.menuInclude, 'checked', 'off');
% 
figs = get(0,'children');
figs(figs == handles.figure1) = []; % delete your current figure from the list
close(figs)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuZoomToggle_Callback(hObject, eventdata, handles)
% hObject    handle to menuZoomToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ax = gca;
axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];
if strcmp(get(handles.menuZoomToggle, 'Checked'), 'on')
    zoomState = true;
    set(handles.menuZoomToggle, 'Checked', 'off')
else
    zoomState = false;
    set(handles.menuZoomToggle, 'Checked', 'on')
end

for ind = 1:length(axHandles)
    
    zBox = handles.zoomBoxLTBR(ind,:);
    ax = axHandles(ind);
    kym_lines = (handles.kymLines(ind,:));
    
    if zoomState
        set(ax, 'XLim', [0 512]);
        set(ax, 'YLim', [0 512]);

        delete(handles.pos_txt(:,ind));

    else
        set(ax, 'XLim', [zBox(1) zBox(3)]);
        set(ax, 'YLim', [zBox(2) zBox(4)]);
        
        tposx = get(kym_lines, 'XData');
        tposy = get(kym_lines, 'YData');
        for kpos = 1:length(kym_lines)
            handles.pos_txt(kpos,ind) = text(tposx{kpos}(1), tposy{kpos}(1), ...
                sprintf('%0.2f', handles.positionsAlongLine(kpos)),...
                'Parent', axHandles(ind), 'FontSize', 8);
            set(handles.pos_txt(kpos, ind), 'Color', 'r');
        end
    end
    
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuPreCutFig_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axUpSpeedVPosition_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axUpSpeedVPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles = guidata(gcf);

if gca == handles.axUpSpeedVPosition
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
    direction = 'up';
    handles.currentDir = 'up';
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
    direction = 'down';
    handles.currentDir = 'down';
end

a = get(gca, 'CurrentPoint');
xpos = a(1,1);
x = abs(handles.poss{ax} - xpos);

closest = find(x == min(x));

move_selected_point(closest);

function move_selected_point(closest)

handles = guidata(gcf);
set(handles.listData, 'Enable', 'on');
busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];

if gca == handles.axUpSpeedVPosition
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
    direction = 'up';
    handles.currentDir = 'up';
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
    direction = 'down';
    handles.currentDir = 'down';
end

folder = [baseFolder2 appendText];



h = findobj('Parent', gca);

for ind = 1:length(h)
    if (get(h(ind), 'Color') == [1 0 0])
        delete(h(ind));
    end
end

hold on
plot(handles.poss{ax}(closest), handles.speeds{ax}(closest), 'o', 'Color', 'r');
hold off

[~, closest_kymline] = min(abs(handles.positionsAlongLine - handles.poss{ax}(closest)));

for kymInd = 1:length(handles.kymLines(ax,:))
    if kymInd == closest_kymline
        set(handles.kymLines(ax, closest_kymline), 'Color', 'g');
    else
        set(handles.kymLines(ax, kymInd), 'Color', 'r');
    end
end


%% Get relevant kymograph file and plot
filepath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
pos_along_cut = getKymPosMetadataFromText(filepath);
fractional_pos_along_cut = getNumericMetadataFromText(filepath, 'metadata.kym_region.fraction_along_cut');
distance_from_edge = getNumericMetadataFromText(filepath, 'metadata.kym_region.distance_from_edge');
kym_ind = find((round(100*pos_along_cut)/100) == (round(100*handles.poss{ax}(closest))/100)) - 2;
handles.currentKymInd = kym_ind;

fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
    ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(kym_ind)...
    appendText '.fig'];
try
    h = openfig(fpath, 'new', 'invisible');

    fAx = get(h, 'Children');
    dataObjs = get(fAx, 'Children');
    im = get(dataObjs(end), 'CData');
    x = get(dataObjs(end), 'XData');
    y = get(dataObjs(end), 'YData');

    % imH = imagesc(x, y, im, 'Parent', kym_ax);
    hold(kym_ax, 'on');
    RI = imref2d(size(im));
    RI.XWorldLimits = [min(x) max(x)];
    RI.YWorldLimits = [min(y) max(y)];
    bg = zeros(size(im));
    cmap = gray;
    cmap(1,:) = [0 1 1];
    colBg = ind2rgb(bg, cmap);
    % hold off;
    handles.kymIm(ax) = imshow(im, RI, [min(im(:)) max(im(:))], 'Parent', kym_ax);
    axis tight;
    handles.kymData(ax,:,:) = im;
    xlabel(kym_ax, 'Time relative to cut, s')
    ylabel(kym_ax, 'Position relative to cut, \mum')

    title_txt = [handles.date ' Embryo ' handles.embryoNumber ', Cut ' handles.cutNumber...
        ',' appendText ', kymograph position along cut: ' sprintf('%0.2f', handles.poss{ax}(closest)) ' \mum'];
    handles.kymTitle{ax} = title(kym_ax, title_txt);

    handles.currentPosition = handles.poss{ax}(closest);
    handles.currentSpeed = handles.speeds{ax}(closest);
    handles.currentFractionalPosition = fractional_pos_along_cut(round(1000*pos_along_cut)/1000 ...
        == round(1000*handles.currentPosition)/1000);
    handles.currentDistanceFromEdge = distance_from_edge(round(1000*pos_along_cut)/1000 ...
        == round(1000*handles.currentPosition)/1000);

    %% get number of blocked out frames
    temp = regionprops(logical(sum(im,1) == 0));
    handles.currentBlockedFrames = max([temp.Area]);

    fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
        ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(kym_ind)...
       ' - quantitative kymograph.fig'];
    h = openfig(fpath, 'new', 'invisible');
    fAx = get(h, 'Children');
    dataObjs = get(fAx, 'Children');

    % TODO: get data on frames/second from metadata
    xoffset = (1+sum(sum(im(:,25:30),1)==0))*0.2;
    y=get(dataObjs{1}(1), 'YData')+0.218;
    x=get(dataObjs{1}(1), 'XData');
    x = x + xoffset;
    x = [x(1) x(end)];
    y = [y(1) y(end)];

    set(handles.kymIm(ax), 'UIContextMenu', handles.menuSelectedKymFig);

    % handles.kymIm(ax) = imH;

    fitLineState = get(handles.menuOverlayFitLine, 'Checked');
    membraneOverlayState = get(handles.menuOverlayEdge, 'Checked');


    % TODO: get data on frames/second and pre- and post-cut time from metadata
    membrane = get(dataObjs{2}, 'CData');
    prePad = zeros(size(membrane, 1), 21+find(sum(im(:,22:32),1)==0, 1, 'last'));
    postPad = zeros(abs(size(im) - size(membrane) - size(prePad)));
    handles.paddedMembrane{ax} = [prePad membrane postPad];

    % if(~strcmp(membraneOverlayState, 'on'))
        imshow(colBg, RI, 'Parent', kym_ax);
        handles.kymIm(ax) = imshow(im, RI, [min(im(:)) max(im(:))], 'Parent', kym_ax);

        % For now, default overlay to on
    % if(~strcmp(membraneOverlayState, 'on'))    
        set(handles.kymIm(ax), 'AlphaData', 1-handles.paddedMembrane{ax}/2);
        set(handles.menuOverlayEdge, 'Checked', 'on');
    % else
    %     set(handles.kymIm(ax), 'AlphaData', 1);
    % end
        hold(kym_ax, 'off');
        set(handles.kymIm(ax), 'UIContextMenu', handles.menuSelectedKymFig);
    % end

    handles.fitLine(ax) = line(x, y, 'Parent', kym_ax, 'Color', 'r');
    handles.fitText(ax) = text(x(2)+1, y(2), {[sprintf('%0.2f', handles.speeds{ax}(closest)) ' \mum s^{-1}'], 'R^{2} = 3'},...
        'Parent', kym_ax, 'Color', 'r', 'FontSize', 10, 'BackgroundColor', 'k');

    if(~strcmp(fitLineState, 'on'))
        set(handles.fitLine(ax), 'Visible', 'off');
        set(handles.fitText(ax), 'Visible', 'off');
    end

    if sum(checkIfStored(handles, direction)) > 0 
        set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
    else
        set(handles.kymTitle{ax}, 'BackgroundColor', 'none');
    end
catch ME
    disp(ME);
end
busyDlg(busyOutput);
set(handles.listData, 'Enable', 'on');

guidata(gcbo, handles);
% guidata(hObject, handles);


% --------------------------------------------------------------------
function saveToPNG_Callback(hObject, eventdata, handles)
% hObject    handle to saveToPNG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'baseFolder')
    default_folder = handles.baseFolder;
else
    default_folder = 'C:\Users\Doug\Desktop\test';
end

c = clock;
dateStr = sprintf('%d-%02d-%02d %02d%02d', c(1), c(2), c(3), c(4), c(5));
defaultName = [dateStr ' Kymograph Data Viewer.png'];
[fname,pname] = uiputfile('*.png', 'Save current view to PNG...', [default_folder filesep defaultName]);
set(gcf,'PaperPositionMode','auto');
set(gcf,'InvertHardcopy','off')

print(gcf, [pname fname], '-dpng', '-r600', '-loose');

% --------------------------------------------------------------------
function saveToPPT_Callback(hObject, eventdata, handles)
% hObject    handle to saveToPPT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function exportWizard_Callback(hObject, eventdata, handles)
% hObject    handle to exportWizard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% CHECK IF THERE IS DATA TO SAVE?
if isfield(handles, 'includedData')
   if isempty(handles.includedData)
       msgbox('No data included for export!');
       return;
   end
else
    msgbox('No data included for export!');
    return;
end

%% DIALOG TO CHECK WHETHER DATA SHOULD BE APPENDED OR WRITTEN ANEW
% reply = questdlg('Create a new output file, or append output to an existing file?', ...
%     'Create/append?', 'Create new', 'Append', 'Create new');
reply = 'Create new';

switch reply
    case 'Create new'
        [fname, pname] = uiputfile('*.xlsx');
    case 'Append'
        [fname, pname, ~] = uigetfile('*.xlsx');
    otherwise
        return;
end

if isequal(fname, 0)
    return;
else
    outputName = [pname filesep fname];
end
        
%% DIALOG TO CHECK WHICH STATS (MAX, MEAN, MEDIAN ETC.) SHOULD BE INCLUDED
reply = questdlg('Save raw data only, or generate max, median, mean for each kymograph?', ...
    'Include max/median/mean?', 'Include stats', 'Don''t include stats', 'Don''t include stats');

switch reply
    case 'Include stats'
        includeStats = true;
    case 'Don''t include stats'
        includeStats = false;
    otherwise
        return;
end

%% EXPORT (TO CSV?)
disp('Export...')

busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');

headerLine = fields(handles.includedData)';
data = struct2cell(handles.includedData)';

if ~isfield(handles.includedData, 'distanceCutToApicalSurfaceUm')

	varn = 'metadata.distanceToApicalSurface';

	distances = cell(0);

	for ind = 1:size(data,1)
	 
	 
		fdate = data{ind,1};
		fENumber = data{ind,2};
		fDirection = data{ind, 31};
		fCNumber = data{ind, 3};
        
        if isa(fdate, 'double')
            fdate = num2str(fdate);
        end
        
        if isa(fCNumber, 'double')
            fCNumber = num2str(fCNumber);
        end
        
        if isa(fENumber, 'double')
            fENumber = num2str(fENumber);
        end
		
		fpath = [handles.baseFolder filesep fdate ', Embryo ' fENumber...
		 ' ' fDirection 'wards' filesep 'trimmed_cutinfo_cut_' num2str(fCNumber)...
		 '.txt'];
	 
		distances = [distances; num2cell(getNumericMetadataFromText(fpath, varn))];
		
	end
	
	data = [data distances];
	
	headerLine = [headerLine 'distanceCutToApicalSurfaceUm'];
 
end

xxwrite(outputName, [headerLine; data]);

if includeStats
    %% get list of kymograph IDs
    [uniqueKymIDs,ia,ic]  = unique(data(:, strcmp(headerLine, 'ID')),'stable');
    
    %% for each kymograph, isolate the  relevant data rows and calculate stats
    for ind = 1:max(ic)
        mu(ind) = mean([data{ic == ind, strcmp(headerLine, 'speed')}]);
        sd(ind) = std([data{ic == ind, strcmp(headerLine, 'speed')}]);
        mx(ind) = max([data{ic == ind, strcmp(headerLine, 'speed')}]);
        med(ind) = median([data{ic == ind, strcmp(headerLine, 'speed')}]);
%         filtmu(ind) = mean([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
%             & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
    end
    
    %% turn off "add sheet" warnings...
    wid = 'MATLAB:xlswrite:AddSheet';
    warning('off', wid);
    
    mudata = data(ia, :);
    mudata(:, strcmp(headerLine, 'speed')) = num2cell(mu);
    xxwrite(outputName, [headerLine; mudata], 'Mean speeds, ums^-1');
    
    sddata = data(ia, :);
    sddata(:, strcmp(headerLine, 'speed')) = num2cell(sd);
    xxwrite(outputName, [headerLine; sddata], 'SD on speeds, ums^-1');
    
    mxdata = data(ia, :);
    mxdata(:, strcmp(headerLine, 'speed')) = num2cell(mx);
    xxwrite(outputName, [headerLine; mxdata], 'Max speeds, ums^-1');
    
    meddata = data(ia, :);
    meddata(:, strcmp(headerLine, 'speed')) = num2cell(med);
    xxwrite(outputName, [headerLine; meddata], 'Median speeds, ums^-1');
    
    %% get list of embryo/cut/date
    ids = data(:, strcmp(headerLine, 'ID'));
    for ind = 1:length(ids)
        r  = regexp(ids{ind}, '-', 'split');
        ids2{ind} = sprintf('%s-%s-%s', r{1}, r{2}, r{3});
    end
    
    [~, ia, ic] = unique(ids2, 'stable');
    %% for each kymograph, isolate the  relevant data rows and calculate stats
    for ind = 1:max(ic)
        filtmu(ind) = mean([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
            & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
        
        filtsd(ind) = std([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
            & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
        
        try
            filtmx(ind) = max([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
                & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
        catch
            filtmx(ind) = NaN;
        end
        
        filtmed(ind) = median([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
            & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
    end
       
    filtmudata = data(ia, :);
    filtmudata(:, strcmp(headerLine, 'speed')) = num2cell(filtmu);
    xxwrite(outputName, [headerLine; filtmudata], 'JonFiltMean');
    
    filtsddata = data(ia, :);
    filtsddata(:, strcmp(headerLine, 'speed')) = num2cell(filtsd);
    xxwrite(outputName, [headerLine; filtsddata], 'JonFiltSD');
    
    filtmxdata = data(ia, :);
    filtmxdata(:, strcmp(headerLine, 'speed')) = num2cell(filtmx);
    xxwrite(outputName, [headerLine; filtmxdata], 'JonFiltMax');
    
    filtmeddata = data(ia, :);
    filtmeddata(:, strcmp(headerLine, 'speed')) = num2cell(filtmed);
    xxwrite(outputName, [headerLine; filtmeddata], 'JonFiltMedian');
    
    
    %% Now do Jon-style ("inside cut only") filtering, but separating up and down kymographs for
    % meaningful comparison of apical and basal surface movement in order
    % to assess whether cells are moving or changing size:
    
    filtmu = [];
    filtsd = [];
    filtmx = [];
    filtmed = [];
    
    [~, ia, ic] = unique(ids, 'stable');
    %% for each kymograph, isolate the  relevant data rows and calculate stats
    for ind = 1:max(ic)
        filtmu(ind) = mean([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
            & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
        
        filtsd(ind) = std([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
            & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
        
        try
            filtmx(ind) = max([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
                & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
        catch
            filtmx(ind) = NaN;
        end
        
        filtmed(ind) = median([data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
            & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}]);
    end
       
    filtmudata = data(ia, :);
    filtmudata(:, strcmp(headerLine, 'speed')) = num2cell(filtmu);
    xxwrite(outputName, [headerLine; filtmudata], 'InsideCutFiltMean');
    
    filtsddata = data(ia, :);
    filtsddata(:, strcmp(headerLine, 'speed')) = num2cell(filtsd);
    xxwrite(outputName, [headerLine; filtsddata], 'InsideCutFiltSD');
    
    filtmxdata = data(ia, :);
    filtmxdata(:, strcmp(headerLine, 'speed')) = num2cell(filtmx);
    xxwrite(outputName, [headerLine; filtmxdata], 'InsideCutFiltMax');
    
    filtmeddata = data(ia, :);
    filtmeddata(:, strcmp(headerLine, 'speed')) = num2cell(filtmed);
    xxwrite(outputName, [headerLine; filtmeddata], 'InsideCutFiltMedian');
    
end
   
busyDlg(busyOutput);
set(handles.listData, 'Enable', 'on');
    
    
function xxwrite(varargin)
outName = varargin{1};
data = varargin{2};
if ~ispc
    [pname, fname, ~] = fileparts(outName);
    outName = [pname filesep fname '.xls'];
    if nargin == 2
        xlwrite(outName, data);
    elseif nargin == 3
        sht = varargin{3};
        xlwrite(outName, data, sht);
    end
else
    if nargin ==2
        xlswrite(outName, data);
    elseif nargin == 3
        sht = varargin{3};
        xlswrite(outName, data, sht);
    end
end
    

% --------------------------------------------------------------------
function menuOverlayFitLine_Callback(hObject, eventdata, handles, callAx)
% hObject    handle to menuOverlayFitLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% replace callAx with gca?
if (callAx == handles.axUpSelectedKym)
    ax = 1;
elseif (callAx == handles.axDownSelectedKym)
    ax = 2;
end

fitLineState = get(handles.menuOverlayFitLine, 'Checked');
if strcmp(fitLineState, 'on')
    set(handles.menuOverlayFitLine, 'Checked', 'off');
    set(handles.fitLine(ax), 'Visible', 'off');
    set(handles.fitText(ax), 'Visible', 'off');
else
    set(handles.menuOverlayFitLine, 'Checked', 'on');
    set(handles.fitLine(ax), 'Visible', 'on');
    set(handles.fitText(ax), 'Visible', 'on');
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSelectedKymFig_Callback(hObject, eventdata, handles)
% hObject    handle to menuSelectedKymFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (gca == handles.axUpSelectedKym)
    ax = 1;
    handles.currentDir = 'up';
elseif (gca == handles.axDownSelectedKym)
    ax = 2;
    handles.currentDir = 'down';
end

if strcmp(get(handles.fitLine(ax), 'Visible'), 'on')
    set(handles.menuOverlayFitLine, 'Checked', 'on');
else
    set(handles.menuOverlayFitLine, 'Checked', 'off');
end

ad = get(handles.kymIm(ax), 'AlphaData');
if mean(ad(:))==1
    set(handles.menuOverlayEdge, 'Checked', 'off');
else
    set(handles.menuOverlayEdge, 'Checked', 'on');
end

if isfield(handles, 'experimentMetadata')
    if ~isempty(handles.experimentMetadata)
        set(handles.menuInclude, 'Enable', 'on');
    else
        set(handles.menuInclude, 'Enable', 'off');
    end
else
    set(handles.menuInclude, 'Enable', 'off');
end

if ischar(get(handles.kymTitle{ax}, 'BackgroundColor'))
    if strcmp(get(handles.kymTitle{ax}, 'BackgroundColor'), 'none')
        set(handles.menuInclude, 'Checked', 'off');
    end
else
    set(handles.menuInclude, 'Checked', 'on');
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuOverlayEdge_Callback(hObject, eventdata, handles)
% hObject    handle to menuOverlayEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(gcf);

if (gca == handles.axUpSelectedKym)
    ax = 1;
elseif (gca == handles.axDownSelectedKym)
    ax = 2;
end

overlayEdgeState = get(handles.menuOverlayEdge, 'Checked');
if strcmp(overlayEdgeState, 'on')
    set(handles.menuOverlayEdge, 'Checked', 'off');
    set(handles.kymIm(ax), 'AlphaData', 1);
else
    set(handles.menuOverlayEdge, 'Checked', 'on');
    set(handles.kymIm(ax), 'AlphaData', 1-handles.paddedMembrane{ax}/2);
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuManualLine_Callback(hObject, eventdata, handles)
% hObject    handle to menuManualLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off');
    set(handles.menuSaveManualSpeed, 'Enable', 'off')
    if isfield(handles, 'manualLine')
        delete(handles.manualLine);
        handles.currentManualLineSpeed = [];
    end
else
    set(hObject, 'checked', 'on');
    set(handles.menuSaveManualSpeed, 'Enable', 'on')
    nonsense = get(gca);
    handles.manualLine = imline(gca, [0 4], [1 1]);
%     addNewPositionCallback(handles.manualLine, manualLineCallback(hObject, handles))
end

guidata(hObject, handles)


function pos = manualLineCallback(hObject, handles)

    disp('nonsense');
%     pos = handles.manualLine.getPosition;
%     handles.currentManualLineSpeed = (pos(1,2) - pos(2,2))/...
%         (pos(1,1) - pos(2,1));

guidata(hObject, handles)

% --------------------------------------------------------------------
function menuFixAxisLimits_Callback(hObject, eventdata, handles)
% hObject    handle to menuFixAxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToggleFixedAxes_Callback(hObject, eventdata, handles)
% hObject    handle to menuToggleFixedAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('toggle');


% --------------------------------------------------------------------
function menuSetLimits_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSpeedVPos_Callback(hObject, eventdata, handles)
% hObject    handle to menuSpeedVPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoadMetadata_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadMetadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


default_folder = 'C:\Users\Doug\Desktop\test';
if isfield(handles, 'metadataPath')
    if ischar(handles.metadataPath)
        sf = handles.metadataPath;
    else
        sf = default_folder;
    end
elseif ~isfield(handles, 'baseFolder')
    sf = default_folder;
else
    if ischar(handles.baseFolder)
        sf = handles.baseFolder;
    else
        sf = default_folder;
    end
end

reply = 'OK';
% if isfield(handles, 'includedData')
%     if ~isempty(handles.includedData)
%         reply = questdlg('Discard data currently set as "included" for export?', ...
%             'Discard data - are you sure?', 'OK', 'Cancel', 'Cancel');
%     end
% end

if strcmp(reply, 'OK')

    busyOutput = busyDlg();
    set(handles.listData, 'Enable', 'off');

    [fname, pname,~]= uigetfile('*.xlsx', 'Choose the xlsx file containing the experiment metadata...', sf);
    handles.metadataPath = [pname, fname];

    if ischar(handles.metadataPath)
        handles.experimentMetadata = getExperimentMetadata(handles.metadataPath);
    end

    busyDlg(busyOutput);
    set(handles.listData, 'Enable', 'on');

    if ~isfield(handles, 'includedData')
        handles.includedData = [];
    end
%     handles.includedData = [];

end
    
guidata(hObject, handles);

function indices = checkIfStored(handles, direction)
% Check whether currently selected kymograph data has been stored for
% export
indices = 0;
if isfield(handles, 'includedData');
    if isstruct(handles.includedData)
        stored = struct2cell(handles.includedData);
        f = fields(handles.includedData);
        dates = {stored(strcmp(f, 'date'), :)};
%         if isnumeric(dates{1}{1})
%             dates = cellfun(@num2str, dates{1}, 'UniformOutput', false);
%             dates = num2str(dates);
%         end
        dates = convertToStringUtil({stored(strcmp(f, 'date'), :)});
        embryoNs = convertToStringUtil({stored(strcmp(f, 'embryoNumber'), :)});
        cutNs = cell2mat(stored(strcmp(f, 'cutNumber'), :));
        directions = convertToStringUtil({stored(strcmp(f, 'direction'), :)}); 
        positions = cell2mat(stored(strcmp(f, 'kymPosition'), :));

        if max(size(dates)) == 1
            indices = strcmp(dates{1}, handles.date) & strcmp(embryoNs{1}, handles.embryoNumber) & ...
                (cutNs == str2double(handles.cutNumber)) & strcmp(directions{1}, direction) & ...
                round(1000*positions)/1000 == round(1000*handles.currentPosition)/1000;
        else
            indices = strcmp(dates, handles.date) & strcmp(embryoNs, handles.embryoNumber) & ...
                (cutNs == str2double(handles.cutNumber)) & strcmp(directions{:}, direction) & ...
                round(1000*positions)/1000 == round(1000*handles.currentPosition)/1000;
        end
            
    end
end

function outVar = convertToStringUtil(inVar)

if isnumeric(inVar{1}{1})
    outVar = cellfun(@num2str, inVar{1}, 'UniformOutput', false);
else
    outVar = inVar;
end

% --------------------------------------------------------------------
function menuInclude_Callback(hObject, eventdata, handles)
% hObject    handle to menuInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Check state of checkbox
if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end

if gca == handles.axUpSelectedKym
    direction = 'up';
    ax = 1;
else
    direction = 'down';
    ax = 2;
end

%% Check if current date/embryo/cut/direction/position is stored yet
indices = checkIfStored(handles, direction);

%% If not, store in includedData structure along with metadata
if sum(indices) == 0 && strcmp(get(hObject, 'checked'), 'on')
    
    % Find the relevant experiment metadata fields...
    expMeta = struct2cell(handles.experimentMetadata);
    expMetaFields = fields(handles.experimentMetadata);
    
    dates = {expMeta(strcmp(expMetaFields, 'date'), :)};
    embryoNs = {expMeta(strcmp(expMetaFields, 'embryoNumber'), :)};
    cutNs = {expMeta(strcmp(expMetaFields, 'cutNumber'), :)};
    
    expMetaIndices = strcmp(dates{1}, handles.date) & strcmp(embryoNs{1}, handles.embryoNumber) & ...
        (cell2mat(cutNs{1}) == str2double(handles.cutNumber));
    
    incData = handles.experimentMetadata(expMetaIndices);
    incData.ID = [handles.date '-' handles.embryoNumber '-' handles.cutNumber '-' direction];
    incData.kymPosition = handles.currentPosition;
    incData.fractionalPosition = handles.currentFractionalPosition;
    incData.distanceFromEdge = handles.currentDistanceFromEdge;
    incData.speed = handles.currentSpeed;
    incData.direction = direction;
    incData.numberBlockedFrames = handles.currentBlockedFrames;
    
    incData.distanceCutToApicalSurfaceUm = handles.currentApicalSurfaceToCutDistance;
    
    if isfield(handles, 'currentManualLineSpeed')
        incData.manualSpeed = handles.currentManualLineSpeed;
    else
        incData.manualSpeed = nan;
    end
    
    handles.includedData = [handles.includedData; incData];
    
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
        
end

%% Deal with case when kymograph has been selected but user has changed mind...
if sum(indices > 0) && strcmp(get(hObject, 'checked'), 'off')
   %% remove data from handles.includedData based on indices vector 
   set(handles.kymTitle{ax}, 'BackgroundColor', 'none');
   if length(handles.includedData) > 1
        handles.includedData(indices) = [];
   else
       handles.includedData = [];
   end
end

guidata(hObject, handles);
    


% --------------------------------------------------------------------
function menuMovies_Callback(hObject, eventdata, handles)
% hObject    handle to menuMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

if isfield(handles, 'movieFrames')
    if length(handles.movieFrames) >= ax  
        if ~isempty(handles.movieFrames{ax})
            set(handles.menuSaveMovie, 'Enable', 'on');
        else
            set(handles.menuSaveMovie, 'Enable', 'off');
        end
    else
        set(handles.menuSaveMovie, 'Enable', 'off');
    end
else
    set(handles.menuSaveMovie, 'Enable', 'off');
end


% --------------------------------------------------------------------
function menuViewMovie_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
busyOutput = busyDlg();
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

folder = [baseFolder2 appendText];
metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
imFName = [folder filesep 'trimmed_stack_cut_' handles.cutNumber '.tif'];

handles.movieFrames{ax} = makeMovieOfProcessedData(imFName, metadataFName);

busyDlg(busyOutput);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuViewSaveMovie_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewSaveMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
busyOutput = busyDlg();
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

folder = [baseFolder2 appendText];
metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
imFName = [folder filesep 'trimmed_stack_cut_' handles.cutNumber '.tif'];

[fileName,pathName,~] = uiputfile('*.avi','Choose AVI filename...',...
    [folder filesep 'Movie of processed membrane movement, date = ', handles.date ...
    ', embryo = ' handles.embryoNumber ', cut = ' handles.cutNumber appendText '.avi']);

if fileName ~= 0
    handles.movieFrames{ax} = makeMovieOfProcessedData(imFName, metadataFName, [pathName fileName]);
end
    
busyDlg(busyOutput);

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSaveMovie_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fps = 15;
busyOutput = busyDlg();
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

folder = [baseFolder2 appendText];
metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
imFName = [folder filesep 'trimmed_stack_cut_' handles.cutNumber '.tif'];
[fileName,pathName,~] = uiputfile('*.avi','Choose AVI filename...',...
    [folder filesep 'Movie of processed membrane movement, date = ', handles.date ...
    ', embryo = ' handles.embryoNumber ', cut = ' handles.cutNumber appendText '.avi']);

makeMovieOfProcessedData(imFName, metadataFName, [pathName fileName], handles.movieFrames{ax}, fps);
busyDlg(busyOutput);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% disp(eventdata.Key);
% disp(eventdata.Character);
% disp(eventdata.Modifier);

if strcmp(eventdata.Key, 'e')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
    else
        axes(handles.axDownSelectedKym);
    end
    callback = get(handles.menuOverlayEdge, 'Callback');
    callback(handles.menuOverlayEdge, []);
end

if strcmp(eventdata.Key, 'i')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
    else
        axes(handles.axDownSelectedKym);
    end
    callback = get(handles.menuInclude, 'Callback');
    callback(handles.menuInclude, []);
end

if strcmp(eventdata.Key, 'p')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpFirstFrame);
    else
        axes(handles.axDownFirstFrame);
    end
    callback = get(handles.menuViewMovie, 'Callback');
    callback(handles.menuViewMovie, []);
end

if strcmp(eventdata.Key, 'rightarrow')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSpeedVPosition);
        ax = 1;
    else
        axes(handles.axDownSpeedVPosition);
        ax = 2;
    end
    % identify current point, and therefore point to the right
    xpos = handles.currentPosition;
    x = abs(handles.poss{ax} - xpos);

    closest = find(x == min(x));

    if (handles.poss{ax}(2) - handles.poss{ax}(1)) > 0
        delta = 1;
    else
        delta = -1;
    end

    if (closest + delta) > 0 && (closest + delta) <= length(handles.poss{ax})
        move_selected_point(closest + delta);
    end
    
end

if strcmp(eventdata.Key, 'leftarrow')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSpeedVPosition);
        ax = 1;
    else
        axes(handles.axDownSpeedVPosition);
        ax = 2;
    end
    % identify current point, and therefore point to the right
    xpos = handles.currentPosition;
    x = abs(handles.poss{ax} - xpos);

    closest = find(x == min(x));
    
    if (handles.poss{ax}(2) - handles.poss{ax}(1)) > 0
        delta = -1;
    else
        delta = 1;
    end

    if (closest + delta) > 0 && (closest + delta) <= length(handles.poss{ax})
        move_selected_point(closest + delta);
    end
    
end

% guidata(hObject, handles);


% --------------------------------------------------------------------
function menuImportInclusion_Callback(hObject, eventdata, handles)
% hObject    handle to menuImportInclusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
busyOutput = busyDlg();
reply = 'Yes';
if isfield(handles, 'includedData')
    if ~isempty(handles.includedData)
        reply = questdlg('Overwrite unsaved inclusion data?', 'Are you sure?', 'Yes', 'No', 'No');
    end
end

if strcmp(reply, 'Yes')
    handles.includedData = [];

    [fname, pname, ~] = uigetfile('*.xls;*.xlsx', 'Choose an exisiting kymograph inclusion file...');
    
    if fname ~= 0
        filepath = [pname fname];
        [~,~,dummy] = xlsread([pname fname]);

        handles.includedData = cell2struct(dummy(2:end, :)', dummy(1,:)', 1);
    end
end

busyDlg(busyOutput);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox(sprintf('Software version: %0.1f', handles.softwareVersion), 'About', 'help');



% --------------------------------------------------------------------
function menuFitType_Callback(hObject, eventdata, handles)
% hObject    handle to menuFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLinearFit_Callback(hObject, eventdata, handles)
% hObject    handle to menuLinearFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('lin fit');
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
    set(handles.menuExpFit, 'Checked', 'off');
    
    handles.linTexpF = true;
    
    guidata(hObject, handles);
    
    callback = get(handles.listData, 'Callback');
    callback(handles.listData, []);
    
end
    


% --------------------------------------------------------------------
function menuExpFit_Callback(hObject, eventdata, handles)
% hObject    handle to menuExpFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('exp fit');
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
    set(handles.menuLinearFit, 'Checked', 'off');
    
    handles.linTexpF = false;
    
    guidata(hObject, handles);
    
    callback = get(handles.listData, 'Callback');
    callback(handles.listData, []);
    
end


% --------------------------------------------------------------------
function menuViewerOptions_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewerOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function menuManualSpeedDetermination_Callback(hObject, eventdata, handles)
% hObject    handle to menuManualSpeedDetermination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSaveManualSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveManualSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'manualLine')
   
    if gca == handles.axUpSelectedKym
        direction = 'up';
        ax = 1;
    else
        direction = 'down';
        ax = 2;
    end

   pos = handles.manualLine.getPosition;
   handles.currentManualLineSpeed = (pos(1,2) - pos(2,2))/(pos(1,1) - pos(2,1));
   
   indices = checkIfStored(handles, direction);
   if sum(indices) > 0
      handles.includedData(indices(1)).manualSpeed = handles.currentManualLineSpeed;
   end
   
   id = [handles.date '-' handles.embryoNumber '-' handles.cutNumber '-' direction '-' handles.currentKymInd];
   
   handles.manualSpeeds = [handles.manualSpeeds; {id handles.currentManualLineSpeed}];
   
end

guidata(hObject, handles)


% --------------------------------------------------------------------
function menuPreCutExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.menuZoomToggle, 'Checked'), 'on')
    zoomState = true;
else
    zoomState = false;
end
% 
% if zoomState
%     set(handles.menuPreCutExportLabels, 'Enable', 'on');
% else
%     set(handles.menuPreCutExportLabels, 'Enable', 'off');
% end

%for now, only allow export of full size image...
if ~zoomState
    set(handles.menuPreCutExportLabels,'Enable', 'off');
    set(handles.menuPreCutExportNoLabels, 'Enable', 'on');
else
    set(handles.menuPreCutExportLabels,'Enable', 'off');
    set(handles.menuPreCutExportNoLabels, 'Enable', 'off');
end

% --------------------------------------------------------------------
function menuPreCutExportLabels_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutExportLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuPreCutExportNoLabels_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutExportNoLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% start busy
busyOutput = busyDlg();

pname = uigetdir(handles.baseFolder, 'Choose a folder to save figures...');

if pname

    ax = gca;
    newfh = figure('Visible', 'off');
    newax = copyobj(ax, newfh);
    T = get(newax, 'TightInset');
%     set(newax, 'Position', [T(1) T(2) 1-T(1)-T(3) 1-T(2)-T(4)]);
    set(newfh, 'Units', 'normalized');
    set(newax, 'OuterPosition', [0 0 1 1]);
    axis equal tight;
    colormap gray;
    txth = findobj(newax, 'Type', 'Text');
    
    % get rid of labels if they exist
    if ~isempty(txth)
        delete(txth);
    end

%     dtstr = datestr(now);
%     dtstr = regexprep(dtstr,':','_');

    if ax == handles.axUpFirstFrame
        direction = 'up';
        ind = 1;
    else
        direction = 'down';
        ind = 2;
    end
    
    fname = ['Pre-cut figure, scalebar=20um, ' handles.date '-E' handles.embryoNumber '-C' handles.cutNumber '-' direction];
    set(newfh, 'Name', fname);

    set(newfh, 'Color', [1 1 1]);
    
    savefig(newfh, [pname filesep fname '.fig']);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'InvertHardcopy','off')

    print(newfh, [pname filesep fname '.png'], '-dpng', '-r600', '-loose');
    
    %get rid of scalebar if it exists...
    
    % zoom in...
    zBox = handles.zoomBoxLTBR(ind,:);
    padding=round(5/handles.umPerPixel);
    set(newax, 'XLim', [max(zBox(1)-padding,1) min(zBox(3)+padding,512)]);
    set(newax, 'YLim', [max(zBox(2)-padding,1) min(zBox(4)+padding,512)]);
    
    % add new scale bar...
    scx = [min(zBox(3)+padding,512) - 10 - padding   min(zBox(3)+padding,512) - 10];
    scy = [min(zBox(4)+padding,512)-10 min(zBox(4)+padding,512)-10];
    scline = line(scx, scy, 'Color', 'w', 'LineWidth',3);
    fname = ['Cropped pre-cut figure, scalebar=5um, ' handles.date '-E' handles.embryoNumber '-C' handles.cutNumber '-' direction];
    set(newfh, 'Name', fname);
    
    savefig(newfh, [pname filesep fname '.fig']);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'InvertHardcopy','off')

    print(newfh, [pname filesep fname '.png'], '-dpng', '-r600', '-loose');

    close(newfh);
    
end

busyDlg(busyOutput);



% --------------------------------------------------------------------
function menuSetLineThickness_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetLineThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'Line width for kymograph axis thickness:';
dlg_title = 'Set line width...';
num_lines = 1;
default_val = num2str(handles.kymAxisThickness);
answer = inputdlg(prompt, dlg_title, num_lines, {default_val});

handles.kymAxisThickness = str2double(answer);

axs = {handles.axUpFirstFrame; handles.axDownFirstFrame};

for ax_ind = 1:length(axs)
    cut_line = findobj('Parent', axs{ax_ind}, 'type', 'line', 'Color', 'b');
    kym_lines = findobj('Parent', axs{ax_ind}, 'type', 'line', 'Color', 'r');

    for kl_ind = 1:length(kym_lines)

        set(kym_lines(kl_ind), 'LineWidth', handles.kymAxisThickness);

    end
    
    set(cut_line, 'LineWidth', round((3/2) * handles.kymAxisThickness));
end

guidata(hObject, handles);
