#!/usr/bin/env bash
# Created by Alec Glisman (GitHub: @alec-glisman) on July 19th, 2022

###############################################################################
# Simulation components: Only affects system preparation                      #
###############################################################################

# polyelectrolytes
export POLY_LEN='16' # OPTIONS: {3, 8, 16, 32, 64} number of monomers
export N_CHAINS='2'  # OPTIONS: {1, 2} number of identical polymer chains
export MONOMER='Acr' # Dominant monomer OPTIONS: {'Acr' acrylate ionized, 'Acn' acrylate neutral}

# two-chain system parameters
export INITIAL_Z_SPACING_NM='1.5' # initial spacing between chains along z-axis
INITIAL_Z_SPACING_ANG=$(echo "${INITIAL_Z_SPACING_NM}"*10 | bc)
export INITIAL_Z_SPACING_ANG

# ions
export N_NA_ION='32' # [# Na^{+}] including counterions
export N_CA_ION='16' # [# Ca^{2+}]
export N_CL_ION='32' # [# Cl^{-}]

# solvent
export WATER_MODEL="spce"

# simulation parameters
export BOX_SIZE='12.0'      # [nm], continuous variable, PAA 32mer has 8.45 nm box_size
export BOX_GEOMETRY='cubic' # OPTIONS: {'cubic', 'triclinic', 'dodecahedron'}
# NOTE: Plumed plugin can only do PBC with orthorhombic boxes

###############################################################################
# Simulation sampling: Only affects production                                #
###############################################################################

# statistical mechanics
export PRODUCTION_ENSEMBLE='nvt' # OPTIONS: {'nvt' NVT, 'npt' NPT}, must be lowercase input
export TEMPERATURE_K='300'       # [K], system thermostat temperature

# hamiltonian replica exchange
export HREMD_N_REPLICA='16'           # number of replicas
export HREMD_N_STEPS_EXCH='500'       # [steps] between coordinate exchange attempts
export HREMD_T_MIN="${TEMPERATURE_K}" # [K] max effective temperature in replicas
export HREMD_T_MAX='440'              # [K] max effective temperature in replicas

# metadynamics
export CV_RG='0'                  # OPTIONS: {0, 1} whether to use radius of gyration as collective variable
export METAD_BIASFACTOR='10'      # bias factor for C.V. effective temperature
export METAD_HEIGHT='1.2'         # [kJ/mol] initial height of Gaussians (kT = 2.48 kJ/mol at 298 K)
export METAD_SIGMA='0.025'        # width of Gaussians, set to 0.33–0.5 of estimated fluctuation
export METAD_GRID_SPACING='0.005' # width of bins in the meta-dynamics grid
export METAD_GRID_MIN='0'         # minimum grid point for Gaussian deposition
export METAD_GRID_MAX='10'        # maximum grid point for Gaussian deposition
export METAD_PACE='500'           # [steps] between deposition of Gaussians

# harmonic walls
export WALL_MIN='0'           # [nm] the lower wall position
export WALL_MAX='6'           # [nm] the upper wall position
export WALL_FORCE_CONST='600' # [kJ/mol/nm] the force constant for the walls

###############################################################################
# Simulation sampling: Periodic boundary conditions                           #
###############################################################################

# atom numbers of pull groups to evaluate periodic boundary conditions with respect to
export PBC_ATOM_CHAIN_A='0'
export PBC_ATOM_CHAIN_B='0'

###############################################################################
# Simulation hardware                                                         #
###############################################################################

# hardware input parameters
export CPU_THREADS='-1' # number of CPU threads for simulation, -1 denotes all available
export PIN_OFFSET='-1'  # offset for CPU thread pinning, -1 denotes no offset
export GPU_IDS='-1'     # GPU IDs for simulation, -1 denotes all available

# software executables
MPI_EXE="$(which mpiexec)"
GMX_MPI_EXE="$(which gmx_mpi)"
GMX_EXE="$(which gmx)" || echo "WARNING: gmx not found, using gmx_mpi instead"
if [[ -z "${GMX_EXE}" ]]; then
    GMX_EXE="${GMX_MPI_EXE}"
