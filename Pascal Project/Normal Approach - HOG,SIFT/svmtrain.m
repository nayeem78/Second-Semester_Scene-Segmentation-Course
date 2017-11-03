% SVM Train
function [w,b] = svmtrain(VOCopts,cls,tree,lambda,kernel)

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
        path = vl_hikmeanspush(tree,uint8(d));
        fd = vl_hikmeanshist(tree,path);
        fd = double(fd(2:end)/fd(1));
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
