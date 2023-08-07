.. _TYPEx_anchor:
.. role:: bash(code)
   :language: bash
   
Deep cell phenotyping
=============
*No more hunt-and-pecking! Detecting single-cell protein expression and cell phenotyping with TYPEx*


.. |workflow| image:: _files/images/typing4.png
        :height: 200
        :alt: TYPEx workflow

|workflow| 

Using multiplexed imaging, TYPEx detects protein expression on single cells, annotates cell types automatically based on user-provided definitions and quantifies cell densities per tissue area. It can be customised with input parameters and configuration files, allowing it to perform an end-to-end cell phenotyping analysis without the need for manual adjustments.

Usage
=============

1. Install `Nextflow <https://www.nextflow.io/docs/latest/getstarted.html#installation>`_
2. Install `Singularity <https://www.sylabs.io/guides/3.0/user-guide/>`_ or `Docker <https://docs.docker.com/engine/installation/>`_
3. Clone the `TYPEX <https://github.com/FrancisCrickInstitute/TYPEx>`_ or the `TRACERx-PHLEX <https://github.com/FrancisCrickInstitute/TRACERx-PHLEX>`_ repository:

    .. code-block:: bash

        git clone --recursive git@github.com:FrancisCrickInstitute/TRACERx-PHLEX.git
        
        git clone git@github.com:FrancisCrickInstitute/TYPEx.git

Running TYPEx on input generated with deep-imcyto
--------------

.. code-block:: bash

   nextflow run TRACERx-PHLEX/TYPEx/main.nf \
        -c $PWD/TRACERx-PHLEX/TYPEx/test.config \
        --input_dir $PWD/results/deep-imcyto/$release/ \
        --sample_file $PWD/TRACERx-PHLEX/TYPEx/data/sample_file.tracerx.txt \
        --release $release \
        --output_dir "$PWD/results/TYPEx/$release/" \
        --params_config "$PWD/TRACERx-PHLEX/TYPEx/data/typing_params.json" \
        --annotation_config "$PWD/TRACERx-PHLEX/TYPEx/data/cell_type_annotation.p1.json" \
        --tissue_seg_model "$PWD/TRACERx-PHLEX/TYPEx/models/tumour_stroma_classifier.ilp" \
	--color_config $PWD/TRACERx-PHLEX/TYPEx/data/celltype_colors.json \
        --deep_imcyto true --mccs true \
        -profile singularity \
        -resume

Running TYPEx with user-provided cell objects tables (indpendently of deep-imcyto)
--------------

.. code-block:: bash

   release=TYPEx_test
   nextflow run TYPEx/main.nf \
   -c $PWD/TYPEx/test.config \
    -c TYPEx/testdata.config \
    --input_dir $PWD/results/ \
    --release $release \
    --input_table $PWD/TYPEx/data/cell_objects.tracerx.txt \
    --sample_file $PWD/TYPEx/data/sample_file.tracerx.txt \
    --output_dir "$PWD/results/TYPEx/$release/" \
    --params_config "$PWD/TYPEx/data/typing_params.json" \
    --annotation_config "$PWD/TYPEx/data/cell_type_annotation.p1.json" \
    --color_config $PWD/TYPEx/data/celltype_colors.json \
    -profile singularity \
    -resume

Running TYPEx locally without high-perfomance computing server

.. code-block:: bash

	   release=TYPEx_test
	   nextflow run TYPEx/main.nf \
	   -c $PWD/TYPEx/conf/testdata.config \
	    -c TYPEx/testdata.config \
	    --input_dir $PWD/results/ \
	    --release $release \
	    --input_table $PWD/TYPEx/data/cell_objects.tracerx.txt \
	    --sample_file $PWD/TYPEx/data/sample_file.tracerx.txt \
	    --outDir "$PWD/results/TYPEx/$release/" \
	    --params_config "$PWD/TYPEx/data/typing_params.json" \
	    --annotation_config "$PWD/TYPEx/data/cell_type_annotation.json" \
		--color_config $PWD/TYPEx/data/celltype_colors.json \
	    -profile docker \
	    -resume

Input Files
==================

*Required Inputs*

- :bash:`cell_type_annotation.json` - a file with cell definitions specific to the user’s antibody panel (see :ref:`Cell type definitions`).
    Specified with :bash:`--annotationConfig` parameter.
- :bash:`sample_data.tracerx.txt`
    A tab-delimited file with information for all images (see :ref:`Sample annotation table`).
    Specified with :bash:`--sampleFile` parameter.
- :bash:`inDir` for deep-imcyto input or :bash:`inputTable` for runs independent of deep-imcyto
    Directory specified with :bash:`--inDir` parameter and input file specified with :bash:`--inputTable` parameter.
    :bash:`--inputTable` is tab-delimited file with marker intensities and cell coordiate per cell object (see :ref:`Input table`).

*Optional Inputs*

