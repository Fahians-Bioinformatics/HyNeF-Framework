function result = hynef_evaluate_candidate(candidate,H_full,tom,opts)
% Evaluate an outer chromosome using its first H fixed latent dimensions.
% candidate is a struct with scalar fields K, m, and H. tom is retained in
% this interface for extensible TOM-aware objectives; the reference objective
% is evaluated by the inner FCM/GA on the fixed latent representation.
if nargin<4 || isempty(opts), opts=hynef_default_options(); end
if ~isstruct(candidate) || ~all(isfield(candidate,{'K','m','H'}))
    error('candidate must contain K, m, and H fields.');
end
if isempty(H_full) || ~isnumeric(H_full), error('H_full must be a numeric latent matrix.'); end
if nargin<3, tom=[]; end %#ok<NASGU>
H=max(1,min(size(H_full,2),round(candidate.H)));
K=max(1,min(size(H_full,1)-1,round(candidate.K)));
inner=hynef_inner_ga(H_full(:,1:H),K,candidate.m,opts);
result=struct('K',K,'m',candidate.m,'H',H,'fitness',inner.fitness,'inner',inner);
end
