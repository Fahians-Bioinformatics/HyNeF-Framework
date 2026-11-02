function M = hynef_cluster_metrics(X,U,C,m,opts)
% Cluster diagnostics using the manuscript objective and silhouette formula.
% X: observations-by-features; U: clusters-by-observations; C: clusters-by-features.
% Manuscript objective: J = sum_j sum_i U(j,i)^2 * ||X(i,:)-C(j,:)||_2.
% Silhouette: s(i) = (b(i)-a(i))/max(a(i),b(i)); hard labels use max(U).
if nargin<5 || isempty(opts), opts=hynef_default_options(); end
[n,~]=size(X); K=size(U,1);
U=max(0,U); sums=sum(U,1); sums(sums<=0)=1;
U=bsxfun(@rdivide,U,sums);

% Diagnostic fuzzy partition coefficient and entropy.
PC=sum(U(:).^2)/max(n,1);
PE=-sum(U(:).*log(max(U(:),opts.eps)))/max(n,1);

% Euclidean distance, not squared distance, and squared membership as shown.
D=zeros(K,n);
for c=1:K
    dif=bsxfun(@minus,X,C(c,:));
    D(c,:)=sqrt(sum(dif.^2,2))';
end
objective=sum(sum((U.^2).*D));

% Retain XB as a diagnostic only (it is not part of manuscript J).
D2=D.^2; num=sum(sum((U.^m).*D2));
if K>1
    cd2=inf(K);
    for a=1:K
        for b=a+1:K
            cd2(a,b)=sum((C(a,:)-C(b,:)).^2);
        end
    end
    minsep=min(cd2(:));
else
    minsep=opts.eps;
end
XB=num/(max(n,1)*max(minsep,opts.eps));

% Silhouette of crisp assignments induced by the largest membership.
[~,lab]=max(U,[],1); lab=lab(:); sil=nan(n,1);
occupied=unique(lab);
if numel(occupied)>=2
    for i=1:n
        own=find(lab==lab(i));
        if numel(own)<=1
            sil(i)=0; % Standard singleton-cluster convention.
            continue;
        end
        own(own==i)=[];
        delta=bsxfun(@minus,X(own,:),X(i,:));
        a=mean(sqrt(sum(delta.^2,2)));
        b=inf;
        for q=1:numel(occupied)
            other=find(lab==occupied(q));
            if occupied(q)==lab(i), continue; end
            delta=bsxfun(@minus,X(other,:),X(i,:));
            b=min(b,mean(sqrt(sum(delta.^2,2))));
        end
        denom=max(a,b);
        if denom>0, sil(i)=(b-a)/denom; else, sil(i)=0; end
    end
end
if all(isnan(sil)), silhouette=NaN; else, silhouette=mean(sil,'omitnan'); end
counts=accumarray(lab,1,[K 1]);
M=struct('PC',PC,'PE',PE,'XB',XB,'objective',objective, ...
    'silhouette',silhouette,'silhouettePerObservation',sil, ...
    'hardCounts',counts);
end
