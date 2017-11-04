clc;
clear all;
close all;

input_image = imread('P2_seg/pingpong2.tif');
input_image = rgb2gray(input_image);
input_image = double(input_image);
input_image = input_image / 255.0;
patch_size = [20];
[height, width] = size(input_image);
distance = [5];


directions = [0 ,-1,-1,-1;
                1,1,0,-1];
orientation_angle = [0, 45, 90, 135];

for p = 1:length(patch_size)
    for l = 1:length(distance)
        for a = 1:size(directions,2)
            sprintf('Texture for  patch_size=%d, distance=%d, angle=%d', patch_size(p), distance(l), orientation_angle(a))
            [energy, contrast, correlation, homogeneity, entropy] = features_descriptor( input_image, patch_size(p),distance(l),directions(1,a),directions(2,a));
            fileName = sprintf('pingpong_patch%d_distance%d_angle%d',patch_size(p),distance(l),orientation_angle(a));
            save(fileName, 'energy', 'contrast', 'correlation', 'homogeneity', 'entropy');
            sprintf('File saved.')
        end
    end
end