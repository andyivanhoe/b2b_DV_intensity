function on_z_slice_selection_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    selection_ind = eventdata.NewValue;

    target_slice = round(data.bottom_slice_index + data.z_offsets((controls.hzradios == selection_ind)) * (data.top_slice_index - data.bottom_slice_index));
    
    set(controls.hzsl, 'Value', target_slice);
    on_z_pos_changed(controls.hzsl, eventdata, handles, controls);
    update_image(controls);
    
%     setappdata(controls.hfig, 'data', data);

end