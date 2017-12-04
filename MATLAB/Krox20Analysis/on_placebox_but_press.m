function on_placebox_but_press(hObject, eventdata, handles, controls)
    
    % Get current app data struc - check this is what this line of code
    % does
    data = getappdata(controls.hfig, 'data');
    
    % Work on height of box - currently set to 80. I want it to be 80
    % MICRONS
    rectangle('Position', [0, round(data.stackSizeY * 0.16), data.stackSizeX, ...
        (80 / double(data.ome_meta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROM)))], ...
        'EdgeColor', 'r')
    
    data.box_top_y = round(data.stackSizeY * 0.16)
     
    data.box_bottom_y = round(data.stackSizeY * 0.16) +  (80 / double(data.ome_meta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROM)))
    
end

% 
% % What do these rotations do in Doug's calc_bb_distances?
%         theta = -deg2rad(edge.tissueRotation);  
%         rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
%         
%         c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
%             double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
%         
%         pix_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
% 
% 
% %         data.stackSizeY = data.ome_meta.getPixelsSizeY(0).getValue(); % image height, pixels 
%     
%         % Check this equals Y pixel size
%         data.pixelSizeY = double(data.ome_meta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROM))
%         
%         y_height_microns = data.stackSizeY * data.pixelSizeY
%         
%         
%     % get z index
%         z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
%         slices_relative_to_top = round(edge.z ./ z_ind_to_micron_depth);
%         z_index = data.top_slice_index - slices_relative_to_top;
%         c = find(strcmp(data.channel_names, 'Ncad'));
% 
%         im = bfGetPlane(data.czi_reader, ...
%             data.czi_reader.getIndex(z_index - 1, c - 1, 0) + 1);