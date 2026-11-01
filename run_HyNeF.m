function result = run_HyNeF(inputData,userOpts)
%RUN_HYNEF End-to-end HyNeF clustering for samples-by-genes data or CSV.
if nargin<2, userOpts=struct(); end
opts=hynef_merge_options(hynef_default_options(),userOpts);
if isfield(userOpts,'kRange') && ~isfield(userOpts,'outerGA'), opts.outerGA.K_range=userOpts.kRange; end
if isfield(userOpts,'mRange') && ~isfield(userOpts,'outerGA'), opts.outerGA.m_range=userOpts.mRange; end
if isfield(userOpts,'hiddenDimRange') && ~isfield(userOpts,'outerGA'), opts.outerGA.H_range=userOpts.hiddenDimRange; end
rng(opts.seed,'twister'); fprintf('HyNeF: starting pipeline\n');
if isnumeric(inputData)
 X=inputData; geneNames=opts.geneNames;
elseif ischar(inputData) || (isstring(inputData) && isscalar(inputData))
 file=char(inputData); if ~isfile(file), error('Input CSV not found: %s',file); end
 try
  tab=readtable(file,'VariableNamingRule','preserve');
  if isempty(opts.geneNames), geneNames=tab.Properties.VariableNames; else, geneNames=opts.geneNames; end
  X=zeros(height(tab),width(tab));
  for j=1:width(tab)
   v=tab{:,j};
   if isnumeric(v), X(:,j)=double(v);
   elseif islogical(v), X(:,j)=double(v);
   else, X(:,j)=str2double(string(v)); end
  end
  bad=all(~isfinite(X),1);
  if any(bad) && isempty(opts.geneNames), geneNames=geneNames(~bad); X=X(:,~bad); end
 catch err
  error('Could not read numeric samples-by-genes CSV: %s',err.message);
 end
else
 error('inputData must be a numeric matrix or CSV path.');
end
fprintf('Step 1/6: Preprocessing...\n'); [Z,geneNames,prepInfo]=hynef_preprocess(X,geneNames);
fprintf('  %d samples x %d usable genes\n',size(Z,1),size(Z,2));
fprintf('Step 2/6: TOM calculation...\n'); [TOM,adjacency,correlation]=hynef_build_tom(Z,opts);
fprintf('Step 3/6: Random nonlinear projection...\n'); maxH=max(1,min([round(opts.maxHiddenDim),size(TOM,1),round(opts.hiddenDimRange(2))]));
[H_full,projectionModel]=hynef_random_projection(TOM,maxH,opts.seed);
opts.outerGA.K_range=[max(2,opts.outerGA.K_range(1)), min(size(Z,2)-1,opts.outerGA.K_range(2))];
opts.outerGA.H_range=[max(1,opts.outerGA.H_range(1)), min(maxH,opts.outerGA.H_range(2))];
if opts.outerGA.K_range(1)>opts.outerGA.K_range(2), opts.outerGA.K_range=[1 max(1,size(Z,2)-1)]; end
if opts.outerGA.H_range(1)>opts.outerGA.H_range(2), opts.outerGA.H_range=[1 maxH]; end
fprintf('Step 4/6: Outer & Inner GA optimization with FCM...\n');
[bestResult,bestCandidate,history]=hynef_outer_ga(H_full,TOM,opts);
U=bestResult.inner.membership; centers=bestResult.inner.centers;
Y=H_full(:,1:bestCandidate.H);
fprintf('Step 5/6: Final metrics and summary...\n'); metrics=hynef_cluster_metrics(Y,U,centers,bestCandidate.m,opts);
result=struct('geneNames',{geneNames},'preprocessedData',Z,'TOM',TOM,'adjacency',adjacency,'correlation',correlation, ...
 'latent',H_full,'projectionModel',projectionModel,'candidate',bestCandidate,'membership',U,'centers',centers, ...
 'metrics',metrics,'history',history,'bestResult',bestResult,'preprocessingInfo',prepInfo,'options',opts);
fprintf('  K=%d, m=%.4g, H=%d; PC=%.4f, PE=%.4f, XB=%.4g\n',bestCandidate.K,bestCandidate.m,bestCandidate.H,metrics.PC,metrics.PE,metrics.XB);
fprintf('Step 6/6: Exporting tables and figures...\n'); files=hynef_export_results(result,opts); result.outputFiles=files;
try
 fig=figure('Visible','off'); plot(history.generation,history.bestFitness,'-o'); xlabel('Generation'); ylabel('Best fitness'); title('HyNeF outer GA convergence'); grid on;
 exportgraphics(fig,fullfile(opts.outputDir,'fitness_history.png')); close(fig);
catch
 if exist('fig','var') && isgraphics(fig), close(fig); end
end
fprintf('HyNeF complete. Results: %s\n',opts.outputDir);
end
