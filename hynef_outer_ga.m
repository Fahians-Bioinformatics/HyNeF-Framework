function [bestResult,bestCandidate,history] = hynef_outer_ga(H_full,tom,opts)
% Mixed integer/continuous GA for K, fuzzifier m, and latent dimension H.
if nargin<3 || isempty(opts), opts=hynef_default_options(); end
cfg=opts.outerGA;
kr=cfg.K_range; mr=cfg.m_range; hr=cfg.H_range;
if size(H_full,1)<2, error('At least two genes are required by the outer GA.'); end
kr=[max(1,ceil(min(kr))) min(size(H_full,1)-1,floor(max(kr)))];
hr=[max(1,ceil(min(hr))) min(size(H_full,2),floor(max(hr)))];
if kr(1)>kr(2), kr=[1 max(1,size(H_full,1)-1)]; end
if hr(1)>hr(2), hr=[1 size(H_full,2)]; end
mr=sort(double(mr)); if numel(mr)~=2 || mr(1)<=1, error('m_range must contain two values greater than 1.'); end
pop=max(2,round(cfg.population)); gens=max(1,round(cfg.generations));
chrom=zeros(pop,3); fitness=inf(pop,1); results=cell(pop,1);
for i=1:pop
 chrom(i,:)=randomChromosome(); [fitness(i),results{i}]=evaluate(chrom(i,:));
end
history=struct('generation',zeros(gens+1,1),'bestFitness',zeros(gens+1,1),'bestCandidate',cell(gens+1,1));
[history.bestFitness(1),ix]=min(fitness); history.generation(1)=0; history.bestCandidate{1}=decode(chrom(ix,:));
bestFitness=fitness(ix); bestGene=chrom(ix,:); bestResult=results{ix};
for g=1:gens
 [~,ord]=sort(fitness); next=zeros(size(chrom)); ne=min(max(1,round(cfg.eliteCount)),pop); next(1:ne,:)=chrom(ord(1:ne),:);
 for j=ne+1:pop
  a=tournament(); b=tournament(); child=chrom(a,:);
  if rand<cfg.crossoverRate
   if rand<0.5
    alpha=rand; child(2)=alpha*chrom(a,2)+(1-alpha)*chrom(b,2);
    child([1 3])=chrom(a,[1 3]); if rand<0.5, child(1)=chrom(b,1); end; if rand<0.5, child(3)=chrom(b,3); end
   else
    mask=rand(1,3)<0.5; child(mask)=chrom(b,mask);
   end
  end
  if rand<cfg.mutationRate
   q=randi(3);
   if q==2
    if rand<0.7, child(2)=child(2)+randn*cfg.mutationSigma*(mr(2)-mr(1)); else, child(2)=mr(1)+rand*(mr(2)-mr(1)); end
   elseif q==1
    if rand<0.7, child(1)=child(1)+round(randn*max(1,(kr(2)-kr(1))/6)); else, child(1)=randi([kr(1) kr(2)]); end
   else
    if rand<0.7, child(3)=child(3)+round(randn*max(1,(hr(2)-hr(1))/6)); else, child(3)=randi([hr(1) hr(2)]); end
   end
  end
  child(1)=min(kr(2),max(kr(1),round(child(1)))); child(2)=min(mr(2),max(mr(1),child(2))); child(3)=min(hr(2),max(hr(1),round(child(3)))); next(j,:)=child;
 end
 chrom=next;
 for i=1:pop, [fitness(i),results{i}]=evaluate(chrom(i,:)); end
 [genBest,ix]=min(fitness); if genBest<bestFitness, bestFitness=genBest; bestGene=chrom(ix,:); bestResult=results{ix}; end
 history.generation(g+1)=g; history.bestFitness(g+1)=bestFitness; history.bestCandidate{g+1}=decode(bestGene);
end
bestCandidate=decode(bestGene);
 function c=randomChromosome()
  c=[randi([kr(1) kr(2)]), mr(1)+rand*(mr(2)-mr(1)), randi([hr(1) hr(2)])];
 end
 function c=decode(x), c=struct('K',round(x(1)),'m',x(2),'H',round(x(3))); end
 function [f,r]=evaluate(x)
  try, r=hynef_evaluate_candidate(decode(x),H_full,tom,opts); f=r.fitness; if ~isfinite(f), f=realmax/1e100; end
  catch, r=[]; f=realmax/1e100; end
 end
 function idx=tournament()
  t=max(2,min(pop,round(cfg.tournamentSize))); cand=randi(pop,[t 1]); [~,ii]=min(fitness(cand)); idx=cand(ii);
 end
end
