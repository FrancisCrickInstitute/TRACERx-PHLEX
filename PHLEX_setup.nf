#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.path = '.'
params.runScript = "$PWD/TRACERx-PHLEX/runPHLEX.sh"

process download_test_data {

    publishDir "${params.path}", mode: 'move'

    output: file '*/*.tiff'

    """
    wget https://zenodo.org/record/8263899/files/PHLEX_test_images.zip
    unzip PHLEX_test_images.zip
    rm PHLEX_test_images.zip
    """
}

process download_weights {
    
    publishDir "${params.path}", mode: 'move'

    output: 
        file '*/*.hdf5'
        file '*/*.pkl'

    """
    wget https://zenodo.org/record/8263899/files/deep-imcyto_weights.zip
    unzip deep-imcyto_weights.zip
    rm deep-imcyto_weights.zip
    """
}

process moveRunScript{
    
        publishDir "${params.path}", mode: 'copy'

        input: path rs
        output: file 'runPHLEX.sh'
    
        """
        echo "Moving ${rs} to ${params.path}"
        """
}

workflow {

    println("Performing PHLEX setup.")
    download_test_data()
    download_weights()
    moveRunScript(params.runScript)

}