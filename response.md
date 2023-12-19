# scbs benchmarks

correlation_fig = Figure 3: Correlation of DNA methylation and gene expression.

benchmark_fig = Fig 4 and Figs. S1 - S2

dmr_fig = Figure 6: Detection of differentially methylated regions between oligodendrocytes and neural stem cells.

## Revisions to do list:
- [ ] compare scbs with other software:
  - [ ] LIGER
  - [ ] scAI
  - [ ] EpiScanpy
  - [x] MOFA+
  - [ ] DeepCpG
  - [ ] epiclonal
  - [ ] MELISSA
  - [ ] scMET
- [ ] benchmark scbs on other data sets
  - [ ] Liu: https://doi.org/10.1038/s41586-020-03182-8 *[currently running scbs prepare]*
  - [ ] Chatterton: https://doi.org/10.1186/s13578-022-00938-9 (only raw data available)
  - [x] scNMT gastrulation data set?
- [x] demonstrate DMR / VMR detection in conditions such as age, cancer
- [x] use regulatory elements as features
  - [x] TSS ±2 kb
  - [x] Encode features as done in episcanpy
- [x] try on CH-methylation data (Luo et al) *ongoing*
- [x] disentangle the effect of iterative PCA from the effect of the use of mean shrunken residuals
  - [x] do a VMR PCA with imputed zeroes instead of iterative PCA
- [x] try different slding window step sizes and show that it doesn't matter so much
  
minor stuff
- [ ] determine cell number and seq coverage that is required for a sensible analysis
- [x] explore of smoothing in fixed intervals of a certain CpG number makes sense (as opposed to 2kb windows)
- [x] during variable window detection, two ends of the window would cancel each other out during variance calculation. Explore whether this matters or happens at all.




## Reviewers' Comments:

### Reviewer #1:
> Remarks to the Author:
> Kremer and colleagues have proposed an innovative dimensionality
> reduction technique, specifically tailored for the analysis of
> single-cell bisulfite sequencing data. This novel approach is predicated
> on the understanding that fixed-size window tiling can result in the
> dilution of cell type-specific signals. As an alternative, the authors
> have suggested a process whereby variably methylated regions (VMRs) are
> identified first, followed by the execution of dimensionality reduction
> on these VMRs. The study compellingly demonstrates that this novel
> approach can yield improved discrimination of cell types.

> Although the limitations of a fixed size window average have long been
> suspected, no previous studies have explored this issue with the depth
> and rigor seen in the current work. The authors compellingly
> demonstrated the superiority of the VMR-based method over the
> conventional 100kb bin average.

> However, a few points for consideration arise:

> There are several existing methods that handle single-cell methylome
> dimensionality reduction and imputation, such as LIGER, scAI, EpiScanpy
> MOFA/MOFA+, which are general-purpose tools that support DNA methylation
> analysis, as well as others like DeepCpG, epiclomal, MELISSA and scMET
> that are specifically focused on DNA methylation (see PMID 35718270 for
> a recent review). The present manuscript, however, only appears to
> compare the new method with the simplest fixed-size window approach,
> without discussing these other, more recently developed methods.

- we expanded the discussion of the paper to discuss these tools and how their functionality compares to scbs
- e.g. none of them is designed find VMRs or DMRs
- furthermore, we demonstrate that MOFA+ is fully compatible with scbs, i.e. it can be used for dimensionality reduction of methylation matrices (%meth or residuals) and, when using VMRs, performs similar to iterative PCA while using less RAM at the cost of a longer runtime.

> It's not entirely clear how this method would be applicable to datasets
> where the primary source of biological variation isn't cell type but
> rather other biological factors such as normal vs. cancer, age, or
> different cell cycle stages. These factors could potentially lead to
> VMRs being present at various genomic scales. Are parameter adjustments
> necessary under these conditions?

- Lukas: I'm re-visiting the Argelaguet scNMT-seq gastrulation data set for this question. We can use it as another benchmarking data set to distinguish cell types, but I will also check if we can distinguish embryonic developmental stages and not just cell type.

> While the direct detection of VMRs from data is certainly a desirable
> feature, it's worth noting that this approach could be computationally
> demanding. A comparison with a less complex alternative that aggregates
> methylation using known biological annotations of regulatory elements
> (for example, from ENCODE, as implemented in EpiScanpy) could provide
> additional insight into the relative advantages and disadvantages of the
> proposed method.

