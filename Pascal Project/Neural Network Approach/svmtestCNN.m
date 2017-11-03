% run SVM classifier on test images
function svmtestCNN(VOCopts,cls,w,b,lambda,kernel)

% load test set ('val' for development kit)
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,VOCopts.testset),'%s %d');

% create results file
fid=fopen(sprintf(VOCopts.clsrespath,'comp1',cls),'w');

% classify each image
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: test: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    try
        % try to load features
        load(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    catch
        % compute and save features
        I=imread(sprintf(VOCopts.imgpath,ids{i}));
        fd=extractnetfd(VOCopts,I);
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end

    % compute confidence of positive classification
    if (kernel ~= -1)
        hom.kernel = 'KChi2';
        hom.order = kernel;
        dataset = vl_svmdataset(fd, 'homkermap', hom);
        [~,~,~,scores] = vl_svmtrain(dataset, 1000, lambda, 'model', w, 'bias', b, 'solver', 'none');
    else
        scores=(w'*fd + b);
    end
    
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},scores);
end

% close results file
fclose(fid);

function fd = extractnetfd(VOCopts,I)

% Some images may be grayscale. Replicate the image 3 times to
% create an RGB image.
global convnet;
if ismatrix(I)
    I = cat(3,I,I,I);
end

% Resize the image as required for the CNN.
Iout = imresize(I, [227 227]);

% Extract features using CNN
featureLayer = 'fc7';
fd = activations(convnet, Iout, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
