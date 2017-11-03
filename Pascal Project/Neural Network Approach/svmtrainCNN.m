% SVM Train
function [w,b] = svmtrainCNN(VOCopts,cls,lambda,kernel)

% load 'train' image set for class
[ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');
% extract features for each image
classifier.FD=zeros(0,length(ids));
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: train: %d/%d\n',cls,i,length(ids));
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
    classifier.FD(1:length(fd),i)=fd;
end
if (kernel ~= -1)
    hom.kernel = 'KChi2';
    hom.order = kernel;
    dataset = vl_svmdataset(classifier.FD, 'homkermap', hom);
else
    dataset = classifier.FD;
end
[w b ~] = vl_svmtrain(dataset, double(classifier.gt), lambda);



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