- we added the latest annotation of ENCODE candidate cis-Regulatory Elements (cCREs) in our benchmarks
- these regions are indeed suitable to distinguish cell types, as they outperformed both 100kb tiles and promoter regions in out benchmarks and performed similarly to VMRs  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/f43be414-65f3-46ef-be93-bf0a5a83471d)  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/1759a17e-2b90-484b-9d19-3b21069104cd)  
- however, due to the large number of annotated cCREs (~340k in mouse) the resulting methylation matrices occupied lots of RAM even in data sets of modest size and took longer to process than the ~60k detected VMRs  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/70c678a3-b2fd-4d38-b05c-57bbd2011f03)  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/8caaa5b2-5eaa-459d-a380-501f1b08cb99)  
- of course, it might not be necessary to use all cCREs to distinguish cell types. In fact, many dimensionality reduction tools such as MOFA+ recommend strict feature selection, i.e. the exclusion of genomic features with low seuqencing coverage. Thus, we obtained the ~60k cCREs with the greatest sequencing coverage and repeated the benchmarks on this reduced data set. As expected, this reduced runtime and RAM usage, but cell type distinction was compromised compared to the full set of cCREs or VMRs.  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/25a82dd2-d579-41fa-8b42-39ca038c148d)
![image](https://github.com/LKremer/scbs-figures/assets/15158974/9ea24835-689a-4cd5-977a-5908bc7df535)  
- thus, VMR detection might more computationally efficient, even when accounting for the additional VMR detection step
- its also kind of cool that our ~60k VMRs perform equally well to the ~340k cCREs which were identified by ENCODE, hundreds of sequencing data set, while we can just find equally informative regions in 1500 methylomes
- furthermore, VMR detection offers a data-driven approach for sc-methylome analysis that does not require any prior knowledge on the genomic regions that might be informative. While cCREs seem to be suitable to distinguish cell types, not all biological factors of interest might be detectible at cCREs. Furthermore, cCREs are only available for mouse and human.

> The method's effectiveness when applied to non-CG methylation should be
> explored, given that this form of methylation is recognized for its
> greater discriminatory power among neurons.

> Philosophically, how does the method address the balance of information
> and sparsity? Smaller VMRs could indeed provide higher discriminatory
> power, but they may also be more affected by data sparsity, making
> imputation necessary for cross-cell comparison.

> It seems the method still relies on choosing a small window size and a
> step size for VMR detection. How would this parameter be chosen and how
> does this affect the cell clustering?

- To address this valid question, we performed an additional parameter sweep of the step size parameter. This benchmark revealed that step sizes between 5bp and 200bp perform very similarly, while performance dropped when using a step size of 500bp or 1000bp.  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/e7e25ab3-ad31-4e21-8bd9-02b74be4ff15)  
- As a greater step size leads to faster runtime of the VMR detection algorithm, we thus increased the default step size from 10bp to 100bp. We thank the reviewer for their valuable suggestion.

> The methodology was benchmarked against the authors' mouse brain data.
> It would be valuable to extend this comparison to other datasets, such
> as those produced by the research groups led by Joe Ecker and Wolf Reik.

- it's challenging to find a data set with ground truth cell type labels, i.e. cell type labels derived not from methylation data but from transcriptomic data, so currently we are a bit limited in our possibilities
- we include the gastrulation scNMT data set from Wolf Reiks lab

> In reference to Figure 4B and C, the utilization of neighbor scores to
> evaluate separation seems ambiguous. Lower neighbor scores can still
> result in clear separability, making the choice of these scores for
> analysis somewhat counterintuitive. Furthermore, the choice to perform
> this neighbor score analysis on PC space rather than the UMAP as
> depicted in Figures B and C could use further clarification.

- how can low neighbor scores result in clear separability?
- UMAP is just for visualization, and of course reducing the whole complexity of the data set to 2D loses lots of detail. So its better to look at the underlying PC space.

> Has the team attempted to use tSNE with varying perplexity parameters?
> This could be another beneficial comparison to further evaluate the
> effectiveness of their proposed method.

- why though


### Reviewer #2:
> Remarks to the Author:
> Kremer et al have presented a paper describing a novel approach to the
> quanitation, normalisation and analysis of single cell bisulphite data
> which aims to address issues of technical bias and signal dilution in
> some of the existing approaches. They provide a description of their
> method, a python software package to implment the processing steps
> (supplemented by example R code for some parts of the described
> analysis), and an example analysis of data from both their group and and
> an external dataset.

