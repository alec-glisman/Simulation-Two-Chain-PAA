#!/usr/bin/env bash
# Created by Alec Glisman (GitHub: @alec-glisman) on January 25th, 2023

#SBATCH --job-name=Eqbm
#SBATCH --time=2-00:00:00

# Slurm: Node configuration
#SBATCH --partition=all --qos=d --account=d
#SBATCH --nodes=1 --ntasks-per-node=32 --mem=8G
#SBATCH --gres=gpu:2 --gpu-bind=closest

# Slurm: Runtime I/O
#SBATCH --output=logs/jobid_%j-node_%N-%x.log --error=logs/jobid_%j-node_%N-%x.log

# built-in shell options
set -o errexit # exit when a command fails
set -o nounset # exit when script tries to use undeclared variables

# signal catching
failure_handler() {
    echo "Caught SIGCONT SIGTERM SIGINT on sbatch submission script"
    date_time=$(date +"%Y-%m-%d %T")
    echo "FAILED: ${date_time}"
}
trap 'failure_handler' SIGCONT SIGTERM SIGINT

# simulation path variables
scripts_dir="$(pwd)/../scripts"
params_dir="$(pwd)/../submission/input"
data_dir="$(pwd)/../data"

input_globals=(
    '2PAcr_16mer_0Ca_12nmbox.sh'
    '2PAcr_16mer_8Ca_12nmbox.sh'
    '2PAcr_16mer_16Ca_12nmbox.sh'
    '2PAcr_16mer_32Ca_12nmbox.sh'
    '2PAcr_16mer_64Ca_12nmbox.sh'
    '2PAcr_16mer_128Ca_12nmbox.sh'
)
input_dirs=(
    # TODO: add input directories
)

# start script
date_time=$(date +"%Y-%m-%d %T")
echo "START: ${date_time}"

# if input_dirs has a length greater than 0, then run simulations with given input data
if [ ${#input_dirs[@]} -gt 0 ]; then
    echo "Running simulations with given input data..."

    # verify that input_dirs and input_globals have the same length
    if [ ${#input_dirs[@]} -ne ${#input_globals[@]} ]; then
        echo "ERROR: input_dirs and input_globals have different lengths. Exiting..."
        exit 1
    fi

    parallel --link --keep-order --ungroup --delay '2' --halt-on-error '2' \
        "${scripts_dir}/run" \
        --global-var "${params_dir}/{1}" \
        --input-files "${data_dir}/{2}" \
        --metadynamics --equilibration \
        ::: "${input_globals[@]}" ::: "${input_dirs[@]}"

else
    echo "ERROR: No input data given. Exiting..."
    exit 1
fi

# end script
date_time=$(date +"%Y-%m-%d %T")
echo "END: ${date_time}"
