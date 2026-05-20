# immunopipe-ThomasW-2020

Reanalysis of the data from [Wu, Thomas D., et al. 2020](https://www.nature.com/articles/s41586-020-2056-8) using [immunopipe](https://github.com/pwwang/immunopipe).

> [Wu, Thomas D., et al. "Peripheral T cell expansion predicts tumour infiltration and clinical response." Nature 579.7798 (2020): 274-278.](https://www.nature.com/articles/s41586-020-2056-8)

## Data preparation

The data was downloaded from [GSE139555](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE139555).

The metadata is also downloaded and used to build a reference Seurat object. One could also use it to map the data to it, instead of using the unsupervised clustering.

See `prepare-data.sh` for details.

## Configuration

> [!NOTE]
> This is not a replication of the original paper, primarily due to the irreproducibility of the clustering results. This is a reanalysis of the data using [`immunopipe`](https://github.com/pwwang/immunopipe), showing the potential of the pipeline similar analyses listed in the paper.

The configuration can be found at `Immunopipe.config.toml`. Some settings may be different from the original paper. The analysis was done using `Seurat` v5. The integration of scRNA-seq data from individual samples were integrated by the `IntegrateLayers`, instead of `FindIntegrationAnchors` and `IntegrateData` workflow in the original paper.

When separating the T cells from the other cells, `CD3G`, `CD3D`, `CD14` and `CD68`, together with `CD3E`, which is the only indicator gene used in the original paper, were used to identify the T cells. Rather than a manual process, `immunopipe` uses k-means clustering to identify the T cells, using the expression of the above genes and TCR clonotype percentages as features.

The T cell clusters were not annotated with the cell types listed in the paper, as we couldn't replicate the exact clustering results from the original paper.

## Results/Reports


You can find the results in the `Immunopipe-output` directory.

The report can be found at [https://imp-thomasw-2020.pwwang.com/REPORTS](https://imp-thomasw-2020.pwwang.com/REPORTS).
