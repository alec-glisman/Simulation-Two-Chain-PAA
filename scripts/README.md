# Simulation pipeline scripts

The [`scripts`](./../scripts) directory contains Bash scripts used to run simulations and analyze data output using Packmol, Gromacs, and Plumed command line interface tools.

The main simulation pipeline is generated using the [`run`](./run) script.
New users should start by running the [`run`](./run) script with the `-h` flag to see the available options.
For further information, please read through the comments in that script.

We will briefly describe the main simulation pipeline scripts below.

## [`gromacs-helpers`](./gromacs-helpers)

This directory contains Bash scripts that are used to set up and run Gromacs simulations.
They form general-purpose wrapper scripts for Gromacs command line tools and are used by the main simulation pipeline scripts.
Scripts can be used independently of the main simulation pipeline scripts, but do require many environment variables to be set.

- [`gmx_analysis`](./gromacs-helpers/gmx_analysis): Bash script for analyzing Gromacs simulation output.
Thermodynamic, mechanical, and structural properties are calculated using Gromacs tools and generate `.xvg` files.
The `.xvg` files are converted to `.png` files using `xmgrace` tools.
Water is removed from the system trajectory and coordinates are unwrapped about the polyelectrolyte chains.
Finally, all created files are moved into a `analysis` directory.
- [`gmx_mdrun`](./gromacs-helpers/gmx_mdrun): Bash script for running Gromacs `mdrun`.
The script merely specifies the Gromacs command line options, prepares an input `.tpr` file with `grompp`, and runs the simulation using `gmx mdrun`.
- [`gmx_mdrun_pipeline`](./gromacs-helpers/gmx_mdrun_pipeline): Bash script for running a pipeline for an individual `mdrun` command.
The script copies input files to a new directory, runs `gmx_mdrun`, analyzes output with `gmx_analysis`, and organizes output files.
This is the main script used by the main simulation pipeline scripts.
- [`gmx_pdb_import`](./gromacs-helpers/gmx_pdb_import): Bash script for importing a `.pdb` file into a Gromacs simulation using `pdb2gmx`.
The structure is added into an empty simulation box, an index file is generated, and the structure is energy minimized in the absence of electrostatic interactions.
This script is called by [`system_preparation`](./../md-setup/system_preparation) to prepare the initial structure for a simulation.
- [`gmx_sol_ion`](./gromacs-helpers/gmx_sol_ion): Bash script for adding water and ions to a Gromacs simulation using `genion`.
This script is called by [`system_preparation`](./../md-setup/system_preparation) to solvate the polyelectrolyte structure and add ions to a desired ionic strength.

## [`md-setup`](./md-setup)

This directory contains Bash scripts that are used to set up Gromacs simulations.
System initialization and equilibration are performed using the scripts in this directory.
These scripts are called first in the main simulation pipeline script, [`run`](./run).

- [`system_preparation`](./md-setup/system_preparation): Bash script for preparing a Gromacs simulation from atom `.pdb` files and Gromacs format force-field directories.
After system preparation, the system is energy minimized before moving to equilibration `mdrun` commands.
- [`equilibration`](./md-setup/equilibration): Bash script for performing equilibration of a Gromacs simulation.

## [`md-production`](./md-production)

This directory contains Bash scripts that are used to run Gromacs production simulations.
The scripts take as input a Gromacs simulation prepared by the scripts in the [`md-setup`](./md-setup) directory.
The scripts in this directory sometimes perform basic analysis of the simulation output, but full data analysis and visualization is performed in a separate repository.
Each script is named for the type of simulation it performs and further information is provided in the comments of each script.

## [`rsync`](./rsync)

This directory contains Bash scripts that are used to synchronize data between various computational devices.
The files can be frequently changed and are not called by the main [`run`](./run) script and should be called directly by the user.

## [`slurm`](./slurm)

This directory contains Bash scripts that are used to submit jobs to the SLURM job scheduler.
They are called by production scripts that need to submit successive jobs to SLURM.