> The paper is well written, with a clear description of the problems with
> current approaches, and justifications for their new methods. The method
> itself is clearly and concisely described. I was able to install their
> software from the PyPi repository and could follow through all the steps
> in their analysis using the example code on their site.

> In general this method is an interesting and well thought out approach
> which offers improvements over existing methods, however there are some
> places where additional clarification or illustration would be useful.

> The initial step in the analysis turns the measured methylation values
> into residuals to a globally calculated methylation value across all
> cells. The initial description of this in the paper talks about
> subtracting the mean methylation for each position, but if I'm reading
> it correctly it's actually the smoothed running value which is used.

> [1] It would be useful to have some comment on the density of data which
> would be necessary for this approach. The datasets used by the authors
> feature thousands of cells, but many scBS experiments are much smaller
> than that, and in those a large proportion of all CpG positions will be
> measured in only 1 or 2 cells, giving little opportunity for calculating
> sensible global values against which to normalise.

To explore how our methods fare on smaller data sets, we performed our benchmarks on sub-sampled data sets, the smallest of which comprise only 100 cells.
Importantly, these sub-samples were processed completely independently, which means that the smoothed averages against which we later normalize were computed separately for data sets of various cell numbers.
These benchmarks show that cell types are indeed more difficult to assign for such small data sets, as indicated by the lower neighbor scores.
However, this is also true when using the average methylation % instead of the shrunken mean of the residuals as a measure of DNA methylation, suggesting that our method does not worsen performance, and in contrast it even increased performance when using 100kb tiles or promoter regions as features.

> [2] In a few places in the paper (kernel smoothing and detection of
> variable and differentially methlylated regions) the methods use small,
> fixed size windows, as the basis for analysis - often 1000bp. This size
> of window can be problematic in BS-Seq data given the uneven
> distribution of CpGs across the genome, and the potential for this to
> introduce bias into the results. Would smoothing in windows of fixed
> numbers of CpGs make more sense?

This is an excellent suggestion.
We imagine that using a fixed number of CpG sites instead of a fixed number of base pairs might indeed be more sensible, as this approach would prevent the evaluation of near-empty genomic windows, i.e. windows in genomic regions with little CpG density that might only contain one or two CpG sites.
Furthermore, the proposed approach would create smaller windows in CpG-dense areas, which would lead to a more fine-grained evaluation of CpG islands.
To put this suggestion to the test, we created a fork of the scbs package at https://github.com/LKremer/scbs/tree/adaptive_bandwidth where the sliding window used for VMR detection always comprises a fixed number of CpG sites.
Testing this approach on our own multi-omics data set, using 9 CpG sites per window, produced very promising results:
We found that VMRs detected with this approach led to a slightly better neighbor score (i.e. better cell type separation), as well as decreased runtime of the VMR detection procedure.
For now, we consider this implementation experimental as its currently lacking unittests as well as extensive benchmarks on multiple data sets.
Furthermore, there are some implementation details that we have not resolved yet:
Especially in smaller data sets with low coverage and/or few cells, there might be substantial gaps with zero coverage between individual CpG sites.
Does it nonetheless make sense to include adjacent CpG sites into one window, or should there be a maximum distance at which windows are broken into smaller pieces?
For now, we thus decided to stick to the "classic" sliding window approach, but if future benchmarks confirm the superiority of this approach we will update the scbs package accordingly.

> [3] When selecting the variably methylated regions the method takes the
> mean of the residuals in a given region. Does this mean that if adjacent
> regions changed in opposite directions that this would be averaged away
> and the region discarded as uninteresting?

