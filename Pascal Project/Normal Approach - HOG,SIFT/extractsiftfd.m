% SIFT feature extractor:
function fd = extractsiftfd(VOCopts,I)
I = single(rgb2gray(I));
[~,n] = vl_sift(I);

fd=double(n);