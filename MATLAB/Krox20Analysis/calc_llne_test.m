 % Extract  the number of y-values along the impoly line using following equation:
        % linspace(data.current_edge(1,2), data.current_edge(2,2));
        
        % Scale linspace to size of line
        % data.current_edge = linspace(data.current_edge(1,2), data.current_edge(2,2), (data.current_edge(2,2) - data.current_edge(1,2)));
        
        % Make integer for every y-pixel along the line
        
        % Alternativies code is: data.current_edge = uint8(data.current_edge); using uint8 instead of round()
        
        % data.current_edge = round(data.current_edge);
        
        % Transpose y-pixel values along impoly line from a row to a column
        % data.current_edge = data.current_edge.'; 
        
        
          % TODO: If the above code works, I need to make it that the
        % appropriate checkbox is ticked
        
        % How does the code store the different edge details for each image?
        
        % These edges need to remain on display and there could be an
        % 'Analyze' button that I press and this will them work out
        % basal-to-basal distance and do improfile (or extract values directly from matrix of image intensities)
        % all within a box/boundary of set AP disance (if this box is user
        % coontrollable, great!
        
                % How do I make this display appear in a big box over the image?
        % Otherwise, I guess I can conform myself with seeing it in the
        % workspace