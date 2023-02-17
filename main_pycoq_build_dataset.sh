# Goal: install of coq projs then use pycoq to mine data set
source $AFS/.bashrc.lfs
#conda activate mds_env_gpu
#conda activate metalearning_gpu
conda activate iit_synthesis
export CUDA_VISIBLE_DEVICES=5; export SLURM_JOBID=$(python -c "import random;print(random.randint(0, 1_000_000))")
echo CUDA_VISIBLE_DEVICES = $CUDA_VISIBLE_DEVICES; echo SLURM_JOBID = $SLURM_JOBID; echo hostname = $(hostname)
ulimit -n 120000; ulimit -Sn; ulimit -Hn
#nvidia-smi; (echo "GPU_ID PID UID APP" ; for GPU in 0 1 2 3 ; do for PID in $( nvidia-smi -q --id=${GPU} --display=PIDS | awk '/Process ID/{print $NF}') ; do echo -n "${GPU} ${PID} " ; ps -up ${PID} | awk 'NR-1 {print $1,$NF}' ; done ; done) | column -t; hostname; tmux ls;
nvidia-smi; (echo "GPU_ID PID MEM% UTIL% UID APP" ; for GPU in 0 1 2 3 ; do for PID in $( nvidia-smi -q --id=${GPU} --display=PIDS | awk '/Process ID/{print $NF}') ; do echo -n "${GPU} ${PID} " ; nvidia-smi -q --id=${GPU} --display=UTILIZATION | grep -A4 -E '^[[:space:]]*Utilization' | awk 'NR=0{gut=0 ;mut=0} $1=="Gpu"{gut=$3} $1=="Memory"{mut=$3} END{printf "%s %s ",mut,gut}' ; ps -up ${PID} | gawk 'NR-1 {print $1,$NF}' ; done ; done) | column -t; hostname;

(echo "GPU_ID PID UID APP" ; for GPU in 0 1 2 3 ; do for PID in $( nvidia-smi -q --id=${GPU} --display=PIDS | awk '/Process ID/{print $NF}') ; do echo -n "${GPU} ${PID} " ; ps -up ${PID} | awk 'NR-1 {print $1,$NF}' ; done ; done) | column -t

# -- Build dependencies for Coq Projects built later, which will later be used for data mining by PyCoq. Also install opam
bash $HOME/proverbot9001/pycoq_install_coqgym_deps.sh

# - install projs
sh $HOME/proverbot9001/pycoq_build_coq_projects.sh

# - scrape data (done in pycoq)
# sh pycoq_scrape_coq_projects.sh

# --- Mine data using PyCoq
# -- make sure conda & env we need is setup
source $HOME/proverbot9001/install_conda.sh
source $HOME/install_iit_python_env.sh

# -- set up env for Python
echo 'make sure bash env is setup for python script (wish I could run the python script indepdently of anything else), for now see my .bashrc.user and .bashrc.lfs'
echo '.bashrc.ls: https://github.com/brando90/.dotfiles/blob/master/.bashrc.lfs'; echo '.bashrc.user: https://github.com/brando90/.dotfiles/blob/master/.bashrc.user'
#source $AFS/.bashrc.lfs
source /afs/cs.stanford.edu/u/brando9/.bashrc.lfs
conda activate iit_synthesis

# -- mine
python -u ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/pycoq_lf_debug/' --save_flatten_data_set_as_single_json_file

# - brando's debug
#python -m pdb -c continue ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/debug_proj/' --split train --save_flatten_data_set_as_single_json_file

# - compcert
#python ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/compcert/' --split train --save_flatten_data_set_as_single_json_file

# - coqgym
#python ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/coqgym/' --split train --save_flatten_data_set_as_single_json_file
