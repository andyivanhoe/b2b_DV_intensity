function outStatses = apLengthCZIHandler(rootPath)
    
    outpath = 'C:\Users\d.kelly\Desktop\TestImagesOut';
    saveFigures = false;
    

    % ensure that bioformats functions are on search path
    dummy = [mfilename('fullpath') '.m'];
    currdir = fileparts(dummy);
    funcPath = [currdir filesep '..'];
    addpath(genpath(currdir));
    addpath(funcPath);

    [filename, pathname, ~] = uigetfile('*.czi', ...
        'Choose CZI file to work on', ...
        rootPath);
    
    % error checking - is file CZI? 
    [~,strpname,ext] = fileparts(filename);
    if ~strcmp(ext, '.czi')
        msgbox('File isn''t CZI!');
        return;
    end
    
    % get metadata, reader object for individual planes
    reader = bfGetReader([pathname filename]);
    omeMeta = reader.getMetadataStore();
    
    % image processing steps
    % 1. Load n-cad channel as a means of checking whether the plane is at
    % an appropriate depth in the embryo
    % 2. Extract krox20 channel and feed to function to determine AP length
    
    zPlaneDepth = double(omeMeta.getPixelsPhysicalSizeZ(0).value);
    pix2um = double(omeMeta.getPixelsPhysicalSizeX(0).value);
    nZPlanes = double(omeMeta.getPixelsSizeZ(0).getValue());
    nChannels = double(omeMeta.getPixelsSizeC(0).getValue());
    
    smallestAreas = [];
    outStatses = [];
    
    if saveFigures
        hfig = figure;
    else
        hfig = [];
    end
    
    for zidx = 1:nZPlanes
        
       % use krox20 channel
       fprintf('Current z plane = %d\n\n', zidx);
       C = 2;
       iPlane = reader.getIndex(zidx - 1, C - 1, 0) + 1;
       im = bfGetPlane(reader, iPlane);
       [imStats, outStats] = apLength(im, pix2um, hfig);
       
       if saveFigures
            savefig(hfig, [outpath filesep sprintf('Zplane = %d', zidx)]);
            print(hfig, [outpath filesep sprintf('Zplane = %d', zidx)], '-dpng', '-r300');
       end
       
       
       % check whether sizes of "rhombomeres" are appropriate, and thus
       % whether z plane is suitable. Assume correct id of rhombomeres in
       % first (deepest) z plane
       smallestArea = imStats(2).Area;
       smallestAreas = [smallestAreas; smallestArea];
       if length(smallestAreas) > 5
           threshArea = 0.75 * mean(smallestAreas(1:5));
           if smallestArea < threshArea
               break;
           end
       end      
       outStatses = [outStatses; outStats];
    end
    
    % remove last 20 um (i.e. shallowest 20 um) from outstats
    idxToZeroDepth = length(outStatses);
    twentyMicronsIndex = round(20/zPlaneDepth);
    outStatses = outStatses(1: end - twentyMicronsIndex);
    
    close(hfig);
    
    % output data to excel
    zs = 1:length(outStatses);
    res = [zs' [(idxToZeroDepth - zs)*zPlaneDepth]' [outStatses.minD]' [outStatses.maxD]' [outStatses.meanD]' [outStatses.medianD]'];
    csvwrite([outpath filesep strpname ' results.csv'], res);