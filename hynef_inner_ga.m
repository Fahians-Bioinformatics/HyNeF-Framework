function best = hynef_inner_ga(Y,K,m,opts)
% Real/integer-coded GA over unique gene-index center chromosomes.
n=size(Y,1); K=min(max(1,round(K)),n-1); pop=max(2,round(opts.innerPopulation)); gens=max(1,round(opts.innerGenerations));
chrom=zeros(pop,K); fit=inf(pop,1); detail=cell(pop,1);
for p=1:pop, chrom(p,:)=randperm(n,K); [fit(p),detail{p}]=score(chrom(p,:)); end
for g=1:gens
 [~,ord]=sort(fit); next=zeros(size(chrom)); ne=min(max(1,opts.eliteCount),pop); next(1:ne,:)=chrom(ord(1:ne),:);
 for p=ne+1:pop
  a=selectParent(fit); b=selectParent(fit); child=chrom(a,:);
  if rand<opts.crossoverRate, mask=rand(1,K)<0.5; child(mask)=chrom(b,mask); end
  if rand<opts.mutationRate, pos=randi(K); available=setdiff(1:n,child); if ~isempty(available), child(pos)=available(randi(numel(available))); end, end
  child=uniqueFix(child,n,K); next(p,:)=child;
 end
 chrom=next;
 for p=1:pop, [fit(p),detail{p}]=score(chrom(p,:)); end
end
[best.fitness,idx]=min(fit); best.centerIndices=chrom(idx,:); best.centers=Y(best.centerIndices,:); best.membership=detail{idx}.U; best.metrics=detail{idx}.metrics; best.fcmInfo=detail{idx}.info;
 function [f,out]=score(ix)
  [u,c,infoc]=hynef_fcm(Y,K,m,opts,Y(ix,:)); met=hynef_cluster_metrics(Y,u,c,m,opts); f=met.objective;
  if ~isfinite(f), f=realmax/1e100; end; out=struct('U',u,'C',c,'metrics',met,'info',infoc);
 end
 function idx=selectParent(fv)
  a=randi(pop); b=randi(pop); if fv(a)<fv(b), idx=a; else, idx=b; end
 end
end
function x=uniqueFix(x,n,K)
x=round(x); x=max(1,min(n,x)); x=unique(x,'stable');
while numel(x)<K, avail=setdiff(1:n,x); x(end+1)=avail(randi(numel(avail))); end
x=x(1:K);
end
