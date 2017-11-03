%
%Author : Shubham Wagh, Nayee Muddin Khan
%Created on : 23/02/2017

%Fuzzy C-Means function implementation
%Input: Number of clusters
%Output: Segemented image

function seg = fuzzymeans(input_image,clusters)
data = reshape(input_image,[],3);
pixel_value = linspace(0,255,clusters);
row = size(input_image,1);
col = size(input_image,2);

seg = zeros(row,col);

[center, U_objective] = fcm(data,clusters);
for i = 1:row
    for j = 1:col
        t =1;
        m = abs(input_image(i,j) - center(t));
        
        for k = 2:clusters
            if(abs(input_image(i,j)- center(k)) < m)
                t = k;
                m = abs(input_image(i,j) - center(k));
                
            end
        end
        seg(i,j) = pixel_value(t);
    end
end
end