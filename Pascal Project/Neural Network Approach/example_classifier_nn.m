function example_classifier

% change this path if you install the VOC code elsewhere
addpath([cd '/VOCcode']);

% initialize VOC options
VOCinit;

% Load pre-trained CNN, alexnet, provided by MATLAB
cnnMatFile = fullfile('imagenet-caffe-alex.mat');
global convnet;
convnet = helperImportMatConvNet(cnnMatFile);

% Global multi-class SVM model
%global model;

% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
  
    [w,b] = svmtrainCNN(VOCopts,cls,0.00001,3);
 
    
    
    svmtestCNN(VOCopts,cls,w,b,0.00001,3);
    
    [fp,tp,auc]=VOCroc(VOCopts,'comp1',cls,true);   % compute and display ROC
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        pause;
    end
end

% train classifier
function classifier = train(VOCopts,cls)

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
        
        % Set the ImageDatastore ReadFcn
        %imds.ReadFcn = @(filename)readAndPreprocessImage(sprintf(VOCopts.imgpath,ids{i}));
        
        fd=extractfd(VOCopts,I);
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end
    
    classifier.FD(1:length(fd),i)=fd;
end

% run classifier on test images
function test(VOCopts,cls,classifier)

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
        fd=extractfd(VOCopts,I);
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end
    
    % compute confidence of positive classification
    c=classify(VOCopts,classifier,fd);
    
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},c);
end

% close results file
fclose(fid);

% Extract features using CNN
function fd = extractfd(VOCopts,I)

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






