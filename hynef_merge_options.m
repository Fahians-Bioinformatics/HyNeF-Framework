function out = hynef_merge_options(base, user)
% Recursively merge user fields into a defaults struct.
out=base; if nargin<2 || isempty(user), return; end
if ~isstruct(user), error('opts must be a struct.'); end
names=fieldnames(user);
for i=1:numel(names)
 f=names{i}; if isfield(out,f) && isstruct(out.(f)) && isstruct(user.(f))
  out.(f)=hynef_merge_options(out.(f),user.(f));
 else, out.(f)=user.(f); end
end
end
