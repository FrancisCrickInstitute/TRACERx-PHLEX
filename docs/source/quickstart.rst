
.. |zenlink| image:: https://zenodo.org/badge/DOI/10.5281/zenodo.7665181.svg
.. _zenlink: https://doi.org/10.5281/zenodo.7665181

Quick start
+++++++++++++++
#. Ensure `Nextflow <https://www.nextflow.io/docs/latest/getstarted.html#installation>`_ and either `Singularity <https://www.sylabs.io/guides/3.0/user-guide/>`_ or `Docker <https://docs.docker.com/engine/installation/>`_ are installed on your system.
#. Create a suitable working directory for the PHLEX analysis.

   .. code-block:: console

      $ mkdir PHLEX_testing
      $ cd PHLEX_testing

#. Clone the `TRACERx-PHLEX repository <https://github.com/FrancisCrickInstitute/TRACERx-PHLEX>`_ from github:

   .. code-block:: console

      $ git clone --recursive git@github.com:FrancisCrickInstitute/TRACERx-PHLEX.git

#. Run the TRACERx-PHLEX setup pipeline to download the required weights, test images and shell script to launch TRACERx-PHLEX:

   .. code-block:: console

      $ nextflow run TRACERx-PHLEX/PHLEX_setup.nf -w scratch


   .. tip:: The directory structure should now look like this:

      .. code-block:: bash

         PHLEX_testing/
         ├── TRACERx-PHLEX
         │   ├── deep-imcyto
         │   ├── docs
         │   ├── LICENSE
         │   ├── README.rst
         │   ├── Spatial-PHLEX
         │   └── TYPEx
         ├── deep-imcyto_weights
         │   ├── AE_weights.hdf5
         │   ├── boundaries.hdf5
         │   ├── com.hdf5
         │   ├── nuclear_morph_scaler.pkl
         │   └── nucleus_edge_weighted.hdf5
         ├── PHLEX_test_images
         │   ├── P1_TMA002_L_201906190-roi_16.ome.tiff
         │   ├── P1_TMA005_R_20190619-roi_4.ome.tiff
         │   ├── P1_TMA006_L_20190619-roi_24.ome.tiff
         │   ├── P1_TMA006_L_20190619-roi_6.ome.tiff
         │   └── P1_TMA007_L_20190619-roi_12.ome.tiff
         └── runPHLEX.sh

#. Launch TRACERx-PHLEX by calling the ``runPHLEX.sh`` script from the command line:

   .. code-block:: console

      $ ./runPHLEX.sh

#.  TRACERx-PHLEX will then begin.

.. note:: 

   The first time PHLEX is run, Nextflow will download all the necessary Docker images that are required to run PHLEX. This may take a while and it may appear as if a particular process is hanging whilst the containers are built. Subsequent runs will be much faster. Download of these image files and execution of local Nextflow processes will require sufficient memory. Error messages will flag insufficient memory.


Tutorial
+++++++++++++++
Detailed description on parameters, input files and functionalities is described for each module

:doc:`PHLEX: deep-imcyto<deep-imcyto>`
=======================================

   A module devoted to performing accurate nuclear and cellular segmentation and single cell measurement in multiplex images.

:ref:`PHLEX: TYPEx<TYPEx_anchor>`
=======================================

   A module for cellular phenotyping from marker expression intensities derived from multiplex images.

:ref:`Spatial-PHLEX<Spatial-PHLEX>`
=======================================

   A module for performing several types of automated spatial analysis.

Data Repository
+++++++++++++++
The imaging mass cytometry datasets associated with Enfield et al., Cancer Discovery, 2024 and Magness et al., Nature Communications, 2024, are available for access requests under
https://zenodo.org/records/12587543

Download a step-by-step guide
+++++++++++++++
:download:`Download <docs/source/_files/ReadTheDocs_Tutorial.pdf>`

Contact
+++++++++++++++
mihaela.angelova@crick.ac.uk
alastair.magness@crick.ac.uk
emma.coliver@crick.ac.uk
katey.enfield@crick.ac.uk


