function kym_positioning = firstFigure(frame, md, uO)
% firstFigure takes the first frame of a stack, the metadata pertaining to
% it and the pertinent user options and saves a figure with the cut and the
% kymograph lines overlaid, along with a scalebar. It returns the data
% pertaining to the positioning of the kymographs. 


%% work out where the cut and kymograph lines should go
kym_positioning = placeKymographs(md, uO);
kp = kym_positioning;

if (uO.saveFirstFrameFigure)
    
    %% Plot figure with first frame
    title_txt = sprintf('%d, Embryo %d, Cut %d', md.acquisitionDate, ...
        md.embryoNumber, md.cutNumber);
    dir_txt = sprintf('%d, Embryo %d', md.acquisitionDate, md.embryoNumber);    
    title_txt = [title_txt uO.firstFigureTitleAppend];
    
    if ~isfield(uO, 'figHandle')
        h = figure('Name', title_txt,'NumberTitle','off');
    else
        h = uO.figHandle;
        set(uO.figHandle, 'Name', title_txt,'NumberTitle','off');
        set(0, 'currentFigure', uO.figHandle)
    end
    
    imagesc(frame);
    axis equal tight;
    colormap gray;
    
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca, 'ytick', [])
    set(gca,'yticklabel',[])
    title(title_txt);
    
    %% Add lines for cut and kymograph
    h_cutline = line(kp.xcut, kp.ycut, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2);
    h_kymline = line([kp.kym_startx; kp.kym_endx], [kp.kym_starty; kp.kym_endy], 'Color', 'r');
    
    %% Handle placement of the scale bar
    scx = [0.95 * size(frame,1) - uO.scale_bar_length/md.umperpixel 0.95 * size(frame,1)];
    scy = [0.95 * size(frame,2) 0.95 * size(frame,2)];
    scline = line(scx, scy, 'Color', 'w', 'LineWidth', 6);
    scstr = [num2str(uO.scale_bar_length) ' \mum'];
    
    % these fields will likely need tweaking! - need to work out the extent
    % of the text box in order to do this properly
    nudgex = -25;
    nudgey = 470;
    sctxt = text(nudgex + scx(1) + (scx(2) - scx(1))/2, nudgey, scstr);
    set(sctxt, 'Color', 'w');
    set(sctxt, 'FontSize', 14);
    
    set(h, 'Units', 'normalized')
    set(h, 'Position', [0 0 1 1]);
    
    if ~isdir([uO.outputFolder filesep dir_txt])
        mkdir([uO.outputFolder filesep dir_txt])
    end
    out_file = [uO.outputFolder filesep dir_txt filesep title_txt];
    print(out_file, '-dpng', '-r300');
    savefig(h, [out_file '.fig']);
    
    if ~isfield(uO, 'figHandle')
        close(h);
    end
    
end