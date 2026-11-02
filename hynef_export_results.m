function files = hynef_export_results(result,opts)
% Export hard/fuzzy assignments, module summaries, and complete MAT result.
if nargin<2 || isempty(opts), opts=hynef_default_options(); end
if ~isfield(opts,'outputDir') || isempty(opts.outputDir), opts.outputDir='HyNeF_results'; end
if ~exist(opts.outputDir,'dir'), mkdir(opts.outputDir); end
U=result.membership; [K,N]=size(U); names=result.geneNames(:);
if numel(names)~=N, names=arrayfun(@(i)sprintf('Gene%d',i),1:N,'UniformOutput',false)'; end
[maxMembership,assignment]=max(U,[],1); assignment=assignment(:); maxMembership=maxMembership(:);
assignTable=table(names,assignment,maxMembership,'VariableNames',{'GeneName','ModuleIndex','MaxMembership'});
f1=fullfile(opts.outputDir,'module_assignments.csv'); writetable(assignTable,f1);
varNames=[{'GeneName'},arrayfun(@(k)sprintf('Module%d',k),1:K,'UniformOutput',false)];
fuzzyTable=array2table(U','VariableNames',varNames(2:end)); fuzzyTable=addvars(fuzzyTable,names,'Before',1,'NewVariableNames','GeneName');
f2=fullfile(opts.outputDir,'fuzzy_membership.csv'); writetable(fuzzyTable,f2);
moduleID=(1:K)'; geneCount=zeros(K,1); avgMembership=zeros(K,1); tomDensity=nan(K,1); meanConnectivity=nan(K,1);
T=result.TOM; A=[]; if isfield(result,'adjacency'), A=result.adjacency; end
for k=1:K
 ix=find(assignment==k); geneCount(k)=numel(ix);
 if ~isempty(ix), avgMembership(k)=mean(maxMembership(ix)); else, avgMembership(k)=0; end
 if numel(ix)>1, sub=T(ix,ix); tomDensity(k)=sum(sub(:)-diag(diag(sub)))/(numel(ix)*(numel(ix)-1));
 elseif numel(ix)==1, tomDensity(k)=0; else, tomDensity(k)=0; end
 if ~isempty(A)
  if numel(ix)>1, sub=A(ix,ix); meanConnectivity(k)=sum(sub(:)-diag(diag(sub)))/numel(ix); else, meanConnectivity(k)=0; end
 else, meanConnectivity(k)=tomDensity(k)*max(0,numel(ix)-1); end
end
summaryTable=table(moduleID,geneCount,avgMembership,tomDensity,meanConnectivity,'VariableNames',{'ModuleID','GeneCount','AvgMembership','TOM_Density','MeanIntramodularConnectivity'});
f3=fullfile(opts.outputDir,'module_summary.csv'); writetable(summaryTable,f3);
f4=fullfile(opts.outputDir,'hynef_results.mat'); save(f4,'result','-v7.3');
files=struct('moduleAssignments',f1,'fuzzyMembership',f2,'moduleSummary',f3,'matFile',f4);
end
