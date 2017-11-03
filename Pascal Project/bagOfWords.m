function TREE = bagOfWords(VOCopts,clusterNumber)
data = [];
for i=1:VOCopts.nclasses
    cls = VOCopts.classes{i};
    [ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');
    % extract features for each image
    count = 0;
    for j=1:length(ids)
        if count == 8
            break;
        end
        if classifier.gt(j) == -1
            continue;
        end
        
        count = count + 1;
            
        
        try
            % try to load features
            load(sprintf(VOCopts.exfdpath,ids{j}),'fd');
            TREE = [];
            return
        catch
            % compute and save features
            I=imread(sprintf(VOCopts.imgpath,ids{j}));
            disp('extracting');
            %fd1 = extractsiftcolortexturefd(VOCopts,I);
            %I = imgaussfilt(I);
            fd = extracthogfd(VOCopts,I);
            disp('extraction done');
            data = [data,fd];
            
        end
    end
end
disp('data collected')
size(data)
disp('Creating Dictionary....')
[TREE,~] = vl_hikmeans(uint8(data),clusterNumber,10);
save('dictionary_HOG_smoothing_800.mat','TREE');

disp('Dictionary ready to use')
