function [Z, names, info] = hynef_preprocess(X, geneNames)
% Impute gene medians, remove unusable genes, and z-standardize columns.
if ~isnumeric(X) || ndims(X)~=2 || isempty(X), error('X must be a nonempty numeric samples-by-genes matrix.'); end
X=double(X); [~,p]=size(X);
if nargin<2 || isempty(geneNames), geneNames=arrayfun(@(j)sprintf('Gene%d',j),1:p,'UniformOutput',false); end
if numel(geneNames)~=p, error('geneNames length must match the number of input genes.'); end
geneNames=cellstr(string(geneNames)); keep=true(1,p); med=nan(1,p);
for j=1:p
 v=X(:,j); good=isfinite(v); if any(good), med(j)=median(v(good)); X(~good,j)=med(j); else, keep(j)=false; end
end
X=X(:,keep); names=geneNames(keep); med=med(keep);
if isempty(X), error('No genes remain after removing all-missing columns.'); end
mu=mean(X,1); sd=std(X,0,1); scale=max(1,abs(mu)); keep2=isfinite(sd) & sd>1e-12.*scale;
X=X(:,keep2); names=names(keep2); med=med(keep2); mu=mu(keep2); sd=sd(keep2);
if size(X,2)<3, error('At least 3 usable genes are required after filtering.'); end
Z=bsxfun(@rdivide,bsxfun(@minus,X,mu),sd);
info=struct('keptNames',{names},'imputationMedians',med,'means',mu,'standardDeviations',sd,'nInputGenes',p,'nKeptGenes',size(Z,2));
end
