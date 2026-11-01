function opts = hynef_default_options()
% Default options for the runnable HyNeF reference implementation.
opts.seed=1; opts.outputDir='HyNeF_results'; opts.geneNames={};
opts.beta=6; opts.signedAdjacency=false; opts.correlationType='Pearson';
opts.maxHiddenDim=16; opts.hiddenDimRange=[2 8]; opts.kRange=[2 8]; opts.mRange=[1.5 2.8];
opts.outerPopulation=12; opts.outerGenerations=8;
opts.outerGA=struct('K_range',[2 8],'m_range',[1.5 2.8],'H_range',[2 8],'population',12,'generations',8,'tournamentSize',3,'crossoverRate',0.8,'mutationRate',0.18,'mutationSigma',0.15,'eliteCount',2); opts.innerPopulation=10; opts.innerGenerations=8;
opts.eliteCount=2; opts.mutationRate=0.18; opts.crossoverRate=0.8;
opts.fcmMaxIter=150; opts.fcmTol=1e-6; opts.entropyWeight=0.05; opts.complexityWeight=0.01;
opts.smallClusterWeight=0.1; opts.membershipThreshold=0.1; opts.eps=1e-10;
end
