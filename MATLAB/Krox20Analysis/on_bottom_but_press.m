function on_bottom_but_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    current_z_ind = get(controls.hzsl, 'Value');
    
    disp(current_z_ind);
    
    for zr = controls.hzradios
        set(zr, 'Enable', 'on');
    end
    
    set(controls.hsetbotbut, 'Enable', 'off');
    set(controls.hplacebox, 'Enable', 'on');
    set(controls.hzradios(1), 'Value', 0);
    set([controls.hledgebut, controls.hredgebut], 'Enable', 'on');
    
    data.bottom_slice_index = round(current_z_ind);
    setappdata(controls.hfig, 'data', data);

    
%     eventdata.NewValue = controls.hzradios(1);
%     on_z_slice_selection_changed(hObject, eventdata, [], controls);
    
%     data.edges = [data.edges; Edges()];

%     setappdata(controls.hfig, 'data', data);
    