- :bash:`typing_params.json` - a config file with information on the cell typing workflow.
    A tab-delimited file with information for all images (see :ref:`Typing parameters config`).
    Specified with :bash:`--paramsConfig` parameter.
- :bash:`tissue_segmentation.json` - a file with information on tissue categories/annotation that can be overlaid to each cell object along with the cell type information.
   In  case of Tumour and Stroma tissue compartments, a summary table will also be generated with quantifications per compartment.
    Specified with :bash:`--overlayConfigFile` parameter.
- :bash:`celltype_colors.json` - color settings for the user-defined cell types.
    Specified with :bash:`--colorConfig` parameter.

Input Parameters
==================

:bash:`release` - provide a unique identifier for the run [default: PHLEX_test]
:bash:`panel` - provide a unique identifier for the panel [default: p1]
:bash:`study` - provide a unique identifier for the study [default: tracerx]

Several input paramters can be used to define the typing workflow:

- :bash:`deep-imcyto` run the TYPEx multi-tiered approach [default: true]
- :bash:`mccs` run TYPEx on deep-imcyto in MCCS mode when true and simple segmentation mode when false [default: true]

- :bash:`tiered` run the TYPEx multi-tiered approach  [default: true]
- :bash:`stratify_by_confidence` include the stratification by low and high confidence when true [default: true]
- :bash:`sampled` run TYPEx on subsampled data with three iterations when true [default: false]
- :bash:`clustered` perform clustering without any stratification [default: false]

The following parameters refer to the typing approach:

- :bash:`subtype_method` the clustering approach to be used in the last stratification step [default: FastPG]
- :bash:`major_markers` the label of the major cell type definitions in :bash:`cell_type_annotation.json` [default: major_markers]
- :bash:`subtype_markers` the label of the cell subtype definitions in :bash:`cell_type_annotation.json` [default: subtype_markers]
- :bash:`mostFreqCellType` the most frequent cell type in the cohort if known in :bash:`cell_type_annotation.json` [default: None]

    .. note:: The most frequent cell type is used to build the reference model by excluding this cell type. When it is not provided, the complete model wil be built, followed by the reference model. If provided, both will be executed in parallel. Parallel execution can make a difference in time, as these are the most time-consuming processes.

.. _Cell type definitions:

User-provided cell type definitions
-----------------------------
 
The cell-type definitions file :bash:`cell_type_annotation.json` includes a list of cell lineages and the corresponding marker proteins that together can be used to identify a cell lineage. When designing this file it is important to ensure that each cell in the cohort can be covered by these definitions. Some markers, such as CD45 and Vimentin, are expressed by multiple cell lineages. These shared proteins are used to infer a hierarchy of cell lineages, which is later considered for cell stratification and annotation. An example of a cell-type definitions file is shown below for TRACERx analyses, where we defined 13 major cell types targeted by our two antibody panels, while ensuring that each cell in the cohort can be covered by these definitions. 


.. _Input table:
Input table
-----------------------------

The input matrix has values that summarise the intensity of a protein per cell object, such as mean intensity, independently of the imaging modality or antibody tagging technique.

=============== =========== ===== ===== ============== ============ ============ ============
  ObjectNumber   imagename    X     Y     Area [opt].   <Marker 1>       ...      <Marker N>  
=============== =========== ===== ===== ============== ============ ============ ============

.. _Typing parameters config:
Typing parameters config
-----------------------------

:bash:`typing_params.json` contains the settings for clustering approaches to be used, normalisation approaches, and filtering criteria.

Key parameters that are often of interest are:
* magnitude 
As CellAssign was developed for single-cell sequencing read count data, the input protein intensity matrix should be rescaled to a range of 0 - 10^6 using the input parameter magnitude. 

* batch_effects
CellAssign also accounts for batch effects, which can be considered if provided in a sample-annotation table and specified as input parameters to TYPEx for batch correction.

.. _Sample annotation table:
Sample annotation table
-----------------------------
Provide the sample annotation table in the following format: 

============ ================== ======= ===================
  Image ID     Batch effect 1     ...     Batch effect N  
============ ================== ======= ===================

.. _Outputs:
Outputs
=============
TYPEx outputs summary tables that can be readily interrogated for biological questions. 
These include densities of identified cell phenotypes (cell_density_*.txt), a catalogue of the expressed proteins and combinations thereof (phenotypes.*.txt), quantified across the whole tissue area (summary_*.cell_stats.txt) or within each tissue compartment (categs_summary_*.cell_stats.txt).

.. code-block:: bash

        summary
        ├── cell_density_*.txt
        ├── cell_objects_*.txt
        ├── phenotypes.*.txt          
        ├── summary_*.cell_stats.txt
        ├── categs_summary_*.cell_stats.txt
       
Troubleshooting
=============

Several visualisation plots are output for each step in the workflow and can be used to make sure each step has gone as expected.
