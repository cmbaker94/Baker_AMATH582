function [uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% this function creates matrices of the digits for interest for the LDA and
% other machine learning algorithms

uxtrain= [];
uxtest = [];

labtrain = [];
labtest = [];


for i = 1:length(numchoice)
    idtrain = find(labels_train == numchoice(i));
    idtest = find(labels_test == numchoice(i));
    
    uxtrain = [uxtrain, Train_ux(:,idtrain)];
    uxtest = [uxtest, Test_ux(:,idtest)];
    
    labtrain = [labtrain; labels_train(idtrain)];
    labtest = [labtest; labels_test(idtest)];
end