fi
PLUMED_MPI_EXE="$(which plumed)"
PYTHON_BIN="$(which python)"

# path to repository base directory
file_path="${BASH_SOURCE[0]}"
second_parent_dir="$(readlink -f "$(dirname "$(dirname "$(dirname "${file_path}")")")")"
export REPO_BASE_DIR="${second_parent_dir}"

# export executables
export GMX_EXE
export MPI_EXE
export GMX_MPI_EXE
export PLUMED_MPI_EXE
export PYTHON_BIN
export REPO_BASE_DIR

# report path to executables
echo "DEBUG: MPI_EXE: ${MPI_EXE}"
echo "DEBUG: GMX_MPI_EXE: ${GMX_MPI_EXE}"
echo "DEBUG: GMX_EXE: ${GMX_EXE}"
echo "DEBUG: PLUMED_MPI_EXE: ${PLUMED_MPI_EXE}"
echo "DEBUG: PYTHON_BIN: ${PYTHON_BIN}"
echo "DEBUG: REPO_BASE_DIR: ${REPO_BASE_DIR}"

# slurm defaults supersedes hardware input parameters
if [[ -n "${SLURM_NTASKS+x}" ]] && [[ "${CPU_THREADS}" == "-1" ]]; then
    export CPU_THREADS="${SLURM_NTASKS}"
fi
if [[ -n ${SLURM_GPUS+x} ]]; then
    if [[ "${SLURM_GPUS}" == "1" ]] && [[ "${GPU_IDS}" == "-1" ]]; then
        export GPU_IDS="${SLURM_GPUS}"
    fi
fi

# define number of computational nodes
# shellcheck disable=SC2236
if [[ ! -n "${SLURM_JOB_NUM_NODES+x}" ]]; then
    export SLURM_JOB_NUM_NODES='1'
fi

# Hamiltonian replica exchange
n_threads_per_node="$(grep -c ^processor /proc/cpuinfo)"
export HREMD_N_SIM_PER_NODE=$(((HREMD_N_REPLICA + SLURM_JOB_NUM_NODES - 1) / SLURM_JOB_NUM_NODES)) # number of replicas run per node (ceil division)
export HREMD_N_THREAD_PER_SIM=$((n_threads_per_node / HREMD_N_SIM_PER_NODE))                       # number of CPU threads per replica (floor division)

###############################################################################
# Force field                                                                 #
###############################################################################

# force field parent directory
export FORCE_FIELD_NAME='gaff'
export FORCE_FIELD_DIR="${REPO_BASE_DIR}/force-field/${FORCE_FIELD_NAME}.ff"

###############################################################################
# Simulation identifiers                                                      #
###############################################################################

# repository base directory
export PARAMETERS_DIR="${REPO_BASE_DIR}/parameters/mdp"

# Unique polyelectrolyte tag
tacticity="atactic"
terminus_group="Hend"
monomer_tags="${tacticity}-${terminus_group}"
CHAIN_TAG="P${MONOMER}-${N_CHAINS}chain-${POLY_LEN}mer-${tacticity}-${terminus_group}"

# Unique simulation tag
TAG="${CHAIN_TAG}-${N_CA_ION}Ca-${N_NA_ION}Na-${N_CL_ION}Cl-${BOX_SIZE}nmbox-$(hostname -s)-$(date +"%F-%T.%N")"
if [[ -n "${SLURM_JOB_ID+x}" ]]; then
    TAG="sjobid_${SLURM_JOB_ID}-${TAG}"
else
    TAG="sjobid_0-${TAG}"
fi

export TAG

###############################################################################
# Initial structures: Only affects system preparation                         #
###############################################################################

# filename of initial pdb file without extension
pdb_file_tags="P${MONOMER}-${POLY_LEN}mer-${monomer_tags}"

# subdirectory of pdb files
PDB_INPUT_DIR="${REPO_BASE_DIR}/initial-structure" # path to .pdb input directory

# full path to pdb file
export PDB_FILE="${PDB_INPUT_DIR}/${pdb_file_tags}.pdb"
