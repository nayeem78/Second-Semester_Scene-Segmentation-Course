% HOG feature extractor:
function fd = extracthogfd(VOCopts,I)
%I = imgaussfilt(I);
hog = vl_hog(single(I),8);
[width,height,~] = size(hog);
fd = [];
for i = 1:width
    for j = 1:height
        hog_feature_vec = reshape(double(hog(i,j,:)),31,1);
        fd = [fd, 1024*hog_feature_vec ];
    end
end