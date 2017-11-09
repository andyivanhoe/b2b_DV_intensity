function on_top_but_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    current_z_ind = get(controls.hzsl, 'Value');

    disp(current_z_ind);
    
    if any(cell2mat(get(controls.hffchecks, 'Value')))
       answer = questdlg(['Resetting top slice will remove existing edges. '...
           'Continue?'], 'Warning!', 'Yes', 'No', 'No');
       if strcmp(answer, 'No')
           return;
       else
           % remove stored edges from data structure
           % reset the checkboxes showing which edges are stored
       end
    end
    
    set(controls.hsetbotbut, 'Enable', 'on');

    data.top_slice_index = round(current_z_ind);
    setappdata(controls.hfig, 'data', data);    
%     data.edges = [data.edges; Edges()];

%     setappdata(controls.hfig, 'data', data);
    
