#!/usr/bin/env bash
# Created by Alec Glisman (GitHub: @alec-glisman) on July 19th, 2022

###############################################################################
# Simulation hardware                                                         #
###############################################################################

# repository path
HOSTNAME="$(hostname -s)"
export HOSTNAME
REPO_BASE_DIR="$(pwd)"
export REPO_BASE_DIR

# executable paths
export GMX_EXE='gmx'
export MPI_EXE='mpiexec'
export GMX_MPI_EXE='gmx_mpi'
export PLUMED_MPI_EXE='plumed'

# hardware input parameters
export CPU_THREADS='16'
export PIN_OFFSET='0'
export GPU_IDS='0'

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

###############################################################################
# Simulation components: Only affects system preparation                      #
###############################################################################

# polyelectrolytes
export PDB_INPUT_DIR="initial-structure" # path to .pdb input directory
export INPUT_CONFORMATION='chain-em'     # conformation tag for polymer chain
export POLY_LEN='16'                     # OPTIONS: {1, 2, 3, 4, 5, 8, 16, 32} number of monomers
export N_CHAINS='2'                      # OPTIONS: {1, 2} number of identical polymer chains
export MONOMER='Acr'                     # OPTIONS: {'Acr' acrylic} acid

# two-chain system parameters
export INITIAL_Z_SPACING_NM='2' # initial spacing between chains along z-axis
INITIAL_Z_SPACING_ANG=$(echo "${INITIAL_Z_SPACING_NM}"*10 | bc)
export INITIAL_Z_SPACING_ANG

# salt
export N_NA_ION='0'  # [# NA+] OPTIONS: whatever integer desired on top of specified M NaCl
export N_CA_ION='64' # [# Ca2+]  OPTIONS: whatever integer desired on top of specified M CaCl2

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
export HREMD_N_REPLICA='24'                                                                        # number of replicas
export HREMD_N_STEPS_EXCH='100'                                                                    # [steps] between coordinate exchange attempts
export HREMD_T_MIN="${TEMPERATURE_K}"                                                              # [K] max effective temperature in replicas
export HREMD_T_MAX='440'                                                                           # [K] max effective temperature in replicas
export HREMD_N_SIM_PER_NODE=$(((HREMD_N_REPLICA + SLURM_JOB_NUM_NODES - 1) / SLURM_JOB_NUM_NODES)) # number of replicas run per node (ceil division)
export HREMD_N_THREAD_PER_SIM=$((32 / HREMD_N_SIM_PER_NODE))                                       # number of CPU threads per replica (floor division)

# metadynamics
export CV_RG='0'                  # OPTIONS: {0, 1} whether to use radius of gyration as collective variable
export METAD_BIASFACTOR='10'      # bias factor for C.V. effective temperature
export METAD_HEIGHT='1.2'         # [kJ/mol] initial height of Gaussians (kT = 2.48 kJ/mol at 298 K)
export METAD_SIGMA='0.025'        # width of Gaussians, set to 0.33–0.5 of estimated fluctuation
export METAD_GRID_SPACING='0.005' # width of bins in the meta-dynamics grid
export METAD_GRID_MIN='0'         # minimum grid point for Gaussian deposition
export METAD_GRID_MAX='10'        # maximum grid point for Gaussian deposition
export METAD_PACE='500'           # [steps] between deposition of Gaussians

# umbrella sampling
export WINDOW_SPACING_NM='0' # [nm] distance between windows used in umbrella sampling, negative denotes decreasing spacing

# harmonic walls
export WALL_MIN='0'                               # [nm] the lower wall position
WALL_MAX="$(bc -l <<<"scale=2; ${BOX_SIZE}/2.0")" # [nm] the upper wall position
export WALL_MAX
export WALL_FORCE_CONST='600' # [kJ/mol/nm] the force constant for the walls

###############################################################################
# Simulation sampling: Periodic boundary conditions                           #
###############################################################################

# atom numbers of pull groups to evaluate periodic boundary conditions with respect to
export PBC_ATOM_CHAIN_A='0'
export PBC_ATOM_CHAIN_B='0'

###############################################################################
# Force field                                                                 #
###############################################################################

# parameters

# force field parent directory
export FF_BASE_DIR="${REPO_BASE_DIR}/force-field/small-ion-eccr-scaled-charge/eccrpa-force-fields"

# force field for specific polymer chemistry
if [[ "${MONOMER}" == "Asp" ]] || [[ "${MONOMER}" == "Glu" ]]; then
    FORCE_FIELD_NAME="amber99sb-star-ildn-q"

elif [[ "${MONOMER}" == "Acr" ]]; then
    FORCE_FIELD_NAME="gaff"

    tacticity="atactic"
    terminus_group="Hend"
    CHAIN_TAG="P${MONOMER}-${N_CHAINS}chain-${POLY_LEN}mer-${tacticity}-${terminus_group}-${INPUT_CONFORMATION}"

fi
FORCE_FIELD_DIR="${FF_BASE_DIR}/${FORCE_FIELD_NAME}.ff"

export FORCE_FIELD_NAME
export FORCE_FIELD_DIR

###############################################################################
# Simulation identifiers                                                      #
###############################################################################

# repository base directory
export PARAMETERS_DIR="${REPO_BASE_DIR}/parameters/mdp"

# Unique polyelectrolyte tag
if [[ "${MONOMER}" == "Asp" ]] || [[ "${MONOMER}" == "Glu" ]]; then
    stereochemistry="Lenantiomer"
    n_terminus_group="amine"
    c_terminus_group="carboxylicacid"
    CHAIN_TAG="P${MONOMER}-${N_CHAINS}chain-${POLY_LEN}mer-${stereochemistry}-N${n_terminus_group}-C${c_terminus_group}-${INPUT_CONFORMATION}"

elif [[ "${MONOMER}" == "Acr" ]]; then
    tacticity="atactic"
    terminus_group="Hend"
    CHAIN_TAG="P${MONOMER}-${N_CHAINS}chain-${POLY_LEN}mer-${tacticity}-${terminus_group}-${INPUT_CONFORMATION}"
fi

export CHAIN_TAG

# Unique simulation tag
TAG="${CHAIN_TAG}-${N_NA_ION}Na-${N_CA_ION}Ca-${BOX_SIZE}nmbox-${CHARGE_TYPE}EStatics-$(hostname -s)-$(date +"%F-%T.%N")"
if [[ -n "${SLURM_JOB_ID+x}" ]]; then
    TAG="sjobid_${SLURM_JOB_ID}-${TAG}"
fi

export TAG

# Unique PDB file tag
if [[ "${MONOMER}" == "Acr" ]]; then
    monomer_tags="atactic-Hend"
else
    monomer_tags="Lenantiomer-Namine-Ccarboxylicacid"
fi

# filename of initial pdb file without extension
pdb_file_tags="P${MONOMER}-${POLY_LEN}mer-${monomer_tags}-${INPUT_CONFORMATION}"

###############################################################################
# Initial structures: Only affects system preparation                         #
###############################################################################

# full path to pdb file
export PDB_FILE="${REPO_BASE_DIR}/${PDB_INPUT_DIR}/${pdb_file_tags}.pdb"
