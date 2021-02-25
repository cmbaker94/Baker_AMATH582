function [Y,svdout] = calc_pcp(X)
% compute the principal component projection
% INPUT: X matrix of data valeus
% OUTPUT: Y: PCP matrix, svdout: outputs from SVD function

[m,n]=size(X); % compute data size 
mn=mean(X,2); % compute mean for each row 
X=X-repmat(mn,1,n); % subtract mean

[u,s,v]=svd(X/sqrt(n-1)); % perform the SVD 
lambda=diag(s).^2; % produce diagonal variances 
Y=u'*X; % produce the principal components projection
svdout.u = u;
svdout.s = s;
svdout.v = v;
svdout.lambda = lambda;