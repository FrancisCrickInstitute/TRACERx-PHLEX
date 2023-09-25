#!/bin/bash

#LOAD MODULES
ml purge
ml Nextflow/22.04.0
ml Singularity/3.6.4

# export cache directory for singularity
export NXF_SINGULARITY_CACHEDIR='.singularity'

release="PHLEX_test"

# deep-imcyto in MCCS mode
assetsDir=$PWD/TRACERx-PHLEX/deep-imcyto/assets
nextflow -log "$PWD/results/deep-imcyto/$release/logs/deep-imcyto.log" \
    run TRACERx-PHLEX/deep-imcyto/main.nf \
    --input "$PWD/PHLEX_test_images/*.tiff" \
    --outdir "$PWD/results" \
    --release $release \
    --metadata "$PWD/TRACERx-PHLEX/deep-imcyto/assets/metadata/PHLEX_test_metadata.csv" \
    --nuclear_weights_directory "$PWD/deep-imcyto_weights/" \
    --segmentation_workflow 'MCCS' \
    --full_stack_cppipe "$assetsDir/cppipes/MCCS/full_stack_preprocessing.cppipe"\
    --segmentation_cppipe "$assetsDir/cppipes/MCCS/segmentationP1.cppipe" \
    --mccs_stack_cppipe "$assetsDir/cppipes/MCCS/mccs_stack_preprocessing.cppipe" \
    --compensation_tiff "$assetsDir/spillover/P1_imc_sm_pixel_adaptive.tiff" \
    --singularity_bind_path '/camp,/nemo'\
    --plugins "$assetsDir/plugins" \
    -profile crick \
    -w 'scratch' \
    -resume

# TYPEx
nextflow -log "$PWD/results/TYPEx/$release/logs/TYPEx.log" \
    run TRACERx-PHLEX/TYPEx/main.nf \
    -c $PWD/TRACERx-PHLEX/TYPEx/test.config \
    --input_dir $PWD/results/deep-imcyto/$release/ \
    --sample_file $PWD/TRACERx-PHLEX/TYPEx/data/sample_file.tracerx.txt \
    --release $release \
    --params_config "$PWD/TRACERx-PHLEX/TYPEx/data/typing_params_MCCS.json" \
    --annotation_config "$PWD/TRACERx-PHLEX/TYPEx/data/cell_type_annotation.testdata.json" \
    --color_config $PWD/TRACERx-PHLEX/TYPEx/conf/celltype_colors.json \
    --tissue_seg_model "$PWD/TRACERx-PHLEX/TYPEx/models/tumour_stroma_classifier.ilp" \
    --output_dir "$PWD/results/TYPEx/$release/" \
    --deep_imcyto true --mccs true \
    -profile singularity \
    -w 'scratch' \
    -resume


# Spatial-PHLEX
nextflow -log "$PWD/results/Spatial-PHLEX/$release/logs/Spatial-PHLEX.log"\
    run TRACERx-PHLEX/Spatial-PHLEX/main.nf \
    --workflow_name 'clustered_barrier' \
    --objects "$PWD/results/TYPEx/$release/summary/*/tables/cell_objects_${release}_p1.txt"\
    --objects_delimiter "\t" \
    --image_id_col "imagename"\
    --phenotyping_column 'majorType'\
    --phenotype_to_cluster 'Epithelial cells'\
    --x_coord_col "centerX"\
    --y_coord_col "centerY"\
    --barrier_phenotyping_column "majorType" \
    --barrier_source_cell_type "CD8 T cells"\
    --barrier_target_cell_type "Epithelial cells"\
    --barrier_cell_type "aSMA+ cells"\
    --n_neighbours 10\
    --outdir "../results" \
    --release $release \
    --singularity_bind_path '/camp,/nemo'\
    -w "scratch"\
    -profile crick \
    -resume
