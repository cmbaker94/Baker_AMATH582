clear all
close all
clc

addpath(genpath('/Users/cmbaker9/Documents/MTOOLS'))

%% STEP 0: Locate and load data

datapath    = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW4/data/';
figfolder   = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW4/figures/';

%% Load data

[images_train, labels_train] = mnist_parse([datapath,'train-images-idx3-ubyte'], [datapath,'train-labels-idx1-ubyte']);
[images_test, labels_test] = mnist_parse([datapath,'t10k-images-idx3-ubyte'], [datapath,'t10k-labels-idx1-ubyte']);

figure('units','inches','position',[1 1 6 6],'Color','w');
for j=1:9
    subplot(3,3,j)
    imshow(images_train(:,:,j))
end
Sname1 = [figfolder,'eximages'];
print(Sname1,'-dpng')

%% run svd on data

res = size(images_train,1);
ntrain = size(images_train,3);
ntest = size(images_test,3);

Xtrain = double(reshape(images_train,res*res,ntrain));
[S,U,V] = calc_svd(Xtrain);

Xtest = double(reshape(images_test,res*res,ntest));

%% inspect training set

sig=diag(S);
energy(1)=sig(1)/sum(sig);
for i = 2:length(sig)
    energy(i) = sum(sig(1:i))/sum(sig);
end

% pricipal components 1 , 2 , 3 ,4 
figure('units','inches','position',[1 1 6 6],'Color','w');
titlenum = ['a','b','c','d'];
for j=1:4
    subplot(2,2,j)
    ut1=reshape(U(:,j),res,res);
    ut2=ut1(res:-1:1,:);
    pcolor(ut2); shading interp
    title(['(',titlenum(j),')'],'interpreter','latex','fontsize',20)
    set(gca,'Xtick',[],'Ytick',[])
end
Sname1 = [figfolder,'princ_components'];
print(Sname1,'-dpng')

% covariance
lambda=diag(S).^2;

figure('units','inches','position',[1 1 10 6],'Color','w');
mode = 1:length(lambda);
scatter(mode,lambda/sum(lambda)*100,100,'k','fill')
hold on
xlabel('Mode','interpreter','latex','fontsize',20)
ylabel('percent $\sigma^2 (\%)$','interpreter','latex','fontsize',20)
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
Sname1 = [figfolder,'covariance'];
print(Sname1,'-dpng')


%% Projection onto 3 V-modes
SV = V*S;

figure('units','inches','position',[1 1 10 8],'Color','w');
for label=0:9
    label_indices = find(labels_train == label);
    plot3(SV(label_indices,2),SV(label_indices,3),SV(label_indices,5),'o','Linewidth',1)
    hold on
end
xlabel('Mode 2','interpreter','latex','fontsize',20)
ylabel('Mode 3','interpreter','latex','fontsize',20)
zlabel('Mode 5','interpreter','latex','fontsize',20)
h2 = legend({'1','2','3','4','5','6','7','8','9'});
set(h2,'interpreter','latex','fontsize',20,'orientation','vertical');
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
Sname1 = [figfolder,'3d'];
print(Sname1,'-dpng')

%% make matrixes

feature = 20;
Train_ux = U(:,1:feature)'*Xtrain;
Test_ux = U(:,1:feature)'*Xtest;

% Train_ux = Train_ux-mean(Train_ux,1);
% Test_ux = Test_ux-mean(Test_ux,1);

Train_ux = Train_ux/max(Train_ux(:));
Test_ux = Test_ux/max(Test_ux(:));

%% LDA: pick 2 numbers
% Pick two digits. See if you can build a linear classifier (LDA) that can reasonable identify them.

numchoice = [1 2];

[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);

