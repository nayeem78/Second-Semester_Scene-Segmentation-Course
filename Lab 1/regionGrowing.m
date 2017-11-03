%
%Author : Shubham Wagh, Nayee Muddin Khan
%Created on : 23/02/2017

%Region Growing function
%Input: Threshold vale, Neighborhood: 4 or 8 point connectivity
%Output: Segmented image, number of segements
function [output_segImage, numberOfRegions] = regionGrowing(input_Image, threshold, Neighborhood)


    im = input_Image;
    % Get the image dimensions
    [row, col, dim] = size(im);
    % Declare mean variable as an array with length dim:
    % if image is colored: dim == 3; else dim = 1;
    mean = zeros(1, dim);
   
    F = []; %zeros(height*width, 2);
    % Array for segmentation result
    output_segImage = zeros(row, col);
    % Const array for neighbourhood operations
    x_neighbor_direction = [0, 1, 0, -1, 1, -1, 1, -1];
    y_neighbor_direction = [-1, 0, 1, 0, 1, 1, -1, -1];
    % 4 or 8 connectivity
    nN = 8;
    if Neighborhood == 4 || Neighborhood == 8
        nN = Neighborhood;
    end;
    % Define the threshold
    T = threshold;
    % Initial number of regions
    nR = 0;

    % Region growing algorithm
    %tic
    for i = 1 : row
        for j = 1 : col
            % if the pixel at (i, j) doesn't belong to any region
            if output_segImage(i, j) == 0
               l = 1;        %variable pointing to the first element of the queue        
               r = 1;        %variable pointing to the end of the queue        
               mean(:) = im(i, j,:); 
               F(l, 1) = i;      
               F(l, 2) = j;      
               n = 1;                
               nR = nR + 1;         
               output_segImage(i, j) = nR;       
               while l <= r         
                   x_c = F(l, 1); 
                   y_c = F(l, 2); 
                   for k = 1 : nN    
                      
                       if x_c+x_neighbor_direction(k) > 0 && x_c+x_neighbor_direction(k) <= row && y_c+y_neighbor_direction(k) > 0 && y_c+y_neighbor_direction(k) <= col && output_segImage(x_c+x_neighbor_direction(k), y_c+y_neighbor_direction(k)) == 0
                       
                           tmp = zeros(1, dim);
                           tmp(:) = im(x_c+x_neighbor_direction(k), y_c+y_neighbor_direction(k), :);
                           euclidean = norm(tmp(:) - (mean(:)/n), 2);
                           % if euclidean distance is below the threshold
                           if euclidean <= T
                               % add that pixel to the queue
                               r = r + 1;
                               F(r, 1) = x_c + x_neighbor_direction(k);
                               F(r, 2) = y_c + y_neighbor_direction(k);
                               % assign the label
                               output_segImage(x_c+x_neighbor_direction(k), y_c+y_neighbor_direction(k)) = nR;
                               % increase the number of pixels in the region
                               n = n + 1;
                               % update mean
                               tmp = zeros(1, dim);
                               tmp(:) = im(x_c+x_neighbor_direction(k), y_c+y_neighbor_direction(k), :);
                               mean(:) = mean(:) + tmp(:);
                           end;
                       end;
                   end;
                 
                   l = l + 1;
               end;
            end;
        end;
    end;
    %toc
    numberOfRegions = nR;
end