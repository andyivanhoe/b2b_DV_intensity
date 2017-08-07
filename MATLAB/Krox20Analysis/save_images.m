function save_images(controls, data)

    % get z positions
    z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
    slices_relative_to_top = round(data.z_offsets ./ z_ind_to_micron_depth);
    z_planes = data.top_slice_index - slices_relative_to_top;
    
    % get edges data
    ts = [data.edges.timepoint];
    zs = [data.edges.z];
    
    % get XY scaling
    pix2micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    scale_bar_length_pix = round(data.scale_bar_length_um / pix2micron);
    
    for z_pos = data.z_offsets
        for chidx = 1:length(data.channel_names)
            z_fldr = sprintf('z = %0.2f um', z_pos);
            of = [data.out_folder filesep z_fldr];
            mkdir(of);

            im = bfGetPlane(data.czi_reader, ...
                data.czi_reader.getIndex((z_planes(data.z_offsets == z_pos)) - 1, chidx - 1, 0) + 1);

            % save tiffs, for now without edges
            imwrite(im, [of filesep sprintf('%s, t = %0.2f.tif', ...
                data.channel_names{chidx}, data.timepoint)]);

            % save png with edges and scale bar
            hfig_temp = figure('Visible', 'off');
            hax_temp = axes;
            imagesc(im);
            edges = data.edges((ts == data.timepoint) & (zs == z_pos));
            edgstr = {'L', 'M', 'R'};
            colormap gray;
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            axis equal tight;

            % loop through and draw edges
            for edg = edgstr
                line(edges.(edg{1})(:,1), ...
                    edges.(edg{1})(:,2), ...
                    'Color', 'r', ...
                    'Parent', hax_temp);
            end

            % add scale bar
            hscl = line([0.95 * size(im, 2) - scale_bar_length_pix, 0.95 * size(im, 2)], ...
            [0.95 * size(im, 1), 0.95 * size(im, 1)], ...
            'Color', 'w', ...
            'LineWidth', 3, ...
            'Parent', hax_temp);

            savefig(hfig_temp, [of filesep sprintf('%s, t = %0.2f.fig', ...
                data.channel_names{chidx}, data.timepoint)]);
            print(hfig_temp, [of filesep sprintf('%s, t = %0.2f.png', ...
                data.channel_names{chidx}, data.timepoint)], '-dpng', '-r300');

            close(hfig_temp);

        end
    end
  
end