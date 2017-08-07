function attach_callbacks(controls)

    set(controls.hzsl, 'Callback', {@on_z_pos_changed, [], controls});
    set(controls.hcsl, 'Callback', {@on_c_pos_changed, [], controls});
    set(controls.hsettopbut, 'Callback', {@on_top_but_press, [], controls});
    set(controls.hradiogroup, 'SelectionChangeFcn', ...
        {@on_z_slice_selection_changed, [], controls});
    set(controls.hax, 'ButtonDownFcn', {@on_image_click, [], controls});
    set(controls.hredgebut, 'Callback', ...
        {@on_edge_button_press, [], controls});
    set(controls.hledgebut, 'Callback', ...
        {@on_edge_button_press, [], controls});
    set(controls.hmidlbut, 'Callback', ...
        {@on_edge_button_press, [], controls});
    set(controls.hshowchk, 'Callback', ...
        {@on_showedges_changed, [], controls});
    set(controls.hnextbut, 'Callback', ...
        {@on_next_button_press, [], controls});
    
end