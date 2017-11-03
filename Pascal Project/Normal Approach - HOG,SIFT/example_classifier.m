function example_classifier
clc
clear all
close all
% change this path if you install the VOC code elsewhere
addpath([cd '/VOCcode']);

% initialize VOC options
VOCinit;

% bag of words
%TREE = bagOfWords(VOCopts,400);
load('dictionary_HOG_smoothing_800.mat');

% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
                       
    
    %classifier = train(VOCopts,cls,TREE);      % train classifier
    %test(VOCopts,cls,classifier,TREE);         % test classifier
    
    [w,b] = svmtrain(VOCopts,cls,TREE,0.00001,3);
    svmtest(VOCopts,cls,w,b,TREE,0.00001,3)
    
    %w = trainnaivebayes(VOCopts,cls,TREE);
    %testnaivebc(VOCopts,cls,w,TREE)
    [fp,tp,auc]=VOCroc(VOCopts,'comp1',cls,true);   % compute and display ROC
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        pause;
    end
end

% train classifier
function classifier = train(VOCopts,cls,TREE)

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
        d=extracthogfd (VOCopts,I);
        path = vl_hikmeanspush(TREE,uint8(d));
        fd = vl_hikmeanshist(TREE,path);
        fd = double(fd(2:end)/fd(1));
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
       
        
    end
    
    classifier.FD(1:length(fd),i)= fd;
end



% run classifier on test images
function test(VOCopts,cls,classifier,TREE)

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
        d=extracthogfd (VOCopts,I);
        path = vl_hikmeanspush(TREE,uint8(d));
        fd = vl_hikmeanshist(TREE,path);
        fd = double(fd(2:end)/fd(1));
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end
    
    % compute confidence of positive classification
    c=classify(VOCopts,classifier,fd);
    
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},c);
end

% close results file
fclose(fid);


% trivial feature extractor: compute mean RGB
function fd = extractfd(VOCopts,I)

fd=squeeze(sum(sum(double(I)))/(size(I,1)*size(I,2)));





% trivial classifier: compute ratio of L2 distance betweeen
% nearest positive (class) feature vector and nearest negative (non-class)
% feature vector
function c = classify(VOCopts,classifier,fd)

d=sum(fd.*fd)+sum(classifier.FD.*classifier.FD)-2*fd'*classifier.FD;
dp=min(d(classifier.gt>0));
dn=min(d(classifier.gt<0));
c=dn/(dp+eps);
