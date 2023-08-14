# Simulation Software

The [`software`](./../software) directory contains the source code for various simulation software packages.
We currently use gromacs 2022.3 patched with plumed 2.8.1.
Packmol 20.3.5 is used to generate initial configurations from `.pdb` files and Alan Grossfield's WHAM 2.0.11 is used to compare the WHAM outputs from the different software packages.

More information on the specific environment used for the simulations can be found in the [`requirements`](./requirements) directory.
Python virtual environment files are provided in both `pip` and `conda` formats.
Spack environment files are also provided for users who wish to use Spack to install the software packages using `spack install` inside the [`spack`](./requirements//spack) directory.
