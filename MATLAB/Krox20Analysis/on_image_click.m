% function on_image_click(hObject, eventdata, handles, controls)
% 
%     data = getappdata(controls.hfig, 'data');
%     
%     kids = get(controls.hax, 'Children');
%     delete(kids(strcmp(get(kids, 'Type'), 'hggroup')))
% 
%    %closed = strcmp(data.channel_names{data.curr_c_plane}, 'Krox20');
%    % try
%     data.current_edge = imfreehand(controls.hax, 'Closed');
%    % end
% %     data.current_edge = M1.getPosition;
% 
%     setappdata(controls.hfig, 'data', data);
%     
% end


function on_image_click(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')))

    data.current_edge = impoly(controls.hax, 'Closed',false);
    
    cods = getPosition(data.current_edge);
    
    y = linspace(cods(1,2), cods(2,2)); % Extract y-values along the impoly line
    
    %%TODO: replace 42 with 
    y2 = linspace(cods(1,2), cods(2,2), (cods(2,2) - cods(1,2)));    % Scale linspace to size of line
    
       
    y3 = uint8(y2);    % Make integer for every y-pixel along the line
    y3 = y3.';  % Transpose y-pixel values along impoly line from a row to a column
    
    setappdata(controls.hfig, 'data', data);
    
end    