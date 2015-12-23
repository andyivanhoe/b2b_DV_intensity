function [stack, md] = kymographPreprocessing(stack, metadata, userOptions)
%kymographPreprocessing applies preprocessing steps to images from 
% timelapse data

% See also quantitativeKymographs

md = metadata;
kp = md.kym_region;
uO = userOptions;

if (uO.kymDownOrUp)
    direction = ' upwards';
else
    direction = ' downwards';
end

dir_txt = sprintf('%s, Embryo %s%s', md.acquisitionDate, md.embryoNumber, direction);

if ~isdir([uO.outputFolder filesep dir_txt]) && (uO.savePreprocessed)
    mkdir([uO.outputFolder filesep dir_txt])
end

output_path = [uO.outputFolder filesep dir_txt filesep sprintf('trimmed_stack_cut_%d.tif', md.cutNumber)];
cutDataPath = [uO.outputFolder filesep dir_txt];
redoPreprocess = false;

if (uO.loadPreprocessedImages) && (exist(output_path, 'file') == 2)
    try
        stack = loadMultipageTiff(output_path);
        [md, redoPreprocess] = loadAndCheckMetadata(cutDataPath, uO);
        md.isCropped = true;
    catch
        redoPreprocess = true;
    end
    
end

if (redoPreprocess) || ~uO.loadPreprocessedImages || (exist(output_path, 'file') ~= 2)
    
    %% Let user know if they intended to use loaded images but program can't find them and is preprocessing anew...
    if (uO.loadPreprocessedImages)
        errString = 'Can''t find preprocessed images to load; reprocessing...';
        errorLog(uO.outputFolder, errString);
    end
    
    %% First, trim image to fit around the kymograph regigon
    tic
    disp('Trimming...')
    stack = stack(kp.boundingBox_LTRB(2):kp.boundingBox_LTRB(4),...
        kp.boundingBox_LTRB(1):kp.boundingBox_LTRB(3),:);
    t = toc;
    timeStr = sprintf('Trimming E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
    errorLog(uO.outputFolder, timeStr);
    md.isCropped = true;

    %% Then perform median filtering
    tic
    disp('Median filtering...')
    for ind = 1:size(stack, 3)
        image = squeeze(stack(:,:,ind));
        %% -------------------------------------------------------------------
        % EITHER threshold based on median filter OR threshold based on median
        % value
        % -------------------------------------------------------------------%%

    %     med = median(image(:));
    %     thresh = ones(size(image))*med;

        thresh = medfilt2(image, [uO.medianFiltKernelSize uO.medianFiltKernelSize]);
    %     thresh = medfilt2(image, [50 50]);
        image(image < thresh) = 0;

        %% -------------------------------------------------------------------
        % Perform erosion followed by dilation on a binary image to get rid of
        % single pixel noise, then use this binary mask to get rid of single
        % pixel noise in the thresholded data
        % -------------------------------------------------------------------%%

        binary_im = (image > 0);
        se = strel('disk', 1);
        binary_im = imerode(binary_im, se);
        binary_im = imdilate(binary_im, se);
        image(binary_im == 0) = 0;

        stack(:,:,ind) = image;
    end
    t = toc;
    timeStr = sprintf('Median filtering E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
    errorLog(uO.outputFolder, timeStr);

    %% Finally rotate image so that kymographs lie along a vertical column of 
    %  pixels...
    % tic
    % disp('Rotating...')
    % stack = imrotate(stack, radtodeg(md.cutTheta));
    % t = toc;
    % timeStr = sprintf('Rotating E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
    % errorLog(uO.outputFolder, timeStr);

    %DEBUG - check that cut is in right place on processed image...
    firstFigure(squeeze(stack(:,:,1)), md, uO);

    if uO.savePreprocessed

        saveMultipageTiff(stack, output_path);
        saveMetadata(cutDataPath, md, uO)
        
    end

end