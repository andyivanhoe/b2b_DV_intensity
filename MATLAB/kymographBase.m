function output = kymographBase(varargin)
% kymographBase takes a directory containing data directories as an
% argument and performs all steps for generation of quantitative kymograph
% data. 

    %% User variables for setting up kymographs
    userOptions.forcedSpeedRange = [-1.5 1.5];          % speed [min max]
    userOptions.forcedPositionRange = [-5 20];      % position um [min max]
    
    userOptions.fixedNumberOrFixedSpacing = true;   % false = fixed number of kym; true = fixed spacing between kym in um.                      Default = true;
    userOptions.kymSpacingUm = 1;                   % Kymograph spacing in um.                                                                  Default = 1;
    userOptions.number_kym = 10;                    % Number of kymographs calculated per cut.                                                  Default = 10
    userOptions.kymDownOrUp = true;                % false = investigate movement below cut; true = investigate movement above cut.            Default = false;
    
    userOptions.timeBeforeCut = 5;                  % Time in seconds before cut for kymograph to start.                                        Default = 5
    userOptions.timeAfterCut = 10;                  % Time in seconds after cut for kymograph to end.                                           Default = 10
    
    userOptions.kym_width = 5;                      % Width of region kymograph calculated over, pix. Must be odd.                              Default = 9
    userOptions.kym_length = 50;                    % Length of region kymograph calculated over, pix.                                          Default = 50
    
    userOptions.loadPreprocessedImages = false;
    userOptions.scale_bar_length = 20;              % Length of scale bar in images, um.                                                        Default = 20
    userOptions.outputFolder = 'C:\Users\Doug\Desktop\test2';
    userOptions.saveFirstFrameFigure = true;        % Save first figure?                                                                        Default = true
    userOptions.firstFigureTitleAppend = '' ;       % Text to append to the title of the first figure.                                          Default = ''
    userOptions.saveCutPositioningFigs = false;     % Toggle saving of helper images for checking cut positioning.                              Default = false
    userOptions.removeCutFrames = true;             % Toggle removal of frames with scattered light.                                            Default = true
    userOptions.figHandle = figure;                 % Allow figures to be rendered in a single window. 
    userOptions.savePreprocessed = true;            % Save stack of images following preprocessing with cut position information.               Default = true
    userOptions.avgOrMax = 1;                       % Choose between averaging (1) or taking max over (2) the kym_width per kym.                Default = 1
    userOptions.medianFiltKernelSize = 50;           % Size of median filter kernel in pixels - reduce for increased speed...                   Default = 50
    userOptions.preProcess = true;                  % Toggle pre-processing on or off                                                           Default = true
    userOptions.showKymographOverlapOverlay = true;
    
    userOptions.basalMembraneKym = false;
    userOptions.usePreviouslySavedBasalPos = false;

    narginchk(1, 2);
    if nargin == 1
        root = varargin{1};
    elseif nargin == 2
        root = varargin{1};
        userOptions.kymDownOrUp = varargin{2};
    end
    
    output.userOptions = userOptions;
    output.metadata = [];
    output.stack = [];
    output.kymographs = [];
    output.results = [];        

    %% Find all directories in the root directory
    dirs = dir([root filesep '*_*']);
    dirs = dirs([dirs.isdir]);
    
    getAllBasalMembranePositions(dirs, root, userOptions)
    if userOptions.basalMembraneKym
        userOptions.outputFolder = [userOptions.outputFolder filesep 'Basal'];
        mkdir(userOptions.outputFolder);
    else
        userOptions.outputFolder = [userOptions.outputFolder filesep 'Apical'];
        mkdir(userOptions.outputFolder);
    end
    
    
    try

        % Loop through these (tiff-containing) data directories
        for dind = 1:length(dirs)

           d = dirs(dind).name;
           % Identify how many cuts were performed on this embryo
           curr_path = [root filesep d];
           num_cuts = length(dir([curr_path filesep '*.txt']))/2;

           for cut_ind = 0:num_cuts-1

               %% Get metadata for current cut
               curr_metadata = getMetadata(curr_path, cut_ind);
               output.metadata = [output.metadata; curr_metadata];
               disp(['Date: ' curr_metadata.acquisitionDate...
                   ', Embryo: ' curr_metadata.embryoNumber...
                   ', cut: ' num2str(curr_metadata.cutNumber)])

               %% Get frames from  A seconds before cut to B seconds after cut
               A = userOptions.timeBeforeCut;
               B = userOptions.timeAfterCut;
               frames = floor(curr_metadata.cutFrame ...
                   - A/curr_metadata.acqMetadata.cycleTime) + 2 : ceil(curr_metadata.cutFrame ...
                   + B/curr_metadata.acqMetadata.cycleTime) + 2; 
               
               if userOptions.basalMembraneKym
                   stack = zeros(612,612,length(frames));
               else
                    stack = zeros(512,512,length(frames));
               end

               %% Block out frames with scattered light from cut
               ind = 1;
              block_frames = ceil(curr_metadata.cutMetadata.time/(1000 * curr_metadata.acqMetadata.cycleTime));

               
               for frame_ind = frames(1):frames(end)  
                   
                       try
                           if userOptions.basalMembraneKym
                                stack(51:562,51:562,ind) = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]);
                           else
                                stack(:,:,ind) = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]);
                           end
                        catch ME
                            errString = ['Error: ' ME.identifier ': ' ME.message];
                            errorLog(userOptions.outputFolder, errString);
                       end
                       
                   ind = ind+1;
               end
               
               if userOptions.removeCutFrames
                   msk = intensityScatterFinderV2(stack, curr_metadata.cutFrame + 2 - frames(1), block_frames);
                   stack(:,:,msk) = 0;
               end

                %% Find position of cut, and generate first output figure: 
                %   the first frame of the stack with cut line and kymograph
                %   lines overlaid, along with a scale bar. 
                
                %% deal with basal membrane kymographing
                if userOptions.basalMembraneKym
                    % get kym positions from files
                    curr_metadata = getKymographPositionMetadata(userOptions, curr_metadata, curr_path);
                else
                    curr_metadata.kym_region = placeKymographs(curr_metadata, userOptions);
                end
