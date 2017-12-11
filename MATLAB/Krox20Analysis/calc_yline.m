 % Extract  the number of y-values along the impoly edge
 
 function data = calc_yline(controls, data)
 
 % TODO - creata for loop to go through all stored edges (if I am doing at
 % the end may not be able ot use data.current_edge
 % TODO alternative - make this line for each line and use for drawing line
 
    % linspace(data.current_edge(1,2), data.current_edge(2,2));
        
    % Scale linspace to size of line
    data.current_edge_line = linspace(data.current_edge(1,2), ...
        data.current_edge(end,2), (data.current_edge(end,2) - data.current_edge(1,2)));
        
    % Make integer for every y-pixel along the line
    data.current_edge_line = round(data.current_edge_line);
    
    % Transpose y-pixel values along impoly line from a row to a column
    data.current_edge_line = data.current_edge_line.'; 
        
        
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