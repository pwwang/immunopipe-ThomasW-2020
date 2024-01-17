library(Seurat)
library(future)
# library(parallel)
library(glue)

set.seed(8525)

METAFILE <- "prepared-data/GSE139555_tcell_metadata.txt.gz"
DATADIR <- "prepared-data"
NCORES <- 8

options(future.globals.maxSize = 80000 * 1024^2)
plan(strategy = "multicore", workers = NCORES)

load_sample <- function(sample) {
    print(glue("- Loading sample: {sample} ..."))
    exprs <- Read10X(data.dir = file.path(DATADIR, sample))
    obj <- CreateSeuratObject(counts=exprs, project=sample)
    obj <- RenameCells(obj, add.cell.id = glue("ref_{sample}"))
    # Run SCTransform
    obj <- SCTransform(obj, method = "glmGamPoi", verbose = FALSE)
    obj
}

print("Loading and transforming samples ...")
samples <- c()
for (path in Sys.glob(file.path(DATADIR, "*"))) {
    if (file.info(path)$isdir) {
        samples <- c(samples, basename(path))
    }
}

# samples = samples[1:4]
obj_list <- lapply(samples, load_sample)

print("SelectIntegrationFeatures ...")
features <- SelectIntegrationFeatures(object.list = obj_list, nfeatures = 3000)

print("PrepSCTIntegration ...")
obj_list <- PrepSCTIntegration(object.list = obj_list, anchor.features = features)

print("PCA on each sample ...")
obj_list <- lapply(X = obj_list, FUN = RunPCA, features = features, verbose = FALSE)

print("Find anchors ...")
anchors <- FindIntegrationAnchors(
    object.list = obj_list,
    normalization.method = "SCT",
    anchor.features = features,
    reduction = "rpca",
    verbose = FALSE,
    reference = c(11, 24:26)
)

print("IntegrateData ...")
sobj <- IntegrateData(
    anchorset = anchors,
    dims = 1:30,
    normalization.method = "SCT",
    verbose = FALSE
)

rm(obj_list)

print("Reading metadata ...")
meta <- read.table(METAFILE, header=TRUE, sep="\t", row.names=1)

print("Filtering cells ...")
sobj <- subset(sobj, cells = rownames(meta))

print("RunPCA ...")
sobj <- RunPCA(sobj, verbose = FALSE)

print("RunUMAP ...")
sobj <- RunUMAP(sobj, reduction = "pca", dims = 1:30)

print("Adding metadata ...")
sobj <- AddMetaData(sobj, metadata = meta)

print("Saving reference ...")
saveRDS(sobj, file.path(DATADIR, "reference.RDS"))
