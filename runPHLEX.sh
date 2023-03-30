#!/bin/bash

#LOAD MODULES
ml purge
ml Nextflow/22.04.0
ml Singularity/3.6.4

# export cache directory for singularity
export NXF_SINGULARITY_CACHEDIR='Singularity_cache'

release="PHLEX_test"

# deep-imcyto in MCCS mode
assetsDir=$PWD/TRACERx-PHLEX/deep-imcyto/assets
nextflow run TRACERx-PHLEX/deep-imcyto/main.nf \
   --input "$PWD/PHLEX_test_images/*.tiff" \
   --outdir "$PWD/results" \
   --release $release \
   --metadata "$PWD/TRACERx-PHLEX/deep-imcyto/assets/metadata/PHLEX_test_metadata.csv" \
   --nuclear_weights_directory "$PWD/deep-imcyto_weights/" \
   --segmentation_workflow 'MCCS' \
   --full_stack_cppipe "$assetsDir/cppipes/MCCS/full_stack_preprocessing.cppipe"\
   --segmentation_cppipe "$assetsDir/cppipes/MCCS/segmentationP1.cppipe" \
   --mccs_stack_cppipe "$assetsDir/cppipes/MCCS/mccs_stack_preprocessing.cppipe" \
   --compensation_tiff "$assetsDir/spillover/P1_imc*.tiff" \
   --plugins "$assetsDir/plugins" \
   -profile crick \
   -w 'scratch' \
   -resume

# TYPEx
nextflow run TRACERx-PHLEX/TYPEx/main.nf \
   -c $PWD/TRACERx-PHLEX/TYPEx/conf/testdata.config \
   --input_dir $PWD/results/deep-imcyto/$release/ \
   --sample_file $PWD/TRACERx-PHLEX/TYPEx/data/sample_data.tracerx.txt \
   --release $release \
   --output_dir "$PWD/results/TYPEx/$release/" \
   --params_config "$PWD/TRACERx-PHLEX/TYPEx/data/typing_params.json" \
   --annotation_config "$PWD/TRACERx-PHLEX/TYPEx/data/cell_type_annotation.p1.json" \
   --deep_imcyto true --mccs true \
   -profile singularity \
   --wd "scratch" \
   -resume
   
   
# Spatial-PHLEX
nextflow run TRACERx-PHLEX/Spatial-PHLEX/main.nf \
   --sampleFile "$PWD/TRACERx-PHLEX/Spatial-PHLEX/data/sample_data.tracerx.txt"\
   --objects "$PWD/results/TYPEx/$release/summary/*/cell_objects_${release}_p1.txt"\
   --phenotyping_column "majorType" \
   --barrier_phenotyping_column "majorType" \
   --outdir "$PWD/results" \
   --release $release \
   --workflow_name "default" \
   --barrier_source_cell_type "CD8 T cells"\
   --barrier_target_cell_type "Epithelial cells"\
   --barrier_cell_type "aSMA+ cells"\
   -w "scratch" \
   -resume
