# Gromacs Force Fields

The [`force-field`](.//force-field) directory contains files that are used to build Gromacs topologies and parameterize molecules.

The synthetic polymer force field is based on parameters from
[Mintis and Mavrantzas (2019)](https://doi.org/10.1021/acs.jpcb.9b01696), which used the General Amber Force Field (GAFF).
We have converted the tables of parameters into a force field named [`gaff.ff`](./gaff.ff) that can be used with Gromacs.

Small ion parameters, such as sodium, calcium, and chlorine, are taken from the Jungwirth group's ECCR model fittings.
Sodium ion parameters are found in:
> Kohagen, Miriam, Philip E. Mason, and Pavel Jungwirth. "Accounting for electronic polarization effects in aqueous sodium chloride via molecular dynamics aided by neutron scattering." The Journal of Physical Chemistry B 120.8 (2016): 1454-1460.

Calcium and chlorine ion parameters are found in:
> Martinek, Tomas, et al. "Calcium ions in aqueous solutions: Accurate force field description aided by ab initio molecular dynamics and neutron scattering." The Journal of chemical physics 148.22 (2018): 222813

Water is modeled using SPC/E, as it offers a good balance of physical performance and computational accuracy.
Future work may investigate polarizable water models.

Force field parameter generation is handled by the [`parameter-generation`](./parameter-generation) directory.
