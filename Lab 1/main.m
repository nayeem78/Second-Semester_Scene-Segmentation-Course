%
%Author : Shubham Wagh, Nayee Muddin Khan
%Created on : 23/02/2017

clc;
clear all;
close all;

name = double(imread('p1_images/coins.png'));
%name = double(imread('p1_images/color.tif'));
%name = double(imread('p1_images/gantrycrane.png'));
%name = double(imread('p1_images/woman.tif'));

%Applying 9 x 9 median filter
dim = size(name,3);
if dim == 1
    %graylevel image
    fimage = medfilt2(name,[9,9]);
else
    %color image
    fimage1 = medfilt2(name(:,:,1),[9,9]);
    fimage2 = medfilt2(name(:,:,2),[9,9]);
    fimage3 = medfilt2(name(:,:,3),[9,9]);
    
    fimage = cat(3,fimage1,fimage2,fimage3);
end

   
%[seg,n] = regionGrowing(name,100,8); %for gantrycrane
%tic
[seg,n] = regionGrowing(name,80,8); 
%toc

%tic
[fseg,fn] = regionGrowing(fimage,50,8); %Region growing for filtered image
%toc

rgb = label2rgb(seg);
frgb = label2rgb(fseg);
figure,
subplot(2,2,1),imshow(uint8(name));title('Original Image'),hold on;
subplot(2,2,2),imshow(rgb), title('Segmented Image(Regions)');hold on;
subplot(2,2,4), imshow(frgb), title('Segmented Image - After Filtering(Regions)')
subplot(2,2,3),imshow(uint8(fimage)),title('Filtered Image');

fprintf('Number of regions: %d\n',n);
fprintf('Number of regions- after filtering: %d\n',fn);
hold off;

%tic
fcmseg = fuzzymeans(name,2);      %fuzzyC-means implementation
%toc
fcmseg_rgb = label2rgb(uint8(fcmseg));
figure,
subplot(2,2,1),imshow(uint8(name));title('Original Image'),hold on;
subplot(2,2,2),imshow(rgb), title('Segmented Image(Regions)');
subplot(2,2,3), imshow(frgb), title('Segmented Image - After Filtering(Regions)');
subplot(2,2,4),imshow(fcmseg_rgb),title('Segmented Image(FCM)');
hold off;