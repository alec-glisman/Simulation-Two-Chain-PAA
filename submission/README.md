# Computational Job Submission Files

The [`submission`](./../submission) directory contains files that are used to submit jobs to a cluster or workstation.
These files are essentially wrappers on the pipeline [`run`](./../scripts/run) script.
The files gather previous data from the [`data`](./../data) directory, pipeline global variables from the [`parameters`](./../parameters) directory, and call the pipeline script.

Files in this directory can be added/deleted/modified as needed.
Slurm output logs are placed in the [`logs`](./logs) directory.
The log files are often large and commonly deleted, so they are ignored by git.
