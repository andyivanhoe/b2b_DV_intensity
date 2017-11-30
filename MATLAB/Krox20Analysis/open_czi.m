function open_czi()

    %% Get file path
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fileparts(curr_dir)));
    
    %% Initialises logging, as per https://github.com/openmicroscopy/bioformats/issues/2233
    bfInitLogging()
    
  %% Parameters
     z_offsets = [.25, .5, .75];         % Percentage along DV-axis. Ventral = 0, Dorsal = 1
     channel_names = {'cdh2-tFT'};
% %     channel_names = {'pard3-EGFP', 'membrane label'};
     scale_bar_length_um = 20;
% %    midline_definition_method = 'max';  %'none', 'max' or 'mean'

%% Choose base folder
    folder = uigetdir([], ...
        'Choose a folder containing a CZI files...');   % Why do we not see this string or is it in Command Window?

    if (folder == 0) 
        return;
    end

   %% Get CZI files and display first z-slice
    disp('Loading files...');
    [files_out, timestamps] = order_files(folder);
    
    % Initialise elements of data structure
    data.files = files_out;
    data.timestamps = timestamps;   % Do not need this for single time points
    
    data.edges = [];
    data.top_slice_index = [];
    data.filename = files_out(1).name;
    %data.timepoint = 1; 
    data.czi_reader = bfGetReader([folder filesep files_out(1).name]);
    data.im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(0, 0, 0) + 1);
    data.ome_meta = data.czi_reader.getMetadataStore();
    data.z_offsets = z_offsets;
    data.channel_names = channel_names;
    data.scale_bar_length_um = scale_bar_length_um;
    controls = setup_ui(data);
    data.controls = controls;
    %data.midline_definition_method = midline_definition_method;
    setappdata(controls.hfig, 'data', data);
    
    initialise_sliders(controls, data);
    attach_callbacks(controls)
    imagesc(data.im, 'Parent', controls.hax);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis equal tight;
end

    
    
    
    
%%



% 
% %% Initialises logging, as per https://github.com/openmicroscopy/bioformats/issues/2233
%     bfInitLogging()
% 
% %% Open CZI file
% % Use low-level bfGetReader to access the file reader without loading all the data    
% czi_reader = bfGetReader(fullFileName);
% 
% % Access the OME metadata
% omeMeta = czi_reader.getMetadataStore();
% 
% % Individual z-slices can be queried using bfGetPlane
% im = bfGetPlane(czi_reader, czi_reader.getIndex(0, 0, 0) +1);  % Check with Doug what this is doing?


% data.czi_reader = bfGetReader([folder filesep files_out(1).name]);
% data.im = bfGetPlane(data.czi_reader, ...
%     data.czi_reader.getIndex(0, 0, 0) + 1);
% data.ome_meta = data.czi_reader.getMetadataStore();
