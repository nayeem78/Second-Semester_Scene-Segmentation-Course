function testdrbmc(VOCopts,cls,w,tree)

% load test set ('val' for development kit)
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,VOCopts.testset),'%s %d');

% create results file
fid=fopen(sprintf(VOCopts.clsrespath,'comp1',cls),'w');

testdata = [];
% classify each image
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
        d =extracthogfd(VOCopts,I);
        path = vl_hikmeanspush(tree,uint8(d));
        fd = vl_hikmeanshist(tree,path);
        fd = double(fd(2:end)/fd(1));
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end

    
    testdata = [testdata; fd'];
    
    % write to results file
    %fprintf(fid,'%s %f\n',ids{i},c);
end

data = dataset(testdata,gt);
data = setprior(data,getprior(data));
fclass=data*w*classc
temp=+fclass;
for i=1:length(ids)
    fprintf(fid,'%s %f\n',ids{i},temp(i,2));
end

% close results file
fclose(fid);
