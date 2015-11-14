%% TO GET QUANTITATIVE DATA FROM KYMOGRAPHS
num_kyms = 10;
results = [];
for kpos = 1:num_kyms
    result.kym_number = kpos;
% - trim kymograph - initially first 20 frames (=4 seconds)
    kym_segment = squeeze(avg_kym_stack(144:164,:,kpos))';
%     correct_membrane = zeros(size(kym_segment,1), size(kym_segment,2), num_kyms);
% - use canny edge filter to get binary image of membrane front movement
    filt_kym = edge(kym_segment, 'canny');
    result.kym_segment = kym_segment;
    figure;
    subplot(1,4,1);
    imagesc(kym_segment);
    axis equal tight;
    subplot(1,4,2);
    imagesc(filt_kym); 
    axis equal tight; 
    colormap gray;
    subplot(1,4,3);
    l = bwlabel(filt_kym);
    imagesc(l);
    r = regionprops(filt_kym);
    % Sort regions by y position (centroid)
    dpos = [];
    for i = 1:length(r)
        dpos = [dpos; r(i).Centroid(2)];
    end
    [dpos, I] = sort(dpos);
    % Then check the time extent of the trace for each of these in order;
    % the first one that is found that extends more than 80% of the trace
    % is considered to be the right one
    % N.B. this may (will?) break down in case when we have more than the
    % first four seconds as the canny edge might be discontinuous. 
    found = false;
    i = 1;
    while (found == false)
        
        if (r(I(i)).BoundingBox(3) > size(filt_kym,2)*.8)
            found = true;
        else
            i=i+1;
        end
        % Break out of loop if a sensible edge hasn't been found
        if (i > length(dpos))
            found = true;
        end
    end
    if (i < length(dpos))
        % Identify only the highest edge - perform loop through each column
        % and choose the first pixel:
        % - choose the highest edge to represent the membrane front, extract t, d
        % co-ordinates for this edge...
        t = []; d = [];
        correct_membrane = (l == I(i));
        
        for tind = 1:size(correct_membrane,1)
            point_sel = false;
            tind
            for dind = 1:size(correct_membrane,2)
                dind
                if (not(point_sel)) && ( correct_membrane(tind, dind) > 0 )
                        point_sel = true;
                        correct_membrane(tind, dind) = 1;
                        t = [t; tind];
                        d = [d; dind];
                else
                    correct_membrane(tind, dind) = 0;
                end
           
            end
        
        end
        result.t = t;
        result.d = d;
    end
    subplot(1,4,4);
    imagesc(correct_membrane);
    
    results = [results; result];

% - fit curve to this data (first order is a straight line, goodness of fit
% tells us how linear motion actually is, discuss with supervisors what
% alternative models to fit)
% - convert to um/second


end
% OUTPUT FOR SUPERVISORS:
% 

% h_kymline = line([kym_startx(1); kym_endx(1)], [kym_starty(1); kym_endy(1)], 'Color', 'r', 'LineWidth', 3);