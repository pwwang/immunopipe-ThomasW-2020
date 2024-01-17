#!/usr/bin/env bash

# The URL to the tar file
DATAURL="https://ftp.ncbi.nlm.nih.gov/geo/series/GSE139nnn/GSE139555/suppl/GSE139555_RAW.tar"
DATASHA="8aebf418433603d710df0c3652c616719f8d21c0"
DATAFILE="prepared-data/GSE139555.tar"
METAURL="https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE139555&format=file&file=GSE139555%5Ftcell%5Fmetadata%2Etxt%2Egz"
METAFILE="prepared-data/GSE139555_tcell_metadata.txt.gz"

echo "- Make the directory for prepared data ..."
mkdir -p prepared-data

echo "- Download the data if needed ..."
if [ ! -e $DATAFILE ] || [ "$(shasum $DATAFILE | cut -d' ' -f1)" != "$DATASHA" ]; then
    wget -O $DATAFILE $DATAURL
fi

echo "- Extract the data ..."
tar -xvf $DATAFILE --directory=./prepared-data

echo "- Separate desired samples ..."
for sample in $(ls -1b prepared-data/GSM*.*.gz | xargs -n 1 basename | cut -d. -f1 | cut -d'-' -f2 | sort | uniq); do
    mkdir -p prepared-data/"${sample^^}"
    mv prepared-data/*-"$sample".barcodes.tsv.gz prepared-data/"${sample^^}"/barcodes.tsv.gz
    mv prepared-data/*-"$sample".genes.tsv.gz prepared-data/"${sample^^}"/features.tsv.gz
    mv prepared-data/*-"$sample".matrix.mtx.gz prepared-data/"${sample^^}"/matrix.mtx.gz
    mv prepared-data/*-"$sample".filtered_contig_annotations.csv.gz prepared-data/"${sample^^}"/filtered_contig_annotations.csv.gz
done

echo "- Remove unnecessary files ..."
rm -rf prepared-data/*.tsv.gz prepared-data/*.csv.gz prepared-data/*.mtx.gz

echo "- Prepare reference data ..."
if [ ! -e "$METAFILE" ]; then
    wget -O "$METAFILE" "$METAURL"
fi
if [ ! -e "prepared-data/reference.RDS" ]; then
    # Seurat is needed to run this script
    Rscript prepare-reference.R
fi

echo "- Done!"
