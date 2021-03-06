function ap_lengths = calc_ap_lengths(data, edge)


    rhs = [4, 5, 6];
    pix_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    
    for rh = rhs
        if sum(edge.rhombomereLimits) > 0
            ap_lengths.(['Rh' num2str(rh)]) = abs(edge.rhombomereLimits(rh-min(rhs)+2) - ...
                edge.rhombomereLimits(rh-min(rhs)+1)) * pix_to_micron;
            ap_lengths.AllRh = abs(edge.rhombomereLimits(end) - edge.rhombomereLimits(1)) * pix_to_micron;
        else
            ap_lengths.(['Rh' num2str(rh)]) = NaN;
            ap_lengths.AllRh = NaN;
        end
    end
    
%     ap_lengths.AllRh = abs(edge.rhombomereLimits(end) - edge.rhombomereLimits(1)) * pix_to_micron;
    
end