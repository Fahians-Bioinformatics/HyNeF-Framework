# HyNeF MATLAB Reference Implementation

This folder contains a self-contained MATLAB implementation of a gene-module clustering workflow. It is a runnable reference implementation, not a claim of equivalence to a published method, journal readiness, or empirical validation.

## Package contents

Keep all 12 `.m` files in this folder and add the folder to the MATLAB path. `run_HyNeF.m` is the entry point. The helper files implement preprocessing, TOM construction, a fixed random projection, nested genetic algorithms (GAs), fuzzy c-means (FCM), metrics, option merging, and export.

## Input data and orientation

Input must be a numeric matrix with **samples/observations in rows and genes in columns**. It is not transposed automatically. For CSV input, each data row is a sample and each data column is a gene. The reader treats the first row as column headers by default; headers are used as gene names unless `opts.geneNames` is supplied. Thus, CSV files should have one header per gene and numeric values beneath them. Text entries in gene columns are converted to missing values where possible; a column with no finite numeric values is dropped when names are inferred. There is no special sample-ID-column handling: do not include a non-numeric sample identifier column as a gene. For a CSV without headers, supply a correctly formatted file with headers (or import/build a numeric matrix yourself), because `readtable` may interpret its first row as variable names.

Preprocessing converts data to double precision, replaces non-finite entries within a gene by that gene's median, removes all-missing and near-constant genes, then z-standardizes each retained gene. At least three usable genes must remain. Gene names must match the input matrix's original number of columns if explicitly supplied.

## Run

```matlab
addpath('/path/to/HyNeF_MATLAB_EN');
result = run_HyNeF('expression.csv');
```

Or pass a samples-by-genes matrix and options:

```matlab
X = randn(30, 40);                 % 30 samples by 40 genes
opts = struct();
opts.seed = 42;
opts.outputDir = 'HyNeF_results';
opts.geneNames = arrayfun(@(i) sprintf('Gene%d', i), 1:size(X,2), ...
                          'UniformOutput', false);
opts.maxHiddenDim = 4;
opts.hiddenDimRange = [2 4];
opts.outerGA = struct('K_range', [2 5], 'm_range', [1.6 2.4], ...
    'H_range', [2 4], 'population', 4, 'generations', 2, ...
    'tournamentSize', 2, 'crossoverRate', 0.8, 'mutationRate', 0.18, ...
    'mutationSigma', 0.15, 'eliteCount', 1);
opts.innerPopulation = 4;
opts.innerGenerations = 2;
opts.fcmMaxIter = 30;
result = run_HyNeF(X, opts);
```

The small settings above demonstrate the interface only; they are not a recommended analysis configuration or evidence of performance. For a quick run, use at least 12 nonconstant genes and ensure `K_range` is feasible (`K` is clamped below the number of genes). The outer population must be at least 2 and generations at least 1 in the implementation.

## Options actually used

Defaults are defined in `hynef_default_options.m`; user fields are recursively merged by `hynef_merge_options.m`.

- `seed` (default 1): seeds MATLAB's Twister random generator.
- `outputDir` (`HyNeF_results`): output folder.
- `geneNames`: optional cell/string-compatible names, one per input gene.
- `beta` (6): power for adjacency; `signedAdjacency` (false) chooses `abs(r)^beta` when false, or `((1+r)/2)^beta` when true.
- `maxHiddenDim` (16), `hiddenDimRange` ([2 8]): cap the generated latent width. The actual projection width is also limited by the gene count and the upper end of `hiddenDimRange`.
- `outerGA`: the active nested GA configuration: `K_range`, `m_range`, `H_range`, `population`, `generations`, `tournamentSize`, `crossoverRate`, `mutationRate`, `mutationSigma`, and `eliteCount`.
- `innerPopulation`, `innerGenerations`, and `eliteCount` (top-level): settings for the inner center-index GA. Note `eliteCount` is used for both GAs unless overridden in `outerGA`.
- `fcmMaxIter`, `fcmTol`: FCM iteration cap and convergence tolerance.
- `entropyWeight`, `complexityWeight`, `smallClusterWeight`, `eps`: reference objective and numerical-stability settings.
- `kRange`, `mRange`, `hiddenDimRange` are legacy top-level aliases for the corresponding outer ranges, applied only when `outerGA` is not supplied by the caller. If `outerGA` is provided, set its range fields directly.

Some fields present in the defaults are currently not consumed by the computation: `correlationType`, `membershipThreshold`, `outerPopulation`, `outerGenerations`, and the top-level `mutationRate`/`crossoverRate`. `outerGA` fields control the outer search. In particular, changing `correlationType` does not change the Pearson correlation calculation. These fields are retained for compatibility and should not be mistaken for active controls.

