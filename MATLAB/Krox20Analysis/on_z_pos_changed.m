function on_z_pos_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    data.curr_z_plane = round(get(hObject, 'Value'));
    %fprintf('z = %d of %d\r\n', data.curr_z_plane, 'Max'));
    %data.curr_c_plane = round(get(controls.hcsl, 'Value'));
    update_image(controls)
    
    % enable edge selection only if a relevant frame is displayed
    edge_buts = [controls.hledgebut, controls.hredgebut];
    rh_buts = [controls.hrh4but, controls.hrh6but];
    if (isfield(data, 'top_slice_index') && isfield(data, 'bottom_slice_index'))
        if (~isempty(data.top_slice_index) && ~isempty(data.bottom_slice_index))
            
            target_slices = round(data.bottom_slice_index + data.z_offsets * (data.top_slice_index - data.bottom_slice_index));

            if any(data.curr_z_plane == target_slices)
                if any(strcmp(data.channel_names, 'Krox20'))
                    rhombomere_im = bfGetPlane(data.czi_reader, ...
                        data.czi_reader.getIndex(data.curr_z_plane - 1, ....
                        find(strcmp(data.channel_names, 'Krox20')) - 1, 0) + 1);
                    data = detect_rhombomeres(controls, data, rhombomere_im);
                end
                if strcmp(data.channel_names{data.curr_c_plane}, 'Krox20')
                    set(rh_buts, 'Enable', 'on');
                    set(edge_buts, 'Enable', 'off');
                else
                    set(edge_buts, 'Enable', 'on');
                    set(rh_buts, 'Enable', 'off');
                end
            else
                set([edge_buts rh_buts], 'Enable', 'off');
            end
        else
            set([edge_buts rh_buts], 'Enable', 'off');
        end
        
    else
        set([edge_buts rh_buts], 'Enable', 'off');
    end
    
    setappdata(controls.hfig, 'data', data);
