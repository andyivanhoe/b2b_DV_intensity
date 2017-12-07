function on_edge_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

% Commenting out the below lines will hopefully bypass add_edge.m
    edg = get(hObject, 'Tag');
    data = add_edge(edg, controls, data);
% %     if (strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6'))
% %        data = calculate_rhombomere_extents(data, controls); 
% %     end
    
   setappdata(controls.hfig, 'data', data);
    
end