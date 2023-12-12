# Simulation Parameters

[`mdp`](./mdp) contains the molecular dynamics parameters (MDP) for Gromacs.
File specifications are described in the [Gromacs manual](https://manual.gromacs.org/documentation/current/user-guide/mdp-options.html).
The file names are important, as they are used by the [`scripts`](./../scripts) to call `gmx grompp` on the `mdp` files to generate the input `tpr` files for the simulations.
The files are placed in subdirectories according to the type of simulation they are used for.

[`packmol`](./packmol) contains the input files for the [Packmol](http://leandro.iqm.unicamp.br/m3g/packmol/home.shtml) program.
The `inp` files are used to generate the initial configurations for the simulations from `pdb` files found in the [`initial-structure`](./../initial-structure) directory.
Packmol documentation contains a broad variety of [example inputs](http://leandro.iqm.unicamp.br/m3g/packmol/examples.shtml).

[`plumed-mdrun`](./plumed-mdrun) contains the input files for the [Plumed](https://www.plumed.org/) patch inside `gmx mdrun`.
These files should be called during a simulation with the `-plumed` flag.
We currently have template input files for HREMD and metadynamics simulations.
