function movieFrames = makeMovieOfProcessedData(imfname, metafname, handles, movfname, frames, fps)
% generate video from processed data frames, overlaying kymograph lines.
% These will be labelled with positions once debug is complete. 
% movieFrames = makeMovieOfProcessedData(imfname, metafname) generates and
% shows frames from the image file imfname and overlays kymographs
% extracted from metadata file metafname. 
% movieFrames = makeMovieOfProcessedData(imfname, metafname, movfname)
% saves the same frames to an avi file with name movfname. 

% DEBUG
% imfname = 'C:\Users\Doug\Desktop\test\280815, Embryo 14 upwards\trimmed_stack_cut_1.tif';
% metafname = 'C:\Users\Doug\Desktop\test\280815, Embryo 14 upwards\trimmed_cutinfo_cut_1.txt';

if nargin < 5
    info = imfinfo(imfname);

    im = zeros(info(1).Height, info(1).Width, length(info));

    for ind = 1:length(info)
        im(:,:,ind) = imread(imfname, ind);
    end

    cutx = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_xcut');
    cuty = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_ycut');
    kymstartx = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_startx');
    kymstarty = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_starty');
    kymendx = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_endx');
    kymendy = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_endy');

    figH = figure;
    set(figH, 'CloseRequestFcn', []);
    image(squeeze(im(:,:,1)));
    colormap gray;
    axis equal tight;
    ax = gca;
    set(ax, 'NextPlot', 'replaceChildren');

    F(length(info)) = struct('cdata',[],'colormap',[]);
    % Scale gray levels to maximum value across all frames. 
    imScale = 64/max(im(:));
    for ind = 1:length(info)

        im1 = squeeze(im(:,:,ind))*imScale;
        image(im1, 'Parent', ax);
        colormap gray
        axis equal tight;
        axis off;
        ax = gca;

        cutLineH  = line(cutx, cuty, 'Color', 'c', 'LineStyle', '-');
        kymLinesH = line([kymstartx; kymendx], [kymstarty; kymendy], 'Color', 'r', 'LineStyle', '--');

        if ~isempty(handles.currentKymInd)
            set(kymLinesH(...
                (round(100*handles.positionsAlongLine) == round(100*handles.currentPosition))), ...
                'Color', 'g');
            % OR
%             set(kymLinesH(...
%                 (round(1000*handles.positionsAlongLine) == round(1000*handles.currentPosition))), ...
%                 'Visible', 'off');
        end
        drawnow

        F(ind) = getframe(ax);

    end

    set(figH, 'CloseRequestFcn', 'closereq');
    close(figH);

    if nargin == 4
        % force save as avi for now...
        [pname, fname, ext] = fileparts(movfname);
        if ~strcmp(ext, 'avi')
            ext = 'avi';
        end

        movfname = [pname filesep fname '.' ext];
        v = VideoWriter(movfname);
        set(v, 'FrameRate', 15);
        open(v);
        writeVideo(v,F);
        close(v);
    end

    movieFrames = F;

else
    % force save as avi for now...
    [pname, fname, ext] = fileparts(movfname);
    if ~strcmp(ext, 'avi')
        ext = 'avi';
    end

    movfname = [pname filesep fname '.' ext];
    v = VideoWriter(movfname);
    set(v, 'FrameRate', fps);
    open(v);
    writeVideo(v,frames);
    close(v);
end