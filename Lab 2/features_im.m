function [energy,contrast, correlation, homogeneity, entropy] = features_im(im,patchSize,distance,x_directions, y_directions)
[height, width] = size(im);




contrast = zeros(height, width);
homogeneity = zeros(height, width);
energy = zeros(height, width);
correlation = zeros(height, width);
entropy = zeros(height,width);
%offsets = [0,1;-1,1;-1,0;-1,-1];


%offsets =[0,1];



for i = 1:height-patchSize+1
    for j = 1:width-patchSize+1
        w = im(i:(i+patchSize-1), j:(j+patchSize-1));
        
        glcm = graycomatrix(w, 'NumLevels', 8, 'Offset', [distance*x_directions distance*y_directions]);
        prop = graycoprops(glcm);
        x = i+floor(patchSize/2);
        y = j+floor(patchSize/2);
        contrast(x, y) = prop.Contrast;
        correlation(x, y) = prop.Correlation;
        energy(x, y) = prop.Energy;
        %disp('Hello');
        homogeneity(x, y) = prop.Homogeneity;
        s = 0.0;
        for w = 1:size(glcm,1)
            for t = 1:size(glcm,2)
                if glcm(w,t)> 0
                    
                    s = s + glcm(w,t)*log(glcm(w,t));
                end
            end
            entropy(x,y) = s;
        end
    end
    
end

