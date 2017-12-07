function data = add_edge(edg, controls, data)
    
    vis = 'off';
    if get(controls.hshowchk, 'Value')
        vis = 'on';
    end
    
    if ~isa(data.current_edge, 'impoly')
        
        disp('Draw edge by clicking on image before pressing edge button')
        return
        
    else
        % I need to put in a check here that checks the edge spans the top
        % to bottom of the red box placed over the image - wrap this up in
        % an edge validity function
        % If edge does not span the box:
        
        % disp('Ensure completely covers 80 micron box, from top to
        % bottom')
        % return
        % else...
        
        % Now I put in my check for whether current z plane exisits in array of stored edges...
        
        data.current_edge = getPosition(data.current_edge);
        
        data.edges = [data.edges; Edges()]; % Substructure edges wthin data is now having an extra element added to it called Edges()
        data.edges(end).z = data.curr_z_plane; 
        data.edges(end).(edg) = data.current_edge;  % Going to the end of the edges element ...
        % (which is a substructure within data struct and adding another element called edg - which equals a string 'L' or 'R' and adding this
        
        data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
            data.current_edge(:,2), ...
            'Color', 'r', ...
            'Visible', vis);
    end
end
%     if isa(data.current_edge, 'impoly')
%                 
%         data.current_edge = getPosition(data.current_edge);
%         
%        
%         
%         data.edges = [data.edges; Edges()]; % Substructure edges wthin data is now having an extra element added to it called Edges()
%         data.edges(end).z = data.curr_z_plane; 
%         data.edges(end).(edg) = data.current_edge;  % Going to the end of the edges element ...
%         % (which is a substructure within data struct and adding another element called edg - which equals a string 'L' or 'R' and adding this
%         
%         data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
%             data.current_edge(:,2), ...
%             'Color', 'r', ...
%             'Visible', vis);
%     else
%         % Check that line has been drawn
%         disp('Draw edge by clicking on image before pressing edge button')
%         
%     end
    
% Remove this 'end' once I get update UI code working

% update UI
%     edg_let = {'L', 'R'};
%     if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
%         set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
%         'Value', 1);
%     end
% end
%     show_edges(controls, data);
%     kids = get(controls.hax, 'Children');
%     delete(kids(strcmp(get(kids, 'Type'), 'hggroup')));
                
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


