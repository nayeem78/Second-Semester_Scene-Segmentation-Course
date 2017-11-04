%Texture and Intensity based segmentation

clc;
clear all;
close all;

image0 = load('feli_patch5_distance3_angle0.mat');
image45 = load('feli_patch15_distance3_angle45.mat');
image90 = load('feli_patch5_distance3_angle90.mat');
image135 = load('feli_patch5_distance3_angle135.mat');

energy = image45.energy;
contrast = image45.contrast;
homogeneity = image45.homogeneity;
correlation = image45.correlation;
correlation(isnan(correlation)) = 1.0;
entropy = image45.entropy;
entropy = entropy/max(entropy(:));
%contrast1 = image0.contrast;
im = imread('P2_seg/feli.tif');
im = double(im);
im = im / 255.0;


 %smoothing
 energy = medfilt2(energy, [7,7]);
 homogeneity = medfilt2(homogeneity, [7,7]);
 contrast = medfilt2(contrast, [7,7]);
 correlation = medfilt2(correlation,[7,7]);
 %contrast1 = medfilt2(contrast1, [7,7]);
 

 
 
 im1 = medfilt2(im(:,:,1),[7,7]);
 im2 = medfilt2(im(:,:,2),[7,7]);
 im3 = medfilt2(im(:,:,3),[7,7]);
 
im = cat(3,im1,im2,im3);
 
im(:,:,6) = energy(:,:);
%im(:,:,7) = correlation(:,:);
im(:,:,4) = contrast(:,:);
%im(:,:,5) = entropy(:,:);

[seg, n]= regionGrowing(im, 0.30 ,4); %......................)%120.0/255.0, 8);
n

%seg = 1 - (double(seg) - min(seg(:)))/(max(seg(:)) - min(seg(:)));
figure,imagesc(seg);
%colormap(gray);