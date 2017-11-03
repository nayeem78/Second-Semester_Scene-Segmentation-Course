%sift color texture feature extract
function fd = extractsiftcolortexturefd(VOCopts,I)
[m,n,~] = size(I);
[a1,d1] = vl_sift(single(reshape(I(:,:,1),m,n)));
[a2,d2] = vl_sift(single(reshape(I(:,:,2),m,n)));
[a3,d3] = vl_sift(single(reshape(I(:,:,3),m,n)));
se=strel('square',7);
[a4,d4] = vl_sift(single(stdfilt(rgb2gray(I),getnhood(se))));
fd = double([d1,d2,d3,d4]);