Mdl = fitcdiscr(uxtrain',labtrain);
restrain = predict(Mdl,uxtrain');
restest = predict(Mdl,uxtest');
% train error
[errNum.LDA2pick_train,sucRate.LDA2pick_train] = calc_err(restrain,labtrain);
% test error
[errNum.LDA2pick_test,sucRate.LDA2pick_test] = calc_err(restest,labtest);


%% LDA: pick 3 numbers
% Pick three digits. Try to build a linear classifier to identify these three now.

numchoice = [1 2 3];

[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);

Mdl = fitcdiscr(uxtrain',labtrain);
restrain = predict(Mdl,uxtrain');
restest = predict(Mdl,uxtest');
% train error
[errNum.LDA3pick_test,sucRate.LDA3pick_test] = calc_err(restrain,labtrain);
% test error
[errNum.LDA3pick_train,sucRate.LDA3pick_train] = calc_err(restest,labtest);


%% LDA Hardest / easiest
% Which two digits in the data set appear to be the most difficult to separate? Quantify the accuracy of the separation with LDA on the test data.
% Which two digits in the data set are most easy to separate? Quantify the accuracy of the separation with LDA on the test data

for i = 1:10
    for j = 1:10
        numchoice = [i j]-1;
        if i ~= j
            [uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
            
            Mdl = fitcdiscr(uxtrain',labtrain);
            restrain = predict(Mdl,uxtrain');
            restest = predict(Mdl,uxtest');
            
            % train error
            [errNum_train(i,j),sucRate_train(i,j)] = calc_err(restrain,labtrain);
            
            % test error
            [errNum_test(i,j),sucRate_test(i,j)] = calc_err(restest,labtest);
        elseif i == j
            errNum_train(i,j) = NaN;
            sucRate_train(i,j) = NaN;
            
            errNum_test(i,j) = NaN;
            sucRate_test(i,j) = NaN;
        end
    end
end

% train
% find easiest
[sucRate.ldaeas_train,id] = max(sucRate_train(:)); % find max of spectra index in array
[num1,num2] = ind2sub(size(sucRate_train),id);
display('easiest to seperate')
easiest.train = [num1 num2]-1;

% find hardest
[sucRate.ldahard_train,id] = min(sucRate_train(:)); % find max of spectra index in array
[num1,num2] = ind2sub(size(sucRate_train),id);
display('easiest to seperate')
hardest.train = [num1 num2]-1;

% test
% find easiest
[sucRate.ldaeas_test,id] = max(sucRate_test(:)); % find max of spectra index in array
[num1,num2] = ind2sub(size(sucRate_test),id);
display('easiest to seperate')
easiest.test = [num1 num2]-1
% find hardest
[sucRate.ldahard_test,id] = min(sucRate_test(:)); % find max of spectra index in array
[num1,num2] = ind2sub(size(sucRate_test),id);
display('easiest to seperate')
hardest.test = [num1 num2]-1

%% SVM and decisiontree on all

% SVM
Mdl = fitcecoc(Train_ux',labels_train);
restrain = predict(Mdl,Train_ux');
restest = predict(Mdl,Test_ux');
% train error
[errNum.SVMall_train,sucRate.SVMall_train] = calc_err(restrain,labels_train);
% test error
[errNum.SVMall_test,sucRate.SVMall_test] = calc_err(restest,labels_test);
clear restrain retest

% Decision tree
% classification tree on fisheriris data
tree=fitctree(Train_ux',labels_train);
restrain = predict(tree,Train_ux');
restest = predict(tree,Test_ux');
% train error
[errNum.treeall_train,sucRate.treeall_train] = calc_err(restrain,labels_train);
% test error
[errNum.treeall_test,sucRate.treeall_test] = calc_err(restest,labels_test);
clear restrain retest

%% SVM on hardest and easiest
% hardest train
numchoice = hardest.train;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% SVM: 2 num
Mdl = fitcsvm(uxtrain',labtrain);
restrain = predict(Mdl,uxtrain');
% train error
[errNum.SVMhard_train,sucRate.SVMhard_train] = calc_err(restrain,labtrain);
clear restrain restest

% hardest test
numchoice = hardest.test;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% SVM: 2 num
Mdl = fitcsvm(uxtrain',labtrain);
restest = predict(Mdl,uxtest');
% train error
[errNum.SVMhard_test,sucRate.SVMhard_test] = calc_err(restest,labtest);
clear restrain restest

% easiest train
numchoice = easiest.train;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% SVM: 2 num
Mdl = fitcsvm(uxtrain',labtrain);
restrain = predict(Mdl,uxtrain');
% train error
[errNum.SVMeas_train,sucRate.SVMeas_train] = calc_err(restrain,labtrain);
clear restrain restest

% easiest test
numchoice = easiest.test;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% SVM: 2 num
Mdl = fitcsvm(uxtrain',labtrain);
restest = predict(Mdl,uxtest');
% train error
[errNum.SVMeas_test,sucRate.SVMeas_test] = calc_err(restest,labtest);
clear restrain restest

%% decision tress on hardest and easiest

% hardest train
numchoice = hardest.train;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% SVM: 2 num
Mdl = fitctree(uxtrain',labtrain);
restrain = predict(Mdl,uxtrain');
% train error
[errNum.treehard_train,sucRate.treehard_train] = calc_err(restrain,labtrain);
clear restrain restest

% hardest test
numchoice = hardest.test;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% tree: 2 num
Mdl = fitctree(uxtrain',labtrain);
restest = predict(Mdl,uxtest');
% train error
[errNum.treehard_test,sucRate.treehard_test] = calc_err(restest,labtest);
clear restrain restest

% easiest train
numchoice = easiest.train;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% tree: 2 num
Mdl = fitctree(uxtrain',labtrain);
restrain = predict(Mdl,uxtrain');
% train error
[errNum.treeeas_train,sucRate.treeeas_train] = calc_err(restrain,labtrain);
clear restrain restest

% easiest test
numchoice = easiest.test;
[uxtrain,uxtest,labtrain,labtest] = get_nums(numchoice,Train_ux,Test_ux,labels_train,labels_test);
% tree: 2 num
Mdl = fitctree(uxtrain',labtrain);
restest = predict(Mdl,uxtest');
% train error
[errNum.treeeas_test,sucRate.treeeas_test] = calc_err(restest,labtest);
clear restrain restest
