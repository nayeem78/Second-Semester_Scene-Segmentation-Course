function v = computeFeatureVector(A)
%
% Describe an image A using texture features.
%   A is the image
%   v is a 1xN vector, being N the number of features used to describe the
% image
%

if size(A,3) > 1,
	A = rgb2gray(A);
end
offset0 = [0,1];
offset45 = [-1,1];
offset90 = [-1,0];
offset135 = [-1,-1];
offsets = [offset0;offset45;offset90;offset135];

%offsets = [offsets; offsets*9; offsets*5]; % 93.75 percent



glcm = graycomatrix(A,'NumLevels',8,'Offset',offsets);

vector_feature =[];
for i=1:size(glcm,3)
    st = graycoprops(glcm(:,:,i));
    vector_feature = [vector_feature, st.Contrast, st.Energy, st.Homogeneity, st.Correlation];% entropy(glcm(:,:,i))]; 
        %entropy(glcm(:,:,i))];
end
v = vector_feature;


function value = entropy(A)
value = 0.0;
for w = 1:size(A,1)
    for t = 1:size(A,2)
        if A(w,t) > 0
            
            value = value + A(w,t)*log(A(w,t));
        end
        
    end
end