%                 curr_metadata = manualBasalMembraneKymographPositioning(squeeze(stack(:,:,1)), userOptions, curr_metadata);

                % FOR NOW (01/12/2015) do this three times with start, end and
                % just after cut images
                userOptions.firstFigureTitleAppend = sprintf(', %d s pre-cut', A);
                curr_metadata.kym_region = firstFigure(squeeze(stack(:,:,1)), curr_metadata, userOptions);
                
                if ~userOptions.basalMembraneKym
                    curr_metadata = findDistanceToMidline(stack, curr_metadata);
                end
                
                if (userOptions.saveCutPositioningFigs)
                    userOptions.firstFigureTitleAppend = ', immediately post-cut';
                    firstFigure(squeeze(stack(:,:,find(frames == curr_metadata.cutFrame)+4)), curr_metadata, userOptions);
                    userOptions.firstFigureTitleAppend = sprintf(', %d s post-cut', B);
                    firstFigure(squeeze(stack(:,:,end)), curr_metadata, userOptions);
                    userOptions.firstFigureTitleAppend = sprintf(', multipage');
                    testCutPositioningSlow(stack, curr_metadata, userOptions);
                    userOptions.firstFigureTitleAppend = sprintf(', multipage fast');
                    testCutPositioningFast(stack, curr_metadata, userOptions);
                end
                
                
               %% Pre-process images in stack
               [stack, curr_metadata] = kymographPreprocessing(stack, curr_metadata, userOptions);
               
               %% Plot and save kymographs
               kymographs = plotAndSaveKymographsSlow(stack, curr_metadata, userOptions);
               results = extractQuantitativeKymographData(kymographs, curr_metadata, userOptions);
%                output.results = cat(2, output.results, results);
%                output.kymographs = cat(4, output.kymographs, kymographs);
               
           end

        end
        
        if nargin == 1
            imDone();
        end

    catch ME
        beep;
        uiwait(msgbox(['Error on line ' num2str(ME.stack(1).line) ' of ' ME.stack(1).name ': ' ME.identifier ': ' ME.message], 'Argh!'));
        rethrow(ME);
    end
    
    close all;
end