## Processing and algorithm implemented

1. `hynef_preprocess` imputes, filters, and standardizes the samples-by-genes matrix.
2. `hynef_build_tom` computes Pearson gene-gene correlations, transforms them into adjacency using the selected signed/unsigned rule and `beta`, and computes a bounded WGCNA-style topological overlap matrix (TOM). This is a lightweight implementation, not the full WGCNA package.
3. `hynef_random_projection` standardizes TOM rows, multiplies them by a seeded Gaussian weight matrix, applies `tanh`, then standardizes latent dimensions. Weights are generated once and are fixed during optimization; there is no learned projection or backpropagation. The outer search uses the first `H` dimensions of this fixed embedding. This fixed projection is a reference implementation choice, not independently verified as a published-method detail.
4. `hynef_outer_ga` searches integer `K` (cluster count), continuous fuzzifier `m`, and integer latent width `H`. Its mixed chromosome uses tournament selection, crossover, mutation, and elitism. For every candidate, `hynef_inner_ga` searches unique gene-index chromosomes for FCM starting centers. `hynef_fcm` then updates fuzzy memberships and centers.
5. `hynef_cluster_metrics` reports fuzzy partition coefficient (PC), partition entropy (PE), and Xie-Beni (XB), and uses the displayed manuscript objective `J = sum_j sum_i U(j,i)^2 * ||X(i,:)-C(j,:)||_2` as the GA fitness. Silhouette is computed from hard labels `argmax_j U(j,i)` using `s(i)=(b(i)-a(i))/max(a(i),b(i))`, and reported as validation (not added to J). PC, PE, and XB remain diagnostics only. A singleton cluster receives silhouette 0; if fewer than two hard clusters are occupied, the overall silhouette is NaN.

Randomness is seeded, including the fixed projection and GA/FCM initialization. Repeated runs with the same input, options, and compatible MATLAB environment are intended to be reproducible; exact results across MATLAB releases/platforms are not guaranteed. The outer evaluator currently catches candidate-evaluation errors and assigns a large penalty, so a failed candidate may not stop the run; inspect warnings/results and validate outputs rather than treating a completed run as proof of validity.

## Returned value and files

`run_HyNeF` returns a struct with retained gene names, preprocessed data, TOM, adjacency, correlation, full latent projection and model, winning candidate, membership matrix, centers, metrics, GA history, preprocessing details, effective options, and output-file paths.

The exporter writes to `opts.outputDir`:

- `module_assignments.csv`: one row per gene; assigned module is the maximum-membership module, with its membership value.
- `fuzzy_membership.csv`: one row per gene, with one membership column per module.
- `module_summary.csv`: module size, average maximum membership, TOM density, and mean intramodular connectivity.
- `hynef_results.mat`: saved complete result struct (MATLAB `-v7.3` format).
- `fitness_history.png`: outer-GA best-fitness plot, when the MATLAB graphics/export environment supports it. Plot export is optional and failures are suppressed.

## Dependencies and limitations

No Statistics and Machine Learning Toolbox FCM implementation is used; FCM is implemented in `hynef_fcm.m`. The workflow does require MATLAB functions for tables/CSV (`readtable`, `table`, `array2table`, `addvars`, `writetable`) and MAT saving. CSV input uses `readtable` with `VariableNamingRule='preserve'`; the optional plot uses graphics and `exportgraphics`. A recent MATLAB release with these APIs is recommended. Octave compatibility has not been established. Runtime, memory, and search cost grow with gene count and GA settings; TOM construction uses dense matrices and is not intended for very large gene sets without resource assessment.

No MATLAB or Octave executable was available during preparation, so this package has not been runtime-smoke-tested. The code and interfaces were statically inspected, but that does not establish numerical correctness or scientific validity.

## Extending the objective

The current objective is assembled in `hynef_cluster_metrics.m` and consumed by `hynef_inner_ga.m`; the outer GA uses the returned inner fitness. Change these connected points together if defining a different fitness. `hynef_evaluate_candidate` also receives TOM, but the current objective does not use it. Add any added diagnostics to the metrics struct to retain them in returned results. Validate changes with MATLAB execution and appropriate data; do not infer method equivalence from matching function names or output structure.


## Manuscript-alignment scope

The supplied flowchart provides explicit equations only for J and the per-observation silhouette. This revision implements those equations. The accompanying figures do not specify an ANN layer equation, trainable-weight update, activation (`TF_type`) definition, or a complete GA chromosome/fitness combining network topology; those details are not fabricated here. The existing fixed random projection and nested GA over K, m, H, and FCM center indices remain reference implementation behavior and should not be described as an exact trainable-ANN reproduction.
