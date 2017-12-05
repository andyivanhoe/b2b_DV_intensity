function data = add_edge(edg, controls, data)

% Do not do any of the checks that Doug did in original code, such as:
    % check whether current z plane exists in array of stored edges...
% Instead, try to just go to output

    % Z = %TODO - define this as 25%, 50% or 75% to match z-offset, but calculate it...
    %if I just click on the checkboxes to take me to the correct slice,
    %however, I do not need to do this! Add as a feature request to avoid
    %problems later, but right now I think I can ignor it

    vis = 'off';
    if get(controls.hshowchk, 'Value')
        vis = 'on';
    end
    
    if isa(data.current_edge, 'impoly')
        % data.current_edge = data.current_edge.getPosition  % similar to
        % doug's code, but does not work for me --> is it becase I am using
        % impoly while he used imfreehand?
        
        data.current_edge = getPosition(data.current_edge);
        
        % Extract  the number ofy-values along the impoly line using following equation:
        % linspace(data.current_edge(1,2), data.current_edge(2,2));
        
        % Scale linspace to size of line
        % data.current_edge = linspace(data.current_edge(1,2), data.current_edge(2,2), (data.current_edge(2,2) - data.current_edge(1,2)));
        
        % Make integer for every y-pixel along the line
        
        % Alternativies code is: data.current_edge = uint8(data.current_edge); using uint8 instead of round()
        
        % data.current_edge = round(data.current_edge);
        
        % Transpose y-pixel values along impoly line from a row to a column
        % data.current_edge = data.current_edge.'; 
        
        data.edges = [data.edges; Edges()]; % Substructure edges wthin data is now having an extra element added to it called Edges()
        data.edges(end).z = data.curr_z_plane; 
        data.edges(end).(edg) = data.current_edge;  % Going to the end of the edges element ...
        % (which is a substructure within data struct and adding another element called edg - which equals a string 'L' or 'R' and adding this
        
        data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
            data.current_edge(:,2), ...
            'Color', 'r', ...
            'Visible', vis);
        
        % TODO: If the above code works, I need to make it that the
        % appropriate checkbox is ticked
        % Also, how does the current code deal with left edge and right
        % edge separately?
        % Finally (for now), how does the code store the different edge
        % details for each image?
        
        % These edges need to remain on display and there could be an
        % 'Analyze' button that I press and this will them work out
        % basal-to-basal distance and do improfile (or extract values directly from matrix of image intensities)
        % all within a box/boundary of set AP disance (if this box is user
        % coontrollable, great!
        
    else
        % Check that line has been drawn
        disp('Draw edge by clicking on image before pressing edge button')
        
        % How do I make this disp appear in a big box over the image?
        % Otherwise, I guess I can conform myself with seeing it in the
        % workspace
    end
    
end

                
% % %% Chunk
% % 
% % 
% % 
% %     
% % %    data.current_edge_cods = getPosition(data.current_edge); - a better
% % %    way of doing this, based on Doug's code is in the line above.
% % % Is there any problem with reassigning to the same variable name? Or is it
% % % okay because we are dealing with a structure which is not in the
% % % workspace? --> Dynamically renaming variables?
% % % 
% % %     
% % %             
% % %         
% % %      
% %     
% %     
% %     
% %    
% %    
% % %%
% % 
% %         
% %         
% %         
% %         %% Older code I have been playing around with
% %     z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
% %         double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
% % %    t = data.timepoint;
% %     
% %     vis = 'off';
% %     if get(controls.hshowchk, 'Value')
% %         vis = 'on';
% %     end
% %     
% % % 
% % %     
% % %     cods = getPosition(data.current_edge);
% % % 
% % %     y = linspace(cods(1,2), cods(2,2)); % Extract y-values along the impoly line
% % %     y2 = linspace(cods(1,2), cods(2,2), (cods(2,2) - cods(1,2)));    % Scale linspace to size of line        
% % %     y3 = uint8(y2);    % Make integer for every y-pixel along the line
% % %     y3 = y3.';  % Transpose y-pixel values along impoly line from a row to a column
% % %     
% % %     
% %     % update UI
% %     edg_let = {'L', 'R', 'M', 'Rh4', 'Rh6'};
% %     if strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6')
% %         set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
% %         'Value', 1);
% %     else
% % %         if any(data.edges(zs == z).edgeValidity(strcmp(edg_str, edg),:))
% % %             set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
% % %             'Value', 1);
% % %        end
% %     end
% %     show_edges(controls, data);
% %     kids = get(controls.hax, 'Children');
% %     delete(kids(strcmp(get(kids, 'Type'), 'hggroup')));
% % end
% %     
% %     % check whether current z plane exists in array of stored edges...
% %     edg_str = {'L', 'R', 'M'};
% %     if ~isempty(data.edges)
% %         % ts = [data.edges.timepoint];
% %         zs = [data.edges.z];
% %         if any(ts == t)
% %             if any(zs(ts == t) == z)
% %                  data.edges((ts == t) & (zs == z)).timestamp = data.timestamps(t);
% %                 if ~( strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6') )
% %                     if isa(data.current_edge, 'impoly')
% %                         data.current_edge = data.current_edge.getPosition;
% %                     end
% %                     data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
% %                     data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:) = ...
% %                         check_edge_validity(data, data.edges((ts == t) & (zs == z)));
% %                     if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
% %                         data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
% %                     end
% %                 else
% %                     if isa(data.current_edge, 'impoly')
% %                         data.current_edge = data.current_edge.getPosition;
% %                     end
% %                     data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
% % %                     data = calculate_rhombomere_extents(data, controls);
% %                 end
% %                 if isgraphics(data.edges(end).(['hl' edg]))
% %                     delete(data.edges(end).(['hl' edg]));
% %                 end
% %                 if ~( strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6') )
% %                     if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
% %                         data.edges((ts == t) & (zs == z)).(['hl' edg]) = line(data.current_edge(:,1), ...
% %                             data.current_edge(:,2), ...
% %                             'Color', 'r', ...
% %                             'Visible', vis);
% %                     end
% %                 else
% %                     data.edges((ts == t) & (zs == z)).(['hl' edg]) = patch(data.current_edge(:,1), ...
% %                         data.current_edge(:,2), ...
% %                         'r', ...
% %                         'EdgeColor', 'r', ...
% %                         'LineWidth', 2, ...
% %                         'FaceAlpha', 0.25, ...
% %                         'Visible', vis);
% % %                     data.edges(end).(['hl' edg]) = % create overlay patch from binary mask
% %                 end
% %             else
% %                 data.edges = [data.edges; Edges()];
% %                 data.edges(end).timepoint = t;
% %                 data.edges(end).timestamp = data.timestamps(t);
% %                 data.edges(end).z = z;
% %                 if isa(data.current_edge, 'impoly')
% %                     data.current_edge = data.current_edge.getPosition;
% %                 end
% %                 data.edges(end).(edg) = data.current_edge;
% %                 data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
% %                     data.current_edge(:,2), ...
% %                     'Color', 'r', ...
% %                     'Visible', vis);
% %             end
% %         else
% %             data.edges = [data.edges; Edges()];
% %             data.edges(end).timepoint = t;
% %             data.edges(end).timestamp = data.timestamps(t);
% %             data.edges(end).z = z;
% %             if isa(data.current_edge, 'impoly')
% %                 data.current_edge = data.current_edge.getPosition;
% %             end
% %             data.edges(end).(edg) = data.current_edge;
% %             data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
% %                     data.current_edge(:,2), ...
% %                     'Color', 'r', ...
% %                     'Visible', vis);
% %         end
% %     else
% %         data.edges = [data.edges; Edges()];
% %         data.edges(end).timepoint = t;
% %         data.edges(end).timestamp = data.timestamps(t);
% %         data.edges(end).z = z;
% %         data.edges(end).(edg) = data.current_edge;
% %         if ~( strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6') )
% %             data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
% %                         data.current_edge(:,2), ...
% %                         'Color', 'r', ...
% %                         'Visible', vis);
% %         else
% %             data.edges(end).(['hl' edg]) = patch(data.current_edge(:,1), ...
% %                         data.current_edge(:,2), ...
% %                         'r', ...
% %                         'EdgeColor', 'r', ...
% %                         'LineWidth', 2, ...
% %                         'FaceAlpha', 0.25, ...
% %                         'Visible', vis);
% %         end
% %     end
% %     
% %     % update UI
% %     edg_let = {'L', 'R', 'M', 'Rh4', 'Rh6'};
% %     if strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6')
% %         set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
% %         'Value', 1);
% %     else
% %         if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
% %             set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
% %             'Value', 1);
% %         end
% %     end
% %     show_edges(controls, data);
% %     kids = get(controls.hax, 'Children');
% %     delete(kids(strcmp(get(kids, 'Type'), 'hggroup')));
% %     
% %     % check if all edges are saved - if so, allow moving on to the next
% %     % timepoint
% % %     if all(cell2mat(get(controls.hffchecks, 'Value')))
% % %         set(controls.hnextbut, 'Enable', 'on');
% % %     end
% %     
% % end


