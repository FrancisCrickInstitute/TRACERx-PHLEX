.. _guides:

Download a detailed step-by-step guide
+++++++++++++++
:download:`Download <_files/ReadTheDocs_Tutorial.pdf>`

Data Repository
+++++++++++++++
The imaging mass cytometry datasets associated with Enfield et al., Cancer Discovery, 2024 and Magness et al., Nature Communications, 2024, are available for access requests under
https://zenodo.org/records/12587543

Multiplexed consensus cell segmentation (MCCS)
+++++++++++++++

.. |consensus| figure:: _files/images/consensus.png
        :width: 800
        :alt: Principles of multiplexed consensus cell segmentation.

        Overview of the principles of multiplexed consensus cell segmentation.

Multiplexed consensus cell segmentation (MCCS) is a hybrid cell segmentation method for multiplexed imaging data developed in the Swanton lab. MCCS combines the deep learning-based nuclear predictions of the core deep-imcyto model with classical propagation-based segmentation techniques to overcome many of the limitations of simpler segmentation approaches (See [LINK TO PAPER]).

MCCS harnesses the multiplexed nature of IMC data to improve whole cell segmentation across cell types in complex tissues, including where different cell types may be crowded together. In MCCS mode, individual cell segmentation masks are generated for each of a set of user-defined cell lineage markers and then combined to yield a high confidence total cell mask. MCCS can be tailored to additionally identify cell populations which lack nuclei in the imaged plane, such as fibroblasts, improving on methods relying on a 1:1 nucleus:cell correspondence.

In the deep-imcyto Nextflow framework, MCCS procedures are implemented using user-configured CellProfiler pipeline files. MCCS outputs include single cell expression and morphometric data and - optionally - cell neighbourhood data. See Developing a multiplexed consensus cell segmentation pipeline for more information on how to develop an MCCS pipeline for your own IMC panel.

.. |consensus| figure:: _files/images/MCCS_rationale.png
        :width: 800
        :alt: Examples of the benefits of MCCS over segmentation methods based on pixel dilation and a 1:1 nucleus:cell correspondence.

        Examples of the benefits of MCCS over segmentation methods based on pixel dilation and a 1:1 nucleus:cell correspondence.

Developing a multiplexed consensus cell segmentation pipeline
--------------------------------------------------------------
This section describes the necessary steps to design and implement an MCCS cell segmentation procedure for deep-imcyto. 

A more detailed description of the rationale for designing an MCCS procedure and examples of superior performance compared to simpler cell segmentation approaches can be found in `[insert manuscript reference]<>`_.

The required inputs for MCCS are: 

* A full_stack of ``.tiff`` images - all channel images, with no preprocessing yet applied (generated by the IMCTools process in deep-imcyto).
* An mccs_stack of ``.tiff`` images - a subset of the above images, defined by the user as segmentation marker images (see below).
* Nuclear segmentation ``.tiff`` images generated by the nuclear segmentation process in deep_imcyto.
* Three user-configured CellProfiler ``.cppipe`` files at the filepaths specified by ``--full_stack_cppipe``, ``--mccs_stack_cppipe``, and ``--segmentation_cppipe`` (see below). Examples are available in the ``assets/cppipes`` directory of the deep-imcyto repository.
* Optional: A spillover compensation ``.tiff`` file (see :ref:`Workflow-dependent inputs`).
* Optional: Additional CellProfiler plugin files not shipped with CellProfiler v3.1.X (see below).

Outputs for MCCS are user-defined in the :bash:`--segmentation_cppipe` pipeline file, but should minimally include:
* A ``.csv`` file containing single cell level expression and/or morphometric data, in the example MCCS implementation distributed with deep-imcyto named ``cells.csv``.
* A ``.tiff`` file - The total cell mask generated by MCCS.
* Optional: ``.csv`` file containing cell neighbourhood information.

Software requirements for MCCS in deep-imcyto
---------------------------------------------
`CellProfiler <https://cellprofiler.org/>`_ is a free open-source software for measuring and analyzing cell images. To execute MCCS mode in deep-imcyto, a user is required to provide three user-configured CellProfiler ``.cppipe`` files at the filepaths specified by ``--full_stack_cppipe``, ``--mccs_stack_cppipe``, and ``--segmentation_cppipe``. 



The Docker/Singularity container which deep-imcyto uses to run MCCS runs CellProfiler v3.1.9. Accordingly, user-developed MCCS procedures should be developed using CellProfiler v3.1.9 in order to be compatible with deep-imcyto out-of-the-box. Additional CellProfiler plugin files which users may find useful for building a CellProfiler MCCS procedure are bundled within the deep-imcyto repository which, if included in any of the three cppipe files, should be specified in deep-imcyto using the ``--plugins`` flag.