VMRs coordinates are determined by merging overlapping genomic windows above a variance threshold (2% by default).
Although the variance is then re-calculated for the entire VMR, this value is not used for a secondary filtering step but only reported in the output file of `scbs scan`.
The rationale behind this is that we also want to report regions where the variance of individual windows briefly drops below the variance threshold - such as the one depicted in Fig. 2:  
![Fig_sliding](https://github.com/LKremer/scbs-figures/assets/15158974/e8f68d28-806e-4a4a-be6f-5a4d05fde243)  
In this example, two of the 2kb windows in the center of the VMR are just barely below the variance threshold, but we nonetheless report the entire region because the 2kb windows above the threshold are 2kb wide and are thus able to "bridge the gap".
Similarly, in the scenario described by the reviewer, a VMR with two opposite trends would not be discarded as long as the individual 2kb windows are above the 2% variance threshold.
However, our data indicate that such regions are rather rare.
A closer look at the variances of all 2kb windows of the largest chromosome, as well as the variances of reported VMRs, shows that the majority of VMRs are above the 2% variance threshold (red line).  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/9bf7845a-e9cd-4887-8b32-3176ee8baeaa)  
As expected due to the two scenarios described above, the region-wide variance of some VMRs is slightly below the 2% window variance threshold.
However, these variances are still well above genome-wide background levels (blue line: average of all genomic windows), suggesting that cancellation of two opposing signals as described by the reviewer is not common.

> The authors illustrate the effectiveness of their method by showing a
> PCA of a set of cells separated by their VMR process, compared to a more
> conventional separation by simple methylation calculation. In the VMR
> PCA there are two potentially influential steps - the conversion of
> methylation to residuals, and the imputation of missing values by
> iterative PCA. It would be useful to know which of these was having the
> greatest influence, since it's possible that it is the imputation which
> is causing the clearer separation through the reinforcement of the
> initial signal, rather than that the initial values are clearer.

