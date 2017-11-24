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
    
    setappdata(controls.hfig, 'data', data);
    
%    cods = getPosition(data.current_edge); % Not sure if this line is working
    
%    cods = getPosition(data.current_edge);
%     y = linspace(cods(1,2), cods(2,2)); % Extract y-values along the impoly line
%     y2 = linspace(cods(1,2), cods(2,2), (cods(2,2) - cods(1,2)));    % Scale linspace to size of line        
%     y3 = uint8(y2);    % Make integer for every y-pixel along the line
%     data.current_edge = y3.';  % Transpose y-pixel values along impoly line from a row to a column
%     
%   
% 
%     data.current_edge_cods = getPosition(data.current_edge);
% 
%     data.y = linspace(data.current_edge_cods(1,2), data.current_edge_cods(2,2)); % Extract y-values along the impoly line
%     data.scaled_y = linspace(data.current_edge_cods(1,2), data.current_edge_cods(2,2), (data.current_edge_cods(2,2) - data.current_edge_cods(1,2)));    % Scale linspace to size of line        
%     data.integer_y = uint8(data.scaled_y);    % Make integer for every y-pixel along the line
%     data.integer_y_transpose = data.integer_y.';  % Transpose y-pixel values along impoly line from a row to a column
%     
%     
%     setappdata(controls.hfig, 'data', data);
    
end    