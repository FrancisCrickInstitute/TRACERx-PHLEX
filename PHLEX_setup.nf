#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.path = '.'

process download_test_data {

    publishDir "${params.path}", mode: 'move'

    output: file '*/*.tiff'

    """
    wget https://zenodo.org/record/7665181/files/PHLEX_test_images.zip
    unzip PHLEX_test_images.zip
    rm PHLEX_test_images.zip
    """
}

process download_weights {
    
    publishDir "${params.path}", mode: 'move'

    output: file '*/*.tiff'

    """
    wget https://zenodo.org/record/7665181/files/deep-imcyto_weights.zip
    unzip deep-imcyto_weights.zip
    rm deep-imcyto_weights.zip
    """
}

process moveRunScript{
    
        publishDir "${params.path}", mode: 'move'

        input: file 'TRACERx-PHLEX/runPHLEX.sh'
        output: file 'runPHLEX.sh'
    
        """
        echo "Moving runPHLEX.sh to ${params.path}"
        """
}

workflow {

    download_test_data()
    download_weights()
    moveRunScript()
}