It is true that our previous benchmarks did not allow us to distinguish the effects of the choice of dimensionality reduction technique (e.g. iterative PCA) from the choice of DNA methylation measure (average methylation % or shrunken means of the residuals).
To disentangle the influence of these analysis options, we refined our benchmarks by testing all possible combinations of the following choices:
- genomic features at which DNA methylation is quantified (100kb tiles, VMRs, promoters or ENCODE candidate cis-regulatory elements (cCREs))
- the measure used to quantify DNA methylation at these features (average methylation % or the shrunken mean of the residuals)
- dimensionality reduction methods (iterative PCA as proposed by us, lightly-imputed PCA on high-coverage features as proposed by Luo et al., or PCA with the missing values set to the column-mean (i.e. zero when using residuals) as suggested by this reviewer in comment [4])  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/f43be414-65f3-46ef-be93-bf0a5a83471d)  
![image](https://github.com/LKremer/scbs-figures/assets/15158974/1759a17e-2b90-484b-9d19-3b21069104cd)  
Based on these new results, we can now draw more detailed conclusions on the impact various choices of methods:
1. Using the shrunken means of the residuals over average methylation percentages provides the greatest benefit when quantifying promoters or 100kb tiles.
   The likely reason for this is that these regions are more heterogeneously methylated than VMRs or cCREs:
   100kb tiles are very large and thus each tile will comprise stretches of DNA with high and low methylation.
   Similarly, many promoter regions (here: TSS±2kb) will comprise a lowly-methylated center region near the TSS, as well as more highly methylated promoter flanks.
   As the shrunken mean of the residuals is designed to account for this heterogeneity within a region (Fig. 1), it makes sense that we see the greatest benefit of their use when quantifying promoters or large tiles.
2. The use of iterative PCA over other PCA-variations constantly improved the ability to distinguish cell types.
   The main reason for this performance gain is that iterative PCA alleviates differences between low-quality and high-quality cells, as is clearly visible in these plots:
   [add plot here]
3. Overall, it is clearly visible that the most important choice is the set of genomic features to be quantified. Our results indicate that both VMRs and ENCODE cCREs are suitable for this task and offer good ability to distinguish cell types, although using cCREs requires more RAM and runtime.

> [4] What would a PCA of the VMR values with missing values still set to
> 0 look like? This would be a more direct comparison to the global
> calculation and would demonstrate which step is more important in the
> improved separation they show.

This comment was addressed and illustrated in our response to the previous comment, where we show benchmarking results and exemplary plots of zero-imputed PCAs.

> [5] In the DMR detection they show a comparison of 130 cells and 58
> cells, but am I right in thinking that these cells were split off only
> after calculating the normalised VMR values from a much larger
> population of cells? Does the approach still work as effectively if
> starting from the 188 cells in the DMR analysis, or do you require the
> context of the larger dataset to get accurate VMR values to put into the
> DMR detection?

Yes, the 130 vs 58 cells used for DMR detection were split off from a larger data set (comprising 540 cells) and compared against each other, as is commonly done in scRNA-seq where users might select two cell clusters for differential gene expression testing.
To clarify, the DMR detection procedure does not use any VMR coordinates that were detected on the full data set, as DMR coordinates are newly discovered on the selected sub-data set.
However, as the reviewer rightly points out, the DMR detection uses the shrunken mean of the residuals as a measure of methylation, which in turn uses the smoothed average genomic methylation values for normalization.
These smoothed averages were indeed calculated on the full data set and not on the reduced set of 130 + 58 cells.
To assess whether this would affect DMR detection, we thus repeated the DMR analysis depicted in Fig. 6 on the 130 + 58 cells only, using smoothed genomic averages calculated on these cells only.
The obtained oligodendrocyte- and NSC-DMR sets are largely consistent with those obtained using smoothed averages obtained from the full data set.
For comparison, here is Fig. 6 from the manuscript (full data set) and Fig. 6 based on the reduced data set only:

All 540 cells (current manuscript version of the figure):  
![Fig_DMRs](https://github.com/LKremer/scbs-figures/assets/15158974/51287393-fba8-4e2f-a82f-6359a57ed985)  
130 + 58 cells only:  
![Fig_DMR_showcase](https://github.com/LKremer/scbs-figures/assets/15158974/18ac2686-be83-47df-ba9d-579c1670867b)  
While the DMR lists obtained using both approaches are not 100% identical, the results are qualitatively similar and yield similar largely identical top 5 enriched GO terms.

> [6] In the DMR calculation the false discovery rate is estimated by
> shuffling cell labels and repeating the analysis - which seems to be a
> reasonable idea for this type of data. However, the FDR estimation is
> done only after the initially calculated windows are filtered for the
> top 2% then merged if they are adjacent. The values tested are those
> from the recalculated t-statistic after merging. I would assume that the
> approach shown heavily favours regions which are much larger than the
> initial window size, and that the major contribution to significance is
> adjacency in the initially filtered top 2% of regions. Does this method
> work if the FDR values are calculated from the original window data,
> before merging adjacent windows? If not, then what size of DMR is
> realistically detectable with this method?

L: Ok, here we have to discuss a bit and explain that we want to be able to detect DMRs of flexible size.
Calculating FDR for individual windows would work, but once we merge them the FDR of the entire region is unclear.  
Maybe its also worth demonstrating that DMR detection works even if we don't merge windows, so its not the window merging thats driving significance.
Without merging, we get some nice DMRs but all of them have the same width, of course, which doesn't make so much sense:
![image](https://github.com/LKremer/scbs-figures/assets/15158974/fd2301ca-00d5-4bff-a3fb-a70099d367bd)


### Reviewer #3:
> Remarks to the Author:
> Kremer et al describe ‘scbs’ – a computational toolset for the analysis
> of single-cell methylation data. In the field there is certainly a need
> for a suite of tools to handle single-cell methylation data, and the
> manuscript details several compelling strategies and frameworks for
> doing so. The most significant aspect is the identification of variable
> regions that are then used for subsequent dimensionality reduction,
> clustering and visualization; followed by tools for DMR calling. The
> authors apply ‘scbs’ to their own, published, scNMT-seq dataset on brain
> as well as some applications to a dataset produced by the Ecker Lab,
> also brain. While there are positives to the work, there are key
> limitations in the assessment of the tool that need to be performed in
> order to properly evaluate the tool and its broader utility. Lastly, the
> name itself is a term that is already used to define an experimental
> approach” “single-cell bisulfite sequencing” – whereas this reports on a
> computational tool for that type of data (or enzymatic-converted data,
> which is not bisulfite). I strongly suggest changing the name of the
> tool to something informative – e.g. SCMtools for “single-cell methylome
> tools” – anything that indicates that it is a computational tool and
> used for analysis of single-cell methylome data.

> Major Comments:

> The authors perform almost all of their evaluation solely on their own
> dataset with very little analysis of the Luo et al 2017 dataset.
> Furthermore, their only comparison of methodology is by using 100 kbp
> tiling windows for CpG methylation levels, which does not seem all that
> appropriate. Using relevant windows – e.g. all annotated promoters and
> enhancers like geneHancer or something like that is a much more
> reasonable strategy. Even just all promoter regions such as TSS +/- 2
> kbp or something.

In response to this comment, we greatly expanded the scope of our benchmarks by including additional data sets as well as other sets of genomic regions.
Specifically, we added the following data sets: ...
Furthermore, as kindly suggested by this reviewer, we included the set of promoter regions (TSS ± 2 kbp), as well as the latest release of human and mouse candidate cis-regulatory elements (cCREs) published by the ENCODE consortium.  

Add a quick summary of our updated conclusions here:
- if you're working on human/mouse, cCREs also work nicely, but lead to hefty resource and time requirements on intermediate to big data sets.
- our proposed approach (VMR detection -> residuals) robustly worked across all tested data sets

> They do not compare cluster resolution with CH methylation windows which
> is generally used for neuron subtype clustering (as often CpG
> methylation will be the same between two subtypes of the same class, eg
> excitatory, but the CH levels will be different). Does the tool work
> with CH methylation? How does the variable window approach for CpG
> methylation look compared to 100 kbp tiling CH methylation (where 100
> kbp tiles make sense due to the structure of the mark in neurons).

Here we have to kindly explain the following:
- to assess performance of a given combination of analysis methods, we assess its ability to distinguish cell types (neighbor score)
- for this, we need ground-truth cell type labels
- in our own dataset, we also have the transcriptome of each cell, which we can use to infer ground-truth cell type labels
- most published data sets only have methylome information though, so we cant use them for benchmarking
- as the cell type labels published by Luo et al. are already based on CH methylation, we cannot use these labels as a ground truth for benchmarking the performance of our tool on CH-data
- nonetheless, to demonstrate that scbs can be used to quantify and explore CH-data, we performed a representative CH-methylation analysis on Luo's data (add a UMAP based on CH-data here)

> These analyses should be carried out on both their own dataset, the Luo
> et al dataset, but also on datasets from other tissue types. For example:

> Argelaguet R, Clark SJ, Mohammed H, Stapel LC, Krueger C, Kapourani CA,
> Imaz-Rosshandler I, Lohoff T, Xiang Y, Hanna CW, Smallwood S,
> Ibarra-Soria X, Buettner F, Sanguinetti G, Xie W, Krueger F, Göttgens B,
> Rugg-Gunn PJ, Kelsey G, Dean W, Nichols J, Stegle O, Marioni JC, Reik W.
> Multi-omics profiling of mouse gastrulation at single-cell resolution.
> Nature. 2019 Dec;576(7787):487-491. doi: 10.1038/s41586-019-1825-8. Epub
> 2019 Dec 11.

> Chatterton, Z., Lamichhane, P., Ahmadi Rastegar, D. et al. Single-cell
> DNA methylation sequencing by combinatorial indexing and enzymatic DNA
> methylation conversion. Cell Biosci 13, 2 (2023).
> https://doi.org/10.1186/s13578-022-00938-9
<https://doi.org/10.1186/s13578-022-00938-9> (Enzymatic conversion workflow)

We were unable to retrieve the cell type annotation and methylation report files for this particular data set, but as mentioned in a previous reply, we included X additional data sets from various tissues in our benchmarks.

> Furthermore, the tool is demonstrated on relatively small datasets on
> the order of ~3000 cells; however, single-cell methylation datasets are
> increasing in size – the Luo et al dataset used is quite old at this
> point, with much larger datasets produced by the Ecker and Luo labs,
> with hundreds-of-thousands of cells. It is likely that such datasets
> will become more common and any tool that will reach wide adoption will
> have to be able to handle large datasets. At least one of these should
> be used as an example with compute times reported – eg:

> Liu, H., Zhou, J., Tian, W. et al. DNA methylation atlas of the mouse
> brain at single-cell resolution. Nature 598, 120–128 (2021).
> https://doi.org/10.1038/s41586-020-03182-8
<https://doi.org/10.1038/s41586-020-03182-8> (~100k cells)
> Or the newer dataset that is ~300-400k cells; however, the 100k cell
> dataset should be sufficient for demonstration purposes. Again comparing
> CH methylation 100 kbp windows (standard for neurons) vs variable
> windows vs promoters & enhancers.

L: I think they are underestimating the size of these data sets, and also how uncommon such huge data sets currently are.
Even the smaller 100k cell data set was stitched together from almost 40 separate experiments, and the analysis likely took months to complete...
Quantifying enhancers in this data set is not feasible for sure, the methylation matrix would be 110k cells x 340k regions.
We can try CpG (not CH) in genomic tiles and/or VMRs just as a proof of concept.
To show that we can work with CH meth, we should use the Luo data set.
