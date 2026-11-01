function [Y, model] = hynef_random_projection(T, maxDim, seed)
% Fixed Gaussian nonlinear projection of TOM rows; returned model is reusable.
if nargin<3, seed=1; end
rng(seed,'twister'); n=size(T,1); mu=mean(T,1); sd=std(T,0,1); sd(sd<1e-12)=1;
S=bsxfun(@rdivide,bsxfun(@minus,T,mu),sd); W=randn(n,maxDim)/sqrt(max(1,n)); H=tanh(S*W);
hm=mean(H,1); hs=std(H,0,1); hs(hs<1e-12)=1; Y=bsxfun(@rdivide,bsxfun(@minus,H,hm),hs);
model=struct('inputMean',mu,'inputStd',sd,'weights',W,'latentMean',hm,'latentStd',hs,'maxDim',maxDim);
end
