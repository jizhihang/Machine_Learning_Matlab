%% SVM with 5-Fold cross validation test
% This homework reads Wine+Quality Data from
% http://archive.ics.uci.edu/ml/datasets/Wine+Quality.
% This code is using libsvm svm functions
% Use 5 fold cross-validation to choose the right parameter
% Use cross validation with 60% train and 40% test data to draw ROC
% Draw ROC to compare different param settings.
clear all;
close all;
clc;

% addpath to the libsvm toolbox
addpath('./libsvm/matlab');

%% Read and transform data
% data=csvread('winequality-white.csv',1,0);
data=csvread('winequality-red.csv',1,0);
x0=data(:,1:11);
n=size(data,1);
x0=(x0-repmat(mean(x0),n,1))./repmat(std(x0),n,1);
t=data(:,12);
t(t<=5)=-ones(size(find(t<=5)));
t(t>5)=ones(size(find(t>5)));
x=x0;
% x=sparse(x0);
% libsvmwrite('white_wine',t,x);
% [t, x] = libsvmread('white_wine');

%% Parameters for training SVM
% Split into 5 sets
idx=crossvalind('Kfold',n,5);

%% cross-validation
miter=5;
% Initiatilize array
linear_AUC1=zeros(miter,1); % Area Under ROC
linear_sv_s=zeros(miter,1); % No. of Support Vectors
poly_AUC1=zeros(miter,1);
poly_sv_s=zeros(miter,1);
rbf_AUC1=zeros(miter,1);
rbf_sv_s=zeros(miter,1);

for iter=1:miter
    
    test_idx = find(idx==mod(iter,5)+1 | idx==mod(iter+1,5)+1);
    train_idx = find(idx~=mod(iter,5)+1 & idx~=mod(iter+1,5)+1);
    %% Train linear classifier
    % Train the SVM
    linear_SVM1 = svmtrain(t(train_idx,:),x(train_idx,:), '-t 0 -c 1');
    linear_sv_s(iter)=linear_SVM1.totalSV;
    % Make a prediction for the test set
    [~, ~, t_values] = svmpredict(t(test_idx,:),x(test_idx,:), linear_SVM1);
    [X,Y,~,linear_AUC1(iter),Poc]=perfcurve(t(test_idx,:),t_values,1);
        
    if iter == miter
        plot(X,Y,'b')
        hold on
    end
    
    %% Train polynomial classifier
    % Train the SVM
    poly_SVM1 = svmtrain(t(train_idx,:),x(train_idx,:), '-t 1  -c 1 -d 3 -g 0.01 -r 10');
    poly_sv_s(iter)=poly_SVM1.totalSV;
    % Make a prediction for the test set
    [~, ~, t_values] = svmpredict(t(test_idx,:),x(test_idx,:), poly_SVM1);
    [X,Y,~,poly_AUC1(iter)]=perfcurve(t(test_idx,:),t_values,1);
    if iter == miter
        plot(X,Y,'r')
    end
    
    %% Train rbf classifier
    % Train the SVM
    rbf_SVM1 = svmtrain(t(train_idx,:),x(train_idx,:), '-t 2 -c 10 -g 1/11');
    rbf_sv_s(iter)=rbf_SVM1.totalSV;
    % Make a prediction for the test set
    [~, ~, t_values] = svmpredict(t(test_idx,:),x(test_idx,:), rbf_SVM1);
    [X,Y,~,rbf_AUC1(iter)]=perfcurve(t(test_idx,:),t_values,1);
    if iter == miter
        plot(X,Y,'g')
        xlabel('False positive rate'); ylabel('True positive rate')
        title('ROC for classification by SVM')
        legend('Linear Kernel','Polyomial Kernel','RBF Kernel')
    end
end

linear_sv_s_mean=mean(linear_sv_s)
linear_AUC1_mean=mean(linear_AUC1)
linear_AUC1_std=std(linear_AUC1)

poly_sv_s_mean=mean(poly_sv_s)
poly_AUC1_mean=mean(poly_AUC1)
poly_AUC1_std=std(poly_AUC1)

rbf_sv_s_mean=mean(rbf_sv_s)
rbf_AUC1_mean=mean(rbf_AUC1)
rbf_AUC1_std=std(rbf_AUC1)
