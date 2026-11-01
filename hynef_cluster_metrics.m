function M = hynef_cluster_metrics(X,U,C,m,opts)
% Standard fuzzy indices plus a documented reference minimization objective.
if nargin<5 || isempty(opts), opts=hynef_default_options(); end
[n,~]=size(X); K=size(U,1); U=max(0,U); sums=sum(U,1); sums(sums<=0)=1; U=bsxfun(@rdivide,U,sums);
PC=sum(U(:).^2)/max(n,1); PE=-sum(U(:).*log(max(U(:),opts.eps)))/max(n,1);
D2=zeros(K,n); for c=1:K, dif=bsxfun(@minus,X,C(c,:)); D2(c,:)=sum(dif.^2,2)'; end
num=sum(sum((U.^m).*D2)); if K>1
 cd2=inf(K); for a=1:K, for b=a+1:K, cd2(a,b)=sum((C(a,:)-C(b,:)).^2); end, end
 minsep=min(cd2(:));
else, minsep=opts.eps; end
XB=num/(max(n,1)*max(minsep,opts.eps)); [~,lab]=max(U,[],1); counts=accumarray(lab(:),1,[K 1]); target=n/K;
small=sum(max(0,0.25*target-counts))/(max(n,1));
objective=log(max(XB,0)+opts.eps)+opts.entropyWeight*PE+opts.complexityWeight*K+opts.smallClusterWeight*small;
M=struct('PC',PC,'PE',PE,'XB',XB,'objective',objective,'hardCounts',counts,'smallClusterPenalty',small);
end
