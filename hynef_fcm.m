function [U,C,info] = hynef_fcm(X,K,m,opts,initialCenters)
% Toolbox-free fuzzy c-means; X is observations-by-features.
if nargin<4 || isempty(opts), opts=hynef_default_options(); end
[n,d]=size(X); K=max(1,min([round(K),n])); m=max(1.01,double(m));
if nargin<5 || isempty(initialCenters), ix=randperm(n,K); C=X(ix,:); else, C=initialCenters; end
U=ones(K,n)/K; converged=false;
for it=1:opts.fcmMaxIter
 D2=zeros(K,n); for c=1:K, dif=bsxfun(@minus,X,C(c,:)); D2(c,:)=sum(dif.^2,2)'; end
 D2=max(D2,opts.eps); zero=D2<=opts.eps*10;
 power=1/(m-1); Unew=zeros(K,n);
 for j=1:n
  z=find(zero(:,j)); if ~isempty(z), Unew(z,j)=1/numel(z); else, q=D2(:,j).^(-power); Unew(:,j)=q/sum(q); end
 end
 Um=Unew.^m; den=sum(Um,2); Cnew=zeros(K,d);
 for c=1:K, if den(c)>opts.eps, Cnew(c,:)=sum(bsxfun(@times,X,Um(c,:)'),1)/den(c); else, Cnew(c,:)=X(randi(n),:); end, end
 delta=max(abs(Unew(:)-U(:))); U=Unew; C=Cnew; if delta<opts.fcmTol, converged=true; break; end
end
info=struct('iterations',it,'converged',converged);
end
