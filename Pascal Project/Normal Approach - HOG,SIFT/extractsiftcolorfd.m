% SIFT feature and color extractor:
function fd = extractsiftcolorfd(VOCopts,I)
[m,n,~] = size(I);
[a1,n1] = vl_sift(single(reshape(I(:,:,1),m,n)));
[a2,n2] = vl_sift(single(reshape(I(:,:,2),m,n)));
[a3,n3] = vl_sift(single(reshape(I(:,:,3),m,n)));
fd = double([n1,n2,n3]);