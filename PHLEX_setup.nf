#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.path = '.'

process download_test_data {
    
    publishDir "${params.path}", mode: 'move'

    output: file '*/*.tiff'

    """
    wget https://zenodo.org/record/7665181/files/PHLEX_test_images.zip
    unzip PHLEX_test_images.zip
    """
}


workflow {

    download_test_data()

}