Once configured, deep-imcyto will automatically execute the MCCS procedure using CellProfiler.

.. note::

    While we developed an MCCS procedure in CellProfiler (v3.1.9), in principle, the MCCS approach can be executed (outside of deep-imcyto) in any appropriate software which permits thresholding and propagation-based object identification on images, and for any multiplexed imaging technology, including IF-based approaches. To perform MCCS for any multiplexed imaging experiment, a template CellProfiler pipeline is distributed as part of PHLEX, which can be adapted to a user's own antibody panel and provides a conceptual template for other software implementations.

.. tip:: 

    To run an MCCS procedure developed in CellProfiler 4.x.x. the user needs to alter the deep-imcyto config to specify a different CellProfiler container which may be downloaded and built by Nextflow.

    .. code-block:: bash
        :emphasize-lines: 2

        withLabel:'MCCS' {
            container = 'cellprofiler/cellprofiler:3.1.9' // Change this to the CellProfiler container of your choice
            withName:'PREPROCESS_MCCS_STACK|PREPROCESS_FULL_STACK' {
                //process low
                cpus = { check_max( 2 * task.attempt, 'cpus' ) }
                memory = { check_max( 14.GB * task.attempt, 'memory' ) }
                time = { check_max( 0.5.h * task.attempt, 'time' ) }
            }
            withName:'CONSENSUS_CELL_SEGMENTATION_MCCS_PP|CONSENSUS_CELL_SEGMENTATION|CELL_SEGMENTATION' {
                //process medium
                cpus = { check_max( 6 * task.attempt, 'cpus' ) }
                memory = { check_max( 42.GB * task.attempt, 'memory' ) }
                time = { check_max( 8.h * task.attempt, 'time' ) }
        }




MCCS Procedure Design in CellProfiler
-------------------------------------
A simplified overview of the key steps to implement in an MCCS procedure is included below. Steps are grouped by the input cppipe file and relevant CellProfiler modules suggested.

full_stack_cppipe
^^^^^^^^^^^^^^^^^^
.. note:: 

    We use the term *full stack* to refer to all channel images in an IMC experiment, including those which are not used for segmentation.


In this step, minimal preprocessing is applied to all channel images output in the ``imctools/full_stack/`` folder. 

Inputs:
'''''''
imctools/full_stack/ tiff files should be named as inputs in the full_stack_cppipe pipeline file (**CP module: NamesAndGroups**), as should the spillover compensation tiff if spillover compensation is being applied. 

Full stack preprocessing
''''''''''''''''''''''''
If spillover compensation is being applied, this should be applied first, specifically to an ordered stack of the channels which need to be compensated (**CP modules: GrayToColor, CorrectSpilloverApply**). We then suggest hot pixel removal in IMC images (all channels, including those not spillover-compensated) (**CP module: SmoothMultiChannel**) before rescaling all channels to between 0 and 1 - required by CellProfiler - by division by a large number which exceeds the maximum pixel intensity across any IMC channel in all images (e.g. 100000) (**CP module: RescaleIntensity**) and saving of images in 32-bit format (**CP module: SaveImages**). 


mccs_stack_cppipe
^^^^^^^^^^^^^^^^^^

In this step, preprocessing is applied to only a subset of the full_stack images output by the IMCTools step, specifically those channels chosen as segmentation markers.

Segmentation marker selection
'''''''''''''''''''''''''''''

A set of cytoplasmic or membrane markers must be selected to capture as many cell lineages as possible in images. This should be adapted for different antibody panels and be chosen to allow for identification of different cell subsets at the segmentation stage, e.g. selecting all of CD8, CD4, and CD3 to identify distinct T cell populations. Markers with high signal-to-noise ratio with low prevalence of artefacts across the imaged cohort should be prioritised.

Inputs: 
'''''''

All imctools/full_stack/ tiff files which are subject to spillover compensation should be named as inputs in the mccs_stack_cppipe pipeline file (CP module: NamesAndGroups), as should the spillover compensation tiff if spillover compensation is being applied. 

Segmentation marker channel preprocessing
''''''''''''''''''''''''''''''''''''''''

Minimal preprocessing is first applied to all markers channels, including spillover compensation (**CP modules: GrayToColor, CorrectSpilloverApply**) and hot pixel removal (**CP module: SmoothMultiChannel**) as already described. Following this, only the subset of segmentation markers is carried forward to subsequent steps (**CP module: ColorToGray**). Median filtering is applied to these segmentation marker channels (**CP module: MedianFilter**) to smooth noise to support the subsequent intensity propagation-based segmentation approach in the segmentation_cppipe. Images are then scaled across the intensity range (**CP module: RescaleIntensity**) and saved in 32 bit tiff format (**CP module: SaveImages**). We suggest naming output files in the form ``preprocessed_X.tiff ``where X is the segmentation marker of interest.

segmentation_cppipe
^^^^^^^^^^^^^^^^^^
In this step, preprocessed segmentation markers are combined with the nuclear objects output from the nuclear_segmentation process in deep_imcyto to generate a total cell mask using the hybrid MCCS approach. Single-cell level metrics are then measured and produced as output alongside a total cell mask image.

Inputs: 
''''''''''

channel_preprocess/full_stack/ tiff files and channel_preprocess/mccs_stack/ tiff files should be named as inputs in the segmentation_cppipe pipeline file (**CP module: NamesAndGroups**), as should the nuclear_mask image file generated by nuclear_segmentation. 

Creation of a cell mask for each individual segmentation marker:
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

The following steps are then applied to each preprocessed segmentation marker image in turn (i.e. independently of one another). First, global Otsu thresholding is applied to identify areas of cell foreground based on that single segmentation marker (**CP module: Threshold**). Thresholding parameters are set on a marker-by-marker basis by visual inspection across a range of representative images, which can be facilitated by CellProfiler Test mode. Next, the extent of overlap of thresholded cell foreground with the nuclear objects predicted by deep-imcyto is quantified (**CP module: MeasureObjectOverlap**). Specifically, nuclei for which cell foreground overlaps with at least 50% of the edge pixels of the nucleus are retained and carried forward to be used as seeds for propagation-based cell segmentation (**CP module: MaskObjects**). By requiring sufficient overlap between nuclei and cell foreground, nuclei at the edge of neighbouring cells are not inadvertently propagated out on into a neighbouring cell. This can be particularly important when dealing with cells with nuclei which are not centred in cell bodies. Retained nuclei are then used as seeds for propagation onto the relevant minimally preprocessed segmentation marker image to yield a single cell segmentation mask for that individual cell segmentation marker (**CP module: IdentifySecondaryObjects**). An individual cell in a segmentation mask can only overlap a single nucleus. 

.. note:: 
    
    The comprehensive set of CP modules required to undertake these steps can be found in the template segmentation.cppipe CellProfiler pipeline file provided with this release.

Consensus Cell Mask generation
''''''''''''''''''''''''''''''

Next, having repeated the above series of steps for each segmentation marker independently, the set of single segmentation marker cell masks is combined. First, nuclei not retained as seeds in any cell segmentation mask are dilated on by +1 pixel expansion to reflect the expected larger area of a cell than its contained nucleus for cells for which no appropriate cell segmentation marker is available (**CP module: DilateObjects**). Then, a series of serial maskings are performed such that for each nuclear object, only the intersection of different cell segmentation masks derived from that nuclear object are retained in the final cell object attributed to that nucleus (**CP module: MaskObjects**). At the same time, areas of overlap between cell objects derived from different nuclei are removed. These steps respectively ensure that only the pixels most confidently attributed to the same cell are retained in the same single cell object, and that individual pixels which could derive from different cells at cell boundaries are removed from analysis to avoid inadvertently assigning a cell membrane marker to the wrong one of two tightly packed neighbouring cells. This whole step yields a total nucleated cells segmentation mask. 

Optional step: Addition of non-nucleated stromal cell populations
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Finally, an additional primary object identification step can be applied directly to any single channel observed to stain cells which lack coincident nuclei in the imaging plane (**CP module: IdentifyPrimaryObjects**). For example, in the companion TRACERx study, ɑSMA+ cells were frequently observed without an in-plane nucleus. Global Otsu thresholding and cell size parameters are adjusted to identify these additional ‘non-nucleated’ cell populations, and then identified objects combined with the total nucleated cell segmentation mask, removing areas of overlap (including removal of non-nucleated objects with >33% overlap with the nucleated cell mask) (**CP module: MaskObjects**). Finally, minimum (4 pixels) and maximum (1000 pixels) cell area filters are applied to yield a final total cell segmentation mask (**CP module: FilterObjects**). 

Extraction of single cell-level metrics
'''''''''''''''''''''''''''''''''''''''

This final total cell segmentation mask is then used to delineate the boundaries of individual cells and extract single cell-level expression data and morphometric features (**CP modules: MeasureIntensityMultichannel, MeasureObjectSizeShape**). The single cell expression data measured can be fed into TYPEx for identification of cellular phenotypes and cell marker positivity status. If desired, additional (CellProfiler) modules can also be implemented on the final total cell mask to derive information about cell-cell neighbour relationships (**CP module: MeasureObjectNeighbor**).
