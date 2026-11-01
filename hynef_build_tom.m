function [T,A,C] = hynef_build_tom(Z, opts)
% Build Pearson correlation, adjacency, and topological overlap matrix.
if nargin<2, opts=hynef_default_options(); end
C=corrcoef(Z); C(~isfinite(C))=0; C=max(-1,min(1,C)); C(1:size(C,1)+1:end)=1;
if opts.signedAdjacency, A=((1+C)./2).^opts.beta; else, A=abs(C).^opts.beta; end
A(1:size(A,1)+1:end)=0; k=sum(A,2); n=size(A,1);
T=(A*A + A)./(bsxfun(@min,k,k')+1-A+opts.eps); T(1:n+1:end)=1; T=max(0,min(1,T));
end
