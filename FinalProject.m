
% add required search paths
setup ;

%% Phase One & Two: Data Preparation and Training
t = cputime;

encoding = 'vggm128-fc7' ;
augmentation = false ;
encoder = loadEncoder(encoding) ;
pos.names = getImageSet('/path/to/matlab/data/myImages', augmentation) ;
if numel(pos.names) == 0, error('Please add some images to data/myImages before running this exercise') ; end

pos.descriptors = encodeImage(encoder, pos.names, ['data/cache_' encoding]) ;
lab={};
e=cputime-t
%% Training Continues

names = {pos.names{:}};
for i=1:length(names)
    tmp=names{i};
    q=tmp(15);
    lab=vertcat(lab,q);
end
lab;
descriptors = [pos.descriptors];

%% Testing Images
pos.names = getImageSet('data/test', augmentation) ;
if numel(pos.names) == 0, error('Please add some images to data/myImages before running this exercise') ; end

pos.descriptors = encodeImage(encoder, pos.names, ['data/test/cache_' encoding]) ;
tlab={};
%% Testing Images continues

tnames = {pos.names{:}};
for i=1:length(tnames)
    tmp=tnames{i};
    q=tmp(11);
    tlab=vertcat(tlab,q);
end
testdescriptors = [pos.descriptors];


%% Phase Three: Classifier Training

% Train the linear SVM
C = 10 ;
t= templateSVM('Standardize',1,'KernelFunction','linear');

clf = fitcecoc(descriptors',lab,'Learners',t,'FitPosterior',1,...
    'ClassNames',{'3','5','7','9','a','f','k','m','o','w'},...
    'Verbose',2);

%% Phase Four and Five: Predicting and Analysis
label=predict(clf,testdescriptors');
clf.BinaryLoss;
idx = randsample(size(testdescriptors',1),15,1);
ClassNames = clf.ClassNames
PredictionTable = table(tlab(idx),label(idx),'VariableNames',{'TrueLabel','PredLabel'})
ConfusionMatrix = confusionmat(tlab,label)
%% Presenting Results
idx=randsample(length(label),10);
for i=4:3:length(idx)
 figure
subplot(2,2,1), subimage(standardizeImage(tnames{idx(i-3)}))
x = sprintf('Prediction: %s True Label: %s',label{idx(i-3)},tlab{idx(i-3)});
title(x)
subplot(2,2,2), subimage(standardizeImage(tnames{idx(i-2)}))
x = sprintf('Prediction: %s True Label: %s',label{idx(i-2)},tlab{idx(i-2)});
title(x)
subplot(2,2,3), subimage(standardizeImage(tnames{idx(i-1)}))
x = sprintf('Prediction: %s True Label: %s',label{idx(i-1)},tlab{idx(i-1)});
title(x)
subplot(2,2,4), subimage(standardizeImage(tnames{idx(i)}))
x = sprintf('Prediction: %s True Label: %s',label{idx(i)},tlab{idx(i)})
title(x)
end


