# Python (helper) files

The [`python`](./../python) directory contains Python files that aid in the simulation pipeline.
These are called by the [`scripts`](./../scripts).

- [`mean_frame_xvg_2_col.py`](./mean_frame_xvg_2_col.py): A script to calculate the mean of a subset of frames from a 2 column `.xvg` file. This is used to calculate the average density from an NPT simulation and pick a frame that is closest to the average density for future NVT simulations.
- [`probability_exchange.py`](./probability_exchange.py): A script to calculate the probability of exchange between HREMD replicas from the `.log` files of the simulations.
