#!/usr/bin/env bash
# Created by Alec Glisman (GitHub: @alec-glisman) on January 25th, 2023

#SBATCH --job-name=SysPrep
#SBATCH --time=1-00:00:00

# Slurm: Node configuration
#SBATCH --partition=all --qos=d --account=d
#SBATCH --nodes=1 --ntasks-per-node=16 --mem=4G
#SBATCH --gres=gpu:1 --gpu-bind=closest

# Slurm: Runtime I/O
#SBATCH --output=logs/jobid_%j-node_%N-%x.log --error=logs/jobid_%j-node_%N-%x.log

# built-in shell options
set -o errexit # exit when a command fails
set -o nounset # exit when script tries to use undeclared variables

# simulation path variables
proj_base_dir="$(pwd)/.."
scripts_dir="${proj_base_dir}/scripts"
params_dir="${proj_base_dir}/submission/input"
input_globals=(
    '2PAcr_16mer_0Ca_12nmbox.sh'
    '2PAcr_16mer_8Ca_12nmbox.sh'
    '2PAcr_16mer_16Ca_12nmbox.sh'
    '2PAcr_16mer_32Ca_12nmbox.sh'
    '2PAcr_16mer_64Ca_12nmbox.sh'
    '2PAcr_16mer_128Ca_12nmbox.sh'
)

# start script
date_time=$(date +"%Y-%m-%d %T")
echo "START: ${date_time}"

parallel --keep-order --halt-on-error '2' --jobs '1' --delay '1' \
    "${scripts_dir}/run" \
    --global-var "${params_dir}/{1}" \
    --metadynamics --system-preparation \
    ::: "${input_globals[@]}"

# end script
date_time=$(date +"%Y-%m-%d %T")
echo "END: ${date_time}"
